/// COS配置
class COSConfig {
  COSConfig({
    required this.appId,
    required this.secretId,
    required this.secretKey,
    this.sessionToken,
  });

  /// 开发者访问 COS 服务时拥有的用户维度唯一资源标识
  String appId;

  /// 开发者拥有的项目身份识别 ID
  String secretId;

  /// 开发者拥有的项目身份密钥
  String secretKey;

  /// 如果使用临时安全凭证必须传入该参数
  String? sessionToken;
}
