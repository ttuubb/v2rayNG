import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart' as encrypt;

/// 加密工具类
/// 提供常用的加密、解密、编码、解码等功能
class CryptoUtils {
  /// AES加密
  /// [plainText] 明文
  /// [key] 密钥
  /// 返回加密后的字符串
  static String aesEncrypt(String plainText, String key) {
    final keyBytes = utf8.encode(key);
    final paddedKey =
        keyBytes.length < 32 ? _padList(keyBytes, 32) : keyBytes.sublist(0, 32);

    final encrypter = encrypt.Encrypter(encrypt.AES(
      encrypt.Key(paddedKey),
      mode: encrypt.AESMode.cbc,
      padding: 'PKCS7',
    ));

    // 使用固定的IV以确保加密和解密一致
    final iv = encrypt.IV.fromUtf8('1234567890123456');
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return encrypted.base64;
  }

  /// AES解密
  /// [encryptedText] 密文
  /// [key] 密钥
  /// 返回解密后的字符串
  static String aesDecrypt(String encryptedText, String key) {
    final keyBytes = utf8.encode(key);
    final paddedKey =
        keyBytes.length < 32 ? _padList(keyBytes, 32) : keyBytes.sublist(0, 32);

    final encrypter = encrypt.Encrypter(encrypt.AES(
      encrypt.Key(paddedKey),
      mode: encrypt.AESMode.cbc,
      padding: 'PKCS7',
    ));

    // 使用与加密相同的IV
    final iv = encrypt.IV.fromUtf8('1234567890123456');
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);

    return decrypted;
  }

  /// Base64编码
  /// [data] 原始数据
  /// 返回Base64编码后的字符串
  static String base64Encode(String data) {
    final bytes = utf8.encode(data);
    return base64.encode(bytes);
  }

  /// Base64解码
  /// [encodedData] Base64编码的字符串
  /// 返回解码后的字符串
  static String base64Decode(String encodedData) {
    final bytes = base64.decode(encodedData);
    return utf8.decode(bytes);
  }

  /// 验证UUID是否有效
  /// [uuid] UUID字符串
  /// 返回是否为有效的UUID
  static bool isValidUuid(String uuid) {
    final RegExp uuidRegExp = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegExp.hasMatch(uuid);
  }

  /// 计算MD5哈希值
  /// [input] 输入字符串
  /// 返回MD5哈希值的十六进制字符串
  static String md5(String input) {
    final bytes = utf8.encode(input);
    final digest = crypto.md5.convert(bytes);
    return digest.toString();
  }

  /// 计算SHA1哈希值
  /// [input] 输入字符串
  /// 返回SHA1哈希值的十六进制字符串
  static String sha1(String input) {
    final bytes = utf8.encode(input);
    final digest = crypto.sha1.convert(bytes);
    return digest.toString();
  }

  /// 生成指定长度的随机字符串
  /// [length] 字符串长度
  /// 返回随机字符串
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// 检查密码强度
  /// [password] 密码
  /// 返回密码强度评级：'weak', 'medium', 'strong'
  static String checkPasswordStrength(String password) {
    if (password.length < 8) {
      return 'weak';
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = 0;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialChars) strength++;

    if (strength >= 4 && password.length >= 12) {
      return 'strong';
    } else if (strength >= 3) {
      return 'medium';
    } else {
      return 'weak';
    }
  }

  /// 辅助方法：填充列表到指定长度
  /// [list] 原始列表
  /// [length] 目标长度
  /// [padValue] 填充值
  /// 返回填充后的列表
  static Uint8List _padList(List<int> list, int length, [int padValue = 0]) {
    if (list.length >= length) return Uint8List.fromList(list);

    final result = List<int>.from(list);
    while (result.length < length) {
      result.add(padValue);
    }

    return Uint8List.fromList(result);
  }
}
