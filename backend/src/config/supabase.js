import {createClient} from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Faltan las variables de entorno de Supabase');
}
const supabase = createClient(supabaseUrl, supabaseAnonKey);

const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

export { supabase, supabaseAdmin };

