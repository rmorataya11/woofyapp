import { supabase } from '../config/supabase';
import { success } from '../utils/response';
import { NotFoundError } from '../utils/errors';
import logger from '../utils/logger';

const getReminders = async (req, res, next) => {
  try {
    const { upcoming, type } = req.query;

    const { data: pets } = await supabase
      .from('pets')
      .select('id')
      .eq('user_id', req.userId);

    const petIds = pets.map(p => p.id);

    if (petIds.length === 0) {
      return success(res, [], 'No hay recordatorios');
    }

    let query = supabase
      .from('reminders')
      .select(`
        *,
        pet:pets(id, name, breed, photo_url)
      `)
      .in('pet_id', petIds)
      .order('due_at', { ascending: true });

    if (upcoming === 'true') {
      query = query.gte('due_at', new Date().toISOString());
    }

    if (type) {
      query = query.eq('type', type);
    }

    const { data, error: dbError } = await query;

    if (dbError) throw dbError;

    return success(res, data, 'Recordatorios obtenidos correctamente');
  } catch (err) {
    logger.error('Error al obtener recordatorios:', err);
    next(err);
  }
};

const getRemindersByPet = async (req, res, next) => {
  try {
    const { petId } = req.params;

    const { data: pet } = await supabase
      .from('pets')
      .select('id')
      .eq('id', petId)
      .eq('user_id', req.userId)
      .single();

    if (!pet) {
      throw new NotFoundError('Mascota no encontrada');
    }

    const { data, error: dbError } = await supabase
      .from('reminders')
      .select('*')
      .eq('pet_id', petId)
      .order('due_at', { ascending: true });

    if (dbError) throw dbError;

    return success(res, data, 'Recordatorios obtenidos correctamente');
  } catch (err) {
    logger.error('Error al obtener recordatorios:', err);
    next(err);
  }
};

const getReminderById = async (req, res, next) => {
  try {
    const { id } = req.params;

    const { data, error: dbError } = await supabase
      .from('reminders')
      .select(`
        *,
        pet:pets(id, name, breed, user_id)
      `)
      .eq('id', id)
      .single();

    if (dbError) throw dbError;
    if (!data) throw new NotFoundError('Recordatorio no encontrado');

    if (data.pet.user_id !== req.userId) {
      throw new NotFoundError('Recordatorio no encontrado');
    }

    return success(res, data, 'Recordatorio obtenido correctamente');
  } catch (err) {
    logger.error('Error al obtener recordatorio:', err);
    next(err);
  }
};

const createReminder = async (req, res, next) => {
  try {
    const { petId } = req.params;
    const { title, description, due_at, type } = req.body;

    const { data: pet } = await supabase
      .from('pets')
      .select('id')
      .eq('id', petId)
      .eq('user_id', req.userId)
      .single();

    if (!pet) {
        throw new NotFoundError('La mascota no pertenece al usuario');
    }

    const reminderData = {
      pet_id: petId,
      title,
      description,
      due_at,
      type
    };

    const { data, error: dbError } = await supabase
      .from('reminders')
      .insert(reminderData)
      .select()
      .single();

    if (dbError) throw dbError;

    return success(res, data, 'Recordatorio creado correctamente', 201);
  } catch (err) {
    logger.error('Error al crear recordatorio:', err);
    next(err);
  }
};

const updateReminder = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { title, description, due_at, type, is_sent } = req.body;

    const { data: reminder } = await supabase
      .from('reminders')
      .select('pet_id, pets(user_id)')
      .eq('id', id)
      .single();

    if (!reminder || reminder.pets.user_id !== req.userId) {
      throw new NotFoundError('Recordatorio no encontrado');
    }

    const updateData = {};
    if (title !== undefined) updateData.title = title;
    if (description !== undefined) updateData.description = description;
    if (due_at !== undefined) updateData.due_at = due_at;
    if (type !== undefined) updateData.type = type;
    if (is_sent !== undefined) updateData.is_sent = is_sent;

    const { data, error: dbError } = await supabase
      .from('reminders')
      .update(updateData)
      .eq('id', id)
      .select()
      .single();

    if (dbError) throw dbError;

    return success(res, data, 'Recordatorio actualizado correctamente');
  } catch (err) {
    logger.error('Error al actualizar recordatorio:', err);
    next(err);
  }
};

const deleteReminder = async (req, res, next) => {
  try {
    const { id } = req.params;

    const { data: reminder } = await supabase
      .from('reminders')
      .select('pet_id, pets(user_id)')
      .eq('id', id)
      .single();

    if (!reminder || reminder.pets.user_id !== req.userId) {
      throw new NotFoundError('Recordatorio no encontrado');
    }

    const { error: dbError } = await supabase
      .from('reminders')
      .delete()
      .eq('id', id);

    if (dbError) throw dbError;

    return success(res, null, 'Recordatorio eliminado correctamente');
  } catch (err) {
    logger.error('Error al eliminar recordatorio:', err);
    next(err);
  }
};

export {
  getReminders,
  getRemindersByPet,
  getReminderById,
  createReminder,
  updateReminder,
  deleteReminder
};

