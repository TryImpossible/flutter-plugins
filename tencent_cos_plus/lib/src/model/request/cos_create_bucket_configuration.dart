import 'package:xml/xml.dart';

class COSCreateBucketConfiguration {
  COSCreateBucketConfiguration();

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('CreateBucketConfiguration', nest: () {
      builder.element('BucketAZConfig', nest: 'MAZ');
    });
    return builder.buildDocument();
  }

  String toXmlString() {
    return toXml().toXmlString();
  }
}
