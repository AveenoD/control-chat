import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Per-blob symmetric encryption for media (images/files/voice).
///
/// Each attachment gets a fresh random AES-256-GCM key. The encrypted bytes are
/// uploaded to object storage (server sees only ciphertext); the random key is
/// then carried *inside* the E2EE message body (see [ChatWire]), so only the
/// recipient devices can derive it. This mirrors WhatsApp/Signal's media model.
class MediaCryptoService {
  MediaCryptoService._();

  static final _aesGcm = AesGcm.with256bits();

  /// Encrypts [data] under a brand-new random key. Returns the self-contained
  /// blob to upload (nonce ‖ ciphertext ‖ mac) plus the base64 key to embed in
  /// the encrypted message.
  static Future<({Uint8List blob, String keyBase64})> encryptBytes(
    Uint8List data,
  ) async {
    final secretKey = await _aesGcm.newSecretKey();
    final box = await _aesGcm.encrypt(data, secretKey: secretKey);
    final nonce = box.nonce; // 12 bytes
    final mac = box.mac.bytes; // 16 bytes
    final blob = Uint8List(nonce.length + box.cipherText.length + mac.length);
    blob.setRange(0, nonce.length, nonce);
    blob.setRange(nonce.length, nonce.length + box.cipherText.length, box.cipherText);
    blob.setRange(nonce.length + box.cipherText.length, blob.length, mac);
    final keyBytes = await secretKey.extractBytes();
    return (blob: blob, keyBase64: base64Encode(keyBytes));
  }

  /// Reverses [encryptBytes]. Throws on a wrong key or tampered/truncated blob.
  static Future<Uint8List> decryptBytes(Uint8List blob, String keyBase64) async {
    const nonceLen = 12;
    const macLen = 16;
    if (blob.length < nonceLen + macLen) {
      throw ArgumentError('Blob too small');
    }
    final nonce = blob.sublist(0, nonceLen);
    final cipherText = blob.sublist(nonceLen, blob.length - macLen);
    final mac = blob.sublist(blob.length - macLen);
    final secretKey = SecretKey(base64Decode(keyBase64));
    final clear = await _aesGcm.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
      secretKey: secretKey,
    );
    return Uint8List.fromList(clear);
  }
}
