class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({required this.message, this.statusCode, this.errors});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException extends ApiException {
  NetworkException({String? message})
    : super(message: message ?? 'No hay conexión a internet', statusCode: 0);
}

class TimeoutException extends ApiException {
  TimeoutException({String? message})
    : super(
        message: message ?? 'La solicitud ha excedido el tiempo límite',
        statusCode: 408,
      );
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String? message})
    : super(
        message:
            message ?? 'No autorizado. Por favor inicia sesión nuevamente.',
        statusCode: 401,
      );
}

class ForbiddenException extends ApiException {
  ForbiddenException({String? message})
    : super(
        message: message ?? 'No tienes permisos para realizar esta acción',
        statusCode: 403,
      );
}

class NotFoundException extends ApiException {
  NotFoundException({String? message})
    : super(message: message ?? 'Recurso no encontrado', statusCode: 404);
}

class ValidationException extends ApiException {
  ValidationException({super.message = 'Error de validación', super.errors})
    : super(statusCode: 400);
}

class ServerException extends ApiException {
  ServerException({String? message})
    : super(message: message ?? 'Error interno del servidor', statusCode: 500);
}

class ConflictException extends ApiException {
  ConflictException({String? message})
    : super(
        message: message ?? 'Conflicto con el estado actual',
        statusCode: 409,
      );
}

class ApiExceptionHandler {
  static ApiException fromStatusCode(
    int statusCode,
    String message, {
    Map<String, dynamic>? errors,
  }) {
    switch (statusCode) {
      case 400:
        return ValidationException(message: message, errors: errors);
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return ForbiddenException(message: message);
      case 404:
        return NotFoundException(message: message);
      case 408:
        return TimeoutException(message: message);
      case 409:
        return ConflictException(message: message);
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(message: message);
      default:
        return ApiException(
          message: message,
          statusCode: statusCode,
          errors: errors,
        );
    }
  }

  static String getUserFriendlyMessage(ApiException exception) {
    if (exception is NetworkException) {
      return 'No hay conexión a internet. Por favor verifica tu conexión.';
    } else if (exception is TimeoutException) {
      return 'La solicitud está tardando demasiado. Intenta nuevamente.';
    } else if (exception is UnauthorizedException) {
      return 'Tu sesión ha expirado. Por favor inicia sesión nuevamente.';
    } else if (exception is ForbiddenException) {
      return 'No tienes permisos para realizar esta acción.';
    } else if (exception is NotFoundException) {
      return 'No se encontró la información solicitada.';
    } else if (exception is ValidationException) {
      return exception.message;
    } else if (exception is ServerException) {
      return 'Error del servidor. Por favor intenta más tarde.';
    } else {
      return exception.message;
    }
  }
}
