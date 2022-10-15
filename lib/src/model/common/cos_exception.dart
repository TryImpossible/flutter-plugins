import 'package:http/http.dart' show Response;
import 'package:xml/xml.dart';

class COSException implements Exception {
  COSException._(this._response) {
    if (_response.body.isNotEmpty) {
      _error = COSError.fromXml(XmlDocument.parse(_response.body).rootElement);
    }
  }

  factory COSException.fromResponse(Response response) =>
      COSException._(response);

  Response get response => _response;
  final Response _response;

  COSError? _error;

  int get statusCode => _response.statusCode;

  String? get code => _error?.code;

  String? get message => _error?.message;

  String? get resource => _error?.resource;

  String? get requestId => _error?.requestId;

  String? get traceId => _error?.traceId;

  @override
  String toString() {
    return "COSException:\n${_response.body}";
  }
}

class COSError {
  String? code;
  String? message;
  String? resource;
  String? requestId;
  String? traceId;

  COSError();

  factory COSError.fromXml(XmlElement? xml) {
    return COSError()
      ..code = xml?.getElement('Code')?.innerText
      ..message = xml?.getElement('Message')?.innerText
      ..resource = xml?.getElement('Resource')?.innerText
      ..requestId = xml?.getElement('RequestId')?.innerText
      ..traceId = xml?.getElement('TraceId')?.innerText;
  }
}
