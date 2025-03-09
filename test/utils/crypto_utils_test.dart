import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/utils/crypto_utils.dart';

void main() {
  group('CryptoUtils Tests', () {
    test('AES加密解密测试', () {
      const plainText = 'Hello, V2rayNG!';
      const key = 'test-key-12345678';
      
      final encrypted = CryptoUtils.aesEncrypt(plainText, key);
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(equals(plainText)));
      
      final decrypted = CryptoUtils.aesDecrypt(encrypted, key);
      expect(decrypted, equals(plainText));
    });

    test('Base64编码解码测试', () {
      const rawData = 'Test Data 123!@#';
      
      final encoded = CryptoUtils.base64Encode(rawData);
      expect(encoded, isNotEmpty);
      expect(encoded, isNot(equals(rawData)));
      
      final decoded = CryptoUtils.base64Decode(encoded);
      expect(decoded, equals(rawData));
    });

    test('UUID验证测试', () {
      const validUuid = '123e4567-e89b-12d3-a456-426614174000';
      const invalidUuid = 'not-a-valid-uuid';
      
      expect(CryptoUtils.isValidUuid(validUuid), isTrue);
      expect(CryptoUtils.isValidUuid(invalidUuid), isFalse);
    });

    test('哈希计算测试', () {
      const input = 'test-data';
      
      final md5Hash = CryptoUtils.md5(input);
      expect(md5Hash, hasLength(32));
      expect(md5Hash, matches(RegExp(r'^[a-f0-9]{32}$')));
      
      final sha1Hash = CryptoUtils.sha1(input);
      expect(sha1Hash, hasLength(40));
      expect(sha1Hash, matches(RegExp(r'^[a-f0-9]{40}$')));
    });

    test('随机字符串生成测试', () {
      const length = 16;
      
      final random1 = CryptoUtils.generateRandomString(length);
      final random2 = CryptoUtils.generateRandomString(length);
      
      expect(random1, hasLength(length));
      expect(random2, hasLength(length));
      expect(random1, isNot(equals(random2)));
    });

    test('密码强度验证测试', () {
      const weakPassword = '12345678';
      const mediumPassword = 'Test123!';
      const strongPassword = 'Test123!@#\$%^&*';
      
      expect(CryptoUtils.checkPasswordStrength(weakPassword), equals('weak'));
      expect(CryptoUtils.checkPasswordStrength(mediumPassword), equals('medium'));
      expect(CryptoUtils.checkPasswordStrength(strongPassword), equals('strong'));
    });
  });
}