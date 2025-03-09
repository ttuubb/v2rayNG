import 'package:flutter_test/flutter_test.dart';
import 'package:v2rayng/utils/url_utils.dart';

void main() {
  group('UrlUtils Tests', () {
    test('URL解析测试', () {
      const testUrl = 'https://example.com:443/path?param=value#fragment';
      final parsedUrl = UrlUtils.parseUrl(testUrl);

      expect(parsedUrl.scheme, equals('https'));
      expect(parsedUrl.host, equals('example.com'));
      expect(parsedUrl.port, equals(443));
      expect(parsedUrl.path, equals('/path'));
      expect(parsedUrl.query, equals('param=value'));
      expect(parsedUrl.fragment, equals('fragment'));
    });

    test('特殊字符URL解析测试', () {
      const testUrl = 'https://example.com/path%20with%20spaces?q=test%26more';
      final parsedUrl = UrlUtils.parseUrl(testUrl);

      expect(Uri.decodeComponent(parsedUrl.path), equals('/path with spaces'));
      expect(UrlUtils.decodeQuery(parsedUrl.query), equals({'q': 'test&more'}));
    });

    test('无效URL测试', () {
      const invalidUrl = 'not_a_valid_url';
      expect(
        () => UrlUtils.parseUrl(invalidUrl),
        throwsFormatException,
      );
    });

    test('URL编码测试', () {
      const rawString = 'Hello World & More!';
      final encoded = UrlUtils.encodeComponent(rawString);
      expect(encoded, equals('Hello%20World%20%26%20More%21'));

      final decoded = UrlUtils.decodeComponent(encoded);
      expect(decoded, equals(rawString));
    });

    test('查询参数解析测试', () {
      const queryString = 'name=test&age=25&tags=a,b,c';
      final params = UrlUtils.parseQueryString(queryString);

      expect(params['name'], equals('test'));
      expect(params['age'], equals('25'));
      expect(params['tags'], equals('a,b,c'));
    });

    test('URL构建测试', () {
      final urlParts = {
        'scheme': 'https',
        'host': 'example.com',
        'port': '443',
        'path': '/api/v1',
        'query': 'key=value'
      };

      final builtUrl = UrlUtils.buildUrl(urlParts);
      expect(builtUrl, equals('https://example.com:443/api/v1?key=value'));
    });
  });
}
