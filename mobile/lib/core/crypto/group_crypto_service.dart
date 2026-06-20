import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'chat_crypto_service.dart';
/// Group E2EE — shared symmetric key distributed per member device.
class GroupCryptoService {
  GroupCryptoService._();

  static final _aesGcm = AesGcm.with256bits();
  static final _rng = Random.secure();
  static final Map<String, SecretKey> _groupKeyCache = {};
  static final Map<String, Uint8List> _groupKeyBytesCache = {};

  static Future<Uint8List> generateGroupKeyBytes() async {
    final key = Uint8List(32);
    for (var i = 0; i < key.length; i++) {
      key[i] = _rng.nextInt(256);
    }
    return key;
  }

  static String groupKeyToBase64(Uint8List key) => base64Encode(key);

  static Uint8List groupKeyFromBase64(String b64) => base64Decode(b64);

  static Future<String> encryptGroupKeyForPeer({
    required Uint8List groupKey,
    required String groupId,
    required String peerPublicKeyBase64,
  }) async {
    final keyPair = await ChatCryptoService.identityKeyPair();
    final peerBytes = base64Decode(peerPublicKeyBase64);
    final peerPublicKey = SimplePublicKey(peerBytes, type: KeyPairType.x25519);
    final shared = await X25519().sharedSecretKey(keyPair: keyPair, remotePublicKey: peerPublicKey);
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final derived = await hkdf.deriveKey(
      secretKey: shared,
      info: utf8.encode('auratalk:group-key:$groupId'),
    );
    final secretBox = await _aesGcm.encrypt(groupKey, secretKey: derived);
    return base64Encode(utf8.encode(jsonEncode({
      'v': 1,
      'n': base64Encode(secretBox.nonce),
      'c': base64Encode(secretBox.cipherText),
      'm': base64Encode(secretBox.mac.bytes),
    })));
  }

  static Future<Uint8List> decryptGroupKeyFromEnvelope({
    required String ciphertext,
    required String groupId,
    required String peerPublicKeyBase64,
  }) async {
    final keyPair = await ChatCryptoService.identityKeyPair();
    final peerBytes = base64Decode(peerPublicKeyBase64);
    final peerPublicKey = SimplePublicKey(peerBytes, type: KeyPairType.x25519);
    final shared = await X25519().sharedSecretKey(keyPair: keyPair, remotePublicKey: peerPublicKey);
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final derived = await hkdf.deriveKey(
      secretKey: shared,
      info: utf8.encode('auratalk:group-key:$groupId'),
    );
    final outer = jsonDecode(utf8.decode(base64Decode(ciphertext))) as Map<String, dynamic>;
    final secretBox = SecretBox(
      base64Decode(outer['c'] as String),
      nonce: base64Decode(outer['n'] as String),
      mac: Mac(base64Decode(outer['m'] as String)),
    );
    final clear = await _aesGcm.decrypt(secretBox, secretKey: derived);
    return Uint8List.fromList(clear);
  }

  static void cacheGroupKey(String groupId, Uint8List key) {
    _groupKeyBytesCache[groupId] = key;
    _groupKeyCache[groupId] = SecretKey(key);
  }

  static Uint8List? cachedGroupKey(String groupId) => _groupKeyBytesCache[groupId];

  static Future<String> encryptMessage({
    required String groupId,
    required Uint8List groupKey,
    required String plaintext,
  }) async {
    final secretKey = _groupKeyCache[groupId] ?? SecretKey(groupKey);
    _groupKeyCache[groupId] = secretKey;
    final secretBox = await _aesGcm.encrypt(utf8.encode(plaintext), secretKey: secretKey);
    return base64Encode(utf8.encode(jsonEncode({
      'v': 1,
      'n': base64Encode(secretBox.nonce),
      'c': base64Encode(secretBox.cipherText),
      'm': base64Encode(secretBox.mac.bytes),
    })));
  }

  static Future<String> decryptMessage({
    required String groupId,
    required Uint8List groupKey,
    required String ciphertext,
  }) async {
    final secretKey = _groupKeyCache[groupId] ?? SecretKey(groupKey);
    final outer = jsonDecode(utf8.decode(base64Decode(ciphertext))) as Map<String, dynamic>;
    final secretBox = SecretBox(
      base64Decode(outer['c'] as String),
      nonce: base64Decode(outer['n'] as String),
      mac: Mac(base64Decode(outer['m'] as String)),
    );
    final clear = await _aesGcm.decrypt(secretBox, secretKey: secretKey);
    return utf8.decode(clear);
  }
}
