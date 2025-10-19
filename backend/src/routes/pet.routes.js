import express from 'express';
const router = express.Router();
import { authenticate } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validator.middleware';
import { 
  createPetValidator, 
  updatePetValidator, 
  petIdValidator 
} from '../validators/pet.validator';  
import { getPets, getPetById, createPet, updatePet, deletePet } from '../controllers/pet.controller';

router.use(authenticate);

router.get('/', getPets);

router.post('/', createPetValidator, validate, createPet);

router.get('/:id', petIdValidator, validate, getPetById);

router.put('/:id', updatePetValidator, validate, updatePet);

router.delete('/:id', petIdValidator, validate, deletePet);

export default router;

