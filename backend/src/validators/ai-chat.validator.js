import { body, param } from 'express-validator';

const createConversationValidator = [
  body('title')
    .optional()
    .isString().withMessage('El título debe ser texto')
    .trim()
    .isLength({ max: 200 }).withMessage('El título debe tener máximo 200 caracteres')
];

const sendMessageValidator = [
  param('id')
    .isUUID().withMessage('ID de conversación inválido'),
  
  body('content')
    .notEmpty().withMessage('El contenido del mensaje es requerido')
    .isString().withMessage('El contenido debe ser texto')
    .trim()
    .isLength({ min: 1, max: 2000 }).withMessage('El mensaje debe tener entre 1 y 2000 caracteres'),
  
  body('pet_id')
    .optional()
    .isUUID().withMessage('ID de mascota inválido')
];

const conversationIdValidator = [
  param('id')
    .isUUID().withMessage('ID de conversación inválido')
];

export {
  createConversationValidator,
  sendMessageValidator,
  conversationIdValidator
};

