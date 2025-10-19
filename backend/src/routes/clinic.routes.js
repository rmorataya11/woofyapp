import express from 'express';
const router = express.Router();
import { optionalAuth } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validator.middleware';
import { clinicIdValidator } from '../validators/clinic.validator';
import {
  getClinics,
  getClinicById,
  getClinicServices,
  getClinicHours
} from '../controllers/clinic.controller';

router.use(optionalAuth);

router.get('/', getClinics);

router.get('/:id', clinicIdValidator, validate, getClinicById);

router.get('/:id/services', clinicIdValidator, validate, getClinicServices);

router.get('/:id/hours', clinicIdValidator, validate, getClinicHours);

export default router;

