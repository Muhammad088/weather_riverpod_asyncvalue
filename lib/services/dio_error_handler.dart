import 'package:dio/dio.dart';

String dioErrorHandler(Response response) {
  final statusCode = response.statusCode;
  final statusMessage = response.statusMessage;
  String message =
      "Request Failed \n status code : $statusCode \n reason: $statusMessage";
  return message;
}
