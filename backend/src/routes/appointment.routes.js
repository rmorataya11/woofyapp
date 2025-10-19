import express from 'express';
const router = express.Router();
import { authenticate } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validator.middleware';
import {
  createAppointmentValidator,
  updateAppointmentValidator,
  updateAppointmentStatusValidator,
  appointmentIdValidator
} from '../validators/appointment.validator';
import {
  getAppointments,  
  getAppointmentById,
  createAppointment,
  updateAppointment,
  updateAppointmentStatus,
  deleteAppointment
} from '../controllers/appointment.controller';

router.use(authenticate);

router.get('/', getAppointments);

router.post('/', createAppointmentValidator, validate, createAppointment);

router.get('/:id', appointmentIdValidator, validate, getAppointmentById);

router.put('/:id', updateAppointmentValidator, validate, updateAppointment);

router.patch('/:id/status', updateAppointmentStatusValidator, validate, updateAppointmentStatus);

router.delete('/:id', appointmentIdValidator, validate, deleteAppointment);

export default router;

