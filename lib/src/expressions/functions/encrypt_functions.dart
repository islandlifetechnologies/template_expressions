import 'dart:convert' as convert;
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

/// Functions related to AES and RSA encryption.
class EncryptFunctions {
  /// The functions related to JsonPath processing.
  static final functions = {
    'AES': () => Aes(),
    'IV': _createIv,
    'RSA': () => Rsa(),
  };
}

/// Functions related to the AES encryption
class Aes {
  static final Map<String, BlockCipher> _ciphers = {
    'CBC': PaddedBlockCipher('AES/CBC/PKCS7'),
    'ECB': PaddedBlockCipher('AES/ECB/PKCS7'),
  };

  BlockCipher _cipher = _ciphers['CBC']!;
  Uint8List? _key;
  Uint8List? _iv;

  /// Decrypts the encrypted string.  This supports having a pre-set [IV] or
  /// having the [IV] encoded on the [value] by having the [value] encoded as
  /// `${base64Iv}:${base64EncryptedValue}`.
  List<int> decrypt(String value) {
    var iv = _iv;
    var encrypted = value;
    if (iv == null || value.contains(':')) {
      final parts = value.split(':');

      if (parts.length != 2) {
        throw Exception('Attempted to AES decrypt but no IV has been set.');
      }

      iv ??= convert.base64.decode(parts[0]);
      encrypted = parts[1];
    }

    final key = _key;

    if (key == null) {
      throw Exception('Attempted to AES decrypt but no key has been set.');
    }

    final result = _aesDecrypt(key, iv, convert.base64.decode(encrypted));

    return result;
  }

  /// Encrypts the given value.  If an [IV] was pre-set, that [IV] will be used
  /// otherwise a new random one will be created.  The resulting string will be
  /// returned in the following form: `${base64Iv}:${base64EncryptedValue}`.
  String encrypt(dynamic value) {
    Uint8List bytes;

    if (value == null) {
      throw Exception('Required value is null');
    } else if (value is List<int>) {
      bytes = Uint8List.fromList(value);
    } else if (value is Uint8List) {
      bytes = value;
    } else if (value is String) {
      bytes = convert.utf8.encode(value);
    } else {
      bytes = convert.utf8.encode(value.toString());
    }

    final iv = _iv ?? _createIv();
    final key = _key;

    if (key == null) {
      throw Exception('Attempted to AES encrypt but no key has been set.');
    }

    final result = _aesEncrypt(key, iv, bytes);

    return '${convert.base64.encode(iv)}:${convert.base64.encode(result)}';
  }

  /// Sets the [IV] for use.
  Aes iv(dynamic iv) {
    _iv = _createIv(iv);
    return this;
  }

  /// Sets the secret key on the object.
  Aes key(dynamic key) {
    if (key is List<int>) {
      _key = Uint8List.fromList(key);
    } else if (key is Uint8List) {
      _key = key;
    } else if (key is String) {
      _key = convert.base64.decode(key);
    } else {
      throw Exception('Unknown key type: [${key?.runtimeType.toString()}]');
    }

    return this;
  }

  /// Sets the AES encryption [mode].
  Aes mode(String mode) {
    final cipher = _ciphers[mode.toUpperCase()];

    if (cipher == null) {
      throw Exception('Unknown AES mode: [$mode]');
    }

    cipher.reset();
    _cipher = cipher;

    return this;
  }

  /// Sets the AES encryption [padding].
  @Deprecated('No longer does anything as PKCS7 is the only supported option')
  Aes padding(String padding) => this;

  Uint8List _aesDecrypt(Uint8List key, Uint8List iv, Uint8List cipherText) {
    final ivParams = ParametersWithIV<KeyParameter>(KeyParameter(key), iv);
    final paddingParams =
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
          ivParams,
          null,
        );

