import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart marionette_client.dart <tool_name> [args_json]');
    return;
  }

  final toolName = args[0];
  Map<String, dynamic> toolParams = {};
  if (args.length > 1) {
    toolParams = jsonDecode(args[1]) as Map<String, dynamic>;
  }

  final process = await Process.start('dart', ['pub', 'global', 'run', 'marionette_mcp']);

  // Buffer for stdout
  final stdoutBuffer = StringBuffer();
  final stderrBuffer = StringBuffer();

  process.stdout.transform(utf8.decoder).listen((data) {
    stdoutBuffer.write(data);
  });

  process.stderr.transform(utf8.decoder).listen((data) {
    stderrBuffer.write(data);
  });

  // Wait for server to start
  await Future.delayed(Duration(milliseconds: 500));

  // Initialize
  final initRequest = {
    'jsonrpc': '2.0',
    'id': 1,
    'method': 'initialize',
    'params': {
      'protocolVersion': '2024-11-05',
      'capabilities': {},
      'clientInfo': {'name': 'marionette-client', 'version': '1.0.0'}
    }
  };
  process.stdin.writeln(jsonEncode(initRequest));

  await Future.delayed(Duration(milliseconds: 500));

  // Clear buffers so we only get the tool response
  stdoutBuffer.clear();

  // Call tool
  final toolRequest = {
    'jsonrpc': '2.0',
    'id': 2,
    'method': 'tools/call',
    'params': {
      'name': toolName,
      'arguments': toolParams
    }
  };
  process.stdin.writeln(jsonEncode(toolRequest));

  // Wait for response
  await Future.delayed(Duration(seconds: 4));

  final output = stdoutBuffer.toString();
  print('=== TOOL OUTPUT ===');
  print(output);
  if (stderrBuffer.isNotEmpty) {
    print('=== TOOL ERRORS ===');
    print(stderrBuffer.toString());
  }

  process.kill();
}
