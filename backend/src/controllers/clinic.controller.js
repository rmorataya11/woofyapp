import { supabase } from '../config/supabase';
import { success } from '../utils/response';
import { NotFoundError } from '../utils/errors';
import logger from '../utils/logger';

const getClinics = async (req, res, next) => {
  try {
    const { is_active = true } = req.query;

    let query = supabase
      .from('clinics')
      .select('*')
      .order('rating', { ascending: false });

    if (is_active !== undefined) {
      query = query.eq('is_active', is_active);
    }

    const { data, error: dbError } = await query;

    if (dbError) throw dbError;

    return success(res, data, 'Clínicas obtenidas correctamente');
  } catch (err) {
    logger.error('Error al obtener clínicas:', err);
    next(err);
  }
};

const getClinicById = async (req, res, next) => {
  try {
    const { id } = req.params;

    const { data, error: dbError } = await supabase
      .from('clinics')
      .select('*')
      .eq('id', id)
      .single();

    if (dbError) throw dbError;
    if (!data) throw new NotFoundError('Clínica no encontrada');

    return success(res, data, 'Clínica obtenida correctamente');
  } catch (err) {
    logger.error('Error al obtener clínica:', err);
    next(err);
  }
};

const getClinicServices = async (req, res, next) => {
  try {
    const { id } = req.params;

    const { data, error: dbError } = await supabase
      .from('services')
      .select('*')
      .eq('clinic_id', id)
      .eq('is_active', true)
      .order('category');

    if (dbError) throw dbError;

    return success(res, data, 'Servicios obtenidos correctamente');
  } catch (err) {
    logger.error('Error al obtener servicios:', err);
    next(err);
  }
};

const getClinicHours = async (req, res, next) => {
  try {
    const { id } = req.params;

    const { data, error: dbError } = await supabase
      .from('clinic_hours')
      .select('*')
      .eq('clinic_id', id)
      .order('day_of_week');

    if (dbError) throw dbError;

    return success(res, data, 'Horarios obtenidos correctamente');
  } catch (err) {
    logger.error('Error al obtener horarios:', err);
    next(err);
  }
};

export {
  getClinics,
  getClinicById,
  getClinicServices,
  getClinicHours
};

