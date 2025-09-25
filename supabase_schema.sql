-- =============================================
-- WOOFY APP - SUPABASE SCHEMA
-- =============================================

-- 1. EXTENSIONES NECESARIAS
-- =============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. TABLA DE PERFILES DE USUARIO
-- =============================================
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT,
    phone TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS (Row Level Security) para profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver y editar su propio perfil
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- 3. TABLA DE MASCOTAS
-- =============================================
CREATE TABLE public.pets (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    breed TEXT,
    age_months INTEGER,
    weight_kg DECIMAL(5,2),
    photo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS para pets
ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver y editar sus propias mascotas
CREATE POLICY "Users can view own pets" ON public.pets
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own pets" ON public.pets
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own pets" ON public.pets
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own pets" ON public.pets
    FOR DELETE USING (auth.uid() = user_id);

-- 4. TABLA DE CLÍNICAS
-- =============================================
CREATE TABLE public.clinics (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    phone TEXT,
    email TEXT,
    website TEXT,
    rating DECIMAL(3, 2) DEFAULT 0.0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS para clinics (público, todos pueden leer)
ALTER TABLE public.clinics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Clinics are viewable by everyone" ON public.clinics
    FOR SELECT USING (true);

-- 5. TABLA DE HORARIOS DE CLÍNICAS
-- =============================================
CREATE TABLE public.clinic_hours (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    clinic_id UUID REFERENCES public.clinics(id) ON DELETE CASCADE NOT NULL,
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6), -- 0=domingo, 6=sábado
    open_time TIME,
    close_time TIME,
    is_closed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS para clinic_hours
ALTER TABLE public.clinic_hours ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Clinic hours are viewable by everyone" ON public.clinic_hours
    FOR SELECT USING (true);

-- 6. TABLA DE SERVICIOS
-- =============================================
CREATE TABLE public.services (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    clinic_id UUID REFERENCES public.clinics(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    category TEXT NOT NULL, -- 'consultation', 'vaccination', 'surgery', 'grooming', etc.
    base_price DECIMAL(10, 2),
    currency TEXT DEFAULT 'USD',
    description TEXT,
    duration_minutes INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS para services
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Services are viewable by everyone" ON public.services
    FOR SELECT USING (true);

-- 7. TABLA DE CITAS
-- =============================================
CREATE TABLE public.appointments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    pet_id UUID REFERENCES public.pets(id) ON DELETE CASCADE NOT NULL,
    clinic_id UUID REFERENCES public.clinics(id) ON DELETE CASCADE NOT NULL,
    service_id UUID REFERENCES public.services(id) ON DELETE CASCADE NOT NULL,
    starts_at TIMESTAMP WITH TIME ZONE NOT NULL,
    ends_at TIMESTAMP WITH TIME ZONE NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'rescheduled', 'cancelled', 'done')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS para appointments
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own appointments" ON public.appointments
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own appointments" ON public.appointments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own appointments" ON public.appointments
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own appointments" ON public.appointments
    FOR DELETE USING (auth.uid() = user_id);

-- 8. TABLA DE REGISTROS MÉDICOS
-- =============================================
CREATE TABLE public.medical_records (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    pet_id UUID REFERENCES public.pets(id) ON DELETE CASCADE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('vaccine', 'deworm', 'antiflea', 'surgery', 'allergy', 'weight', 'other')),
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    notes TEXT,
    attachments TEXT[], -- Array de URLs de archivos adjuntos
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS para medical_records
ALTER TABLE public.medical_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own pet medical records" ON public.medical_records
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = medical_records.pet_id 
            AND pets.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own pet medical records" ON public.medical_records
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = medical_records.pet_id 
            AND pets.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own pet medical records" ON public.medical_records
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = medical_records.pet_id 
            AND pets.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete own pet medical records" ON public.medical_records
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = medical_records.pet_id 
            AND pets.user_id = auth.uid()
        )
    );

-- 9. TABLA DE RECORDATORIOS
-- =============================================
CREATE TABLE public.reminders (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    pet_id UUID REFERENCES public.pets(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    due_at TIMESTAMP WITH TIME ZONE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('vaccine', 'deworm', 'antiflea', 'checkup', 'grooming', 'other')),
    is_sent BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS para reminders
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own pet reminders" ON public.reminders
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = reminders.pet_id 
            AND pets.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own pet reminders" ON public.reminders
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = reminders.pet_id 
            AND pets.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own pet reminders" ON public.reminders
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = reminders.pet_id 
            AND pets.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete own pet reminders" ON public.reminders
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = reminders.pet_id 
            AND pets.user_id = auth.uid()
        )
    );

-- 10. TABLA DE DIAGNÓSTICOS PRELIMINARES
-- =============================================
CREATE TABLE public.symptom_checks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    pet_id UUID REFERENCES public.pets(id) ON DELETE CASCADE NOT NULL,
    symptoms TEXT NOT NULL,
    triage_level TEXT NOT NULL CHECK (triage_level IN ('low', 'medium', 'high')),
    advice TEXT NOT NULL,
    next_actions TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS para symptom_checks
