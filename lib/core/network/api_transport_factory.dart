import 'api_transport.dart';
import 'api_transport_io.dart'
    if (dart.library.html) 'api_transport_web.dart'
    as platform;

ApiTransport createApiTransport([Object? httpClient]) {
  return platform.createApiTransport(httpClient);
}
