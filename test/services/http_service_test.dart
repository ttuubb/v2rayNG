import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:v2rayng/services/http_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('HttpService Tests', () {
    late HttpService httpService;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      httpService = HttpService(client: mockHttpClient);
    });

    test('GET请求测试', () async {
      const url = 'https://example.com/api';
      final response = http.Response('{\'data\': \'test\'}', 200);

      when(mockHttpClient.get(Uri.parse(url)))
          .thenAnswer((_) async => response);

      final result = await httpService.get(url);
      expect(result.statusCode, equals(200));
      expect(result.body, equals('{\'data\': \'test\'}'));
    });

    test('POST请求测试', () async {
      const url = 'https://example.com/api';
      const body = '{\'test\': \'data\'}';
      final response = http.Response('{\'success\': true}', 200);

      when(mockHttpClient.post(
        Uri.parse(url),
        body: body,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => response);

      final result = await httpService.post(url, body);
      expect(result.statusCode, equals(200));
      expect(result.body, equals('{\'success\': true}'));
    });

    test('网络错误处理测试', () async {
      const url = 'https://example.com/api';

      when(mockHttpClient.get(Uri.parse(url)))
          .thenThrow(Exception('Network error'));

      expect(
        () => httpService.get(url),
        throwsA(isA<Exception>()),
      );
    });

    test('超时处理测试', () async {
      const url = 'https://example.com/api';

      when(mockHttpClient.get(Uri.parse(url)))
          .thenThrow(TimeoutException('Request timeout'));

      expect(
        () => httpService.get(url),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}