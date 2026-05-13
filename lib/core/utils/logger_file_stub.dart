/// Web stub – file I/O is not available in the browser.
/// All methods are no-ops so the logger compiles cleanly on web.
Future<void> initPlatformFileLogging(
  List<dynamic> bufferedEntries,
  String Function(dynamic) toLine,
) async {}

String? get platformLogDirectory => null;
String? get platformLogFilePath => null;

void writePlatformLogLine(String line) {}

Future<void> flushPlatformLog() async {}
