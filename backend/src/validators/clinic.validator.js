import { param } from 'express-validator';

const clinicIdValidator = [
  param('id')
    .isUUID().withMessage('ID de clínica inválido')
];

export {
  clinicIdValidator
};

