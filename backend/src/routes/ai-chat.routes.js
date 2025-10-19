import express from 'express';
const router = express.Router();
import { authenticate } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validator.middleware';
import {
  createConversationValidator,
  sendMessageValidator,
  conversationIdValidator
} from '../validators/ai-chat.validator';
import {
  getConversations,
  getConversationById,
  createConversation,
  sendMessage,
  deleteConversation
} from '../controllers/ai-chat.controller';

router.use(authenticate);

router.get('/conversations', getConversations);

router.post('/conversations', createConversationValidator, validate, createConversation);

router.get('/conversations/:id', conversationIdValidator, validate, getConversationById);

router.post('/conversations/:id/messages', sendMessageValidator, validate, sendMessage);

router.delete('/conversations/:id', conversationIdValidator, validate, deleteConversation);

export default router;