    _cipher.init(false, paddingParams); // false=decrypt
    return _cipher.process(cipherText);
  }

  Uint8List _aesEncrypt(Uint8List key, Uint8List iv, Uint8List plaintext) {
    final ivParams = ParametersWithIV<KeyParameter>(KeyParameter(key), iv);
    final paddingParams =
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
          ivParams,
          null,
        );
    _cipher.init(true, paddingParams); // true=encrypt

    return _cipher.process(plaintext);
  }
}

class Rsa {
  static final Map<String, (Digest, String)> _digests = {
    'SHA256': (SHA256Digest(), '0609608648016503040201'),
    'SHA512': (SHA512Digest(), '0609608648016503040203'),
  };

  Aes? _aes;
  String _digest = 'SHA256';
  AsymmetricBlockCipher _encoding = PKCS1Encoding(RSAEngine());
  RSAPrivateKey? _privateKey;
  RSAPublicKey? _publicKey;

  /// Sets the [Aes] object to use when performing the encryption of the data.
  Rsa aes(Aes aes) {
    _aes = aes;

    return this;
  }

  /// Decrypts the given [value] and returns the resulting bytes.  This expects
  /// the passed in value to be of the format:
  /// `${rsaEncryptedAesKey}:${base64Iv}:${base64EncryptedValue}`
  List<int> decrypt(String value) {
    final parts = value.split(':');
    final encrypted = '${parts[1]}:${parts[2]}';

    final aes = _aes ?? Aes();

    final privateKey = _privateKey;
    if (privateKey == null) {
      throw Exception('RSA attempted to decrypt but [privateKey] is null');
    }

    final key = _rsaDecrypt(privateKey, convert.base64.decode(parts[0]));

    final result = aes.key(key).decrypt(encrypted);

    return result;
  }

  /// Sets the [Digest] to use for signing and verifying.
  Rsa digest(dynamic digest) {
    if (digest is String) {
      switch (digest) {
        case 'SHA256':
        case 'SHA512':
          _digest = digest;
          break;

        default:
          throw Exception('Unknown RSA Digest value encountered: [$digest]');
      }
    } else {
      throw Exception(
        'Unknown RSA Digest type: [${digest?.runtimeType.toString()}]',
      );
    }

    return this;
  }

  /// Sets the [AsymmetricBlockCipher] to use for RSA based encryption values.
  Rsa encoding(dynamic encoding) {
    if (encoding is AsymmetricBlockCipher) {
      _encoding = encoding;
    } else if (encoding is String) {
      switch (encoding) {
        case 'OAEP':
          _encoding = OAEPEncoding(RSAEngine());
          break;

        case 'PKCS1':
          _encoding = PKCS1Encoding(RSAEngine());
          break;

        default:
          throw Exception(
            'Unknown RSA Encoding value encountered: [$encoding]',
          );
      }
    } else {
      throw Exception(
        'Unknown RSA Encoding type: [${encoding?.runtimeType.toString()}]',
      );
    }

    return this;
  }

  /// If an [Aes] object is already set, this will use that object.  Otherwise,
  /// it will...
  /// 1. Create a new [Aes] object.
  /// 2. Create a new AES key and set it on the object.
  /// 3. Create a new IV and set it on the object.
  ///
  /// Either way, next this will RSA encrypt the AES key, encrypt the [value]
  /// using the [Aes] object.
  ///
  /// The returned string will be encoded as:
  /// `${rsaEncryptedAesKey}:${base64Iv}:${base64EncryptedValue}`
  String encrypt(dynamic value) {
    List<int> bytes;

    if (value == null) {
      throw Exception('Required value is null');
    } else if (value is List<int>) {
      bytes = value;
    } else if (value is Uint8List) {
      bytes = value.toList();
    } else if (value is String) {
      bytes = convert.utf8.encode(value);
    } else {
      bytes = convert.utf8.encode(value.toString());
    }

    final publicKey = _publicKey;
    if (publicKey == null) {
      throw Exception('RSA attempted to encrypt but [publicKey] is null');
    }

    final aes = _aes ?? Aes();
    final key =
        aes._key ??
        _createSecureRandom().nextBytes(
          256 /* bits */ ~/ 8 /* bits-per-byte */,
        );

    final result = aes.key(key).encrypt(bytes);

    final encryptedKey = _rsaEncrypt(publicKey, key);

    return '${convert.base64.encode(encryptedKey)}:$result';
  }

