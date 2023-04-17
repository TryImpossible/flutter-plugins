import 'package:xml/xml.dart';

class COSCORSConfiguration {
  COSCORSConfiguration({required this.corsRules});

  List<COSCORSRule> corsRules;

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('CORSConfiguration', nest: () {
      for (final COSCORSRule corsRule in corsRules) {
        builder.xml(corsRule.toXmlString());
      }
    });
    return builder.buildDocument();
  }

  String toXmlString() {
    return toXml().toXmlString();
  }

  factory COSCORSConfiguration.fromXml(XmlElement? xml) {
    return COSCORSConfiguration(
      corsRules: xml
              ?.findElements('CORSRule')
              .map((XmlElement xmlElement) => COSCORSRule.fromXml(xmlElement))
              .toList() ??
          <COSCORSRule>[],
    );
  }
}

class COSCORSRule {
  COSCORSRule({
    required this.allowedOrigins,
    required this.allowedMethods,
    required this.allowedHeaders,
    required this.exposeHeaders,
    required this.maxAgeSeconds,
    this.id,
  });

  List<String> allowedOrigins;
  List<String> allowedMethods;
  List<String> allowedHeaders;
  List<String> exposeHeaders;
  int maxAgeSeconds;
  String? id;

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('CORSRule', nest: () {
      for (final String allowedOrigin in allowedOrigins) {
        builder.element('AllowedOrigin', nest: allowedOrigin);
      }
      for (final String allowedMethod in allowedMethods) {
        builder.element('AllowedMethod', nest: allowedMethod);
      }
      for (final String allowedHeader in allowedHeaders) {
        builder.element('AllowedHeader', nest: allowedHeader);
      }
      for (final String exposeHeader in exposeHeaders) {
        builder.element('ExposeHeader', nest: exposeHeader);
      }
      builder.element('MaxAgeSeconds', nest: maxAgeSeconds);
      if (id?.isNotEmpty ?? false) {
        builder.element('ID', nest: id);
      }
    });
    return builder.buildDocument();
  }

  String toXmlString() {
    return toXml().toXmlString();
  }

  factory COSCORSRule.fromXml(XmlElement? xml) {
    return COSCORSRule(
      allowedOrigins: xml
              ?.findElements('AllowedOrigin')
              .map((XmlElement xmlElement) => xmlElement.innerText)
              .toList() ??
          <String>[],
      allowedMethods: xml
              ?.findElements('AllowedMethod')
              .map((XmlElement xmlElement) => xmlElement.innerText)
              .toList() ??
          <String>[],
      allowedHeaders: xml
              ?.findElements('AllowedHeader')
              .map((XmlElement xmlElement) => xmlElement.innerText)
              .toList() ??
          <String>[],
      exposeHeaders: xml
              ?.findElements('ExposeHeader')
              .map((XmlElement xmlElement) => xmlElement.innerText)
              .toList() ??
          <String>[],
      maxAgeSeconds:
          int.parse(xml?.getElement('MaxAgeSeconds')?.innerText ?? '0'),
      id: xml?.getElement('ID')?.innerText,
    );
  }
}
