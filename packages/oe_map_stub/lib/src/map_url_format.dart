/// URL scheme produced by [MapLauncherStub].
enum MapUrlFormat {
  /// RFC 5870 `geo:` URI that mobile OS maps apps can open.
  geo,

  /// HTTPS link to OpenStreetMap (no API key, no vendor SDK).
  openStreetMap,
}
