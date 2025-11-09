--Ultima versión de las tablas de la base de datos
create table public.ai_conversations (
  id uuid not null default extensions.uuid_generate_v4 (),
  user_id uuid not null,
  title text null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint ai_conversations_pkey primary key (id),
  constraint ai_conversations_user_id_fkey foreign KEY (user_id) references profiles (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_ai_conversations_user_id on public.ai_conversations using btree (user_id) TABLESPACE pg_default;

create trigger update_ai_conversations_updated_at BEFORE
update on ai_conversations for EACH row
execute FUNCTION update_updated_at_column ();
create table public.ai_messages (
  id uuid not null default extensions.uuid_generate_v4 (),
  conversation_id uuid not null,
  role text not null,
  content text not null,
  created_at timestamp with time zone null default now(),
  constraint ai_messages_pkey primary key (id),
  constraint ai_messages_conversation_id_fkey foreign KEY (conversation_id) references ai_conversations (id) on delete CASCADE,
  constraint ai_messages_role_check check (
    (
      role = any (array['user'::text, 'assistant'::text])
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_ai_messages_conversation_id on public.ai_messages using btree (conversation_id) TABLESPACE pg_default;
create table public.appointment_requests (
  id uuid not null default extensions.uuid_generate_v4 (),
  user_id uuid not null,
  clinic_id uuid not null,
  pet_id uuid not null,
  preferred_date date not null,
  preferred_time time without time zone not null,
  service_type text not null,
  reason text not null,
  notes text null,
  status text null default 'pending_confirmation'::text,
  final_date date null,
  final_time time without time zone null,
  confirmed_at timestamp with time zone null,
  confirmation_notes text null,
  request_type text null default 'user_initiated'::text,
  cancelled_at timestamp with time zone null,
  cancellation_reason text null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint appointment_requests_pkey primary key (id),
  constraint appointment_requests_clinic_id_fkey foreign KEY (clinic_id) references clinics (id) on delete CASCADE,
  constraint appointment_requests_pet_id_fkey foreign KEY (pet_id) references pets (id) on delete CASCADE,
  constraint appointment_requests_user_id_fkey foreign KEY (user_id) references profiles (id) on delete CASCADE,
  constraint check_status check (
    (
      status = any (
        array[
          'pending_confirmation'::text,
          'confirmed_by_clinic'::text,
          'cancelled'::text,
          'rejected'::text
        ]
      )
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_appointment_requests_user on public.appointment_requests using btree (user_id) TABLESPACE pg_default;

create index IF not exists idx_appointment_requests_clinic on public.appointment_requests using btree (clinic_id) TABLESPACE pg_default;

create index IF not exists idx_appointment_requests_pet on public.appointment_requests using btree (pet_id) TABLESPACE pg_default;

create index IF not exists idx_appointment_requests_status on public.appointment_requests using btree (user_id, status) TABLESPACE pg_default;

create index IF not exists idx_appointment_requests_created on public.appointment_requests using btree (created_at desc) TABLESPACE pg_default;

create trigger update_appointment_requests_updated_at BEFORE
update on appointment_requests for EACH row
execute FUNCTION update_updated_at_column ();
create table public.appointments (
  id uuid not null default extensions.uuid_generate_v4 (),
  user_id uuid not null,
  pet_id uuid not null,
  clinic_id uuid not null,
  service_id uuid not null,
  starts_at timestamp with time zone not null,
  ends_at timestamp with time zone not null,
  status text not null default 'pending'::text,
  notes text null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  appointment_date date null,
  appointment_time time without time zone null,
  service_type text null,
  reason text null,
  created_from_request boolean null default false,
  request_id uuid null,
  constraint appointments_pkey primary key (id),
  constraint appointments_pet_id_fkey foreign KEY (pet_id) references pets (id) on delete CASCADE,
  constraint appointments_clinic_id_fkey foreign KEY (clinic_id) references clinics (id) on delete CASCADE,
  constraint appointments_service_id_fkey foreign KEY (service_id) references services (id) on delete CASCADE,
  constraint appointments_request_id_fkey foreign KEY (request_id) references appointment_requests (id) on delete set null,
  constraint appointments_user_id_fkey foreign KEY (user_id) references profiles (id) on delete CASCADE,
  constraint appointments_status_check check (
    (
      status = any (
        array[
          'pending'::text,
          'confirmed'::text,
          'scheduled'::text,
          'rescheduled'::text,
          'cancelled'::text,
          'done'::text
        ]
      )
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_appointments_user_id on public.appointments using btree (user_id) TABLESPACE pg_default;

create index IF not exists idx_appointments_starts_at on public.appointments using btree (starts_at) TABLESPACE pg_default;

create trigger update_appointments_updated_at BEFORE
update on appointments for EACH row
execute FUNCTION update_updated_at_column ();
create table public.clinic_contacts (
  id uuid not null default extensions.uuid_generate_v4 (),
  user_id uuid not null,
  clinic_id uuid not null,
  name text not null,
  email text not null,
  phone text null,
  subject text null,
  message text not null,
  status text null default 'pending'::text,
  created_at timestamp with time zone null default now(),
  constraint clinic_contacts_pkey primary key (id),
  constraint clinic_contacts_clinic_id_fkey foreign KEY (clinic_id) references clinics (id) on delete CASCADE,
  constraint clinic_contacts_user_id_fkey foreign KEY (user_id) references profiles (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_clinic_contacts_user_id on public.clinic_contacts using btree (user_id) TABLESPACE pg_default;

create index IF not exists idx_clinic_contacts_clinic_id on public.clinic_contacts using btree (clinic_id) TABLESPACE pg_default;

create index IF not exists idx_clinic_contacts_status on public.clinic_contacts using btree (status) TABLESPACE pg_default;

create index IF not exists idx_clinic_contacts_created_at on public.clinic_contacts using btree (created_at desc) TABLESPACE pg_default;
create table public.clinic_hours (
  id uuid not null default extensions.uuid_generate_v4 (),
  clinic_id uuid not null,
  day_of_week integer not null,
  open_time time without time zone null,
  close_time time without time zone null,
  is_closed boolean null default false,
  created_at timestamp with time zone null default now(),
  constraint clinic_hours_pkey primary key (id),
  constraint clinic_hours_clinic_id_fkey foreign KEY (clinic_id) references clinics (id) on delete CASCADE,
  constraint clinic_hours_day_of_week_check check (
    (
      (day_of_week >= 0)
      and (day_of_week <= 6)
    )
  )
) TABLESPACE pg_default;
create table public.clinics (
  id uuid not null default extensions.uuid_generate_v4 (),
  name text not null,
  address text not null,
  latitude numeric(10, 8) null,
  longitude numeric(11, 8) null,
  phone text null,
  email text null,
  website text null,
  rating numeric(3, 2) null default 0.0,
  is_active boolean null default true,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  google_place_id text null,
  constraint clinics_pkey primary key (id),
  constraint clinics_google_place_id_key unique (google_place_id)
) TABLESPACE pg_default;

create index IF not exists idx_clinics_location on public.clinics using gist (
  point(
    (longitude)::double precision,
    (latitude)::double precision
  )
) TABLESPACE pg_default;

create trigger update_clinics_updated_at BEFORE
update on clinics for EACH row
execute FUNCTION update_updated_at_column ();
create table public.medical_records (
  id uuid not null default extensions.uuid_generate_v4 (),
  pet_id uuid not null,
  type text not null,
  date timestamp with time zone not null,
  notes text null,
  attachments text[] null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  user_id uuid null,
  constraint medical_records_pkey primary key (id),
  constraint medical_records_pet_id_fkey foreign KEY (pet_id) references pets (id) on delete CASCADE,
  constraint medical_records_user_id_fkey foreign KEY (user_id) references profiles (id) on delete CASCADE,
  constraint medical_records_type_check check (
    (
      type = any (
        array[
          'vaccine'::text,
          'deworm'::text,
          'antiflea'::text,
          'surgery'::text,
          'allergy'::text,
          'weight'::text,
          'other'::text
        ]
      )
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_medical_records_pet_id on public.medical_records using btree (pet_id) TABLESPACE pg_default;

create index IF not exists idx_medical_records_date on public.medical_records using btree (date) TABLESPACE pg_default;

create trigger update_medical_records_updated_at BEFORE
update on medical_records for EACH row
execute FUNCTION update_updated_at_column ();
create table public.notifications (
  id uuid not null default extensions.uuid_generate_v4 (),
  user_id uuid not null,
  type text not null,
  title text not null,
  body text not null,
  data jsonb null,
  read boolean null default false,
  read_at timestamp with time zone null,
  created_at timestamp with time zone null default now(),
  constraint notifications_pkey primary key (id),
  constraint notifications_user_id_fkey foreign KEY (user_id) references profiles (id) on delete CASCADE,
  constraint notifications_type_check check (
    (
      type = any (
        array[
          'appointment'::text,
          'reminder'::text,
          'general'::text,
          'promotion'::text
        ]
      )
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_notifications_user_id on public.notifications using btree (user_id) TABLESPACE pg_default;

create index IF not exists idx_notifications_read on public.notifications using btree (user_id, read) TABLESPACE pg_default;

create index IF not exists idx_notifications_type on public.notifications using btree (user_id, type) TABLESPACE pg_default;

create index IF not exists idx_notifications_created_at on public.notifications using btree (user_id, created_at desc) TABLESPACE pg_default;
create table public.pets (
  id uuid not null default extensions.uuid_generate_v4 (),
  user_id uuid not null,
  name text not null,
  breed text null,
  age_months integer null,
  weight_kg numeric(5, 2) null,
  photo_url text null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  age integer null,
  weight numeric(5, 2) null,
  vaccination_status text null default 'unknown'::text,
  medical_notes text null,
  constraint pets_pkey primary key (id),
  constraint pets_user_id_fkey foreign KEY (user_id) references profiles (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_pets_user_id on public.pets using btree (user_id) TABLESPACE pg_default;

create trigger update_pets_updated_at BEFORE
update on pets for EACH row
execute FUNCTION update_updated_at_column ();
create table public.profiles (
  id uuid not null,
  email text not null,
  name text null,
  phone text null,
  avatar_url text null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  preferences jsonb null default '{}'::jsonb,
  constraint profiles_pkey primary key (id),
  constraint profiles_email_key unique (email),
  constraint profiles_id_fkey foreign KEY (id) references auth.users (id) on delete CASCADE
) TABLESPACE pg_default;

create trigger update_profiles_updated_at BEFORE
update on profiles for EACH row
execute FUNCTION update_updated_at_column ();
create table public.reminders (
  id uuid not null default extensions.uuid_generate_v4 (),
  pet_id uuid not null,
  title text not null,
  description text null,
  due_at timestamp with time zone not null,
  type text not null,
  is_sent boolean null default false,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  user_id uuid null,
  is_completed boolean null default false,
  constraint reminders_pkey primary key (id),
  constraint reminders_pet_id_fkey foreign KEY (pet_id) references pets (id) on delete CASCADE,
  constraint reminders_user_id_fkey foreign KEY (user_id) references profiles (id) on delete CASCADE,
  constraint reminders_type_check check (
    (
      type = any (
        array[
          'vaccine'::text,
          'deworm'::text,
          'antiflea'::text,
          'checkup'::text,
          'grooming'::text,
          'other'::text
        ]
      )
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_reminders_pet_id on public.reminders using btree (pet_id) TABLESPACE pg_default;

create index IF not exists idx_reminders_due_at on public.reminders using btree (due_at) TABLESPACE pg_default;

create trigger update_reminders_updated_at BEFORE
update on reminders for EACH row
execute FUNCTION update_updated_at_column ();
create table public.services (
  id uuid not null default extensions.uuid_generate_v4 (),
  clinic_id uuid not null,
  name text not null,
  category text not null,
  base_price numeric(10, 2) null,
  currency text null default 'USD'::text,
  description text null,
  duration_minutes integer null,
  is_active boolean null default true,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint services_pkey primary key (id),
  constraint services_clinic_id_fkey foreign KEY (clinic_id) references clinics (id) on delete CASCADE
) TABLESPACE pg_default;

create trigger update_services_updated_at BEFORE
update on services for EACH row
execute FUNCTION update_updated_at_column ();
create table public.symptom_checks (
  id uuid not null default extensions.uuid_generate_v4 (),
  pet_id uuid not null,
  symptoms text not null,
  triage_level text not null,
  advice text not null,
  next_actions text[] null,
  created_at timestamp with time zone null default now(),
  constraint symptom_checks_pkey primary key (id),
  constraint symptom_checks_pet_id_fkey foreign KEY (pet_id) references pets (id) on delete CASCADE,
  constraint symptom_checks_triage_level_check check (
    (
      triage_level = any (array['low'::text, 'medium'::text, 'high'::text])
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_symptom_checks_pet_id on public.symptom_checks using btree (pet_id) TABLESPACE pg_default;
create table public.user_devices (
  id uuid not null default extensions.uuid_generate_v4 (),
  user_id uuid not null,
  device_token text not null,
  device_type text not null,
  device_name text null,
  app_version text null,
  is_active boolean null default true,
  registered_at timestamp with time zone null default now(),
  last_used_at timestamp with time zone null default now(),
  constraint user_devices_pkey primary key (id),
  constraint user_devices_device_token_key unique (device_token),
  constraint user_devices_user_id_fkey foreign KEY (user_id) references profiles (id) on delete CASCADE,
  constraint user_devices_device_type_check check (
    (
      device_type = any (array['ios'::text, 'android'::text, 'web'::text])
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_user_devices_user_id on public.user_devices using btree (user_id) TABLESPACE pg_default;

create index IF not exists idx_user_devices_device_token on public.user_devices using btree (device_token) TABLESPACE pg_default;

create index IF not exists idx_user_devices_is_active on public.user_devices using btree (user_id, is_active) TABLESPACE pg_default;