ALTER TABLE public.symptom_checks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own pet symptom checks" ON public.symptom_checks
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = symptom_checks.pet_id 
            AND pets.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own pet symptom checks" ON public.symptom_checks
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = symptom_checks.pet_id 
            AND pets.user_id = auth.uid()
        )
    );

-- 11. TABLA DE CONVERSACIONES CON IA
-- =============================================
CREATE TABLE public.ai_conversations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS para ai_conversations
ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own AI conversations" ON public.ai_conversations
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own AI conversations" ON public.ai_conversations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own AI conversations" ON public.ai_conversations
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own AI conversations" ON public.ai_conversations
    FOR DELETE USING (auth.uid() = user_id);

-- 12. TABLA DE MENSAJES DE IA
-- =============================================
CREATE TABLE public.ai_messages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    conversation_id UUID REFERENCES public.ai_conversations(id) ON DELETE CASCADE NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS para ai_messages
ALTER TABLE public.ai_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own AI messages" ON public.ai_messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.ai_conversations 
            WHERE ai_conversations.id = ai_messages.conversation_id 
            AND ai_conversations.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own AI messages" ON public.ai_messages
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.ai_conversations 
            WHERE ai_conversations.id = ai_messages.conversation_id 
            AND ai_conversations.user_id = auth.uid()
        )
    );

-- 13. FUNCIONES DE ACTUALIZACIÓN AUTOMÁTICA
-- =============================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para actualizar updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pets_updated_at BEFORE UPDATE ON public.pets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clinics_updated_at BEFORE UPDATE ON public.clinics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON public.services
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON public.appointments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_medical_records_updated_at BEFORE UPDATE ON public.medical_records
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reminders_updated_at BEFORE UPDATE ON public.reminders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ai_conversations_updated_at BEFORE UPDATE ON public.ai_conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 14. FUNCIÓN PARA CREAR PERFIL AUTOMÁTICAMENTE
-- =============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, name)
    VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'name');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para crear perfil automáticamente
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 15. ÍNDICES PARA OPTIMIZACIÓN
-- =============================================

-- Índices para búsquedas geográficas
CREATE INDEX idx_clinics_location ON public.clinics USING GIST (point(longitude, latitude));

-- Índices para búsquedas por usuario
CREATE INDEX idx_pets_user_id ON public.pets(user_id);
CREATE INDEX idx_appointments_user_id ON public.appointments(user_id);
CREATE INDEX idx_medical_records_pet_id ON public.medical_records(pet_id);
CREATE INDEX idx_reminders_pet_id ON public.reminders(pet_id);
CREATE INDEX idx_symptom_checks_pet_id ON public.symptom_checks(pet_id);
CREATE INDEX idx_ai_conversations_user_id ON public.ai_conversations(user_id);
CREATE INDEX idx_ai_messages_conversation_id ON public.ai_messages(conversation_id);

-- Índices para fechas
CREATE INDEX idx_appointments_starts_at ON public.appointments(starts_at);
CREATE INDEX idx_reminders_due_at ON public.reminders(due_at);
CREATE INDEX idx_medical_records_date ON public.medical_records(date);

-- 16. DATOS DE EJEMPLO (OPCIONAL)
-- =============================================

-- Insertar algunas clínicas de ejemplo
INSERT INTO public.clinics (name, address, latitude, longitude, phone, rating) VALUES
('Clínica Veterinaria Central', 'Av. Principal 123, Ciudad', 40.7128, -74.0060, '+1-555-0123', 4.5),
('Hospital Veterinario San Patricio', 'Calle Secundaria 456, Ciudad', 40.7589, -73.9851, '+1-555-0456', 4.2),
('Centro Médico Animal', 'Boulevard Norte 789, Ciudad', 40.7505, -73.9934, '+1-555-0789', 4.8);

-- Insertar servicios de ejemplo
INSERT INTO public.services (clinic_id, name, category, base_price, description, duration_minutes) VALUES
((SELECT id FROM public.clinics LIMIT 1), 'Consulta General', 'consultation', 50.00, 'Consulta veterinaria general', 30),
((SELECT id FROM public.clinics LIMIT 1), 'Vacuna Triple', 'vaccination', 35.00, 'Vacuna contra enfermedades comunes', 15),
((SELECT id FROM public.clinics LIMIT 1), 'Desparasitación', 'treatment', 25.00, 'Tratamiento antiparasitario', 20);

-- Insertar horarios de ejemplo
INSERT INTO public.clinic_hours (clinic_id, day_of_week, open_time, close_time) VALUES
((SELECT id FROM public.clinics LIMIT 1), 1, '09:00', '18:00'), -- Lunes
((SELECT id FROM public.clinics LIMIT 1), 2, '09:00', '18:00'), -- Martes
((SELECT id FROM public.clinics LIMIT 1), 3, '09:00', '18:00'), -- Miércoles
((SELECT id FROM public.clinics LIMIT 1), 4, '09:00', '18:00'), -- Jueves
((SELECT id FROM public.clinics LIMIT 1), 5, '09:00', '18:00'), -- Viernes
((SELECT id FROM public.clinics LIMIT 1), 6, '09:00', '14:00'); -- Sábado
