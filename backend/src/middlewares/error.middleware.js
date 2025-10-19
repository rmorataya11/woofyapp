import logger from '../utils/logger';
import { AppError } from '../utils/errors.js';

const errorHandler = (err, req, res) => {
  let error = { ...err };
  error.message = err.message;

  logger.error('Error:', {
    message: err.message,
    stack: err.stack,
    url: req.originalUrl,
    method: req.method
  });

  if (err.name === 'ValidationError') {
    const message = 'Error de validación';
    error = new AppError(message, 400);
  }

  if (err.isOperational) {
    return res.status(err.statusCode || 500).json({
      success: false,
      message: error.message,
      errors: err.errors || undefined
    });
  }

  return res.status(500).json({
    success: false,
    message: 'Error interno del servidor'
  });
};

const notFound = (req, res) => {
  res.status(404).json({
    success: false,
    message: `Ruta no encontrada: ${req.originalUrl}`
  });
};

export { errorHandler, notFound };

