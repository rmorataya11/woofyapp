import { validationResult } from 'express-validator';
import { ValidationError } from '../utils/errors.js';

const validate = (req, next) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    const formattedErrors = errors.array().map(err => ({
      field: err.path || err.param,
      message: err.msg
    }));

    throw new ValidationError('Validation errors', formattedErrors);
  }

  next();
};

export { validate };

