/// No-op stub for non-web platforms.
void triggerWebDownload(String href, String filename) {
  // Not implemented on mobile/desktop — callers must guard with kIsWeb.
}
