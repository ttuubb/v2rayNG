import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/models/server_config.dart';

void main() {
  group('ServerConfig Tests', () {
    test('should create ServerConfig with valid data', () {
      final config = ServerConfig(
        name: 'Test Server',
        address: 'test.server.com',
        port: 443,
        protocol: 'vmess',
        settings: {'id': 'test-uuid', 'security': 'auto'}
      );

      expect(config.name, equals('Test Server'));
      expect(config.address, equals('test.server.com'));
      expect(config.port, equals(443));
      expect(config.protocol, equals('vmess'));
    });

    test('should validate port range', () {
      expect(
        () => ServerConfig(
          name: 'Test Server',
          address: 'test.server.com',
          port: 70000,  // Invalid port
          protocol: 'vmess',
          settings: {'id': 'test-uuid', 'security': 'auto'}
        ),
        throwsA(isA<ArgumentError>())
      );
    });

    test('should validate required fields', () {
      expect(
        () => ServerConfig(
          name: '',  // Empty name
          address: 'test.server.com',
          port: 443,
          protocol: 'vmess',
          settings: {'id': 'test-uuid', 'security': 'auto'}
        ),
        throwsA(isA<ArgumentError>())
      );
    });

    test('should convert to and from JSON', () {
      final config = ServerConfig(
        name: 'Test Server',
        address: 'test.server.com',
        port: 443,
        protocol: 'vmess',
        settings: {'id': 'test-uuid', 'security': 'auto'}
      );

      final json = config.toJson();
      final fromJson = ServerConfig.fromJson(json);

      expect(fromJson.name, equals(config.name));
      expect(fromJson.address, equals(config.address));
      expect(fromJson.port, equals(config.port));
      expect(fromJson.protocol, equals(config.protocol));
    });
  });
}