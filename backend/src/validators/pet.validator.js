import { body, param } from 'express-validator';

const createPetValidator = [
  body('name')
    .notEmpty().withMessage('El nombre es requerido')
    .isString().withMessage('El nombre debe ser texto')
    .trim()
    .isLength({ min: 1, max: 100 }).withMessage('El nombre debe tener entre 1 y 100 caracteres'),
  
  body('breed')
    .optional()
    .isString().withMessage('La raza debe ser texto')
    .trim(),
  
  body('age_months')
    .optional()
    .isInt({ min: 0, max: 300 }).withMessage('La edad debe ser un número entero positivo'),
  
  body('weight_kg')
    .optional()
    .isFloat({ min: 0, max: 500 }).withMessage('El peso debe ser un número positivo'),
  
  body('photo_url')
    .optional()
    .isURL().withMessage('La URL de la foto no es válida')
];

const updatePetValidator = [
  param('id')
    .isUUID().withMessage('ID de mascota inválido'),
  
  body('name')
    .optional()
    .isString().withMessage('El nombre debe ser texto')
    .trim()
    .isLength({ min: 1, max: 100 }).withMessage('El nombre debe tener entre 1 y 100 caracteres'),
  
  body('breed')
    .optional()
    .isString().withMessage('La raza debe ser texto')
    .trim(),
  
  body('age_months')
    .optional()
    .isInt({ min: 0, max: 300 }).withMessage('La edad debe ser un número entero positivo'),
  
  body('weight_kg')
    .optional()
    .isFloat({ min: 0, max: 500 }).withMessage('El peso debe ser un número positivo'),
  
  body('photo_url')
    .optional()
    .isURL().withMessage('La URL de la foto no es válida')
];

const petIdValidator = [
  param('id')
    .isUUID().withMessage('ID de mascota inválido')
];

export {
  createPetValidator,
  updatePetValidator,
  petIdValidator
};