  /// Sets the private key on this encryption object.
  Rsa privateKey(dynamic key) {
    if (key is RSAPrivateKey) {
      _privateKey = key;
    } else if (key is String) {
      _privateKey = RSAKeyParser().parse(key) as RSAPrivateKey;
    } else {
      throw Exception(
        'Unknown privateKey type: [${key?.runtimeType.toString()}]',
      );
    }

    return this;
  }

  /// Sets the public key on this encryption object.
  Rsa publicKey(dynamic key) {
    if (key is RSAPublicKey) {
      _publicKey = key;
    } else if (key is String) {
      _publicKey = RSAKeyParser().parse(key) as RSAPublicKey;
    } else {
      throw Exception(
        'Unknown publicKey type: [${key?.runtimeType.toString()}]',
      );
    }

    return this;
  }

  /// Signs the [value] and returns the resulting byte array.
  List<int> sign(dynamic value) {
    final privateKey = _privateKey;
    if (privateKey == null) {
      throw Exception('RSA attempted to sign but [privateKey] is null');
    }

    Uint8List bytes;

    if (value == null) {
      throw Exception('Required value is null');
    } else if (value is List<int>) {
      bytes = Uint8List.fromList(value);
    } else if (value is Uint8List) {
      bytes = value;
    } else if (value is String) {
      bytes = convert.utf8.encode(value);
    } else {
      bytes = convert.utf8.encode(value.toString());
    }

    return _rsaSign(privateKey, bytes);
  }

  /// Verifies the [value] and the [signature].
  bool verify(dynamic value, dynamic signature) {
    final publicKey = _publicKey;
    if (publicKey == null) {
      throw Exception('RSA attempted to verify but [publicKey] is null');
    }

    Uint8List bytes;
    Uint8List sigBytes;

    if (value == null) {
      throw Exception('Required value is null');
    } else if (value is List<int>) {
      bytes = Uint8List.fromList(value);
    } else if (value is Uint8List) {
      bytes = value;
    } else if (value is String) {
      bytes = convert.utf8.encode(value);
    } else {
      bytes = convert.utf8.encode(value.toString());
    }

    if (signature == null) {
      throw Exception('Required signature is null');
    } else if (signature is List<int>) {
      sigBytes = Uint8List.fromList(signature);
    } else if (signature is Uint8List) {
      sigBytes = signature;
    } else if (signature is String) {
      sigBytes = convert.base64.decode(signature);
    } else {
      sigBytes = convert.base64.decode(signature.toString());
    }

    return _rsaVerify(publicKey, bytes, sigBytes);
  }

  Uint8List _rsaDecrypt(RSAPrivateKey myPrivate, Uint8List cipherText) {
    final decryptor = _encoding
      ..init(
        false,
        PrivateKeyParameter<RSAPrivateKey>(myPrivate),
      ); // false=decrypt

    return decryptor.process(cipherText);

    // return _processInBlocks(decryptor, cipherText);
  }

  Uint8List _rsaEncrypt(RSAPublicKey myPublic, Uint8List dataToEncrypt) {
    final encryptor = _encoding
      ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic));

    return encryptor.process(dataToEncrypt);
    // return _processInBlocks(encryptor, dataToEncrypt);
  }

  Uint8List _rsaSign(RSAPrivateKey privateKey, Uint8List dataToSign) {
    final (digest, hex) = _digests[_digest]!;
    final signer = RSASigner(digest, hex);

    signer.init(
      true,
      PrivateKeyParameter<RSAPrivateKey>(privateKey),
    ); // true=sign

    final sig = signer.generateSignature(dataToSign);

    return sig.bytes;
  }

  bool _rsaVerify(
    RSAPublicKey publicKey,
    Uint8List signedData,
    Uint8List signature,
  ) {
    final (digest, hex) = _digests[_digest]!;
    final sig = RSASignature(signature);

    final verifier = RSASigner(digest, hex);

    verifier.init(
      false,
      PublicKeyParameter<RSAPublicKey>(publicKey),
    ); // false=verify

    try {
      return verifier.verifySignature(signedData, sig);
    } catch (e) {
      return false;
    }
  }
}

