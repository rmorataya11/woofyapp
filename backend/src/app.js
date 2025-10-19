import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import logger from './utils/logger';
import { errorHandler, notFound } from './middlewares/error.middleware';
import routes from './routes';

const app = express();

app.use(helmet());

const corsOptions = {
  origin: process.env.CORS_ORIGIN?.split(',') || '*',
  credentials: true,
  optionsSuccessStatus: 200
};
app.use(cors(corsOptions));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (process.env.NODE_ENV !== 'production') {
  app.use((req, res, next) => {
    logger.debug(`${req.method} ${req.path}`);
    next();
  });
}

app.use('/api', routes);

app.use(notFound);

app.use(errorHandler);

export default app;

