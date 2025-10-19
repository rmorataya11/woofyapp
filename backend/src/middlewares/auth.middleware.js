import { supabase } from '../config/supabase';
import { UnauthorizedError } from '../utils/errors';
import logger from '../utils/logger';

const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedError('Token no proporcionado');
    }

    const token = authHeader.substring(7);

    const { data: { user }, error } = await supabase.auth.getUser(token);

    if (error || !user) {
      throw new UnauthorizedError('Token inválido o expirado');
    }

    req.user = user;
    req.userId = user.id;

    next();
  } catch (error) {
    logger.error('Error en autenticación:', error);
    if (error instanceof UnauthorizedError) {
      return res.status(401).json({
        success: false,
        message: error.message
      });
    }
    return res.status(401).json({
      success: false,
      message: 'Error de autenticación'
    });
  }
};

const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const { data: { user } } = await supabase.auth.getUser(token);

      if (user) {
        req.user = user;
        req.userId = user.id;
      }
    }

    next();
  } catch (error) {
    logger.error('Error en autenticación opcional:', error);
    next();
  }
};

export { authenticate, optionalAuth };

