import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'chat_crypto_service.dart';
/// Group E2EE — shared symmetric key distributed per member device.
///
/// Keys are versioned by an integer `epoch`. Every membership change that must
/// revoke access (remove / leave) rotates the key (new epoch); historical
/// messages stay readable because each ciphertext carries the epoch it used and
/// every device keeps the per-epoch keys it has been sealed.
class GroupCryptoService {
  GroupCryptoService._();

  static final _aesGcm = AesGcm.with256bits();
  static final _rng = Random.secure();
  // Keyed by "$groupId:$epoch".
  static final Map<String, Uint8List> _groupKeyBytesCache = {};

  static String _ck(String groupId, int epoch) => '$groupId:$epoch';

  static Future<Uint8List> generateGroupKeyBytes() async {
    final key = Uint8List(32);
    for (var i = 0; i < key.length; i++) {
      key[i] = _rng.nextInt(256);
    }
    return key;
  }

  static String groupKeyToBase64(Uint8List key) => base64Encode(key);

  static Uint8List groupKeyFromBase64(String b64) => base64Decode(b64);

  /// Seals [groupKey] to a peer device. The sealer's identity public key is
  /// embedded (`pk`) so the recipient can ECDH-decrypt regardless of which admin
  /// performed the (re)distribution — no need to guess "the admin".
  static Future<String> encryptGroupKeyForPeer({
    required Uint8List groupKey,
    required String groupId,
    required String peerPublicKeyBase64,
  }) async {
    final keyPair = await ChatCryptoService.identityKeyPair();
    final myPub = await ChatCryptoService.publicKeyBase64();
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
      'pk': myPub,
      'n': base64Encode(secretBox.nonce),
      'c': base64Encode(secretBox.cipherText),
      'm': base64Encode(secretBox.mac.bytes),
    })));
  }

  /// Decrypts a sealed group key. Uses the sealer public key embedded in the
  /// envelope (`pk`); falls back to [fallbackPeerPublicKeyBase64] for legacy
  /// envelopes that pre-date the embedded key.
  static Future<Uint8List> decryptGroupKeyFromEnvelope({
    required String ciphertext,
    required String groupId,
    String? fallbackPeerPublicKeyBase64,
  }) async {
    final outer = jsonDecode(utf8.decode(base64Decode(ciphertext))) as Map<String, dynamic>;
    final sealerPub = (outer['pk'] as String?) ?? fallbackPeerPublicKeyBase64;
    if (sealerPub == null) {
      throw StateError('Group key envelope missing sealer public key');
    }
    final keyPair = await ChatCryptoService.identityKeyPair();
    final peerBytes = base64Decode(sealerPub);
    final peerPublicKey = SimplePublicKey(peerBytes, type: KeyPairType.x25519);
    final shared = await X25519().sharedSecretKey(keyPair: keyPair, remotePublicKey: peerPublicKey);
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final derived = await hkdf.deriveKey(
      secretKey: shared,
      info: utf8.encode('auratalk:group-key:$groupId'),
    );
    final secretBox = SecretBox(
      base64Decode(outer['c'] as String),
      nonce: base64Decode(outer['n'] as String),
      mac: Mac(base64Decode(outer['m'] as String)),
    );
    final clear = await _aesGcm.decrypt(secretBox, secretKey: derived);
    return Uint8List.fromList(clear);
  }

  static void cacheGroupKey(String groupId, int epoch, Uint8List key) {
    _groupKeyBytesCache[_ck(groupId, epoch)] = key;
  }

  static Uint8List? cachedGroupKey(String groupId, int epoch) =>
      _groupKeyBytesCache[_ck(groupId, epoch)];

  /// Highest cached epoch for [groupId], or null if none cached.
  static int? highestCachedEpoch(String groupId) {
    int? best;
    final prefix = '$groupId:';
    for (final k in _groupKeyBytesCache.keys) {
      if (k.startsWith(prefix)) {
        final ep = int.tryParse(k.substring(prefix.length));
        if (ep != null && (best == null || ep > best)) best = ep;
      }
    }
    return best;
  }

  /// Reads the key epoch a group ciphertext was encrypted with. Legacy messages
  /// without `ep` default to epoch 1.
  static int ciphertextEpoch(String ciphertext) {
    try {
      final outer = jsonDecode(utf8.decode(base64Decode(ciphertext))) as Map<String, dynamic>;
      final ep = outer['ep'];
      if (ep is int) return ep;
      if (ep is num) return ep.toInt();
    } catch (_) {}
    return 1;
  }

  static Future<String> encryptMessage({
    required String groupId,
    required Uint8List groupKey,
    required int epoch,
    required String plaintext,
  }) async {
    final secretBox = await _aesGcm.encrypt(utf8.encode(plaintext), secretKey: SecretKey(groupKey));
    return base64Encode(utf8.encode(jsonEncode({
      'v': 1,
      'ep': epoch,
      'n': base64Encode(secretBox.nonce),
      'c': base64Encode(secretBox.cipherText),
      'm': base64Encode(secretBox.mac.bytes),
    })));
  }

  static Future<String> decryptMessage({
    required Uint8List groupKey,
    required String ciphertext,
  }) async {
    final outer = jsonDecode(utf8.decode(base64Decode(ciphertext))) as Map<String, dynamic>;
    final secretBox = SecretBox(
      base64Decode(outer['c'] as String),
      nonce: base64Decode(outer['n'] as String),
      mac: Mac(base64Decode(outer['m'] as String)),
    );
    final clear = await _aesGcm.decrypt(secretBox, secretKey: SecretKey(groupKey));
    return utf8.decode(clear);
  }
}
