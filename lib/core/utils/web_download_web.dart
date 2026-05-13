// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Triggers a file download in the browser using an anchor element.
void triggerWebDownload(String href, String filename) {
  html.AnchorElement(href: href)
    ..setAttribute('download', filename)
    ..click();
}
