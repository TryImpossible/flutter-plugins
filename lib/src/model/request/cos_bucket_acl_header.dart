class COSBucketACLHeader {
  String? xCosAcl;
  String? xCosGrantRead;
  String? xCosGrantWrite;
  String? xCosGrantReadAcp;
  String? xCosGrantWriteAcp;
  String? xCosGrantFullControl;

  Map<String, String> toMap() {
    return <String, String>{
      if (xCosAcl != null) 'x-cos-acl': xCosAcl!,
      if (xCosGrantRead != null) 'x-cos-grant-read': xCosGrantRead!,
      if (xCosGrantWrite != null) 'x-cos-grant-write': xCosGrantWrite!,
      if (xCosGrantReadAcp != null) 'x-cos-grant-read-acp': xCosGrantReadAcp!,
      if (xCosGrantWriteAcp != null)
        'x-cos-grant-write-acp': xCosGrantWriteAcp!,
      if (xCosGrantFullControl != null)
        'x-cos-grant-full-control': xCosGrantFullControl!,
    };
  }
}
