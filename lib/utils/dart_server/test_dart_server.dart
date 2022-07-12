/*
  Resource: https://suragch.medium.com/how-to-send-yourself-email-notifications-from-a-dart-server-a7c16a1900d6
 */



import 'dart:convert';
import 'dart:io';
Future<void> main() async {
  final server = await createServer();
  print('Server started: ${server.address} port ${server.port}');
  await _handleRequests(server);
}
Future<HttpServer> createServer() async {
  final address = InternetAddress.loopbackIPv4;
  const port = 4040;
  return await HttpServer.bind(address, port);
}
Future<void> _handleRequests(HttpServer server) async {
  await for (HttpRequest request in server) {
    if (request.method == 'POST' && 
        request.uri.path == '/contact') {
      _handleContactPost(request);
    } else {
      _handleBadRequest(request);
    }
  }
}
void _handleBadRequest(HttpRequest request) {
  request.response
    ..statusCode = HttpStatus.badRequest
    ..write('Bad request')
    ..close();
}
Future<void> _handleContactPost(HttpRequest request) async {
  final body = await utf8.decodeStream(request);
  // TODO: email body
}