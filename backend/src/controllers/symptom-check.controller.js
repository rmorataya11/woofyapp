import { supabase } from '../config/supabase';
import { success } from '../utils/response';
import { NotFoundError, ValidationError } from '../utils/errors';
import { analyzeSymptoms } from '../services/ai.service';
import logger from '../utils/logger';

const getSymptomChecksByPet = async (req, res, next) => {
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
      .from('symptom_checks')
      .select('*')
      .eq('pet_id', petId)
      .order('created_at', { ascending: false });

    if (dbError) throw dbError;

    return success(res, data, 'Chequeos de síntomas obtenidos correctamente');
  } catch (err) {
    logger.error('Error al obtener chequeos de síntomas:', err);
    next(err);
  }
};

const getSymptomCheckById = async (req, res, next) => {
  try {
    const { id } = req.params;

    const { data, error: dbError } = await supabase
      .from('symptom_checks')
      .select(`
        *,
        pet:pets(id, name, breed, user_id)
      `)
      .eq('id', id)
      .single();

    if (dbError) throw dbError;
    if (!data) throw new NotFoundError('Chequeo de síntomas no encontrado');

    if (data.pet.user_id !== req.userId) {
      throw new NotFoundError('Chequeo de síntomas no encontrado');
    }

    return success(res, data, 'Chequeo de síntomas obtenido correctamente');
  } catch (err) {
    logger.error('Error al obtener chequeo de síntomas:', err);
    next(err);
  }
};

const createSymptomCheck = async (req, res, next) => {
  try {
    const { petId } = req.params;
    const { symptoms } = req.body;

    const { data: pet, error: petError } = await supabase
      .from('pets')
      .select('*')
      .eq('id', petId)
      .eq('user_id', req.userId)
      .single();

    if (petError || !pet) {
      throw new ValidationError('La mascota no pertenece al usuario');
    }

    const analysis = await analyzeSymptoms(pet, symptoms);

    const checkData = {
      pet_id: petId,
      symptoms,
      triage_level: analysis.triage_level,
      advice: analysis.advice,
      next_actions: analysis.next_actions
    };

    const { data, error: dbError } = await supabase
      .from('symptom_checks')
      .insert(checkData)
      .select()
      .single();

    if (dbError) throw dbError;

    return success(res, {
      ...data,
      possible_causes: analysis.possible_causes
    }, 'Análisis de síntomas completado', 201);
  } catch (err) {
    logger.error('Error al crear chequeo de síntomas:', err);
    
    if (err.message.includes('OpenAI no está configurado')) {
      return res.status(503).json({
        success: false,
        message: 'El servicio de análisis de síntomas no está disponible temporalmente'
      });
    }
    
    next(err);
  }
};

export {
  getSymptomChecksByPet,
  getSymptomCheckById,
  createSymptomCheck
};

