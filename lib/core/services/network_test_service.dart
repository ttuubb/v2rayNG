import 'dart:async';
import 'dart:io';

abstract class NetworkTestService {
  Future<int> measureLatency(String address, int port, {String protocol = 'tcp'});
  Future<double> measureThroughput(String address, int port);
}

class NetworkTestServiceImpl implements NetworkTestService {
  static const int _timeoutSeconds = 5;

  @override
  Future<int> measureLatency(String address, int port, {String protocol = 'tcp'}) async {
    final stopwatch = Stopwatch();
    try {
      stopwatch.start();
      final dynamic socket = await (protocol == 'tcp'
          ? Socket.connect(address, port, timeout: const Duration(seconds: _timeoutSeconds))
          : RawSocket.connect(address, port, timeout: const Duration(seconds: _timeoutSeconds)));
      stopwatch.stop();
      socket.close();
      return stopwatch.elapsedMilliseconds;
    } on SocketException catch (e) {
      throw Exception('Latency test failed: ${e.message}');
    }
  }

  @override
  Future<double> measureThroughput(String address, int port) async {
    const testDataSize = 1024 * 1024; // 1MB测试数据
    final testData = List<int>.filled(testDataSize, 0);
    final stopwatch = Stopwatch();

    try {
      final socket = await Socket.connect(address, port);
      stopwatch.start();
      socket.add(testData);
      await socket.flush();
      stopwatch.stop();
      socket.close();

      // 计算传输速率 (MB/s)
      return testDataSize / (stopwatch.elapsedMilliseconds / 1000) / (1024 * 1024);
    } on SocketException catch (e) {
      throw Exception('Throughput test failed: ${e.message}');
    }
  }
}