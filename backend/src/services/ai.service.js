import { openai } from '../config/openai';
import { TRIAGE_LEVELS } from '../config/constants';
import logger from '../utils/logger';

const analyzeSymptoms = async (petInfo, symptoms) => {
  try {
    if (!openai) {
      throw new Error('OpenAI no está configurado');
    }

    const prompt = `Eres un asistente veterinario experto. Analiza los siguientes síntomas de una mascota:

Información de la mascota:
- Nombre: ${petInfo.name}
- Raza: ${petInfo.breed || 'No especificada'}
- Edad: ${petInfo.age_months ? `${petInfo.age_months} meses` : 'No especificada'}
- Peso: ${petInfo.weight_kg ? `${petInfo.weight_kg} kg` : 'No especificado'}

Síntomas reportados:
${symptoms}

Por favor proporciona:
1. Nivel de urgencia (low, medium, high)
2. Posibles causas
3. Recomendaciones inmediatas
4. Próximos pasos

Responde en formato JSON con esta estructura:
{
  "triage_level": "low|medium|high",
  "possible_causes": ["causa 1", "causa 2"],
  "advice": "texto con recomendaciones",
  "next_actions": ["acción 1", "acción 2"]
}`;

    const response = await openai.chat.completions.create({
      model: 'gpt-4 o-mini',
      messages: [
        {
          role: 'system',
          content: 'Eres un asistente veterinario experto que proporciona análisis preliminares de síntomas. Siempre recomiendas consultar a un veterinario para diagnósticos definitivos.'
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      temperature: 0.7,
      response_format: { type: 'json_object' }
    });

    const result = JSON.parse(response.choices[0].message.content);

    if (!Object.values(TRIAGE_LEVELS).includes(result.triage_level)) {
      result.triage_level = TRIAGE_LEVELS.MEDIUM;
    }

    return {
      triage_level: result.triage_level,
      advice: result.advice,
      next_actions: result.next_actions || [],
      possible_causes: result.possible_causes || []
    };
  } catch (error) {
    logger.error('Error al analizar síntomas con IA:', error);
    throw new Error('Error al procesar el análisis de síntomas');
  }
};

const generateChatResponse = async (messages, petContext = null) => {
  try {
    if (!openai) {
      throw new Error('OpenAI no está configurado');
    }

    const systemMessage = {
      role: 'system',
      content: `Eres "WooFy Assistant", un asistente veterinario inteligente y amigable. 
Tu objetivo es ayudar a los dueños de mascotas con información sobre cuidado, salud y bienestar animal.

Pautas:
- Sé empático y comprensivo
- Proporciona información precisa y útil
- SIEMPRE recomienda consultar a un veterinario profesional para diagnósticos y tratamientos
- No proporciones diagnósticos definitivos ni prescripciones médicas
- Si la situación parece urgente, enfatiza la necesidad de atención veterinaria inmediata
- Responde en español de manera clara y concisa

${petContext ? `Contexto de la mascota actual:\n${JSON.stringify(petContext, null, 2)}` : ''}`
    };

    const chatMessages = [systemMessage, ...messages];

    const response = await openai.chat.completions.create({
      model: 'gpt-4 o-mini',
      messages: chatMessages,
      temperature: 0.8,
      max_tokens: 500
    });

    return response.choices[0].message.content;
  } catch (error) {
    logger.error('Error al generar respuesta de chat:', error);
    throw new Error('Error al generar respuesta del asistente');
  }
};

const generateChatResponseStream = async (messages, petContext = null) => {
  try {
    if (!openai) {
      throw new Error('OpenAI no está configurado');
    }

    const systemMessage = {
      role: 'system',
      content: `Eres "WooFy Assistant", un asistente veterinario inteligente y amigable. 
Tu objetivo es ayudar a los dueños de mascotas con información sobre cuidado, salud y bienestar animal.

Pautas:
- Sé empático y comprensivo
- Proporciona información precisa y útil
- SIEMPRE recomienda consultar a un veterinario profesional para diagnósticos y tratamientos
- No proporciones diagnósticos definitivos ni prescripciones médicas
- Si la situación parece urgente, enfatiza la necesidad de atención veterinaria inmediata
- Responde en español de manera clara y concisa

${petContext ? `Contexto de la mascota actual:\n${JSON.stringify(petContext, null, 2)}` : ''}`
    };

    const chatMessages = [systemMessage, ...messages];

    const stream = await openai.chat.completions.create({
      model: 'gpt-4 o-mini',
      messages: chatMessages,
      temperature: 0.8,
      max_tokens: 500,
      stream: true
    });

    return stream;
  } catch (error) {
    logger.error('Error al generar respuesta de chat en streaming:', error);
    throw new Error('Error al generar respuesta del asistente');
  }
};

export {
  analyzeSymptoms,
  generateChatResponse,
  generateChatResponseStream
};

