import 'package:xml/xml.dart';

class COSAccelerateConfiguration {
  String? status;
  String? type;

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('AccelerateConfiguration', nest: () {
      if (status != null) {
        builder.element('Status', nest: status);
      }
      if (type != null) {
        builder.element('Type', nest: type);
      }
    });
    return builder.buildDocument();
  }

  String toXmlString() {
    return toXml().toXmlString();
  }

  COSAccelerateConfiguration();

  factory COSAccelerateConfiguration.fromXml(XmlElement? xml) {
    return COSAccelerateConfiguration()
      ..status = xml?.getElement('Status')?.innerText
      ..type = xml?.getElement('Type')?.innerText;
  }
}
