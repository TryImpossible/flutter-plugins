class COSGetObject {
  COSGetObject({
    this.responseCacheControl,
    this.responseContentDisposition,
    this.responseContentEncoding,
    this.responseContentLanguage,
    this.responseContentType,
    this.responseExpires,
    this.versionId,
  });

  String? responseCacheControl;
  String? responseContentDisposition;
  String? responseContentEncoding;
  String? responseContentLanguage;
  String? responseContentType;
  String? responseExpires;
  String? versionId;

  Map<String, String> toMap() {
    return <String, String>{
      if (responseCacheControl != null)
        'response-cache-control': responseCacheControl!,
      if (responseContentDisposition != null)
        'response-content-disposition': responseContentDisposition!,
      if (responseContentEncoding != null)
        'response-content-encoding': responseContentEncoding!,
      if (responseContentLanguage != null)
        'response-content-language': responseContentLanguage!,
      if (responseContentType != null)
        'response-content-type': responseContentType!,
      if (responseExpires != null) 'response-expires': responseExpires!,
      if (versionId != null) 'versionId': versionId!,
    };
  }
}
