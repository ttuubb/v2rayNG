import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/models/config_model.dart';

void main() {
  group('ConfigModel Tests', () {
    test('序列化和反序列化测试', () {
      final config = ConfigModel(
        protocol: 'vmess',
        address: 'example.com',
        port: 443,
        uuid: 'test-uuid',
        alterId: 0,
        security: 'auto',
        network: 'tcp',
      );

      final json = config.toJson();
      final decodedConfig = ConfigModel.fromJson(json);

      expect(decodedConfig.protocol, equals('vmess'));
      expect(decodedConfig.address, equals('example.com'));
      expect(decodedConfig.port, equals(443));
      expect(decodedConfig.uuid, equals('test-uuid'));
      expect(decodedConfig.alterId, equals(0));
      expect(decodedConfig.security, equals('auto'));
      expect(decodedConfig.network, equals('tcp'));
    });

    test('数据验证逻辑测试', () {
      final config = ConfigModel(
        protocol: 'vmess',
        address: 'example.com',
        port: 443,
        uuid: 'test-uuid',
        alterId: 0,
        security: 'auto',
        network: 'tcp',
      );

      expect(config.validate(), isTrue);

      // 测试无效端口
      final invalidPortConfig = config.copyWith(port: 65536);
      expect(invalidPortConfig.validate(), isFalse);

      // 测试无效地址
      final invalidAddressConfig = config.copyWith(address: '');
      expect(invalidAddressConfig.validate(), isFalse);

      // 测试无效UUID
      final invalidUuidConfig = config.copyWith(uuid: 'invalid-uuid');
      expect(invalidUuidConfig.validate(), isFalse);
    });

    test('边界条件测试', () {
      // 测试最小端口号
      final minPortConfig = ConfigModel(
        protocol: 'vmess',
        address: 'example.com',
        port: 1,
        uuid: 'test-uuid',
        alterId: 0,
        security: 'auto',
        network: 'tcp',
      );
      expect(minPortConfig.validate(), isTrue);

      // 测试最大端口号
      final maxPortConfig = ConfigModel(
        protocol: 'vmess',
        address: 'example.com',
        port: 65535,
        uuid: 'test-uuid',
        alterId: 0,
        security: 'auto',
        network: 'tcp',
      );
      expect(maxPortConfig.validate(), isTrue);

      // 测试最大alterId
      final maxAlterIdConfig = ConfigModel(
        protocol: 'vmess',
        address: 'example.com',
        port: 443,
        uuid: 'test-uuid',
        alterId: 65535,
        security: 'auto',
        network: 'tcp',
      );
      expect(maxAlterIdConfig.validate(), isTrue);
    });

    test('配置导入导出测试', () {
      final config = ConfigModel(
        protocol: 'vmess',
        address: 'example.com',
        port: 443,
        uuid: 'test-uuid',
        alterId: 0,
        security: 'auto',
        network: 'tcp',
      );

      // 测试配置导出为字符串
      final exportedStr = config.toString();
      expect(exportedStr, isNotEmpty);

      // 测试从字符串导入配置
      final importedConfig = ConfigModel.fromString(exportedStr);
      expect(importedConfig.protocol, equals(config.protocol));
      expect(importedConfig.address, equals(config.address));
      expect(importedConfig.port, equals(config.port));
      expect(importedConfig.uuid, equals(config.uuid));
    });

    test('配置更新测试', () {
      final config = ConfigModel(
        protocol: 'vmess',
        address: 'example.com',
        port: 443,
        uuid: 'test-uuid',
        alterId: 0,
        security: 'auto',
        network: 'tcp',
      );

      // 测试更新单个字段
      final updatedConfig = config.copyWith(port: 8080);
      expect(updatedConfig.port, equals(8080));
      expect(updatedConfig.address, equals(config.address));

      // 测试更新多个字段
      final multiUpdatedConfig = config.copyWith(
          port: 8080, address: 'new.example.com', security: 'none');
      expect(multiUpdatedConfig.port, equals(8080));
      expect(multiUpdatedConfig.address, equals('new.example.com'));
      expect(multiUpdatedConfig.security, equals('none'));
    });

    test('配置加密解密测试', () {
      final config = ConfigModel(
        protocol: 'vmess',
        address: 'example.com',
        port: 443,
        uuid: 'test-uuid',
        alterId: 0,
        security: 'auto',
        network: 'tcp',
      );

      // 测试配置加密
      final encryptedConfig = config.encrypt('testPassword');
      expect(encryptedConfig, isNotEmpty);

      // 测试配置解密
      final decryptedConfig =
          ConfigModel.decrypt(encryptedConfig, 'testPassword');
      expect(decryptedConfig.protocol, equals(config.protocol));
      expect(decryptedConfig.address, equals(config.address));
      expect(decryptedConfig.port, equals(config.port));
      expect(decryptedConfig.uuid, equals(config.uuid));

      // 测试错误密码
      expect(
        () => ConfigModel.decrypt(encryptedConfig, 'wrongPassword'),
        throwsException,
      );
    });

    test('配置版本兼容性测试', () {
      // 测试旧版本配置格式
      final oldVersionJson = {
        'ver': 1,
        'protocol': 'vmess',
        'addr': 'example.com', // 旧版本使用'addr'而不是'address'
        'port': 443,
        'id': 'test-uuid', // 旧版本使用'id'而不是'uuid'
        'aid': 0, // 旧版本使用'aid'而不是'alterId'
        'security': 'auto',
        'net': 'tcp', // 旧版本使用'net'而不是'network'
      };

      final config = ConfigModel.fromJson(oldVersionJson);
      expect(config.protocol, equals('vmess'));
      expect(config.address, equals('example.com'));
      expect(config.port, equals(443));
      expect(config.uuid, equals('test-uuid'));
      expect(config.alterId, equals(0));
      expect(config.security, equals('auto'));
      expect(config.network, equals('tcp'));

      // 验证转换后的配置仍然有效
      expect(config.validate(), isTrue);
    });

    test('配置迁移测试', () {
      final oldConfig = ConfigModel(
        protocol: 'vmess',
        address: 'old.example.com',
        port: 443,
        uuid: 'old-uuid',
        alterId: 1, // 旧的 alterId 值
        security: 'aes-128-gcm',
        network: 'tcp',
      );

      // 测试配置迁移到新版本
      final migratedConfig = oldConfig.migrate();
      expect(migratedConfig.alterId, equals(0)); // 新版本默认使用 alterId 0
      expect(migratedConfig.security, equals('auto')); // 新版本默认使用 auto

      // 验证其他字段保持不变
      expect(migratedConfig.protocol, equals(oldConfig.protocol));
      expect(migratedConfig.address, equals(oldConfig.address));
      expect(migratedConfig.port, equals(oldConfig.port));
      expect(migratedConfig.uuid, equals(oldConfig.uuid));
      expect(migratedConfig.network, equals(oldConfig.network));
    });

    test('配置验证测试 - 特殊字符', () {
      // 测试地址中包含特殊字符
      final specialCharConfig = ConfigModel(
        protocol: 'vmess',
        address: 'test!@#.com',
        port: 443,
        uuid: 'test-uuid',
        alterId: 0,
        security: 'auto',
        network: 'tcp',
      );
      expect(specialCharConfig.validate(), isFalse);

      // 测试包含中文字符
      final chineseCharConfig = ConfigModel(
        protocol: 'vmess',
        address: '测试.com',
        port: 443,
        uuid: 'test-uuid',
        alterId: 0,
        security: 'auto',
        network: 'tcp',
      );
      expect(chineseCharConfig.validate(), isFalse);
    });
  });
}
