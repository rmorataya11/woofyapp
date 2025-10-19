import { body, param } from 'express-validator';
import { MEDICAL_RECORD_TYPES } from '../config/constants';

const createMedicalRecordValidator = [
  param('petId')
    .isUUID().withMessage('ID de mascota inválido'),
  
  body('type')
    .notEmpty().withMessage('El tipo es requerido')
    .isIn(Object.values(MEDICAL_RECORD_TYPES)).withMessage('Tipo inválido'),
  
  body('date')
    .notEmpty().withMessage('La fecha es requerida')
    .isISO8601().withMessage('Fecha inválida'),
  
  body('notes')
    .optional()
    .isString().withMessage('Las notas deben ser texto'),
  
  body('attachments')
    .optional()
    .isArray().withMessage('Los adjuntos deben ser un array')
];

const updateMedicalRecordValidator = [
  param('id')
    .isUUID().withMessage('ID de registro médico inválido'),
  
  body('type')
    .optional()
    .isIn(Object.values(MEDICAL_RECORD_TYPES)).withMessage('Tipo inválido'),
  
  body('date')
    .optional()
    .isISO8601().withMessage('Fecha inválida'),
  
  body('notes')
    .optional()
    .isString().withMessage('Las notas deben ser texto'),
  
  body('attachments')
    .optional()
    .isArray().withMessage('Los adjuntos deben ser un array')
];

const medicalRecordIdValidator = [
  param('id')
    .isUUID().withMessage('ID de registro médico inválido')
];

const petIdValidator = [
  param('petId')
    .isUUID().withMessage('ID de mascota inválido')
];

export {
  createMedicalRecordValidator,
  updateMedicalRecordValidator,
  medicalRecordIdValidator,
  petIdValidator
};

