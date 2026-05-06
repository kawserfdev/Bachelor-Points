-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.bazar_schedules (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  mess_id uuid NOT NULL,
  user_id uuid NOT NULL,
  date date NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT bazar_schedules_pkey PRIMARY KEY (id),
  CONSTRAINT bazar_schedules_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.deposits (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  mess_id uuid NOT NULL,
  user_id uuid NOT NULL,
  received_by uuid,
  amount numeric NOT NULL CHECK (amount > 0::numeric),
  date date NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT deposits_pkey PRIMARY KEY (id),
  CONSTRAINT deposits_mess_id_fkey FOREIGN KEY (mess_id) REFERENCES public.messes(id),
  CONSTRAINT deposits_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT deposits_received_by_fkey FOREIGN KEY (received_by) REFERENCES auth.users(id)
);
CREATE TABLE public.expenses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  mess_id uuid NOT NULL,
  created_by uuid,
  amount numeric NOT NULL CHECK (amount > 0::numeric),
  category USER-DEFINED NOT NULL DEFAULT 'others'::expense_category,
  note text,
  date date NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT expenses_pkey PRIMARY KEY (id),
  CONSTRAINT expenses_mess_id_fkey FOREIGN KEY (mess_id) REFERENCES public.messes(id),
  CONSTRAINT expenses_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id)
);
CREATE TABLE public.meals (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  mess_id uuid NOT NULL,
  user_id uuid NOT NULL,
  date date NOT NULL,
  breakfast numeric DEFAULT 0.0 CHECK (breakfast >= 0::numeric),
  lunch numeric DEFAULT 0.0 CHECK (lunch >= 0::numeric),
  dinner numeric DEFAULT 0.0 CHECK (dinner >= 0::numeric),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT meals_pkey PRIMARY KEY (id),
  CONSTRAINT meals_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.members (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  mess_id uuid NOT NULL,
  user_id uuid NOT NULL,
  role USER-DEFINED NOT NULL DEFAULT 'viewer'::mess_role,
  joined_at timestamp with time zone DEFAULT now(),
  CONSTRAINT members_pkey PRIMARY KEY (id),
  CONSTRAINT members_mess_id_fkey FOREIGN KEY (mess_id) REFERENCES public.messes(id),
  CONSTRAINT members_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.mess_members (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  mess_id uuid NOT NULL,
  user_id uuid NOT NULL,
  role USER-DEFINED NOT NULL DEFAULT 'member'::user_role,
  joined_at timestamp with time zone DEFAULT now(),
  CONSTRAINT mess_members_pkey PRIMARY KEY (id),
  CONSTRAINT mess_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.mess_settings (
  mess_id uuid NOT NULL,
  meal_cutoff_time time without time zone NOT NULL DEFAULT '22:00:00'::time without time zone,
  currency text DEFAULT 'BDT'::text,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT mess_settings_pkey PRIMARY KEY (mess_id)
);
CREATE TABLE public.messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  mess_id uuid NOT NULL,
  user_id uuid,
  sender_name text NOT NULL,
  message text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT messages_pkey PRIMARY KEY (id),
  CONSTRAINT messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.messes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  invite_code character varying NOT NULL UNIQUE CHECK (char_length(invite_code::text) = 6),
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT messes_pkey PRIMARY KEY (id),
  CONSTRAINT messes_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id)
);
CREATE TABLE public.monthly_summary (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  mess_id uuid NOT NULL,
  user_id uuid NOT NULL,
  month date NOT NULL,
  total_meal numeric DEFAULT 0.0,
  total_cost numeric DEFAULT 0.0,
  total_deposit numeric DEFAULT 0.0,
  balance numeric DEFAULT 0.0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT monthly_summary_pkey PRIMARY KEY (id),
  CONSTRAINT monthly_summary_mess_id_fkey FOREIGN KEY (mess_id) REFERENCES public.messes(id),
  CONSTRAINT monthly_summary_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  body text NOT NULL,
  data jsonb,
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT notifications_pkey PRIMARY KEY (id),
  CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  full_name text NOT NULL,
  email text NOT NULL UNIQUE,
  phone_number text,
  fcm_token text,
  avatar_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  mess_id uuid NOT NULL,
  user_id uuid NOT NULL,
  type USER-DEFINED NOT NULL,
  details jsonb NOT NULL,
  status USER-DEFINED NOT NULL DEFAULT 'pending'::request_status,
  reviewed_by uuid,
  reviewed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT requests_pkey PRIMARY KEY (id),
  CONSTRAINT requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT requests_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.profiles(id)
);