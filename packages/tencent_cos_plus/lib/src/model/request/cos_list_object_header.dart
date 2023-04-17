class COSListObjectHeader {
  String? prefix;
  String? delimiter;
  String? encodingType;
  String? marker;
  String? versionIdMarker;
  int? maxKeys;

  Map<String, String> toMap() {
    return <String, String>{
      if (prefix != null) 'prefix': prefix!,
      if (delimiter != null) 'delimiter': delimiter!,
      if (encodingType != null) 'encoding-type': encodingType!,
      if (marker != null) 'marker': marker!,
      if (versionIdMarker != null) 'version-id-marker': versionIdMarker!,
      if (maxKeys != null) 'max-keys': maxKeys.toString(),
    };
  }
}