class RSAKeyParser {
  /// Parses the PEM key no matter it is public or private, it will figure it out.
  RSAAsymmetricKey parse(String key) {
    final rows = key.split(RegExp(r'\r\n?|\n'));
    final header = rows.first;

    if (header == '-----BEGIN RSA PUBLIC KEY-----') {
      return _parsePublic(_parseSequence(rows));
    }

    if (header == '-----BEGIN PUBLIC KEY-----') {
      return _parsePublic(_pkcs8PublicSequence(_parseSequence(rows)));
    }

    if (header == '-----BEGIN RSA PRIVATE KEY-----') {
      return _parsePrivate(_parseSequence(rows));
    }

    if (header == '-----BEGIN PRIVATE KEY-----') {
      return _parsePrivate(_pkcs8PrivateSequence(_parseSequence(rows)));
    }

    throw FormatException('Unable to parse key, invalid format.', header);
  }

  RSAAsymmetricKey _parsePublic(ASN1Sequence sequence) {
    final modulus = (sequence.elements![0] as ASN1Integer).integer!;
    final exponent = (sequence.elements![1] as ASN1Integer).integer!;

    return RSAPublicKey(modulus, exponent);
  }

  RSAAsymmetricKey _parsePrivate(ASN1Sequence sequence) {
    final modulus = (sequence.elements![1] as ASN1Integer).integer!;
    final exponent = (sequence.elements![3] as ASN1Integer).integer!;
    final p = (sequence.elements![4] as ASN1Integer).integer!;
    final q = (sequence.elements![5] as ASN1Integer).integer!;

    return RSAPrivateKey(modulus, exponent, p, q);
  }

  ASN1Sequence _parseSequence(List<String> rows) {
    final keyText = rows
        .skipWhile((row) => row.startsWith('-----BEGIN'))
        .takeWhile((row) => !row.startsWith('-----END'))
        .map((row) => row.trim())
        .join('');

    final keyBytes = Uint8List.fromList(convert.base64.decode(keyText));
    final asn1Parser = ASN1Parser(keyBytes);

    return asn1Parser.nextObject() as ASN1Sequence;
  }

  ASN1Sequence _pkcs8PublicSequence(ASN1Sequence sequence) {
    final bitString = sequence.elements![1];
    final bytes = bitString.valueBytes!.sublist(1);
    final parser = ASN1Parser(Uint8List.fromList(bytes));

    return parser.nextObject() as ASN1Sequence;
  }

  ASN1Sequence _pkcs8PrivateSequence(ASN1Sequence sequence) {
    final bitString = sequence.elements![2];
    final bytes = bitString.valueBytes!;
    final parser = ASN1Parser(bytes);

    return parser.nextObject() as ASN1Sequence;
  }
}

Uint8List _createIv([dynamic value]) {
  Uint8List iv;

  if (value is Uint8List) {
    iv = value;
  } else if (value == null) {
    iv = _createSecureRandom().nextBytes(16);
  } else if (value is int) {
    iv = _createSecureRandom().nextBytes(value);
  } else if (value is List<int>) {
    iv = Uint8List.fromList(value);
  } else if (value is String) {
    iv = convert.base64.decode(value);
  } else {
    throw Exception('Unknown IV type: [${value.runtimeType}');
  }

  return iv;
}

SecureRandom _createSecureRandom() {
  final secureRandom = FortunaRandom();

  final seedSource = Random.secure();
  final seeds = <int>[];
  for (var i = 0; i < 32; i++) {
    seeds.add(seedSource.nextInt(255));
  }
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

  return secureRandom;
}
