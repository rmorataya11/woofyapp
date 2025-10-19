import express from 'express';
const router = express.Router();
import { authenticate } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validator.middleware';
import { updateProfileValidator } from '../validators/profile.validator';
import { getMyProfile, updateMyProfile } from '../controllers/profile.controller';

router.use(authenticate);

router.get('/me', getMyProfile);

router.put('/me', updateProfileValidator, validate, updateMyProfile);

export default router;

