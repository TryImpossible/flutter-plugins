import 'package:xml/xml.dart';

import '../common/cos_common.dart';

class COSDelete {
  bool quiet;
  List<COSObject> objects;

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('Delete', nest: () {
      builder.element('Quiet', nest: quiet);
      for (var object in objects) {
        builder.xml(object.toXmlString());
      }
    });
    return builder.buildDocument();
  }

  String toXmlString() {
    return toXml().toXmlString();
  }

  COSDelete({
    this.quiet = false,
    required this.objects,
  });

  factory COSDelete.fromXml(XmlElement? xml) {
    return COSDelete(
      quiet: xml?.getElement('Quiet')?.innerText == 'true',
      objects: xml
              ?.findElements('Object')
              .map((XmlElement xmlElement) => COSObject.fromXml(xmlElement))
              .toList() ??
          <COSObject>[],
    );
  }
}
