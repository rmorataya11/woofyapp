import { supabase } from '../config/supabase';
import { success } from '../utils/response';
import { NotFoundError } from '../utils/errors';
import { generateChatResponse } from '../services/ai.service';
import logger from '../utils/logger';

const getConversations = async (req, res, next) => {
  try {
    const { data, error: dbError } = await supabase
      .from('ai_conversations')
      .select('*')
      .eq('user_id', req.userId)
      .order('updated_at', { ascending: false });

    if (dbError) throw dbError;

    return success(res, data, 'Conversaciones obtenidas correctamente');
  } catch (err) {
    logger.error('Error al obtener conversaciones:', err);
    next(err);
  }
};

const getConversationById = async (req, res, next) => {
  try {
    const { id } = req.params;

    const { data: conversation, error: convError } = await supabase
      .from('ai_conversations')
      .select('*')
      .eq('id', id)
      .eq('user_id', req.userId)
      .single();

    if (convError) throw convError;
    if (!conversation) throw new NotFoundError('Conversación no encontrada');

    const { data: messages, error: msgError } = await supabase
      .from('ai_messages')
      .select('*')
      .eq('conversation_id', id)
      .order('created_at', { ascending: true });

    if (msgError) throw msgError;

    return success(res, {
      ...conversation,
      messages
    }, 'Conversación obtenida correctamente');
  } catch (err) {
    logger.error('Error al obtener conversación:', err);
    next(err);
  }
};

const createConversation = async (req, res, next) => {
  try {
    const { title } = req.body;

    const conversationData = {
      user_id: req.userId,
      title: title || 'Nueva conversación'
    };

    const { data, error: dbError } = await supabase
      .from('ai_conversations')
      .insert(conversationData)
      .select()
      .single();

    if (dbError) throw dbError;

    return success(res, data, 'Conversación creada correctamente', 201);
  } catch (err) {
    logger.error('Error al crear conversación:', err);
    next(err);
  }
};

const sendMessage = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { content, pet_id } = req.body;

    const { data: conversation, error: convError } = await supabase
      .from('ai_conversations')
      .select('*')
      .eq('id', id)
      .eq('user_id', req.userId)
      .single();

    if (convError || !conversation) {
      throw new NotFoundError('Conversación no encontrada');
    }

    const { data: previousMessages } = await supabase
      .from('ai_messages')
      .select('role, content')
      .eq('conversation_id', id)
      .order('created_at', { ascending: true });

    const { data: userMessage, error: userMsgError } = await supabase
      .from('ai_messages')
      .insert({
        conversation_id: id,
        role: 'user',
        content
      })
      .select()
      .single();

    if (userMsgError) throw userMsgError;

    let petContext = null;
    if (pet_id) {
      const { data: pet } = await supabase
        .from('pets')
        .select('*')
        .eq('id', pet_id)
        .eq('user_id', req.userId)
        .single();

      if (pet) {
        petContext = {
          name: pet.name,
          breed: pet.breed,
          age_months: pet.age_months,
          weight_kg: pet.weight_kg
        };
      }
    }

    const messages = [
      ...previousMessages.map(msg => ({
        role: msg.role,
        content: msg.content
      })),
      { role: 'user', content }
    ];

    const aiResponse = await generateChatResponse(messages, petContext);

    const { data: assistantMessage, error: aiMsgError } = await supabase
      .from('ai_messages')
      .insert({
        conversation_id: id,
        role: 'assistant',
        content: aiResponse
      })
      .select()
      .single();

    if (aiMsgError) throw aiMsgError;

    if (!conversation.title || conversation.title === 'Nueva conversación') {
      const newTitle = content.substring(0, 50) + (content.length > 50 ? '...' : '');
      await supabase
        .from('ai_conversations')
        .update({ title: newTitle })
        .eq('id', id);
    }

    return success(res, {
      user_message: userMessage,
      assistant_message: assistantMessage
    }, 'Mensaje enviado correctamente', 201);
  } catch (err) {
    logger.error('Error al enviar mensaje:', err);
    
    if (err.message.includes('OpenAI no está configurado')) {
      return res.status(503).json({
        success: false,
        message: 'El servicio de chat con IA no está disponible temporalmente'
      });
    }
    
    next(err);
  }
};

const deleteConversation = async (req, res, next) => {
  try {
    const { id } = req.params;

    const { error: dbError } = await supabase
      .from('ai_conversations')
      .delete()
      .eq('id', id)
      .eq('user_id', req.userId);

    if (dbError) throw dbError;

    return success(res, null, 'Conversación eliminada correctamente');
  } catch (err) {
    logger.error('Error al eliminar conversación:', err);
    next(err);
  }
};

export {
  getConversations,
  getConversationById,
  createConversation,
  sendMessage,
  deleteConversation
};

