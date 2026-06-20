import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Client-side E2EE (X25519 + AES-GCM). Keys cached in memory for smooth UI.
class ChatCryptoService {
  ChatCryptoService._();

  static const _storage = FlutterSecureStorage();
  static const _privateKeyKey = 'chat_identity_private_v1';

  static final _x25519 = X25519();
  static final _aesGcm = AesGcm.with256bits();
  static SimpleKeyPair? _cachedKeyPair;
  static final Map<String, SecretKey> _conversationKeyCache = {};

  static Future<SimpleKeyPair> _loadOrCreateKeyPair() async {
    if (_cachedKeyPair != null) return _cachedKeyPair!;

    final stored = await _storage.read(key: _privateKeyKey);
    if (stored != null) {
      final map = jsonDecode(stored) as Map<String, dynamic>;
      _cachedKeyPair = SimpleKeyPairData(
        base64Decode(map['private'] as String),
        publicKey: SimplePublicKey(
          base64Decode(map['public'] as String),
          type: KeyPairType.x25519,
        ),
        type: KeyPairType.x25519,
      );
      return _cachedKeyPair!;
    }

    final keyPair = await _x25519.newKeyPair();
    final privateBytes = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();
    await _storage.write(
      key: _privateKeyKey,
      value: jsonEncode({
        'private': base64Encode(privateBytes),
        'public': base64Encode(publicKey.bytes),
      }),
    );
    _cachedKeyPair = keyPair;
    return keyPair;
  }

  static Future<SimpleKeyPair> identityKeyPair() => _loadOrCreateKeyPair();

  static Future<String> publicKeyBase64() async {
    final keyPair = await _loadOrCreateKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    return base64Encode(publicKey.bytes);
  }

  static Future<SecretKey> conversationKey({
    required String conversationId,
    required String peerPublicKeyBase64,
  }) async {
    final cacheKey = '$conversationId::$peerPublicKeyBase64';
    final cached = _conversationKeyCache[cacheKey];
    if (cached != null) return cached;

    final keyPair = await _loadOrCreateKeyPair();
    final peerBytes = base64Decode(peerPublicKeyBase64);
    final peerPublicKey = SimplePublicKey(peerBytes, type: KeyPairType.x25519);
    final shared = await _x25519.sharedSecretKey(
      keyPair: keyPair,
      remotePublicKey: peerPublicKey,
    );
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final derived = await hkdf.deriveKey(
      secretKey: shared,
      info: utf8.encode('auratalk:$conversationId'),
    );
    _conversationKeyCache[cacheKey] = derived;
    return derived;
  }

  static Future<String> encrypt({
    required String plaintext,
    required String conversationId,
    required String peerPublicKeyBase64,
  }) async {
    final key = await conversationKey(
      conversationId: conversationId,
      peerPublicKeyBase64: peerPublicKeyBase64,
    );
    final secretBox = await _aesGcm.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
    );
    final payload = {
      'v': 1,
      'n': base64Encode(secretBox.nonce),
      'c': base64Encode(secretBox.cipherText),
      'm': base64Encode(secretBox.mac.bytes),
    };
    return base64Encode(utf8.encode(jsonEncode(payload)));
  }

  static Future<String> decrypt({
    required String ciphertext,
    required String conversationId,
    required String peerPublicKeyBase64,
  }) async {
    final key = await conversationKey(
      conversationId: conversationId,
      peerPublicKeyBase64: peerPublicKeyBase64,
    );
    return _decryptWithKey(ciphertext: ciphertext, key: key);
  }

  static Future<String> _decryptWithKey({
    required String ciphertext,
    required SecretKey key,
  }) async {
    final outer = jsonDecode(utf8.decode(base64Decode(ciphertext))) as Map<String, dynamic>;
    final nonce = base64Decode(outer['n'] as String);
    final cipherText = base64Decode(outer['c'] as String);
    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(base64Decode(outer['m'] as String)),
    );
    final clear = await _aesGcm.decrypt(secretBox, secretKey: key);
    return utf8.decode(clear);
  }

  /// Batch decrypt — derives conversation key once.
  static Future<List<String>> decryptBatch({
    required List<String> ciphertexts,
    required String conversationId,
    required String peerPublicKeyBase64,
  }) async {
    if (ciphertexts.isEmpty) return [];
    final key = await conversationKey(
      conversationId: conversationId,
      peerPublicKeyBase64: peerPublicKeyBase64,
    );
    final out = <String>[];
    for (final ct in ciphertexts) {
      try {
        out.add(await _decryptWithKey(ciphertext: ct, key: key));
      } catch (_) {
        out.add('🔒 Unable to decrypt');
      }
    }
    return out;
  }
}
