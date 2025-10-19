import { supabase } from '../config/supabase';
import { success } from '../utils/response';
import { NotFoundError } from '../utils/errors';
import logger from '../utils/logger';

const getMyProfile = async (req, res, next) => {
  try {
    const { data, error: dbError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', req.userId)
      .single();

    if (dbError) throw dbError;
    if (!data) throw new NotFoundError('Perfil no encontrado');

    return success(res, data, 'Perfil obtenido correctamente');
  } catch (err) {
    logger.error('Error al obtener perfil:', err);
    next(err);
  }
};

const updateMyProfile = async (req, res, next) => {
  try {
    const { name, phone, avatar_url } = req.body;

    const updateData = {};
    if (name !== undefined) updateData.name = name;
    if (phone !== undefined) updateData.phone = phone;
    if (avatar_url !== undefined) updateData.avatar_url = avatar_url;

    const { data, error: dbError } = await supabase
      .from('profiles')
      .update(updateData)
      .eq('id', req.userId)
      .select()
      .single();

    if (dbError) throw dbError;

    return success(res, data, 'Perfil actualizado correctamente');
  } catch (err) {
    logger.error('Error al actualizar perfil:', err);
    next(err);
  }
};

export {
  getMyProfile,
  updateMyProfile
};

