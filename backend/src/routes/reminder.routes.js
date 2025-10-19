import express from 'express';
const router = express.Router();
import { authenticate } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validator.middleware';
import {
  createReminderValidator,
  updateReminderValidator,
  reminderIdValidator,
  petIdValidator
} from '../validators/reminder.validator';
import {
  getReminders,
  getRemindersByPet,
  getReminderById,
  createReminder,
  updateReminder,
  deleteReminder
} from '../controllers/reminder.controller';

router.use(authenticate);

router.get('/', getReminders);

router.get('/pet/:petId', petIdValidator, validate, getRemindersByPet);

router.post('/pet/:petId', createReminderValidator, validate, createReminder);

router.get('/:id', reminderIdValidator, validate, getReminderById);

router.put('/:id', updateReminderValidator, validate, updateReminder);

router.delete('/:id', reminderIdValidator, validate, deleteReminder);

export default router;

