import { body, param } from 'express-validator';

const createSymptomCheckValidator = [
  param('petId')
    .isUUID().withMessage('ID de mascota inválido'),
  
  body('symptoms')
    .notEmpty().withMessage('Los síntomas son requeridos')
    .isString().withMessage('Los síntomas deben ser texto')
    .trim()
    .isLength({ min: 10, max: 2000 }).withMessage('Los síntomas deben tener entre 10 y 2000 caracteres')
];

const symptomCheckIdValidator = [
  param('id')
    .isUUID().withMessage('ID de chequeo de síntomas inválido')
];

const petIdValidator = [
  param('petId')
    .isUUID().withMessage('ID de mascota inválido')
];

export {
  createSymptomCheckValidator,
  symptomCheckIdValidator,
  petIdValidator
};

