import { supabase } from '../config/supabase';
import { success } from '../utils/response';
import { NotFoundError, ValidationError } from '../utils/errors';
import logger from '../utils/logger';

const getMedicalRecordsByPet = async (req, res, next) => {
  try {
    const { petId } = req.params;
    const { type } = req.query;

    const { data: pet } = await supabase
      .from('pets')
      .select('id')
      .eq('id', petId)
      .eq('user_id', req.userId)
      .single();

    if (!pet) {
      throw new NotFoundError('Mascota no encontrada');
    }

    let query = supabase
      .from('medical_records')
      .select('*')
      .eq('pet_id', petId)
      .order('date', { ascending: false });

    if (type) {
      query = query.eq('type', type);
    }

    const { data, error: dbError } = await query;

    if (dbError) throw dbError;

    return success(res, data, 'Registros médicos obtenidos correctamente');
  } catch (err) {
    logger.error('Error al obtener registros médicos:', err);
    next(err);
  }
};

const getMedicalRecordById = async (req, res, next) => {
  try {
    const { id } = req.params;

    const { data, error: dbError } = await supabase
      .from('medical_records')
      .select(`
        *,
        pet:pets(id, name, breed, user_id)
      `)
      .eq('id', id)
      .single();

    if (dbError) throw dbError;
    if (!data) throw new NotFoundError('Registro médico no encontrado');

    if (data.pet.user_id !== req.userId) {
      throw new NotFoundError('Registro médico no encontrado');
    }

    return success(res, data, 'Registro médico obtenido correctamente');
  } catch (err) {
    logger.error('Error al obtener registro médico:', err);
    next(err);
  }
};

const createMedicalRecord = async (req, res, next) => {
  try {
    const { petId } = req.params;
    const { type, date, notes, attachments } = req.body;

    const { data: pet } = await supabase
      .from('pets')
      .select('id')
      .eq('id', petId)
      .eq('user_id', req.userId)
      .single();

    if (!pet) {
      throw new ValidationError('La mascota no pertenece al usuario');
    }

    const recordData = {
      pet_id: petId,
      type,
      date,
      notes,
      attachments
    };

    const { data, error: dbError } = await supabase
      .from('medical_records')
      .insert(recordData)
      .select()
      .single();

    if (dbError) throw dbError;

    return success(res, data, 'Registro médico creado correctamente', 201);
  } catch (err) {
    logger.error('Error al crear registro médico:', err);
    next(err);
  }
};

const updateMedicalRecord = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { type, date, notes, attachments } = req.body;

    const { data: record } = await supabase
      .from('medical_records')
      .select('pet_id, pets(user_id)')
      .eq('id', id)
      .single();

    if (!record || record.pets.user_id !== req.userId) {
      throw new NotFoundError('Registro médico no encontrado');
    }

    const updateData = {};
    if (type !== undefined) updateData.type = type;
    if (date !== undefined) updateData.date = date;
    if (notes !== undefined) updateData.notes = notes;
    if (attachments !== undefined) updateData.attachments = attachments;

    const { data, error: dbError } = await supabase
      .from('medical_records')
      .update(updateData)
      .eq('id', id)
      .select()
      .single();

    if (dbError) throw dbError;

    return success(res, data, 'Registro médico actualizado correctamente');
  } catch (err) {
    logger.error('Error al actualizar registro médico:', err);
    next(err);
  }
};

const deleteMedicalRecord = async (req, res, next) => {
  try {
    const { id } = req.params;

    const { data: record } = await supabase
      .from('medical_records')
      .select('pet_id, pets(user_id)')
      .eq('id', id)
      .single();

    if (!record || record.pets.user_id !== req.userId) {
      throw new NotFoundError('Registro médico no encontrado');
    }

    const { error: dbError } = await supabase
      .from('medical_records')
      .delete()
      .eq('id', id);

    if (dbError) throw dbError;

    return success(res, null, 'Registro médico eliminado correctamente');
  } catch (err) {
    logger.error('Error al eliminar registro médico:', err);
    next(err);
  }
};

export {
  getMedicalRecordsByPet,
  getMedicalRecordById,
  createMedicalRecord,
  updateMedicalRecord,
  deleteMedicalRecord
};

