import { body } from 'express-validator';

const updateProfileValidator = [
  body('name')
    .optional()
    .isString().withMessage('El nombre debe ser texto')
    .trim()
    .isLength({ min: 2, max: 100 }).withMessage('El nombre debe tener entre 2 y 100 caracteres'),
  
  body('phone')
    .optional()
    .isString().withMessage('El teléfono debe ser texto')
    .trim(),
  
  body('avatar_url')
    .optional()
    .isURL().withMessage('La URL del avatar no es válida')
];

export {
  updateProfileValidator
};

