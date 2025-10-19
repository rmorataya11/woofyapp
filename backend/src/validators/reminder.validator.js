import { body, param } from 'express-validator';
import { REMINDER_TYPES } from '../config/constants';

const createReminderValidator = [
  param('petId')
    .isUUID().withMessage('ID de mascota inválido'),
  
  body('title')
    .notEmpty().withMessage('El título es requerido')
    .isString().withMessage('El título debe ser texto')
    .trim()
    .isLength({ min: 1, max: 200 }).withMessage('El título debe tener entre 1 y 200 caracteres'),
  
  body('description')
    .optional()
    .isString().withMessage('La descripción debe ser texto'),
  
  body('due_at')
    .notEmpty().withMessage('La fecha de vencimiento es requerida')
    .isISO8601().withMessage('Fecha inválida'),
  
  body('type')
    .notEmpty().withMessage('El tipo es requerido')
    .isIn(Object.values(REMINDER_TYPES)).withMessage('Tipo inválido')
];

const updateReminderValidator = [
  param('id')
    .isUUID().withMessage('ID de recordatorio inválido'),
  
  body('title')
    .optional()
    .isString().withMessage('El título debe ser texto')
    .trim()
    .isLength({ min: 1, max: 200 }).withMessage('El título debe tener entre 1 y 200 caracteres'),
  
  body('description')
    .optional()
    .isString().withMessage('La descripción debe ser texto'),
  
  body('due_at')
    .optional()
    .isISO8601().withMessage('Fecha inválida'),
  
  body('type')
    .optional()
    .isIn(Object.values(REMINDER_TYPES)).withMessage('Tipo inválido'),
  
  body('is_sent')
    .optional()
    .isBoolean().withMessage('is_sent debe ser booleano')
];

const reminderIdValidator = [
  param('id')
    .isUUID().withMessage('ID de recordatorio inválido')
];

const petIdValidator = [
  param('petId')
    .isUUID().withMessage('ID de mascota inválido')
];

export {
  createReminderValidator,
  updateReminderValidator,
  reminderIdValidator,
  petIdValidator
};

