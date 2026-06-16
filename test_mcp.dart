import 'dart:convert';
import 'dart:io';

void main() async {
  print('Starting marionette_mcp process...');
  final process = await Process.start('dart', [
    'pub',
    'global',
    'run',
    'marionette_mcp',
  ]);

  // Listen to stdout
  process.stdout.transform(utf8.decoder).listen((data) {
    print('STDOUT: $data');
  });

  // Listen to stderr
  process.stderr.transform(utf8.decoder).listen((data) {
    print('STDERR: $data');
  });

  // Wait a bit to ensure server is ready
  await Future.delayed(Duration(seconds: 1));

  // Send initialize request
  final initRequest = {
    'jsonrpc': '2.0',
    'id': 1,
    'method': 'initialize',
    'params': {
      'protocolVersion': '2024-11-05',
      'capabilities': {},
      'clientInfo': {'name': 'test-client', 'version': '1.0.0'},
    },
  };

  print('Sending initialize request...');
  process.stdin.writeln(jsonEncode(initRequest));

  await Future.delayed(Duration(seconds: 1));

  // Send list tools request
  final listRequest = {
    'jsonrpc': '2.0',
    'id': 2,
    'method': 'tools/list',
    'params': {},
  };

  print('Sending tools/list request...');
  process.stdin.writeln(jsonEncode(listRequest));

  await Future.delayed(Duration(seconds: 2));

  print('Killing process...');
  process.kill();
}
