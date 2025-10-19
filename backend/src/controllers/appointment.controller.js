import { supabase } from '../config/supabase';
import { success } from '../utils/response';
import { NotFoundError, ValidationError } from '../utils/errors';
import { APPOINTMENT_STATUS } from '../config/constants';
import logger from '../utils/logger';

const getAppointments = async (req, res, next) => {
  try {
    const { status, upcoming } = req.query;

    let query = supabase
      .from('appointments')
      .select(`
        *,
        pet:pets(id, name, breed, photo_url),
        clinic:clinics(id, name, address, phone),
        service:services(id, name, category, base_price, duration_minutes)
      `)
      .eq('user_id', req.userId)
      .order('starts_at', { ascending: false });

    if (status) {
      query = query.eq('status', status);
    }

    if (upcoming === 'true') {
      query = query.gte('starts_at', new Date().toISOString());
    }

    const { data, error: dbError } = await query;

    if (dbError) throw dbError;

    return success(res, data, 'Citas obtenidas correctamente');
  } catch (err) {
    logger.error('Error al obtener citas:', err);
    next(err);
  }
};

const getAppointmentById = async (req, res, next) => {
  try {
    const { id } = req.params;

    const { data, error: dbError } = await supabase
      .from('appointments')
      .select(`
        *,
        pet:pets(id, name, breed, photo_url),
        clinic:clinics(id, name, address, phone),
        service:services(id, name, category, base_price, duration_minutes)
      `)
      .eq('id', id)
      .eq('user_id', req.userId)
      .single();

    if (dbError) throw dbError;
    if (!data) throw new NotFoundError('Cita no encontrada');

    return success(res, data, 'Cita obtenida correctamente');
  } catch (err) {
    logger.error('Error al obtener cita:', err);
    next(err);
  }
};

const createAppointment = async (req, res, next) => {
  try {
    const { pet_id, clinic_id, service_id, starts_at, ends_at, notes } = req.body;

    const { data: pet } = await supabase
      .from('pets')
      .select('id')
      .eq('id', pet_id)
      .eq('user_id', req.userId)
      .single();

    if (!pet) {
      throw new ValidationError('La mascota no pertenece al usuario');
    }

    const appointmentData = {
      user_id: req.userId,
      pet_id,
      clinic_id,
      service_id,
      starts_at,
      ends_at,
      status: APPOINTMENT_STATUS.PENDING,
      notes
    };

    const { data, error: dbError } = await supabase
      .from('appointments')
      .insert(appointmentData)
      .select(`
        *,
        pet:pets(id, name, breed, photo_url),
        clinic:clinics(id, name, address, phone),
        service:services(id, name, category, base_price, duration_minutes)
      `)
      .single();

    if (dbError) throw dbError;

    return success(res, data, 'Cita creada correctamente', 201);
  } catch (err) {
    logger.error('Error al crear cita:', err);
    next(err);
  }
};

const updateAppointment = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { starts_at, ends_at, notes } = req.body;

    const updateData = {};
    if (starts_at !== undefined) updateData.starts_at = starts_at;
    if (ends_at !== undefined) updateData.ends_at = ends_at;
    if (notes !== undefined) updateData.notes = notes;

    const { data, error: dbError } = await supabase
      .from('appointments')
      .update(updateData)
      .eq('id', id)
      .eq('user_id', req.userId)
      .select(`
        *,
        pet:pets(id, name, breed, photo_url),
        clinic:clinics(id, name, address, phone),
        service:services(id, name, category, base_price, duration_minutes)
      `)
      .single();

    if (dbError) throw dbError;
    if (!data) throw new NotFoundError('Cita no encontrada');

    return success(res, data, 'Cita actualizada correctamente');
  } catch (err) {
    logger.error('Error al actualizar cita:', err);
    next(err);
  }
};

const updateAppointmentStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const { data, error: dbError } = await supabase
      .from('appointments')
      .update({ status })
      .eq('id', id)
      .eq('user_id', req.userId)
      .select()
      .single();

    if (dbError) throw dbError;
    if (!data) throw new NotFoundError('Cita no encontrada');

    return success(res, data, `Cita ${status === 'cancelled' ? 'cancelada' : 'actualizada'} correctamente`);
  } catch (err) {
    logger.error('Error al actualizar estado de cita:', err);
    next(err);
  }
};

const deleteAppointment = async (req, res, next) => {
  try {
    const { id } = req.params;

    const { error: dbError } = await supabase
      .from('appointments')
      .delete()
      .eq('id', id)
      .eq('user_id', req.userId);

    if (dbError) throw dbError;

    return success(res, null, 'Cita eliminada correctamente');
  } catch (err) {
    logger.error('Error al eliminar cita:', err);
    next(err);
  }
};

export {
  getAppointments,
  getAppointmentById,
  createAppointment,
  updateAppointment,
  updateAppointmentStatus,
  deleteAppointment
};

