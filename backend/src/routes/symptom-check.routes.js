import express from 'express';
const router = express.Router();
import { authenticate } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validator.middleware';
import {
  createSymptomCheckValidator,
  symptomCheckIdValidator,
  petIdValidator
} from '../validators/symptom-check.validator';
import {
  getSymptomChecksByPet,
  getSymptomCheckById,
  createSymptomCheck
} from '../controllers/symptom-check.controller';

router.use(authenticate);

router.get('/pet/:petId', petIdValidator, validate, getSymptomChecksByPet);

router.post('/pet/:petId', createSymptomCheckValidator, validate, createSymptomCheck);

router.get('/:id', symptomCheckIdValidator, validate, getSymptomCheckById);

export default router;

