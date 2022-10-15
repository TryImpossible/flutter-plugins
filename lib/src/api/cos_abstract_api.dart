import '../client/client.dart';
import '../model/model.dart' show COSConfig;

abstract class COSAbstractApi {
  COSAbstractApi(this.config) : _client = COSClient(config);

  /// COS 配置
  final COSConfig config;

  COSClient get client => _client;
  final COSClient _client;
}
