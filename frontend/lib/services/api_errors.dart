// lib/services/api_errors.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;
  ApiException(this.message, {this.statusCode, this.fieldErrors});
  @override
  String toString() => 'ApiException(${statusCode ?? '-'}) $message';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String msg, {int? code}) : super(msg, statusCode: code);
}

class NotFoundException extends ApiException {
  NotFoundException(String msg, {int? code}) : super(msg, statusCode: code);
}

class ConflictException extends ApiException {
  ConflictException(String msg, {int? code}) : super(msg, statusCode: code);
}

class ValidationException extends ApiException {
  ValidationException(String msg, Map<String, List<String>> fields, {int? code})
    : super(msg, statusCode: code, fieldErrors: fields);
}

class NoAircraftAvailableException extends ApiException {
  NoAircraftAvailableException(String msg, {int? code})
    : super(msg, statusCode: code);
}

class SegmentTimeInvalidException extends ApiException {
  SegmentTimeInvalidException(String msg, {int? code})
    : super(msg, statusCode: code);
}

class WeightExceededException extends ApiException {
  WeightExceededException(String msg, {int? code})
    : super(msg, statusCode: code);
}

class ApiErrors {
  static ApiException fromResponse(http.Response r) {
    final code = r.statusCode;
    String? msg;
    Map<String, List<String>>? modelState;

    // Intenta ProblemDetails o { message | error | detail | errors }
    try {
      if (r.body.isNotEmpty) {
        final data = jsonDecode(r.body);
        if (data is Map) {
          if (data['errors'] is Map) {
            modelState = {};
            (data['errors'] as Map).forEach((k, v) {
              if (v is List) {
                modelState![k.toString()] = v.map((e) => e.toString()).toList();
              } else if (v != null) {
                modelState![k.toString()] = [v.toString()];
              }
            });
          }
          msg =
              (data['message'] ??
                      data['detail'] ??
                      data['error'] ??
                      data['title'])
                  ?.toString();
        }
      }
    } catch (_) {}

    msg ??= r.body.isNotEmpty ? r.body : 'HTTP $code';

    // Mapeos por texto (ES/EN) que vienen del backend
    final low = msg.toLowerCase();
    if (low.contains('no hay aeronaves disponibles')) {
      return NoAircraftAvailableException(msg, code: code);
    }
    if (low.contains('hora de llegada') &&
        (low.contains('anterior') || low.contains('igual'))) {
      return SegmentTimeInvalidException(msg, code: code);
    }
    if (low.contains('excede el peso permitido') ||
        low.contains('peso máximo') ||
        low.contains('weight limit')) {
      return WeightExceededException(msg, code: code);
    }

    // Por status code
    if (code == 401) return UnauthorizedException(msg, code: code);
    if (code == 404) return NotFoundException(msg, code: code);
    if (code == 409) return ConflictException(msg, code: code);
    if (code == 400 || code == 422) {
      if (modelState != null && modelState.isNotEmpty) {
        return ValidationException(
          'Errores de validación',
          modelState,
          code: code,
        );
      }
      return ApiException(msg, statusCode: code);
    }

    return ApiException(msg, statusCode: code);
  }
}
