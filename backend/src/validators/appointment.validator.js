import { body, param } from 'express-validator';
import { APPOINTMENT_STATUS } from '../config/constants';

const createAppointmentValidator = [
  body('pet_id')
    .notEmpty().withMessage('El ID de la mascota es requerido')
    .isUUID().withMessage('ID de mascota inválido'),
  
  body('clinic_id')
    .notEmpty().withMessage('El ID de la clínica es requerido')
    .isUUID().withMessage('ID de clínica inválido'),
  
  body('service_id')
    .notEmpty().withMessage('El ID del servicio es requerido')
    .isUUID().withMessage('ID de servicio inválido'),
  
  body('starts_at')
    .notEmpty().withMessage('La fecha de inicio es requerida')
    .isISO8601().withMessage('Fecha de inicio inválida'),
  
  body('ends_at')
    .notEmpty().withMessage('La fecha de fin es requerida')
    .isISO8601().withMessage('Fecha de fin inválida'),
  
  body('notes')
    .optional()
    .isString().withMessage('Las notas deben ser texto')
];

const updateAppointmentValidator = [
  param('id')
    .isUUID().withMessage('ID de cita inválido'),
  
  body('starts_at')
    .optional()
    .isISO8601().withMessage('Fecha de inicio inválida'),
  
  body('ends_at')
    .optional()
    .isISO8601().withMessage('Fecha de fin inválida'),
  
  body('notes')
    .optional()
    .isString().withMessage('Las notas deben ser texto')
];

const updateAppointmentStatusValidator = [
  param('id')
    .isUUID().withMessage('ID de cita inválido'),
  
  body('status')
    .notEmpty().withMessage('El estado es requerido')
    .isIn(Object.values(APPOINTMENT_STATUS)).withMessage('Estado inválido')
];

const appointmentIdValidator = [
  param('id')
    .isUUID().withMessage('ID de cita inválido')
];

export {
  createAppointmentValidator,
  updateAppointmentValidator,
  updateAppointmentStatusValidator,
  appointmentIdValidator
};

