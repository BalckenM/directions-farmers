/// Native (Android / iOS / desktop) implementation of file logging.
/// Uses dart:io and path_provider.  Never imported on web.
library;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

IOSink? _sink;
File? _logFile;
String? _logDir;

String? get platformLogDirectory => _logDir;
String? get platformLogFilePath => _logFile?.path;

Future<void> initPlatformFileLogging(
  List<dynamic> bufferedEntries,
  String Function(dynamic) toLine,
) async {
  try {
    final Directory base = await _baseDir();
    final Directory logDir = Directory('${base.path}/logs');
    if (!logDir.existsSync()) logDir.createSync(recursive: true);
    _logDir = logDir.path;

    final String date = DateTime.now().toIso8601String().substring(0, 10);
    _logFile = File('${logDir.path}/app_$date.log');
    _sink = _logFile!.openWrite(mode: FileMode.append);
    _sink!.writeln(
      '\n========== SESSION START ${DateTime.now().toIso8601String()} ==========',
    );

    // Write any entries that were buffered before init
    for (final e in bufferedEntries) {
      _sink!.writeln(toLine(e));
    }

    _purge(logDir);
    debugPrint('📁 [Logger] logs → ${_logFile!.path}');
  } catch (e) {
    debugPrint('⚠️ [Logger] file init failed: $e');
  }
}

void writePlatformLogLine(String line) {
  try {
    _sink?.writeln(line);
  } catch (_) {}
}

Future<void> flushPlatformLog() async {
  await _sink?.flush();
  await _sink?.close();
  _sink = null;
}

Future<Directory> _baseDir() async {
  try {
    return await getApplicationDocumentsDirectory();
  } catch (_) {
    return await getTemporaryDirectory();
  }
}

void _purge(Directory dir) {
  try {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    dir
        .listSync()
        .whereType<File>()
        .where((f) => f.statSync().modified.isBefore(cutoff))
        .forEach((f) => f.deleteSync());
  } catch (_) {}
}
