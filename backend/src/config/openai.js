import {OpenAI} from 'openai';

const apiKey = process.env.OPENAI_API_KEY;

if (!apiKey) {
  console.warn('OPENAI_API_KEY is not configured. The AI functions will be disabled.');
}

const openai = apiKey ? new OpenAI({ apiKey }) : null;

export { openai };

