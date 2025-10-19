import 'dotenv/config';
import app from './app';
import logger from './utils/logger';

const PORT = process.env.PORT || 3000;

import fs from 'fs';
const logsDir = 'logs';
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir);
}

const server = app.listen(PORT, () => {
  logger.info(`Server WooFy API started on port ${PORT}`);
  logger.info(` Environment: ${process.env.NODE_ENV || 'development'}`);
  logger.info(`URL: http://localhost:${PORT}`);
  logger.info(`Health check: http://localhost:${PORT}/health`);
});

process.on('unhandledRejection', (err) => {
  logger.error('Unhandled rejection! Closing server...');
  logger.error(err);
  server.close(() => {
    process.exit(1);
  });
});

process.on('uncaughtException', (err) => {
  logger.error('Uncaught exception! Closing server...');
  logger.error(err);
  process.exit(1);
});

process.on('SIGTERM', () => {
  logger.info('SIGTERM received. Closing server correctly...');
  server.close(() => {
    logger.info('Process terminated');
  });
});

