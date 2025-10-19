import express from 'express';
const router = express.Router();
import { authenticate } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validator.middleware';
import {
  createMedicalRecordValidator,
  updateMedicalRecordValidator,
  medicalRecordIdValidator,
  petIdValidator
} from '../validators/medical-record.validator';
import {
  getMedicalRecordsByPet,
  getMedicalRecordById,
  createMedicalRecord,
  updateMedicalRecord,
  deleteMedicalRecord
} from '../controllers/medical-record.controller';

router.use(authenticate);

router.get('/pet/:petId', petIdValidator, validate, getMedicalRecordsByPet);

router.post('/pet/:petId', createMedicalRecordValidator, validate, createMedicalRecord);

router.get('/:id', medicalRecordIdValidator, validate, getMedicalRecordById);

router.put('/:id', updateMedicalRecordValidator, validate, updateMedicalRecord);

router.delete('/:id', medicalRecordIdValidator, validate, deleteMedicalRecord);

export default router;

