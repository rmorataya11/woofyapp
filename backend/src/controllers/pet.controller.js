import { supabase } from '../config/supabase';
import { success } from '../utils/response';
import { NotFoundError } from '../utils/errors';
import logger from '../utils/logger';

const getPets = async (req, res, next) => {
  try {
    const { data, error: dbError } = await supabase
      .from('pets')
      .select('*')
      .eq('user_id', req.userId)
      .order('created_at', { ascending: false });

    if (dbError) throw dbError;

    return success(res, data, 'Mascotas obtenidas correctamente');
  } catch (err) {
    logger.error('Error al obtener mascotas:', err);
    next(err);
  }
};

const getPetById = async (req, res, next) => {
  try {
    const { id } = req.params;

    const { data, error: dbError } = await supabase
      .from('pets')
      .select('*')
      .eq('id', id)
      .eq('user_id', req.userId)
      .single();

    if (dbError) throw dbError;
    if (!data) throw new NotFoundError('Mascota no encontrada');

    return success(res, data, 'Mascota obtenida correctamente');
  } catch (err) {
    logger.error('Error al obtener mascota:', err);
    next(err);
  }
};

const createPet = async (req, res, next) => {
  try {
    const { name, breed, age_months, weight_kg, photo_url } = req.body;

    const petData = {
      user_id: req.userId,
      name,
      breed,
      age_months,
      weight_kg,
      photo_url
    };

    const { data, error: dbError } = await supabase
      .from('pets')
      .insert(petData)
      .select()
      .single();

    if (dbError) throw dbError;

    return success(res, data, 'Mascota creada correctamente', 201);
  } catch (err) {
    logger.error('Error al crear mascota:', err);
    next(err);
  }
};

const updatePet = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { name, breed, age_months, weight_kg, photo_url } = req.body;

    const updateData = {};
    if (name !== undefined) updateData.name = name;
    if (breed !== undefined) updateData.breed = breed;
    if (age_months !== undefined) updateData.age_months = age_months;
    if (weight_kg !== undefined) updateData.weight_kg = weight_kg;
    if (photo_url !== undefined) updateData.photo_url = photo_url;

    const { data, error: dbError } = await supabase
      .from('pets')
      .update(updateData)
      .eq('id', id)
      .eq('user_id', req.userId)
      .select()
      .single();

    if (dbError) throw dbError;
    if (!data) throw new NotFoundError('Mascota no encontrada');

    return success(res, data, 'Mascota actualizada correctamente');
  } catch (err) {
    logger.error('Error al actualizar mascota:', err);
    next(err);
  }
};

const deletePet = async (req, res, next) => {
  try {
    const { id } = req.params;

    const { error: dbError } = await supabase
      .from('pets')
      .delete()
      .eq('id', id)
      .eq('user_id', req.userId);

    if (dbError) throw dbError;

    return success(res, null, 'Mascota eliminada correctamente');
  } catch (err) {
    logger.error('Error al eliminar mascota:', err);
    next(err);
  }
};

export {
  getPets,
  getPetById,
  createPet,
  updatePet,
  deletePet
};

