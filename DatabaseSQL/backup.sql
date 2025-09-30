--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql;


ALTER SCHEMA graphql OWNER TO supabase_admin;

--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql_public;


ALTER SCHEMA graphql_public OWNER TO supabase_admin;

--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- Name: pgsodium; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA pgsodium;


ALTER SCHEMA pgsodium OWNER TO supabase_admin;

--
-- Name: pgsodium; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgsodium WITH SCHEMA pgsodium;


--
-- Name: EXTENSION pgsodium; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgsodium IS 'Pgsodium is a modern cryptography library for Postgres.';


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO supabase_admin;

--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA vault;


ALTER SCHEMA vault OWNER TO supabase_admin;

--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA extensions;


--
-- Name: EXTENSION pgjwt; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgjwt IS 'JSON Web Token API for Postgresql';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


ALTER TYPE auth.oauth_registration_type OWNER TO supabase_auth_admin;

--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE auth.one_time_token_type OWNER TO supabase_auth_admin;

--
-- Name: streaming_session_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.streaming_session_status AS ENUM (
    'active',
    'paused',
    'ended',
    'error',
    'disconnected'
);


ALTER TYPE public.streaming_session_status OWNER TO postgres;

--
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE realtime.action OWNER TO supabase_admin;

--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


ALTER TYPE realtime.equality_op OWNER TO supabase_admin;

--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


ALTER TYPE realtime.user_defined_filter OWNER TO supabase_admin;

--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


ALTER TYPE realtime.wal_column OWNER TO supabase_admin;

--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


ALTER TYPE realtime.wal_rls OWNER TO supabase_admin;

--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS'
);


ALTER TYPE storage.buckettype OWNER TO supabase_storage_admin;

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_cron_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


ALTER FUNCTION extensions.grant_pg_graphql_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_net_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_ddl_watch() OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_drop_watch() OWNER TO supabase_admin;

--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


ALTER FUNCTION extensions.set_graphql_placeholder() OWNER TO supabase_admin;

--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: supabase_admin
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
begin
    raise debug 'PgBouncer auth request: %', p_usename;

    return query
    select 
        rolname::text, 
        case when rolvaliduntil < now() 
            then null 
            else rolpassword::text 
        end 
    from pg_authid 
    where rolname=$1 and rolcanlogin;
end;
$_$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO supabase_admin;

--
-- Name: calculate_session_duration(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_session_duration() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.ended_at IS NOT NULL AND OLD.ended_at IS NULL THEN
        NEW.duration_minutes = EXTRACT(EPOCH FROM (NEW.ended_at - NEW.started_at)) / 60;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.calculate_session_duration() OWNER TO postgres;

--
-- Name: disconnect_rooms_on_session_end(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.disconnect_rooms_on_session_end() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if the session status changed to 'ended'
    IF OLD.status != 'ended' AND NEW.status = 'ended' THEN
        -- Update all streaming rooms for this session to disconnected
        UPDATE public.streaming_rooms 
        SET 
            connected = false,
            ended_at = now(),
            updated_at = now()
        WHERE session_id = NEW.id;
        
        -- Log the disconnection
        RAISE NOTICE 'Disconnected % streaming rooms for ended session %', 
            (SELECT COUNT(*) FROM public.streaming_rooms WHERE session_id = NEW.id),
            NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.disconnect_rooms_on_session_end() OWNER TO postgres;

--
-- Name: manual_disconnect_session_rooms(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.manual_disconnect_session_rooms(session_uuid uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    disconnected_count INTEGER;
BEGIN
    -- Update all streaming rooms for the specified session
    UPDATE public.streaming_rooms 
    SET 
        connected = false,
        ended_at = now(),
        updated_at = now()
    WHERE session_id = session_uuid
    AND connected = true;
    
    GET DIAGNOSTICS disconnected_count = ROW_COUNT;
    
    RETURN disconnected_count;
END;
$$;


ALTER FUNCTION public.manual_disconnect_session_rooms(session_uuid uuid) OWNER TO postgres;

--
-- Name: update_ambulance_camera_count(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_ambulance_camera_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.ambulances 
        SET camera_count = (SELECT COUNT(*) FROM public.cameras WHERE ambulance_id = NEW.ambulance_id)
        WHERE id = NEW.ambulance_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.ambulances 
        SET camera_count = (SELECT COUNT(*) FROM public.cameras WHERE ambulance_id = OLD.ambulance_id)
        WHERE id = OLD.ambulance_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$;


ALTER FUNCTION public.update_ambulance_camera_count() OWNER TO postgres;

--
-- Name: update_room_last_seen(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_room_last_seen() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.last_seen = now();
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_room_last_seen() OWNER TO postgres;

--
-- Name: update_session_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_session_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public.streaming_sessions 
    SET 
        status = CASE 
            WHEN EXISTS (
                SELECT 1 FROM public.streaming_rooms 
                WHERE session_id = COALESCE(NEW.session_id, OLD.session_id) 
                AND connected = true
            ) THEN 'active'::public.streaming_session_status
            ELSE 'disconnected'::public.streaming_session_status
        END,
        updated_at = now()
    WHERE id = COALESCE(NEW.session_id, OLD.session_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$;


ALTER FUNCTION public.update_session_status() OWNER TO postgres;

--
-- Name: update_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at() OWNER TO postgres;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


ALTER FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


ALTER FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) OWNER TO supabase_admin;

--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) OWNER TO supabase_admin;

--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


ALTER FUNCTION realtime."cast"(val text, type_ regtype) OWNER TO supabase_admin;

--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


ALTER FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) OWNER TO supabase_admin;

--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


ALTER FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) OWNER TO supabase_admin;

--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


ALTER FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION realtime.quote_wal2json(entity regclass) OWNER TO supabase_admin;

--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  BEGIN
    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (payload, event, topic, private, extension)
    VALUES (payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


ALTER FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) OWNER TO supabase_admin;

--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


ALTER FUNCTION realtime.subscription_check_filters() OWNER TO supabase_admin;

--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION realtime.to_regrole(role_name text) OWNER TO supabase_admin;

--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


ALTER FUNCTION realtime.topic() OWNER TO supabase_realtime_admin;

--
-- Name: add_prefixes(text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.add_prefixes(_bucket_id text, _name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    prefixes text[];
BEGIN
    prefixes := "storage"."get_prefixes"("_name");

    IF array_length(prefixes, 1) > 0 THEN
        INSERT INTO storage.prefixes (name, bucket_id)
        SELECT UNNEST(prefixes) as name, "_bucket_id" ON CONFLICT DO NOTHING;
    END IF;
END;
$$;


ALTER FUNCTION storage.add_prefixes(_bucket_id text, _name text) OWNER TO supabase_storage_admin;

--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) OWNER TO supabase_storage_admin;

--
-- Name: delete_leaf_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_rows_deleted integer;
BEGIN
    LOOP
        WITH candidates AS (
            SELECT DISTINCT
                t.bucket_id,
                unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        ),
        uniq AS (
             SELECT
                 bucket_id,
                 name,
                 storage.get_level(name) AS level
             FROM candidates
             WHERE name <> ''
             GROUP BY bucket_id, name
        ),
        leaf AS (
             SELECT
                 p.bucket_id,
                 p.name,
                 p.level
             FROM storage.prefixes AS p
                  JOIN uniq AS u
                       ON u.bucket_id = p.bucket_id
                           AND u.name = p.name
                           AND u.level = p.level
             WHERE NOT EXISTS (
                 SELECT 1
                 FROM storage.objects AS o
                 WHERE o.bucket_id = p.bucket_id
                   AND o.level = p.level + 1
                   AND o.name COLLATE "C" LIKE p.name || '/%'
             )
             AND NOT EXISTS (
                 SELECT 1
                 FROM storage.prefixes AS c
                 WHERE c.bucket_id = p.bucket_id
                   AND c.level = p.level + 1
                   AND c.name COLLATE "C" LIKE p.name || '/%'
             )
        )
        DELETE
        FROM storage.prefixes AS p
            USING leaf AS l
        WHERE p.bucket_id = l.bucket_id
          AND p.name = l.name
          AND p.level = l.level;

        GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
        EXIT WHEN v_rows_deleted = 0;
    END LOOP;
END;
$$;


ALTER FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) OWNER TO supabase_storage_admin;

--
-- Name: delete_prefix(text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_prefix(_bucket_id text, _name text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    -- Check if we can delete the prefix
    IF EXISTS(
        SELECT FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name") + 1
          AND "prefixes"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    )
    OR EXISTS(
        SELECT FROM "storage"."objects"
        WHERE "objects"."bucket_id" = "_bucket_id"
          AND "storage"."get_level"("objects"."name") = "storage"."get_level"("_name") + 1
          AND "objects"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    ) THEN
    -- There are sub-objects, skip deletion
    RETURN false;
    ELSE
        DELETE FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name")
          AND "prefixes"."name" = "_name";
        RETURN true;
    END IF;
END;
$$;


ALTER FUNCTION storage.delete_prefix(_bucket_id text, _name text) OWNER TO supabase_storage_admin;

--
-- Name: delete_prefix_hierarchy_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_prefix_hierarchy_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    prefix text;
BEGIN
    prefix := "storage"."get_prefix"(OLD."name");

    IF coalesce(prefix, '') != '' THEN
        PERFORM "storage"."delete_prefix"(OLD."bucket_id", prefix);
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION storage.delete_prefix_hierarchy_trigger() OWNER TO supabase_storage_admin;

--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


ALTER FUNCTION storage.enforce_bucket_name_length() OWNER TO supabase_storage_admin;

--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION storage.extension(name text) OWNER TO supabase_storage_admin;

--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION storage.filename(name text) OWNER TO supabase_storage_admin;

--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


ALTER FUNCTION storage.foldername(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_level(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_level(name text) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


ALTER FUNCTION storage.get_level(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_prefix(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_prefix(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


ALTER FUNCTION storage.get_prefix(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_prefixes(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_prefixes(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$$;


ALTER FUNCTION storage.get_prefixes(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION storage.get_size_by_bucket() OWNER TO supabase_storage_admin;

--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text) OWNER TO supabase_storage_admin;

--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


ALTER FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text) OWNER TO supabase_storage_admin;

--
-- Name: lock_top_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.lock_top_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket text;
    v_top text;
BEGIN
    FOR v_bucket, v_top IN
        SELECT DISTINCT t.bucket_id,
            split_part(t.name, '/', 1) AS top
        FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        WHERE t.name <> ''
        ORDER BY 1, 2
        LOOP
            PERFORM pg_advisory_xact_lock(hashtextextended(v_bucket || '/' || v_top, 0));
        END LOOP;
END;
$$;


ALTER FUNCTION storage.lock_top_prefixes(bucket_ids text[], names text[]) OWNER TO supabase_storage_admin;

--
-- Name: objects_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.objects_delete_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: objects_insert_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_insert_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    NEW.level := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_insert_prefix_trigger() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    -- NEW - OLD (destinations to create prefixes for)
    v_add_bucket_ids text[];
    v_add_names      text[];

    -- OLD - NEW (sources to prune)
    v_src_bucket_ids text[];
    v_src_names      text[];
BEGIN
    IF TG_OP <> 'UPDATE' THEN
        RETURN NULL;
    END IF;

    -- 1) Compute NEW−OLD (added paths) and OLD−NEW (moved-away paths)
    WITH added AS (
        SELECT n.bucket_id, n.name
        FROM new_rows n
        WHERE n.name <> '' AND position('/' in n.name) > 0
        EXCEPT
        SELECT o.bucket_id, o.name FROM old_rows o WHERE o.name <> ''
    ),
    moved AS (
         SELECT o.bucket_id, o.name
         FROM old_rows o
         WHERE o.name <> ''
         EXCEPT
         SELECT n.bucket_id, n.name FROM new_rows n WHERE n.name <> ''
    )
    SELECT
        -- arrays for ADDED (dest) in stable order
        COALESCE( (SELECT array_agg(a.bucket_id ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        COALESCE( (SELECT array_agg(a.name      ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        -- arrays for MOVED (src) in stable order
        COALESCE( (SELECT array_agg(m.bucket_id ORDER BY m.bucket_id, m.name) FROM moved m), '{}' ),
        COALESCE( (SELECT array_agg(m.name      ORDER BY m.bucket_id, m.name) FROM moved m), '{}' )
    INTO v_add_bucket_ids, v_add_names, v_src_bucket_ids, v_src_names;

    -- Nothing to do?
    IF (array_length(v_add_bucket_ids, 1) IS NULL) AND (array_length(v_src_bucket_ids, 1) IS NULL) THEN
        RETURN NULL;
    END IF;

    -- 2) Take per-(bucket, top) locks: ALL prefixes in consistent global order to prevent deadlocks
    DECLARE
        v_all_bucket_ids text[];
        v_all_names text[];
    BEGIN
        -- Combine source and destination arrays for consistent lock ordering
        v_all_bucket_ids := COALESCE(v_src_bucket_ids, '{}') || COALESCE(v_add_bucket_ids, '{}');
        v_all_names := COALESCE(v_src_names, '{}') || COALESCE(v_add_names, '{}');

        -- Single lock call ensures consistent global ordering across all transactions
        IF array_length(v_all_bucket_ids, 1) IS NOT NULL THEN
            PERFORM storage.lock_top_prefixes(v_all_bucket_ids, v_all_names);
        END IF;
    END;

    -- 3) Create destination prefixes (NEW−OLD) BEFORE pruning sources
    IF array_length(v_add_bucket_ids, 1) IS NOT NULL THEN
        WITH candidates AS (
            SELECT DISTINCT t.bucket_id, unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(v_add_bucket_ids, v_add_names) AS t(bucket_id, name)
            WHERE name <> ''
        )
        INSERT INTO storage.prefixes (bucket_id, name)
        SELECT c.bucket_id, c.name
        FROM candidates c
        ON CONFLICT DO NOTHING;
    END IF;

    -- 4) Prune source prefixes bottom-up for OLD−NEW
    IF array_length(v_src_bucket_ids, 1) IS NOT NULL THEN
        -- re-entrancy guard so DELETE on prefixes won't recurse
        IF current_setting('storage.gc.prefixes', true) <> '1' THEN
            PERFORM set_config('storage.gc.prefixes', '1', true);
        END IF;

        PERFORM storage.delete_leaf_prefixes(v_src_bucket_ids, v_src_names);
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.objects_update_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_level_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_level_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Set the new level
        NEW."level" := "storage"."get_level"(NEW."name");
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_update_level_trigger() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    old_prefixes TEXT[];
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Retrieve old prefixes
        old_prefixes := "storage"."get_prefixes"(OLD."name");

        -- Remove old prefixes that are only used by this object
        WITH all_prefixes as (
            SELECT unnest(old_prefixes) as prefix
        ),
        can_delete_prefixes as (
             SELECT prefix
             FROM all_prefixes
             WHERE NOT EXISTS (
                 SELECT 1 FROM "storage"."objects"
                 WHERE "bucket_id" = OLD."bucket_id"
                   AND "name" <> OLD."name"
                   AND "name" LIKE (prefix || '%')
             )
         )
        DELETE FROM "storage"."prefixes" WHERE name IN (SELECT prefix FROM can_delete_prefixes);

        -- Add new prefixes
        PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    END IF;
    -- Set the new level
    NEW."level" := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_update_prefix_trigger() OWNER TO supabase_storage_admin;

--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION storage.operation() OWNER TO supabase_storage_admin;

--
-- Name: prefixes_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.prefixes_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.prefixes_delete_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: prefixes_insert_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.prefixes_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.prefixes_insert_trigger() OWNER TO supabase_storage_admin;

--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql
    AS $$
declare
    can_bypass_rls BOOLEAN;
begin
    SELECT rolbypassrls
    INTO can_bypass_rls
    FROM pg_roles
    WHERE rolname = coalesce(nullif(current_setting('role', true), 'none'), current_user);

    IF can_bypass_rls THEN
        RETURN QUERY SELECT * FROM storage.search_v1_optimised(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    ELSE
        RETURN QUERY SELECT * FROM storage.search_legacy_v1(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    END IF;
end;
$$;


ALTER FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_legacy_v1(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_v1_optimised(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select (string_to_array(name, ''/''))[level] as name
           from storage.prefixes
             where lower(prefixes.name) like lower($2 || $3) || ''%''
               and bucket_id = $4
               and level = $1
           order by name ' || v_sort_order || '
     )
     (select name,
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[level] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where lower(objects.name) like lower($2 || $3) || ''%''
       and bucket_id = $4
       and level = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    sort_col text;
    sort_ord text;
    cursor_op text;
    cursor_expr text;
    sort_expr text;
BEGIN
    -- Validate sort_order
    sort_ord := lower(sort_order);
    IF sort_ord NOT IN ('asc', 'desc') THEN
        sort_ord := 'asc';
    END IF;

    -- Determine cursor comparison operator
    IF sort_ord = 'asc' THEN
        cursor_op := '>';
    ELSE
        cursor_op := '<';
    END IF;
    
    sort_col := lower(sort_column);
    -- Validate sort column  
    IF sort_col IN ('updated_at', 'created_at') THEN
        cursor_expr := format(
            '($5 = '''' OR ROW(date_trunc(''milliseconds'', %I), name COLLATE "C") %s ROW(COALESCE(NULLIF($6, '''')::timestamptz, ''epoch''::timestamptz), $5))',
            sort_col, cursor_op
        );
        sort_expr := format(
            'COALESCE(date_trunc(''milliseconds'', %I), ''epoch''::timestamptz) %s, name COLLATE "C" %s',
            sort_col, sort_ord, sort_ord
        );
    ELSE
        cursor_expr := format('($5 = '''' OR name COLLATE "C" %s $5)', cursor_op);
        sort_expr := format('name COLLATE "C" %s', sort_ord);
    END IF;

    RETURN QUERY EXECUTE format(
        $sql$
        SELECT * FROM (
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    NULL::uuid AS id,
                    updated_at,
                    created_at,
                    NULL::timestamptz AS last_accessed_at,
                    NULL::jsonb AS metadata
                FROM storage.prefixes
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
            UNION ALL
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    id,
                    updated_at,
                    created_at,
                    last_accessed_at,
                    metadata
                FROM storage.objects
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
        ) obj
        ORDER BY %s
        LIMIT $3
        $sql$,
        cursor_expr,    -- prefixes WHERE
        sort_expr,      -- prefixes ORDER BY
        cursor_expr,    -- objects WHERE
        sort_expr,      -- objects ORDER BY
        sort_expr       -- final ORDER BY
    )
    USING prefix, bucket_name, limits, levels, start_after, sort_column_after;
END;
$_$;


ALTER FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer, levels integer, start_after text, sort_order text, sort_column text, sort_column_after text) OWNER TO supabase_storage_admin;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION storage.update_updated_at_column() OWNER TO supabase_storage_admin;

--
-- Name: secrets_encrypt_secret_secret(); Type: FUNCTION; Schema: vault; Owner: supabase_admin
--

CREATE FUNCTION vault.secrets_encrypt_secret_secret() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
		BEGIN
		        new.secret = CASE WHEN new.secret IS NULL THEN NULL ELSE
			CASE WHEN new.key_id IS NULL THEN NULL ELSE pg_catalog.encode(
			  pgsodium.crypto_aead_det_encrypt(
				pg_catalog.convert_to(new.secret, 'utf8'),
				pg_catalog.convert_to((new.id::text || new.description::text || new.created_at::text || new.updated_at::text)::text, 'utf8'),
				new.key_id::uuid,
				new.nonce
			  ),
				'base64') END END;
		RETURN new;
		END;
		$$;


ALTER FUNCTION vault.secrets_encrypt_secret_secret() OWNER TO supabase_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_id text NOT NULL,
    client_secret_hash text NOT NULL,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048))
);


ALTER TABLE auth.oauth_clients OWNER TO supabase_auth_admin;

--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: ai_detections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ai_detections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid NOT NULL,
    camera_id uuid NOT NULL,
    room_id uuid,
    detection_type character varying(50) NOT NULL,
    confidence_score numeric(5,4),
    detection_data jsonb NOT NULL,
    detected_patient_id character varying(100),
    patient_biometrics jsonb,
    frame_timestamp timestamp with time zone NOT NULL,
    sequence_number integer,
    model_used character varying(50),
    processing_time_ms integer,
    processed_on character varying(20) DEFAULT 'edge'::character varying,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT ai_detections_processed_on_check CHECK (((processed_on)::text = ANY ((ARRAY['edge'::character varying, 'cloud'::character varying])::text[])))
);


ALTER TABLE public.ai_detections OWNER TO postgres;

--
-- Name: TABLE ai_detections; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.ai_detections IS 'AI detection results from camera feeds with patient identification';


--
-- Name: COLUMN ai_detections.detected_patient_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.ai_detections.detected_patient_id IS 'AI-generated patient identifier from lenses/facial recognition';


--
-- Name: ambulance_streaming_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ambulance_streaming_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ambulance_id uuid NOT NULL,
    session_name character varying(100),
    session_type character varying(50) DEFAULT 'emergency'::character varying,
    is_active boolean DEFAULT true,
    incident_id character varying(100),
    priority_level integer DEFAULT 3,
    call_type character varying(100),
    origin_location jsonb,
    destination_location jsonb,
    route_data jsonb,
    detected_patients jsonb DEFAULT '[]'::jsonb,
    patient_count integer DEFAULT 0,
    started_at timestamp with time zone DEFAULT now(),
    ended_at timestamp with time zone,
    duration_minutes integer,
    avg_connection_quality numeric(5,2),
    total_cameras_used integer DEFAULT 0,
    data_transferred_mb numeric(10,2),
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    CONSTRAINT ambulance_streaming_sessions_priority_level_check CHECK (((priority_level >= 1) AND (priority_level <= 5))),
    CONSTRAINT ambulance_streaming_sessions_session_type_check CHECK (((session_type)::text = ANY ((ARRAY['emergency'::character varying, 'training'::character varying, 'maintenance'::character varying, 'monitoring'::character varying])::text[])))
);


ALTER TABLE public.ambulance_streaming_sessions OWNER TO postgres;

--
-- Name: TABLE ambulance_streaming_sessions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.ambulance_streaming_sessions IS 'Streaming sessions per ambulance (replaces patient-based sessions)';


--
-- Name: COLUMN ambulance_streaming_sessions.detected_patients; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.ambulance_streaming_sessions.detected_patients IS 'Array of AI-identified patients in the ambulance';


--
-- Name: ambulances; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ambulances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ambulance_number character varying(50) NOT NULL,
    license_plate character varying(20) NOT NULL,
    vehicle_model character varying(100),
    manufacturer character varying(50),
    year_manufactured integer,
    status character varying(20) DEFAULT 'active'::character varying,
    current_location jsonb,
    assigned_hospital_id uuid,
    assigned_team jsonb,
    equipment_list jsonb,
    camera_count integer DEFAULT 0,
    max_camera_capacity integer DEFAULT 8,
    mileage integer,
    last_maintenance date,
    next_maintenance date,
    insurance_info jsonb,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    CONSTRAINT ambulance_year_valid CHECK (((year_manufactured >= 1990) AND ((year_manufactured)::numeric <= (EXTRACT(year FROM now()) + (2)::numeric)))),
    CONSTRAINT ambulances_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'maintenance'::character varying, 'retired'::character varying])::text[]))),
    CONSTRAINT camera_capacity_valid CHECK (((camera_count >= 0) AND (camera_count <= max_camera_capacity)))
);


ALTER TABLE public.ambulances OWNER TO postgres;

--
-- Name: TABLE ambulances; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.ambulances IS 'Ambulance vehicles with equipment and camera installations';


--
-- Name: COLUMN ambulances.ambulance_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.ambulances.ambulance_number IS 'Unique ambulance identifier (e.g., AMB-001)';


--
-- Name: camera_streaming_rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.camera_streaming_rooms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid NOT NULL,
    camera_id uuid NOT NULL,
    room_id character varying(255) NOT NULL,
    device_name character varying(100) NOT NULL,
    connected boolean DEFAULT true,
    connection_started_at timestamp with time zone DEFAULT now(),
    connection_ended_at timestamp with time zone,
    last_seen timestamp with time zone DEFAULT now(),
    current_fps integer,
    current_bitrate integer,
    packet_loss_rate numeric(5,2),
    latency_ms integer,
    ai_processing_active boolean DEFAULT true,
    detections_count integer DEFAULT 0,
    last_detection_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.camera_streaming_rooms OWNER TO postgres;

--
-- Name: TABLE camera_streaming_rooms; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.camera_streaming_rooms IS 'WebRTC streaming rooms for individual cameras';


--
-- Name: cameras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cameras (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    camera_id character varying(100) NOT NULL,
    ambulance_id uuid NOT NULL,
    camera_name character varying(100) NOT NULL,
    camera_type character varying(50) DEFAULT 'surveillance'::character varying,
    position_in_ambulance character varying(50),
    device_model character varying(100),
    resolution character varying(20) DEFAULT '1920x1080'::character varying,
    max_fps integer DEFAULT 30,
    has_night_vision boolean DEFAULT false,
    has_audio boolean DEFAULT true,
    mac_address character varying(17),
    ip_address inet,
    streaming_port integer DEFAULT 8000,
    rtc_config jsonb,
    status character varying(20) DEFAULT 'active'::character varying,
    last_seen timestamp with time zone,
    connection_quality integer,
    ai_enabled boolean DEFAULT true,
    detection_types jsonb DEFAULT '["pose", "movement", "activity"]'::jsonb,
    processing_mode character varying(20) DEFAULT 'edge'::character varying,
    installation_date date,
    warranty_expires date,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT cameras_camera_type_check CHECK (((camera_type)::text = ANY ((ARRAY['surveillance'::character varying, 'medical'::character varying, 'dashboard'::character varying, 'exterior'::character varying])::text[]))),
    CONSTRAINT cameras_connection_quality_check CHECK (((connection_quality >= 0) AND (connection_quality <= 100))),
    CONSTRAINT cameras_processing_mode_check CHECK (((processing_mode)::text = ANY ((ARRAY['edge'::character varying, 'cloud'::character varying, 'hybrid'::character varying])::text[]))),
    CONSTRAINT cameras_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'offline'::character varying, 'maintenance'::character varying, 'error'::character varying])::text[])))
);


ALTER TABLE public.cameras OWNER TO postgres;

--
-- Name: TABLE cameras; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.cameras IS 'Static cameras installed in ambulances for streaming and AI detection';


--
-- Name: COLUMN cameras.camera_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.cameras.camera_id IS 'Static camera identifier (e.g., AMB-001-CAM-01, RPi-ABC123)';


--
-- Name: ambulance_streaming_status; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.ambulance_streaming_status AS
 SELECT a.id AS ambulance_id,
    a.ambulance_number,
    a.license_plate,
    a.status AS ambulance_status,
    s.id AS session_id,
    s.session_name,
    s.is_active,
    s.started_at AS session_started,
    s.incident_id,
    count(c.id) AS total_cameras,
    count(
        CASE
            WHEN ((c.status)::text = 'active'::text) THEN 1
            ELSE NULL::integer
        END) AS active_cameras,
    count(cr.id) AS connected_rooms,
    count(
        CASE
            WHEN (cr.connected = true) THEN 1
            ELSE NULL::integer
        END) AS live_rooms,
    COALESCE(jsonb_agg(
        CASE
            WHEN (cr.connected = true) THEN jsonb_build_object('room_id', cr.room_id, 'camera_name', c.camera_name, 'device_name', cr.device_name, 'last_seen', cr.last_seen, 'fps', cr.current_fps, 'ai_active', cr.ai_processing_active)
            ELSE NULL::jsonb
        END) FILTER (WHERE (cr.connected = true)), '[]'::jsonb) AS active_streams
   FROM (((public.ambulances a
     LEFT JOIN public.ambulance_streaming_sessions s ON (((a.id = s.ambulance_id) AND (s.is_active = true))))
     LEFT JOIN public.cameras c ON ((a.id = c.ambulance_id)))
     LEFT JOIN public.camera_streaming_rooms cr ON (((s.id = cr.session_id) AND (c.id = cr.camera_id))))
  GROUP BY a.id, a.ambulance_number, a.license_plate, a.status, s.id, s.session_name, s.is_active, s.started_at, s.incident_id;


ALTER VIEW public.ambulance_streaming_status OWNER TO postgres;

--
-- Name: camera_health_status; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.camera_health_status AS
 SELECT c.id,
    c.camera_id,
    c.camera_name,
    c.ambulance_id,
    a.ambulance_number,
    c.status,
    c.last_seen,
    c.connection_quality,
    cr.connected AS currently_streaming,
    cr.current_fps,
    cr.latency_ms,
    cr.ai_processing_active,
        CASE
            WHEN (c.last_seen > (now() - '00:05:00'::interval)) THEN 'online'::text
            WHEN (c.last_seen > (now() - '00:30:00'::interval)) THEN 'warning'::text
            ELSE 'offline'::text
        END AS health_status
   FROM ((public.cameras c
     JOIN public.ambulances a ON ((c.ambulance_id = a.id)))
     LEFT JOIN public.camera_streaming_rooms cr ON (((c.id = cr.camera_id) AND (cr.connected = true))));


ALTER VIEW public.camera_health_status OWNER TO postgres;

--
-- Name: doctor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doctor (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    first_name text NOT NULL,
    middle_name text,
    last_name text NOT NULL,
    specialization text NOT NULL,
    email text NOT NULL,
    primary_phone text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.doctor OWNER TO postgres;

--
-- Name: medical_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medical_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    patient_id uuid NOT NULL,
    doctor_id uuid NOT NULL,
    diagnosis text,
    note text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.medical_history OWNER TO postgres;

--
-- Name: note; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.note (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    content text NOT NULL,
    patient_id uuid NOT NULL,
    video_id uuid,
    author uuid NOT NULL,
    timestamp_seconds numeric,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.note OWNER TO postgres;

--
-- Name: patient_event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_event (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    type text NOT NULL,
    confidence smallint DEFAULT '0'::smallint NOT NULL,
    validation_status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    video_id uuid,
    "timestamp" numeric
);


ALTER TABLE public.patient_event OWNER TO postgres;

--
-- Name: patients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patients (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    first_name text NOT NULL,
    middle_name text,
    last_name text NOT NULL,
    dob date NOT NULL,
    primary_phone text NOT NULL,
    address text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.patients OWNER TO postgres;

--
-- Name: video; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.video (
    patient_id uuid NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    file_path text NOT NULL,
    duration bigint DEFAULT '0'::bigint NOT NULL
);


ALTER TABLE public.video OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


ALTER TABLE realtime.messages OWNER TO supabase_realtime_admin;

--
-- Name: messages_2025_09_26; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_09_26 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_09_26 OWNER TO supabase_admin;

--
-- Name: messages_2025_09_27; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_09_27 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_09_27 OWNER TO supabase_admin;

--
-- Name: messages_2025_09_28; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_09_28 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_09_28 OWNER TO supabase_admin;

--
-- Name: messages_2025_09_29; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_09_29 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_09_29 OWNER TO supabase_admin;

--
-- Name: messages_2025_09_30; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_09_30 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_09_30 OWNER TO supabase_admin;

--
-- Name: messages_2025_10_01; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_10_01 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_10_01 OWNER TO supabase_admin;

--
-- Name: messages_2025_10_02; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_10_02 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_10_02 OWNER TO supabase_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;

--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE realtime.subscription OWNER TO supabase_admin;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;

--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets_analytics (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.buckets_analytics OWNER TO supabase_storage_admin;

--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE storage.migrations OWNER TO supabase_storage_admin;

--
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb,
    level integer
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: prefixes; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.prefixes (
    bucket_id text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    level integer GENERATED ALWAYS AS (storage.get_level(name)) STORED NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE storage.prefixes OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


ALTER TABLE storage.s3_multipart_uploads OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.s3_multipart_uploads_parts OWNER TO supabase_storage_admin;

--
-- Name: messages_2025_09_26; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_09_26 FOR VALUES FROM ('2025-09-26 00:00:00') TO ('2025-09-27 00:00:00');


--
-- Name: messages_2025_09_27; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_09_27 FOR VALUES FROM ('2025-09-27 00:00:00') TO ('2025-09-28 00:00:00');


--
-- Name: messages_2025_09_28; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_09_28 FOR VALUES FROM ('2025-09-28 00:00:00') TO ('2025-09-29 00:00:00');


--
-- Name: messages_2025_09_29; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_09_29 FOR VALUES FROM ('2025-09-29 00:00:00') TO ('2025-09-30 00:00:00');


--
-- Name: messages_2025_09_30; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_09_30 FOR VALUES FROM ('2025-09-30 00:00:00') TO ('2025-10-01 00:00:00');


--
-- Name: messages_2025_10_01; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_10_01 FOR VALUES FROM ('2025-10-01 00:00:00') TO ('2025-10-02 00:00:00');


--
-- Name: messages_2025_10_02; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_10_02 FOR VALUES FROM ('2025-10-02 00:00:00') TO ('2025-10-03 00:00:00');


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
00000000-0000-0000-0000-000000000000	7ff787ba-cceb-43d8-968d-9d970ce9e5bd	{"action":"user_confirmation_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-03-22 07:51:10.828566+00	
00000000-0000-0000-0000-000000000000	24380a8d-265d-49c4-a43a-69e4cbf52248	{"action":"user_signedup","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"team"}	2025-03-22 07:52:49.135747+00	
00000000-0000-0000-0000-000000000000	51d42e61-b487-4108-9036-dc0428b8fdaf	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-22 10:43:21.132754+00	
00000000-0000-0000-0000-000000000000	3f3f2ced-2093-4f24-a25d-e1a9611890da	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-22 10:44:15.005519+00	
00000000-0000-0000-0000-000000000000	6ae3187f-715b-42a1-8b1b-8ef1eaf69d46	{"action":"logout","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-03-22 10:45:33.377701+00	
00000000-0000-0000-0000-000000000000	18e7ce54-a5d8-4ed8-adc7-a7db913b678f	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-22 10:50:53.030803+00	
00000000-0000-0000-0000-000000000000	0b3a7c77-c73f-4c67-b361-12811d8390ec	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-22 10:54:09.676828+00	
00000000-0000-0000-0000-000000000000	d148d752-72c0-4d26-bc88-a88f5daecf17	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-22 10:56:17.408579+00	
00000000-0000-0000-0000-000000000000	64799f7e-04e6-4fae-bbfd-8b2c1c99e26b	{"action":"logout","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-03-22 10:56:38.649189+00	
00000000-0000-0000-0000-000000000000	fa98f9fb-0049-4142-825c-e3808ae7c303	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-22 11:05:20.861641+00	
00000000-0000-0000-0000-000000000000	cbd9cbdd-ac96-4025-9d7c-92825a6da60c	{"action":"logout","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-03-22 11:06:54.723075+00	
00000000-0000-0000-0000-000000000000	cf24a399-8cff-4799-905f-3ecb7fffa7d4	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-22 11:07:41.849917+00	
00000000-0000-0000-0000-000000000000	f57b3421-c417-4441-9e41-b54c2498b17c	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 12:07:33.246299+00	
00000000-0000-0000-0000-000000000000	3930d3a2-59fa-43ce-8940-d7fb05d16e39	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 12:07:33.252625+00	
00000000-0000-0000-0000-000000000000	daaa0f05-3606-4ef9-bb05-ad6615b804e5	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 12:07:33.354043+00	
00000000-0000-0000-0000-000000000000	8bca924b-0ffb-4c2f-becf-f20e04e9e130	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 12:07:33.354676+00	
00000000-0000-0000-0000-000000000000	e146580a-4033-42a1-b910-7da5b3c6f52f	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 13:07:24.773978+00	
00000000-0000-0000-0000-000000000000	23cf2d08-03a1-4947-af0b-cb112388cf82	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 13:07:24.781438+00	
00000000-0000-0000-0000-000000000000	42890fa0-9761-4d8b-8245-a324c4dba3b7	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 13:07:24.880421+00	
00000000-0000-0000-0000-000000000000	0be12ffe-5f3f-4594-9dd5-96f2585a485e	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 13:07:24.881817+00	
00000000-0000-0000-0000-000000000000	632744ae-7ea0-46fc-b337-584b9457f554	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 14:07:16.377452+00	
00000000-0000-0000-0000-000000000000	0184e6d1-e7d4-4f59-a2cf-b3c59fbec2aa	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 14:07:16.382487+00	
00000000-0000-0000-0000-000000000000	edcdee1d-aa1d-42e4-89f4-eefd1c83f9e2	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 14:07:16.483752+00	
00000000-0000-0000-0000-000000000000	f017dbc3-f3e2-4654-8feb-c50f61df6772	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 14:07:16.484415+00	
00000000-0000-0000-0000-000000000000	721603f2-54c4-4637-8474-45a147b65e0f	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 15:07:08.893085+00	
00000000-0000-0000-0000-000000000000	8902fbe7-fdd4-47fa-91e4-15509ae95be7	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 15:07:08.895021+00	
00000000-0000-0000-0000-000000000000	84494eac-f993-4799-870f-e296da21ee24	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 15:07:09.000841+00	
00000000-0000-0000-0000-000000000000	734fd765-a75c-438b-9f8f-4011b45d62d2	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 15:07:09.001515+00	
00000000-0000-0000-0000-000000000000	0066fe1a-7f16-4c65-a2fa-903dd6dcc4d9	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 16:07:01.395619+00	
00000000-0000-0000-0000-000000000000	6a304565-7dcd-4347-916e-c425fabddf5f	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 16:07:01.397896+00	
00000000-0000-0000-0000-000000000000	9cd2962d-05b9-4f3e-9cdf-84ec093e8603	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 16:07:01.460486+00	
00000000-0000-0000-0000-000000000000	8fe3d40b-1f71-4bb3-932d-7d5259fc1169	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 16:07:01.461139+00	
00000000-0000-0000-0000-000000000000	64e7fcd6-90b6-430b-bdf5-5300822b2143	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 17:06:53.851039+00	
00000000-0000-0000-0000-000000000000	4e1171c7-6f22-4bd1-9c1c-425680352a26	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 17:06:53.855058+00	
00000000-0000-0000-0000-000000000000	30c9a2ff-2716-4f7f-951e-b0facb650a03	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 17:06:53.948634+00	
00000000-0000-0000-0000-000000000000	ce2951d0-81f0-418b-8d26-fb18908fe50a	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 17:06:53.94926+00	
00000000-0000-0000-0000-000000000000	713b03bd-5e60-42ca-b145-9ae7f74545cc	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 18:06:45.516842+00	
00000000-0000-0000-0000-000000000000	5a2226be-d646-4f38-a201-9924e1a6807a	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 18:06:45.518362+00	
00000000-0000-0000-0000-000000000000	95c44aa1-7fed-4a63-9cb9-40f56bf51098	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 18:06:45.596412+00	
00000000-0000-0000-0000-000000000000	472cc9ac-d9da-4ab4-83ab-c0b4124b98ca	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 18:06:45.59703+00	
00000000-0000-0000-0000-000000000000	5569e570-ebd6-4082-95fc-f382aa3dc8cd	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 19:06:35.029411+00	
00000000-0000-0000-0000-000000000000	74a215c8-5c30-4c4f-82c1-ced923705bad	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 19:06:35.033598+00	
00000000-0000-0000-0000-000000000000	6d4972cb-fed3-4680-ae06-1a9ad7579ffa	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 19:06:35.106986+00	
00000000-0000-0000-0000-000000000000	113c75ca-a683-4f82-b202-0846562f7d00	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 19:06:35.107592+00	
00000000-0000-0000-0000-000000000000	1b29fe6c-73d8-4c4e-9e2e-f9afbb218f1a	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 20:06:25.52207+00	
00000000-0000-0000-0000-000000000000	350ace0c-316a-4ade-a9bf-10d5ce38a3a4	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 20:06:25.52412+00	
00000000-0000-0000-0000-000000000000	6b6070f1-0d4d-45f6-bd67-05851905ddff	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 20:06:25.623083+00	
00000000-0000-0000-0000-000000000000	63adee4c-bac1-4525-a7eb-30f939158aac	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 20:06:25.623723+00	
00000000-0000-0000-0000-000000000000	beb5620f-12da-4dd0-b198-97fcd66d95e3	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 21:06:16.063429+00	
00000000-0000-0000-0000-000000000000	e76bf210-1f7a-4b2f-8bbb-650a470e7cc1	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 21:06:16.064841+00	
00000000-0000-0000-0000-000000000000	03f77bef-f520-4638-88bc-066bab171746	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 21:06:16.141363+00	
00000000-0000-0000-0000-000000000000	1396b99d-7db0-42f3-9cf3-b9294507204f	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 21:06:16.142949+00	
00000000-0000-0000-0000-000000000000	7cb7fc62-0aee-42c2-a24f-73ca3ade37eb	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 22:06:06.530606+00	
00000000-0000-0000-0000-000000000000	4defd5ba-cda5-4f28-9725-c2b616dd2f20	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 22:06:06.532665+00	
00000000-0000-0000-0000-000000000000	4aeb56e8-1ce3-48c6-b58a-4370574cf058	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 22:06:06.597857+00	
00000000-0000-0000-0000-000000000000	aeca22da-9155-4432-a84c-1348c4d684cd	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-22 22:06:06.598521+00	
00000000-0000-0000-0000-000000000000	b4dc7a27-8987-4fe1-9bb4-667a9ef9952c	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"mikefeschenko@yahoo.com","user_id":"bf250d15-2188-413b-b954-120a31ca5840","user_phone":""}}	2025-03-26 18:53:16.034569+00	
00000000-0000-0000-0000-000000000000	cad22832-cdbe-46dc-a8f9-e3ec974f088e	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-26 19:24:16.242069+00	
00000000-0000-0000-0000-000000000000	892d13a3-5c0f-4aa8-b90c-3120a36d6d26	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-26 19:27:20.79989+00	
00000000-0000-0000-0000-000000000000	71ad9dc8-d222-4e99-8339-dfdfc203cdf5	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-26 20:08:18.226091+00	
00000000-0000-0000-0000-000000000000	36ed0219-99fa-44e8-8cc0-e9ef6606065f	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-26 20:10:28.486648+00	
00000000-0000-0000-0000-000000000000	179442fb-a61b-45c5-95a4-c302eb4341c8	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-26 20:17:08.718833+00	
00000000-0000-0000-0000-000000000000	a9575c68-92e6-489d-9d87-90215cda0fb7	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-26 20:19:03.113109+00	
00000000-0000-0000-0000-000000000000	560c2351-a408-400e-8cbc-1b5530313754	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-26 20:20:45.35821+00	
00000000-0000-0000-0000-000000000000	4e271010-559f-48f5-8d49-2e5a0a5b947a	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-26 20:21:44.535506+00	
00000000-0000-0000-0000-000000000000	ead2bf6a-27c1-4401-a313-811cee45b725	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-26 20:23:34.685754+00	
00000000-0000-0000-0000-000000000000	18db650e-cdbd-4d40-83f9-dbd0b506f833	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-26 20:25:34.478382+00	
00000000-0000-0000-0000-000000000000	098e9751-a0de-40fb-b3b2-2c73b6900d98	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-26 20:31:03.204524+00	
00000000-0000-0000-0000-000000000000	098bd951-605c-4993-b8fb-8ca325d312aa	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-26 20:31:11.335617+00	
00000000-0000-0000-0000-000000000000	e254471f-eef1-46e2-a431-bfbbe0b845a5	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-26 20:50:23.394439+00	
00000000-0000-0000-0000-000000000000	8e66c846-51a9-4266-a4a1-1dbbfb8611b0	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-26 21:10:15.54201+00	
00000000-0000-0000-0000-000000000000	27dd5abf-dc71-4695-9afe-7add38532515	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-03-26 21:31:01.645932+00	
00000000-0000-0000-0000-000000000000	b65a2680-d503-436a-a143-6cef10e09359	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-03-26 21:31:01.648613+00	
00000000-0000-0000-0000-000000000000	38b8a0cc-e28d-43dc-9173-d5ffc3c3393e	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-30 00:36:20.728818+00	
00000000-0000-0000-0000-000000000000	0cdb0d97-b958-499c-92dd-665ae69e9566	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-30 00:37:59.510707+00	
00000000-0000-0000-0000-000000000000	99b5bbb9-6cac-4c9d-9612-cb63e16956db	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-30 17:48:23.855675+00	
00000000-0000-0000-0000-000000000000	fcbf2ab6-6c11-493f-accd-75a304882a26	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-30 21:47:55.765731+00	
00000000-0000-0000-0000-000000000000	48f5c4b6-6d93-4462-a8fd-bd0e220ee1f8	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-30 22:10:12.710598+00	
00000000-0000-0000-0000-000000000000	565a78d1-4f0b-48ab-8f85-6ae8a99f9b96	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-30 22:11:51.7003+00	
00000000-0000-0000-0000-000000000000	9d6d5d3c-8a0a-4996-8770-1d0c3d9bc79a	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-30 22:14:23.69884+00	
00000000-0000-0000-0000-000000000000	07a9f366-22a8-464d-9a88-92b2315fcde2	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"phernandez4@csus.edu","user_id":"0764189f-5885-420f-994a-cbf994a444d5","user_phone":""}}	2025-03-31 03:09:35.293244+00	
00000000-0000-0000-0000-000000000000	96d2282f-c875-4628-beef-e3a7d0e6cc53	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"phernandez4@csus.edu","user_id":"0764189f-5885-420f-994a-cbf994a444d5","user_phone":""}}	2025-03-31 03:10:34.756167+00	
00000000-0000-0000-0000-000000000000	1478a806-9d1b-4630-aeac-ca608ece29ea	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"phernandez4@csus.edu","user_id":"f8140ab0-94b5-4318-aacb-6d4b6800fea9","user_phone":""}}	2025-03-31 03:11:00.143735+00	
00000000-0000-0000-0000-000000000000	ad96888a-3150-45af-8b31-df9a20ee059a	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-31 05:22:34.217801+00	
00000000-0000-0000-0000-000000000000	dc5b4c5b-cef2-453c-af10-92a43a536676	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-31 05:38:27.524305+00	
00000000-0000-0000-0000-000000000000	2a63f6a7-e688-493e-909b-f1062a86c402	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-31 07:53:28.414591+00	
00000000-0000-0000-0000-000000000000	96cb0ffc-b76c-4c3e-ab89-e859c9dca7ce	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-31 08:00:40.657835+00	
00000000-0000-0000-0000-000000000000	025d58e0-fc1d-4ded-9e1c-80eb9f1236cf	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-03-31 08:21:14.90607+00	
00000000-0000-0000-0000-000000000000	d49b7d85-788c-420f-883f-fda044a658ac	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-31 09:21:05.335473+00	
00000000-0000-0000-0000-000000000000	5af53f2a-aa9e-4e44-bc7b-d92ca7fc5490	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-31 09:21:05.340443+00	
00000000-0000-0000-0000-000000000000	f1c1857d-d6a5-442a-814d-e9b7b58a6ceb	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-31 09:21:05.413071+00	
00000000-0000-0000-0000-000000000000	1ec6ae2c-7fa6-4068-bd84-cc819a0e88fb	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-31 09:21:05.41371+00	
00000000-0000-0000-0000-000000000000	de19798b-0fe4-4bf0-9b38-224feebb3278	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-31 10:20:55.837708+00	
00000000-0000-0000-0000-000000000000	62d22c10-0dc1-4368-82ab-a24e9ef330d2	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-31 10:20:55.839673+00	
00000000-0000-0000-0000-000000000000	cee3d19f-e5d2-4b48-a8da-1601f4b81b74	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-31 10:20:55.905631+00	
00000000-0000-0000-0000-000000000000	593279e5-1bcf-461e-afd7-2d1ee8bab7b4	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-03-31 10:20:55.909343+00	
00000000-0000-0000-0000-000000000000	25885530-66fc-423e-80ab-4b4788090dcf	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-01 21:43:47.536609+00	
00000000-0000-0000-0000-000000000000	07a8f783-f5ed-4c4b-94a1-087bd5da3864	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-01 21:44:34.188186+00	
00000000-0000-0000-0000-000000000000	8a27aca0-b906-4078-92b2-5ffa128fbb03	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-01 21:47:06.657247+00	
00000000-0000-0000-0000-000000000000	ca8289b3-6509-49b3-a5d0-89734cca7a25	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-01 21:48:52.679831+00	
00000000-0000-0000-0000-000000000000	6d008e44-cd7a-43ba-bc2b-5846d58ce00f	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-01 22:06:03.512563+00	
00000000-0000-0000-0000-000000000000	a49bc540-5c2c-4b2e-8af9-39b6bf33a849	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-10 00:03:15.031168+00	
00000000-0000-0000-0000-000000000000	7a635284-d347-42fd-abe5-98e936cb0ef1	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-10 00:03:25.807103+00	
00000000-0000-0000-0000-000000000000	42882dff-6c45-4fc9-8abc-c8c4bac514ff	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 01:03:03.376526+00	
00000000-0000-0000-0000-000000000000	1473a15e-7503-40f8-a2cd-d1ddd1baa350	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 01:03:03.387706+00	
00000000-0000-0000-0000-000000000000	0069d68e-1cf9-44d6-81eb-c20b137d43a0	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 01:03:03.458405+00	
00000000-0000-0000-0000-000000000000	3b06676d-4ff4-481d-b9c2-62246c76bd99	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 01:03:03.459007+00	
00000000-0000-0000-0000-000000000000	550d6ea3-765a-4f96-b041-1631b69c4739	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 01:03:13.960649+00	
00000000-0000-0000-0000-000000000000	782a1c56-2621-4128-b8c5-61ffb0a34d73	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 01:03:13.961281+00	
00000000-0000-0000-0000-000000000000	af6f947c-f1ad-40ad-85a6-79a3496e0058	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 01:03:14.063649+00	
00000000-0000-0000-0000-000000000000	5cbfe9f3-7ec6-474e-b3ce-14688a85b829	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 01:03:14.064287+00	
00000000-0000-0000-0000-000000000000	d6b2e335-df65-4a01-931c-6de9b41169c1	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-10 01:03:17.931803+00	
00000000-0000-0000-0000-000000000000	ec49931d-46b4-49b9-a178-588e87ee28e5	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 02:02:51.746017+00	
00000000-0000-0000-0000-000000000000	65671536-bd5b-4235-9edc-543102c79b1e	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 02:02:51.748152+00	
00000000-0000-0000-0000-000000000000	8e184fae-0152-4e0c-a44d-86f64a2fb743	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 02:02:51.840518+00	
00000000-0000-0000-0000-000000000000	0105ba1f-ced1-443e-b820-baaa536f61f9	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 02:02:51.842344+00	
00000000-0000-0000-0000-000000000000	827b7751-0ee7-4a25-88ff-bd43cb693d5b	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 02:03:03.210244+00	
00000000-0000-0000-0000-000000000000	1717a023-a6ed-41ce-a484-20afd709bb30	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 02:03:03.210917+00	
00000000-0000-0000-0000-000000000000	81c4042c-7ae8-4325-bc5f-e0b566248bd4	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 02:03:03.313076+00	
00000000-0000-0000-0000-000000000000	502f9d47-b1e3-41ef-9137-a215f4c69447	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 02:03:03.313708+00	
00000000-0000-0000-0000-000000000000	ac4fa928-f2fb-43bd-9d3f-758af522e9eb	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-10 02:03:08.716422+00	
00000000-0000-0000-0000-000000000000	ef1da65c-b9fe-4b28-8b39-b9e7297e799e	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-10 02:03:08.717055+00	
00000000-0000-0000-0000-000000000000	67d997f1-743e-4134-a857-8d593ddcbcae	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-10 02:03:08.777795+00	
00000000-0000-0000-0000-000000000000	5bbf0957-c8c4-438a-9cf3-b46d3d393157	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-10 02:03:08.778405+00	
00000000-0000-0000-0000-000000000000	8fc78b9d-3f1a-4ddd-a10a-e23f79135fb6	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 03:02:40.120711+00	
00000000-0000-0000-0000-000000000000	eb48ab01-8140-4c9f-b28f-f7ff71d3eb1b	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 03:02:40.122203+00	
00000000-0000-0000-0000-000000000000	3d56cbb6-d57e-42bb-86ce-ab443f58f831	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 03:02:51.488136+00	
00000000-0000-0000-0000-000000000000	92d33635-9471-41cf-b9a9-a909c1b150dd	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 03:02:51.489402+00	
00000000-0000-0000-0000-000000000000	9fa951a8-6d8b-4938-9691-5fc59d8e660f	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-10 03:02:59.110718+00	
00000000-0000-0000-0000-000000000000	b3090396-b2e0-4473-9c7d-4c7b57456d1a	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-10 03:02:59.111386+00	
00000000-0000-0000-0000-000000000000	97143ab9-0f99-4f61-aa43-ca79b7feb050	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-10 03:02:59.17931+00	
00000000-0000-0000-0000-000000000000	d6b61fba-f423-48fc-a41f-c99cc9f20e84	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-10 03:02:59.17992+00	
00000000-0000-0000-0000-000000000000	4b4811fb-31f6-49f6-b9c3-4667bc166ad8	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-10 03:51:21.522146+00	
00000000-0000-0000-0000-000000000000	17d7f760-b4bd-4694-b578-47d62ed64b8d	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 04:02:30.380987+00	
00000000-0000-0000-0000-000000000000	3d54f70b-acd7-48e1-b0f9-0d590f463874	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 04:02:30.382637+00	
00000000-0000-0000-0000-000000000000	6bacc612-b3e4-4e0f-9c21-d005cbde18bb	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 04:02:30.463316+00	
00000000-0000-0000-0000-000000000000	feb078f6-ca2c-48ec-bdeb-d79b922b64ef	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 04:02:30.463923+00	
00000000-0000-0000-0000-000000000000	51cbf192-8509-4dc1-b029-b9563a75f5de	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 04:02:40.635705+00	
00000000-0000-0000-0000-000000000000	ad1478be-5daa-4b5b-bbed-33e05ab82d71	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 04:02:40.636382+00	
00000000-0000-0000-0000-000000000000	6d90ea4c-d611-4f80-91d9-2026b53c3f7a	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 04:02:40.692997+00	
00000000-0000-0000-0000-000000000000	236c40f7-7c6b-438c-a82d-b4c422ce0699	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-10 04:02:40.693661+00	
00000000-0000-0000-0000-000000000000	dc22cb49-7ac2-413b-ab08-093b0360d47d	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-11 15:08:52.884597+00	
00000000-0000-0000-0000-000000000000	8dff6bab-0cab-4075-b48c-cebddde55ee5	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-11 15:10:49.751118+00	
00000000-0000-0000-0000-000000000000	b900c4ce-edc4-40b0-b2ae-3befaa8ce7ef	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-11 15:20:58.306751+00	
00000000-0000-0000-0000-000000000000	90c3a2a1-e51d-47e9-b727-c3283960cda5	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-11 15:43:44.667261+00	
00000000-0000-0000-0000-000000000000	1c99d0fd-4322-4d78-96f6-239015ac284a	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-11 15:51:49.245748+00	
00000000-0000-0000-0000-000000000000	2449bac3-ee85-41c0-b2c1-311754c97449	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 16:20:49.162966+00	
00000000-0000-0000-0000-000000000000	7f7076d1-33f2-47cc-9b28-521edc33d64a	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 16:20:49.165626+00	
00000000-0000-0000-0000-000000000000	baf1486d-c681-4f6c-9cdd-3914671d20cd	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 16:20:49.273115+00	
00000000-0000-0000-0000-000000000000	48dc8fb0-f6ce-44ed-9f35-398d7e9902b6	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 16:20:49.273778+00	
00000000-0000-0000-0000-000000000000	07b80e96-5187-4ee7-832f-c98cdb35048e	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 17:20:39.746059+00	
00000000-0000-0000-0000-000000000000	9b99291e-c729-4d74-85e7-b0903407aa4b	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 17:20:39.749717+00	
00000000-0000-0000-0000-000000000000	2a9a26e4-53ae-4f5a-9efd-49d9ad67bf27	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 17:20:39.829218+00	
00000000-0000-0000-0000-000000000000	baa0b758-b041-4fd2-b29b-b0528b3a9547	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 17:20:39.829821+00	
00000000-0000-0000-0000-000000000000	b5549287-fb2a-44ea-a74e-97eed8084db6	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 18:20:30.265802+00	
00000000-0000-0000-0000-000000000000	0e215148-8279-4a21-b3a7-edae307a03a7	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 18:20:30.268821+00	
00000000-0000-0000-0000-000000000000	f2cabc74-4dcc-4544-ab2f-8a2b475290a1	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 18:20:30.335214+00	
00000000-0000-0000-0000-000000000000	79ebcea6-5d46-438e-88bd-8fe8bd81d4f3	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 18:20:30.335821+00	
00000000-0000-0000-0000-000000000000	caa1afec-37bc-4401-a78d-dd66f5f87167	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 19:20:20.762054+00	
00000000-0000-0000-0000-000000000000	d9d747ac-85b2-4540-9b95-2f7168b7f79f	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 19:20:20.765734+00	
00000000-0000-0000-0000-000000000000	d3391e3b-c6bf-4858-8cab-ce83df73daf5	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 19:20:20.838427+00	
00000000-0000-0000-0000-000000000000	b07a22ff-7dd5-400b-b029-8c1b0af9eb02	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 19:20:20.83909+00	
00000000-0000-0000-0000-000000000000	ce112739-55f4-4a56-8c53-6b41064cedbb	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 20:20:11.265457+00	
00000000-0000-0000-0000-000000000000	372b5ed2-2fe9-44f3-a5b5-129fdf729ec3	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 20:20:11.267534+00	
00000000-0000-0000-0000-000000000000	836f3ec0-1a2f-40ea-b0df-570014824d24	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 20:20:11.348942+00	
00000000-0000-0000-0000-000000000000	e97d2632-efea-48ec-a854-46b22472b74f	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 20:20:11.350459+00	
00000000-0000-0000-0000-000000000000	ede2f253-f3c1-405b-8f4d-326e4220700b	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 21:20:02.772553+00	
00000000-0000-0000-0000-000000000000	ad864b52-42a7-4430-a51e-1042c09cbb11	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 21:20:02.775339+00	
00000000-0000-0000-0000-000000000000	a3871a84-f0b4-467f-8dfe-4d350275ee03	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 21:20:02.910182+00	
00000000-0000-0000-0000-000000000000	50e8eabe-5623-4091-8b2f-dd071aae1a6d	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 21:20:02.910835+00	
00000000-0000-0000-0000-000000000000	2f227cda-a190-4477-968d-6f2daaf1944a	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 22:19:53.352858+00	
00000000-0000-0000-0000-000000000000	ec153d0c-5bc2-4602-83f4-98cb86ccd29c	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 22:19:53.355227+00	
00000000-0000-0000-0000-000000000000	4ef0e00c-1643-43cf-9aea-91ead623bda9	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 22:19:53.467423+00	
00000000-0000-0000-0000-000000000000	fed247eb-b0e7-421e-be69-89d4757e708a	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 22:19:53.468019+00	
00000000-0000-0000-0000-000000000000	8d8c5aff-37d7-4b52-a21c-723da995c43a	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 23:19:44.882933+00	
00000000-0000-0000-0000-000000000000	ef44c23d-eefc-431e-b0b9-d8079f72a474	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 23:19:44.884269+00	
00000000-0000-0000-0000-000000000000	7cf24467-27f8-4e87-bed7-d88d7f397357	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 23:19:44.984446+00	
00000000-0000-0000-0000-000000000000	91b14862-9144-49ab-b7d8-ae3e54233fec	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-11 23:19:44.985039+00	
00000000-0000-0000-0000-000000000000	60b98bcb-99db-4c13-864c-f41490a06416	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 00:19:35.395152+00	
00000000-0000-0000-0000-000000000000	20971763-8f3a-4555-a397-a18997224ef7	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 00:19:35.399665+00	
00000000-0000-0000-0000-000000000000	db82abe4-8cdd-4d0b-a288-f9300d018ee0	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 00:19:35.492021+00	
00000000-0000-0000-0000-000000000000	b839eddb-47a6-48af-90a3-148c0f90d8e5	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 00:19:35.492655+00	
00000000-0000-0000-0000-000000000000	45ef8277-8010-4de6-8b5b-4f24ec16c8ec	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 01:19:27.511429+00	
00000000-0000-0000-0000-000000000000	8d73bae4-06c0-4c3c-91cd-d4f18e5af970	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 01:19:27.524896+00	
00000000-0000-0000-0000-000000000000	3c5d4584-815c-44d3-af6e-16a433112c80	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 01:19:27.629365+00	
00000000-0000-0000-0000-000000000000	4e54f580-62b9-4212-b6fe-4137dfd25a1a	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 01:19:27.629983+00	
00000000-0000-0000-0000-000000000000	ac1bb546-6e30-41f2-8acc-35a6f8f6e4d2	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 02:19:19.044396+00	
00000000-0000-0000-0000-000000000000	3c67f03d-cd9a-40ec-bc6f-243a33093e2f	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 02:19:19.047105+00	
00000000-0000-0000-0000-000000000000	399b7c18-a684-45fd-89ad-fe562306ec79	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 02:19:19.15575+00	
00000000-0000-0000-0000-000000000000	4a36a068-3db7-44da-b07f-2c5cc5d9f7be	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 02:19:19.156388+00	
00000000-0000-0000-0000-000000000000	842c9b6b-1710-456c-8ca1-59a789589ded	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 03:19:11.63029+00	
00000000-0000-0000-0000-000000000000	8767eee3-8936-4b79-a443-9b1450e80aa4	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 03:19:11.632294+00	
00000000-0000-0000-0000-000000000000	97680ce2-5af1-479b-89c8-6895e13aecff	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 03:19:11.747654+00	
00000000-0000-0000-0000-000000000000	4ac4dcbf-74cd-48e4-8010-13a25f0cb872	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 03:19:11.748254+00	
00000000-0000-0000-0000-000000000000	6653f825-bccb-4804-ad13-9bbc6e4d6b4d	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 04:19:03.186958+00	
00000000-0000-0000-0000-000000000000	6f4fa702-ae9b-40a3-8e58-3789550c3fc1	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 04:19:03.189932+00	
00000000-0000-0000-0000-000000000000	329ca1f8-23f0-4116-abeb-031d16848241	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 04:19:03.304552+00	
00000000-0000-0000-0000-000000000000	c0d1c37e-d7d7-47d9-a149-0ff944d39427	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 04:19:03.305141+00	
00000000-0000-0000-0000-000000000000	c9a38710-653e-4cdc-8dd0-0ddbe409a41f	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 05:18:55.716315+00	
00000000-0000-0000-0000-000000000000	1d12e375-383d-4000-a23d-e9b190018db1	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 05:18:55.718601+00	
00000000-0000-0000-0000-000000000000	42efa272-3816-491c-9a6d-97d79f27f101	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 05:18:55.78463+00	
00000000-0000-0000-0000-000000000000	4b3d4ea1-4593-4e49-a791-435efd20d149	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 05:18:55.785235+00	
00000000-0000-0000-0000-000000000000	c73c33ca-6066-41d1-b74d-39728aa7089e	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 06:18:48.187227+00	
00000000-0000-0000-0000-000000000000	d11ebad3-170e-4494-a6af-b99ca8556190	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 06:18:48.189275+00	
00000000-0000-0000-0000-000000000000	11b054bd-9a37-47d3-b3cd-d8fb1f721391	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 06:18:48.278744+00	
00000000-0000-0000-0000-000000000000	258e43a7-c351-49a6-84a3-eb3986063d9c	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 06:18:48.279383+00	
00000000-0000-0000-0000-000000000000	6399f5d3-5c3a-4cc3-9009-f40f962388a1	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 07:18:40.717788+00	
00000000-0000-0000-0000-000000000000	247b4f2d-eed3-4f66-b8e6-c26d142a4869	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 07:18:40.723576+00	
00000000-0000-0000-0000-000000000000	d1fcb089-7727-4275-887e-2ae1d31fb717	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 07:18:40.814334+00	
00000000-0000-0000-0000-000000000000	aaea6e3b-41af-4f32-bcba-66bba92af23c	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 07:18:40.814943+00	
00000000-0000-0000-0000-000000000000	04e283cb-8302-4eaa-a59b-27fdc9b718f4	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 08:18:33.24882+00	
00000000-0000-0000-0000-000000000000	e100ecfd-0417-4971-85d7-141cbeee8eb7	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 08:18:33.251985+00	
00000000-0000-0000-0000-000000000000	065f3faf-4b68-4383-babf-32496afddc76	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 08:18:33.336885+00	
00000000-0000-0000-0000-000000000000	4f41f3ea-a362-441d-9619-744b2a6d9012	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 08:18:33.337505+00	
00000000-0000-0000-0000-000000000000	afb2494e-4c83-42ca-8393-d4b3c4f1ced9	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 09:18:25.745335+00	
00000000-0000-0000-0000-000000000000	19c9ceb7-d610-4050-b455-373da0ed3d7d	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 09:18:25.75026+00	
00000000-0000-0000-0000-000000000000	5ec50975-6204-413c-b684-03c50dfb1b96	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 09:18:25.830826+00	
00000000-0000-0000-0000-000000000000	825df15c-00f1-4ef5-aee7-33a9811a3de3	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 09:18:25.831451+00	
00000000-0000-0000-0000-000000000000	23782f51-4771-41d6-9f64-64069e614782	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 10:18:18.260211+00	
00000000-0000-0000-0000-000000000000	082fa07b-67d1-4ed7-b647-ebbbe8cf893f	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 10:18:18.26723+00	
00000000-0000-0000-0000-000000000000	22a2665a-a54b-458c-bd07-21b08632e99d	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 10:18:18.365733+00	
00000000-0000-0000-0000-000000000000	977e3509-5582-4546-b969-171d385f1aff	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 10:18:18.366327+00	
00000000-0000-0000-0000-000000000000	9b920a99-92d0-4a8c-b464-609a2030db1e	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 11:18:11.790496+00	
00000000-0000-0000-0000-000000000000	b09ea060-cc16-47cc-9d34-f4678ed9e91d	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 11:18:11.794224+00	
00000000-0000-0000-0000-000000000000	cab37333-cd10-42d2-bcdf-98273d9bc7b3	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 11:18:11.887012+00	
00000000-0000-0000-0000-000000000000	2bfaa96f-4ce8-44c0-aa24-a89a021b94e7	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 11:18:11.889237+00	
00000000-0000-0000-0000-000000000000	13462fbb-e78e-4992-affe-1ac7f2979c77	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 12:18:04.297711+00	
00000000-0000-0000-0000-000000000000	e2d46a32-041e-4938-802d-ea9398c7cbb3	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 12:18:04.299675+00	
00000000-0000-0000-0000-000000000000	b889f39e-73f1-4eb0-a899-7f1bc49cf8ab	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 12:18:04.389466+00	
00000000-0000-0000-0000-000000000000	209710a9-58df-4ed1-a8c7-16b532830f7b	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 12:18:04.390087+00	
00000000-0000-0000-0000-000000000000	e6d0054e-fa9a-43ba-a668-d9b125b14a73	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 13:17:57.809993+00	
00000000-0000-0000-0000-000000000000	53604ea8-1ad4-494f-bab5-6d8cbd7fc3f8	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 13:17:57.811521+00	
00000000-0000-0000-0000-000000000000	901637c8-b383-469e-8e7d-e0eed66ad68f	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 13:17:57.883335+00	
00000000-0000-0000-0000-000000000000	45d5cf6e-b03a-4d17-a00b-d748721797cc	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 13:17:57.883933+00	
00000000-0000-0000-0000-000000000000	65b09075-6b1a-4aa4-8d98-d5f9d2c45db6	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 14:17:51.269668+00	
00000000-0000-0000-0000-000000000000	d958c8be-1eeb-4e44-a489-7cf873696c1c	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 14:17:51.271217+00	
00000000-0000-0000-0000-000000000000	56191c9a-7af2-4d68-b1b1-fd9258c989fa	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 14:17:51.34924+00	
00000000-0000-0000-0000-000000000000	42c700c6-8077-4856-9122-bfab80c27317	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 14:17:51.349925+00	
00000000-0000-0000-0000-000000000000	60e970ab-89e1-4207-b893-cac29ef54346	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 15:17:44.752208+00	
00000000-0000-0000-0000-000000000000	1cd04004-dccf-47df-b239-880ba733520f	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 15:17:44.75369+00	
00000000-0000-0000-0000-000000000000	def138d2-efc9-475d-88b8-e2be46377bd0	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 15:17:44.879392+00	
00000000-0000-0000-0000-000000000000	869f5812-2902-4414-8415-0b453d72dbbb	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 15:17:44.880087+00	
00000000-0000-0000-0000-000000000000	c0a8db89-7990-4d71-9fcb-8c2fc5be159d	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 16:17:38.415307+00	
00000000-0000-0000-0000-000000000000	3747098e-3b17-4557-a044-ef1afeb061e1	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 16:17:38.416754+00	
00000000-0000-0000-0000-000000000000	085340d1-d116-401b-bec6-da84cc3ce422	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 16:17:38.508241+00	
00000000-0000-0000-0000-000000000000	e0bd466c-ae61-44be-aa94-771cb03de791	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 16:17:38.508847+00	
00000000-0000-0000-0000-000000000000	05e9996a-1fac-49a5-b2c8-41191a5239fe	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 17:17:31.975129+00	
00000000-0000-0000-0000-000000000000	f0e5556e-7e09-43cb-9959-84bf0e17c5f2	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 17:17:31.97676+00	
00000000-0000-0000-0000-000000000000	0ba84274-7c1b-4aac-a258-b6a04ecfdfdd	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 17:17:32.071295+00	
00000000-0000-0000-0000-000000000000	43037913-9052-4983-a976-18e6f1e15bb2	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 17:17:32.071896+00	
00000000-0000-0000-0000-000000000000	bc0087fd-e84a-4c6b-9a9a-4a64d876b87e	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 18:17:26.475008+00	
00000000-0000-0000-0000-000000000000	f303e389-e35a-48c3-8b09-2030fa8e1d26	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 18:17:26.477637+00	
00000000-0000-0000-0000-000000000000	7e952fc3-fd1a-42e1-b974-c61c323030b4	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 18:17:26.596007+00	
00000000-0000-0000-0000-000000000000	3aec40f8-953e-447e-b27b-4426489116f8	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 18:17:26.596684+00	
00000000-0000-0000-0000-000000000000	82b445f2-757a-4020-bd84-d5ade9c485d7	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 19:17:21.038761+00	
00000000-0000-0000-0000-000000000000	fcff69a7-7980-4a91-9fc2-204c9797e7c5	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 19:17:21.042357+00	
00000000-0000-0000-0000-000000000000	e7a7c32e-89ba-4ab2-aede-7ccf6cfaf339	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 19:17:21.139289+00	
00000000-0000-0000-0000-000000000000	092e1846-ed02-4e79-a94c-dfdeebda093a	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 19:17:21.139857+00	
00000000-0000-0000-0000-000000000000	bd9dd7f8-1fb0-42b4-bf2c-a7727009547c	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 20:17:15.53551+00	
00000000-0000-0000-0000-000000000000	35d091ba-67e6-4816-b934-4d3ed01c21c1	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 20:17:15.537669+00	
00000000-0000-0000-0000-000000000000	48c5e835-8832-4aa2-a58f-53bf9690d528	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 20:17:15.665484+00	
00000000-0000-0000-0000-000000000000	a3ae1973-327d-4a7e-94e2-8cdaa38d5e6d	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 20:17:15.666085+00	
00000000-0000-0000-0000-000000000000	75f47fe3-b2fa-495f-839b-68316e376592	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 21:17:05.041602+00	
00000000-0000-0000-0000-000000000000	96704f39-c040-4fe2-8c8d-d55ac4d8d734	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 21:17:05.044272+00	
00000000-0000-0000-0000-000000000000	31c6e47d-cd49-4dc4-8d8e-fedddfc089ce	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 21:17:05.115252+00	
00000000-0000-0000-0000-000000000000	9ecc8431-dd18-47e0-8494-9b9888d040f3	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 21:17:05.115846+00	
00000000-0000-0000-0000-000000000000	7047c5c2-bb09-4120-8b74-5b2d6b8a2a33	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 22:16:55.515672+00	
00000000-0000-0000-0000-000000000000	bcb1ef74-6151-46b1-ab55-12888af0ecbc	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 22:16:55.517385+00	
00000000-0000-0000-0000-000000000000	c23f1db0-614d-4700-a278-a3a8cadb3d66	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 22:16:55.591137+00	
00000000-0000-0000-0000-000000000000	f5c4a332-da3f-4778-8beb-89d360bb32ea	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 22:16:55.591801+00	
00000000-0000-0000-0000-000000000000	35082a14-f747-42e6-9013-397cc9c25249	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 23:16:46.041692+00	
00000000-0000-0000-0000-000000000000	7ac59a15-8d9c-4487-87f1-78e9758076d8	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 23:16:46.043844+00	
00000000-0000-0000-0000-000000000000	755a5e60-44d4-40c5-8e38-d9a69917f2c0	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 23:16:46.15095+00	
00000000-0000-0000-0000-000000000000	dc02a0cd-21d8-4613-a44e-c1c48a61aafd	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-12 23:16:46.151577+00	
00000000-0000-0000-0000-000000000000	31ad1792-83f5-4e39-a2b2-daff289ac2d8	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 00:16:36.556261+00	
00000000-0000-0000-0000-000000000000	540bad16-8e7b-4d1b-8a54-ba2f2621f32e	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 00:16:36.558709+00	
00000000-0000-0000-0000-000000000000	0e63b448-9f15-4ba6-bfa9-f35d347d0f46	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 00:16:36.66174+00	
00000000-0000-0000-0000-000000000000	3b39d3d4-5e46-4bc1-8c05-d090477f9a03	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 00:16:36.662405+00	
00000000-0000-0000-0000-000000000000	96042366-a2ac-4f1d-8ab1-eea7045e4f98	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 01:16:27.164627+00	
00000000-0000-0000-0000-000000000000	18109b0b-ccff-425d-99f9-e6657cf6cf1d	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 01:16:27.172675+00	
00000000-0000-0000-0000-000000000000	83aa3513-1aa2-46e5-9989-996016e916f3	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 01:16:27.248516+00	
00000000-0000-0000-0000-000000000000	119f4daf-a514-43cd-936c-3fee3165798b	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 01:16:27.249105+00	
00000000-0000-0000-0000-000000000000	22a8fc7b-3174-41e6-91e2-babe1efa3c5b	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 02:16:17.671536+00	
00000000-0000-0000-0000-000000000000	a3ea0b5d-eb8e-4fbf-86df-26ab38733485	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 02:16:17.67427+00	
00000000-0000-0000-0000-000000000000	9835ad4e-675a-4c4d-9237-b15c65b00feb	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 02:16:17.744822+00	
00000000-0000-0000-0000-000000000000	1cacceb2-8faf-4a09-9ad6-d2821e1380c4	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 02:16:17.745437+00	
00000000-0000-0000-0000-000000000000	c23dfa8e-f7c4-4069-87dc-af7da95888a6	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 03:16:08.179862+00	
00000000-0000-0000-0000-000000000000	e3950c27-0923-40d9-96d7-d29450b5075f	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 03:16:08.184125+00	
00000000-0000-0000-0000-000000000000	170b208f-6f51-4a9f-8195-985fa99ac2cb	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 03:16:08.246641+00	
00000000-0000-0000-0000-000000000000	548d3bf0-7626-4212-94e5-2f56ee42d878	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 03:16:08.247231+00	
00000000-0000-0000-0000-000000000000	9de6c466-6b08-4d04-8738-0208b699ebd4	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 04:15:59.652164+00	
00000000-0000-0000-0000-000000000000	fe1ffd3d-03d8-4ac9-9998-b1b71a727a24	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 04:15:59.65672+00	
00000000-0000-0000-0000-000000000000	3defd889-f2d6-42bc-b966-50aa59fec936	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 04:15:59.735805+00	
00000000-0000-0000-0000-000000000000	d20f9dfc-867b-468b-b4b1-4bb15dea4b44	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 04:15:59.736419+00	
00000000-0000-0000-0000-000000000000	71fb0374-d5e3-4a36-85d7-75135acc437e	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 05:15:50.156604+00	
00000000-0000-0000-0000-000000000000	10fc2169-b294-4e7c-922f-8ca0380b7a5d	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 05:15:50.16194+00	
00000000-0000-0000-0000-000000000000	806cc9e2-b358-47c2-a4d5-53736b2843ce	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 05:15:50.283178+00	
00000000-0000-0000-0000-000000000000	e3d1cc3f-eaca-429f-ba46-541676a5d548	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 05:15:50.283795+00	
00000000-0000-0000-0000-000000000000	123c9a15-8c2e-4d22-a811-b42c2337067a	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 06:15:41.719744+00	
00000000-0000-0000-0000-000000000000	a48d0358-b6be-4da5-a82f-003bc9d38c92	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 06:15:41.721449+00	
00000000-0000-0000-0000-000000000000	d68977bd-8b5c-4c10-a471-9f596e7bc570	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 06:15:41.84245+00	
00000000-0000-0000-0000-000000000000	7ab85771-ee8b-4797-bc55-fd73c24e88f7	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 06:15:41.843057+00	
00000000-0000-0000-0000-000000000000	ae149b43-6ad3-44df-a139-c78f679a1c9f	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 07:15:33.315624+00	
00000000-0000-0000-0000-000000000000	cced4f1d-e19f-4b08-a508-2216ecb3204a	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 07:15:33.323008+00	
00000000-0000-0000-0000-000000000000	30f1b185-2072-4dce-bef2-4c9c75a4080c	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 07:15:33.42717+00	
00000000-0000-0000-0000-000000000000	1ecaf4e2-1141-4e11-a2ea-baafb2fc00df	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 07:15:33.427772+00	
00000000-0000-0000-0000-000000000000	595362c7-f75d-46fe-9e23-594372feaad9	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 08:15:24.876892+00	
00000000-0000-0000-0000-000000000000	5fcca799-bd6c-44d7-a896-6b2e1f3ed9fc	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 08:15:24.87954+00	
00000000-0000-0000-0000-000000000000	0b13d77a-1f01-423a-a3d8-1567a482c5b1	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 08:15:24.959878+00	
00000000-0000-0000-0000-000000000000	1a41730b-b809-47c8-8eef-e2b252223eca	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-13 08:15:24.960477+00	
00000000-0000-0000-0000-000000000000	7fa6c81c-c2dd-4b3b-a1ad-3a44064ab031	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-13 17:43:50.829895+00	
00000000-0000-0000-0000-000000000000	c7819acc-6795-4506-974a-7f1215d18750	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-13 17:46:34.755177+00	
00000000-0000-0000-0000-000000000000	83a0a84b-f70b-4f7f-acd8-d3154750eef1	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-13 17:47:19.025519+00	
00000000-0000-0000-0000-000000000000	e1778559-6c0a-4968-9afd-f15c4ab783ab	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-14 18:43:33.394869+00	
00000000-0000-0000-0000-000000000000	f3a51faa-1f35-46ad-9375-d6da0cf482be	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-14 19:06:13.258288+00	
00000000-0000-0000-0000-000000000000	12fae0f1-41b4-41fe-8b4c-1eca958b5eff	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-14 19:06:15.645286+00	
00000000-0000-0000-0000-000000000000	0425258a-5390-4118-969b-238bea92e3fd	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-14 19:06:17.063834+00	
00000000-0000-0000-0000-000000000000	528e2993-08c9-42f8-b118-2298db88ea9d	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-14 20:06:08.296876+00	
00000000-0000-0000-0000-000000000000	2906195b-49ea-4afd-add1-0476d6e6cc78	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-14 20:06:08.3022+00	
00000000-0000-0000-0000-000000000000	71fb7663-b840-4eb9-b158-f664a50e6377	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-14 20:06:08.362781+00	
00000000-0000-0000-0000-000000000000	35f783e3-0187-4cdf-8555-e2cce9d64c9a	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-14 20:06:08.363406+00	
00000000-0000-0000-0000-000000000000	46b23783-19fd-47d0-b5b5-205f2bac9165	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-14 22:13:32.683401+00	
00000000-0000-0000-0000-000000000000	633e5b9d-f253-4bd7-9ed5-c29c18e1c671	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-14 22:15:46.822441+00	
00000000-0000-0000-0000-000000000000	fd512d18-c6be-4ea5-a94e-22df0635d6c7	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-14 22:24:58.441822+00	
00000000-0000-0000-0000-000000000000	d4f65992-7f6d-4d95-9847-c11b0dd6e53c	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-14 22:42:52.227582+00	
00000000-0000-0000-0000-000000000000	32f8a96c-e284-4b0e-9a63-1f41fb41033f	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-14 23:42:42.482228+00	
00000000-0000-0000-0000-000000000000	22cac9f3-2d50-4b19-933c-e186985a9552	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-14 23:42:42.484972+00	
00000000-0000-0000-0000-000000000000	1f5f96ee-f194-4374-b589-465ad5d4f46e	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-14 23:42:42.567239+00	
00000000-0000-0000-0000-000000000000	937a0328-c439-47f3-9012-b3f5c4a2a933	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-14 23:42:42.567853+00	
00000000-0000-0000-0000-000000000000	6b765865-a044-4810-bb6e-9bad0b211619	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 00:28:13.658473+00	
00000000-0000-0000-0000-000000000000	25452b1c-bf15-474b-a3b4-20a9d2494c30	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 00:56:47.87706+00	
00000000-0000-0000-0000-000000000000	09aa170b-a628-400e-9f93-a637586a56f9	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 00:57:57.829708+00	
00000000-0000-0000-0000-000000000000	874c1398-6d2a-43fc-b6e9-2ccbb8ea3036	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 04:37:00.955038+00	
00000000-0000-0000-0000-000000000000	8c5a4b1a-7b15-486c-9fef-679073c14925	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 21:57:17.205726+00	
00000000-0000-0000-0000-000000000000	c1d290eb-eaab-4bb7-bbc5-f01f3d2d2c69	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:17:47.446443+00	
00000000-0000-0000-0000-000000000000	bb1aa2aa-97fb-4206-a429-2e25a315efc7	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-15 22:17:47.485368+00	
00000000-0000-0000-0000-000000000000	084f02f0-5377-40f1-9d73-2d5ddc44f203	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-15 23:17:37.926943+00	
00000000-0000-0000-0000-000000000000	db230a20-402d-4979-900c-e12de5ee7a75	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-15 23:17:37.931953+00	
00000000-0000-0000-0000-000000000000	4d8c0025-aa1e-40c2-a2dc-e2fc5e675ff4	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-15 23:17:38.015336+00	
00000000-0000-0000-0000-000000000000	19c71884-50f7-4f08-8994-4555680bb55e	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-15 23:17:38.016395+00	
00000000-0000-0000-0000-000000000000	1a5c731e-67a6-4922-8bc0-342a73610e77	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 00:05:45.199938+00	
00000000-0000-0000-0000-000000000000	0fb4aa1c-287b-48b6-a51a-d753d4effc27	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 01:05:35.651859+00	
00000000-0000-0000-0000-000000000000	f47ba112-dce8-439b-85a7-bd6c6f082a06	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 01:05:35.654334+00	
00000000-0000-0000-0000-000000000000	651ca122-f580-49c2-a494-fc19065a717d	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 01:05:35.723361+00	
00000000-0000-0000-0000-000000000000	850c2070-c893-4125-913e-431dad5cb65b	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 01:05:35.724012+00	
00000000-0000-0000-0000-000000000000	444fb61e-4b11-4439-9ce8-0fb181d95b96	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 02:05:26.149424+00	
00000000-0000-0000-0000-000000000000	d09f7d57-a732-444a-985e-7d09a892af1d	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 02:05:26.152192+00	
00000000-0000-0000-0000-000000000000	8cbe32a9-c8c0-402b-a4e3-e08e98e965e4	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 02:05:26.259323+00	
00000000-0000-0000-0000-000000000000	db53df2d-98bb-414d-90f6-fca75193688b	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 02:05:26.259954+00	
00000000-0000-0000-0000-000000000000	414479a0-4eb6-4dfa-8b33-ed1f6e71d92f	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 03:49:14.857353+00	
00000000-0000-0000-0000-000000000000	01ef5228-fade-40c5-b00d-68b97d2a87b3	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 04:49:05.295417+00	
00000000-0000-0000-0000-000000000000	f0151e53-e03a-46b9-90c9-b924263a0c27	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 04:49:05.297563+00	
00000000-0000-0000-0000-000000000000	5df74988-8180-483c-a33f-3839e6861371	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 04:49:05.383552+00	
00000000-0000-0000-0000-000000000000	238b942c-32bf-44ab-8bae-6200487825ad	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 04:49:05.384168+00	
00000000-0000-0000-0000-000000000000	6a30e1dc-d0b4-47c3-9ded-0159b1042811	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 05:48:56.8383+00	
00000000-0000-0000-0000-000000000000	695e6c36-9c37-42d6-8db4-0cdd3cf95149	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 05:48:56.839954+00	
00000000-0000-0000-0000-000000000000	671a5d4e-5ab3-4076-b68b-c8a907ce4ecb	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 05:48:56.916886+00	
00000000-0000-0000-0000-000000000000	73021e50-c123-4146-b2ba-b8a5c214747d	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 05:48:56.917572+00	
00000000-0000-0000-0000-000000000000	57e2b000-eeb8-4c89-85af-859c54234c79	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 06:48:46.405805+00	
00000000-0000-0000-0000-000000000000	c4855046-b085-4668-a04b-53c57fbf9bcb	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 06:48:46.418506+00	
00000000-0000-0000-0000-000000000000	71395537-33b9-4121-9ed8-f236c95e2665	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 06:48:46.568721+00	
00000000-0000-0000-0000-000000000000	3c04251a-7dcb-4819-8ade-f8f300a8b953	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-16 06:48:46.569366+00	
00000000-0000-0000-0000-000000000000	3de71d68-1ecc-4228-95f5-40b68055f8b3	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-16 08:36:01.740056+00	
00000000-0000-0000-0000-000000000000	110c396c-81a2-4105-aede-0618569dfcce	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 00:43:08.161745+00	
00000000-0000-0000-0000-000000000000	a557db5e-7e45-4dd5-b5b3-8f65031b3ce8	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 16:35:53.447733+00	
00000000-0000-0000-0000-000000000000	3ea03f5d-1f8f-4a0e-a4f4-2c2f9a7a4b40	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 16:46:33.584689+00	
00000000-0000-0000-0000-000000000000	67395a63-f858-41fb-b6b5-6cd816a6f487	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 16:48:31.800583+00	
00000000-0000-0000-0000-000000000000	e0e7fc8e-4bc5-4904-a111-81590bcf84d3	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 16:48:36.145975+00	
00000000-0000-0000-0000-000000000000	de2722e8-6191-4173-94fb-2c2ec922bc1d	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 17:15:39.78383+00	
00000000-0000-0000-0000-000000000000	6cddc783-6968-4481-a92d-71b50b225aeb	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 17:15:42.140529+00	
00000000-0000-0000-0000-000000000000	39fb0903-88e6-4a7a-8bac-41df3d5223ee	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-19 18:04:26.894129+00	
00000000-0000-0000-0000-000000000000	5709ce60-b256-4eb2-8c89-a074df715758	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"phernandez4@csus.edu","user_id":"f8140ab0-94b5-4318-aacb-6d4b6800fea9","user_phone":""}}	2025-04-19 22:16:56.047842+00	
00000000-0000-0000-0000-000000000000	998c8ef6-981a-4cd2-b7b0-0bdc335abbbb	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"phernandez4@csus.edu","user_id":"9bf190a8-b79d-4058-a1cf-7ecad112b66e","user_phone":""}}	2025-04-19 22:17:14.252179+00	
00000000-0000-0000-0000-000000000000	22304b34-87a0-4051-910a-998fbccbf41c	{"action":"user_recovery_requested","actor_id":"9bf190a8-b79d-4058-a1cf-7ecad112b66e","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-19 22:20:20.445287+00	
00000000-0000-0000-0000-000000000000	6ad5e485-c823-49f0-bc65-512a124dc106	{"action":"login","actor_id":"9bf190a8-b79d-4058-a1cf-7ecad112b66e","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-19 22:20:46.259223+00	
00000000-0000-0000-0000-000000000000	cc490e6a-5403-4a03-8558-a7e72ab13384	{"action":"user_recovery_requested","actor_id":"9bf190a8-b79d-4058-a1cf-7ecad112b66e","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-19 22:21:24.644565+00	
00000000-0000-0000-0000-000000000000	92505ede-19ea-4178-acf7-2f12c7cdb092	{"action":"login","actor_id":"9bf190a8-b79d-4058-a1cf-7ecad112b66e","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-19 22:21:37.417485+00	
00000000-0000-0000-0000-000000000000	618be701-a453-44cb-af68-6d2b0643c4a1	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 23:18:56.835903+00	
00000000-0000-0000-0000-000000000000	c3d2b185-698d-4104-9da1-55faac2126ea	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-20 23:19:00.314599+00	
00000000-0000-0000-0000-000000000000	e1d2e91c-01e8-42d9-ab7a-dbe2ef71733a	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 08:32:14.916301+00	
00000000-0000-0000-0000-000000000000	f233d5c6-96e2-444c-8dee-908dc9b7ea2a	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 08:32:15.908121+00	
00000000-0000-0000-0000-000000000000	25803d07-5de5-4016-ac3b-072782a98bcc	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 18:00:43.016036+00	
00000000-0000-0000-0000-000000000000	4b191a1e-e6f5-4dc1-8ea0-26b441c01505	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 18:01:26.38084+00	
00000000-0000-0000-0000-000000000000	0ccde017-0a53-4602-a9b4-5f440412ecb2	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 18:05:23.026581+00	
00000000-0000-0000-0000-000000000000	a3bf1643-bae8-4671-9e09-0c60054fad26	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-25 18:05:27.594467+00	
00000000-0000-0000-0000-000000000000	913621d8-5e0a-41cc-a912-43d4485c80f2	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-25 18:05:27.599373+00	
00000000-0000-0000-0000-000000000000	14d73270-02a6-4da5-931b-16404227f5f7	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-25 18:06:01.804419+00	
00000000-0000-0000-0000-000000000000	305eb345-30fa-4365-8c97-c1ba2069e357	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-25 18:06:01.805612+00	
00000000-0000-0000-0000-000000000000	a2ab9e14-e1c1-428c-ab32-cc5fa05a6094	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-25 20:57:19.013687+00	
00000000-0000-0000-0000-000000000000	cf5bb4aa-5eab-46ff-a9b8-ef0c9b9cf74e	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-25 20:57:19.017364+00	
00000000-0000-0000-0000-000000000000	b37d49da-a102-485f-9963-f2bad8c123e2	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 21:08:11.135299+00	
00000000-0000-0000-0000-000000000000	7346b3ce-143b-4d4f-973f-2502228c7fa4	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 21:09:15.621335+00	
00000000-0000-0000-0000-000000000000	a3d3c27d-90b6-4146-8691-764e46cfae82	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 21:09:17.266298+00	
00000000-0000-0000-0000-000000000000	d20b8ac1-e301-4022-9dae-4dcd13fdc39f	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 21:09:56.521548+00	
00000000-0000-0000-0000-000000000000	9a8e95b6-92c5-4581-8f56-ea9a7b9c1221	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 21:11:11.223094+00	
00000000-0000-0000-0000-000000000000	40e2d827-4597-4960-a319-52a8135843ef	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 21:11:40.728497+00	
00000000-0000-0000-0000-000000000000	b8e5f1f6-1a4d-4637-81e2-a0090420dc52	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 21:12:41.798365+00	
00000000-0000-0000-0000-000000000000	74ab917c-456f-4863-9237-184e9f72b48f	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 23:38:29.550961+00	
00000000-0000-0000-0000-000000000000	03482e3c-2ef8-4aa0-a187-67f999f3e679	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 23:43:03.282548+00	
00000000-0000-0000-0000-000000000000	0c0203b4-2b78-4886-8990-6667f6eaefef	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 23:52:30.530886+00	
00000000-0000-0000-0000-000000000000	e3389f27-230e-4964-9a25-00c1ca5d2a28	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 23:53:36.823602+00	
00000000-0000-0000-0000-000000000000	0836122d-77da-496e-bc75-6c066e4c44a5	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 23:54:17.698869+00	
00000000-0000-0000-0000-000000000000	feb4efbe-967f-4ba6-b7a2-8f85c02ff7d9	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-25 23:54:24.986135+00	
00000000-0000-0000-0000-000000000000	c1eea96d-2930-427e-aeed-d638fb43f029	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 01:11:33.10478+00	
00000000-0000-0000-0000-000000000000	51355935-0e53-4410-a942-f8bcd42c94f9	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 01:15:23.107261+00	
00000000-0000-0000-0000-000000000000	53395bf1-c7c9-4257-a7e0-32f48e242cc7	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 01:16:11.979487+00	
00000000-0000-0000-0000-000000000000	62581a50-5817-41c6-9665-5d088e481165	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 01:18:31.895844+00	
00000000-0000-0000-0000-000000000000	fc638a71-4cc9-4e2c-8a34-7866238670b6	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 01:19:16.166844+00	
00000000-0000-0000-0000-000000000000	95ae47ed-b8ee-474b-b3cd-9410d46357b2	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 01:23:10.495521+00	
00000000-0000-0000-0000-000000000000	307eaa73-3764-4a26-b314-91af801dbedd	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 01:23:13.454215+00	
00000000-0000-0000-0000-000000000000	d4e6d22f-fd5f-4318-a379-2baa99d8ed36	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 01:23:15.387748+00	
00000000-0000-0000-0000-000000000000	6f0c164a-62e9-4b00-b7dc-804ed7794b5a	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 01:23:44.808523+00	
00000000-0000-0000-0000-000000000000	1193f45b-de32-4082-aa11-ff9c24f915a4	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 01:32:37.069822+00	
00000000-0000-0000-0000-000000000000	fccd0c97-7faa-490c-a5bf-0b8d3134ea16	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 01:46:14.114233+00	
00000000-0000-0000-0000-000000000000	8f82effc-73a4-4632-bde1-e8d2a9e08a89	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 01:47:22.285899+00	
00000000-0000-0000-0000-000000000000	23776a22-9d5a-4b19-93f6-e857f8594e82	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 01:56:17.235668+00	
00000000-0000-0000-0000-000000000000	963f4968-a9f2-486b-80d0-8c79e01daad4	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 02:01:51.391282+00	
00000000-0000-0000-0000-000000000000	38ffaebc-d557-4c32-91e6-2f5713d8a6ed	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 02:03:05.623497+00	
00000000-0000-0000-0000-000000000000	a21bb41b-4421-4837-a1f2-0d69ab2eaa0c	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 02:08:49.072828+00	
00000000-0000-0000-0000-000000000000	5872d14d-739a-499a-9631-42922720df33	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 02:33:20.433475+00	
00000000-0000-0000-0000-000000000000	6aeb9049-10a0-4d95-acac-1c5ecef3c875	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 02:49:31.284406+00	
00000000-0000-0000-0000-000000000000	458b2918-743c-41cc-837d-6be943b7bedd	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 02:50:13.134688+00	
00000000-0000-0000-0000-000000000000	e01e15a0-67c1-4e5a-9e98-f1769b4d7064	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:01:47.672937+00	
00000000-0000-0000-0000-000000000000	18b6c5a6-b1ee-496e-a024-835bdd31b6dc	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:14:37.474123+00	
00000000-0000-0000-0000-000000000000	91a7a595-01ef-4a84-8179-5e1d706b4ddf	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:19:25.063921+00	
00000000-0000-0000-0000-000000000000	e8c53b63-f173-4121-940a-829ca649bb94	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:19:28.780997+00	
00000000-0000-0000-0000-000000000000	24a4bed8-366c-4907-b3a9-22a750dd4278	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:19:49.819561+00	
00000000-0000-0000-0000-000000000000	2e7637e4-96d3-4900-bf65-84050af4a73e	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:21:33.565989+00	
00000000-0000-0000-0000-000000000000	f8d16914-3ec0-4955-a37c-ee6c0af18d15	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:22:07.33105+00	
00000000-0000-0000-0000-000000000000	44be572c-998c-4183-95b4-68173fb27a0a	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:23:10.950899+00	
00000000-0000-0000-0000-000000000000	e4c486a5-a0b6-415d-93cc-ce192c193b18	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:31:44.852816+00	
00000000-0000-0000-0000-000000000000	d20c7d51-ec55-4f9f-872d-973031cc31f1	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:44:51.955224+00	
00000000-0000-0000-0000-000000000000	58e6eb20-06ae-4751-8231-c8c77f6376f1	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:45:13.91727+00	
00000000-0000-0000-0000-000000000000	9245da5d-1912-43ee-b8b8-0a2f7c936cb9	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:46:09.138168+00	
00000000-0000-0000-0000-000000000000	6baca0ab-5b6d-4e96-9329-f6645de52962	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:47:02.385195+00	
00000000-0000-0000-0000-000000000000	60008a80-f474-4bdb-8bfd-a36ecce27393	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:47:42.612647+00	
00000000-0000-0000-0000-000000000000	42bc7934-5979-477e-9eda-02bbcf440a32	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:48:03.032558+00	
00000000-0000-0000-0000-000000000000	eeff35b4-67b6-42a1-bef5-ea80ef28cef8	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:48:30.608075+00	
00000000-0000-0000-0000-000000000000	80048ea5-ab92-49e5-9a84-cfa339965e1c	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:50:57.790262+00	
00000000-0000-0000-0000-000000000000	fd2ac998-72a5-4e1c-99b8-c0e9902a1b2d	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:51:46.725422+00	
00000000-0000-0000-0000-000000000000	2c996153-199e-4f29-ab8f-2ea057a23ee4	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 03:52:25.436039+00	
00000000-0000-0000-0000-000000000000	62577c0e-0220-4465-8aae-99e02867f84b	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 06:10:12.854588+00	
00000000-0000-0000-0000-000000000000	19d19c55-1e43-4d01-90e4-a4a01b67435d	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 06:11:04.873493+00	
00000000-0000-0000-0000-000000000000	1080a602-cc14-432c-89ee-211baff48418	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 06:12:16.128206+00	
00000000-0000-0000-0000-000000000000	dc859ad5-4023-40f5-be47-5d526efddf48	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 06:15:01.591144+00	
00000000-0000-0000-0000-000000000000	a93aa821-74a7-4ef6-b684-63acd0024745	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 06:17:13.863264+00	
00000000-0000-0000-0000-000000000000	9beabc95-3e3e-4795-be63-48c81182482e	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 06:17:49.76382+00	
00000000-0000-0000-0000-000000000000	b84a4277-0665-4edd-99f1-b841552b0269	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 06:20:55.613426+00	
00000000-0000-0000-0000-000000000000	fad8c687-2944-4b44-bbbe-fd5d27eca16f	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 06:24:41.153831+00	
00000000-0000-0000-0000-000000000000	1848c44b-fc91-48a2-8643-dea9b5adeeb5	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 06:25:21.851639+00	
00000000-0000-0000-0000-000000000000	b5a133c3-a306-450f-995a-8b818ad6e5ae	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 06:27:48.756752+00	
00000000-0000-0000-0000-000000000000	85550d04-9806-4174-b672-4ee65fbeeb0f	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:01:33.770145+00	
00000000-0000-0000-0000-000000000000	aae366b9-36c6-44d1-af9e-b78609c8f92b	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:11:47.773673+00	
00000000-0000-0000-0000-000000000000	e08be7a3-630f-42fe-9a52-b29a466d7d70	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:11:48.067307+00	
00000000-0000-0000-0000-000000000000	892ed8a3-0f8c-460a-9049-218c8432dc8c	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:12:05.374952+00	
00000000-0000-0000-0000-000000000000	0ad49516-0ccc-4003-82f2-463aaf6763b7	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:12:42.14031+00	
00000000-0000-0000-0000-000000000000	13f492a0-108f-4520-aecd-09d8bc6d92d3	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:16:01.713335+00	
00000000-0000-0000-0000-000000000000	11ae5491-a6d9-455d-84d5-b00d73ff2ac7	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:16:18.127533+00	
00000000-0000-0000-0000-000000000000	494ce48b-4357-4c9b-a36d-3d8d2e8e4876	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:19:46.522386+00	
00000000-0000-0000-0000-000000000000	9a90b499-cdbc-4367-9507-3d1b2b0baa23	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:24:33.318736+00	
00000000-0000-0000-0000-000000000000	ff35a59d-6806-49c2-8681-352a2666723f	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:25:22.249571+00	
00000000-0000-0000-0000-000000000000	38b8d084-b82f-4c54-9284-e94500cad0d3	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:26:29.281181+00	
00000000-0000-0000-0000-000000000000	43176688-97ef-4bdb-ade8-4e0faba3d0dd	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:27:00.729404+00	
00000000-0000-0000-0000-000000000000	9351b44e-86ac-4ca7-b296-290f6156c2df	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:27:32.406609+00	
00000000-0000-0000-0000-000000000000	7f7957e8-be68-4298-b3e6-0015160a0949	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:28:02.519267+00	
00000000-0000-0000-0000-000000000000	2e495255-e164-4809-b94b-db3c8a7b98a8	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:29:37.047878+00	
00000000-0000-0000-0000-000000000000	589a9a2a-aadb-4108-91fd-3dda2f74fb53	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:41:41.58688+00	
00000000-0000-0000-0000-000000000000	13370b3f-ea63-4963-afae-195bf41913e6	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:44:51.1754+00	
00000000-0000-0000-0000-000000000000	0c0ff83e-9313-4c95-ac88-a51f9dcc3239	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:46:58.218137+00	
00000000-0000-0000-0000-000000000000	df2a087c-bd4d-4fc3-9810-3a2556ee980f	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:53:55.990947+00	
00000000-0000-0000-0000-000000000000	4348eaf0-ce17-4583-ba75-d1c874c8731a	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:57:49.006672+00	
00000000-0000-0000-0000-000000000000	9f333b9f-6afb-4276-8ee7-0d74fa415e51	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 15:58:33.820265+00	
00000000-0000-0000-0000-000000000000	6bc10a6d-4e52-40e1-973b-fc92091fcfca	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 16:15:29.157541+00	
00000000-0000-0000-0000-000000000000	95999c30-df82-43e3-afce-14b75c71ecef	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-26 16:18:11.918833+00	
00000000-0000-0000-0000-000000000000	d1664380-ee47-4860-aa6b-2b7ba1f95cfc	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 06:30:13.214134+00	
00000000-0000-0000-0000-000000000000	bcb21841-a57c-441d-af8b-ed204016d3d4	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 06:30:20.964075+00	
00000000-0000-0000-0000-000000000000	eeae7f3d-ac6c-4cdd-a858-8ac1c0e5a02e	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 06:51:08.688884+00	
00000000-0000-0000-0000-000000000000	d8e0ee5c-e4c7-4735-a23d-c36911206c02	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 06:51:14.578585+00	
00000000-0000-0000-0000-000000000000	571ba4d5-010f-4231-9e1c-21c09ab3e6c7	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 06:52:24.100011+00	
00000000-0000-0000-0000-000000000000	e21f26bf-9b44-4a77-89f2-af5d5917dc75	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 06:52:53.164813+00	
00000000-0000-0000-0000-000000000000	d4925ff7-2c17-4cdb-96fe-7e86e4c6fc9a	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 06:53:14.821437+00	
00000000-0000-0000-0000-000000000000	934e80b3-eb43-4c32-8f6f-c8c19178468f	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 06:53:56.427541+00	
00000000-0000-0000-0000-000000000000	4b1320f3-1c61-4cd3-b6af-7359a89f3659	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 06:55:21.896574+00	
00000000-0000-0000-0000-000000000000	843fc3c2-d5c6-4969-890e-5243c8a7307d	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 06:55:43.420455+00	
00000000-0000-0000-0000-000000000000	2b12665a-c558-4a57-a4af-947ad88410d8	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 06:55:47.898469+00	
00000000-0000-0000-0000-000000000000	5f2baf06-50f3-4574-b481-54c8fc635d45	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 08:12:43.626738+00	
00000000-0000-0000-0000-000000000000	08a8cdf0-339d-47e2-80c9-e431328e39a5	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 09:03:54.911798+00	
00000000-0000-0000-0000-000000000000	9f287c8a-f319-4c47-9f47-c01c7ed49976	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 09:04:31.784499+00	
00000000-0000-0000-0000-000000000000	10d6478e-ec9d-4dde-bdb3-66c0ffe66ff6	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 09:38:30.378075+00	
00000000-0000-0000-0000-000000000000	1dd96b68-3fd8-4348-8784-969873d3a9ea	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 09:53:16.363182+00	
00000000-0000-0000-0000-000000000000	ebed5fe0-a945-4cf6-b0fe-754ac919ce2d	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-27 21:32:53.923229+00	
00000000-0000-0000-0000-000000000000	7ccd8ef8-1314-4e29-8d53-6a5f3feb8352	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-27 21:32:53.940317+00	
00000000-0000-0000-0000-000000000000	c23a60ad-1288-41a3-94cc-51feae944ec9	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-27 22:53:44.564638+00	
00000000-0000-0000-0000-000000000000	60644155-055e-4af5-85a7-79a6f111dafc	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-27 23:26:32.910217+00	
00000000-0000-0000-0000-000000000000	dc7c101f-0b7d-4b51-983e-7465268ceb08	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-27 23:26:49.599043+00	
00000000-0000-0000-0000-000000000000	c67ab3b8-e372-41ae-b15c-f69fce5dd855	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-27 23:34:01.308479+00	
00000000-0000-0000-0000-000000000000	cbc07d5b-b0b0-4de4-9b0f-42dff18279ed	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-27 23:34:17.356764+00	
00000000-0000-0000-0000-000000000000	907fe347-f2b2-49e7-94a3-b021a197ba3b	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-27 23:36:20.31852+00	
00000000-0000-0000-0000-000000000000	e9a6f327-35ce-4fe8-82d9-9703f1b5c103	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-27 23:36:35.504506+00	
00000000-0000-0000-0000-000000000000	12bc9418-1056-498f-b615-89ce14373cb8	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-27 23:45:38.432897+00	
00000000-0000-0000-0000-000000000000	7b716208-2be0-481b-978f-9840e45d866b	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-27 23:45:57.105936+00	
00000000-0000-0000-0000-000000000000	5e0d96a6-0240-4882-9bd1-7bbfd4806ff9	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-27 23:46:41.465692+00	
00000000-0000-0000-0000-000000000000	e5f6f634-d039-49fc-aafb-93c8094eb41d	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-27 23:46:54.733484+00	
00000000-0000-0000-0000-000000000000	a34b4de8-ce8a-4e35-a3c8-d1f36d069346	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-27 23:48:11.499206+00	
00000000-0000-0000-0000-000000000000	fa721571-3f38-4982-8a1e-912f5b1c8e9c	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-27 23:48:28.571589+00	
00000000-0000-0000-0000-000000000000	2ab4469e-5a2b-44c9-9799-a735da901409	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-27 23:50:13.767758+00	
00000000-0000-0000-0000-000000000000	e5e87f6f-b04f-4907-a3a7-8907876009dd	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-27 23:50:29.135982+00	
00000000-0000-0000-0000-000000000000	cb923722-488b-48e6-9ada-29db1b228230	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-28 00:34:53.11374+00	
00000000-0000-0000-0000-000000000000	54c65281-ea38-4ebc-8424-8a89232c207a	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-28 00:35:33.366509+00	
00000000-0000-0000-0000-000000000000	de3df578-53c0-4578-8e07-7f66c4f4bb1e	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 01:51:56.1093+00	
00000000-0000-0000-0000-000000000000	ecbcdfd5-b2db-4652-8105-a8de1802d0d5	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-28 02:51:46.436011+00	
00000000-0000-0000-0000-000000000000	a3faacb9-88c1-49e4-974b-7b90d852a50d	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-28 02:51:46.438282+00	
00000000-0000-0000-0000-000000000000	3961730d-d4c5-420d-bb7d-3fe85f3ae933	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-28 02:51:46.53389+00	
00000000-0000-0000-0000-000000000000	0d8085d2-7682-42ad-92f1-f6cf5bf22aae	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-04-28 02:51:46.536312+00	
00000000-0000-0000-0000-000000000000	324e2a4a-ceaf-4c99-802f-867358638170	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 03:55:12.718285+00	
00000000-0000-0000-0000-000000000000	13e07d9a-1ff9-4694-8b29-35104e67dad8	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 03:55:36.143617+00	
00000000-0000-0000-0000-000000000000	b1cecb66-7828-409d-8a63-d2bdb45f8490	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 04:50:53.164066+00	
00000000-0000-0000-0000-000000000000	f7cc0e89-98d4-40ec-87b1-16ac9b3263e0	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 06:53:44.517924+00	
00000000-0000-0000-0000-000000000000	f54cd50b-feb8-4122-b69b-e68b7cb68064	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 06:53:44.9498+00	
00000000-0000-0000-0000-000000000000	eb68462b-ea82-4581-9e08-a454172280ab	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 06:53:44.951879+00	
00000000-0000-0000-0000-000000000000	7b66b139-7210-4a9b-933f-3f97413b7944	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 06:53:44.981119+00	
00000000-0000-0000-0000-000000000000	fd2eafd4-c72c-4630-8e7d-9a76ef293267	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 07:07:04.638919+00	
00000000-0000-0000-0000-000000000000	84ad45fc-1241-44f7-aea0-d31cc81b4485	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 07:07:05.140362+00	
00000000-0000-0000-0000-000000000000	2503aced-1eab-4a5f-82dc-c30c93ae18ec	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 07:07:05.141065+00	
00000000-0000-0000-0000-000000000000	8517de6b-e824-4b9d-962e-80a54b3e367a	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 07:07:05.177389+00	
00000000-0000-0000-0000-000000000000	2ca2b121-6a0c-4f1f-9b3c-7ff6e9d35be4	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 08:12:28.067357+00	
00000000-0000-0000-0000-000000000000	c2b18d83-03e2-496c-959c-4a897d211c7d	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 08:12:28.069853+00	
00000000-0000-0000-0000-000000000000	e5217c69-242e-4a26-aa73-f190b1d1a9bb	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 08:12:28.10349+00	
00000000-0000-0000-0000-000000000000	6b4f9ec5-64c8-4fa4-9c8a-56c2bd7a1acf	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-28 09:10:36.982865+00	
00000000-0000-0000-0000-000000000000	95353640-43a5-416a-aa15-9acbe89c8d04	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-28 09:10:48.438495+00	
00000000-0000-0000-0000-000000000000	5edd9db3-e914-4ded-a99a-54a78f6346df	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-28 10:57:26.92481+00	
00000000-0000-0000-0000-000000000000	c51c4c3a-3a55-4c7d-a7b1-2c3793c81d11	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-28 10:57:43.782806+00	
00000000-0000-0000-0000-000000000000	49992fe3-83ac-4d7f-9b8b-1cf3077af872	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-28 11:09:39.539184+00	
00000000-0000-0000-0000-000000000000	6fa67bee-6af0-48b4-8615-a6df1ccd3ba1	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-28 11:09:49.676826+00	
00000000-0000-0000-0000-000000000000	9e07eca8-3d7e-419c-9cba-4265935d8924	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-28 12:43:07.517647+00	
00000000-0000-0000-0000-000000000000	34cd28b0-b62f-4164-b3d8-25b5d027acc3	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-28 12:43:32.185833+00	
00000000-0000-0000-0000-000000000000	8fdeecb6-fb43-4da8-88e2-a5bb508874f9	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-28 12:51:47.427338+00	
00000000-0000-0000-0000-000000000000	4fe806f1-0052-4c18-800b-79d0358e7152	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-28 12:51:57.329715+00	
00000000-0000-0000-0000-000000000000	0cdcdf3b-3014-4f3e-8809-3c1397804192	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-28 12:56:19.711543+00	
00000000-0000-0000-0000-000000000000	201b312a-90a0-467d-b1cb-65bf97b4da7d	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-28 12:56:43.743242+00	
00000000-0000-0000-0000-000000000000	c3b8e215-4f97-49d2-bd32-75171de75066	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-28 13:16:20.538109+00	
00000000-0000-0000-0000-000000000000	e02bd39e-2bfb-409a-ad9f-15398734f276	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-28 13:16:31.147119+00	
00000000-0000-0000-0000-000000000000	de5c9cf1-4b12-460c-b85a-44132f3f5277	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-28 19:19:21.865527+00	
00000000-0000-0000-0000-000000000000	a224f710-32d5-4bf7-8c07-1476c44261a6	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-28 19:19:32.819357+00	
00000000-0000-0000-0000-000000000000	fd9adb67-3947-43f4-b51c-8b5a7003a917	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-28 19:48:01.473465+00	
00000000-0000-0000-0000-000000000000	b2f9818e-19f4-4402-bd2a-8f26e75c1510	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-28 19:48:18.085913+00	
00000000-0000-0000-0000-000000000000	0606bd82-3ada-49eb-8f8d-e2c2ef84c5cb	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 19:54:19.148884+00	
00000000-0000-0000-0000-000000000000	5ddbcf7f-3347-4b8a-a8e1-ee6b7b39c496	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 19:54:23.922261+00	
00000000-0000-0000-0000-000000000000	cfcccd5d-795f-47af-addf-1b664c30e0ec	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-28 19:54:39.592803+00	
00000000-0000-0000-0000-000000000000	b51e2f53-72be-467e-bf43-6f832fb4681f	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 19:56:18.662514+00	
00000000-0000-0000-0000-000000000000	50ff7435-69d8-4567-b5a7-2548f2407962	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 19:57:54.43018+00	
00000000-0000-0000-0000-000000000000	0e64be83-30b9-432f-931e-5114593a7fd6	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"nguyenphuctran@csus.edu","user_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","user_phone":""}}	2025-04-28 20:04:11.102585+00	
00000000-0000-0000-0000-000000000000	42c333a8-2bb7-4bec-9d4f-5e8b76ad72bc	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 20:04:19.775407+00	
00000000-0000-0000-0000-000000000000	49fbf8f9-74c1-4bdf-9191-6bde2b3d8053	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 20:04:19.921363+00	
00000000-0000-0000-0000-000000000000	6ececdec-1b63-4d12-a2bc-1a6b0074c694	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 20:04:19.921967+00	
00000000-0000-0000-0000-000000000000	86efdfb0-1b0f-48b1-a1c2-7c85ae2ca133	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 20:12:25.501984+00	
00000000-0000-0000-0000-000000000000	c4da858d-5d48-47c7-82f4-25a2f0edcbd9	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 20:12:25.630818+00	
00000000-0000-0000-0000-000000000000	246a8760-2152-4703-a257-a21a4224020f	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 20:12:25.631476+00	
00000000-0000-0000-0000-000000000000	79a7c8fb-ec73-4f7d-9e64-3eccdded6ac6	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-04-28 20:14:57.735878+00	
00000000-0000-0000-0000-000000000000	72263143-f84d-4ab5-98ef-42919e429691	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-04-28 20:16:37.341813+00	
00000000-0000-0000-0000-000000000000	a7f1a313-a354-4db6-b6ae-04a4626ceae3	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"nguyenphuctran@csus.edu","user_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","user_phone":""}}	2025-04-28 20:16:57.426622+00	
00000000-0000-0000-0000-000000000000	a097f323-56f6-4014-a49e-25d7052cf09f	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 20:17:07.854839+00	
00000000-0000-0000-0000-000000000000	13585556-8c8e-4f3a-9aa8-871327d71775	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 20:17:07.955671+00	
00000000-0000-0000-0000-000000000000	c70a8a06-83b7-4f31-9f8d-bab9c4983979	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 20:17:07.956881+00	
00000000-0000-0000-0000-000000000000	cc3d5347-dad1-4cc6-958d-521fd04ec4e1	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 20:20:20.166136+00	
00000000-0000-0000-0000-000000000000	652f2fec-6378-4f25-8f29-1e152a405b4c	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 20:20:20.30045+00	
00000000-0000-0000-0000-000000000000	ded223f3-78ff-411f-b12b-7e2a69792ee7	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 20:20:20.301066+00	
00000000-0000-0000-0000-000000000000	1a927f56-8f4e-484a-8818-ef82ae2349c0	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 20:23:03.702579+00	
00000000-0000-0000-0000-000000000000	7daa00ae-5edf-4b1e-a9a6-69853df3daa6	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 20:23:03.836844+00	
00000000-0000-0000-0000-000000000000	ed61bda0-c3ba-4758-ac01-e021d03b4f5b	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 20:23:03.837478+00	
00000000-0000-0000-0000-000000000000	312833c4-adcd-4fb4-8bc5-37a6081cb7be	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 20:50:32.862868+00	
00000000-0000-0000-0000-000000000000	4d64a901-26dc-46c0-aef0-4e1b6990bc01	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 20:50:32.998512+00	
00000000-0000-0000-0000-000000000000	3742febc-d046-418c-bf50-b86fbce179a9	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 20:50:32.9992+00	
00000000-0000-0000-0000-000000000000	3030aaeb-3042-4994-8439-ce08e331017f	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 20:55:04.651936+00	
00000000-0000-0000-0000-000000000000	95ed39f5-ed97-461d-9fbb-b24fcf628a84	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 20:55:04.768117+00	
00000000-0000-0000-0000-000000000000	043c3a4f-b09a-48c3-bed5-fcd6c6b6cb95	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 20:55:04.768733+00	
00000000-0000-0000-0000-000000000000	369d69ce-a3e9-46bd-bb6c-96f264b863bf	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 20:58:20.074803+00	
00000000-0000-0000-0000-000000000000	f0198756-062d-4eed-bed2-c953b005d218	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 20:58:20.216503+00	
00000000-0000-0000-0000-000000000000	844e94ce-46bd-4534-be9a-02c924fd18c9	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 20:58:20.218081+00	
00000000-0000-0000-0000-000000000000	fc0a2f88-eab0-4980-b97a-f1ebdccf1f25	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 21:23:44.501239+00	
00000000-0000-0000-0000-000000000000	00a57e8c-0a89-4dc7-8b81-742a03312410	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 21:24:56.185764+00	
00000000-0000-0000-0000-000000000000	b9a79034-6e7a-4d25-8a91-84e68938589c	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 21:26:17.015381+00	
00000000-0000-0000-0000-000000000000	afb52a3e-611d-4608-83b4-1d05834ed50a	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 21:26:17.147184+00	
00000000-0000-0000-0000-000000000000	000ef6e1-87f0-4dfd-9839-aa6784ff5ecc	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 21:26:17.147811+00	
00000000-0000-0000-0000-000000000000	2fd11c21-44ea-4cea-84de-494c7c402163	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 21:28:13.525807+00	
00000000-0000-0000-0000-000000000000	af43e891-2f84-442d-abe7-470a4353001d	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 21:28:13.654503+00	
00000000-0000-0000-0000-000000000000	7cf276c7-9de8-421a-a0c9-0b631cb94b7d	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 21:28:13.655151+00	
00000000-0000-0000-0000-000000000000	a492c204-ef69-4687-be2e-1775179e1e61	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 21:29:01.900909+00	
00000000-0000-0000-0000-000000000000	f9341d2f-fa57-41ec-b3de-3a78e78efdbc	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 21:29:01.904193+00	
00000000-0000-0000-0000-000000000000	87211132-8fad-434e-b8bd-111cc2c8b92c	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 21:29:24.803845+00	
00000000-0000-0000-0000-000000000000	47be8ff5-eeea-4e07-accf-197996fa3e5c	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 21:29:24.890186+00	
00000000-0000-0000-0000-000000000000	f2b9393c-1226-4ae2-9885-7716872624df	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 21:29:24.891513+00	
00000000-0000-0000-0000-000000000000	27087b09-f241-43af-aaed-c685d23b6fac	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 21:31:08.561241+00	
00000000-0000-0000-0000-000000000000	e9ca8352-5eb1-49d6-9c49-20379de911a8	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 21:31:08.695159+00	
00000000-0000-0000-0000-000000000000	fb974836-d033-4ae6-b19b-bb8ffd641b73	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-04-28 21:31:08.695797+00	
00000000-0000-0000-0000-000000000000	0bc65c22-09e0-4b85-abaf-82af0fbe54b9	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 21:31:38.603973+00	
00000000-0000-0000-0000-000000000000	930e45bd-22b2-43a6-b4f2-0aad615f732c	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-04-28 21:39:42.888928+00	
00000000-0000-0000-0000-000000000000	8ca617d4-e716-4122-904a-fd4007837eda	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-05-02 20:34:43.071192+00	
00000000-0000-0000-0000-000000000000	b00097c7-accc-49e1-bc1a-afcf6a32fd8b	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-05-02 20:34:43.81522+00	
00000000-0000-0000-0000-000000000000	0a10699f-3553-403b-809e-86e9ab61cdab	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-05-02 20:34:43.818513+00	
00000000-0000-0000-0000-000000000000	48bbc50f-354b-425b-a635-70ee82655e85	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-05-02 20:34:43.872343+00	
00000000-0000-0000-0000-000000000000	1604ac84-4f34-4e11-bbd1-8d0e332b7c69	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-05-02 20:34:49.281807+00	
00000000-0000-0000-0000-000000000000	3394534c-b5c2-4eeb-9a9a-cac4127b2ba6	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-05-02 20:34:49.284565+00	
00000000-0000-0000-0000-000000000000	0e7b5921-a166-4c28-8b00-59d92062b987	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-05-02 20:34:50.847769+00	
00000000-0000-0000-0000-000000000000	36a3ce8f-672f-4996-8da0-76f0a3df5c69	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-05-02 20:34:50.848421+00	
00000000-0000-0000-0000-000000000000	2b8cfcea-1f24-4caa-968d-2a7e0e556823	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-05-02 20:35:03.276749+00	
00000000-0000-0000-0000-000000000000	126defec-b9ac-41eb-b2b1-20942c5abc49	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-05-03 17:06:42.152859+00	
00000000-0000-0000-0000-000000000000	b3cfc63b-71a0-4d63-adae-4f40a9f4cd1f	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-05-03 17:14:47.701786+00	
00000000-0000-0000-0000-000000000000	9b182b24-2b57-42cb-9a60-a84f41469c64	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-05-03 17:15:08.365369+00	
00000000-0000-0000-0000-000000000000	3c6d35b4-d9bd-400c-87e1-b23d1dfa567a	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-05-03 18:41:17.737266+00	
00000000-0000-0000-0000-000000000000	8a4d27cc-a42a-46ce-a758-36ac106bcfd9	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-05-03 18:43:28.108565+00	
00000000-0000-0000-0000-000000000000	2e4707ad-55ad-4114-9665-a80b6acc6945	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-05-03 18:50:27.668263+00	
00000000-0000-0000-0000-000000000000	ce0732a3-55be-496c-ba93-5acbc6230adf	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-05-03 18:51:02.544124+00	
00000000-0000-0000-0000-000000000000	884de4f7-36bd-40cd-9b18-75c854e7a7b4	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"nguyenphuctran@csus.edu","user_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","user_phone":""}}	2025-05-03 18:51:10.968384+00	
00000000-0000-0000-0000-000000000000	672d57fc-cb68-4850-a6de-1d83a8630ae2	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-05-03 18:51:25.426708+00	
00000000-0000-0000-0000-000000000000	549f1547-fb52-4b32-b3ab-1f469ef8bb1e	{"action":"user_recovery_requested","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-05-03 20:32:47.89576+00	
00000000-0000-0000-0000-000000000000	ab2925ea-1afb-466f-9d6e-1157109dc4d0	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-05-03 20:33:14.363912+00	
00000000-0000-0000-0000-000000000000	c83dd4c4-fa11-4032-be13-3fa9f40727da	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"nguyenphuctran@csus.edu","user_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","user_phone":""}}	2025-05-03 20:35:46.24979+00	
00000000-0000-0000-0000-000000000000	034bf652-6c87-462f-9442-61b1e5b37642	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-05-03 20:36:11.816277+00	
00000000-0000-0000-0000-000000000000	a200992b-0d14-4568-ad71-f9fae0aafd7b	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-05-03 20:39:39.015291+00	
00000000-0000-0000-0000-000000000000	22188d14-2afc-44b2-8b72-62d73d5bb4e0	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-05-03 20:39:39.016135+00	
00000000-0000-0000-0000-000000000000	2ce76e17-afc3-4737-88e1-660bc0e0d9f0	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-05-03 20:40:18.836304+00	
00000000-0000-0000-0000-000000000000	67adc581-b2a3-4c0f-ac61-2a92c64a0901	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"phernandez4@csus.edu","user_id":"9bf190a8-b79d-4058-a1cf-7ecad112b66e","user_phone":""}}	2025-05-03 20:40:55.207299+00	
00000000-0000-0000-0000-000000000000	b47729ab-458d-4863-9fbd-5825d981ba69	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"phernandez4@csus.edu","user_id":"c96981e5-0436-43d2-b096-79dc929f0fb5","user_phone":""}}	2025-05-03 20:41:08.588183+00	
00000000-0000-0000-0000-000000000000	e283d53b-f2b2-4e1c-b90e-5d909607243a	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-05-03 20:41:27.112882+00	
00000000-0000-0000-0000-000000000000	0bbfe263-3728-4d70-96c0-840b8b54caa2	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-05-03 20:42:27.105439+00	
00000000-0000-0000-0000-000000000000	c4569d05-5aaf-499b-ab2c-552da6323137	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-03 20:42:30.607124+00	
00000000-0000-0000-0000-000000000000	b5856612-fe86-4b4a-a397-71e964a1f39f	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-03 20:42:30.610363+00	
00000000-0000-0000-0000-000000000000	f40d7810-1124-44b4-8c0a-baaf40805939	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-03 20:42:30.634379+00	
00000000-0000-0000-0000-000000000000	0ab3c527-cbb4-441e-9291-71aece9e22ed	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-03 20:59:46.062231+00	
00000000-0000-0000-0000-000000000000	fd92193f-fff9-4e13-a29f-d5edb11616d1	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-03 20:59:46.065088+00	
00000000-0000-0000-0000-000000000000	a1aab2f5-228a-45bb-8c36-3d44cc49a6aa	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-03 20:59:46.082648+00	
00000000-0000-0000-0000-000000000000	46035fdb-d9d5-4459-b143-464b03b1c293	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-05-03 21:00:50.445636+00	
00000000-0000-0000-0000-000000000000	5f48d149-35ec-4871-8da2-7f3b0bc8a8f5	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-05-03 21:03:12.110731+00	
00000000-0000-0000-0000-000000000000	f16c5e63-8288-43c3-ab77-b73b30472ba0	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-03 21:05:28.800254+00	
00000000-0000-0000-0000-000000000000	5bcbd5b9-21ba-41a0-80d7-a1e96f038ffa	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-03 21:05:28.801746+00	
00000000-0000-0000-0000-000000000000	978c9927-488e-4321-8fc1-47bdfb6d8c21	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-03 21:06:36.074076+00	
00000000-0000-0000-0000-000000000000	447c312b-3d4d-4fd3-80f3-3a1389b03c05	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-03 21:06:36.076188+00	
00000000-0000-0000-0000-000000000000	54cafdd1-eb3a-4448-bcbf-9738a1814353	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-03 21:13:16.155315+00	
00000000-0000-0000-0000-000000000000	3abfb32b-8d73-4294-962f-4c7f291cbed3	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-03 21:13:16.158094+00	
00000000-0000-0000-0000-000000000000	7c8c5484-f18e-49a5-b631-db42ea3345d6	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-03 21:13:16.177563+00	
00000000-0000-0000-0000-000000000000	8ef74efc-67c1-43af-8039-157110b0e5b8	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-05-04 00:27:25.865017+00	
00000000-0000-0000-0000-000000000000	ca175cd8-5221-4533-8585-913341e060b9	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-05-04 01:27:16.341456+00	
00000000-0000-0000-0000-000000000000	844e9e26-9536-4fe1-b6b9-d8c6404a042a	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-05-04 01:27:16.349118+00	
00000000-0000-0000-0000-000000000000	c2994970-6d35-47f4-baba-29a05254aaf1	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-05-04 01:27:16.426482+00	
00000000-0000-0000-0000-000000000000	1bbad0ce-abe6-4991-b386-323704509ec0	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-05-04 01:27:16.427075+00	
00000000-0000-0000-0000-000000000000	ed7cabdb-36bb-4da6-810b-72ff3e95b98e	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-05-04 01:33:38.425174+00	
00000000-0000-0000-0000-000000000000	24051486-9c08-4ba9-97e5-bb70f42c8c4f	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-05-08 17:31:22.756288+00	
00000000-0000-0000-0000-000000000000	d3c65d57-ae31-4e91-8b37-f2bc9ebb2244	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-08 17:32:35.600042+00	
00000000-0000-0000-0000-000000000000	8c9c42b6-defe-4a62-8d1b-8aa33bac05b9	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-08 17:32:35.607233+00	
00000000-0000-0000-0000-000000000000	c70e6403-c1e2-4ed9-b577-eef5176da3ae	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-08 17:32:35.647405+00	
00000000-0000-0000-0000-000000000000	8d472a6a-b529-4c89-a8b2-7daaf208ba51	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-08 17:33:51.509303+00	
00000000-0000-0000-0000-000000000000	67b4a2e3-c2c3-424d-b170-b96e6ec0955f	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-08 17:33:51.5111+00	
00000000-0000-0000-0000-000000000000	da7f000e-e6b6-410a-868a-3370a491f671	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-05-08 17:33:51.536836+00	
00000000-0000-0000-0000-000000000000	a9e72a5b-dda0-4ff5-a527-8d110445bcc0	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-07-26 00:39:46.929856+00	
00000000-0000-0000-0000-000000000000	3964d036-78f0-45ff-8960-db398ce306aa	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-07-26 00:39:59.717444+00	
00000000-0000-0000-0000-000000000000	d932aedb-5ad2-41e4-81da-31c3c0815843	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-07-26 00:39:59.718046+00	
00000000-0000-0000-0000-000000000000	f6e2f134-591f-4ca0-85a1-09be1e0f91d9	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-07-26 00:39:59.730747+00	
00000000-0000-0000-0000-000000000000	0873cf46-ddc2-4937-a766-172e1af8f5fc	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-08-29 16:38:41.913684+00	
00000000-0000-0000-0000-000000000000	a7786c98-e1da-45a8-ba7d-2b48ff79fa48	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 16:39:12.549464+00	
00000000-0000-0000-0000-000000000000	088c6210-10f3-4883-bb13-2299b9448e6b	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 16:39:12.552907+00	
00000000-0000-0000-0000-000000000000	3692850c-f6bc-40bc-8066-0c76999db585	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 16:39:12.57885+00	
00000000-0000-0000-0000-000000000000	375b08ea-032b-47f6-8e68-79ed9dd34a0b	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 16:39:33.422473+00	
00000000-0000-0000-0000-000000000000	8a57fd9b-dc8d-4443-9cca-7f9a5aa06392	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 16:39:33.42823+00	
00000000-0000-0000-0000-000000000000	93512608-ca56-4c14-b017-611a9c5062a9	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 16:39:33.471561+00	
00000000-0000-0000-0000-000000000000	0519ec3d-f2c7-4918-b1dc-0a8889d020d7	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 16:40:12.563351+00	
00000000-0000-0000-0000-000000000000	e19123f4-8dea-43be-843b-f21263727617	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 16:40:12.564794+00	
00000000-0000-0000-0000-000000000000	90b0123d-5281-40f0-8465-095df557c482	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 16:40:12.594802+00	
00000000-0000-0000-0000-000000000000	7f76d3f2-c5b2-46a1-be28-48aa5af856b8	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 16:40:14.648423+00	
00000000-0000-0000-0000-000000000000	0c96a21b-4c20-4667-906d-ad27a5d50c37	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 16:40:14.649453+00	
00000000-0000-0000-0000-000000000000	21d13f5a-403b-4ba6-b5f4-eeb347bd52b2	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 16:40:14.689462+00	
00000000-0000-0000-0000-000000000000	15bce7fd-1e11-43fc-b9d6-7ee22cb70b37	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 16:40:20.457162+00	
00000000-0000-0000-0000-000000000000	9d2c7655-548a-41aa-98b6-0a06001efb5d	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 16:40:20.458771+00	
00000000-0000-0000-0000-000000000000	8c306624-5620-40cf-bcb3-f020d6b996ce	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 16:40:20.505285+00	
00000000-0000-0000-0000-000000000000	55ca23a2-daec-4288-b5bd-175b2dec491e	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 02:57:31.579848+00	
00000000-0000-0000-0000-000000000000	d21a0cbf-4a1b-4c99-ba55-cb2c29a8c8d9	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 03:00:22.14272+00	
00000000-0000-0000-0000-000000000000	f142b486-699e-4f1d-b9a0-fa5f24765f23	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 03:00:24.783312+00	
00000000-0000-0000-0000-000000000000	4b54ea13-885c-4e81-8b79-74b94a6f7e89	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 03:00:24.786331+00	
00000000-0000-0000-0000-000000000000	17bc5c89-2eb0-4086-abc8-d64dd583195e	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 03:00:24.822796+00	
00000000-0000-0000-0000-000000000000	0c9ecb1a-7818-4ae1-a2a8-6373cc0c25d1	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 03:05:49.775405+00	
00000000-0000-0000-0000-000000000000	8fe77b2a-377b-4491-8865-9840a3c7b7cb	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 03:05:49.785381+00	
00000000-0000-0000-0000-000000000000	7130086f-5153-452c-8b28-66b453316e9f	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 03:10:05.552708+00	
00000000-0000-0000-0000-000000000000	44901921-5cbf-4943-ad7c-b461693922e8	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 03:10:05.553644+00	
00000000-0000-0000-0000-000000000000	9d1f9ec0-00c3-4dcf-aaf9-02594411fea7	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 03:16:14.546865+00	
00000000-0000-0000-0000-000000000000	959554d9-a7dd-4152-ac96-9e66cd80c8aa	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 03:26:35.846023+00	
00000000-0000-0000-0000-000000000000	2f1ca9ff-9311-4847-9c34-d3eb712eb3a8	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 03:28:55.547455+00	
00000000-0000-0000-0000-000000000000	643c3cac-5960-40b8-b687-b60950cf6590	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 03:30:53.68043+00	
00000000-0000-0000-0000-000000000000	a0c98c72-1b44-4015-9593-3beb8412df28	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 03:33:00.076462+00	
00000000-0000-0000-0000-000000000000	dacfc505-b3df-4f52-a20d-d1102301a06e	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 04:32:50.829174+00	
00000000-0000-0000-0000-000000000000	6d47df08-3dbe-4e59-aaa3-39136ce0a8c9	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 04:32:50.843548+00	
00000000-0000-0000-0000-000000000000	01d50727-fb58-4af4-b2d1-0a4f0ce42701	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 04:32:50.985726+00	
00000000-0000-0000-0000-000000000000	f006fd4c-00e6-4e59-8c37-d1f703d2880d	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 04:32:50.987691+00	
00000000-0000-0000-0000-000000000000	9a22fc21-f4cb-490c-9ace-aa327c0adcf3	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 04:42:44.113551+00	
00000000-0000-0000-0000-000000000000	dbf33cb1-b6a9-45bd-a0c9-63ce08c1768d	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 04:42:44.122554+00	
00000000-0000-0000-0000-000000000000	52c8c0e3-2bb5-4330-922d-092c749cb0c9	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 04:42:48.0913+00	
00000000-0000-0000-0000-000000000000	558d0e82-90c9-495b-8c99-8848b1045d1f	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 04:42:48.095516+00	
00000000-0000-0000-0000-000000000000	a00359d2-f3f5-4b94-9641-de0f3aa6b35e	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 04:42:48.223172+00	
00000000-0000-0000-0000-000000000000	190645f1-8d0e-4f90-a53b-ddc58afa8dbd	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 04:42:48.225895+00	
00000000-0000-0000-0000-000000000000	85da7f45-7747-4efb-ac6c-50a63554310a	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 04:42:48.2947+00	
00000000-0000-0000-0000-000000000000	f814dda9-6795-4944-8add-0d5467e024f4	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-04 04:42:48.295537+00	
00000000-0000-0000-0000-000000000000	c03c927c-4ca5-4f9d-8ab4-628172534642	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 04:43:28.416888+00	
00000000-0000-0000-0000-000000000000	98fd4be3-4ce4-4f9d-bc24-951019d762d8	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 06:52:45.952544+00	
00000000-0000-0000-0000-000000000000	4dfeaa89-f247-47c7-a813-b2d0eca8244a	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-04 07:47:19.559724+00	
00000000-0000-0000-0000-000000000000	a9c24c74-2080-4344-8659-91ba5173dc16	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-05 00:00:28.695977+00	
00000000-0000-0000-0000-000000000000	dbfec6e8-2025-401b-aa16-ed41d4f8833a	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-05 01:00:19.587232+00	
00000000-0000-0000-0000-000000000000	6c5958fe-a62c-4dfe-b0ad-ee094d1db518	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-05 01:00:19.606692+00	
00000000-0000-0000-0000-000000000000	d5528d62-ed0d-4941-992d-75c41317ce08	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-05 01:00:19.761576+00	
00000000-0000-0000-0000-000000000000	65e6aa1f-8a3d-4395-b69c-5fda466e03f4	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-05 01:00:19.76231+00	
00000000-0000-0000-0000-000000000000	4645831b-1db4-400c-b61c-b7064bc04057	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-05 01:16:22.712817+00	
00000000-0000-0000-0000-000000000000	a417d54f-42d6-410e-9105-fe557245f0f7	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-05 05:26:17.127352+00	
00000000-0000-0000-0000-000000000000	a0eb03c9-155e-43a5-99cf-e5f87ea79526	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-05 06:26:07.960193+00	
00000000-0000-0000-0000-000000000000	f473ffb8-61aa-42cf-86eb-d8347d7d1735	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-05 06:26:07.97919+00	
00000000-0000-0000-0000-000000000000	d655d389-c9e8-479c-bd72-f0e849cf531a	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-05 06:26:08.147724+00	
00000000-0000-0000-0000-000000000000	fba95164-3fdf-4273-986e-a18bc93472e1	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-05 06:26:08.148469+00	
00000000-0000-0000-0000-000000000000	ff90a2dd-c594-4624-ae1c-8b5e89babd84	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-05 06:41:54.1064+00	
00000000-0000-0000-0000-000000000000	359a65c1-85cc-4f3e-87e6-0536d7398ce5	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 06:51:29.081011+00	
00000000-0000-0000-0000-000000000000	9094efca-6cba-4184-96e6-cfa62cb79542	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 06:51:43.988347+00	
00000000-0000-0000-0000-000000000000	37e06c38-f395-4835-9ebe-bf6daea8efee	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 06:51:43.993574+00	
00000000-0000-0000-0000-000000000000	43b94948-2d8c-42e9-8c8f-b916f887d9fd	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 06:51:44.252547+00	
00000000-0000-0000-0000-000000000000	9d789414-2040-470e-a520-9b2fb8c11b65	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 06:51:44.254003+00	
00000000-0000-0000-0000-000000000000	51ad94af-ec8a-4391-8ccd-1450cbd6ea73	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 06:51:50.777612+00	
00000000-0000-0000-0000-000000000000	1ce3d7c1-297f-4c11-8657-725a62afbb81	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 06:51:50.780865+00	
00000000-0000-0000-0000-000000000000	b2019df8-30c4-467a-b66d-49e217c6905f	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 06:51:50.896069+00	
00000000-0000-0000-0000-000000000000	aa15466c-343a-4ba8-92d8-2c88da62bdcb	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 06:51:50.896816+00	
00000000-0000-0000-0000-000000000000	f5588baf-8f12-4db2-96c2-964d4af74e81	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 07:21:03.7196+00	
00000000-0000-0000-0000-000000000000	16455395-775b-4ebd-8aa8-4a770c2684e7	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 07:21:03.7468+00	
00000000-0000-0000-0000-000000000000	d24e9dec-a705-4289-8b33-45b760c6a602	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 07:21:03.91896+00	
00000000-0000-0000-0000-000000000000	9647c334-ecdb-48f9-a10d-a2a48423ae5e	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 07:21:03.922668+00	
00000000-0000-0000-0000-000000000000	abfc2bf7-d434-46f2-b4a3-6fe490c71189	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 07:21:35.773019+00	
00000000-0000-0000-0000-000000000000	b707aee4-29a1-46a7-8083-78df0a887595	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 07:21:35.776904+00	
00000000-0000-0000-0000-000000000000	b0533613-e813-4437-b2cc-927e9ecae2ca	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 07:21:35.8483+00	
00000000-0000-0000-0000-000000000000	9f00c69c-312e-4f50-baac-cf30f01b53dc	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 07:21:35.849148+00	
00000000-0000-0000-0000-000000000000	6f65ad62-24d6-4485-a093-ff1d82859164	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 07:22:23.211733+00	
00000000-0000-0000-0000-000000000000	6f7eba53-d125-45a6-aad2-31b36993e5da	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 07:22:23.212587+00	
00000000-0000-0000-0000-000000000000	d23e0a93-a7bf-456d-a73f-62041a68e28e	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 07:22:23.289543+00	
00000000-0000-0000-0000-000000000000	3ada5fa6-8d07-4d8e-829e-d5dd00b12a1b	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 07:22:23.290317+00	
00000000-0000-0000-0000-000000000000	dd324121-75f3-4d93-8213-705dfb632751	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 08:12:53.777547+00	
00000000-0000-0000-0000-000000000000	6c2874db-66e2-40a4-bb89-d44048c70711	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 23:43:39.845159+00	
00000000-0000-0000-0000-000000000000	a4bba810-8ea5-4a69-ba0c-13c3bada95ad	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 08:16:15.014054+00	
00000000-0000-0000-0000-000000000000	24964736-c153-4945-a888-a1917d4f64b5	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 01:43:19.499942+00	
00000000-0000-0000-0000-000000000000	f8892d4e-357c-4c76-85fc-9bcb333bc010	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 01:43:19.516012+00	
00000000-0000-0000-0000-000000000000	75617485-2102-4ace-80fe-daacc09907e8	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 08:17:48.441436+00	
00000000-0000-0000-0000-000000000000	bf93668c-36c2-4962-8956-99de0f65eab7	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 08:22:28.947741+00	
00000000-0000-0000-0000-000000000000	db431328-0c5a-42f5-9a9f-cb6d933f8a1c	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 08:31:59.385175+00	
00000000-0000-0000-0000-000000000000	d1823d5b-736a-48bb-9e2a-5c76bea59252	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 09:31:51.376467+00	
00000000-0000-0000-0000-000000000000	bfb73a0b-50c3-49d3-aa95-42323b8cf915	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 09:31:51.401689+00	
00000000-0000-0000-0000-000000000000	d2481269-5a27-4b9d-aacc-d949c9842884	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 09:31:51.564843+00	
00000000-0000-0000-0000-000000000000	6846c6cb-9e50-4119-a930-718610208308	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 09:31:51.56689+00	
00000000-0000-0000-0000-000000000000	e7d1158d-859c-40d9-9c06-1713fcc0120b	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 10:29:04.773388+00	
00000000-0000-0000-0000-000000000000	2e58ac1b-c321-4d1c-b463-4eea1a3a8c79	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 01:43:19.794621+00	
00000000-0000-0000-0000-000000000000	0a24ef9a-7741-41b9-a041-743aba91e22a	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 10:34:54.737353+00	
00000000-0000-0000-0000-000000000000	ad12d175-bd31-4ec7-9968-09428e383189	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 10:35:01.224284+00	
00000000-0000-0000-0000-000000000000	b90294c2-58bc-443c-93a9-0ce5b70e8391	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 10:39:15.580942+00	
00000000-0000-0000-0000-000000000000	0d37e4ff-4621-46a2-a373-c445aed224f0	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 10:43:58.833903+00	
00000000-0000-0000-0000-000000000000	8ea49095-5d74-4d17-a591-3d6b608d67c1	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 10:47:16.583336+00	
00000000-0000-0000-0000-000000000000	fe68c6b9-94ff-42be-9d0a-432d188a4f2c	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 10:53:35.377447+00	
00000000-0000-0000-0000-000000000000	5c59ff3b-7fbb-4bf7-83bf-2254b710c7d3	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 10:56:10.195547+00	
00000000-0000-0000-0000-000000000000	0d13c2d1-74f0-4673-987b-091f84e945f6	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 11:02:19.956859+00	
00000000-0000-0000-0000-000000000000	6df5dfa1-18a2-4929-8f5a-b933eeeb1c56	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 11:03:06.857396+00	
00000000-0000-0000-0000-000000000000	72e7ed09-91cf-4b10-ad16-abc501e9f93f	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 11:05:53.223671+00	
00000000-0000-0000-0000-000000000000	f6a3405c-1410-4da0-93cc-d22bc4699dfe	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 11:08:15.275254+00	
00000000-0000-0000-0000-000000000000	2701a1d7-e49a-4c68-933c-258e0a787a99	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 11:21:23.490171+00	
00000000-0000-0000-0000-000000000000	d44a9c7f-15f2-4ae7-b3a1-d4ecaa0b06fe	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 11:21:23.494891+00	
00000000-0000-0000-0000-000000000000	ca403fbf-b319-4184-8314-f652acd3b743	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 11:21:31.856171+00	
00000000-0000-0000-0000-000000000000	82c58684-2e9c-4eb3-93e5-b6d215f7a8f1	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 11:47:42.157572+00	
00000000-0000-0000-0000-000000000000	aaea9ccd-90eb-4d02-8938-c9ce0253b677	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 11:51:04.056141+00	
00000000-0000-0000-0000-000000000000	a6d8ed75-8a37-4254-bbfd-eeff2fdb4748	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:05:53.222819+00	
00000000-0000-0000-0000-000000000000	446ac4ec-79b9-4f63-931f-d118aa92eff0	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:05:53.242719+00	
00000000-0000-0000-0000-000000000000	f6a7021d-a567-45ac-889a-3be86bb50fc2	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:05:53.291652+00	
00000000-0000-0000-0000-000000000000	14817077-25e3-4ab0-a238-175c61b717a6	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:05:54.09605+00	
00000000-0000-0000-0000-000000000000	bf2ba9b5-caa4-4412-8a4f-9393f1245e8a	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:05:54.097613+00	
00000000-0000-0000-0000-000000000000	8db9f326-2bfe-4a28-aecd-04dbad57d27e	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:05:54.122656+00	
00000000-0000-0000-0000-000000000000	d6d884c6-1a9d-4dbb-9c8e-1afd240c4c73	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:05:54.151478+00	
00000000-0000-0000-0000-000000000000	b72862a3-7f62-4be7-9a20-167f903705e1	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:05:54.203843+00	
00000000-0000-0000-0000-000000000000	ddead91b-0c3c-41d4-9a5e-26f384e9c47d	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:10:23.795186+00	
00000000-0000-0000-0000-000000000000	b1c2474f-5cb9-48fe-a9b3-e99ac4f9f094	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:10:23.796764+00	
00000000-0000-0000-0000-000000000000	dd152fb9-0717-4823-bbbe-19b2bec8ad89	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:10:23.810525+00	
00000000-0000-0000-0000-000000000000	48db1361-787b-4b6d-98ac-4eaa5f3e4ddb	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:10:23.827596+00	
00000000-0000-0000-0000-000000000000	4d9f45b5-df5d-47e9-955f-1355871fa0ee	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:10:27.818588+00	
00000000-0000-0000-0000-000000000000	76d48027-8cbb-4591-b1e1-54f1bff20eb2	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:10:27.821013+00	
00000000-0000-0000-0000-000000000000	b775bdce-9e45-458b-9b86-99c983f3b22c	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:10:27.853294+00	
00000000-0000-0000-0000-000000000000	6a5a8227-ce82-4a47-aab1-345ad348ebc2	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:10:32.429231+00	
00000000-0000-0000-0000-000000000000	cf134f34-ebda-40ac-808d-de09ec612c07	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:10:32.430414+00	
00000000-0000-0000-0000-000000000000	c4a79004-011d-43e4-ad51-a37312944d2d	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:10:32.450048+00	
00000000-0000-0000-0000-000000000000	024017d3-0698-42aa-808e-6f92a3b82cc5	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:10:49.151506+00	
00000000-0000-0000-0000-000000000000	c6309345-8b45-40ac-b39f-49c56a34cfe3	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:10:49.153149+00	
00000000-0000-0000-0000-000000000000	a1714042-c6c1-45be-9e6f-132a9ae96940	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 12:10:49.170508+00	
00000000-0000-0000-0000-000000000000	56c8c475-93f3-46f6-a2cc-0fc2e2c25f53	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 18:01:43.56025+00	
00000000-0000-0000-0000-000000000000	d9d9417b-ed0d-4593-b65c-78e7c724680a	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 18:01:43.596597+00	
00000000-0000-0000-0000-000000000000	7f5ba365-0913-4614-aaa2-c833f6605ada	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 18:01:43.613028+00	
00000000-0000-0000-0000-000000000000	d6fe9fca-6c6f-4c1f-87dc-88badc336283	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 18:13:14.93019+00	
00000000-0000-0000-0000-000000000000	8aa32bde-e927-4656-ab98-6cda4bd453fb	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 19:01:28.932188+00	
00000000-0000-0000-0000-000000000000	7af851a9-62f0-41e0-b857-be7277681565	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-13 02:59:17.096514+00	
00000000-0000-0000-0000-000000000000	e16fa028-ddf5-44ad-b164-043c61da624a	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-13 03:49:21.939977+00	
00000000-0000-0000-0000-000000000000	deb8e1c0-7b76-4a43-82c5-7ce853abc6c3	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-13 03:49:21.958345+00	
00000000-0000-0000-0000-000000000000	60fc7e4a-8dc0-4f56-90c9-3ff840461ba1	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-13 05:15:02.17371+00	
00000000-0000-0000-0000-000000000000	2ffdf439-01b7-4ec5-b846-36ab5eb30771	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-13 05:15:41.232373+00	
00000000-0000-0000-0000-000000000000	f3b30cf1-2cc4-4264-81e8-27d2758130d6	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-13 06:19:37.255609+00	
00000000-0000-0000-0000-000000000000	c7fa9f6e-b20e-4813-9113-d12dc13cc8e8	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-13 06:19:37.283286+00	
00000000-0000-0000-0000-000000000000	4824ac29-7eed-4e04-a6f0-baf537eff200	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-13 08:33:49.505527+00	
00000000-0000-0000-0000-000000000000	06e92064-b0a7-455d-aee8-93e1ec0f68a8	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-13 21:26:34.982014+00	
00000000-0000-0000-0000-000000000000	08d1eb88-aebc-4fcf-a1a8-6c68da53f196	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-13 22:26:25.899088+00	
00000000-0000-0000-0000-000000000000	3f7863e6-de43-4fd7-bf07-869ae1c445b6	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-13 22:26:25.916181+00	
00000000-0000-0000-0000-000000000000	ad1c8952-9867-4552-aa80-bd53b0c86441	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-13 22:26:26.062171+00	
00000000-0000-0000-0000-000000000000	bb690568-a14d-4f04-8ef3-80d118767751	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-13 22:26:26.065924+00	
00000000-0000-0000-0000-000000000000	36f0af45-faf2-42b4-9f99-79dffc7fc5e5	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-14 06:06:15.614541+00	
00000000-0000-0000-0000-000000000000	c6c23b60-0172-4e24-9fb9-720395884658	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-14 06:47:42.189793+00	
00000000-0000-0000-0000-000000000000	616326b8-676a-48fb-8638-5c3370bdc7a5	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-14 07:11:23.263738+00	
00000000-0000-0000-0000-000000000000	06e01c6e-b5c6-4e7b-98aa-be1858da585b	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:06:33.918784+00	
00000000-0000-0000-0000-000000000000	0372018a-4384-4eaa-9431-452e41cb1f5f	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:06:33.933337+00	
00000000-0000-0000-0000-000000000000	4a6e7a1d-871c-4460-a5cd-c8b61193f66a	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:06:33.964274+00	
00000000-0000-0000-0000-000000000000	0173d789-8394-49ee-bc08-38fa343b6f73	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:06:33.972563+00	
00000000-0000-0000-0000-000000000000	dd669fcc-67b8-4bde-9369-e6634eefaa99	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:06:33.981555+00	
00000000-0000-0000-0000-000000000000	b3f58b38-d3c2-4782-8732-78aee90242e0	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:06:33.991732+00	
00000000-0000-0000-0000-000000000000	5e45159a-0b2b-4a2a-afa2-f2446c9be3c5	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:06:34.761707+00	
00000000-0000-0000-0000-000000000000	3befd39d-ebc1-4e1b-b5de-b713a8ef36b3	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:06:34.762838+00	
00000000-0000-0000-0000-000000000000	6095be8e-dae6-4ec5-b5e8-52c8aebe00c7	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:06:34.782724+00	
00000000-0000-0000-0000-000000000000	1c788b89-3f08-49ae-9eeb-aa1cb36c4555	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:06:34.812445+00	
00000000-0000-0000-0000-000000000000	56b503e3-af4b-4ce2-b626-bec29de7560b	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:06:34.824399+00	
00000000-0000-0000-0000-000000000000	49f4ffb5-57fe-4ad7-96e7-c3899f74f7d4	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:06:36.624733+00	
00000000-0000-0000-0000-000000000000	15e90c1b-7185-42ae-978f-d10d2057e32a	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:06:36.625475+00	
00000000-0000-0000-0000-000000000000	3b7ee797-3490-4ef4-bf06-72f2125745fb	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:06:36.64082+00	
00000000-0000-0000-0000-000000000000	8bf67e20-9cd9-45fa-afb2-967a53951ee3	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 08:06:36.669102+00	
00000000-0000-0000-0000-000000000000	054d9ede-c077-40c0-b22d-065400454efd	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-14 08:24:25.738001+00	
00000000-0000-0000-0000-000000000000	e5e6e817-3824-4041-958a-3c0b9a5ecea5	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 09:01:38.295736+00	
00000000-0000-0000-0000-000000000000	e23ce04a-b0ad-4497-bcd0-d9e3441dcef7	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 09:01:38.317341+00	
00000000-0000-0000-0000-000000000000	0f76f371-04fa-4dbb-a5f6-394292602ac0	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 09:01:38.39491+00	
00000000-0000-0000-0000-000000000000	64bc5191-cf62-47e4-81a1-b94588ef65be	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 09:01:56.343753+00	
00000000-0000-0000-0000-000000000000	facdd95c-b1c3-4ba0-b76f-8dc43ec71bee	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 09:01:56.345563+00	
00000000-0000-0000-0000-000000000000	7800a4c1-bf1d-4581-ae5f-52c46049f4eb	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 09:01:56.400271+00	
00000000-0000-0000-0000-000000000000	b327bbf2-adc7-4c89-bb03-c1db2533b4eb	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 09:02:25.17388+00	
00000000-0000-0000-0000-000000000000	2975fa4d-ca08-419b-8378-f300c055e6ac	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 09:02:25.175568+00	
00000000-0000-0000-0000-000000000000	cd37d940-8f43-4ece-9d47-b926df643973	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 09:02:25.186876+00	
00000000-0000-0000-0000-000000000000	29b6e36e-3b83-4b4e-8018-75560fb79a41	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 09:02:25.212799+00	
00000000-0000-0000-0000-000000000000	b1a744bd-1cef-415c-b1fc-96cd19278e5a	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 09:02:25.234596+00	
00000000-0000-0000-0000-000000000000	773bfd29-298a-4f59-a8ea-7291faa53672	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 09:02:25.254338+00	
00000000-0000-0000-0000-000000000000	23fd13a9-2a4d-4316-89af-371a22fe111f	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-14 09:31:44.597709+00	
00000000-0000-0000-0000-000000000000	b7d6a8bc-ccd1-4e64-9659-cba8ab60b37d	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 10:31:45.122926+00	
00000000-0000-0000-0000-000000000000	4434290e-7bc0-4036-8b2e-fd3f533dd3c1	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 10:31:45.153657+00	
00000000-0000-0000-0000-000000000000	935febe2-d4b8-4076-8285-9016e3382abf	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 11:31:45.202135+00	
00000000-0000-0000-0000-000000000000	f831c70d-a33d-44fd-8ab3-031d5ea365e8	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 11:31:45.228958+00	
00000000-0000-0000-0000-000000000000	e66e6f89-ab0e-42f7-94e1-d4b099d52287	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 12:31:45.365506+00	
00000000-0000-0000-0000-000000000000	02f8217b-adfe-4758-a606-d057ccb5a43a	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 12:31:45.390902+00	
00000000-0000-0000-0000-000000000000	0284f8e1-3977-40e9-b444-f390ce70b9d7	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 13:31:45.494234+00	
00000000-0000-0000-0000-000000000000	a9641de8-8372-4697-a853-e166d838edfb	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 13:31:45.523176+00	
00000000-0000-0000-0000-000000000000	74445471-2738-4722-a709-36188229373e	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 14:31:45.707077+00	
00000000-0000-0000-0000-000000000000	c5075e1b-272b-41f9-a2c2-603d1002293a	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 14:31:45.740356+00	
00000000-0000-0000-0000-000000000000	0ddbcd91-e577-42fd-84ef-f05a31963ec4	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 15:31:45.858731+00	
00000000-0000-0000-0000-000000000000	e248a302-436f-4c68-9a2e-37c38719eaa6	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 15:31:45.883333+00	
00000000-0000-0000-0000-000000000000	b7c02169-8f93-4da6-9afe-4188e737a4ec	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 16:31:46.03091+00	
00000000-0000-0000-0000-000000000000	f37ca1c4-1d8f-44ef-87fd-adbb9aff83aa	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 16:31:46.060709+00	
00000000-0000-0000-0000-000000000000	4e81b232-bd01-43d6-914c-c02917a54b9f	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 17:31:51.105649+00	
00000000-0000-0000-0000-000000000000	fafd871c-df50-49b8-9ea4-fe9f564a4965	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 17:31:51.13678+00	
00000000-0000-0000-0000-000000000000	853f32c4-805f-40a0-aaac-03e65aa97435	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 18:31:51.307953+00	
00000000-0000-0000-0000-000000000000	3078fb3b-c67f-4f6b-9dda-4da370895ed9	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 18:31:51.335322+00	
00000000-0000-0000-0000-000000000000	9c57d100-9b73-45f4-b995-7d2a64c06df4	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 18:36:28.23951+00	
00000000-0000-0000-0000-000000000000	52b1a833-6a51-481b-a326-9710d6059c2e	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 18:36:28.255033+00	
00000000-0000-0000-0000-000000000000	e36d0ed6-0b12-4e3c-9310-c11e4ed05d7e	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-14 18:36:57.517673+00	
00000000-0000-0000-0000-000000000000	0d0425b3-b46b-4952-b2a3-7fef6fde3ff3	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 18:43:14.857569+00	
00000000-0000-0000-0000-000000000000	9edb9f19-65ff-4f9b-ba49-a83f7ec50a38	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 18:43:14.862202+00	
00000000-0000-0000-0000-000000000000	aeecbdab-102e-4aec-80c2-2e2fc55be9e9	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 18:43:14.950472+00	
00000000-0000-0000-0000-000000000000	8296a73f-7ac7-4de8-83c9-25d21ae70f78	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-14 19:15:38.816815+00	
00000000-0000-0000-0000-000000000000	7a7164da-a095-424a-9167-b01a9d4253ca	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 19:15:53.475062+00	
00000000-0000-0000-0000-000000000000	8dd9afcb-a6d1-4ecc-a741-d87b94960a38	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 19:15:53.475728+00	
00000000-0000-0000-0000-000000000000	1b90db16-90f7-4c84-8180-1fb16f912d3b	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 19:15:53.508883+00	
00000000-0000-0000-0000-000000000000	81c5ad14-dcb4-48c1-a422-53c0411b4a2f	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-14 19:17:08.162811+00	
00000000-0000-0000-0000-000000000000	e815a1af-093a-4a55-8748-b7d2373b33ec	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 19:31:51.395098+00	
00000000-0000-0000-0000-000000000000	efec759e-f4d0-4d57-b9c0-743d3dc348e3	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 19:31:51.408301+00	
00000000-0000-0000-0000-000000000000	7622c79b-6c00-491b-9a5a-44bb0a9db815	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-14 19:33:03.895298+00	
00000000-0000-0000-0000-000000000000	e28643f0-82cf-43f4-b052-2ca05b65e491	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 19:54:02.334009+00	
00000000-0000-0000-0000-000000000000	90058e69-8b85-4f96-9334-9e6021a77768	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 19:54:02.345377+00	
00000000-0000-0000-0000-000000000000	9842d2c2-699c-467b-9cdf-7b573f60058c	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-14 19:54:02.376067+00	
00000000-0000-0000-0000-000000000000	a1aa6924-ac24-4db1-8143-5f19be3a8dcb	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-14 19:54:58.621105+00	
00000000-0000-0000-0000-000000000000	6202f3bd-7e34-4805-a91c-ab49bf66800f	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:00:06.121276+00	
00000000-0000-0000-0000-000000000000	45b29277-c010-456e-a759-d89837603188	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:00:06.143877+00	
00000000-0000-0000-0000-000000000000	25e481a4-f623-452e-8610-9aa681d538ed	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:00:06.226676+00	
00000000-0000-0000-0000-000000000000	2f9fcf94-e79b-4c4b-9a9a-9391ac314997	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-14 22:08:05.096723+00	
00000000-0000-0000-0000-000000000000	c556867e-448e-4a1d-b408-febe276b52fa	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-14 22:11:26.693465+00	
00000000-0000-0000-0000-000000000000	514c7916-59cc-45ae-abf4-37511b9a1e30	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:17.333574+00	
00000000-0000-0000-0000-000000000000	a1cd397a-da14-49d8-b1cc-4503630b6bae	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:17.345503+00	
00000000-0000-0000-0000-000000000000	27439c0f-60f8-4853-a90a-cf00f7a06beb	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:17.386807+00	
00000000-0000-0000-0000-000000000000	d1da474b-859a-42a6-a898-45e4d115ef81	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:19.191256+00	
00000000-0000-0000-0000-000000000000	1c30d73c-e003-469e-af3d-68b343f9c6b0	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:19.192005+00	
00000000-0000-0000-0000-000000000000	7964b573-630e-4e6d-a670-d1b848ce0233	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:19.220734+00	
00000000-0000-0000-0000-000000000000	d9a32ace-51fa-424e-8dd5-f13edf978f6b	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:20.372675+00	
00000000-0000-0000-0000-000000000000	9421f6fc-03d0-4aed-b16c-2e1d09c9ac71	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:20.373416+00	
00000000-0000-0000-0000-000000000000	2d67f9aa-0886-4076-85d0-c2718f24daef	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:20.39746+00	
00000000-0000-0000-0000-000000000000	93c118df-aca7-4db9-b855-929fed853bbf	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:21.573004+00	
00000000-0000-0000-0000-000000000000	58ba1693-fdd1-4df4-b986-e21f28acbf37	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:21.573609+00	
00000000-0000-0000-0000-000000000000	634de575-6ec4-4363-bede-1f784e44d5bb	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:21.61006+00	
00000000-0000-0000-0000-000000000000	c55a9564-7fb4-4432-b9d2-46c54acf738c	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:26.746746+00	
00000000-0000-0000-0000-000000000000	47efaf82-8264-4c0c-ad22-d16af9e8079d	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:26.74742+00	
00000000-0000-0000-0000-000000000000	52a7f054-70b7-4b35-9a0a-4af21209fcc6	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:28.354285+00	
00000000-0000-0000-0000-000000000000	f5cf54bf-cbd3-446b-a2a5-8bd7c3d946d9	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:28.354979+00	
00000000-0000-0000-0000-000000000000	7ba553b2-a6b1-40b5-bdef-00a5fb7ebae4	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:28.362785+00	
00000000-0000-0000-0000-000000000000	8b536829-1801-492c-91a6-c54fa980ae02	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:29.481775+00	
00000000-0000-0000-0000-000000000000	510e72f6-ee16-45e2-8c6a-1dafe41efbc5	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:29.482706+00	
00000000-0000-0000-0000-000000000000	8c965be4-1fe9-4168-8be2-56e548b93945	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:32.733288+00	
00000000-0000-0000-0000-000000000000	73b64f2b-6a60-4395-a8d0-6e338bb7bd20	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:32.734056+00	
00000000-0000-0000-0000-000000000000	9c574bf3-012e-441e-9e75-4870e16351ec	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:32.765174+00	
00000000-0000-0000-0000-000000000000	b1589e8a-c402-42d7-9ca0-e33c9e0f4bdc	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:34.704194+00	
00000000-0000-0000-0000-000000000000	b958c2cf-ce8c-471f-a930-4294f9a7eeb1	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:34.704882+00	
00000000-0000-0000-0000-000000000000	1436cc50-8e01-48c1-993c-6abcb227a710	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:38.321954+00	
00000000-0000-0000-0000-000000000000	202d41b9-3a0a-46f5-9340-1e17ca4b0ac8	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:38.797672+00	
00000000-0000-0000-0000-000000000000	27e6fafd-9a59-416e-9f29-fe8c98b58e5b	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:38.798364+00	
00000000-0000-0000-0000-000000000000	dffcdb22-44e5-42e2-8257-42f0191e850b	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:38.829013+00	
00000000-0000-0000-0000-000000000000	fae3c6d8-5289-4218-8b0c-9f4fce8ae020	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:40.368737+00	
00000000-0000-0000-0000-000000000000	f834e4bb-ffe9-4a6c-af2e-69c875d3945f	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:40.370074+00	
00000000-0000-0000-0000-000000000000	fa1c0d1f-c6b6-455e-a0f2-fe62ed870eb8	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:40.392008+00	
00000000-0000-0000-0000-000000000000	499453f3-650e-4544-8558-d9a689dcdae6	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:40.857148+00	
00000000-0000-0000-0000-000000000000	00e54543-9790-4c63-9c3b-10cbf301335e	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:40.858372+00	
00000000-0000-0000-0000-000000000000	ffd6c07f-2d80-4b7d-92d6-6fce41c973a0	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:40.908011+00	
00000000-0000-0000-0000-000000000000	039da344-6c91-466b-b7e4-986e5f71a1b1	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 23:46:04.1324+00	
00000000-0000-0000-0000-000000000000	bef78bc3-c8ba-4f2b-a5a3-d3ad5135e672	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 01:43:19.796539+00	
00000000-0000-0000-0000-000000000000	27af2a02-f75a-4cbe-bb02-472141ff309a	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 03:42:59.557671+00	
00000000-0000-0000-0000-000000000000	d20c448c-8bcc-4df2-923b-5c10f44352e7	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 03:42:59.578017+00	
00000000-0000-0000-0000-000000000000	105380ca-192e-4756-a052-1e6e54134975	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 03:42:59.786783+00	
00000000-0000-0000-0000-000000000000	0ac21bd8-e9ac-4c44-9d9b-cebedd487c66	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 03:42:59.787555+00	
00000000-0000-0000-0000-000000000000	feebe462-ec41-4969-86ec-069a9b19fec3	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 05:42:39.434491+00	
00000000-0000-0000-0000-000000000000	d1b00f9c-4972-4273-9854-ddbe95bea50a	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 05:42:39.452284+00	
00000000-0000-0000-0000-000000000000	8906e909-d9a6-4c9b-a790-1fed02e67147	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 05:42:39.693724+00	
00000000-0000-0000-0000-000000000000	8395eab7-97ae-478e-b836-4c56291c145e	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:26.758014+00	
00000000-0000-0000-0000-000000000000	76d3e574-5322-42db-ad90-64fd3c22befd	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:27.364106+00	
00000000-0000-0000-0000-000000000000	fe2fb9ae-a9e0-4dbf-933b-2bc1e7c22c80	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:27.36476+00	
00000000-0000-0000-0000-000000000000	3ccf873f-02a6-40a4-acb9-d73896ce3fe8	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:27.400724+00	
00000000-0000-0000-0000-000000000000	8793b17d-e192-4300-bfd1-e636aab84aba	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:29.507201+00	
00000000-0000-0000-0000-000000000000	a3992e0c-ab1c-457c-a665-bc86fe8f3730	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:34.73519+00	
00000000-0000-0000-0000-000000000000	3fcd7fbc-130b-4351-ae93-e8ab5e3a6597	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:36.660815+00	
00000000-0000-0000-0000-000000000000	3e8279d0-5eff-4beb-a293-2850aadebea8	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:36.661502+00	
00000000-0000-0000-0000-000000000000	2b662170-6232-42cd-a975-ee2b9a50d534	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:36.685863+00	
00000000-0000-0000-0000-000000000000	580154be-97f6-49c7-a8b2-4920e019b19f	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:38.313359+00	
00000000-0000-0000-0000-000000000000	83531397-c52f-45ee-8b10-71952dbde75a	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:38.31404+00	
00000000-0000-0000-0000-000000000000	1c9fb1f9-04ec-47b5-ae08-652568678e51	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:41.462249+00	
00000000-0000-0000-0000-000000000000	2325bb35-d61a-4499-a583-d0543a4db239	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:41.46318+00	
00000000-0000-0000-0000-000000000000	0ee9de0e-a3a5-4f01-a9bb-0388ad904eb8	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:41.483281+00	
00000000-0000-0000-0000-000000000000	07207030-41bd-485d-a62e-dcbef676d151	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:43.731312+00	
00000000-0000-0000-0000-000000000000	1f80dfc4-af4c-4534-be37-f54f7116c336	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:43.731989+00	
00000000-0000-0000-0000-000000000000	2cfcc842-bd3e-4592-81cb-a03fbb8a6308	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:43.747329+00	
00000000-0000-0000-0000-000000000000	6cd627d7-c206-4232-93f9-6568b0ee381a	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:44.434328+00	
00000000-0000-0000-0000-000000000000	e97a0e9c-fd6d-44c2-ba26-b962d7a01207	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:44.435046+00	
00000000-0000-0000-0000-000000000000	f9a12420-9803-498d-be76-28be3c60f567	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:44.469216+00	
00000000-0000-0000-0000-000000000000	6b68350e-6bfd-4f55-bdf6-1d864dac3061	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:46.146908+00	
00000000-0000-0000-0000-000000000000	e16c5889-6a61-46d8-a353-f93974aef9c5	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:46.147782+00	
00000000-0000-0000-0000-000000000000	e89edb20-5739-4811-a88e-8736d60e3284	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:46.172199+00	
00000000-0000-0000-0000-000000000000	481c6179-a295-4afa-aacb-230359343a7d	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:47.187092+00	
00000000-0000-0000-0000-000000000000	3de61dd4-f9b9-4bd3-bcf7-725451d5aafc	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:47.187629+00	
00000000-0000-0000-0000-000000000000	b6c2f889-575d-431c-8a68-4a3834084054	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 22:27:47.199236+00	
00000000-0000-0000-0000-000000000000	3b641f1b-6339-4eda-9217-e32baf24d75e	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 23:27:51.092402+00	
00000000-0000-0000-0000-000000000000	c8dd0ae6-571f-40e9-bf43-c0500cd0a413	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-14 23:27:51.127101+00	
00000000-0000-0000-0000-000000000000	cd6cc2d1-f84d-42f1-83c6-c285a43ade99	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 00:24:54.700191+00	
00000000-0000-0000-0000-000000000000	77e45892-a555-4265-8b7b-4cf9aabfbcfe	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 00:24:54.719215+00	
00000000-0000-0000-0000-000000000000	eaea17a3-8bd5-4e5c-8ef7-0062d29ea00d	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"faithmontemayor@csus.edu","user_id":"78467702-b492-451b-a9f1-2059dbdd433e","user_phone":""}}	2025-09-15 02:03:38.663435+00	
00000000-0000-0000-0000-000000000000	cd5bd4a3-1b2b-4570-b032-6755e1dd9242	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 02:05:02.244346+00	
00000000-0000-0000-0000-000000000000	d88147a6-2aae-4534-b19f-30abd610b557	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 02:05:12.397916+00	
00000000-0000-0000-0000-000000000000	0ef81a57-a868-428f-b718-cef86c835b1a	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 02:05:16.206009+00	
00000000-0000-0000-0000-000000000000	c82d0463-d769-447d-b3f3-8274751760b6	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 03:05:06.553176+00	
00000000-0000-0000-0000-000000000000	25c1fbfe-b030-4a92-beff-0fec12db290d	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 03:05:06.582416+00	
00000000-0000-0000-0000-000000000000	dfaba7d0-6321-4816-882e-beef00dc79d0	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 03:05:06.748747+00	
00000000-0000-0000-0000-000000000000	fd12f87b-3163-4ce0-a471-58f5a3d23edb	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 03:05:06.749598+00	
00000000-0000-0000-0000-000000000000	074ec7ed-206e-4548-8b1d-65c4b441b4f8	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 04:47:14.871897+00	
00000000-0000-0000-0000-000000000000	d74020cd-c5f7-4e70-bd31-3285529c9d3f	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 04:47:14.895194+00	
00000000-0000-0000-0000-000000000000	a9d55ada-e2f4-4986-a22f-ee29e4887654	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 04:47:14.968952+00	
00000000-0000-0000-0000-000000000000	4c62a76c-56d6-4e20-b478-8e1a71fc6cd2	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 05:59:40.370984+00	
00000000-0000-0000-0000-000000000000	9bb814d5-00f4-47fd-95f8-b05c21007bf7	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 05:59:40.38276+00	
00000000-0000-0000-0000-000000000000	98e477d8-1f88-4013-b50d-5c3f8d1a3959	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 05:59:40.434365+00	
00000000-0000-0000-0000-000000000000	9ead57b4-847a-4afb-94e6-1bd0e112f866	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 06:03:26.997859+00	
00000000-0000-0000-0000-000000000000	276528ce-21cd-4623-91ad-c919d0235035	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 06:03:27.009189+00	
00000000-0000-0000-0000-000000000000	79c9f1ae-fe8c-44ac-963a-eb760a76b5a6	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 06:03:27.054185+00	
00000000-0000-0000-0000-000000000000	5f6d4a41-569d-40cd-aa62-fb4b4e9490fc	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"phernandez4@csus.edu","user_id":"c96981e5-0436-43d2-b096-79dc929f0fb5","user_phone":""}}	2025-09-15 06:08:19.548106+00	
00000000-0000-0000-0000-000000000000	123eaa85-8316-4006-b130-4b0cee08e897	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"phernandez4@csus.edu","user_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","user_phone":""}}	2025-09-15 06:08:36.440154+00	
00000000-0000-0000-0000-000000000000	64b9668b-0169-4675-80b3-5e2fa244b093	{"action":"login","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 06:23:33.039098+00	
00000000-0000-0000-0000-000000000000	17470b3f-c717-4af7-bc70-55576c7b08a8	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 06:30:51.308027+00	
00000000-0000-0000-0000-000000000000	7aa0c43f-a216-4aa0-af21-abcc888f4597	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 06:30:51.310327+00	
00000000-0000-0000-0000-000000000000	ef513d32-8708-4f99-920f-4dbd9e1e14dd	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 06:30:51.331683+00	
00000000-0000-0000-0000-000000000000	912d0c4e-f5aa-4aaf-b1e5-347f73b4fe08	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 06:39:08.702681+00	
00000000-0000-0000-0000-000000000000	be4173ef-a218-49f5-b47e-041186407663	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 06:39:08.706001+00	
00000000-0000-0000-0000-000000000000	59316156-3867-4c44-be93-963b7a818bc9	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 06:39:08.743455+00	
00000000-0000-0000-0000-000000000000	31b56544-c81f-47ce-bfba-7895bed81f63	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 06:40:27.691762+00	
00000000-0000-0000-0000-000000000000	801cca2d-0384-445c-895b-e32f79e940f7	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 06:40:27.718815+00	
00000000-0000-0000-0000-000000000000	d96cad94-d0a8-480f-b164-d2385e5ed225	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 06:40:27.793576+00	
00000000-0000-0000-0000-000000000000	73410f54-924d-4486-87fe-d5fa352e9618	{"action":"login","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 07:05:54.784172+00	
00000000-0000-0000-0000-000000000000	269b4bd2-f9b1-4e6a-8eb6-e1729ad4a579	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 07:31:09.292788+00	
00000000-0000-0000-0000-000000000000	cfbfcb3a-494e-4afc-b556-90d72c66165c	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 07:31:09.308978+00	
00000000-0000-0000-0000-000000000000	4a4aadb9-7702-415f-9b18-3562eebb1c1f	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 07:31:09.375448+00	
00000000-0000-0000-0000-000000000000	d19bb7c2-fcb5-49cd-afd6-7af1ba169ad8	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 07:31:31.755739+00	
00000000-0000-0000-0000-000000000000	4d804697-c010-424c-ad2e-93a770c2f501	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 07:31:31.756374+00	
00000000-0000-0000-0000-000000000000	bc887a9e-1e6a-483b-8aae-4a20d00610a2	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 07:31:31.789546+00	
00000000-0000-0000-0000-000000000000	fe384a50-9f22-4da3-81d7-dee2dfdf214a	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 07:32:26.739599+00	
00000000-0000-0000-0000-000000000000	1f5f7c58-abd7-4dac-a27b-7cf426d02fda	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 07:32:26.742269+00	
00000000-0000-0000-0000-000000000000	0af121c7-d3e5-4283-8a0e-071e698700f0	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 07:32:26.774259+00	
00000000-0000-0000-0000-000000000000	eaa549ee-4713-4071-b1a6-6b8e108e51f1	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 07:51:07.648375+00	
00000000-0000-0000-0000-000000000000	4f519d18-f1a8-43cf-8081-d5a1b1c4a762	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 07:51:07.659755+00	
00000000-0000-0000-0000-000000000000	c62f4cfa-3b6c-4c62-973d-9fe0ed2366b9	{"action":"login","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 07:51:24.576978+00	
00000000-0000-0000-0000-000000000000	3dd9d2ed-4846-4922-948c-7585d8056628	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 08:09:29.617592+00	
00000000-0000-0000-0000-000000000000	8c2ace3f-8fd0-4753-8ba4-fa3d33d21bb5	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 08:14:04.606107+00	
00000000-0000-0000-0000-000000000000	83d3bcb4-61dd-472f-9288-f47594aad476	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 08:23:40.103572+00	
00000000-0000-0000-0000-000000000000	52a045df-63c1-4b63-9492-cd219bc7bf2b	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 08:30:02.263852+00	
00000000-0000-0000-0000-000000000000	fc82b864-c7c2-46d6-a074-86e8f859a741	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 08:30:02.269271+00	
00000000-0000-0000-0000-000000000000	77084b7a-c22c-43d3-a466-476d4fba275d	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 08:30:02.297054+00	
00000000-0000-0000-0000-000000000000	a4e84304-ea9e-4254-889b-39f5b9170d0a	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 08:36:47.281781+00	
00000000-0000-0000-0000-000000000000	6a1d0b9e-94dd-4eec-8750-ff22ca758dd7	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 08:36:47.287917+00	
00000000-0000-0000-0000-000000000000	dc07de1a-52cb-47c5-bbf2-d7ce3e0da8b0	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 08:36:47.327214+00	
00000000-0000-0000-0000-000000000000	065560a1-82ae-489d-ac7f-9580ef8a2ed1	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 10:38:28.111191+00	
00000000-0000-0000-0000-000000000000	1d98e9b8-5479-4d62-8258-5390b7918945	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 10:38:28.132049+00	
00000000-0000-0000-0000-000000000000	43ab5163-a5da-4a7b-988c-ef05322ca6b6	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 10:38:28.196678+00	
00000000-0000-0000-0000-000000000000	108dfedd-1cb5-426b-bb93-1d1fe92db646	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 10:38:28.231508+00	
00000000-0000-0000-0000-000000000000	670fc8da-4733-4223-9af1-d75c963515e6	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 10:52:13.573891+00	
00000000-0000-0000-0000-000000000000	6f285c38-c3ef-41f0-a729-188b4d58298a	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 11:12:06.700863+00	
00000000-0000-0000-0000-000000000000	8f259dc5-1c8f-4c72-9837-62bb53de6fa3	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 11:17:26.460565+00	
00000000-0000-0000-0000-000000000000	1b7e41a6-4472-42eb-9347-538b9fe2733f	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 18:05:47.677266+00	
00000000-0000-0000-0000-000000000000	222b2cfa-6ab5-4a3d-a7af-af757945c9fa	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 19:05:37.522739+00	
00000000-0000-0000-0000-000000000000	631fa74f-730e-4b6c-8199-6fcdf56049f1	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 19:05:37.538457+00	
00000000-0000-0000-0000-000000000000	09d73e82-df4f-49b0-a92a-5af3b9ef66d0	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 19:05:37.845679+00	
00000000-0000-0000-0000-000000000000	d25c93bd-98e2-481a-a962-3430e85d4701	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 19:05:37.847289+00	
00000000-0000-0000-0000-000000000000	de91ce0e-690e-4ba0-b1a6-6e84898b9c0f	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 19:17:07.277637+00	
00000000-0000-0000-0000-000000000000	0d8d4392-10b9-4831-9e8a-9a118401ef9f	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 20:05:27.330489+00	
00000000-0000-0000-0000-000000000000	611ba5b6-526b-404a-aae9-bc5dd1b49d49	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 20:05:27.350424+00	
00000000-0000-0000-0000-000000000000	b1895b71-66b4-4dbd-b909-c2825248c550	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 20:05:27.500582+00	
00000000-0000-0000-0000-000000000000	9dd58f44-8b91-43bf-b770-61ddd3e184ab	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 20:05:27.507332+00	
00000000-0000-0000-0000-000000000000	828e1b6e-c6af-4706-a6ab-e8b5cc915c7e	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 21:09:40.476253+00	
00000000-0000-0000-0000-000000000000	200b0a76-8d54-4e0e-9178-9db028bc24a2	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:15:38.781136+00	
00000000-0000-0000-0000-000000000000	2915e029-7a53-4ca2-acc6-7bf8ce49538a	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:15:38.795648+00	
00000000-0000-0000-0000-000000000000	3834f212-5dee-4fab-8226-80f33ae47a9b	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:15:38.997614+00	
00000000-0000-0000-0000-000000000000	5e853ebe-3e35-4251-befc-638bb02abbe4	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:15:38.999607+00	
00000000-0000-0000-0000-000000000000	0830d16d-d776-4c3a-8227-1b07d62d0c04	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:18:52.912385+00	
00000000-0000-0000-0000-000000000000	e76ce699-c39b-4553-97cf-a1d3badd1b2f	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:18:52.914057+00	
00000000-0000-0000-0000-000000000000	6431f4d2-de33-4de4-8723-4875ceaabd53	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:19:00.945553+00	
00000000-0000-0000-0000-000000000000	b3e211b7-4247-4346-ace4-0cc5e93677b1	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:19:00.946891+00	
00000000-0000-0000-0000-000000000000	bda609a4-1dea-457e-894a-96ff656b8eed	{"action":"login","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 23:19:23.359276+00	
00000000-0000-0000-0000-000000000000	58b2a116-60ff-425c-85eb-d9c932c57054	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-15 23:43:39.345043+00	
00000000-0000-0000-0000-000000000000	9b170393-1f71-4ae2-8455-bac2d5bd3df7	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:43:50.68897+00	
00000000-0000-0000-0000-000000000000	9b871fec-22e3-4f15-a5fb-04ffdc35b27a	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:43:50.690969+00	
00000000-0000-0000-0000-000000000000	7ea61910-d37c-411e-9ebd-9a705b882e8b	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:43:50.709306+00	
00000000-0000-0000-0000-000000000000	3cf88bba-04c7-4d8b-b311-7ffb61d83a7a	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:43:58.894525+00	
00000000-0000-0000-0000-000000000000	5f916bc8-846e-4f77-a7b4-fc13bccbce4c	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:43:58.895209+00	
00000000-0000-0000-0000-000000000000	b4a5614f-0342-4013-82ca-1300bba77874	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:43:58.926918+00	
00000000-0000-0000-0000-000000000000	4cebf6b9-1296-4243-8c73-eebe81a52b2d	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:46:29.570763+00	
00000000-0000-0000-0000-000000000000	275428ee-114d-4ed5-8a5a-a1ce7a6995db	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:46:29.572426+00	
00000000-0000-0000-0000-000000000000	6fd43953-91cc-45fc-be5e-8ff086eae45d	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:46:29.718626+00	
00000000-0000-0000-0000-000000000000	84109c9c-6271-4576-84e0-7a6bf43e3981	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:46:33.035836+00	
00000000-0000-0000-0000-000000000000	cd0d7021-8104-4fe1-9c47-8223e661ffb0	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:46:33.036718+00	
00000000-0000-0000-0000-000000000000	9ea8a962-b0dd-4197-b453-882ca907c7e5	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:46:33.046386+00	
00000000-0000-0000-0000-000000000000	d2e0f03b-2b91-404d-a7ca-8a4afcfe0cb3	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:46:34.665056+00	
00000000-0000-0000-0000-000000000000	e0f69dff-9f85-4276-a07c-c04916e9c342	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:46:34.665708+00	
00000000-0000-0000-0000-000000000000	507595d4-e2ed-498e-9eaa-c61220504163	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:46:34.679133+00	
00000000-0000-0000-0000-000000000000	b8db2d38-bb57-468b-9ae7-a858255761e4	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:58:02.830822+00	
00000000-0000-0000-0000-000000000000	a3b985bf-3744-49eb-9742-6733e671b56b	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:58:02.847363+00	
00000000-0000-0000-0000-000000000000	6a96b868-5f3a-483f-a4cc-ced5fe23cb43	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:58:02.892135+00	
00000000-0000-0000-0000-000000000000	6aa60c88-1d0a-4a99-a25d-57b1754df1e5	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:58:03.738527+00	
00000000-0000-0000-0000-000000000000	967d2a5a-fc9a-4c7b-8347-6d698c97a09d	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:58:03.739218+00	
00000000-0000-0000-0000-000000000000	af367cb4-63ca-4961-86a7-7b2de32f39b5	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:58:03.758867+00	
00000000-0000-0000-0000-000000000000	750475d2-36f9-49c3-80ce-87f1ed0a8313	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:58:06.645519+00	
00000000-0000-0000-0000-000000000000	dc62c545-5942-49a6-b1a6-2f5f39d37ced	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:58:06.646355+00	
00000000-0000-0000-0000-000000000000	64046a92-ccff-4c1f-96a5-eb7d1be6e235	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-15 23:58:06.680595+00	
00000000-0000-0000-0000-000000000000	908a4a1f-0f3c-40d5-9020-1411edacf777	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 00:19:13.918259+00	
00000000-0000-0000-0000-000000000000	bf8797f9-1694-43c5-ab7a-467df10a0e3c	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 00:19:13.932621+00	
00000000-0000-0000-0000-000000000000	9ed5fe4f-5e00-4849-9cb9-22480fd8106d	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 00:19:14.058319+00	
00000000-0000-0000-0000-000000000000	f5ad83b1-5ac8-4147-abac-9e2ef8082f7c	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 00:19:14.059023+00	
00000000-0000-0000-0000-000000000000	4ac71aed-3f8b-4e48-9510-63981c6b8e26	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 00:34:48.577028+00	
00000000-0000-0000-0000-000000000000	6e6e2bb5-3284-405b-b51c-c9cc1abae76f	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 00:50:22.404128+00	
00000000-0000-0000-0000-000000000000	694b1a21-58e5-48f7-b01b-283831fdfef6	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 00:57:56.160074+00	
00000000-0000-0000-0000-000000000000	846971af-266e-472c-a79a-c9088a5c057b	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 00:57:56.170125+00	
00000000-0000-0000-0000-000000000000	f66973da-8496-4dbc-9274-18b018df0fd9	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 00:57:56.314857+00	
00000000-0000-0000-0000-000000000000	d59e3bed-341e-4898-93d1-a191afb6def0	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 00:57:56.316252+00	
00000000-0000-0000-0000-000000000000	dea7ef30-a623-4c87-9525-3e2a230d5e45	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 01:19:05.75426+00	
00000000-0000-0000-0000-000000000000	f75b54ea-ce78-418a-b778-1d271380e001	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 01:19:05.769777+00	
00000000-0000-0000-0000-000000000000	655f5c0d-c6ba-44b7-be97-4c7bbcf27242	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 01:19:05.91165+00	
00000000-0000-0000-0000-000000000000	ba46de5c-6b70-4701-a3bb-9e9e995ee0e8	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 01:19:05.91345+00	
00000000-0000-0000-0000-000000000000	c6e73e7e-930f-4e9e-99a2-f6d08cfade49	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 02:02:34.288641+00	
00000000-0000-0000-0000-000000000000	e3834421-f71b-4064-8e80-6e62a4864fc2	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 02:10:19.657536+00	
00000000-0000-0000-0000-000000000000	6a7fa9a5-1b2c-4a40-b48a-8b3d9e69dfba	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 02:10:19.660425+00	
00000000-0000-0000-0000-000000000000	6ca3bcd8-5a61-4445-83fa-dece58d60157	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 02:10:19.688219+00	
00000000-0000-0000-0000-000000000000	7ea08759-2beb-4d63-ad23-3e92e9929b96	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 02:10:33.171949+00	
00000000-0000-0000-0000-000000000000	95c87e69-9839-431b-b5c6-3ca09bcb12c1	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 02:10:33.173958+00	
00000000-0000-0000-0000-000000000000	3b573e09-1e28-4e39-afaf-8dfa9f292c03	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 02:10:33.184422+00	
00000000-0000-0000-0000-000000000000	d0fc4dfb-ebc3-4f6d-872c-809a1451b3d2	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 02:10:35.228104+00	
00000000-0000-0000-0000-000000000000	deb392d1-7c57-4e37-9d1d-de51da0fa8e5	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 02:10:35.22943+00	
00000000-0000-0000-0000-000000000000	f716ce50-a2c9-4735-aedb-e18f8a69f420	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 02:10:35.260967+00	
00000000-0000-0000-0000-000000000000	cf2030d0-c506-4d3e-8b83-289646f87221	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 02:10:38.831677+00	
00000000-0000-0000-0000-000000000000	1d0b3e05-7acb-4e2e-a5c4-3f4aac330b54	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 02:10:38.83237+00	
00000000-0000-0000-0000-000000000000	0fdf1f58-b1a8-46c5-9d52-8a0259a02c69	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 02:10:38.864498+00	
00000000-0000-0000-0000-000000000000	1cc0dad5-4bc1-40dc-b73e-5ed296fb1fa8	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 02:18:56.332108+00	
00000000-0000-0000-0000-000000000000	7620b4e8-cd99-4e70-9e51-0aa08ec063d5	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 02:18:56.338781+00	
00000000-0000-0000-0000-000000000000	9d342378-543f-43cd-ac5d-e90c71d1803e	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 02:18:56.415495+00	
00000000-0000-0000-0000-000000000000	a4b9e447-4449-475e-a3c8-6a9026445a69	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 02:18:56.417697+00	
00000000-0000-0000-0000-000000000000	e21abd2d-8829-47eb-8e1f-576b2f753360	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 03:09:55.08117+00	
00000000-0000-0000-0000-000000000000	b07087bd-c1e3-4b62-9ada-dceeea70af12	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 03:18:47.974876+00	
00000000-0000-0000-0000-000000000000	181ab578-a08b-454b-a94e-b76bafd1e348	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 03:18:47.979628+00	
00000000-0000-0000-0000-000000000000	f1b99c71-ac57-4cb9-87b9-e8e424d0d740	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 03:18:48.095749+00	
00000000-0000-0000-0000-000000000000	d4b7278e-ccc4-4f25-b5ff-d8ca21c62d7d	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 03:18:48.097063+00	
00000000-0000-0000-0000-000000000000	1427f650-b582-4aa7-889f-dc70e283e2e1	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 04:00:39.87668+00	
00000000-0000-0000-0000-000000000000	da7d9592-1f60-425b-9b7b-b3a834c64ba0	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 04:00:39.886529+00	
00000000-0000-0000-0000-000000000000	c25df34b-f01d-4192-adf0-93a047ecf5bc	{"action":"login","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 04:01:07.556141+00	
00000000-0000-0000-0000-000000000000	557b9bab-bf9e-4b6d-8857-1fbea89418c8	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 04:09:45.684917+00	
00000000-0000-0000-0000-000000000000	933f6b8c-184e-48b0-b66b-91499c016a47	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 04:09:45.696206+00	
00000000-0000-0000-0000-000000000000	0eb63ce3-0f26-469c-a68c-3ef6d919487d	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 04:09:45.81085+00	
00000000-0000-0000-0000-000000000000	eeafd08d-31fa-45c2-9764-cf34e8000843	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 04:09:45.812144+00	
00000000-0000-0000-0000-000000000000	7d4c7c87-812d-4f52-87ce-1714f2ca44b9	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 04:51:36.909768+00	
00000000-0000-0000-0000-000000000000	2c5361ec-4366-46d9-873d-e842ac36999b	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 04:51:36.930607+00	
00000000-0000-0000-0000-000000000000	e61a684b-2ed5-448b-984b-cb2433f1e748	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 04:52:44.057391+00	
00000000-0000-0000-0000-000000000000	7bc1486b-6537-4291-ad17-ec9ce0492126	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 04:52:44.060518+00	
00000000-0000-0000-0000-000000000000	34ba96de-5389-48f7-946d-81d566d6e641	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 04:52:44.081045+00	
00000000-0000-0000-0000-000000000000	150c89a4-b2c6-40af-8ca8-4768c88cfcf7	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 04:52:49.669406+00	
00000000-0000-0000-0000-000000000000	ba928dfd-a676-495c-82d6-af1953c238bd	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 04:52:49.670118+00	
00000000-0000-0000-0000-000000000000	98b26bd0-85d1-43d5-8f00-464e1af234c3	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 04:52:49.686593+00	
00000000-0000-0000-0000-000000000000	b6ca5985-657e-4151-ac71-ad318a327b86	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 05:03:45.726175+00	
00000000-0000-0000-0000-000000000000	91a304cf-72ca-4516-b599-54a4272bc33b	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 05:03:45.739063+00	
00000000-0000-0000-0000-000000000000	e5f5aa04-9818-4ddc-9f60-88e841299bea	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 05:03:45.784435+00	
00000000-0000-0000-0000-000000000000	90081fc9-251a-4929-96ae-d5d8df239405	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 05:52:39.082357+00	
00000000-0000-0000-0000-000000000000	859f5fca-7254-45bb-9515-eae082ad0961	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 05:52:39.097282+00	
00000000-0000-0000-0000-000000000000	a6f3b77a-669e-4673-80c1-abb3da601dfa	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 05:52:39.301819+00	
00000000-0000-0000-0000-000000000000	3319e5b0-9a0a-4f45-9dc7-d0e38837a74a	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 05:52:39.306647+00	
00000000-0000-0000-0000-000000000000	57e29f00-715d-49c9-b086-d7f60cf16621	{"action":"login","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 05:58:38.743253+00	
00000000-0000-0000-0000-000000000000	980bdbb4-d31d-4243-b702-8aefae89a7a2	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 06:16:00.537645+00	
00000000-0000-0000-0000-000000000000	de66e603-22f3-42df-8ed6-4d055fcd1ae7	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 06:44:09.498963+00	
00000000-0000-0000-0000-000000000000	b249fe1e-8341-4ad2-b798-0fe8f88d9820	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 06:44:09.515329+00	
00000000-0000-0000-0000-000000000000	b54b63c7-a2de-4d96-834b-6bfae2198dee	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 06:44:09.551581+00	
00000000-0000-0000-0000-000000000000	13dcc939-d287-4227-b770-565443c87313	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 06:44:37.242857+00	
00000000-0000-0000-0000-000000000000	8c80ab08-705c-4a07-bd4b-45f524fc55ea	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 06:44:37.244537+00	
00000000-0000-0000-0000-000000000000	67e5ca4b-413a-4fc5-8188-d675b5f21e66	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 06:44:37.259034+00	
00000000-0000-0000-0000-000000000000	733e7911-b5c9-4750-b1c9-1f8c4dfaa203	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 06:46:06.178254+00	
00000000-0000-0000-0000-000000000000	d689f5dd-fb58-4b6d-bc39-02c54aea6067	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 06:46:06.180085+00	
00000000-0000-0000-0000-000000000000	7e8869fe-8d71-4c40-bbba-d0238abdb09c	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 06:46:06.21102+00	
00000000-0000-0000-0000-000000000000	d02a89d6-bb05-4109-a987-eb7d8fb3cb57	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 08:01:27.433048+00	
00000000-0000-0000-0000-000000000000	51428250-5a21-47d1-8fbf-0d4e72aeba57	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 08:01:27.447161+00	
00000000-0000-0000-0000-000000000000	5ffc0946-6f96-4337-a5dc-d0705b67413e	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 08:01:27.649587+00	
00000000-0000-0000-0000-000000000000	3dc7a551-6c0b-4614-9ce1-952298904b1e	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 08:01:27.651119+00	
00000000-0000-0000-0000-000000000000	48e4a9be-1cfd-4387-afe6-ab120bb8fa0f	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 08:14:37.484412+00	
00000000-0000-0000-0000-000000000000	90c784aa-93e5-4d22-b674-0b401c3905aa	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 08:23:46.74298+00	
00000000-0000-0000-0000-000000000000	8e905cd6-5ad5-4ba3-a44c-4500adb93a56	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 08:32:51.766435+00	
00000000-0000-0000-0000-000000000000	4f20ea7b-46a8-4e9e-89a0-a0989c002454	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 08:32:51.769323+00	
00000000-0000-0000-0000-000000000000	b26498f9-f234-46d6-a94b-09b99075d5de	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 08:32:51.791326+00	
00000000-0000-0000-0000-000000000000	dbd3501e-2745-433a-8915-efe740b0a47d	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 16:06:33.947659+00	
00000000-0000-0000-0000-000000000000	9d1ae61e-8979-43bd-95ac-05165b88af57	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 16:06:33.972802+00	
00000000-0000-0000-0000-000000000000	66ddbaf8-357b-445d-b5cb-ab300cc84846	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 16:06:34.266693+00	
00000000-0000-0000-0000-000000000000	84a9bd17-6d5b-4b5f-8827-dbf945b5a867	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 16:06:34.26816+00	
00000000-0000-0000-0000-000000000000	3b680c50-d0f3-44ec-8507-6ae8231fba2d	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 16:32:31.832597+00	
00000000-0000-0000-0000-000000000000	6a9a20aa-73d5-4387-b6b5-bb85d106f7fb	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 16:38:16.5972+00	
00000000-0000-0000-0000-000000000000	601a6c44-abde-4cf1-bfc8-127ccf9a19c4	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 16:38:16.607359+00	
00000000-0000-0000-0000-000000000000	113e62c3-0e19-475c-af75-c14f9565a339	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 16:38:16.634591+00	
00000000-0000-0000-0000-000000000000	5be5cb42-ac02-4728-90ed-00459b87bc9f	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 16:38:23.828121+00	
00000000-0000-0000-0000-000000000000	0407075e-aeaf-4588-850a-8e2c9b79a5f2	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 16:38:23.828812+00	
00000000-0000-0000-0000-000000000000	913c042f-56c0-4388-994e-735c15d4494b	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 16:38:23.849017+00	
00000000-0000-0000-0000-000000000000	a0c70ded-3c2c-4d9f-a678-0560328132db	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 17:06:47.833001+00	
00000000-0000-0000-0000-000000000000	3b0bf62e-0b85-4f60-82a8-24e3f5904791	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 17:06:47.83966+00	
00000000-0000-0000-0000-000000000000	555e4710-29e6-4bdf-aa30-f34991eba778	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 17:06:47.871+00	
00000000-0000-0000-0000-000000000000	13a4838f-055b-4400-ba46-8b80589b60d9	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 17:06:49.266522+00	
00000000-0000-0000-0000-000000000000	2987ef43-6c18-4fa9-9560-1eafb11daa4d	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 17:06:49.269342+00	
00000000-0000-0000-0000-000000000000	7cc426c2-6d2c-4986-85e7-f53380d7800e	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 17:06:49.295492+00	
00000000-0000-0000-0000-000000000000	8c60b921-0af5-4a86-8bb5-471a259132a3	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 17:06:53.214815+00	
00000000-0000-0000-0000-000000000000	3cd7c9aa-7353-4cfa-a1c1-3995bc2b80c5	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 17:06:53.216286+00	
00000000-0000-0000-0000-000000000000	995ecc2c-4ec8-49ec-b10e-feef99847719	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 17:06:53.252058+00	
00000000-0000-0000-0000-000000000000	51b9bc87-1f49-436e-9302-83e7007dccdd	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 17:06:57.606299+00	
00000000-0000-0000-0000-000000000000	0e602bf7-a4eb-4379-abad-630e1ce83ac9	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 17:06:57.607234+00	
00000000-0000-0000-0000-000000000000	c5f533c4-0f32-4298-a834-76ebd5baa4a3	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 17:06:57.630052+00	
00000000-0000-0000-0000-000000000000	d4a5127f-5815-47e1-be43-c8272761d388	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 17:07:01.637438+00	
00000000-0000-0000-0000-000000000000	07aa20f6-0bda-4e33-a7d2-cb6230a19f2d	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 17:07:01.638234+00	
00000000-0000-0000-0000-000000000000	79517047-00c5-4fa6-bdd3-617ab4c84deb	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 17:07:01.660223+00	
00000000-0000-0000-0000-000000000000	16607553-53c4-46a4-b784-18dfaad81c2f	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:06:51.540601+00	
00000000-0000-0000-0000-000000000000	2516e2dc-2dca-4473-a673-542ba5655f7b	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:06:51.568164+00	
00000000-0000-0000-0000-000000000000	8ccfbe13-80ec-4480-a970-cbcb2a888b33	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:06:51.81373+00	
00000000-0000-0000-0000-000000000000	ccf12853-b353-4b86-ad67-4881cd181939	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:06:51.817733+00	
00000000-0000-0000-0000-000000000000	58404f9e-d0f2-48a0-9665-691e4521a1fa	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 18:38:05.66528+00	
00000000-0000-0000-0000-000000000000	b3c99c2f-f9dd-4d51-a5db-7c4185c01bd9	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:38:26.363389+00	
00000000-0000-0000-0000-000000000000	6299028a-c61b-4f46-9730-45b02a35e3ac	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:38:26.365442+00	
00000000-0000-0000-0000-000000000000	ecc84110-8d92-4fc2-b953-6bd5116a9b5f	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:38:26.404887+00	
00000000-0000-0000-0000-000000000000	e667ec86-8573-4e1d-ac18-c6c94dfebf3d	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:38:32.600408+00	
00000000-0000-0000-0000-000000000000	5f11d2c9-ff6a-4048-b0c8-8113114509e4	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:38:32.601192+00	
00000000-0000-0000-0000-000000000000	f3b479ba-eab9-4685-b1eb-8fe9b6e74e1f	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:38:32.620537+00	
00000000-0000-0000-0000-000000000000	04351e33-7f6a-40d5-b800-ba025ddb4d25	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 18:38:51.393868+00	
00000000-0000-0000-0000-000000000000	c2d0cd17-df07-482d-8b7b-04beced36c00	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:38:59.808258+00	
00000000-0000-0000-0000-000000000000	52161942-7e9a-4a3b-b787-5e5f3bda50aa	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:38:59.81176+00	
00000000-0000-0000-0000-000000000000	f2e7ffde-3f8c-413e-85da-eaddfee49050	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:38:59.830293+00	
00000000-0000-0000-0000-000000000000	227d0d27-e1c2-44d2-92af-8aeaa82e87fb	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 18:47:10.299342+00	
00000000-0000-0000-0000-000000000000	41c3e8cc-8730-4cd8-817d-a07d9c0bcb4b	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:47:18.369983+00	
00000000-0000-0000-0000-000000000000	0e0adb6d-7833-485d-a51b-1ef2001d391d	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:47:18.372289+00	
00000000-0000-0000-0000-000000000000	e62cf871-9486-4a9a-b12a-21481f3c08a9	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:47:18.389071+00	
00000000-0000-0000-0000-000000000000	5fdca9ed-3ac3-4481-9e11-1d495ae622f7	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 18:48:18.169797+00	
00000000-0000-0000-0000-000000000000	5944faa5-9035-4061-8ea2-2c4d733b72aa	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:48:25.4352+00	
00000000-0000-0000-0000-000000000000	acbc57b9-81e3-4ce8-8430-3cdc86ae5ff4	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:48:25.436561+00	
00000000-0000-0000-0000-000000000000	94a65493-7478-40d3-9113-cba1f8ee24fe	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:48:25.471143+00	
00000000-0000-0000-0000-000000000000	9d1abdce-92e1-4372-96ef-099d632d3e4b	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:49:28.5233+00	
00000000-0000-0000-0000-000000000000	98279dce-a027-4012-bffd-8f90de9eafae	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:49:28.52433+00	
00000000-0000-0000-0000-000000000000	094dcfce-031e-485b-9461-8d3f1ddf5daa	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:49:28.54068+00	
00000000-0000-0000-0000-000000000000	a643f95b-c79a-48b7-aaf8-9bce918fcc45	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 18:49:28.568464+00	
00000000-0000-0000-0000-000000000000	d4607f3a-785c-4526-a22a-0c32395c5b8c	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 18:56:06.943831+00	
00000000-0000-0000-0000-000000000000	0fcac73c-45e8-4de9-848d-4bb5de9eda6c	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:29:17.470272+00	
00000000-0000-0000-0000-000000000000	6e16605e-e208-4af4-9aa3-0492d5b2dceb	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:29:17.495565+00	
00000000-0000-0000-0000-000000000000	22d2b119-8965-47be-9430-330bf0c2344e	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:29:17.563041+00	
00000000-0000-0000-0000-000000000000	4c5af143-37b8-4ebf-965c-7c7d688a3b3d	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:29:19.83964+00	
00000000-0000-0000-0000-000000000000	c9d76a88-ee4f-4b11-972b-7a954eda0fb8	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:29:19.841884+00	
00000000-0000-0000-0000-000000000000	fde6648d-6d6b-4be0-bd5c-b0714ee66fa9	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:29:19.863038+00	
00000000-0000-0000-0000-000000000000	29b1bfc6-dd41-40df-880c-ac3297dd84e6	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:29:19.884243+00	
00000000-0000-0000-0000-000000000000	bc1aaa78-e436-4504-8dc1-569836cbba0a	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 19:29:22.000829+00	
00000000-0000-0000-0000-000000000000	b07c094a-ac6a-4499-888b-31f729a01aa9	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:29:26.477049+00	
00000000-0000-0000-0000-000000000000	5ac5f5c7-9463-44c6-a2f9-f543d892248e	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:29:26.47915+00	
00000000-0000-0000-0000-000000000000	e06d52a9-ba89-433e-9621-866433a57155	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:29:26.496236+00	
00000000-0000-0000-0000-000000000000	11ceb850-f11a-4176-bd87-1f79f4752aa8	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:29:26.526666+00	
00000000-0000-0000-0000-000000000000	0966ce9b-081c-4b4f-85f6-d8528a14e6bc	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:29:29.256963+00	
00000000-0000-0000-0000-000000000000	55bd1e34-7727-4150-b180-e92adeec3688	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:29:29.257953+00	
00000000-0000-0000-0000-000000000000	bf2fc93e-f288-40fb-b9a8-e1f4a35feddd	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:29:29.291163+00	
00000000-0000-0000-0000-000000000000	10927be5-8306-4b2a-9769-133df67f0667	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:29:29.323835+00	
00000000-0000-0000-0000-000000000000	a6744fa9-8016-479d-9ce5-4ccdab3f0b2a	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:30:49.12608+00	
00000000-0000-0000-0000-000000000000	e5d741eb-15a3-4936-9aec-4825d5c5263c	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:30:49.138375+00	
00000000-0000-0000-0000-000000000000	f98fc8f4-8e87-4d8a-91a6-95435fbf5e73	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:30:49.178818+00	
00000000-0000-0000-0000-000000000000	4e602c54-2e9c-485b-b420-6f8faa441c3d	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:30:49.185688+00	
00000000-0000-0000-0000-000000000000	5242dc39-eac5-4e0b-8d73-ffb407e9a06e	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:35:59.12073+00	
00000000-0000-0000-0000-000000000000	dd77f0c0-94ca-461d-9acf-1b5211977127	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:35:59.127431+00	
00000000-0000-0000-0000-000000000000	3baf9038-e402-4985-9e21-8128168559fb	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:35:59.163166+00	
00000000-0000-0000-0000-000000000000	9a002794-e041-4c32-958d-7bdf39c1884f	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:39:17.265421+00	
00000000-0000-0000-0000-000000000000	33c200b5-39f0-4047-ab98-f0ade84ff104	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 19:39:17.267495+00	
00000000-0000-0000-0000-000000000000	a635afe9-cab2-4831-90c6-51391c0f2e8f	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 20:39:08.162641+00	
00000000-0000-0000-0000-000000000000	3b1e26a5-567d-48be-8628-eebae8c06174	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 20:39:08.180174+00	
00000000-0000-0000-0000-000000000000	570b105a-9df4-4372-a17c-854685f678c6	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 20:39:08.345628+00	
00000000-0000-0000-0000-000000000000	4b1b5551-5b24-4bec-b0f7-4796c11f4775	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 20:39:08.346405+00	
00000000-0000-0000-0000-000000000000	b16fa6c3-0926-4c7a-a243-a25e53a0b3e7	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 21:38:59.233774+00	
00000000-0000-0000-0000-000000000000	0958ec15-e7e9-49ea-b90b-a4f14a40898c	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 21:38:59.254724+00	
00000000-0000-0000-0000-000000000000	118f093e-98af-415c-8753-082089f53142	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 21:38:59.471446+00	
00000000-0000-0000-0000-000000000000	691ef581-b90c-4f01-a052-430a645d502c	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 21:38:59.472105+00	
00000000-0000-0000-0000-000000000000	83c39d34-06d7-4665-b0d9-beafc80bf856	{"action":"login","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-16 22:03:04.067958+00	
00000000-0000-0000-0000-000000000000	b3d2e27c-abe3-4419-8287-26f42896abe6	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 23:02:54.859335+00	
00000000-0000-0000-0000-000000000000	d51e42e5-2424-4eb4-9f6a-510403bbb81c	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 23:02:54.884543+00	
00000000-0000-0000-0000-000000000000	b7154a38-5799-43ca-8344-d8b89a69a699	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 23:02:55.125065+00	
00000000-0000-0000-0000-000000000000	e2cbb2ae-30d0-4c0d-9d47-876ebfb6915f	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-16 23:02:55.127007+00	
00000000-0000-0000-0000-000000000000	8f96113a-cbec-4530-9369-fa28f5197c20	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 00:43:29.646371+00	
00000000-0000-0000-0000-000000000000	427c3723-cb8c-48f3-a28c-e5a8dc8203d4	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 00:43:29.668582+00	
00000000-0000-0000-0000-000000000000	1317ba12-3b45-4d38-909f-41808267a915	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 00:43:29.886761+00	
00000000-0000-0000-0000-000000000000	7100770b-4407-48a2-89ad-dcb5cf6ce45e	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 00:43:29.888718+00	
00000000-0000-0000-0000-000000000000	d3c2e3d3-414e-48d9-bdfe-3380a1fe44fe	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 02:43:09.621399+00	
00000000-0000-0000-0000-000000000000	46980178-8366-4686-8c66-d7d89f07063f	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 02:43:09.646817+00	
00000000-0000-0000-0000-000000000000	09220544-d67b-40bd-8909-8344174ed1b9	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 02:43:09.85426+00	
00000000-0000-0000-0000-000000000000	2ab8e46a-ab5b-4918-b157-a852782c71fd	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 02:43:09.856323+00	
00000000-0000-0000-0000-000000000000	059fca2a-6da0-4d1b-b145-acd666382b04	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 04:42:49.450533+00	
00000000-0000-0000-0000-000000000000	26461d44-746d-4e1d-b4d8-efb04a2814d5	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 04:42:49.462406+00	
00000000-0000-0000-0000-000000000000	7faa6627-0e90-4f54-8da3-136828b383f2	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 04:42:49.74047+00	
00000000-0000-0000-0000-000000000000	0bb29973-68d5-4a94-a55a-8ee02ccabc20	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 04:42:49.743274+00	
00000000-0000-0000-0000-000000000000	0795dece-041b-4e68-80a2-66169e8109f4	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 05:42:39.696456+00	
00000000-0000-0000-0000-000000000000	54a32ba7-e69c-401e-852a-53f4379c2d7a	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 06:42:29.553113+00	
00000000-0000-0000-0000-000000000000	424fd9c4-6e33-4d5d-a5fe-6f0d7a6926c7	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 06:42:29.570111+00	
00000000-0000-0000-0000-000000000000	cfe03b32-de7a-4ead-8c0c-2df7400919fd	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 06:42:29.75935+00	
00000000-0000-0000-0000-000000000000	1c1833de-8ce4-4a80-b307-bd20822bd18f	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 06:42:29.76204+00	
00000000-0000-0000-0000-000000000000	cff43fac-3908-4127-a49a-9aec8eef17e8	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 07:42:19.523762+00	
00000000-0000-0000-0000-000000000000	0a159b24-9451-4aba-97a4-b074abe070c0	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 07:42:19.543483+00	
00000000-0000-0000-0000-000000000000	7c964472-5064-448d-8830-8fbfd56cb882	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 07:42:19.800017+00	
00000000-0000-0000-0000-000000000000	18b2d94b-060f-4f00-abcb-af484095881b	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 07:42:19.804304+00	
00000000-0000-0000-0000-000000000000	9a82a246-f9ba-4d3d-9abd-90b2c2bdd2c2	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 08:42:09.681124+00	
00000000-0000-0000-0000-000000000000	44ed6fd6-1678-4d82-819b-fe9c4edc49f6	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 08:42:09.705755+00	
00000000-0000-0000-0000-000000000000	63924415-c2f6-4c31-bfbf-aa70f5713c05	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 08:42:09.931545+00	
00000000-0000-0000-0000-000000000000	e522e798-8a92-425c-944f-1541951c7ae6	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 08:42:09.933587+00	
00000000-0000-0000-0000-000000000000	a50935e0-472d-4aad-baff-c144bec9a756	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 09:41:59.586185+00	
00000000-0000-0000-0000-000000000000	758a9e03-b069-4e05-b81e-ea810998b744	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 09:41:59.597654+00	
00000000-0000-0000-0000-000000000000	21eed6d6-53eb-4d94-929f-e37830d5740c	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 09:41:59.805863+00	
00000000-0000-0000-0000-000000000000	15ad03ac-88cb-4ed3-9bd8-dff685202fa7	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 09:41:59.808476+00	
00000000-0000-0000-0000-000000000000	50b23b89-1da7-4a4b-9248-fc2062e348b9	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-17 10:11:09.039579+00	
00000000-0000-0000-0000-000000000000	ba642134-a059-4d3f-9a54-c943963bf42c	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 10:27:55.817794+00	
00000000-0000-0000-0000-000000000000	566dcc20-7911-464d-b439-13ac5ce068da	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 10:27:55.826365+00	
00000000-0000-0000-0000-000000000000	efff4a38-e97d-4106-a229-d0438fb2938a	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-17 10:28:05.214673+00	
00000000-0000-0000-0000-000000000000	0ce7ddea-72b0-4fbd-8657-f95438efb637	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 10:41:49.025803+00	
00000000-0000-0000-0000-000000000000	70154ca5-a414-41a1-bbaa-7a5a012ec07f	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 10:41:49.031691+00	
00000000-0000-0000-0000-000000000000	a7d022e2-df36-4c9e-b848-f3f1d0d2ef6e	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 10:41:49.116701+00	
00000000-0000-0000-0000-000000000000	23fb4b84-57b4-4b93-9e09-d09b1380a63a	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 10:41:49.117553+00	
00000000-0000-0000-0000-000000000000	8fae2698-2539-44c8-944d-cb7f23b850d8	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 11:21:39.597816+00	
00000000-0000-0000-0000-000000000000	811f8fdd-4e89-4829-b99e-eb7b9cd6465f	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 11:21:39.607338+00	
00000000-0000-0000-0000-000000000000	bcf3970d-1eee-446f-946e-94c0be0f252b	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 11:21:39.662685+00	
00000000-0000-0000-0000-000000000000	85d3163e-8af5-4221-9fb1-74bc1e4df07c	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-17 11:22:53.219239+00	
00000000-0000-0000-0000-000000000000	446e3595-567f-4511-880a-9dcfbbd1bac8	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 11:41:39.540555+00	
00000000-0000-0000-0000-000000000000	e2cc0387-7204-4de5-a703-03b3a91fce6d	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 11:41:39.55875+00	
00000000-0000-0000-0000-000000000000	2825e712-26a8-4539-8831-c3a72bf27a30	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 11:41:39.752591+00	
00000000-0000-0000-0000-000000000000	8d55adbb-a1b1-427e-bcd8-74668b584184	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 11:41:39.754699+00	
00000000-0000-0000-0000-000000000000	5a7ab7cb-4fda-4efa-8196-3cd9f29e8918	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 12:16:20.157244+00	
00000000-0000-0000-0000-000000000000	f2928f05-59b5-4882-8931-0faebc3c9da6	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 12:16:20.170107+00	
00000000-0000-0000-0000-000000000000	832c29bc-8ed8-438d-8da9-e2c92d5bd3c9	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 12:16:20.218868+00	
00000000-0000-0000-0000-000000000000	c9650e7b-d4e2-4fac-a9db-d12fc255063e	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 12:20:31.639451+00	
00000000-0000-0000-0000-000000000000	8285d38a-669d-4e6f-a2e4-ddb58396123c	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 12:20:31.64248+00	
00000000-0000-0000-0000-000000000000	e8f43207-e796-4c9d-b7dd-33c0b5eb4f7a	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 12:20:31.670329+00	
00000000-0000-0000-0000-000000000000	f33b7379-9ee3-4516-addd-c763b5482767	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 12:41:29.06884+00	
00000000-0000-0000-0000-000000000000	581e0993-9d61-43bd-9503-c32c5149752f	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 12:41:29.086092+00	
00000000-0000-0000-0000-000000000000	5547a7cd-6b10-4899-87ba-a465c95c98f6	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 12:41:29.200646+00	
00000000-0000-0000-0000-000000000000	a71d3546-5f13-47ea-abfb-3421e49bfa49	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 12:41:29.201286+00	
00000000-0000-0000-0000-000000000000	15c0812e-5154-4b3b-a7e5-dfcc73e2b610	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 13:41:20.025909+00	
00000000-0000-0000-0000-000000000000	df9ab3d0-c7b0-46cf-bd77-596505856128	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 13:41:20.047811+00	
00000000-0000-0000-0000-000000000000	c47f5cf7-2bcb-4acf-9f8f-cf3b0243141e	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 13:41:20.247555+00	
00000000-0000-0000-0000-000000000000	cff32bb8-33d9-4934-abbc-6e2517b63dbb	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 13:41:20.254824+00	
00000000-0000-0000-0000-000000000000	5dbde67e-ac5b-4019-96bf-cb000a871368	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 14:41:10.837452+00	
00000000-0000-0000-0000-000000000000	5e64d25d-c930-4c55-a39a-2f4fc9395c10	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 14:41:10.856669+00	
00000000-0000-0000-0000-000000000000	460fb689-d3a1-4862-9910-41574651f1ce	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 14:41:11.097539+00	
00000000-0000-0000-0000-000000000000	2879c0ba-9aeb-4495-b53e-021afe23c6e4	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 14:41:11.098396+00	
00000000-0000-0000-0000-000000000000	24a627b4-7478-4c80-a5a5-a2ab4f2fdd04	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 15:41:01.77726+00	
00000000-0000-0000-0000-000000000000	51a69e7f-3a8c-47ec-a7b9-24e46a6d0d8f	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 15:41:01.792088+00	
00000000-0000-0000-0000-000000000000	3247a288-756d-46a1-967a-b3fd68d6b6ab	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 15:41:02.001809+00	
00000000-0000-0000-0000-000000000000	c7e24197-4f5a-4601-8a9d-37549fc0bbdf	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 15:41:02.00256+00	
00000000-0000-0000-0000-000000000000	7757f039-60aa-4113-993d-7aab02bba184	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 16:40:52.691119+00	
00000000-0000-0000-0000-000000000000	3b7e414b-1c76-460d-8d42-46632051e923	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 16:40:52.708053+00	
00000000-0000-0000-0000-000000000000	4f64de44-7e32-4d13-a776-4661dc426d2f	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 16:40:52.935205+00	
00000000-0000-0000-0000-000000000000	4cc899bd-2f57-4bd0-a042-98655e6b22df	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 16:40:52.935939+00	
00000000-0000-0000-0000-000000000000	e87b8b8a-b6df-4351-8468-32daebc8692d	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 17:40:43.613313+00	
00000000-0000-0000-0000-000000000000	19368cf2-d175-4d21-9f32-cfe2ffeda1df	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 17:40:43.625845+00	
00000000-0000-0000-0000-000000000000	814718ce-a7b8-4ecc-8304-9f8913eb1c00	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 17:40:43.856127+00	
00000000-0000-0000-0000-000000000000	154e9ace-ac20-413f-8e91-d45d18f9fd43	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 17:40:43.858612+00	
00000000-0000-0000-0000-000000000000	1af208e9-7eb6-42d2-b9ac-a66d0583c45d	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 20:18:29.034538+00	
00000000-0000-0000-0000-000000000000	32a8a9a4-8da4-414d-befb-a935161614c7	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 20:18:29.045752+00	
00000000-0000-0000-0000-000000000000	5cd1cf1c-f922-4d96-834d-d17e175ad874	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-17 20:29:18.738372+00	
00000000-0000-0000-0000-000000000000	2e01e2b1-ab4e-4ca0-8c22-42c909d0602c	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 21:11:18.532008+00	
00000000-0000-0000-0000-000000000000	607f50ec-b949-487e-be51-8ccd1fbdc308	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 21:11:18.547403+00	
00000000-0000-0000-0000-000000000000	f5819eca-9821-41d8-bfb7-0fbc3b84c002	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 21:11:18.85465+00	
00000000-0000-0000-0000-000000000000	e494959c-44cf-4d8d-a280-1e850cd6041a	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 21:28:55.693967+00	
00000000-0000-0000-0000-000000000000	a36b5654-1585-4ece-8abb-59bdc2d2a7b5	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 21:28:55.707688+00	
00000000-0000-0000-0000-000000000000	0b5bbe8e-729b-48da-92a1-355aaeaff3b9	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 21:28:55.759022+00	
00000000-0000-0000-0000-000000000000	b9712bbb-f65a-46f0-9ff4-82f9db169863	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 22:28:48.265045+00	
00000000-0000-0000-0000-000000000000	5750e182-048d-4830-b7b8-832a9e301980	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 22:28:48.282822+00	
00000000-0000-0000-0000-000000000000	703172e3-fe91-4cba-846f-db3e8d7c2783	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 22:28:48.406016+00	
00000000-0000-0000-0000-000000000000	932a27d3-a4d1-41b2-827c-9ef2e4eb76fb	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 22:28:48.408442+00	
00000000-0000-0000-0000-000000000000	87c387c9-8283-4fde-9885-3f1157120bb6	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 23:28:40.633729+00	
00000000-0000-0000-0000-000000000000	1a9d4d6e-11f8-4097-8112-cdf98acdb510	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 23:28:40.65751+00	
00000000-0000-0000-0000-000000000000	5027b1dc-c9b8-4991-a9e0-5badaddcc2de	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 23:28:41.521578+00	
00000000-0000-0000-0000-000000000000	7732139a-7131-41dc-bb0e-59815cf5846d	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-17 23:28:41.530209+00	
00000000-0000-0000-0000-000000000000	0d56c2fb-7f07-4323-9b9a-697ca2d071de	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 00:11:44.377969+00	
00000000-0000-0000-0000-000000000000	840dbcfc-0ca7-447c-a031-3ebcf47754c3	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 00:11:44.397725+00	
00000000-0000-0000-0000-000000000000	b944f376-db30-4dc0-bb4b-94f0b30a6973	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 00:11:44.59405+00	
00000000-0000-0000-0000-000000000000	85a59937-8502-4bb4-a555-f030f7f8fdae	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 00:11:44.595972+00	
00000000-0000-0000-0000-000000000000	6377a567-dab2-4579-a9c0-a5a1a77a3626	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 00:28:33.727278+00	
00000000-0000-0000-0000-000000000000	a99a6567-a543-4241-85d2-e5e98bd366a8	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 00:28:33.734175+00	
00000000-0000-0000-0000-000000000000	856abb60-0a76-48e0-90c2-75c06080dd87	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 00:28:34.219329+00	
00000000-0000-0000-0000-000000000000	533502ca-6955-4342-8149-8c0022e375e3	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 00:28:34.220721+00	
00000000-0000-0000-0000-000000000000	81174ec3-de86-4085-aa55-4d59717b4b0e	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 01:11:34.135457+00	
00000000-0000-0000-0000-000000000000	77deae72-a258-4073-9968-aabd481f81a5	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 01:11:34.146742+00	
00000000-0000-0000-0000-000000000000	4e286eb3-ab96-4197-87a5-915339cfc134	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 01:28:26.248338+00	
00000000-0000-0000-0000-000000000000	0df7a8f8-a5de-4c2a-956e-ed89fc691a53	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 01:28:26.253655+00	
00000000-0000-0000-0000-000000000000	e65f810d-af26-4fcc-98b5-c48209cb1952	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 01:28:27.074489+00	
00000000-0000-0000-0000-000000000000	954d2eba-0b38-49cd-935c-0c54fa58bf54	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 01:28:27.075971+00	
00000000-0000-0000-0000-000000000000	788320b3-f248-4cbd-9b4c-0a826e746b90	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-18 01:58:23.682918+00	
00000000-0000-0000-0000-000000000000	59061bbe-9ff6-4e12-a796-db84a2b7f009	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 02:11:24.574428+00	
00000000-0000-0000-0000-000000000000	bd1c7f48-a37e-46b7-8451-d362b21da359	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 02:11:24.583425+00	
00000000-0000-0000-0000-000000000000	f9def8dc-c66a-4d44-b407-877d5c740f5d	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 02:11:24.699717+00	
00000000-0000-0000-0000-000000000000	bb6c8f9f-7020-40c7-bbd5-57369abfd416	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 02:11:24.701433+00	
00000000-0000-0000-0000-000000000000	082e364f-7181-4350-9ae7-84e6025ead9d	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 02:38:38.958355+00	
00000000-0000-0000-0000-000000000000	f5a124a0-52c1-498b-a5ec-9a91c84e4ffe	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 02:38:38.98422+00	
00000000-0000-0000-0000-000000000000	eac2bb2e-cbe9-42f3-af0e-dae0f74a7045	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-18 02:49:26.502259+00	
00000000-0000-0000-0000-000000000000	82774364-44ee-4e21-9379-01852cc8dffe	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-18 02:56:08.56245+00	
00000000-0000-0000-0000-000000000000	4029b145-7f78-4c72-9dbb-2f19eeb1a55f	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 02:56:35.774347+00	
00000000-0000-0000-0000-000000000000	9281f958-fdd2-4b99-983f-d481b765a984	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 02:56:35.776345+00	
00000000-0000-0000-0000-000000000000	82067a72-991b-47a9-950a-f99427d56c93	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 02:56:35.809649+00	
00000000-0000-0000-0000-000000000000	802ab828-a3ce-4478-9a66-57e455c38cf2	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 02:58:14.18349+00	
00000000-0000-0000-0000-000000000000	bff52324-8751-4876-acf3-0837a6856891	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 02:58:14.185509+00	
00000000-0000-0000-0000-000000000000	25b66bad-81b4-40f6-9324-7dc1f231f878	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 02:58:14.311879+00	
00000000-0000-0000-0000-000000000000	9eba061c-62ac-46f6-bf38-ddeb42369343	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 02:58:14.313231+00	
00000000-0000-0000-0000-000000000000	f7bf75eb-067a-4985-b360-e5194ffd4abf	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-18 03:17:11.824999+00	
00000000-0000-0000-0000-000000000000	ba417944-5326-4a1c-8690-e00bc3c9fd73	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 03:24:55.140077+00	
00000000-0000-0000-0000-000000000000	22da25fd-140e-4ec9-a5b7-f9708385bfc4	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 03:24:55.155159+00	
00000000-0000-0000-0000-000000000000	843f4597-14b3-4b8f-9033-f7a8f02e088b	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 03:24:55.190315+00	
00000000-0000-0000-0000-000000000000	26d6f8ed-8258-46f4-bbcb-2bfde689bf09	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-18 03:27:28.359002+00	
00000000-0000-0000-0000-000000000000	7bcb69df-0205-480f-ad23-ef147dff6bb9	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-18 03:27:52.578125+00	
00000000-0000-0000-0000-000000000000	ca177097-b3bd-4d77-8181-a8358ae300cc	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-18 03:47:24.822833+00	
00000000-0000-0000-0000-000000000000	013a7d3f-7eae-49bc-b911-3f98e9c788da	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-18 03:52:01.105244+00	
00000000-0000-0000-0000-000000000000	3a5f5b50-4bce-462f-aa5c-18d828705149	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 03:57:26.005416+00	
00000000-0000-0000-0000-000000000000	d706821e-751f-4ded-91b9-80686c0b1109	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 03:57:26.009657+00	
00000000-0000-0000-0000-000000000000	d1e079aa-4e2c-4ef2-98ee-2a1500429b87	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 03:57:26.045961+00	
00000000-0000-0000-0000-000000000000	8fc96460-605c-46aa-8cbc-92bd25f7ea28	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 03:57:29.674053+00	
00000000-0000-0000-0000-000000000000	3b375984-f527-4d91-8d86-87e67846584c	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 03:57:29.676885+00	
00000000-0000-0000-0000-000000000000	e05fe9f9-fc49-4cde-a53e-2f230f4d248f	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 03:57:29.693283+00	
00000000-0000-0000-0000-000000000000	6399a91e-b13a-464d-a6c0-9e475902d884	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-18 03:58:20.868467+00	
00000000-0000-0000-0000-000000000000	878f135e-46d1-47b3-a9ae-8fdb5f223d33	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-18 04:12:44.159834+00	
00000000-0000-0000-0000-000000000000	53ce34d5-de72-4d75-beb0-c698ea9104ce	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 04:33:02.415866+00	
00000000-0000-0000-0000-000000000000	d5ea8f0c-6c4b-43b5-bc73-27beb9553579	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 04:33:02.430361+00	
00000000-0000-0000-0000-000000000000	2071a0e3-ce88-4cf6-af12-1362ef0fd5f9	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 04:33:02.471872+00	
00000000-0000-0000-0000-000000000000	dbe8f934-20b1-42ec-9f18-d16aafb2e2e7	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-18 04:33:25.176952+00	
00000000-0000-0000-0000-000000000000	051f4115-0ab3-42f7-a4bd-b1000b159845	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 04:40:52.041783+00	
00000000-0000-0000-0000-000000000000	f5619786-3cae-48e2-a2a9-d6754fa3ecc1	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 04:40:52.044328+00	
00000000-0000-0000-0000-000000000000	67cbc81c-efdb-4511-a63a-25f600f83715	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 04:40:52.17079+00	
00000000-0000-0000-0000-000000000000	b8611996-1b72-4040-9b76-3e5380154947	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 04:40:52.172701+00	
00000000-0000-0000-0000-000000000000	8be950fd-d8c7-42bc-ba4e-cbb2bf397fee	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 05:25:10.760876+00	
00000000-0000-0000-0000-000000000000	4b90877b-34c5-4ee3-8d0f-a8b1e08649b2	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 05:25:10.773166+00	
00000000-0000-0000-0000-000000000000	ae6b0fbe-bb8a-4c15-a813-c26f5d5190ed	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 05:25:10.818199+00	
00000000-0000-0000-0000-000000000000	76db5d7d-f34d-4214-9ddb-f16e41b33095	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-18 05:32:54.747245+00	
00000000-0000-0000-0000-000000000000	d5d63265-1d48-417f-874b-319ed07367c2	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 05:40:42.462587+00	
00000000-0000-0000-0000-000000000000	0f8c1e9f-41cf-4263-abf7-979a64a7df04	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 05:40:42.465389+00	
00000000-0000-0000-0000-000000000000	aed9f3bd-c04b-47b8-8231-a207e8657166	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 05:40:42.553428+00	
00000000-0000-0000-0000-000000000000	b8cfa944-6d7c-488c-8ccd-28862efec65f	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 05:40:42.554241+00	
00000000-0000-0000-0000-000000000000	7f2e096d-c381-4f97-8473-374f62a2f5f2	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 06:09:35.008793+00	
00000000-0000-0000-0000-000000000000	696a94e6-8f90-4b4d-9f9d-a60c37d14d85	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 06:09:35.024012+00	
00000000-0000-0000-0000-000000000000	b04cfcc4-33c7-42dd-b6f8-84ea6fe6f5c4	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 06:09:35.06931+00	
00000000-0000-0000-0000-000000000000	04dc5be3-4b90-4a69-b1a2-56f96fd6f86a	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 06:19:42.94483+00	
00000000-0000-0000-0000-000000000000	bca83c86-be2f-48c9-9cd3-c54820fd87d7	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 06:19:42.954638+00	
00000000-0000-0000-0000-000000000000	a06bfd98-21a9-473a-beb7-60804af5b9c1	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 06:19:42.997223+00	
00000000-0000-0000-0000-000000000000	5cdcb872-c6aa-4e44-9fbd-ce821a871f1a	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 06:20:02.080076+00	
00000000-0000-0000-0000-000000000000	942a61de-9ad5-4ee3-afa6-cb233e01fd72	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 06:20:02.082988+00	
00000000-0000-0000-0000-000000000000	68c19c51-b2a2-46ac-922c-ecd5c5be2f1f	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 06:20:02.096589+00	
00000000-0000-0000-0000-000000000000	2893d355-0974-423d-8352-4c295fc7727f	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 06:40:32.063977+00	
00000000-0000-0000-0000-000000000000	d15bea6f-78b4-4872-ac9d-2b7cd36f5e83	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 06:40:32.080633+00	
00000000-0000-0000-0000-000000000000	343fc493-e964-44c5-9ee2-d4d70d0462b6	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 06:40:32.211663+00	
00000000-0000-0000-0000-000000000000	cae385ef-bc4a-434f-a6a6-70cc545efd83	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 06:40:32.214809+00	
00000000-0000-0000-0000-000000000000	1262423e-93fa-4b0b-a034-846ef3d59a75	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-18 06:47:40.518406+00	
00000000-0000-0000-0000-000000000000	3b58e056-976a-4489-9884-f151fecb5f70	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-18 07:20:34.59365+00	
00000000-0000-0000-0000-000000000000	646cd84e-eba9-4ed5-be33-b035574139b8	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 07:40:22.554281+00	
00000000-0000-0000-0000-000000000000	4c928419-6db2-447d-bbb6-e7fec6ef0157	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 07:40:22.57195+00	
00000000-0000-0000-0000-000000000000	d50fed02-15f1-4f98-b96a-08674c7c432a	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 07:40:22.691622+00	
00000000-0000-0000-0000-000000000000	015c9b50-c6c1-41b5-8302-c240e65a5ac8	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-18 07:40:22.694375+00	
00000000-0000-0000-0000-000000000000	9d20f8b5-2417-4de3-a760-9d448456d568	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 07:42:29.565466+00	
00000000-0000-0000-0000-000000000000	cf24e451-2c6b-4c62-9942-30520471bbfe	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 07:42:29.569352+00	
00000000-0000-0000-0000-000000000000	491e5226-3d9c-4d03-98cd-36a6338ecd6e	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 07:42:29.609996+00	
00000000-0000-0000-0000-000000000000	686d2e1d-a7a6-417f-a8cf-c262a2cc8af1	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 07:42:42.325162+00	
00000000-0000-0000-0000-000000000000	64402af2-77d0-4089-9559-60ae6ae31523	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 07:42:42.326749+00	
00000000-0000-0000-0000-000000000000	0c1ea818-64cd-4306-9c64-6c170db1e302	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-18 07:42:42.369633+00	
00000000-0000-0000-0000-000000000000	bef5d968-fa77-4ffd-a07e-dbb882f497f9	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-19 03:30:46.981808+00	
00000000-0000-0000-0000-000000000000	09c45774-8e1b-4161-b995-cd73f919370d	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-19 03:30:47.000996+00	
00000000-0000-0000-0000-000000000000	1be4eca2-bb4d-4e30-9534-47eed270cf75	{"action":"token_refreshed","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-19 03:30:47.245362+00	
00000000-0000-0000-0000-000000000000	ed13f91e-bfcd-4e30-b90a-4833285c0267	{"action":"token_revoked","actor_id":"78467702-b492-451b-a9f1-2059dbdd433e","actor_username":"faithmontemayor@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-19 03:30:47.246884+00	
00000000-0000-0000-0000-000000000000	41858947-b34b-4cca-a7a4-c216210c0170	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-19 06:31:15.564868+00	
00000000-0000-0000-0000-000000000000	df246a77-1494-4768-a7f7-ce67465cb57e	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-19 06:31:15.586487+00	
00000000-0000-0000-0000-000000000000	2bf4dabb-e75b-44af-be82-318ab79c0b9a	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-20 00:47:33.233628+00	
00000000-0000-0000-0000-000000000000	fac1752f-02c5-47e7-a885-4626a27ad78a	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-20 00:47:33.25702+00	
00000000-0000-0000-0000-000000000000	45ee5cd7-c815-4dec-b54c-15fd4dd3cc04	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-20 00:47:41.640791+00	
00000000-0000-0000-0000-000000000000	158f1966-4031-498e-9cac-c62708565a99	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-20 00:48:29.49685+00	
00000000-0000-0000-0000-000000000000	2d1b111e-00d8-4fcd-aba1-250770043440	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-20 00:48:29.503315+00	
00000000-0000-0000-0000-000000000000	1d9d9870-f0c2-4773-b346-f1bc95450141	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-20 00:48:29.524132+00	
00000000-0000-0000-0000-000000000000	f27c1045-c13a-4f18-9fae-58956a43284c	{"action":"token_refreshed","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-24 00:47:13.984712+00	
00000000-0000-0000-0000-000000000000	9d811a8c-9ff2-4e92-a33c-660e8e48727b	{"action":"token_revoked","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"token"}	2025-09-24 00:47:14.01182+00	
00000000-0000-0000-0000-000000000000	2c76d71f-9539-49c0-b8a4-6a6e403ed9bb	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-24 00:47:21.047445+00	
00000000-0000-0000-0000-000000000000	53c712f9-eb19-4e2a-bff3-68d34097b2d6	{"action":"login","actor_id":"bf250d15-2188-413b-b954-120a31ca5840","actor_username":"mikefeschenko@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-24 01:46:18.558644+00	
00000000-0000-0000-0000-000000000000	e63fa40e-bba4-4e91-9d51-51454d0f1fa9	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"corbinwest@csus.edu","user_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","user_phone":""}}	2025-09-26 22:05:34.968444+00	
00000000-0000-0000-0000-000000000000	b83a1aba-4981-4c0f-8cce-20d285e18210	{"action":"login","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-26 22:39:16.307348+00	
00000000-0000-0000-0000-000000000000	160e6e24-543d-4a9d-aa41-22906585765b	{"action":"user_recovery_requested","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-09-26 22:42:09.84861+00	
00000000-0000-0000-0000-000000000000	38f69386-7698-4255-b78a-54e55f03fd11	{"action":"login","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-09-26 22:42:22.724173+00	
00000000-0000-0000-0000-000000000000	d4b45186-2599-4422-91cc-1b20d9865756	{"action":"login","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-26 22:43:51.510773+00	
00000000-0000-0000-0000-000000000000	ea682a8c-58ab-46b2-a1e1-d55e8af053ae	{"action":"user_recovery_requested","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-09-26 22:55:11.839776+00	
00000000-0000-0000-0000-000000000000	3550a8a1-1704-41b2-950e-ecf9ca71e5c2	{"action":"login","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-09-26 22:55:35.44981+00	
00000000-0000-0000-0000-000000000000	357674c4-901a-4da9-8f69-ce85d4f177f1	{"action":"user_recovery_requested","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-09-26 22:58:01.828528+00	
00000000-0000-0000-0000-000000000000	cb4697dc-46ba-4321-9f2f-e890a99c5140	{"action":"login","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-09-26 22:58:14.909063+00	
00000000-0000-0000-0000-000000000000	2ebc734e-4b25-4087-8628-e70eb0aac287	{"action":"login","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-26 23:01:18.975607+00	
00000000-0000-0000-0000-000000000000	6d3c2112-04c7-4a70-8db9-65abbf4b1c11	{"action":"user_recovery_requested","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-09-26 23:02:08.526738+00	
00000000-0000-0000-0000-000000000000	e1d96caf-bcd8-4eec-9287-92bc012c4138	{"action":"login","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-09-26 23:02:17.260207+00	
00000000-0000-0000-0000-000000000000	0b545f10-d522-4272-b219-af1e48a4931f	{"action":"user_recovery_requested","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-09-26 23:08:19.126416+00	
00000000-0000-0000-0000-000000000000	a60e37a8-8ae8-4495-9911-90487a495d79	{"action":"login","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-09-26 23:08:32.528703+00	
00000000-0000-0000-0000-000000000000	3be04ce9-00dd-48d4-ac6b-2a89c52676c2	{"action":"user_recovery_requested","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-09-26 23:09:46.602561+00	
00000000-0000-0000-0000-000000000000	4e9b0a6f-e3c4-4771-9546-4606c466e7db	{"action":"login","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-09-26 23:09:57.990172+00	
00000000-0000-0000-0000-000000000000	42558c88-e6d6-4e6f-bc71-2c31cb8953fd	{"action":"user_recovery_requested","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-09-26 23:15:04.096243+00	
00000000-0000-0000-0000-000000000000	68205066-d923-4f7f-87a0-a13d3ab9a781	{"action":"login","actor_id":"c607bf29-70df-4b8d-9ffe-1f7329a76880","actor_username":"corbinwest@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-09-26 23:15:08.490914+00	
00000000-0000-0000-0000-000000000000	76719752-9628-423d-9f6c-a501e3e09c46	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"xiangfeng@csus.edu","user_id":"0b2cf935-fb93-4d9c-ba58-0b3e6c8f3d7c","user_phone":""}}	2025-09-27 19:51:33.726607+00	
00000000-0000-0000-0000-000000000000	68c3fc29-d064-4c54-a249-e169e2d4497f	{"action":"user_recovery_requested","actor_id":"0b2cf935-fb93-4d9c-ba58-0b3e6c8f3d7c","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"user"}	2025-09-27 19:57:29.095296+00	
00000000-0000-0000-0000-000000000000	f72afefb-586d-40b3-a396-bb65f03dc3b5	{"action":"login","actor_id":"0b2cf935-fb93-4d9c-ba58-0b3e6c8f3d7c","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account"}	2025-09-27 19:57:48.111257+00	
00000000-0000-0000-0000-000000000000	5b8f0d4d-3b2b-4d4f-a91e-ed4d8c48239c	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"xiangfeng@csus.edu","user_id":"0b2cf935-fb93-4d9c-ba58-0b3e6c8f3d7c","user_phone":""}}	2025-09-27 20:00:07.614067+00	
00000000-0000-0000-0000-000000000000	a4446461-0f21-4b77-93dd-880fcc479f21	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"xiangfeng@csus.edu","user_id":"05498f83-18ab-4ba9-b663-767df738a0da","user_phone":""}}	2025-09-27 20:00:34.615322+00	
00000000-0000-0000-0000-000000000000	ea1941e0-85e0-42cb-abe4-908c352a342b	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-27 20:12:52.558949+00	
00000000-0000-0000-0000-000000000000	bef7d162-87a8-4d6f-bfeb-9ca06c709627	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-27 20:12:53.604411+00	
00000000-0000-0000-0000-000000000000	ea152be6-8a78-4687-9ab0-280e245f34d3	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-27 20:12:53.608723+00	
00000000-0000-0000-0000-000000000000	451f1552-cd43-4ba7-b6bd-b8b4ad321da4	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-27 20:12:53.661687+00	
00000000-0000-0000-0000-000000000000	85c9fd64-6892-4e66-a1a7-4f8796305a16	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-27 20:13:00.908699+00	
00000000-0000-0000-0000-000000000000	243ea4e7-671a-413a-9ec2-df44cf4cc557	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-27 20:13:00.911834+00	
00000000-0000-0000-0000-000000000000	7d273f03-fab2-47b2-8c4b-19d37e2fe1d5	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-27 20:13:06.514115+00	
00000000-0000-0000-0000-000000000000	463506d3-2df0-4c12-a4f6-a02caba9192a	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-27 20:13:06.518961+00	
00000000-0000-0000-0000-000000000000	b4345ddf-2bb0-4377-b980-80d944fd6bf6	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-27 20:13:06.535837+00	
00000000-0000-0000-0000-000000000000	6b4e1571-1451-436a-aeec-7f32c225279d	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-27 20:13:07.88465+00	
00000000-0000-0000-0000-000000000000	502ac722-2a71-4bb2-83e9-df05decc2448	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-27 20:13:07.88673+00	
00000000-0000-0000-0000-000000000000	20b936a6-66c4-40dc-8a32-6c5ecd2e77da	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-27 20:13:07.910944+00	
00000000-0000-0000-0000-000000000000	dcbfc4e9-3de3-4b31-ab9c-2066b2dd5f1d	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-27 21:28:58.258237+00	
00000000-0000-0000-0000-000000000000	7ec93a27-c81c-4119-b9b2-b9073953548e	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-27 21:55:41.929283+00	
00000000-0000-0000-0000-000000000000	f09f50c4-d6f8-488a-b5d7-6b99a688518b	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 03:27:17.528104+00	
00000000-0000-0000-0000-000000000000	610a377f-456a-47fc-9f11-e86d201b7c99	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 03:27:17.54467+00	
00000000-0000-0000-0000-000000000000	7fab8818-31f6-4d71-ae1c-0730b26a53bf	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 03:27:17.722363+00	
00000000-0000-0000-0000-000000000000	b194b7ee-e1d3-4006-ad4e-aa475b906ed9	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 03:27:17.724249+00	
00000000-0000-0000-0000-000000000000	72bd0505-dbd0-4244-99a9-517e97899fe9	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-28 18:18:56.73999+00	
00000000-0000-0000-0000-000000000000	97544cdd-84d7-494a-a824-2498d4e5028c	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:01:44.969143+00	
00000000-0000-0000-0000-000000000000	5af2bf58-138e-4f46-945d-58bdbd9c00bb	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:01:44.994875+00	
00000000-0000-0000-0000-000000000000	37aa9f62-c699-4801-9b57-cc96c5e778bb	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:01:45.06272+00	
00000000-0000-0000-0000-000000000000	941d9ec9-af3b-4b2e-b3d1-d9308b6c0d17	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:01:45.089901+00	
00000000-0000-0000-0000-000000000000	c0d0d58c-70a6-479a-a062-e8bfabeb36c9	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:01:45.115256+00	
00000000-0000-0000-0000-000000000000	2012adfc-d97f-480c-8bcd-0f894d70e853	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:01:54.746468+00	
00000000-0000-0000-0000-000000000000	614b72ad-9748-4b14-b23a-2aa9e4d22cae	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:01:54.750638+00	
00000000-0000-0000-0000-000000000000	17713e00-1cd7-476a-ac79-c379367a921f	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:01:54.765189+00	
00000000-0000-0000-0000-000000000000	ad8866be-f341-4068-9619-b4543dbdd8d8	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-28 22:02:33.669639+00	
00000000-0000-0000-0000-000000000000	31c816d7-ddb5-4077-9d2a-df29ccccae16	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:02:41.502449+00	
00000000-0000-0000-0000-000000000000	a9a2bab3-f795-4e52-945e-0beda5e4119c	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:02:41.507687+00	
00000000-0000-0000-0000-000000000000	86dde397-50b4-414f-b02e-f5c6eb5fc3ec	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:02:41.562503+00	
00000000-0000-0000-0000-000000000000	1bda8964-e1f7-4e1c-b50f-e5591bd5006f	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:02:41.580339+00	
00000000-0000-0000-0000-000000000000	825c8422-b22f-4d6b-9d11-34a2b23ea79e	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:02:41.638742+00	
00000000-0000-0000-0000-000000000000	722cc915-a148-427d-9ec8-8c8c4d59ffab	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:03:54.166822+00	
00000000-0000-0000-0000-000000000000	e2decad7-c948-4b6b-8983-444b7e193f35	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:03:54.168087+00	
00000000-0000-0000-0000-000000000000	450a4770-4fd8-44ea-8d6a-184336e77843	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:03:54.199481+00	
00000000-0000-0000-0000-000000000000	1f2bfda2-f924-48a8-b3a6-32b68fa9fdc1	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:05:12.480655+00	
00000000-0000-0000-0000-000000000000	6b3c2d3f-6896-4a68-b465-f0b8e8a1568c	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:05:12.481411+00	
00000000-0000-0000-0000-000000000000	7d4c6c67-7870-4dbc-aa36-2405a817c422	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:05:12.506822+00	
00000000-0000-0000-0000-000000000000	6cd2de58-23b6-439d-9cca-3a8e3ad563ea	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:05:23.126071+00	
00000000-0000-0000-0000-000000000000	76a624e9-012e-4b88-85bf-557272810730	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:05:23.127996+00	
00000000-0000-0000-0000-000000000000	92b2f141-b405-4427-8d9d-935d16fe2e1f	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:05:23.147515+00	
00000000-0000-0000-0000-000000000000	cb373f73-f3f2-4ead-a1b5-3399e0658ddf	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:17:39.936195+00	
00000000-0000-0000-0000-000000000000	1afb6b29-21df-428d-9817-78a572be3e86	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:17:39.940503+00	
00000000-0000-0000-0000-000000000000	529a4b05-ffd7-4c87-a3aa-d9559e9dce46	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-28 22:17:39.973947+00	
00000000-0000-0000-0000-000000000000	617cf300-22ce-462e-9114-74c252686ba2	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 00:15:57.700698+00	
00000000-0000-0000-0000-000000000000	94471545-6763-46fa-b82b-2feb044f745f	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 00:15:57.726418+00	
00000000-0000-0000-0000-000000000000	7636c1da-43f8-427a-ac4e-2c8cf9993aa1	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 00:15:57.800066+00	
00000000-0000-0000-0000-000000000000	d63115b9-8e9f-492b-992c-18f4d4766760	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 00:15:57.822981+00	
00000000-0000-0000-0000-000000000000	49eabd70-8148-4c63-832c-ba0a15095f6f	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 00:15:57.839422+00	
00000000-0000-0000-0000-000000000000	90b9906a-ee8f-45b2-ba9d-ceef5bfad34f	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 00:16:41.944543+00	
00000000-0000-0000-0000-000000000000	0fbf5446-83a0-4f9f-ad16-8dc536bb1b55	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 00:16:41.947042+00	
00000000-0000-0000-0000-000000000000	4e87c248-e7b5-4173-b3f9-28c7fc3de4ee	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 00:16:41.974011+00	
00000000-0000-0000-0000-000000000000	5beacf29-786b-4cfc-8f77-3739a88118c7	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 01:17:58.683254+00	
00000000-0000-0000-0000-000000000000	0a410228-8a0c-44b1-a593-a0189c861fab	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 01:17:58.70826+00	
00000000-0000-0000-0000-000000000000	13799105-589e-4ca7-a9f7-fae7779b5195	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 01:17:58.76567+00	
00000000-0000-0000-0000-000000000000	56671f55-c006-46e1-ac28-401463c2fc81	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 01:17:58.777781+00	
00000000-0000-0000-0000-000000000000	945d8166-65b8-4188-98e9-9778f664d71a	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 01:18:11.874668+00	
00000000-0000-0000-0000-000000000000	047f737e-5043-4b45-a06d-b008b6c61245	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 01:18:11.878369+00	
00000000-0000-0000-0000-000000000000	3ac4e860-3938-4c1c-bf61-ef221f8ca600	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 01:18:11.910144+00	
00000000-0000-0000-0000-000000000000	b826dd5a-e66a-4a77-906f-182d457fbafc	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 01:18:11.940126+00	
00000000-0000-0000-0000-000000000000	926d5525-ec5b-468f-9ddc-4b37dafc955e	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 01:18:16.311922+00	
00000000-0000-0000-0000-000000000000	9405d175-6de3-43a9-92de-3f8cc630cf49	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 01:18:56.817968+00	
00000000-0000-0000-0000-000000000000	ce9f8d72-0073-4f15-90d3-953d542dee16	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 01:52:20.35561+00	
00000000-0000-0000-0000-000000000000	b7684851-d34f-4da1-b3d2-c2d4b5032cf3	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 01:55:24.101971+00	
00000000-0000-0000-0000-000000000000	8af9924f-945a-4eaf-b3b5-19b40be01002	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 01:55:27.063685+00	
00000000-0000-0000-0000-000000000000	419c9c4f-06bc-45f0-804f-8d554343cf00	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 01:55:39.631113+00	
00000000-0000-0000-0000-000000000000	3b13a4b1-e2bd-4801-a10e-12f786bfb58f	{"action":"login","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 01:58:48.669797+00	
00000000-0000-0000-0000-000000000000	8b25bcaf-c3e9-4a79-a163-365bc4f83700	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 02:38:08.334194+00	
00000000-0000-0000-0000-000000000000	457f1444-b642-4f25-9ba3-6834bc0c2036	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 02:38:08.362071+00	
00000000-0000-0000-0000-000000000000	120af979-e727-44df-aded-bdf91b5640cd	{"action":"login","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 02:38:13.941848+00	
00000000-0000-0000-0000-000000000000	f0e681f5-233d-4fe0-89c7-d74aea46fe4c	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 02:56:51.042576+00	
00000000-0000-0000-0000-000000000000	08be7404-61ff-400e-a458-9967872b012b	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 02:56:51.053411+00	
00000000-0000-0000-0000-000000000000	8639f607-bb48-4bb3-8ff6-0de3413ab84e	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 03:43:52.794512+00	
00000000-0000-0000-0000-000000000000	6b521b0d-11bf-42a9-b468-1647db3690f0	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 03:43:52.810913+00	
00000000-0000-0000-0000-000000000000	00f39d98-47b9-4c9a-9e36-dfed1a597f50	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 03:43:54.549885+00	
00000000-0000-0000-0000-000000000000	fcbaf2b8-ae74-45c7-9162-c70dab862cdb	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 03:43:54.551309+00	
00000000-0000-0000-0000-000000000000	470f3a06-b0a3-45a1-a507-4633de059ba1	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 03:43:58.967786+00	
00000000-0000-0000-0000-000000000000	e563d1b9-bbb4-48c5-863d-a9306f833809	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 03:56:41.497062+00	
00000000-0000-0000-0000-000000000000	4ebe5d2a-3ca0-4548-a21b-634370115348	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 03:56:41.524694+00	
00000000-0000-0000-0000-000000000000	6960d73e-a31e-4762-91a7-de7063d55699	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 03:56:41.66905+00	
00000000-0000-0000-0000-000000000000	2043092d-a011-4f59-942e-38870c49cede	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 03:56:41.671553+00	
00000000-0000-0000-0000-000000000000	c1056c15-b778-4249-99d7-9b3822b1d95e	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 04:01:50.678087+00	
00000000-0000-0000-0000-000000000000	abfbc136-d9f3-45ec-91e4-1d0044af0425	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 04:03:44.780964+00	
00000000-0000-0000-0000-000000000000	e7b1371e-8f08-4c04-866b-f8ccf2738af4	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 04:16:11.582806+00	
00000000-0000-0000-0000-000000000000	abadfa28-c2ab-4b84-ac63-741f90ca8bd2	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 04:21:13.037039+00	
00000000-0000-0000-0000-000000000000	a14b11ab-d918-42a8-aa99-e1f46542b398	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 04:40:32.345156+00	
00000000-0000-0000-0000-000000000000	336e6817-0f94-4e67-8973-4354b4f8bb40	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 04:46:15.867895+00	
00000000-0000-0000-0000-000000000000	771f6119-3737-45e4-af92-cc934e4f188f	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 04:46:15.878579+00	
00000000-0000-0000-0000-000000000000	5a1b7591-b983-4b2e-a334-9d559b7ae071	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 04:52:15.782479+00	
00000000-0000-0000-0000-000000000000	6f48ffe7-551b-4bfa-bc6f-c7b3066c88bf	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 04:52:36.364763+00	
00000000-0000-0000-0000-000000000000	baf7a794-83e9-4e34-b70b-39056f651195	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 04:52:38.278598+00	
00000000-0000-0000-0000-000000000000	f45f8956-9f37-4727-b63b-e68746b9f4bf	{"action":"login","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 05:20:51.983955+00	
00000000-0000-0000-0000-000000000000	c8928e96-a931-441e-8047-da78a2e655f0	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 05:36:54.327403+00	
00000000-0000-0000-0000-000000000000	aa397eee-e718-4aba-9291-d7ea175888e0	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 05:36:56.523388+00	
00000000-0000-0000-0000-000000000000	f3703e3d-e3a1-4dcb-9433-a0e085ef7714	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 05:37:00.15423+00	
00000000-0000-0000-0000-000000000000	0f9223ac-af19-4344-a14e-c6bb9a853ca2	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 05:37:00.154944+00	
00000000-0000-0000-0000-000000000000	e27702a4-0b6b-4e80-b6a1-a01bef240b07	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 05:37:00.180796+00	
00000000-0000-0000-0000-000000000000	3fabd7e9-e8d8-4099-8e65-a091b90ccd99	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 05:39:04.960501+00	
00000000-0000-0000-0000-000000000000	b03e48ee-20c7-4b07-9d8d-914d203bb01b	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 05:40:23.814769+00	
00000000-0000-0000-0000-000000000000	aac40f72-269e-4d9d-9808-1edcf683880c	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 05:40:23.817608+00	
00000000-0000-0000-0000-000000000000	7493fcd8-75ac-4470-a352-7913e769ed82	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 05:40:23.968755+00	
00000000-0000-0000-0000-000000000000	d60a4a92-73a4-43d7-a54e-dac3a3e169b1	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 05:40:23.972689+00	
00000000-0000-0000-0000-000000000000	599115ee-d8fa-46e2-aaac-68edd061865d	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 06:20:44.375565+00	
00000000-0000-0000-0000-000000000000	c77ee48a-7195-4eca-997a-92cea4d106a0	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 06:20:44.405019+00	
00000000-0000-0000-0000-000000000000	a08b03e1-b5c9-446e-b0d1-c2f6588b922b	{"action":"token_refreshed","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 06:20:44.536706+00	
00000000-0000-0000-0000-000000000000	a6ffe6f4-a5fb-46a4-a5da-2b804eabd089	{"action":"token_revoked","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 06:20:44.539103+00	
00000000-0000-0000-0000-000000000000	a81e36e3-6dfb-4cbe-93a3-60907ad18eb6	{"action":"login","actor_id":"1dc56294-d8f6-4fc9-984a-6d176d125856","actor_username":"phernandez4@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 06:22:49.764622+00	
00000000-0000-0000-0000-000000000000	6c60b4d7-a4ab-48d3-8a28-be21cca58fd4	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 06:39:58.67911+00	
00000000-0000-0000-0000-000000000000	5b414bb2-01e8-4ebe-8a53-ab850bb5ad02	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 06:39:58.691953+00	
00000000-0000-0000-0000-000000000000	7d970b6f-93ce-40d8-8ab8-a1f82a66a554	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 06:39:58.842131+00	
00000000-0000-0000-0000-000000000000	1f98498a-273a-4ced-ae0c-886a10700e05	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 06:39:58.842823+00	
00000000-0000-0000-0000-000000000000	aeb3ca42-10b8-4ff2-8537-13efe02c9e7b	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 06:40:15.289616+00	
00000000-0000-0000-0000-000000000000	d2e0f8e9-acdf-4600-9339-c941f732ce12	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 06:40:15.292481+00	
00000000-0000-0000-0000-000000000000	3165732e-10ce-4b6f-87df-d5f8c57f833d	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 06:40:15.450532+00	
00000000-0000-0000-0000-000000000000	2dcede7a-88c4-4983-bb62-bad529d148a9	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 06:40:15.45249+00	
00000000-0000-0000-0000-000000000000	30777c36-d52e-4293-b597-f80914ee3eab	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 06:43:40.825234+00	
00000000-0000-0000-0000-000000000000	e54a7022-a0ab-46cc-ad4e-525724f74c76	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 06:57:46.37977+00	
00000000-0000-0000-0000-000000000000	41648195-aad4-479c-89d2-e1ca032e6c23	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 07:05:54.285277+00	
00000000-0000-0000-0000-000000000000	29ff5cb5-cd51-4518-8729-577d9531668f	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 07:05:59.306692+00	
00000000-0000-0000-0000-000000000000	92126aa3-06bb-43ae-b195-48bf14bbb9d1	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 07:05:59.310571+00	
00000000-0000-0000-0000-000000000000	6262fd29-65d2-4c97-91a9-9307fde09041	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 07:05:59.343403+00	
00000000-0000-0000-0000-000000000000	0b4ab758-4b3c-414f-a16e-71f601565468	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 08:05:51.237152+00	
00000000-0000-0000-0000-000000000000	fee8d74c-e0bd-4fb7-a1ac-46bb01f07bb5	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 08:05:51.258188+00	
00000000-0000-0000-0000-000000000000	61a6cbce-9e44-4b6e-8490-9975d064c2bb	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 08:05:51.405858+00	
00000000-0000-0000-0000-000000000000	34fc9a35-0aed-4d81-9cc8-250da19e29d0	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 08:05:51.408043+00	
00000000-0000-0000-0000-000000000000	7f387330-28dd-4a9d-ac89-d8f3b8e73802	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 09:05:44.33695+00	
00000000-0000-0000-0000-000000000000	f4d12cd9-315a-42f9-83fb-678bb63fc66f	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 09:05:44.35346+00	
00000000-0000-0000-0000-000000000000	63f4ff3c-3f60-4fe5-9905-d209252e2087	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 09:05:44.513048+00	
00000000-0000-0000-0000-000000000000	40d09f6f-b38d-4e4e-8b35-f45d5cafbdec	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 09:05:44.515611+00	
00000000-0000-0000-0000-000000000000	9c9c0950-1fed-4e76-9f93-59e7571dede5	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 10:05:37.379978+00	
00000000-0000-0000-0000-000000000000	3720d258-bd8b-4379-bdff-068f10a82c92	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 10:05:37.403212+00	
00000000-0000-0000-0000-000000000000	d15e91c5-2e3b-4ee8-9e13-d03b3f8cd0d1	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 10:05:37.538594+00	
00000000-0000-0000-0000-000000000000	76180bc0-e8ad-47da-80a9-28360c656283	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 10:05:37.541713+00	
00000000-0000-0000-0000-000000000000	b827a575-775c-4c5c-8818-8245c29cb8b0	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 11:05:30.455091+00	
00000000-0000-0000-0000-000000000000	a1d40300-8449-4caa-b141-4782601abc28	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 11:05:30.478113+00	
00000000-0000-0000-0000-000000000000	51c6f579-52ac-45e6-bde6-bbe086f710ba	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 11:05:30.639673+00	
00000000-0000-0000-0000-000000000000	276a5912-efe0-489f-9d6f-98381015287f	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 11:05:30.643966+00	
00000000-0000-0000-0000-000000000000	d4b5d4f8-927e-4f46-8c32-31c9d60f576f	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 12:05:23.499586+00	
00000000-0000-0000-0000-000000000000	a2cb402a-1b9e-4051-af82-4b5d101117b6	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 12:05:23.522211+00	
00000000-0000-0000-0000-000000000000	f5788c9e-e9d4-430a-a1ff-56ed170f84a4	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 12:05:23.674905+00	
00000000-0000-0000-0000-000000000000	40389579-50ee-4f34-9fa8-0af7ceff7b8e	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 12:05:23.677334+00	
00000000-0000-0000-0000-000000000000	dd8012e8-044c-4ff9-ade5-7539aff086dd	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 13:05:16.618448+00	
00000000-0000-0000-0000-000000000000	1cb9e4f6-707f-4786-b6cb-f18b5408f4b2	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 13:05:16.639201+00	
00000000-0000-0000-0000-000000000000	f257c6c4-e768-4602-9a25-7466a37e8788	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 13:05:16.789181+00	
00000000-0000-0000-0000-000000000000	1735416b-7f8e-423d-9bfc-5621b4077ae6	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 13:05:16.79534+00	
00000000-0000-0000-0000-000000000000	a27e6e6b-4ef1-4fbd-9c1d-214f8b326af0	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 14:05:09.721814+00	
00000000-0000-0000-0000-000000000000	22292548-3575-458b-bda6-03a123847a99	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 14:05:09.73775+00	
00000000-0000-0000-0000-000000000000	c2bbb52e-1679-45c7-951d-8206b54276a0	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 14:05:09.90787+00	
00000000-0000-0000-0000-000000000000	c43f373d-36c3-4540-ba71-f9f788084940	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 14:05:09.910442+00	
00000000-0000-0000-0000-000000000000	7b2bee24-4cae-4b28-94e2-8997d52d4118	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 15:05:02.833115+00	
00000000-0000-0000-0000-000000000000	c1af1ec6-a812-4edc-89d5-f5dea5566c3d	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 15:05:02.849625+00	
00000000-0000-0000-0000-000000000000	2578badc-7e2f-4077-807a-427f57c68b79	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 15:05:03.118829+00	
00000000-0000-0000-0000-000000000000	3ec746d7-0b51-4e35-88c9-48fab79bfd7c	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 15:05:03.123658+00	
00000000-0000-0000-0000-000000000000	712a42f0-6bde-4889-a92c-ee54f509599c	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 16:04:57.047042+00	
00000000-0000-0000-0000-000000000000	c79ba328-a091-404f-96ec-a1d0c62da3e3	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 16:04:57.070561+00	
00000000-0000-0000-0000-000000000000	b1295f92-b1a0-463b-8dcd-f88680ea1921	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 16:04:57.251471+00	
00000000-0000-0000-0000-000000000000	620a317f-cf63-468c-aa01-ca9732ff119e	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 16:04:57.255439+00	
00000000-0000-0000-0000-000000000000	05b7819c-0299-4421-9475-f3058896a961	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 17:04:51.198003+00	
00000000-0000-0000-0000-000000000000	08a661c5-f5bc-4543-a785-9d2ecda9fd1e	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 17:04:51.214471+00	
00000000-0000-0000-0000-000000000000	2e2f4769-1ef2-4a34-b70f-75f57dbf4951	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 17:04:51.381585+00	
00000000-0000-0000-0000-000000000000	b8fa6781-269b-4209-baa5-a29bd2abfce5	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 17:04:51.385327+00	
00000000-0000-0000-0000-000000000000	477d130c-05cb-473f-8277-192b4b94a0ae	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 18:04:45.324603+00	
00000000-0000-0000-0000-000000000000	6f555e28-493a-41ab-93dd-5c9a0378c1ef	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 18:04:45.342216+00	
00000000-0000-0000-0000-000000000000	d420ee9a-5fe5-4631-9b1b-d47e18877a69	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 18:04:45.499279+00	
00000000-0000-0000-0000-000000000000	4be8da36-a44f-4104-a0a2-6967434e7e19	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 18:04:45.503374+00	
00000000-0000-0000-0000-000000000000	8ad7a484-5725-4c11-b8ca-a127afb87c24	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 19:04:39.3952+00	
00000000-0000-0000-0000-000000000000	09288c7b-8c44-4da7-8f79-85b8f5da1785	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 19:04:39.414754+00	
00000000-0000-0000-0000-000000000000	0ac6b85d-9ce5-4a43-8197-b9910ff3a756	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 19:04:39.550952+00	
00000000-0000-0000-0000-000000000000	b0a9a305-5540-4504-8a9c-d85723dccefa	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 19:04:39.55179+00	
00000000-0000-0000-0000-000000000000	a3ff70cb-1499-41ba-9629-7077e592513f	{"action":"token_refreshed","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 19:33:08.036444+00	
00000000-0000-0000-0000-000000000000	fd593c3d-baab-4485-8ff5-8fbfce99a8c0	{"action":"token_revoked","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 19:33:08.058695+00	
00000000-0000-0000-0000-000000000000	53319df8-5313-4e90-9a8e-fc34e2fd2bbc	{"action":"login","actor_id":"05498f83-18ab-4ba9-b663-767df738a0da","actor_username":"xiangfeng@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-29 19:33:08.653846+00	
00000000-0000-0000-0000-000000000000	20694c3c-1aae-477f-8b3e-69fd08f70f70	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 20:04:33.269871+00	
00000000-0000-0000-0000-000000000000	37da6809-8be3-4d97-a76a-7981e35884f6	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 20:04:33.280406+00	
00000000-0000-0000-0000-000000000000	c600aab5-ad9e-4ff1-a73a-799ff7ffa90b	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 20:04:33.389825+00	
00000000-0000-0000-0000-000000000000	809d7dff-e24b-414c-acbf-6ec38269200d	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-29 20:04:33.392395+00	
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
3d05eadb-9eb9-4368-8928-87ccd7783f32	3d05eadb-9eb9-4368-8928-87ccd7783f32	{"sub": "3d05eadb-9eb9-4368-8928-87ccd7783f32", "email": "nguyenphuctran@csus.edu", "email_verified": true, "phone_verified": false}	email	2025-03-22 07:51:10.818523+00	2025-03-22 07:51:10.818579+00	2025-03-22 07:51:10.818579+00	c518d05b-546e-4fc4-83bf-0cc382cb0239
bf250d15-2188-413b-b954-120a31ca5840	bf250d15-2188-413b-b954-120a31ca5840	{"sub": "bf250d15-2188-413b-b954-120a31ca5840", "email": "mikefeschenko@yahoo.com", "email_verified": false, "phone_verified": false}	email	2025-03-26 18:53:16.031667+00	2025-03-26 18:53:16.032343+00	2025-03-26 18:53:16.032343+00	2aad0565-ed2a-4616-8fd2-c5b28cfd179a
78467702-b492-451b-a9f1-2059dbdd433e	78467702-b492-451b-a9f1-2059dbdd433e	{"sub": "78467702-b492-451b-a9f1-2059dbdd433e", "email": "faithmontemayor@csus.edu", "email_verified": false, "phone_verified": false}	email	2025-09-15 02:03:38.658414+00	2025-09-15 02:03:38.658476+00	2025-09-15 02:03:38.658476+00	03e366a1-8943-4b83-bceb-722d9b4e3c9b
1dc56294-d8f6-4fc9-984a-6d176d125856	1dc56294-d8f6-4fc9-984a-6d176d125856	{"sub": "1dc56294-d8f6-4fc9-984a-6d176d125856", "email": "phernandez4@csus.edu", "email_verified": false, "phone_verified": false}	email	2025-09-15 06:08:36.43656+00	2025-09-15 06:08:36.436623+00	2025-09-15 06:08:36.436623+00	676d086f-e532-423e-aab7-6e01d612475f
c607bf29-70df-4b8d-9ffe-1f7329a76880	c607bf29-70df-4b8d-9ffe-1f7329a76880	{"sub": "c607bf29-70df-4b8d-9ffe-1f7329a76880", "email": "corbinwest@csus.edu", "email_verified": false, "phone_verified": false}	email	2025-09-26 22:05:34.961027+00	2025-09-26 22:05:34.961738+00	2025-09-26 22:05:34.961738+00	1ce06021-1acb-44cd-b740-df694f47d13a
05498f83-18ab-4ba9-b663-767df738a0da	05498f83-18ab-4ba9-b663-767df738a0da	{"sub": "05498f83-18ab-4ba9-b663-767df738a0da", "email": "xiangfeng@csus.edu", "email_verified": false, "phone_verified": false}	email	2025-09-27 20:00:34.599574+00	2025-09-27 20:00:34.602401+00	2025-09-27 20:00:34.602401+00	bf44d766-217b-44d9-be31-2a22584295e8
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
fe367ed1-0301-48b1-803a-71aafc0a2611	2025-05-03 21:00:50.457015+00	2025-05-03 21:00:50.457015+00	password	3bae3676-c6d9-46a4-9547-61c3ffc771e4
02c09fa3-41db-483d-9e6e-d85ab6d9ff93	2025-03-26 19:24:16.269394+00	2025-03-26 19:24:16.269394+00	password	a4ede50e-3790-443c-aad3-09aad038da78
8b0e4112-b5cb-4d46-bd52-ef26600897c9	2025-03-26 19:27:20.808164+00	2025-03-26 19:27:20.808164+00	password	37d266f1-4116-4b05-a2ee-f1d9194901c5
074ed4bc-16ee-4fdd-9640-a1ddcd5151f0	2025-03-26 20:08:18.23457+00	2025-03-26 20:08:18.23457+00	password	d694313e-0bb9-4a12-83eb-7f0be198e36e
9e4248da-131b-4abf-87b7-a496b37f3c4b	2025-03-26 20:10:28.493151+00	2025-03-26 20:10:28.493151+00	password	dc70992b-a4f0-40ac-adbe-66b31dac6593
aea4c651-4e1e-48f4-8afb-9c45d73eede6	2025-03-26 20:17:08.728172+00	2025-03-26 20:17:08.728172+00	password	89c28bed-c3fe-4724-9dd9-ab20989caf8e
e693787e-1c24-41f8-bfb2-8b0d295ef3e6	2025-03-26 20:19:03.117011+00	2025-03-26 20:19:03.117011+00	password	2750e04d-dc90-4f73-ad4c-4a7666280fde
b2029b81-a467-48ea-b4b0-861153e7142b	2025-03-26 20:20:45.363369+00	2025-03-26 20:20:45.363369+00	password	4fba11fa-669f-4ae1-9ddc-b602c30ed2b1
cb9360a6-b75e-46f2-bac0-8ed97e005f34	2025-03-26 20:21:44.545055+00	2025-03-26 20:21:44.545055+00	password	001e6194-c2e6-4f9d-9057-f1b2dcc83352
f42520ce-6019-41f6-936a-4cf2c410a0b0	2025-03-26 20:23:34.689753+00	2025-03-26 20:23:34.689753+00	password	10ab37cd-7503-4628-a657-5c4840495129
6b96f06a-c6d9-4516-ba2f-c023c0ad791a	2025-03-26 20:25:34.482453+00	2025-03-26 20:25:34.482453+00	password	59abc6ed-ce6d-488b-a4e7-083f31bb092f
a8383d5f-611d-46f6-9620-2162b6ce5193	2025-03-26 20:31:03.210579+00	2025-03-26 20:31:03.210579+00	password	861626c4-f252-4bcc-82c7-913385721cea
ac701636-1b72-403b-b3e1-ebda28c5e9be	2025-03-26 20:31:11.338121+00	2025-03-26 20:31:11.338121+00	password	c9eab1bd-9a81-4dfd-bafc-fe3b44834972
91875e7d-8757-44c5-a78a-0e584b1c1b33	2025-03-26 20:50:23.402971+00	2025-03-26 20:50:23.402971+00	password	272fbfd7-074d-4a49-ae82-af2d7aff3784
ebd413d7-1e0f-4caa-bf72-b9c7fbdc4879	2025-03-26 21:10:15.549961+00	2025-03-26 21:10:15.549961+00	password	d45804af-b68b-454c-b08f-b95d75284fc1
81975daa-dd3c-4217-8e0d-8d472a80cfbe	2025-03-30 00:36:20.806852+00	2025-03-30 00:36:20.806852+00	password	21c99e10-ffdb-4476-b0c4-4390461a6963
b0fbf591-fb54-4997-82e5-7a542ba06807	2025-03-30 00:37:59.522032+00	2025-03-30 00:37:59.522032+00	password	5dd80e93-1221-4bc8-9504-44f8d73316ef
1238fb8a-1436-4854-abe2-ff446b715299	2025-03-30 17:48:23.908798+00	2025-03-30 17:48:23.908798+00	password	78f5321e-39e2-468e-bf38-54915f429716
10c685d6-0361-49d9-8796-072dde50fd33	2025-03-30 21:47:55.789055+00	2025-03-30 21:47:55.789055+00	password	31ef9bde-010b-4929-836f-d745ba08ad49
7de13324-c133-4b8f-be02-45c9d92f3a9f	2025-03-30 22:10:12.723329+00	2025-03-30 22:10:12.723329+00	password	5607ce69-4e30-4dcf-b2e9-a652315f2d20
6ddb6c89-caca-4386-bbd0-0fa7bf35e39a	2025-03-30 22:11:51.710273+00	2025-03-30 22:11:51.710273+00	password	b248cc15-b642-4964-a406-4b9b9cc92881
f260b724-f528-42a7-8db4-6fd799b996a7	2025-03-30 22:14:23.709414+00	2025-03-30 22:14:23.709414+00	password	a493b24e-34c0-4681-9b4c-4c80a89e38a3
5abd24b2-f3c0-40fc-9004-5b26c7543d8c	2025-03-31 05:22:34.24258+00	2025-03-31 05:22:34.24258+00	password	efebfbf9-e485-4125-959b-572188ee36b2
cfeae367-5189-4bec-8686-d49aec3ec71b	2025-03-31 05:38:27.534183+00	2025-03-31 05:38:27.534183+00	password	ec5d3140-e6e1-4c4d-b433-bd609b82d839
e971e0d2-9215-4868-a3ec-45a61f772cad	2025-05-04 01:33:38.438021+00	2025-05-04 01:33:38.438021+00	password	5a30fbd0-43cc-4197-ab3d-1d963740149f
9cae04dd-8e75-4c99-ad80-1091efb3a205	2025-04-01 21:43:47.619811+00	2025-04-01 21:43:47.619811+00	password	e0de270f-d319-4cc7-b9bd-6f9ea6aa2230
6906e6bc-384f-4207-8e5d-a9fb307a186f	2025-04-01 21:44:34.192467+00	2025-04-01 21:44:34.192467+00	password	8a1fede5-9df7-4083-b3b5-e0db83cfd760
ea0776cb-bf09-4e44-bc53-0ff669ab2e1b	2025-04-01 21:47:06.662446+00	2025-04-01 21:47:06.662446+00	password	e69513de-c5c7-41c8-93aa-e87cd5652601
0ef81737-c780-4166-9ee7-f23ded438cf8	2025-04-01 21:48:52.6913+00	2025-04-01 21:48:52.6913+00	password	3f0113fa-a101-49a6-ae65-f7eb82360469
0a69daaa-bc93-42a0-a8c9-11737c9e9b57	2025-04-01 22:06:03.527835+00	2025-04-01 22:06:03.527835+00	password	80bd511f-826b-44d7-ac36-3f7055981af1
00ae48b1-545f-4471-a712-f1b2ade005d2	2025-04-10 00:03:15.090708+00	2025-04-10 00:03:15.090708+00	password	8cd59ce1-3320-4637-be47-a350087f2638
c3cae0ec-4c4c-4aba-b65f-2a435ccc53a8	2025-04-10 00:03:25.813734+00	2025-04-10 00:03:25.813734+00	password	ae709cef-1184-4c45-8732-3b61e1ae95e7
ca5bf2f7-be3d-42de-aa85-36467dad35e3	2025-04-10 03:51:21.532349+00	2025-04-10 03:51:21.532349+00	password	ebc0b21a-c316-4560-bb20-cd1584506981
8ad101cf-f5a4-48dd-a3be-d8a3544bd24e	2025-04-11 15:08:52.924039+00	2025-04-11 15:08:52.924039+00	password	d9cc1692-9c57-482a-a376-8e4c1f6842ee
195c9e8c-8e78-41ec-885b-4d76ae239418	2025-04-11 15:10:49.756302+00	2025-04-11 15:10:49.756302+00	password	4081f616-8961-46fa-8d31-0594683369a2
a226a2e9-60aa-448b-959d-9721d44caad1	2025-04-11 15:43:44.677517+00	2025-04-11 15:43:44.677517+00	password	eb4d6ecc-a1c5-4404-9780-956e93edeb29
91fdfa03-d938-463c-864e-6c38eaab7f6f	2025-04-11 15:51:49.255335+00	2025-04-11 15:51:49.255335+00	password	ab756561-6f38-45b6-8f4a-f73729789b2c
3901fc23-e282-4c9c-bb47-c029f4903ff3	2025-04-13 17:43:50.85638+00	2025-04-13 17:43:50.85638+00	password	b63df6bb-d8a1-495f-adfd-bd33d016f5ec
deaa56d3-2c18-45ed-8ede-2b6ca1261c07	2025-04-13 17:46:34.765314+00	2025-04-13 17:46:34.765314+00	password	0b1624c7-9a50-46d7-8674-06d7dc55f34a
b948d350-ff7a-47cb-b4d4-8d78994c4620	2025-04-13 17:47:19.028659+00	2025-04-13 17:47:19.028659+00	password	e361352b-b36b-4a18-8fee-32dc69c1e412
c81018f0-4aaf-4693-9d5d-5675296e941c	2025-04-14 19:06:13.270232+00	2025-04-14 19:06:13.270232+00	password	65286d22-76e7-457f-886a-47016045d5f2
e510a996-77ce-4e18-a594-55465a03b986	2025-04-14 19:06:15.649752+00	2025-04-14 19:06:15.649752+00	password	7691d065-7e90-4271-847a-2d98330a69ea
220e457f-5908-4039-a283-ce75ca266382	2025-04-14 19:06:17.06735+00	2025-04-14 19:06:17.06735+00	password	964fdbf3-d272-4544-93da-4d590a896f7c
935c6082-2e84-45d8-8067-dac5cadd189a	2025-04-14 22:13:32.694623+00	2025-04-14 22:13:32.694623+00	password	78dbf9a6-f513-44e5-9bdc-538724c60c3e
16ce9913-e975-4bd6-b4cf-02c215639946	2025-04-14 22:15:46.82832+00	2025-04-14 22:15:46.82832+00	password	d8dee781-27c5-4265-8071-a936686cb8a1
6f92ec87-8705-4fe4-ace2-aef03c67a7f9	2025-04-14 22:42:52.236292+00	2025-04-14 22:42:52.236292+00	password	56ca40f5-9b54-4f28-8115-d77a4e640593
63a45b0d-f621-44e1-9881-4b543b1a26ee	2025-04-15 00:28:13.669959+00	2025-04-15 00:28:13.669959+00	password	4c79f277-65ab-4ce2-b359-2ede0cafecb3
c43643fd-1a50-484d-912b-c7d5b827a211	2025-04-15 00:56:47.889132+00	2025-04-15 00:56:47.889132+00	password	4ab933da-f586-4c98-98aa-2b4e7df24eb7
ba10fb1b-cc7f-45b7-92fd-e7d47aacfcc5	2025-04-15 00:57:57.83351+00	2025-04-15 00:57:57.83351+00	password	f9cb0ec1-c711-4388-9f43-4aee14392254
d61a2d50-298a-41ad-9a46-19e69af57515	2025-04-19 00:43:08.245794+00	2025-04-19 00:43:08.245794+00	password	080d08e0-95df-4543-9eb8-31a76e77b9d7
46b83fa0-9db7-4e07-add9-d7006e2021d7	2025-04-19 16:35:53.497119+00	2025-04-19 16:35:53.497119+00	password	6acb892c-43b7-4d4e-af22-1cd5a2191183
18242170-cf07-4ef9-a1ea-172e2352802b	2025-04-19 16:46:33.601846+00	2025-04-19 16:46:33.601846+00	password	4110670f-b012-4f2a-a6b8-33c776a08f85
e36f9dba-faed-4545-a2e1-fb3b442733d5	2025-04-19 16:48:31.808984+00	2025-04-19 16:48:31.808984+00	password	7ef6469e-07db-4a8f-b8ad-38563d2ef2aa
860dd21b-60d7-41ec-80c7-c9ea0aadd529	2025-04-19 16:48:36.151102+00	2025-04-19 16:48:36.151102+00	password	c053c44a-a9d7-40e6-907d-72a06583be02
957ae2ce-6e6f-4f7b-b32b-8d1bb7c39be0	2025-04-19 17:15:39.805624+00	2025-04-19 17:15:39.805624+00	password	546e9ceb-0f2d-4f6e-a5a4-af6aefe71e85
50540fee-1412-4f40-b4de-9b34eb2942d2	2025-04-19 17:15:42.14365+00	2025-04-19 17:15:42.14365+00	password	33317aea-f0fe-46bb-9286-501676d34eda
6af7747d-b891-4b55-99b0-1d1422e7ee65	2025-04-19 18:04:26.911051+00	2025-04-19 18:04:26.911051+00	password	34d18227-0e38-40f8-8a84-c0d47d4b701c
c34b90d7-cd6a-4df9-b5a5-2053d7a42e6f	2025-04-20 23:18:56.915071+00	2025-04-20 23:18:56.915071+00	password	c704abc9-1cbc-4d15-b852-0282f4f9d9f9
d0b51716-7860-43ce-8dd3-6ba415217384	2025-04-20 23:19:00.326401+00	2025-04-20 23:19:00.326401+00	password	a60c9889-eceb-41b4-8f1d-8fdb0ae9d480
7006555d-0a48-41e6-80d7-bc78441f4cc0	2025-05-03 20:36:11.824079+00	2025-05-03 20:36:11.824079+00	password	7238e1e9-b4be-4992-9f4b-2006873134f3
e03c19f5-ffe2-4a63-942b-451f48840200	2025-05-03 21:03:12.118966+00	2025-05-03 21:03:12.118966+00	password	f2da721b-140f-4014-bd64-324635656181
792b6c44-22cf-4a9b-ba8a-a09e6c4ff9d5	2025-05-08 17:31:22.845966+00	2025-05-08 17:31:22.845966+00	password	ed8f7dcc-e80e-454e-a7d6-6e36a0e5afdd
5776bee8-ded7-430c-a312-9f9766075c77	2025-05-03 20:40:18.838931+00	2025-05-03 20:40:18.838931+00	password	5217ed22-5879-4470-a39e-35f34f513de9
90f1e9d5-bb09-4b6f-8926-7eec1c9dfd51	2025-05-03 20:41:27.121745+00	2025-05-03 20:41:27.121745+00	password	913679af-803f-470b-8818-d2d3a2a9b417
96e6199a-bd27-452e-bf9c-9011e9bc92bf	2025-05-03 20:42:27.109898+00	2025-05-03 20:42:27.109898+00	password	20b11c40-2fe5-4f68-9fbd-9d3678004da7
9711f210-f944-436f-94f0-e4c4caa489c2	2025-05-04 00:27:25.911884+00	2025-05-04 00:27:25.911884+00	password	e44a737d-f6ec-44d4-bd09-f2b2d221d89c
6081e976-fbcb-4d9b-84d6-215ac319094d	2025-04-28 01:51:56.118358+00	2025-04-28 01:51:56.118358+00	password	73720a48-a8f3-4d68-b8ca-f08e26da4363
4d6f494b-9739-4be0-8225-7191e57fed6d	2025-07-26 00:39:46.966455+00	2025-07-26 00:39:46.966455+00	password	ae42d8f1-c4bd-4cec-bce6-10c90d8d62a8
1a9f0bad-6fe3-4494-a78b-fd90b1f1ffe0	2025-08-29 16:38:41.939167+00	2025-08-29 16:38:41.939167+00	password	74adad45-45b4-4870-b5b6-5bec354d05bd
72c3ee15-f774-4706-9f43-c60a75b3f7e3	2025-09-04 02:57:31.678453+00	2025-09-04 02:57:31.678453+00	password	dd2ff1a3-a848-4f03-b28e-65c1d9bfdc88
e3dd638f-dd2c-483c-8b9e-ff2bd331fc05	2025-09-04 03:00:22.153199+00	2025-09-04 03:00:22.153199+00	password	50523a65-87de-4e0b-9e80-a157a030ac8d
4bbd7775-d0d7-481a-bf6e-12ae59b6ee93	2025-09-04 03:16:14.579283+00	2025-09-04 03:16:14.579283+00	password	486d7181-421e-4bd5-b634-4c1e2c6fb231
fd23a616-ec28-4cd8-a631-f5d633a0003a	2025-09-04 03:26:35.862917+00	2025-09-04 03:26:35.862917+00	password	9e0bfa72-3e99-4c8a-8a72-84ebc477ed77
ce457df0-bfc4-4d66-86eb-3af1def5e9fb	2025-09-04 03:28:55.5531+00	2025-09-04 03:28:55.5531+00	password	73b7ec9a-650c-405a-a99d-6245d3c5bebd
fd591671-c3b2-44c0-b7b6-170580b690a6	2025-09-04 03:30:53.800004+00	2025-09-04 03:30:53.800004+00	password	cb2dfbbc-c8b2-4cfb-b700-258e1a7d0d20
9d65e46e-1d59-4ffd-a0c2-e3d91d8a5458	2025-09-04 03:33:00.095065+00	2025-09-04 03:33:00.095065+00	password	292ca3e4-ac5f-4306-871d-7568d6aa33f6
65fc0d10-851d-4b88-8e65-882499cf7bb6	2025-09-04 04:43:28.438885+00	2025-09-04 04:43:28.438885+00	password	16c35f81-3ac0-4221-8f82-47e6c8f02500
b789fcba-eb67-4ddd-9fea-cbcafa4a2fc1	2025-09-04 06:52:46.03121+00	2025-09-04 06:52:46.03121+00	password	1301de5d-7492-43c4-832c-e64388dae48a
fc372ee1-b75f-4e37-a6e1-232840d27149	2025-09-04 07:47:19.626066+00	2025-09-04 07:47:19.626066+00	password	4f92bade-2da5-4efa-8724-1ff7712134ef
6419843a-fc06-40cd-98ad-391e91a8137d	2025-09-05 00:00:28.804323+00	2025-09-05 00:00:28.804323+00	password	c2f1e5f1-0ee0-4fcc-be85-ea83fdc74890
bab38d1e-4e2b-43bb-81cd-8abaccaec8da	2025-09-05 01:16:22.756662+00	2025-09-05 01:16:22.756662+00	password	112a82b5-d8c3-4599-b02a-66abc2b8d099
91d8b177-bae2-4841-b0ca-0c33fe976a1c	2025-09-05 05:26:17.236882+00	2025-09-05 05:26:17.236882+00	password	64ad2983-9ab3-4207-a41f-02a412aa2fe2
f716839c-35ab-48f0-92cb-6e0db330368a	2025-09-05 06:41:54.130694+00	2025-09-05 06:41:54.130694+00	password	e9f5d28d-b396-4966-bde6-58a115fa79e6
21afe93a-435c-42df-97fa-67ea6be55f69	2025-09-12 06:51:29.145346+00	2025-09-12 06:51:29.145346+00	password	8f886af2-91c9-41a8-8869-dac2f7bb2e6c
a5bdff3a-8034-4930-93d0-83ca2b69f9a0	2025-09-12 08:12:53.79531+00	2025-09-12 08:12:53.79531+00	password	1340ad22-ecf1-4328-8f87-884732eb90d1
a220fcaf-6c3d-43f1-87b8-6a8197667c54	2025-09-12 08:16:15.022018+00	2025-09-12 08:16:15.022018+00	password	68e9e5e8-e216-4293-a327-6bff06b06aa3
c553d554-172d-418c-ace5-acf8953b5867	2025-09-12 08:17:48.446409+00	2025-09-12 08:17:48.446409+00	password	0de9e607-380e-49ab-87d1-91f9cbde5bc5
964677c1-610a-429a-a6a9-56980139259a	2025-09-12 08:22:28.955335+00	2025-09-12 08:22:28.955335+00	password	3bdc7cae-e4f4-49b4-a155-3bb37ccdb17c
2ee64cf8-a1a6-4053-a778-6ed2cc97aa1f	2025-09-12 08:31:59.444485+00	2025-09-12 08:31:59.444485+00	password	3b31a54d-6061-4703-8094-069b26590af5
47387d9c-a03b-497c-92ca-c7e33d1436c3	2025-09-12 10:29:04.844357+00	2025-09-12 10:29:04.844357+00	password	07855a1d-d193-47d8-9106-150a18be8465
a410fe17-ff1b-41bf-be10-2e2bcdacfdf7	2025-09-12 10:34:54.749074+00	2025-09-12 10:34:54.749074+00	password	19c6cce3-c26f-4b75-bb67-ab0012197b14
cd2b73d6-4d7a-42fe-884b-0d3161edd8a3	2025-09-12 10:35:01.228032+00	2025-09-12 10:35:01.228032+00	password	1b9399ba-29d8-4d1a-84c0-2cc730c3465e
e69ddca4-bbed-433b-984e-3ea987690e4a	2025-09-12 10:39:15.59186+00	2025-09-12 10:39:15.59186+00	password	30d0c052-c24e-4004-a657-1460b3c3a5a2
5c08900e-5e31-4d22-b308-453c37e8ea89	2025-09-12 10:43:58.852501+00	2025-09-12 10:43:58.852501+00	password	fe8d670d-8e0f-4d35-a074-8c42b50c36b0
a4612ea7-c20f-4208-887a-ddd1af8d5dc1	2025-09-12 10:47:16.594785+00	2025-09-12 10:47:16.594785+00	password	96c5f88c-72e7-4b82-b660-557470735a88
927b66b3-5c04-40b7-948c-eba020033fc1	2025-09-12 10:53:35.404996+00	2025-09-12 10:53:35.404996+00	password	016faf1e-e808-407b-b24f-d338d3cd4584
75429ef2-9e61-4726-91a3-f82dcf3e45d4	2025-09-12 10:56:10.205221+00	2025-09-12 10:56:10.205221+00	password	4ec202e4-7dd3-4005-bac0-c5437ab83216
f3037ca4-77c0-4df2-bf32-3b854d39989f	2025-09-12 11:02:19.994952+00	2025-09-12 11:02:19.994952+00	password	de975216-ebf4-4b35-bbaf-7e73f27e642d
accfe3d0-8ee6-47c3-96ac-5847f4acff13	2025-09-12 11:03:06.875532+00	2025-09-12 11:03:06.875532+00	password	8f692304-50a1-405e-86fc-13264df77a4f
f86a41b9-2a45-41a5-914a-ae44c0604574	2025-09-12 11:05:53.233987+00	2025-09-12 11:05:53.233987+00	password	537a2c8c-681b-4417-9091-d06a141ec0f8
8b7fb74f-bb08-4844-b546-a039820809c6	2025-09-12 11:08:15.280057+00	2025-09-12 11:08:15.280057+00	password	b3ba09d6-54a0-45a6-87d3-9a254106917f
4e2712c9-7762-4cab-87e4-dd95c76b0a9a	2025-09-12 11:21:31.863441+00	2025-09-12 11:21:31.863441+00	password	e9847bb8-3054-41d1-a77e-92b71db2bcff
a4990197-3b49-4588-b5b6-8b773b2b1eeb	2025-09-12 11:47:42.236381+00	2025-09-12 11:47:42.236381+00	password	c8f4170c-ce58-4390-95db-9554dd92fc32
09ee0a1b-d5d7-4142-9b24-488af18563a4	2025-09-12 11:51:04.065428+00	2025-09-12 11:51:04.065428+00	password	6b6f5a39-c110-4bb5-b21e-34f3c3e28e0f
76140067-cb3f-43a6-9838-1229ba6a69ce	2025-09-12 18:13:14.942372+00	2025-09-12 18:13:14.942372+00	password	eaf073f6-5200-43f0-818f-6d60d8f40b2c
e2d152b3-e4b6-4cc6-8c35-ade398896c11	2025-09-12 19:01:29.007408+00	2025-09-12 19:01:29.007408+00	password	af40a603-c10f-48e1-92a8-38f262ef70bf
dc75c993-d127-4e85-9581-d33f71263cea	2025-09-13 02:59:17.208773+00	2025-09-13 02:59:17.208773+00	password	06a82592-8c21-4379-ab65-6f72433e5317
79e0fa6c-dbcd-4c7f-aed8-d7abd74c935b	2025-09-13 05:15:02.250318+00	2025-09-13 05:15:02.250318+00	password	85235c4a-694e-4e03-836e-c33e1deb3096
314d3388-00c5-48c5-babe-8c70fb84535a	2025-09-13 05:15:41.242883+00	2025-09-13 05:15:41.242883+00	password	94061e5d-2663-43ff-b8b7-552c07c28435
5daffb69-09f0-4706-a823-e4ee235600b9	2025-09-13 08:33:49.60143+00	2025-09-13 08:33:49.60143+00	password	c3268a20-da75-40d8-93cd-964e215e14df
104e3d9e-15e9-4f01-b2a5-1ad9b02a6bd5	2025-09-13 21:26:35.091416+00	2025-09-13 21:26:35.091416+00	password	9c0d7ac8-ab70-4138-8766-c929fc725ca6
5cdc7063-dfdf-4f8a-ac00-118100fa5ad1	2025-09-14 06:06:15.724989+00	2025-09-14 06:06:15.724989+00	password	8170a08a-4c77-454f-92a1-70f30dc58b10
8434698b-7bf5-4401-a6db-2968f956f61c	2025-09-14 06:47:42.246026+00	2025-09-14 06:47:42.246026+00	password	5c2f5e3d-4caa-4727-86f8-4e40b656cb8d
ac34c1a7-8bff-4836-b952-48b0cdade96e	2025-09-14 07:11:23.30705+00	2025-09-14 07:11:23.30705+00	password	90b4678f-4178-4fd4-9127-d5c11aaaac3a
3d3d0f8b-eef6-469c-b333-722c32b3aa9a	2025-09-14 08:24:25.764334+00	2025-09-14 08:24:25.764334+00	password	54a7ca26-f46e-4935-8e2f-84080136dc0b
f17da7ad-4ba1-471d-a3d0-7225537f8aa5	2025-09-14 09:31:44.63643+00	2025-09-14 09:31:44.63643+00	password	3a5e2355-2816-46bd-ae5d-fe36ba6641ad
5f3dcba5-bc20-49f8-a141-b381f9feca61	2025-09-14 18:36:57.542801+00	2025-09-14 18:36:57.542801+00	password	35f2885c-0444-41a8-84e8-04bce0cf6281
83a8ae57-6717-4831-857e-6a3ea8165224	2025-09-14 19:15:38.902797+00	2025-09-14 19:15:38.902797+00	password	c2367b15-8c01-489c-8ce5-ce6f1e29025a
230eb5c4-a702-4a81-a32f-31bc53ac82a6	2025-09-14 19:17:08.170314+00	2025-09-14 19:17:08.170314+00	password	794e6b6d-eb03-4cfa-ba50-dee50d39d133
051f8903-3e13-4345-82d1-e123318dbc20	2025-09-14 19:33:03.902858+00	2025-09-14 19:33:03.902858+00	password	678809af-0d8d-442b-b7d3-bcb95b025c4d
7f0c84ac-90b1-4149-ab8f-29fe67198d16	2025-09-14 19:54:58.680131+00	2025-09-14 19:54:58.680131+00	password	fb408337-a816-4929-8f03-4b0acd2fddea
981dcbe1-f199-4e65-abf9-c53beaf6637d	2025-09-14 22:08:05.115831+00	2025-09-14 22:08:05.115831+00	password	4c8d126b-dac9-4cbe-9a58-c6d0cfc4f425
905b2c4b-69fb-4d42-a89c-62e76b6e044b	2025-09-14 22:11:26.702208+00	2025-09-14 22:11:26.702208+00	password	0a367a7f-ad04-4c35-91a4-acfe654e7a5c
b030bc4b-89dd-429d-8f1a-de455c3015eb	2025-09-15 02:05:02.278842+00	2025-09-15 02:05:02.278842+00	password	078160c7-c2e2-42ce-bb68-fb4a288b6456
fb430cc6-333d-48ad-8632-86ef5ca510c8	2025-09-15 02:05:12.407285+00	2025-09-15 02:05:12.407285+00	password	858fb069-4fc6-4dae-84db-0d8623ffd3ba
e986b82b-50ec-4d86-839a-c345d3179c07	2025-09-15 02:05:16.213118+00	2025-09-15 02:05:16.213118+00	password	3089cb0b-5143-4c84-afbf-ac06a60dd78f
f6553552-7c87-4bcb-a859-3a48870d116c	2025-09-15 06:23:33.074598+00	2025-09-15 06:23:33.074598+00	password	288d8f0c-620c-4303-a9ed-1f5b37172251
0eca28be-4686-4dd3-887d-49f56060f062	2025-09-15 07:05:54.825062+00	2025-09-15 07:05:54.825062+00	password	bcc1f066-170e-429a-97f2-c68a52e85c3f
76367272-6b3c-4059-8faf-3ae7f807ecf9	2025-09-15 07:51:24.591922+00	2025-09-15 07:51:24.591922+00	password	deb350b2-a66a-4038-a302-f3617dff301c
b645d2ad-52f2-4f09-859b-7afa13adc3a9	2025-09-15 08:09:29.657279+00	2025-09-15 08:09:29.657279+00	password	6493212a-010e-4b33-bf2c-941064c7a977
60e6db0b-9148-4e3d-8fc6-6bcfc79505f6	2025-09-15 08:14:04.697716+00	2025-09-15 08:14:04.697716+00	password	f64c618d-4c75-456d-b910-6023af19dea7
ce51c5d5-8061-4ef9-a7dd-9725b3bc4477	2025-09-15 08:23:40.177732+00	2025-09-15 08:23:40.177732+00	password	4857e412-6102-4982-ac1a-7659074e4060
3a6b85e2-1903-43ea-a0eb-fdf04dd3e96c	2025-09-15 10:52:13.60449+00	2025-09-15 10:52:13.60449+00	password	9d5e1668-b7e6-4c84-92f6-df169381a739
f661643e-a468-42ce-b654-fc1a2e8d098c	2025-09-15 11:12:06.758812+00	2025-09-15 11:12:06.758812+00	password	514905b3-5559-4096-b320-794b9cfdf093
c0c21c5c-3898-46d3-8369-084efe12f2cc	2025-09-15 11:17:26.487254+00	2025-09-15 11:17:26.487254+00	password	c9386b82-576b-4af1-852d-8c6205dd5477
ba43f993-07b3-4b9d-817b-d1105c31ed8a	2025-09-15 18:05:47.760417+00	2025-09-15 18:05:47.760417+00	password	ff72a3fc-05aa-4c40-8972-984a35127958
38d3e981-380e-47e6-bd42-8a9e988fe778	2025-09-15 19:17:07.320878+00	2025-09-15 19:17:07.320878+00	password	5f6bf3f0-9f13-4420-875d-9283408467d6
f352a10d-320a-47c1-a8b4-98d34b9d5940	2025-09-15 21:09:40.500149+00	2025-09-15 21:09:40.500149+00	password	74aa87c6-6467-4348-bbd4-2ac566590346
ecbccb35-5476-4d47-8146-3e7859417cd4	2025-09-15 23:19:23.364695+00	2025-09-15 23:19:23.364695+00	password	57a03af6-4ecd-4368-a703-b2bc3099c77e
fb3aa1ed-2104-49d0-8d5c-ffa6f7c2796a	2025-09-15 23:43:39.363512+00	2025-09-15 23:43:39.363512+00	password	b0960354-6c05-4769-ae0c-45fbf5aaed44
af1a1548-ef1a-4d2e-9797-febf86aa21aa	2025-09-16 00:34:48.642671+00	2025-09-16 00:34:48.642671+00	password	1d52ce45-8326-41f9-bdb9-91c1ce3b2d8b
4267d7c0-091c-467c-b153-6339c4ec6b93	2025-09-16 00:50:22.430951+00	2025-09-16 00:50:22.430951+00	password	767287bd-ee82-48f4-9f8e-6d20693195f5
de277f17-ceb3-426d-b990-b55199b0b0c6	2025-09-16 02:02:34.315562+00	2025-09-16 02:02:34.315562+00	password	6330f8fd-60f8-4c2a-a521-441b98b8fdfd
5a07f556-71c5-48b4-9ae0-1882cc9d34db	2025-09-16 03:09:55.136827+00	2025-09-16 03:09:55.136827+00	password	32016bb8-6a51-4a7c-a8c7-bdfd1a9e2095
dfd646ea-2159-4796-8833-60f9e2c2d65f	2025-09-16 04:01:07.565956+00	2025-09-16 04:01:07.565956+00	password	4248f981-19c9-4cd9-b8e8-c58a87b1afec
b7702bbe-80d8-4ab8-9b8e-36d1df1a9fcf	2025-09-16 05:58:38.770285+00	2025-09-16 05:58:38.770285+00	password	26236eba-cf1b-4e88-b282-36524dd2ab1f
9fa307ea-1bbb-4f3d-8c46-a29335e56982	2025-09-16 06:16:00.605453+00	2025-09-16 06:16:00.605453+00	password	56cce4d4-8668-4434-8ae6-0feac9999b9c
2d8a65d9-fd7b-4fff-8802-3498e456b389	2025-09-16 08:14:37.503508+00	2025-09-16 08:14:37.503508+00	password	3f0eefb0-7557-4eac-b158-3207d06bd7e1
ffa44850-ca30-4c58-a6fc-d771833667dc	2025-09-16 08:23:46.816749+00	2025-09-16 08:23:46.816749+00	password	7c65be80-a5bc-42b8-8e71-3403af93b76d
43a1d000-fa65-49bf-9581-9a0028e132ab	2025-09-16 16:32:31.897073+00	2025-09-16 16:32:31.897073+00	password	787c0532-8840-4143-8a9f-687a6401447b
e79f7d9f-d2cb-4d6e-bb1e-095606cdb783	2025-09-16 18:38:05.723196+00	2025-09-16 18:38:05.723196+00	password	d8ba4ff5-7016-42c5-a980-c05807e6d80a
5ceac1b5-dc39-46dd-b56f-63ea02d13f99	2025-09-16 18:38:51.397358+00	2025-09-16 18:38:51.397358+00	password	7dd90411-4610-4063-b3fc-eb4f3480bbd9
4cb8e984-0e7e-43d7-a1e7-0e97132e1b8e	2025-09-16 18:47:10.343693+00	2025-09-16 18:47:10.343693+00	password	db8b2958-30e0-4849-8076-752ad51890a5
a0f895b3-d892-4034-a7e9-5906d8e2085a	2025-09-16 18:48:18.173322+00	2025-09-16 18:48:18.173322+00	password	cb1ff0a1-0a8b-427a-a67d-724544ad9aec
ae732e60-c8e3-4228-afdb-7aa8adcfb974	2025-09-16 18:56:06.977455+00	2025-09-16 18:56:06.977455+00	password	bb99cdc1-1c93-4d05-ba7b-df2625bc9500
45471ddd-1817-4460-bd43-1ea8df8ae99f	2025-09-16 19:29:22.008706+00	2025-09-16 19:29:22.008706+00	password	5885998c-03dc-48a8-b969-abbbad6b3bf1
ae572a98-4030-4fc5-ad51-b5f899cc8f30	2025-09-16 22:03:04.084823+00	2025-09-16 22:03:04.084823+00	password	e1ebf010-91ff-4dc4-874a-4380c8b7a2e7
9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0	2025-09-16 23:43:39.92975+00	2025-09-16 23:43:39.92975+00	password	b607b165-616c-4a9b-94cd-bc20596cda01
833d1385-ba1f-4557-9021-cac4e0c889a0	2025-09-16 23:46:04.147097+00	2025-09-16 23:46:04.147097+00	password	ae226653-d433-484b-a0db-5ea3f384b938
4528bae3-3f44-4e75-a3cd-654ace35ffc0	2025-09-17 10:11:09.121967+00	2025-09-17 10:11:09.121967+00	password	645e3830-deff-4c62-9b49-21aa26f1b148
bc3647d9-c7d0-4f53-bea8-8b9158cab35c	2025-09-17 10:28:05.223372+00	2025-09-17 10:28:05.223372+00	password	b80dbfda-6ba2-4c45-baf1-8f6c564aeb7c
c2576234-3e34-493f-9d57-2cea5e39aa05	2025-09-17 11:22:53.22834+00	2025-09-17 11:22:53.22834+00	password	374037cf-b2b4-4b0c-b85c-d83f66801852
e4de159c-a466-4f2c-b85c-ecb24e4e72aa	2025-09-17 20:29:18.765723+00	2025-09-17 20:29:18.765723+00	password	d101221f-d282-49fc-a71b-8cd5a2d99f4d
89c141a2-771c-4a9e-8f6d-4f52416a71a7	2025-09-18 01:58:23.700508+00	2025-09-18 01:58:23.700508+00	password	85445bde-46b8-4b1e-99b8-067f82803d3c
f52e50dc-6451-4aab-9300-5ee3d12aa663	2025-09-18 02:49:26.548356+00	2025-09-18 02:49:26.548356+00	password	1e9af3ae-2261-40df-987c-4264387ce6b7
28a8c730-a855-4703-a909-44ab4600f2e4	2025-09-18 02:56:08.611622+00	2025-09-18 02:56:08.611622+00	password	cb7be808-e403-4d18-a6c4-0bb2f7489639
02874424-dba7-4ae0-a20d-6e7796ddd1df	2025-09-18 03:17:11.851363+00	2025-09-18 03:17:11.851363+00	password	c57ed57c-97f3-4a01-b7bb-d9f01cf0af0f
28cf8058-092a-4f12-bb42-0a6e8991cbea	2025-09-18 03:27:28.364445+00	2025-09-18 03:27:28.364445+00	password	d365dd6a-e931-4deb-a342-f2ee6cba307d
7e5094e9-81c6-4a62-abaf-6908e3a6a081	2025-09-18 03:27:52.582972+00	2025-09-18 03:27:52.582972+00	password	236cc2ce-4f28-41cf-aca6-d75d8016f524
805cebc3-d1ff-4b9f-a5df-39ccd4542414	2025-09-18 03:47:24.858008+00	2025-09-18 03:47:24.858008+00	password	cffb19c0-e0b6-4545-b6a4-3a34e27afb48
3e8ee467-5b06-4fa6-9fa8-ec1171a577b6	2025-09-18 03:52:01.140053+00	2025-09-18 03:52:01.140053+00	password	8edca867-477d-4655-8899-5a757e786d58
33dfc82b-a471-4f29-9c3b-f74b730767ea	2025-09-18 03:58:20.874032+00	2025-09-18 03:58:20.874032+00	password	43e43cd7-6c1a-44e2-993c-d5ee92b72f73
4796cb6f-ea55-4a9b-90a0-785f594b14bd	2025-09-18 04:12:44.246314+00	2025-09-18 04:12:44.246314+00	password	f9267ca1-cddb-411e-9288-dd3f7cf5eb77
046128ff-faa8-4529-b9c2-a78cb9d29349	2025-09-18 04:33:25.184495+00	2025-09-18 04:33:25.184495+00	password	e466d529-5663-49d4-bee2-c5ba9c900327
cbf96df9-654c-4371-ac5f-8df35cc85703	2025-09-18 05:32:54.807828+00	2025-09-18 05:32:54.807828+00	password	b536ac6b-776d-4a3f-a8f0-26372292a757
e881b73c-0cde-4f35-bf6b-710e7ffb78c0	2025-09-18 06:47:40.534717+00	2025-09-18 06:47:40.534717+00	password	35c11e0f-f389-4079-a399-fb70bf4b0f94
a59fc041-975e-40d8-b6b4-d2a234684e69	2025-09-18 07:20:34.635095+00	2025-09-18 07:20:34.635095+00	password	36d796d7-65c1-497d-aec6-ce82bdbea0c2
9fa5cb6d-9a4c-428a-8244-d06adc0ff85e	2025-09-20 00:47:41.657334+00	2025-09-20 00:47:41.657334+00	password	cd7ec21d-8bfc-419d-b8ea-a507b8483faf
4212192e-cf57-4127-b5c4-8dad2a050b90	2025-09-24 00:47:21.063673+00	2025-09-24 00:47:21.063673+00	password	5177d39d-7e83-4e5d-8ad4-7e2c76899d52
0d8c0c02-2b51-4531-a204-f1191f5cc218	2025-09-24 01:46:18.613109+00	2025-09-24 01:46:18.613109+00	password	42ed6088-4105-4d87-9948-2829e9044a02
306d892a-7a17-42b9-b223-f892f3161f68	2025-09-26 22:39:16.412886+00	2025-09-26 22:39:16.412886+00	password	4ae20a33-8cec-4daa-92d6-4f6d60135f8d
20e5429d-b26f-49b4-ab5d-afeecf16af18	2025-09-26 22:42:22.758965+00	2025-09-26 22:42:22.758965+00	otp	c8230f36-c8ac-482a-9d73-921b7e6e2e5c
68144ade-084b-4a77-83f3-3b6dc183c592	2025-09-26 22:43:51.517515+00	2025-09-26 22:43:51.517515+00	password	841ce077-3068-458c-9fdc-92661c122de7
1451e5b3-46c3-4733-bc13-688bbe8d4919	2025-09-26 22:55:35.464166+00	2025-09-26 22:55:35.464166+00	otp	b976c8fc-519a-4126-a2e4-e5ac7899252f
6aea7bb2-7a28-4cf2-aaf4-59045b6449de	2025-09-26 22:58:14.915587+00	2025-09-26 22:58:14.915587+00	otp	44f7638d-c75e-4e2a-8eb4-529505afbaee
bfea420d-890e-439b-a343-8d1870d9e102	2025-09-26 23:01:18.985393+00	2025-09-26 23:01:18.985393+00	password	feb75d71-00c6-4662-aa3f-ef647ca927de
62e9c3b7-4827-4f2d-b3f9-5f0b4559313c	2025-09-26 23:02:17.270144+00	2025-09-26 23:02:17.270144+00	otp	bfe0d4c6-748a-4900-a8a6-e967b7f646ad
fcfa0146-570f-4dc9-978f-452902ae3f5f	2025-09-26 23:08:32.539425+00	2025-09-26 23:08:32.539425+00	otp	dfbb7f0c-40b3-4862-bbec-9f09f969919f
1c592d80-e271-4f25-973b-bf073c088cbd	2025-09-26 23:09:58.003054+00	2025-09-26 23:09:58.003054+00	otp	6b8d3b19-5c72-4f00-b1d5-a0ed1219220a
eb7bd3b3-6106-42cc-bc2a-8919da90a8b4	2025-09-26 23:15:08.508823+00	2025-09-26 23:15:08.508823+00	otp	410c574e-71cc-42a5-8c4d-aecb42d626e5
40e19829-7ebc-49a5-8c00-67ebdcd4eeb8	2025-09-27 20:12:52.596258+00	2025-09-27 20:12:52.596258+00	password	8e3f6403-4a8f-41db-a6f4-0bda243815d9
066bf61d-4e0e-448b-94f5-f30011d17fa7	2025-09-27 21:28:58.325105+00	2025-09-27 21:28:58.325105+00	password	cbbc31b9-8f31-4019-b94b-d88cc987279a
17d0de8c-131c-4812-8335-043e43a0ddea	2025-09-27 21:55:42.008136+00	2025-09-27 21:55:42.008136+00	password	41ab10d1-056c-4646-a563-5f8012ba4943
9a8ef10a-14d6-4559-b587-c26b40618cb5	2025-09-28 18:18:56.776045+00	2025-09-28 18:18:56.776045+00	password	21292de4-52bc-41e8-a596-e9055338fa08
725cd264-5811-4e1d-b9a8-3e00696ca092	2025-09-28 22:02:33.71575+00	2025-09-28 22:02:33.71575+00	password	4a3cbbb5-61f7-4ac6-bdf0-4f746e35c60f
84eaf787-0d12-4a76-906d-35d89f1551b7	2025-09-29 01:18:16.3222+00	2025-09-29 01:18:16.3222+00	password	9e8e8ee8-dfc1-4ad1-9471-2bd42447a915
ef632746-7bd6-4459-a497-06e7df6f1046	2025-09-29 01:18:56.823037+00	2025-09-29 01:18:56.823037+00	password	ad3750ab-65ef-4860-b056-4b32b2eecc74
d9a70e68-8fc2-452f-8a23-5d982be83ec2	2025-09-29 01:52:20.435275+00	2025-09-29 01:52:20.435275+00	password	a287e80a-4fb1-4761-9504-679763b159dc
903b85d5-f326-4dae-b496-1f46328f31a6	2025-09-29 01:55:24.111681+00	2025-09-29 01:55:24.111681+00	password	130b3e5b-4347-4159-af9e-fa02d41ec217
5a41f105-4990-4ef1-88ac-82b2bbc00d04	2025-09-29 01:55:27.069144+00	2025-09-29 01:55:27.069144+00	password	8f58d0ec-e9ef-4bb9-82f0-3c8a89992298
8b042945-b6f4-4887-a76c-9565c3c2327b	2025-09-29 01:55:39.641678+00	2025-09-29 01:55:39.641678+00	password	44f46fd4-a8b2-4c98-98bc-0ba1062f44bc
2c7c85b8-be0f-48d8-b075-49f62c720f54	2025-09-29 01:58:48.679109+00	2025-09-29 01:58:48.679109+00	password	e1822cd3-8b13-40cb-a303-71cf952a5e97
e2698428-dc8e-4886-8f28-0b7b7fb866f8	2025-09-29 02:38:13.953629+00	2025-09-29 02:38:13.953629+00	password	1124bf89-d313-4e3f-a391-5ed33f79ce0a
942a51d2-470e-410f-aa70-f03d985658d3	2025-09-29 03:43:58.981638+00	2025-09-29 03:43:58.981638+00	password	e85d07bd-5425-4f2f-baed-da854be439d2
288094a8-de3b-45f4-9d5b-ff25f4eed972	2025-09-29 04:01:50.695816+00	2025-09-29 04:01:50.695816+00	password	199def42-243d-412f-8196-59e55fe796ab
126ff890-43f6-4cf5-9b58-c83af2d95205	2025-09-29 04:03:44.847728+00	2025-09-29 04:03:44.847728+00	password	911dae50-5a06-4598-af6f-01e8d8edba00
07c2ba0b-4b7a-4580-8631-ce0cfd59b5be	2025-09-29 04:16:11.666406+00	2025-09-29 04:16:11.666406+00	password	cfb94194-0922-4337-80f1-76ed21341680
d9d0793e-377e-4b2d-9855-f4b9f1585dc0	2025-09-29 04:21:13.085036+00	2025-09-29 04:21:13.085036+00	password	61912b61-3af8-4c3a-bf9e-62d754fcca6d
1cc4ef10-f2e9-4df9-88cf-afba444b7592	2025-09-29 04:40:32.402752+00	2025-09-29 04:40:32.402752+00	password	357af82a-2057-4b0c-94e9-85a491ece371
e56b6eb8-7d1d-4501-8474-a3b85e8a53a5	2025-09-29 04:52:15.79914+00	2025-09-29 04:52:15.79914+00	password	df24a085-b38b-4177-8dc5-d2e1324ab6b8
a478b1da-611c-422c-af62-5f8718cf9433	2025-09-29 04:52:36.368297+00	2025-09-29 04:52:36.368297+00	password	49a4cf77-fa85-4072-b82b-c264e127ddbf
f503e6f2-6a96-4318-9133-6779f36469f1	2025-09-29 04:52:38.283481+00	2025-09-29 04:52:38.283481+00	password	dc9d680f-b028-428e-b365-ff0d938b7314
d6f6c0ec-5577-475a-afb6-3c6ec9134da7	2025-09-29 05:20:52.050761+00	2025-09-29 05:20:52.050761+00	password	98a134ed-2711-4e9d-bcf0-e6ce8fcf3e7a
c5d90591-bf5b-4abf-ba1f-cc22844f2527	2025-09-29 05:36:54.358054+00	2025-09-29 05:36:54.358054+00	password	dcf236cb-c9ef-45b8-aa2f-9fcbc1a6222d
fc4fc8b3-d213-4a6b-bb9d-5cecb8ee85d2	2025-09-29 05:36:56.529816+00	2025-09-29 05:36:56.529816+00	password	b49808a4-8c46-43ae-98c5-4d0163dfd126
d586d7e6-5428-4c91-8fd2-19d522a98a1f	2025-09-29 05:39:04.965276+00	2025-09-29 05:39:04.965276+00	password	0ca2bccb-2e6c-4328-bbf3-9ba37a2ad194
3b6a6ad8-d19b-42d6-be4b-f7d59757ad8f	2025-09-29 06:22:49.784222+00	2025-09-29 06:22:49.784222+00	password	474455d5-7072-42ff-903e-0f71a10322b1
c26859af-aa74-4c16-953d-73bd7eaf905d	2025-09-29 06:43:40.848549+00	2025-09-29 06:43:40.848549+00	password	a035e670-5788-4093-bf21-551284b5e8a5
7a2d5f1b-2bd6-415d-a942-f08c72628d28	2025-09-29 06:57:46.428769+00	2025-09-29 06:57:46.428769+00	password	12a5c6ea-dfca-439a-bee8-985c4e4be203
64a6b0e6-a071-4930-a370-1db3357d6ba9	2025-09-29 07:05:54.296427+00	2025-09-29 07:05:54.296427+00	password	8f08a891-d86b-4a3d-a003-5dd8bfa9735d
c069bef0-ef33-42b6-927d-78c318f7db27	2025-09-29 19:33:08.669164+00	2025-09-29 19:33:08.669164+00	password	3323011b-2e43-498d-bb9d-a50e48a8270f
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_clients (id, client_id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
00000000-0000-0000-0000-000000000000	417	6J9BJSN3pRtGmtrmNL-KUA	bf250d15-2188-413b-b954-120a31ca5840	t	2025-05-03 21:05:28.805224+00	2025-05-03 21:06:36.076751+00	nizi2NYE3kcDPxl8g8OOFA	e03c19f5-ffe2-4a63-942b-451f48840200
00000000-0000-0000-0000-000000000000	31	zCzRKSSB2RLqFvRSxOmXlg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-26 19:24:16.253312+00	2025-03-26 19:24:16.253312+00	\N	02c09fa3-41db-483d-9e6e-d85ab6d9ff93
00000000-0000-0000-0000-000000000000	32	oX-ZODzqETvpIf7NIj-NCg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-26 19:27:20.804884+00	2025-03-26 19:27:20.804884+00	\N	8b0e4112-b5cb-4d46-bd52-ef26600897c9
00000000-0000-0000-0000-000000000000	33	moAECp-Y7ZMbRLDLrOzUnw	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-26 20:08:18.230782+00	2025-03-26 20:08:18.230782+00	\N	074ed4bc-16ee-4fdd-9640-a1ddcd5151f0
00000000-0000-0000-0000-000000000000	34	laOvdV0T702Z-0kyCruJaw	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-26 20:10:28.490144+00	2025-03-26 20:10:28.490144+00	\N	9e4248da-131b-4abf-87b7-a496b37f3c4b
00000000-0000-0000-0000-000000000000	35	8BiHMBQMB1QbydJMrWGiVg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-26 20:17:08.724533+00	2025-03-26 20:17:08.724533+00	\N	aea4c651-4e1e-48f4-8afb-9c45d73eede6
00000000-0000-0000-0000-000000000000	36	ZUmjTalPh79BHHES43H9tw	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-26 20:19:03.115169+00	2025-03-26 20:19:03.115169+00	\N	e693787e-1c24-41f8-bfb2-8b0d295ef3e6
00000000-0000-0000-0000-000000000000	37	NWy-LUY50nWFm6CZVIuajg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-26 20:20:45.360914+00	2025-03-26 20:20:45.360914+00	\N	b2029b81-a467-48ea-b4b0-861153e7142b
00000000-0000-0000-0000-000000000000	38	_-qJYA1OBXdF44UpoJoKmw	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-26 20:21:44.540534+00	2025-03-26 20:21:44.540534+00	\N	cb9360a6-b75e-46f2-bac0-8ed97e005f34
00000000-0000-0000-0000-000000000000	39	N6q8hGH_6hi3O8e0N6TyOg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-26 20:23:34.687762+00	2025-03-26 20:23:34.687762+00	\N	f42520ce-6019-41f6-936a-4cf2c410a0b0
00000000-0000-0000-0000-000000000000	40	bEk655YzUR-aSt-ioSlKVQ	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-26 20:25:34.4805+00	2025-03-26 20:25:34.4805+00	\N	6b96f06a-c6d9-4516-ba2f-c023c0ad791a
00000000-0000-0000-0000-000000000000	41	25fKvayGVDrvdPf8WAHmYQ	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-26 20:31:03.207669+00	2025-03-26 20:31:03.207669+00	\N	a8383d5f-611d-46f6-9620-2162b6ce5193
00000000-0000-0000-0000-000000000000	43	-Qe2fxlCKyT9iYlCapg7Tw	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-26 20:50:23.398171+00	2025-03-26 20:50:23.398171+00	\N	91875e7d-8757-44c5-a78a-0e584b1c1b33
00000000-0000-0000-0000-000000000000	44	7dDmCZX8EwoCZH7ipTF39g	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-26 21:10:15.545518+00	2025-03-26 21:10:15.545518+00	\N	ebd413d7-1e0f-4caa-bf72-b9c7fbdc4879
00000000-0000-0000-0000-000000000000	42	Ss3SK-4l3rbLXwBr0NNtnw	bf250d15-2188-413b-b954-120a31ca5840	t	2025-03-26 20:31:11.336976+00	2025-03-26 21:31:01.649098+00	\N	ac701636-1b72-403b-b3e1-ebda28c5e9be
00000000-0000-0000-0000-000000000000	45	Nx8OlFkzYxO-FEtNhh6Djw	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-26 21:31:01.651866+00	2025-03-26 21:31:01.651866+00	Ss3SK-4l3rbLXwBr0NNtnw	ac701636-1b72-403b-b3e1-ebda28c5e9be
00000000-0000-0000-0000-000000000000	46	ra4h9hsznCHi6sUNwmzwxQ	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-30 00:36:20.769806+00	2025-03-30 00:36:20.769806+00	\N	81975daa-dd3c-4217-8e0d-8d472a80cfbe
00000000-0000-0000-0000-000000000000	47	5j3E1LW6oVJ4OqA7KJn5LQ	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-30 00:37:59.516243+00	2025-03-30 00:37:59.516243+00	\N	b0fbf591-fb54-4997-82e5-7a542ba06807
00000000-0000-0000-0000-000000000000	48	xHQkuFOtgmtVGr7kgaGiFQ	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-30 17:48:23.886369+00	2025-03-30 17:48:23.886369+00	\N	1238fb8a-1436-4854-abe2-ff446b715299
00000000-0000-0000-0000-000000000000	49	VbFThH16SXoP9BySB6xQlQ	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-30 21:47:55.780027+00	2025-03-30 21:47:55.780027+00	\N	10c685d6-0361-49d9-8796-072dde50fd33
00000000-0000-0000-0000-000000000000	50	lcIRNrShnu_LSxlVUu8vMw	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-30 22:10:12.715938+00	2025-03-30 22:10:12.715938+00	\N	7de13324-c133-4b8f-be02-45c9d92f3a9f
00000000-0000-0000-0000-000000000000	51	kZn6VOisoI6bKiFRLiBi-g	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-30 22:11:51.703215+00	2025-03-30 22:11:51.703215+00	\N	6ddb6c89-caca-4386-bbd0-0fa7bf35e39a
00000000-0000-0000-0000-000000000000	52	BcOatJzL11yt-DQ6GlxLhw	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-30 22:14:23.7037+00	2025-03-30 22:14:23.7037+00	\N	f260b724-f528-42a7-8db4-6fd799b996a7
00000000-0000-0000-0000-000000000000	53	6zl5ItT4UpqgzA9MdD9ugg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-31 05:22:34.232018+00	2025-03-31 05:22:34.232018+00	\N	5abd24b2-f3c0-40fc-9004-5b26c7543d8c
00000000-0000-0000-0000-000000000000	54	gfZroNkYE__aQKV9NpYb2Q	bf250d15-2188-413b-b954-120a31ca5840	f	2025-03-31 05:38:27.52848+00	2025-03-31 05:38:27.52848+00	\N	cfeae367-5189-4bec-8686-d49aec3ec71b
00000000-0000-0000-0000-000000000000	418	Eu5_i9DxUFNTOMDzYxDc8Q	bf250d15-2188-413b-b954-120a31ca5840	t	2025-05-03 21:06:36.077944+00	2025-05-03 21:13:16.158647+00	6J9BJSN3pRtGmtrmNL-KUA	e03c19f5-ffe2-4a63-942b-451f48840200
00000000-0000-0000-0000-000000000000	62	TgDSaQbTc_-aM5-2pjP0JA	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-01 21:43:47.58132+00	2025-04-01 21:43:47.58132+00	\N	9cae04dd-8e75-4c99-ad80-1091efb3a205
00000000-0000-0000-0000-000000000000	63	M3xz0ZzezWl23cvrp77jCw	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-01 21:44:34.189662+00	2025-04-01 21:44:34.189662+00	\N	6906e6bc-384f-4207-8e5d-a9fb307a186f
00000000-0000-0000-0000-000000000000	64	1pTxHJ8gXZ_DuU6z__OfZQ	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-01 21:47:06.659411+00	2025-04-01 21:47:06.659411+00	\N	ea0776cb-bf09-4e44-bc53-0ff669ab2e1b
00000000-0000-0000-0000-000000000000	65	kGLz9e60J0s8XlcUu404pQ	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-01 21:48:52.68463+00	2025-04-01 21:48:52.68463+00	\N	0ef81737-c780-4166-9ee7-f23ded438cf8
00000000-0000-0000-0000-000000000000	66	YXHMyZm--7RuroBNZANYUQ	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-01 22:06:03.517236+00	2025-04-01 22:06:03.517236+00	\N	0a69daaa-bc93-42a0-a8c9-11737c9e9b57
00000000-0000-0000-0000-000000000000	67	jmJoxgKbLwJZm9bgELSNKw	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-10 00:03:15.066139+00	2025-04-10 01:03:03.388213+00	\N	00ae48b1-545f-4471-a712-f1b2ade005d2
00000000-0000-0000-0000-000000000000	69	kFAORoynNiRzMecWHvsgEg	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-10 01:03:03.393229+00	2025-04-10 01:03:03.459489+00	jmJoxgKbLwJZm9bgELSNKw	00ae48b1-545f-4471-a712-f1b2ade005d2
00000000-0000-0000-0000-000000000000	68	vgT1wMyuMOUshTzcTzvcJA	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-10 00:03:25.809221+00	2025-04-10 01:03:13.961746+00	\N	c3cae0ec-4c4c-4aba-b65f-2a435ccc53a8
00000000-0000-0000-0000-000000000000	71	K5zvIK6JmaIT0YQ3k4cyOQ	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-10 01:03:13.962042+00	2025-04-10 01:03:14.065429+00	vgT1wMyuMOUshTzcTzvcJA	c3cae0ec-4c4c-4aba-b65f-2a435ccc53a8
00000000-0000-0000-0000-000000000000	70	0xEeOayY1qtr64cyszQaHA	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-10 01:03:03.460964+00	2025-04-10 02:02:51.748652+00	kFAORoynNiRzMecWHvsgEg	00ae48b1-545f-4471-a712-f1b2ade005d2
00000000-0000-0000-0000-000000000000	74	W7ssqyNrE00OO1FtBVIrQg	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-10 02:02:51.751151+00	2025-04-10 02:02:51.842853+00	0xEeOayY1qtr64cyszQaHA	00ae48b1-545f-4471-a712-f1b2ade005d2
00000000-0000-0000-0000-000000000000	72	Tarq761mAb05Ckitpj01KQ	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-10 01:03:14.066416+00	2025-04-10 02:03:03.211419+00	K5zvIK6JmaIT0YQ3k4cyOQ	c3cae0ec-4c4c-4aba-b65f-2a435ccc53a8
00000000-0000-0000-0000-000000000000	76	MkqIT0JZ2641WBGL0tXtHQ	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-10 02:03:03.211739+00	2025-04-10 02:03:03.314186+00	Tarq761mAb05Ckitpj01KQ	c3cae0ec-4c4c-4aba-b65f-2a435ccc53a8
00000000-0000-0000-0000-000000000000	75	Zd3UDCyUWvEyolaQDASKvQ	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-10 02:02:51.843165+00	2025-04-10 03:02:40.122701+00	W7ssqyNrE00OO1FtBVIrQg	00ae48b1-545f-4471-a712-f1b2ade005d2
00000000-0000-0000-0000-000000000000	77	pgydi-7El62H-FbBbTsVSw	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-10 02:03:03.314486+00	2025-04-10 03:02:51.489909+00	MkqIT0JZ2641WBGL0tXtHQ	c3cae0ec-4c4c-4aba-b65f-2a435ccc53a8
00000000-0000-0000-0000-000000000000	84	rtUhJzRhEEEMhWtqP3c7mg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-10 03:51:21.52639+00	2025-04-10 03:51:21.52639+00	\N	ca5bf2f7-be3d-42de-aa85-36467dad35e3
00000000-0000-0000-0000-000000000000	80	3DXCqw0VbJ5ZtOQH7YG6oA	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-10 03:02:40.123888+00	2025-04-10 04:02:30.383145+00	Zd3UDCyUWvEyolaQDASKvQ	00ae48b1-545f-4471-a712-f1b2ade005d2
00000000-0000-0000-0000-000000000000	85	WFZyiuRp-t--YztEn6AqyQ	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-10 04:02:30.385129+00	2025-04-10 04:02:30.464467+00	3DXCqw0VbJ5ZtOQH7YG6oA	00ae48b1-545f-4471-a712-f1b2ade005d2
00000000-0000-0000-0000-000000000000	86	frgZIuW5JRwZIapPsVxHNg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-10 04:02:30.464783+00	2025-04-10 04:02:30.464783+00	WFZyiuRp-t--YztEn6AqyQ	00ae48b1-545f-4471-a712-f1b2ade005d2
00000000-0000-0000-0000-000000000000	81	kvddJpOSl9fBuUNszpqVdQ	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-10 03:02:51.490199+00	2025-04-10 04:02:40.636872+00	pgydi-7El62H-FbBbTsVSw	c3cae0ec-4c4c-4aba-b65f-2a435ccc53a8
00000000-0000-0000-0000-000000000000	87	Emk9ikowk12_fnHD_iOhDA	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-10 04:02:40.6372+00	2025-04-10 04:02:40.694131+00	kvddJpOSl9fBuUNszpqVdQ	c3cae0ec-4c4c-4aba-b65f-2a435ccc53a8
00000000-0000-0000-0000-000000000000	88	4tJxtkpl2aXC04hI-hiutg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-10 04:02:40.694429+00	2025-04-10 04:02:40.694429+00	Emk9ikowk12_fnHD_iOhDA	c3cae0ec-4c4c-4aba-b65f-2a435ccc53a8
00000000-0000-0000-0000-000000000000	89	cvpzeFtqnVvHHmL5da8jsw	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-11 15:08:52.911583+00	2025-04-11 15:08:52.911583+00	\N	8ad101cf-f5a4-48dd-a3be-d8a3544bd24e
00000000-0000-0000-0000-000000000000	90	Cw7hgvLQYpRfZHTpyAsAYw	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-11 15:10:49.753114+00	2025-04-11 15:10:49.753114+00	\N	195c9e8c-8e78-41ec-885b-4d76ae239418
00000000-0000-0000-0000-000000000000	92	M24msm-Tf826Do1MNBVrLg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-11 15:43:44.672598+00	2025-04-11 15:43:44.672598+00	\N	a226a2e9-60aa-448b-959d-9721d44caad1
00000000-0000-0000-0000-000000000000	93	ixCAbjbVHPU5qYHrSQg8VA	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-11 15:51:49.250429+00	2025-04-11 15:51:49.250429+00	\N	91fdfa03-d938-463c-864e-6c38eaab7f6f
00000000-0000-0000-0000-000000000000	419	BBzbMZT2mt8remtVwyLZeQ	bf250d15-2188-413b-b954-120a31ca5840	f	2025-05-03 21:13:16.162017+00	2025-05-03 21:13:16.162017+00	Eu5_i9DxUFNTOMDzYxDc8Q	e03c19f5-ffe2-4a63-942b-451f48840200
00000000-0000-0000-0000-000000000000	408	0cARvgBmxYndNrfXUki65w	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-05-03 20:36:11.819742+00	2025-05-03 20:39:39.016631+00	\N	7006555d-0a48-41e6-80d7-bc78441f4cc0
00000000-0000-0000-0000-000000000000	420	x7QX3M78W7-SVEQ4VvGu1A	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-05-04 00:27:25.891446+00	2025-05-04 01:27:16.350243+00	\N	9711f210-f944-436f-94f0-e4c4caa489c2
00000000-0000-0000-0000-000000000000	176	1PIE1nhJ98Vta0r_2-LQNA	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-13 17:43:50.844622+00	2025-04-13 17:43:50.844622+00	\N	3901fc23-e282-4c9c-bb47-c029f4903ff3
00000000-0000-0000-0000-000000000000	177	DWwpaB69N52KlG12MGfIPA	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-13 17:46:34.762192+00	2025-04-13 17:46:34.762192+00	\N	deaa56d3-2c18-45ed-8ede-2b6ca1261c07
00000000-0000-0000-0000-000000000000	178	aStJR3vuja9Y6dEMnLSffA	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-13 17:47:19.026916+00	2025-04-13 17:47:19.026916+00	\N	b948d350-ff7a-47cb-b4d4-8d78994c4620
00000000-0000-0000-0000-000000000000	180	HCNeUiIO5UyErDoBHS74zg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-14 19:06:13.263565+00	2025-04-14 19:06:13.263565+00	\N	c81018f0-4aaf-4693-9d5d-5675296e941c
00000000-0000-0000-0000-000000000000	181	fINvO88umlZn1GZeRw5Ntg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-14 19:06:15.647982+00	2025-04-14 19:06:15.647982+00	\N	e510a996-77ce-4e18-a594-55465a03b986
00000000-0000-0000-0000-000000000000	182	zd9KpR95_wRPErTFhtlvDw	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-14 19:06:17.065343+00	2025-04-14 20:06:08.303994+00	\N	220e457f-5908-4039-a283-ce75ca266382
00000000-0000-0000-0000-000000000000	183	Cz0Lo0vvqky665QfqPNPnw	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-14 20:06:08.309502+00	2025-04-14 20:06:08.363863+00	zd9KpR95_wRPErTFhtlvDw	220e457f-5908-4039-a283-ce75ca266382
00000000-0000-0000-0000-000000000000	184	-GBU9xSeSM-pOwPOUSp2PA	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-14 20:06:08.364168+00	2025-04-14 20:06:08.364168+00	Cz0Lo0vvqky665QfqPNPnw	220e457f-5908-4039-a283-ce75ca266382
00000000-0000-0000-0000-000000000000	185	q0gwrEoBCgb-a9AyBDeyug	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-14 22:13:32.687262+00	2025-04-14 22:13:32.687262+00	\N	935c6082-2e84-45d8-8067-dac5cadd189a
00000000-0000-0000-0000-000000000000	186	vMZ7OYKplzn9LvRn7E6KDQ	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-14 22:15:46.826566+00	2025-04-14 22:15:46.826566+00	\N	16ce9913-e975-4bd6-b4cf-02c215639946
00000000-0000-0000-0000-000000000000	188	VUONxUszhAnJoxhcez1mmQ	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-14 22:42:52.231618+00	2025-04-14 23:42:42.485483+00	\N	6f92ec87-8705-4fe4-ace2-aef03c67a7f9
00000000-0000-0000-0000-000000000000	189	TPBu5fnbSjAT4kGYopakqA	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-14 23:42:42.489362+00	2025-04-14 23:42:42.568366+00	VUONxUszhAnJoxhcez1mmQ	6f92ec87-8705-4fe4-ace2-aef03c67a7f9
00000000-0000-0000-0000-000000000000	190	s-sG3aNgwzxhPMeIHWkqFw	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-14 23:42:42.568672+00	2025-04-14 23:42:42.568672+00	TPBu5fnbSjAT4kGYopakqA	6f92ec87-8705-4fe4-ace2-aef03c67a7f9
00000000-0000-0000-0000-000000000000	191	7X9x7g93Qgsu2Hw7U62peg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-15 00:28:13.664049+00	2025-04-15 00:28:13.664049+00	\N	63a45b0d-f621-44e1-9881-4b543b1a26ee
00000000-0000-0000-0000-000000000000	192	R9PLeaDTN7_eXp6LqIZycg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-15 00:56:47.881221+00	2025-04-15 00:56:47.881221+00	\N	c43643fd-1a50-484d-912b-c7d5b827a211
00000000-0000-0000-0000-000000000000	193	CG3zq5ogRb4MunpZJFg1Ew	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-15 00:57:57.8317+00	2025-04-15 00:57:57.8317+00	\N	ba10fb1b-cc7f-45b7-92fd-e7d47aacfcc5
00000000-0000-0000-0000-000000000000	409	80pVh5Dm7qoVabkWy-6jgA	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-05-03 20:39:39.019056+00	2025-05-03 20:39:39.019056+00	0cARvgBmxYndNrfXUki65w	7006555d-0a48-41e6-80d7-bc78441f4cc0
00000000-0000-0000-0000-000000000000	410	cVkm2pEAZAM9XupbqIZjxw	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-05-03 20:40:18.837817+00	2025-05-03 20:40:18.837817+00	\N	5776bee8-ded7-430c-a312-9f9766075c77
00000000-0000-0000-0000-000000000000	411	xs3x9oncj2LNhpVhd_tdHA	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-05-03 20:41:27.118733+00	2025-05-03 20:41:27.118733+00	\N	90f1e9d5-bb09-4b6f-8926-7eec1c9dfd51
00000000-0000-0000-0000-000000000000	412	JeoI_o1VNBflA5FY7oJ8jg	bf250d15-2188-413b-b954-120a31ca5840	t	2025-05-03 20:42:27.108133+00	2025-05-03 20:42:30.610949+00	\N	96e6199a-bd27-452e-bf9c-9011e9bc92bf
00000000-0000-0000-0000-000000000000	413	PZNfA1SD1di0Hfj3wCbKVg	bf250d15-2188-413b-b954-120a31ca5840	t	2025-05-03 20:42:30.611283+00	2025-05-03 20:59:46.065635+00	JeoI_o1VNBflA5FY7oJ8jg	96e6199a-bd27-452e-bf9c-9011e9bc92bf
00000000-0000-0000-0000-000000000000	421	bkLON4qsX66eVuWQ8KVg3g	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-05-04 01:27:16.355321+00	2025-05-04 01:27:16.428923+00	x7QX3M78W7-SVEQ4VvGu1A	9711f210-f944-436f-94f0-e4c4caa489c2
00000000-0000-0000-0000-000000000000	422	_mMLK6LILZCB0qtjOSLjhg	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-05-04 01:27:16.429782+00	2025-05-04 01:27:16.429782+00	bkLON4qsX66eVuWQ8KVg3g	9711f210-f944-436f-94f0-e4c4caa489c2
00000000-0000-0000-0000-000000000000	213	78MGxgCm9aqZEVXpefTm3A	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-19 00:43:08.213662+00	2025-04-19 00:43:08.213662+00	\N	d61a2d50-298a-41ad-9a46-19e69af57515
00000000-0000-0000-0000-000000000000	214	FSZE11bGWoiEZG8EcD4yiA	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-19 16:35:53.471694+00	2025-04-19 16:35:53.471694+00	\N	46b83fa0-9db7-4e07-add9-d7006e2021d7
00000000-0000-0000-0000-000000000000	215	t2_57PIVzYzeVROTnNnFFw	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-19 16:46:33.590945+00	2025-04-19 16:46:33.590945+00	\N	18242170-cf07-4ef9-a1ea-172e2352802b
00000000-0000-0000-0000-000000000000	216	V7AHbnvYjuwRXf3gbZPE_g	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-19 16:48:31.805687+00	2025-04-19 16:48:31.805687+00	\N	e36f9dba-faed-4545-a2e1-fb3b442733d5
00000000-0000-0000-0000-000000000000	217	_VbJAO0GyrO8zZiE13s5CQ	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-19 16:48:36.148667+00	2025-04-19 16:48:36.148667+00	\N	860dd21b-60d7-41ec-80c7-c9ea0aadd529
00000000-0000-0000-0000-000000000000	218	OgNYWDkavojNxBYGwECi7w	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-19 17:15:39.788808+00	2025-04-19 17:15:39.788808+00	\N	957ae2ce-6e6f-4f7b-b32b-8d1bb7c39be0
00000000-0000-0000-0000-000000000000	219	mWyx5lTFeXnsy-VcMfqyyg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-19 17:15:42.142544+00	2025-04-19 17:15:42.142544+00	\N	50540fee-1412-4f40-b4de-9b34eb2942d2
00000000-0000-0000-0000-000000000000	220	wB_Iw0a8DGqTG1i4kqe-aw	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-19 18:04:26.900368+00	2025-04-19 18:04:26.900368+00	\N	6af7747d-b891-4b55-99b0-1d1422e7ee65
00000000-0000-0000-0000-000000000000	223	FOUpdjzJduBditFpJPJXMw	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-20 23:18:56.881725+00	2025-04-20 23:18:56.881725+00	\N	c34b90d7-cd6a-4df9-b5a5-2053d7a42e6f
00000000-0000-0000-0000-000000000000	224	9OdCpACjVd-d4YNuoQ4jBA	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-20 23:19:00.322895+00	2025-04-20 23:19:00.322895+00	\N	d0b51716-7860-43ce-8dd3-6ba415217384
00000000-0000-0000-0000-000000000000	414	9A11Ps54CwI6xl6OzjdyfQ	bf250d15-2188-413b-b954-120a31ca5840	f	2025-05-03 20:59:46.069448+00	2025-05-03 20:59:46.069448+00	PZNfA1SD1di0Hfj3wCbKVg	96e6199a-bd27-452e-bf9c-9011e9bc92bf
00000000-0000-0000-0000-000000000000	423	c357TjycS07GEbnpRxtpMQ	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-05-04 01:33:38.432721+00	2025-05-04 01:33:38.432721+00	\N	e971e0d2-9215-4868-a3ec-45a61f772cad
00000000-0000-0000-0000-000000000000	415	T-fqBaDX71fQHjBgUZ2gOQ	bf250d15-2188-413b-b954-120a31ca5840	f	2025-05-03 21:00:50.451981+00	2025-05-03 21:00:50.451981+00	\N	fe367ed1-0301-48b1-803a-71aafc0a2611
00000000-0000-0000-0000-000000000000	424	xPX0j_ofOuV7PjU7O-jv1w	bf250d15-2188-413b-b954-120a31ca5840	t	2025-05-08 17:31:22.801595+00	2025-05-08 17:32:35.609649+00	\N	792b6c44-22cf-4a9b-ba8a-a09e6c4ff9d5
00000000-0000-0000-0000-000000000000	425	f3rFhqbVzPm8mITDRiX-fA	bf250d15-2188-413b-b954-120a31ca5840	t	2025-05-08 17:32:35.614135+00	2025-05-08 17:33:51.511625+00	xPX0j_ofOuV7PjU7O-jv1w	792b6c44-22cf-4a9b-ba8a-a09e6c4ff9d5
00000000-0000-0000-0000-000000000000	343	Bgn11gn_BZPP2BT0oQctaw	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-28 01:51:56.115704+00	2025-04-28 02:51:46.438842+00	\N	6081e976-fbcb-4d9b-84d6-215ac319094d
00000000-0000-0000-0000-000000000000	344	TFxxxd2UkIJRSnGMs9f2Ow	bf250d15-2188-413b-b954-120a31ca5840	t	2025-04-28 02:51:46.444807+00	2025-04-28 02:51:46.536895+00	Bgn11gn_BZPP2BT0oQctaw	6081e976-fbcb-4d9b-84d6-215ac319094d
00000000-0000-0000-0000-000000000000	345	3xag1ATV-JZViNwzxNh-EA	bf250d15-2188-413b-b954-120a31ca5840	f	2025-04-28 02:51:46.537228+00	2025-04-28 02:51:46.537228+00	TFxxxd2UkIJRSnGMs9f2Ow	6081e976-fbcb-4d9b-84d6-215ac319094d
00000000-0000-0000-0000-000000000000	416	nizi2NYE3kcDPxl8g8OOFA	bf250d15-2188-413b-b954-120a31ca5840	t	2025-05-03 21:03:12.11627+00	2025-05-03 21:05:28.802951+00	\N	e03c19f5-ffe2-4a63-942b-451f48840200
00000000-0000-0000-0000-000000000000	426	kjV5VV5etRAOQD_JuxaHQg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-05-08 17:33:51.512272+00	2025-05-08 17:33:51.512272+00	f3rFhqbVzPm8mITDRiX-fA	792b6c44-22cf-4a9b-ba8a-a09e6c4ff9d5
00000000-0000-0000-0000-000000000000	427	dnscytz7e42r	bf250d15-2188-413b-b954-120a31ca5840	t	2025-07-26 00:39:46.953779+00	2025-07-26 00:39:59.718542+00	\N	4d6f494b-9739-4be0-8225-7191e57fed6d
00000000-0000-0000-0000-000000000000	428	psar4ag3a4vo	bf250d15-2188-413b-b954-120a31ca5840	f	2025-07-26 00:39:59.719694+00	2025-07-26 00:39:59.719694+00	dnscytz7e42r	4d6f494b-9739-4be0-8225-7191e57fed6d
00000000-0000-0000-0000-000000000000	429	lta7g2pjymz6	bf250d15-2188-413b-b954-120a31ca5840	t	2025-08-29 16:38:41.925986+00	2025-08-29 16:39:12.5536+00	\N	1a9f0bad-6fe3-4494-a78b-fd90b1f1ffe0
00000000-0000-0000-0000-000000000000	583	t7exjicm2zee	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-15 07:32:26.743569+00	2025-09-15 07:32:26.743569+00	tae63ide7obk	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	430	upfujyb5adop	bf250d15-2188-413b-b954-120a31ca5840	t	2025-08-29 16:39:12.5573+00	2025-08-29 16:39:33.430021+00	lta7g2pjymz6	1a9f0bad-6fe3-4494-a78b-fd90b1f1ffe0
00000000-0000-0000-0000-000000000000	431	eiv6ad7363xg	bf250d15-2188-413b-b954-120a31ca5840	t	2025-08-29 16:39:33.433173+00	2025-08-29 16:40:12.566799+00	upfujyb5adop	1a9f0bad-6fe3-4494-a78b-fd90b1f1ffe0
00000000-0000-0000-0000-000000000000	587	u5yn2vv56vr5	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-15 08:14:04.659222+00	2025-09-15 08:30:02.270576+00	\N	60e6db0b-9148-4e3d-8fc6-6bcfc79505f6
00000000-0000-0000-0000-000000000000	432	grnnwiepurmn	bf250d15-2188-413b-b954-120a31ca5840	t	2025-08-29 16:40:12.567194+00	2025-08-29 16:40:14.650591+00	eiv6ad7363xg	1a9f0bad-6fe3-4494-a78b-fd90b1f1ffe0
00000000-0000-0000-0000-000000000000	433	7lp2sotyykt6	bf250d15-2188-413b-b954-120a31ca5840	t	2025-08-29 16:40:14.651347+00	2025-08-29 16:40:20.459663+00	grnnwiepurmn	1a9f0bad-6fe3-4494-a78b-fd90b1f1ffe0
00000000-0000-0000-0000-000000000000	434	lhrnqr3u2chj	bf250d15-2188-413b-b954-120a31ca5840	f	2025-08-29 16:40:20.460706+00	2025-08-29 16:40:20.460706+00	7lp2sotyykt6	1a9f0bad-6fe3-4494-a78b-fd90b1f1ffe0
00000000-0000-0000-0000-000000000000	435	un544z5fycp6	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-04 02:57:31.633346+00	2025-09-04 02:57:31.633346+00	\N	72c3ee15-f774-4706-9f43-c60a75b3f7e3
00000000-0000-0000-0000-000000000000	589	vtmrcnlx3tdn	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-15 08:30:02.282171+00	2025-09-15 08:36:47.288714+00	u5yn2vv56vr5	60e6db0b-9148-4e3d-8fc6-6bcfc79505f6
00000000-0000-0000-0000-000000000000	436	n2fillpy2vhw	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-04 03:00:22.149971+00	2025-09-04 03:00:24.786952+00	\N	e3dd638f-dd2c-483c-8b9e-ff2bd331fc05
00000000-0000-0000-0000-000000000000	591	wxya5v6llnkb	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-15 10:38:28.155064+00	2025-09-15 10:38:28.155064+00	eohmrzegdbps	60e6db0b-9148-4e3d-8fc6-6bcfc79505f6
00000000-0000-0000-0000-000000000000	437	2r4miw4tbwf6	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-04 03:00:24.793023+00	2025-09-04 03:05:49.786064+00	n2fillpy2vhw	e3dd638f-dd2c-483c-8b9e-ff2bd331fc05
00000000-0000-0000-0000-000000000000	438	2zjxp46borbn	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-04 03:05:49.790846+00	2025-09-04 03:10:05.554316+00	2r4miw4tbwf6	e3dd638f-dd2c-483c-8b9e-ff2bd331fc05
00000000-0000-0000-0000-000000000000	439	gg7jx3em54kj	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-04 03:10:05.555085+00	2025-09-04 03:10:05.555085+00	2zjxp46borbn	e3dd638f-dd2c-483c-8b9e-ff2bd331fc05
00000000-0000-0000-0000-000000000000	440	yxprhudhtby5	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-04 03:16:14.565552+00	2025-09-04 03:16:14.565552+00	\N	4bbd7775-d0d7-481a-bf6e-12ae59b6ee93
00000000-0000-0000-0000-000000000000	441	kjry4izfm3xx	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-04 03:26:35.857892+00	2025-09-04 03:26:35.857892+00	\N	fd23a616-ec28-4cd8-a631-f5d633a0003a
00000000-0000-0000-0000-000000000000	442	zvxkusj3px4a	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-04 03:28:55.550366+00	2025-09-04 03:28:55.550366+00	\N	ce457df0-bfc4-4d66-86eb-3af1def5e9fb
00000000-0000-0000-0000-000000000000	443	5cpewafzqsfg	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-04 03:30:53.751981+00	2025-09-04 03:30:53.751981+00	\N	fd591671-c3b2-44c0-b7b6-170580b690a6
00000000-0000-0000-0000-000000000000	444	2ps4rp62qyke	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-04 03:33:00.086838+00	2025-09-04 04:32:50.845894+00	\N	9d65e46e-1d59-4ffd-a0c2-e3d91d8a5458
00000000-0000-0000-0000-000000000000	445	vhq22bmqnfdr	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-04 04:32:50.858344+00	2025-09-04 04:32:50.989597+00	2ps4rp62qyke	9d65e46e-1d59-4ffd-a0c2-e3d91d8a5458
00000000-0000-0000-0000-000000000000	446	gob2xqhfaxpi	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-04 04:32:50.989921+00	2025-09-04 04:42:44.123262+00	vhq22bmqnfdr	9d65e46e-1d59-4ffd-a0c2-e3d91d8a5458
00000000-0000-0000-0000-000000000000	447	iequtzj2quf7	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-04 04:42:44.127626+00	2025-09-04 04:42:48.096284+00	gob2xqhfaxpi	9d65e46e-1d59-4ffd-a0c2-e3d91d8a5458
00000000-0000-0000-0000-000000000000	448	fdcjzgbrshem	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-04 04:42:48.09728+00	2025-09-04 04:42:48.226563+00	iequtzj2quf7	9d65e46e-1d59-4ffd-a0c2-e3d91d8a5458
00000000-0000-0000-0000-000000000000	449	bjikrvtqryrc	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-04 04:42:48.226918+00	2025-09-04 04:42:48.296183+00	fdcjzgbrshem	9d65e46e-1d59-4ffd-a0c2-e3d91d8a5458
00000000-0000-0000-0000-000000000000	450	t2bhsrbqc2cd	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-04 04:42:48.296612+00	2025-09-04 04:42:48.296612+00	bjikrvtqryrc	9d65e46e-1d59-4ffd-a0c2-e3d91d8a5458
00000000-0000-0000-0000-000000000000	451	xcbepockj5n2	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-04 04:43:28.434179+00	2025-09-04 04:43:28.434179+00	\N	65fc0d10-851d-4b88-8e65-882499cf7bb6
00000000-0000-0000-0000-000000000000	452	73suedjucib7	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-04 06:52:45.998358+00	2025-09-04 06:52:45.998358+00	\N	b789fcba-eb67-4ddd-9fea-cbcafa4a2fc1
00000000-0000-0000-0000-000000000000	453	bzalpx5s6uxr	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-04 07:47:19.600093+00	2025-09-04 07:47:19.600093+00	\N	fc372ee1-b75f-4e37-a6e1-232840d27149
00000000-0000-0000-0000-000000000000	454	vi5hwxfpxddy	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-05 00:00:28.751314+00	2025-09-05 01:00:19.609107+00	\N	6419843a-fc06-40cd-98ad-391e91a8137d
00000000-0000-0000-0000-000000000000	455	3jlyw445w4ji	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-05 01:00:19.625258+00	2025-09-05 01:00:19.762892+00	vi5hwxfpxddy	6419843a-fc06-40cd-98ad-391e91a8137d
00000000-0000-0000-0000-000000000000	456	jukyl43uoqvu	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-05 01:00:19.763273+00	2025-09-05 01:00:19.763273+00	3jlyw445w4ji	6419843a-fc06-40cd-98ad-391e91a8137d
00000000-0000-0000-0000-000000000000	457	mkrmf3cgmkly	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-05 01:16:22.7437+00	2025-09-05 01:16:22.7437+00	\N	bab38d1e-4e2b-43bb-81cd-8abaccaec8da
00000000-0000-0000-0000-000000000000	458	bszsdixbmq2r	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-05 05:26:17.183706+00	2025-09-05 06:26:07.982962+00	\N	91d8b177-bae2-4841-b0ca-0c33fe976a1c
00000000-0000-0000-0000-000000000000	459	qctlkhmetpv5	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-05 06:26:07.999285+00	2025-09-05 06:26:08.149115+00	bszsdixbmq2r	91d8b177-bae2-4841-b0ca-0c33fe976a1c
00000000-0000-0000-0000-000000000000	460	rws5epql3zek	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-05 06:26:08.149445+00	2025-09-05 06:26:08.149445+00	qctlkhmetpv5	91d8b177-bae2-4841-b0ca-0c33fe976a1c
00000000-0000-0000-0000-000000000000	462	uogjmithfa6x	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 06:51:29.120618+00	2025-09-12 06:51:43.994855+00	\N	21afe93a-435c-42df-97fa-67ea6be55f69
00000000-0000-0000-0000-000000000000	463	vm5nhnzfwaur	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 06:51:43.998625+00	2025-09-12 06:51:44.256099+00	uogjmithfa6x	21afe93a-435c-42df-97fa-67ea6be55f69
00000000-0000-0000-0000-000000000000	464	bwwhssfipk6q	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 06:51:44.257068+00	2025-09-12 06:51:50.784224+00	vm5nhnzfwaur	21afe93a-435c-42df-97fa-67ea6be55f69
00000000-0000-0000-0000-000000000000	465	ocuibdbq7irh	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 06:51:50.78528+00	2025-09-12 06:51:50.897449+00	bwwhssfipk6q	21afe93a-435c-42df-97fa-67ea6be55f69
00000000-0000-0000-0000-000000000000	466	ces7n34sxml6	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 06:51:50.897811+00	2025-09-12 07:21:03.749072+00	ocuibdbq7irh	21afe93a-435c-42df-97fa-67ea6be55f69
00000000-0000-0000-0000-000000000000	467	bzaejb344kg2	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 07:21:03.769803+00	2025-09-12 07:21:03.925808+00	ces7n34sxml6	21afe93a-435c-42df-97fa-67ea6be55f69
00000000-0000-0000-0000-000000000000	468	f2aocrpw2y4l	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 07:21:03.926808+00	2025-09-12 07:21:35.777534+00	bzaejb344kg2	21afe93a-435c-42df-97fa-67ea6be55f69
00000000-0000-0000-0000-000000000000	469	bjdrfppzvlua	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 07:21:35.777953+00	2025-09-12 07:21:35.850043+00	f2aocrpw2y4l	21afe93a-435c-42df-97fa-67ea6be55f69
00000000-0000-0000-0000-000000000000	470	kgydm7gkfivp	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 07:21:35.851479+00	2025-09-12 07:22:23.213223+00	bjdrfppzvlua	21afe93a-435c-42df-97fa-67ea6be55f69
00000000-0000-0000-0000-000000000000	471	q65xktk7726r	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 07:22:23.21358+00	2025-09-12 07:22:23.292749+00	kgydm7gkfivp	21afe93a-435c-42df-97fa-67ea6be55f69
00000000-0000-0000-0000-000000000000	472	any4whrkzn52	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 07:22:23.293171+00	2025-09-12 08:11:16.971639+00	q65xktk7726r	21afe93a-435c-42df-97fa-67ea6be55f69
00000000-0000-0000-0000-000000000000	474	hxqnd35g2m5x	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 08:16:15.017637+00	2025-09-12 08:16:15.017637+00	\N	a220fcaf-6c3d-43f1-87b8-6a8197667c54
00000000-0000-0000-0000-000000000000	475	6cpalsf5zqjs	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 08:17:48.445137+00	2025-09-12 08:17:48.445137+00	\N	c553d554-172d-418c-ace5-acf8953b5867
00000000-0000-0000-0000-000000000000	476	c2xe4zj3jxdq	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 08:22:28.952009+00	2025-09-12 08:22:28.952009+00	\N	964677c1-610a-429a-a6a9-56980139259a
00000000-0000-0000-0000-000000000000	473	7l2v2ldxeypx	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 08:12:53.791421+00	2025-09-12 11:21:23.497419+00	\N	a5bdff3a-8034-4930-93d0-83ca2b69f9a0
00000000-0000-0000-0000-000000000000	461	svag4qeim7lc	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-05 06:41:54.123108+00	2025-09-14 18:36:28.258951+00	\N	f716839c-35ab-48f0-92cb-6e0db330368a
00000000-0000-0000-0000-000000000000	477	lhqi3c772kqx	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 08:31:59.42275+00	2025-09-12 09:31:51.403075+00	\N	2ee64cf8-a1a6-4053-a778-6ed2cc97aa1f
00000000-0000-0000-0000-000000000000	478	yz3xtxbbe7bj	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 09:31:51.421327+00	2025-09-12 09:31:51.570176+00	lhqi3c772kqx	2ee64cf8-a1a6-4053-a778-6ed2cc97aa1f
00000000-0000-0000-0000-000000000000	479	n3g6yddgg5ej	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 09:31:51.570547+00	2025-09-12 09:31:51.570547+00	yz3xtxbbe7bj	2ee64cf8-a1a6-4053-a778-6ed2cc97aa1f
00000000-0000-0000-0000-000000000000	480	e6x7f632nljv	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 10:29:04.819499+00	2025-09-12 10:29:04.819499+00	\N	47387d9c-a03b-497c-92ca-c7e33d1436c3
00000000-0000-0000-0000-000000000000	481	h7y5uiacfqsa	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 10:34:54.743257+00	2025-09-12 10:34:54.743257+00	\N	a410fe17-ff1b-41bf-be10-2e2bcdacfdf7
00000000-0000-0000-0000-000000000000	482	thwmnp6pkgkq	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 10:35:01.226655+00	2025-09-12 10:35:01.226655+00	\N	cd2b73d6-4d7a-42fe-884b-0d3161edd8a3
00000000-0000-0000-0000-000000000000	483	wjnxcrlwn4ze	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 10:39:15.586269+00	2025-09-12 10:39:15.586269+00	\N	e69ddca4-bbed-433b-984e-3ea987690e4a
00000000-0000-0000-0000-000000000000	484	6tmq7dhi6ghn	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 10:43:58.845592+00	2025-09-12 10:43:58.845592+00	\N	5c08900e-5e31-4d22-b308-453c37e8ea89
00000000-0000-0000-0000-000000000000	485	e2ezgwo3aiko	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 10:47:16.590474+00	2025-09-12 10:47:16.590474+00	\N	a4612ea7-c20f-4208-887a-ddd1af8d5dc1
00000000-0000-0000-0000-000000000000	486	eb2rljjq4w3f	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 10:53:35.395626+00	2025-09-12 10:53:35.395626+00	\N	927b66b3-5c04-40b7-948c-eba020033fc1
00000000-0000-0000-0000-000000000000	487	qzossybcaz4h	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 10:56:10.199875+00	2025-09-12 10:56:10.199875+00	\N	75429ef2-9e61-4726-91a3-f82dcf3e45d4
00000000-0000-0000-0000-000000000000	488	jifj6yipjwi6	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 11:02:19.976623+00	2025-09-12 11:02:19.976623+00	\N	f3037ca4-77c0-4df2-bf32-3b854d39989f
00000000-0000-0000-0000-000000000000	489	z3kdkiii7e2m	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 11:03:06.860523+00	2025-09-12 11:03:06.860523+00	\N	accfe3d0-8ee6-47c3-96ac-5847f4acff13
00000000-0000-0000-0000-000000000000	490	xqgsqkhwpvca	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 11:05:53.229645+00	2025-09-12 11:05:53.229645+00	\N	f86a41b9-2a45-41a5-914a-ae44c0604574
00000000-0000-0000-0000-000000000000	491	b2dv2y3pfb2n	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 11:08:15.27804+00	2025-09-12 11:08:15.27804+00	\N	8b7fb74f-bb08-4844-b546-a039820809c6
00000000-0000-0000-0000-000000000000	492	d55mqhemrgpk	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 11:21:23.504511+00	2025-09-12 11:21:23.504511+00	7l2v2ldxeypx	a5bdff3a-8034-4930-93d0-83ca2b69f9a0
00000000-0000-0000-0000-000000000000	494	5mlcgqdltvcq	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 11:47:42.205619+00	2025-09-12 11:47:42.205619+00	\N	a4990197-3b49-4588-b5b6-8b773b2b1eeb
00000000-0000-0000-0000-000000000000	495	zigqsq75p4eo	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 11:51:04.061613+00	2025-09-12 11:51:04.061613+00	\N	09ee0a1b-d5d7-4142-9b24-488af18563a4
00000000-0000-0000-0000-000000000000	493	l5oijob7nq3y	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 11:21:31.862214+00	2025-09-12 12:05:53.247907+00	\N	4e2712c9-7762-4cab-87e4-dd95c76b0a9a
00000000-0000-0000-0000-000000000000	496	23er7ilmsfeu	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 12:05:53.26546+00	2025-09-12 12:05:54.098255+00	l5oijob7nq3y	4e2712c9-7762-4cab-87e4-dd95c76b0a9a
00000000-0000-0000-0000-000000000000	497	asohvfvcuni2	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 12:05:54.099254+00	2025-09-12 12:10:23.797414+00	23er7ilmsfeu	4e2712c9-7762-4cab-87e4-dd95c76b0a9a
00000000-0000-0000-0000-000000000000	498	n7szzahcnixk	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 12:10:23.799453+00	2025-09-12 12:10:27.82199+00	asohvfvcuni2	4e2712c9-7762-4cab-87e4-dd95c76b0a9a
00000000-0000-0000-0000-000000000000	499	jyhhkat4o7o5	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 12:10:27.82382+00	2025-09-12 12:10:32.432213+00	n7szzahcnixk	4e2712c9-7762-4cab-87e4-dd95c76b0a9a
00000000-0000-0000-0000-000000000000	500	oxi7p2bib7wq	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-12 12:10:32.432976+00	2025-09-12 12:10:49.15378+00	jyhhkat4o7o5	4e2712c9-7762-4cab-87e4-dd95c76b0a9a
00000000-0000-0000-0000-000000000000	501	fsurzn2muoev	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 12:10:49.154142+00	2025-09-12 12:10:49.154142+00	oxi7p2bib7wq	4e2712c9-7762-4cab-87e4-dd95c76b0a9a
00000000-0000-0000-0000-000000000000	502	nrqbixmzx32m	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 18:13:14.935629+00	2025-09-12 18:13:14.935629+00	\N	76140067-cb3f-43a6-9838-1229ba6a69ce
00000000-0000-0000-0000-000000000000	503	7jvs5zvngixu	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-12 19:01:28.982576+00	2025-09-12 19:01:28.982576+00	\N	e2d152b3-e4b6-4cc6-8c35-ade398896c11
00000000-0000-0000-0000-000000000000	504	otvgpryauxku	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-13 02:59:17.157656+00	2025-09-13 03:49:21.962011+00	\N	dc75c993-d127-4e85-9581-d33f71263cea
00000000-0000-0000-0000-000000000000	505	wfjmbuhqcjco	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-13 03:49:21.981009+00	2025-09-13 03:49:21.981009+00	otvgpryauxku	dc75c993-d127-4e85-9581-d33f71263cea
00000000-0000-0000-0000-000000000000	507	7klfl7gbunur	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-13 05:15:41.239342+00	2025-09-13 05:15:41.239342+00	\N	314d3388-00c5-48c5-babe-8c70fb84535a
00000000-0000-0000-0000-000000000000	506	a7krtjnoszdb	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-13 05:15:02.215001+00	2025-09-13 06:19:37.286347+00	\N	79e0fa6c-dbcd-4c7f-aed8-d7abd74c935b
00000000-0000-0000-0000-000000000000	508	guwetgex2ifo	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-13 06:19:37.308342+00	2025-09-13 06:19:37.308342+00	a7krtjnoszdb	79e0fa6c-dbcd-4c7f-aed8-d7abd74c935b
00000000-0000-0000-0000-000000000000	509	3gfxslnmgur5	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-13 08:33:49.558564+00	2025-09-13 08:33:49.558564+00	\N	5daffb69-09f0-4706-a823-e4ee235600b9
00000000-0000-0000-0000-000000000000	510	3amynpwokcln	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-13 21:26:35.0385+00	2025-09-13 22:26:25.918984+00	\N	104e3d9e-15e9-4f01-b2a5-1ad9b02a6bd5
00000000-0000-0000-0000-000000000000	511	qrcjfi7utkj6	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-13 22:26:25.936405+00	2025-09-13 22:26:26.066572+00	3amynpwokcln	104e3d9e-15e9-4f01-b2a5-1ad9b02a6bd5
00000000-0000-0000-0000-000000000000	512	clocpn6xwb4o	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-13 22:26:26.066924+00	2025-09-13 22:26:26.066924+00	qrcjfi7utkj6	104e3d9e-15e9-4f01-b2a5-1ad9b02a6bd5
00000000-0000-0000-0000-000000000000	513	zi6gsbkase4i	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-14 06:06:15.668732+00	2025-09-14 06:06:15.668732+00	\N	5cdc7063-dfdf-4f8a-ac00-118100fa5ad1
00000000-0000-0000-0000-000000000000	514	rsqngkjhwayb	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-14 06:47:42.220184+00	2025-09-14 06:47:42.220184+00	\N	8434698b-7bf5-4401-a6db-2968f956f61c
00000000-0000-0000-0000-000000000000	515	px2h2h33w4mb	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 07:11:23.28809+00	2025-09-14 08:06:33.934256+00	\N	ac34c1a7-8bff-4836-b952-48b0cdade96e
00000000-0000-0000-0000-000000000000	516	rr46fjfa4pjt	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 08:06:33.947693+00	2025-09-14 08:06:34.763356+00	px2h2h33w4mb	ac34c1a7-8bff-4836-b952-48b0cdade96e
00000000-0000-0000-0000-000000000000	517	5wfdsm7aveqm	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 08:06:34.764165+00	2025-09-14 08:06:36.626096+00	rr46fjfa4pjt	ac34c1a7-8bff-4836-b952-48b0cdade96e
00000000-0000-0000-0000-000000000000	518	724mri2quazw	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-14 08:06:36.626463+00	2025-09-14 08:06:36.626463+00	5wfdsm7aveqm	ac34c1a7-8bff-4836-b952-48b0cdade96e
00000000-0000-0000-0000-000000000000	519	nwdgw7ftem2z	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 08:24:25.754584+00	2025-09-14 09:01:38.318847+00	\N	3d3d0f8b-eef6-469c-b333-722c32b3aa9a
00000000-0000-0000-0000-000000000000	520	3pppg2tcvlqx	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 09:01:38.340376+00	2025-09-14 09:01:56.346185+00	nwdgw7ftem2z	3d3d0f8b-eef6-469c-b333-722c32b3aa9a
00000000-0000-0000-0000-000000000000	521	ji25mhkyny7f	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 09:01:56.34652+00	2025-09-14 09:02:25.176252+00	3pppg2tcvlqx	3d3d0f8b-eef6-469c-b333-722c32b3aa9a
00000000-0000-0000-0000-000000000000	522	nm2d2iny24as	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-14 09:02:25.176939+00	2025-09-14 09:02:25.176939+00	ji25mhkyny7f	3d3d0f8b-eef6-469c-b333-722c32b3aa9a
00000000-0000-0000-0000-000000000000	523	i7froxjwuhpt	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 09:31:44.617537+00	2025-09-14 10:31:45.156744+00	\N	f17da7ad-4ba1-471d-a3d0-7225537f8aa5
00000000-0000-0000-0000-000000000000	524	eumby5ps2otp	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 10:31:45.18708+00	2025-09-14 11:31:45.232107+00	i7froxjwuhpt	f17da7ad-4ba1-471d-a3d0-7225537f8aa5
00000000-0000-0000-0000-000000000000	525	dmuo42mbz62z	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 11:31:45.256977+00	2025-09-14 12:31:45.392757+00	eumby5ps2otp	f17da7ad-4ba1-471d-a3d0-7225537f8aa5
00000000-0000-0000-0000-000000000000	526	42uthb44ovqo	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 12:31:45.41287+00	2025-09-14 13:31:45.524684+00	dmuo42mbz62z	f17da7ad-4ba1-471d-a3d0-7225537f8aa5
00000000-0000-0000-0000-000000000000	527	kjgvwuqar7fb	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 13:31:45.546545+00	2025-09-14 14:31:45.742754+00	42uthb44ovqo	f17da7ad-4ba1-471d-a3d0-7225537f8aa5
00000000-0000-0000-0000-000000000000	528	ktvdipv4k7ch	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 14:31:45.767951+00	2025-09-14 15:31:45.886512+00	kjgvwuqar7fb	f17da7ad-4ba1-471d-a3d0-7225537f8aa5
00000000-0000-0000-0000-000000000000	576	xcmh2d5phfz5	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-15 06:23:33.064172+00	2025-09-15 07:51:07.661579+00	\N	f6553552-7c87-4bcb-a859-3a48870d116c
00000000-0000-0000-0000-000000000000	529	eekkgao5q6fm	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 15:31:45.914154+00	2025-09-14 16:31:46.06308+00	ktvdipv4k7ch	f17da7ad-4ba1-471d-a3d0-7225537f8aa5
00000000-0000-0000-0000-000000000000	530	6jbxcw6suig5	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 16:31:46.085074+00	2025-09-14 17:31:51.139079+00	eekkgao5q6fm	f17da7ad-4ba1-471d-a3d0-7225537f8aa5
00000000-0000-0000-0000-000000000000	585	kypvnmsnzx7t	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-15 07:51:24.585674+00	2025-09-15 23:19:00.948792+00	\N	76367272-6b3c-4059-8faf-3ae7f807ecf9
00000000-0000-0000-0000-000000000000	531	pxeoex7ot2sm	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 17:31:51.163665+00	2025-09-14 18:31:51.337839+00	6jbxcw6suig5	f17da7ad-4ba1-471d-a3d0-7225537f8aa5
00000000-0000-0000-0000-000000000000	533	l3cnk45xl2t5	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-14 18:36:28.270628+00	2025-09-14 18:36:28.270628+00	svag4qeim7lc	f716839c-35ab-48f0-92cb-6e0db330368a
00000000-0000-0000-0000-000000000000	534	aavrgildmmgl	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-14 18:36:57.534832+00	2025-09-14 18:43:14.863536+00	\N	5f3dcba5-bc20-49f8-a141-b381f9feca61
00000000-0000-0000-0000-000000000000	535	i3yse2hd4mv5	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-14 18:43:14.867752+00	2025-09-14 18:43:14.867752+00	aavrgildmmgl	5f3dcba5-bc20-49f8-a141-b381f9feca61
00000000-0000-0000-0000-000000000000	536	ufsb2otunpht	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-14 19:15:38.858415+00	2025-09-14 19:15:53.476257+00	\N	83a8ae57-6717-4831-857e-6a3ea8165224
00000000-0000-0000-0000-000000000000	538	hx7gitsafmoy	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-14 19:17:08.167802+00	2025-09-14 19:17:08.167802+00	\N	230eb5c4-a702-4a81-a32f-31bc53ac82a6
00000000-0000-0000-0000-000000000000	532	fermvppp2re4	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 18:31:51.361875+00	2025-09-14 19:31:51.409008+00	pxeoex7ot2sm	f17da7ad-4ba1-471d-a3d0-7225537f8aa5
00000000-0000-0000-0000-000000000000	540	chio6aozqxwx	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-14 19:33:03.901554+00	2025-09-14 19:33:03.901554+00	\N	051f8903-3e13-4345-82d1-e123318dbc20
00000000-0000-0000-0000-000000000000	537	k2grfwogpvqq	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-14 19:15:53.478058+00	2025-09-14 19:54:02.346742+00	ufsb2otunpht	83a8ae57-6717-4831-857e-6a3ea8165224
00000000-0000-0000-0000-000000000000	541	tywfq3ct6lxp	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-14 19:54:02.351698+00	2025-09-14 19:54:02.351698+00	k2grfwogpvqq	83a8ae57-6717-4831-857e-6a3ea8165224
00000000-0000-0000-0000-000000000000	542	be4mdc4pqlnk	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-14 19:54:58.66801+00	2025-09-14 19:54:58.66801+00	\N	7f0c84ac-90b1-4149-ab8f-29fe67198d16
00000000-0000-0000-0000-000000000000	539	fdqswwq2jmdk	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 19:31:51.430391+00	2025-09-14 22:00:06.147073+00	fermvppp2re4	f17da7ad-4ba1-471d-a3d0-7225537f8aa5
00000000-0000-0000-0000-000000000000	543	76ctomdcec2t	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-14 22:00:06.168747+00	2025-09-14 22:00:06.168747+00	fdqswwq2jmdk	f17da7ad-4ba1-471d-a3d0-7225537f8aa5
00000000-0000-0000-0000-000000000000	544	rzxj3mjrjht3	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-14 22:08:05.107068+00	2025-09-14 22:08:05.107068+00	\N	981dcbe1-f199-4e65-abf9-c53beaf6637d
00000000-0000-0000-0000-000000000000	545	sesazl6nk2gk	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:11:26.697348+00	2025-09-14 22:27:17.347625+00	\N	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	546	3zrcllqp6ku3	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:17.35358+00	2025-09-14 22:27:19.193128+00	sesazl6nk2gk	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	547	7rgwnf47tfuu	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:19.194622+00	2025-09-14 22:27:20.37429+00	3zrcllqp6ku3	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	548	q5bkq6mt5rov	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:20.374641+00	2025-09-14 22:27:21.577315+00	7rgwnf47tfuu	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	549	qruorsgyhjtl	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:21.577901+00	2025-09-14 22:27:26.747967+00	q5bkq6mt5rov	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	550	glygkj7otlkd	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:26.748313+00	2025-09-14 22:27:27.366275+00	qruorsgyhjtl	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	551	fatji5wxphip	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:27.366767+00	2025-09-14 22:27:28.355589+00	glygkj7otlkd	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	552	pim66ycjsk45	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:28.35596+00	2025-09-14 22:27:29.483752+00	fatji5wxphip	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	553	cjtzopir6ans	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:29.484916+00	2025-09-14 22:27:32.734673+00	pim66ycjsk45	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	554	3ok4p6n4ww3g	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:32.735038+00	2025-09-14 22:27:34.705462+00	cjtzopir6ans	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	555	djszb5vhlvz6	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:34.705835+00	2025-09-14 22:27:36.662074+00	3ok4p6n4ww3g	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	556	ntco5xjupbcg	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:36.66243+00	2025-09-14 22:27:38.314574+00	djszb5vhlvz6	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	557	xuhnlcf5y6w6	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:38.314955+00	2025-09-14 22:27:38.799005+00	ntco5xjupbcg	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	558	fruxypfysycp	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:38.7993+00	2025-09-14 22:27:40.370624+00	xuhnlcf5y6w6	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	559	e36mispiewv2	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:40.370899+00	2025-09-14 22:27:40.859193+00	fruxypfysycp	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	560	4qghjvlayfxe	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:40.859623+00	2025-09-14 22:27:41.463764+00	e36mispiewv2	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	561	k6skkea5jikw	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:41.464079+00	2025-09-14 22:27:43.732627+00	4qghjvlayfxe	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	562	v7rxggpv73zh	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:43.732922+00	2025-09-14 22:27:44.435611+00	k6skkea5jikw	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	563	rayzgjqjyqxc	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:44.43594+00	2025-09-14 22:27:46.148374+00	v7rxggpv73zh	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	564	y5wx5gsn4jwx	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:46.148797+00	2025-09-14 22:27:47.188092+00	rayzgjqjyqxc	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	565	sudaoyzljc7l	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 22:27:47.188386+00	2025-09-14 23:27:51.129018+00	y5wx5gsn4jwx	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	566	7gjqcjolt3tg	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-14 23:27:51.155304+00	2025-09-15 00:24:54.721004+00	sudaoyzljc7l	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	568	acwdb3rml5fb	78467702-b492-451b-a9f1-2059dbdd433e	f	2025-09-15 02:05:02.266066+00	2025-09-15 02:05:02.266066+00	\N	b030bc4b-89dd-429d-8f1a-de455c3015eb
00000000-0000-0000-0000-000000000000	569	otthbfpendxl	78467702-b492-451b-a9f1-2059dbdd433e	f	2025-09-15 02:05:12.403652+00	2025-09-15 02:05:12.403652+00	\N	fb430cc6-333d-48ad-8632-86ef5ca510c8
00000000-0000-0000-0000-000000000000	570	mkb3tfa2h34k	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 02:05:16.208757+00	2025-09-15 03:05:06.584358+00	\N	e986b82b-50ec-4d86-839a-c345d3179c07
00000000-0000-0000-0000-000000000000	571	3fs44q5zwxj7	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 03:05:06.608668+00	2025-09-15 03:05:06.751976+00	mkb3tfa2h34k	e986b82b-50ec-4d86-839a-c345d3179c07
00000000-0000-0000-0000-000000000000	572	4evdxhdr2lkv	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 03:05:06.753465+00	2025-09-15 03:07:06.800138+00	3fs44q5zwxj7	e986b82b-50ec-4d86-839a-c345d3179c07
00000000-0000-0000-0000-000000000000	567	tkid34zwj4ny	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-15 00:24:54.734053+00	2025-09-15 04:47:14.899026+00	7gjqcjolt3tg	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	573	5mvmp6ham3aq	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-15 04:47:14.925401+00	2025-09-15 05:59:40.387292+00	tkid34zwj4ny	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	574	ak5vcrxhabaj	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-15 05:59:40.397663+00	2025-09-15 06:03:27.01319+00	5mvmp6ham3aq	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	575	ojsti4a4ijos	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-15 06:03:27.028649+00	2025-09-15 06:30:51.312044+00	ak5vcrxhabaj	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	577	uaqmglhwmx64	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-15 06:30:51.316462+00	2025-09-15 06:39:08.707821+00	ojsti4a4ijos	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	578	jyoa7wfv6h2c	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-15 06:39:08.71158+00	2025-09-15 06:40:27.72126+00	uaqmglhwmx64	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	582	tae63ide7obk	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-15 07:31:31.760161+00	2025-09-15 07:32:26.74288+00	5co6pdanoqtb	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	580	dbozjfucijbg	1dc56294-d8f6-4fc9-984a-6d176d125856	f	2025-09-15 07:05:54.808396+00	2025-09-15 07:05:54.808396+00	\N	0eca28be-4686-4dd3-887d-49f56060f062
00000000-0000-0000-0000-000000000000	579	t4nviu3ec2s6	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-15 06:40:27.737896+00	2025-09-15 07:31:09.310255+00	jyoa7wfv6h2c	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	586	ioxlfcyitb3a	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-15 08:09:29.643823+00	2025-09-15 08:09:29.643823+00	\N	b645d2ad-52f2-4f09-859b-7afa13adc3a9
00000000-0000-0000-0000-000000000000	581	5co6pdanoqtb	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-15 07:31:09.329721+00	2025-09-15 07:31:31.759756+00	t4nviu3ec2s6	905b2c4b-69fb-4d42-a89c-62e76b6e044b
00000000-0000-0000-0000-000000000000	733	suk6tiv4a2vy	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 16:40:52.725068+00	2025-09-17 16:40:52.93713+00	qj7ze5ztoqep	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	588	cniyiz44cou3	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-15 08:23:40.144955+00	2025-09-15 08:23:40.144955+00	\N	ce51c5d5-8061-4ef9-a7dd-9725b3bc4477
00000000-0000-0000-0000-000000000000	590	eohmrzegdbps	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-15 08:36:47.293951+00	2025-09-15 10:38:28.132754+00	vtmrcnlx3tdn	60e6db0b-9148-4e3d-8fc6-6bcfc79505f6
00000000-0000-0000-0000-000000000000	592	ee4u6qq5jbza	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-15 10:52:13.59346+00	2025-09-15 10:52:13.59346+00	\N	3a6b85e2-1903-43ea-a0eb-fdf04dd3e96c
00000000-0000-0000-0000-000000000000	593	k4r5tnhfwk2l	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-15 11:12:06.738723+00	2025-09-15 11:12:06.738723+00	\N	f661643e-a468-42ce-b654-fc1a2e8d098c
00000000-0000-0000-0000-000000000000	594	kq63jdnnmuss	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-15 11:17:26.471504+00	2025-09-15 11:17:26.471504+00	\N	c0c21c5c-3898-46d3-8369-084efe12f2cc
00000000-0000-0000-0000-000000000000	595	uocfd2pvynqb	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 18:05:47.729749+00	2025-09-15 19:05:37.542234+00	\N	ba43f993-07b3-4b9d-817b-d1105c31ed8a
00000000-0000-0000-0000-000000000000	596	hl2yy2fsvwpy	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 19:05:37.56288+00	2025-09-15 19:05:37.849119+00	uocfd2pvynqb	ba43f993-07b3-4b9d-817b-d1105c31ed8a
00000000-0000-0000-0000-000000000000	597	lvgftwvkdhlr	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 19:05:37.850691+00	2025-09-15 20:05:27.352358+00	hl2yy2fsvwpy	ba43f993-07b3-4b9d-817b-d1105c31ed8a
00000000-0000-0000-0000-000000000000	599	lxdortwnrpey	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 20:05:27.374206+00	2025-09-15 20:05:27.507995+00	lvgftwvkdhlr	ba43f993-07b3-4b9d-817b-d1105c31ed8a
00000000-0000-0000-0000-000000000000	600	l6op3z2k6nxq	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 20:05:27.509654+00	2025-09-15 21:08:47.068142+00	lxdortwnrpey	ba43f993-07b3-4b9d-817b-d1105c31ed8a
00000000-0000-0000-0000-000000000000	601	qhxswspbpq6c	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 21:09:40.492901+00	2025-09-15 23:15:38.796942+00	\N	f352a10d-320a-47c1-a8b4-98d34b9d5940
00000000-0000-0000-0000-000000000000	602	7ekc7veiin66	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 23:15:38.807868+00	2025-09-15 23:15:39.000943+00	qhxswspbpq6c	f352a10d-320a-47c1-a8b4-98d34b9d5940
00000000-0000-0000-0000-000000000000	584	uuyqhvkrbi2p	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-15 07:51:07.669019+00	2025-09-15 23:18:52.91667+00	xcmh2d5phfz5	f6553552-7c87-4bcb-a859-3a48870d116c
00000000-0000-0000-0000-000000000000	605	tl25ho5jega3	1dc56294-d8f6-4fc9-984a-6d176d125856	f	2025-09-15 23:19:00.949941+00	2025-09-15 23:19:00.949941+00	kypvnmsnzx7t	76367272-6b3c-4059-8faf-3ae7f807ecf9
00000000-0000-0000-0000-000000000000	603	idqa6okcoj2e	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 23:15:39.001307+00	2025-09-15 23:43:09.50532+00	7ekc7veiin66	f352a10d-320a-47c1-a8b4-98d34b9d5940
00000000-0000-0000-0000-000000000000	607	m6x4huepgeme	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 23:43:39.357366+00	2025-09-15 23:43:50.691581+00	\N	fb3aa1ed-2104-49d0-8d5c-ffa6f7c2796a
00000000-0000-0000-0000-000000000000	608	nqutnnql7sb5	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 23:43:50.692203+00	2025-09-15 23:43:58.895752+00	m6x4huepgeme	fb3aa1ed-2104-49d0-8d5c-ffa6f7c2796a
00000000-0000-0000-0000-000000000000	609	sxjlw2uoaois	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 23:43:58.89612+00	2025-09-15 23:46:29.573701+00	nqutnnql7sb5	fb3aa1ed-2104-49d0-8d5c-ffa6f7c2796a
00000000-0000-0000-0000-000000000000	610	swy3awounbgs	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 23:46:29.575668+00	2025-09-15 23:46:33.037313+00	sxjlw2uoaois	fb3aa1ed-2104-49d0-8d5c-ffa6f7c2796a
00000000-0000-0000-0000-000000000000	611	d6megh7ljvr7	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 23:46:33.03766+00	2025-09-15 23:46:34.66751+00	swy3awounbgs	fb3aa1ed-2104-49d0-8d5c-ffa6f7c2796a
00000000-0000-0000-0000-000000000000	612	fmym3onwagat	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 23:46:34.66808+00	2025-09-15 23:58:02.848091+00	d6megh7ljvr7	fb3aa1ed-2104-49d0-8d5c-ffa6f7c2796a
00000000-0000-0000-0000-000000000000	613	pu3fynhmzyhr	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 23:58:02.862145+00	2025-09-15 23:58:03.739926+00	fmym3onwagat	fb3aa1ed-2104-49d0-8d5c-ffa6f7c2796a
00000000-0000-0000-0000-000000000000	614	ukp64iu3igxv	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 23:58:03.740491+00	2025-09-15 23:58:06.647064+00	pu3fynhmzyhr	fb3aa1ed-2104-49d0-8d5c-ffa6f7c2796a
00000000-0000-0000-0000-000000000000	606	6pfd5djh476q	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-15 23:19:23.363399+00	2025-09-16 00:19:13.935313+00	\N	ecbccb35-5476-4d47-8146-3e7859417cd4
00000000-0000-0000-0000-000000000000	616	fijp4amfg4r5	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-16 00:19:13.947898+00	2025-09-16 00:19:14.061617+00	6pfd5djh476q	ecbccb35-5476-4d47-8146-3e7859417cd4
00000000-0000-0000-0000-000000000000	618	kzeh5nuzabve	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-16 00:34:48.614718+00	2025-09-16 00:34:48.614718+00	\N	af1a1548-ef1a-4d2e-9797-febf86aa21aa
00000000-0000-0000-0000-000000000000	619	2xr63o6v534m	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-16 00:50:22.415758+00	2025-09-16 00:50:22.415758+00	\N	4267d7c0-091c-467c-b153-6339c4ec6b93
00000000-0000-0000-0000-000000000000	615	ebwsbuhfntsb	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-15 23:58:06.647767+00	2025-09-16 00:57:56.170812+00	ukp64iu3igxv	fb3aa1ed-2104-49d0-8d5c-ffa6f7c2796a
00000000-0000-0000-0000-000000000000	620	bax35why6bxw	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 00:57:56.186404+00	2025-09-16 00:57:56.318968+00	ebwsbuhfntsb	fb3aa1ed-2104-49d0-8d5c-ffa6f7c2796a
00000000-0000-0000-0000-000000000000	617	453alchazfb5	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-16 00:19:14.063123+00	2025-09-16 01:19:05.773748+00	fijp4amfg4r5	ecbccb35-5476-4d47-8146-3e7859417cd4
00000000-0000-0000-0000-000000000000	622	cu3nldm5tal7	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-16 01:19:05.793998+00	2025-09-16 01:19:05.914736+00	453alchazfb5	ecbccb35-5476-4d47-8146-3e7859417cd4
00000000-0000-0000-0000-000000000000	621	znjm3vabtkif	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 00:57:56.319341+00	2025-09-16 02:02:11.762085+00	bax35why6bxw	fb3aa1ed-2104-49d0-8d5c-ffa6f7c2796a
00000000-0000-0000-0000-000000000000	624	w3cvgxf7vy5z	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 02:02:34.306942+00	2025-09-16 02:10:19.662391+00	\N	de277f17-ceb3-426d-b990-b55199b0b0c6
00000000-0000-0000-0000-000000000000	625	inzxnyipe4lb	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 02:10:19.665652+00	2025-09-16 02:10:33.174652+00	w3cvgxf7vy5z	de277f17-ceb3-426d-b990-b55199b0b0c6
00000000-0000-0000-0000-000000000000	626	ztdnnh4qz6n3	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 02:10:33.17569+00	2025-09-16 02:10:35.229991+00	inzxnyipe4lb	de277f17-ceb3-426d-b990-b55199b0b0c6
00000000-0000-0000-0000-000000000000	627	3uiohdphkryz	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 02:10:35.23034+00	2025-09-16 02:10:38.833735+00	ztdnnh4qz6n3	de277f17-ceb3-426d-b990-b55199b0b0c6
00000000-0000-0000-0000-000000000000	623	ry4nfxilvxfw	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-16 01:19:05.915175+00	2025-09-16 02:18:56.339435+00	cu3nldm5tal7	ecbccb35-5476-4d47-8146-3e7859417cd4
00000000-0000-0000-0000-000000000000	629	pvtmqoa5hsth	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-16 02:18:56.344889+00	2025-09-16 02:18:56.418363+00	ry4nfxilvxfw	ecbccb35-5476-4d47-8146-3e7859417cd4
00000000-0000-0000-0000-000000000000	630	ey6sqwynpf55	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-16 02:18:56.419391+00	2025-09-16 03:18:47.980839+00	pvtmqoa5hsth	ecbccb35-5476-4d47-8146-3e7859417cd4
00000000-0000-0000-0000-000000000000	632	cvivemiskwzs	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-16 03:18:47.99143+00	2025-09-16 03:18:48.097712+00	ey6sqwynpf55	ecbccb35-5476-4d47-8146-3e7859417cd4
00000000-0000-0000-0000-000000000000	604	f7cmjtm4cs4e	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-15 23:18:52.917463+00	2025-09-16 04:00:39.889504+00	uuyqhvkrbi2p	f6553552-7c87-4bcb-a859-3a48870d116c
00000000-0000-0000-0000-000000000000	634	e3rwyelbhbn2	1dc56294-d8f6-4fc9-984a-6d176d125856	f	2025-09-16 04:00:39.900305+00	2025-09-16 04:00:39.900305+00	f7cmjtm4cs4e	f6553552-7c87-4bcb-a859-3a48870d116c
00000000-0000-0000-0000-000000000000	633	v6mkne4atnwv	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-16 03:18:48.098089+00	2025-09-16 04:00:45.447607+00	cvivemiskwzs	ecbccb35-5476-4d47-8146-3e7859417cd4
00000000-0000-0000-0000-000000000000	631	rs3u2aikb6me	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 03:09:55.112686+00	2025-09-16 04:09:45.698807+00	\N	5a07f556-71c5-48b4-9ae0-1882cc9d34db
00000000-0000-0000-0000-000000000000	628	3qrdalwdihu3	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 02:10:38.834367+00	2025-09-16 04:51:36.931364+00	3uiohdphkryz	de277f17-ceb3-426d-b990-b55199b0b0c6
00000000-0000-0000-0000-000000000000	598	hvhdv52epweg	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-15 19:17:07.305149+00	2025-09-17 10:27:55.827748+00	\N	38d3e981-380e-47e6-bd42-8a9e988fe778
00000000-0000-0000-0000-000000000000	636	54maqmgbvx3i	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 04:09:45.71241+00	2025-09-16 04:09:45.814551+00	rs3u2aikb6me	5a07f556-71c5-48b4-9ae0-1882cc9d34db
00000000-0000-0000-0000-000000000000	637	gj7nex5lgr2i	78467702-b492-451b-a9f1-2059dbdd433e	f	2025-09-16 04:09:45.814886+00	2025-09-16 04:09:45.814886+00	54maqmgbvx3i	5a07f556-71c5-48b4-9ae0-1882cc9d34db
00000000-0000-0000-0000-000000000000	638	3tuz5hjpcuyw	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 04:51:36.950099+00	2025-09-16 04:52:44.061128+00	3qrdalwdihu3	de277f17-ceb3-426d-b990-b55199b0b0c6
00000000-0000-0000-0000-000000000000	639	q77blowbu6bc	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 04:52:44.062092+00	2025-09-16 04:52:49.67252+00	3tuz5hjpcuyw	de277f17-ceb3-426d-b990-b55199b0b0c6
00000000-0000-0000-0000-000000000000	635	thvlafhxtn5k	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-16 04:01:07.562686+00	2025-09-16 05:03:45.740869+00	\N	dfd646ea-2159-4796-8833-60f9e2c2d65f
00000000-0000-0000-0000-000000000000	641	w3smzcrkmw2d	1dc56294-d8f6-4fc9-984a-6d176d125856	f	2025-09-16 05:03:45.752984+00	2025-09-16 05:03:45.752984+00	thvlafhxtn5k	dfd646ea-2159-4796-8833-60f9e2c2d65f
00000000-0000-0000-0000-000000000000	640	g2xniy24otvg	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 04:52:49.672865+00	2025-09-16 05:52:39.098591+00	q77blowbu6bc	de277f17-ceb3-426d-b990-b55199b0b0c6
00000000-0000-0000-0000-000000000000	642	eg42pdmywham	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 05:52:39.113911+00	2025-09-16 05:52:39.310099+00	g2xniy24otvg	de277f17-ceb3-426d-b990-b55199b0b0c6
00000000-0000-0000-0000-000000000000	644	m35qq2e6qkop	1dc56294-d8f6-4fc9-984a-6d176d125856	f	2025-09-16 05:58:38.757976+00	2025-09-16 05:58:38.757976+00	\N	b7702bbe-80d8-4ab8-9b8e-36d1df1a9fcf
00000000-0000-0000-0000-000000000000	643	tp47s67obqhw	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 05:52:39.310501+00	2025-09-16 06:11:51.016349+00	eg42pdmywham	de277f17-ceb3-426d-b990-b55199b0b0c6
00000000-0000-0000-0000-000000000000	645	venl4bdzk4ja	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 06:16:00.583021+00	2025-09-16 06:44:09.516038+00	\N	9fa307ea-1bbb-4f3d-8c46-a29335e56982
00000000-0000-0000-0000-000000000000	646	rsy4a3scekyl	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 06:44:09.522836+00	2025-09-16 06:44:37.245898+00	venl4bdzk4ja	9fa307ea-1bbb-4f3d-8c46-a29335e56982
00000000-0000-0000-0000-000000000000	647	exin6m5hssvk	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 06:44:37.246606+00	2025-09-16 06:46:06.18126+00	rsy4a3scekyl	9fa307ea-1bbb-4f3d-8c46-a29335e56982
00000000-0000-0000-0000-000000000000	648	z6kpcyzvbni7	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 06:46:06.184663+00	2025-09-16 08:01:27.450856+00	exin6m5hssvk	9fa307ea-1bbb-4f3d-8c46-a29335e56982
00000000-0000-0000-0000-000000000000	649	cvogil2wr3i6	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 08:01:27.460839+00	2025-09-16 08:01:27.651841+00	z6kpcyzvbni7	9fa307ea-1bbb-4f3d-8c46-a29335e56982
00000000-0000-0000-0000-000000000000	650	ddbwqkhnaw5n	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 08:01:27.652313+00	2025-09-16 08:13:26.802373+00	cvogil2wr3i6	9fa307ea-1bbb-4f3d-8c46-a29335e56982
00000000-0000-0000-0000-000000000000	651	nkak6zyfypul	78467702-b492-451b-a9f1-2059dbdd433e	f	2025-09-16 08:14:37.496274+00	2025-09-16 08:14:37.496274+00	\N	2d8a65d9-fd7b-4fff-8802-3498e456b389
00000000-0000-0000-0000-000000000000	652	fj4hxdifobmi	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 08:23:46.784018+00	2025-09-16 08:32:51.770718+00	\N	ffa44850-ca30-4c58-a6fc-d771833667dc
00000000-0000-0000-0000-000000000000	653	2z2psco3vnx6	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 08:32:51.778285+00	2025-09-16 16:06:33.977718+00	fj4hxdifobmi	ffa44850-ca30-4c58-a6fc-d771833667dc
00000000-0000-0000-0000-000000000000	654	cwvd5momn32h	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 16:06:34.003221+00	2025-09-16 16:06:34.269396+00	2z2psco3vnx6	ffa44850-ca30-4c58-a6fc-d771833667dc
00000000-0000-0000-0000-000000000000	655	wzgs65urkva5	78467702-b492-451b-a9f1-2059dbdd433e	f	2025-09-16 16:06:34.270392+00	2025-09-16 16:06:34.270392+00	cwvd5momn32h	ffa44850-ca30-4c58-a6fc-d771833667dc
00000000-0000-0000-0000-000000000000	656	fjlmxvkkdtf3	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 16:32:31.874301+00	2025-09-16 16:38:16.608729+00	\N	43a1d000-fa65-49bf-9581-9a0028e132ab
00000000-0000-0000-0000-000000000000	657	hw7zotmwv3do	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 16:38:16.621938+00	2025-09-16 16:38:23.829539+00	fjlmxvkkdtf3	43a1d000-fa65-49bf-9581-9a0028e132ab
00000000-0000-0000-0000-000000000000	658	vtzjk77dqgwo	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 16:38:23.830155+00	2025-09-16 17:06:47.841612+00	hw7zotmwv3do	43a1d000-fa65-49bf-9581-9a0028e132ab
00000000-0000-0000-0000-000000000000	659	6gwkzpl3ovkf	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 17:06:47.847317+00	2025-09-16 17:06:49.270129+00	vtzjk77dqgwo	43a1d000-fa65-49bf-9581-9a0028e132ab
00000000-0000-0000-0000-000000000000	660	wfhv6bslxuv3	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 17:06:49.270523+00	2025-09-16 17:06:53.216985+00	6gwkzpl3ovkf	43a1d000-fa65-49bf-9581-9a0028e132ab
00000000-0000-0000-0000-000000000000	661	zidbb5t6l4n5	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 17:06:53.21737+00	2025-09-16 17:06:57.607811+00	wfhv6bslxuv3	43a1d000-fa65-49bf-9581-9a0028e132ab
00000000-0000-0000-0000-000000000000	662	w2auwiyctnbj	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 17:06:57.608526+00	2025-09-16 17:07:01.63884+00	zidbb5t6l4n5	43a1d000-fa65-49bf-9581-9a0028e132ab
00000000-0000-0000-0000-000000000000	663	e267ebsfqe4u	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 17:07:01.639824+00	2025-09-16 18:06:51.570122+00	w2auwiyctnbj	43a1d000-fa65-49bf-9581-9a0028e132ab
00000000-0000-0000-0000-000000000000	664	3xlpa2dqfifw	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 18:06:51.594217+00	2025-09-16 18:06:51.820295+00	e267ebsfqe4u	43a1d000-fa65-49bf-9581-9a0028e132ab
00000000-0000-0000-0000-000000000000	665	a34e6phqxdph	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 18:06:51.821715+00	2025-09-16 18:08:43.198117+00	3xlpa2dqfifw	43a1d000-fa65-49bf-9581-9a0028e132ab
00000000-0000-0000-0000-000000000000	666	guo66qw5lprh	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 18:38:05.706234+00	2025-09-16 18:38:26.367027+00	\N	e79f7d9f-d2cb-4d6e-bb1e-095606cdb783
00000000-0000-0000-0000-000000000000	667	6zei4etgluyi	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 18:38:26.371473+00	2025-09-16 18:38:32.601757+00	guo66qw5lprh	e79f7d9f-d2cb-4d6e-bb1e-095606cdb783
00000000-0000-0000-0000-000000000000	668	6myf2mjpjtky	78467702-b492-451b-a9f1-2059dbdd433e	f	2025-09-16 18:38:32.602777+00	2025-09-16 18:38:32.602777+00	6zei4etgluyi	e79f7d9f-d2cb-4d6e-bb1e-095606cdb783
00000000-0000-0000-0000-000000000000	669	226rysyc5ipo	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 18:38:51.396156+00	2025-09-16 18:38:59.812347+00	\N	5ceac1b5-dc39-46dd-b56f-63ea02d13f99
00000000-0000-0000-0000-000000000000	670	xdnnahfkn5kh	78467702-b492-451b-a9f1-2059dbdd433e	f	2025-09-16 18:38:59.815516+00	2025-09-16 18:38:59.815516+00	226rysyc5ipo	5ceac1b5-dc39-46dd-b56f-63ea02d13f99
00000000-0000-0000-0000-000000000000	671	yg2rc3qkbvqd	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 18:47:10.321076+00	2025-09-16 18:47:18.373028+00	\N	4cb8e984-0e7e-43d7-a1e7-0e97132e1b8e
00000000-0000-0000-0000-000000000000	672	n5nrd2xajeqt	78467702-b492-451b-a9f1-2059dbdd433e	f	2025-09-16 18:47:18.375679+00	2025-09-16 18:47:18.375679+00	yg2rc3qkbvqd	4cb8e984-0e7e-43d7-a1e7-0e97132e1b8e
00000000-0000-0000-0000-000000000000	673	vof5vf3bcbyy	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 18:48:18.171584+00	2025-09-16 18:48:25.43721+00	\N	a0f895b3-d892-4034-a7e9-5906d8e2085a
00000000-0000-0000-0000-000000000000	674	2z6wszv73imx	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 18:48:25.437599+00	2025-09-16 18:49:28.526865+00	vof5vf3bcbyy	a0f895b3-d892-4034-a7e9-5906d8e2085a
00000000-0000-0000-0000-000000000000	675	raoalc2vtxuh	78467702-b492-451b-a9f1-2059dbdd433e	f	2025-09-16 18:49:28.52755+00	2025-09-16 18:49:28.52755+00	2z6wszv73imx	a0f895b3-d892-4034-a7e9-5906d8e2085a
00000000-0000-0000-0000-000000000000	676	xmknevogwhhl	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 18:56:06.971345+00	2025-09-16 19:29:17.498046+00	\N	ae732e60-c8e3-4228-afdb-7aa8adcfb974
00000000-0000-0000-0000-000000000000	677	qdo4xs4chyrs	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 19:29:17.531202+00	2025-09-16 19:29:19.845074+00	xmknevogwhhl	ae732e60-c8e3-4228-afdb-7aa8adcfb974
00000000-0000-0000-0000-000000000000	678	kp5ppcsxiurp	78467702-b492-451b-a9f1-2059dbdd433e	f	2025-09-16 19:29:19.845438+00	2025-09-16 19:29:19.845438+00	qdo4xs4chyrs	ae732e60-c8e3-4228-afdb-7aa8adcfb974
00000000-0000-0000-0000-000000000000	679	pr4zjmhxjbiv	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 19:29:22.007333+00	2025-09-16 19:29:26.479892+00	\N	45471ddd-1817-4460-bd43-1ea8df8ae99f
00000000-0000-0000-0000-000000000000	680	gsqwiuug46rm	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 19:29:26.481368+00	2025-09-16 19:29:29.258633+00	pr4zjmhxjbiv	45471ddd-1817-4460-bd43-1ea8df8ae99f
00000000-0000-0000-0000-000000000000	681	5kvvp74vbyt2	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 19:29:29.259121+00	2025-09-16 19:30:49.13975+00	gsqwiuug46rm	45471ddd-1817-4460-bd43-1ea8df8ae99f
00000000-0000-0000-0000-000000000000	682	yj4cfvnovo76	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 19:30:49.152547+00	2025-09-16 19:35:59.13071+00	5kvvp74vbyt2	45471ddd-1817-4460-bd43-1ea8df8ae99f
00000000-0000-0000-0000-000000000000	683	yejvnwiuhypj	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 19:35:59.138492+00	2025-09-16 19:39:17.268129+00	yj4cfvnovo76	45471ddd-1817-4460-bd43-1ea8df8ae99f
00000000-0000-0000-0000-000000000000	684	hmtvo6ffnj3j	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 19:39:17.268774+00	2025-09-16 20:39:08.182667+00	yejvnwiuhypj	45471ddd-1817-4460-bd43-1ea8df8ae99f
00000000-0000-0000-0000-000000000000	732	qj7ze5ztoqep	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 15:41:02.004213+00	2025-09-17 16:40:52.711454+00	d52xdfwlgfeq	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	685	xcjn45ea2coj	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 20:39:08.204035+00	2025-09-16 20:39:08.346962+00	hmtvo6ffnj3j	45471ddd-1817-4460-bd43-1ea8df8ae99f
00000000-0000-0000-0000-000000000000	734	hm7ytsnhwqas	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 16:40:52.938754+00	2025-09-17 17:40:43.629588+00	suk6tiv4a2vy	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	686	ozqigtc7bt7w	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 20:39:08.347348+00	2025-09-16 21:38:59.257965+00	xcjn45ea2coj	45471ddd-1817-4460-bd43-1ea8df8ae99f
00000000-0000-0000-0000-000000000000	687	qztgfi47dxj6	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 21:38:59.284961+00	2025-09-16 21:38:59.474088+00	ozqigtc7bt7w	45471ddd-1817-4460-bd43-1ea8df8ae99f
00000000-0000-0000-0000-000000000000	735	vi5mhzna6yj7	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 17:40:43.650168+00	2025-09-17 17:40:43.859257+00	hm7ytsnhwqas	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	688	2gjyfg22hs4r	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 21:38:59.475662+00	2025-09-16 22:02:59.001475+00	qztgfi47dxj6	45471ddd-1817-4460-bd43-1ea8df8ae99f
00000000-0000-0000-0000-000000000000	724	j2rauuuttk3n	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-17 12:20:31.643829+00	2025-09-17 20:18:29.050375+00	st5qpuu62dfy	c2576234-3e34-493f-9d57-2cea5e39aa05
00000000-0000-0000-0000-000000000000	689	braz52fvkj6a	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 22:03:04.080557+00	2025-09-16 23:02:54.888852+00	\N	ae572a98-4030-4fc5-ad51-b5f899cc8f30
00000000-0000-0000-0000-000000000000	693	4gcbeqqqxg42	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-16 23:46:04.143324+00	2025-09-18 02:38:38.987129+00	\N	833d1385-ba1f-4557-9021-cac4e0c889a0
00000000-0000-0000-0000-000000000000	690	fzapxlcyvtc5	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 23:02:54.914374+00	2025-09-16 23:02:55.129518+00	braz52fvkj6a	ae572a98-4030-4fc5-ad51-b5f899cc8f30
00000000-0000-0000-0000-000000000000	691	ksnk3jotnwlf	78467702-b492-451b-a9f1-2059dbdd433e	f	2025-09-16 23:02:55.131795+00	2025-09-16 23:02:55.131795+00	fzapxlcyvtc5	ae572a98-4030-4fc5-ad51-b5f899cc8f30
00000000-0000-0000-0000-000000000000	692	btnyxsw4u5tj	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-16 23:43:39.89399+00	2025-09-17 00:43:29.671073+00	\N	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	694	2ozshv5gd4iv	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 00:43:29.690613+00	2025-09-17 00:43:29.889391+00	btnyxsw4u5tj	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	695	jqrztcpad56f	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 00:43:29.889795+00	2025-09-17 01:43:19.518617+00	2ozshv5gd4iv	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	696	5jjaiy6bwrxs	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 01:43:19.530284+00	2025-09-17 01:43:19.80031+00	jqrztcpad56f	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	697	6i67smzngsm2	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 01:43:19.800706+00	2025-09-17 02:43:09.650522+00	5jjaiy6bwrxs	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	698	m4qnlbzonbo6	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 02:43:09.678539+00	2025-09-17 02:43:09.856958+00	6i67smzngsm2	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	699	l3vf6wmwcli3	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 02:43:09.859969+00	2025-09-17 03:42:59.581146+00	m4qnlbzonbo6	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	700	kbb5bmcbjlxz	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 03:42:59.609113+00	2025-09-17 03:42:59.789486+00	l3vf6wmwcli3	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	701	kyazvmjnyiat	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 03:42:59.790479+00	2025-09-17 04:42:49.46313+00	kbb5bmcbjlxz	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	702	q2wch7zov5av	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 04:42:49.47516+00	2025-09-17 04:42:49.744649+00	kyazvmjnyiat	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	703	diaclflipybn	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 04:42:49.745081+00	2025-09-17 05:42:39.455567+00	q2wch7zov5av	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	704	nlmt2lhw73ai	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 05:42:39.475592+00	2025-09-17 05:42:39.698401+00	diaclflipybn	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	705	u2zjucafbzm3	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 05:42:39.698776+00	2025-09-17 06:42:29.570793+00	nlmt2lhw73ai	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	706	35wg6ixqlnaj	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 06:42:29.588187+00	2025-09-17 06:42:29.76471+00	u2zjucafbzm3	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	707	kj3hjgsdvfnw	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 06:42:29.769602+00	2025-09-17 07:42:19.546171+00	35wg6ixqlnaj	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	708	w5hg676u4sob	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 07:42:19.567626+00	2025-09-17 07:42:19.804988+00	kj3hjgsdvfnw	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	709	sawdcfiu6xx4	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 07:42:19.805429+00	2025-09-17 08:42:09.709758+00	w5hg676u4sob	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	710	wuf2sf57p2nl	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 08:42:09.735117+00	2025-09-17 08:42:09.940462+00	sawdcfiu6xx4	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	711	ocytf2r72s4r	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 08:42:09.941462+00	2025-09-17 09:41:59.599633+00	wuf2sf57p2nl	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	712	xpstqhg3mre7	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 09:41:59.610738+00	2025-09-17 09:41:59.809054+00	ocytf2r72s4r	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	714	bgxhk7i6kghj	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-17 10:11:09.09279+00	2025-09-17 10:11:09.09279+00	\N	4528bae3-3f44-4e75-a3cd-654ace35ffc0
00000000-0000-0000-0000-000000000000	716	fqmjayhbx7yd	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-17 10:28:05.219563+00	2025-09-17 10:28:05.219563+00	\N	bc3647d9-c7d0-4f53-bea8-8b9158cab35c
00000000-0000-0000-0000-000000000000	713	dhivoyblall4	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 09:41:59.809435+00	2025-09-17 10:41:49.0344+00	xpstqhg3mre7	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	717	yq47oomcdwop	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 10:41:49.042919+00	2025-09-17 10:41:49.118285+00	dhivoyblall4	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	715	2i3zyejjhdef	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-17 10:27:55.832953+00	2025-09-17 11:21:39.608621+00	hvhdv52epweg	38d3e981-380e-47e6-bd42-8a9e988fe778
00000000-0000-0000-0000-000000000000	719	qi35d542lawx	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-17 11:21:39.618277+00	2025-09-17 11:21:39.618277+00	2i3zyejjhdef	38d3e981-380e-47e6-bd42-8a9e988fe778
00000000-0000-0000-0000-000000000000	718	bdfjyuhshuxc	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 10:41:49.118671+00	2025-09-17 11:41:39.560817+00	yq47oomcdwop	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	721	3o5ps3c6w4ij	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 11:41:39.587163+00	2025-09-17 11:41:39.759195+00	bdfjyuhshuxc	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	720	bxwy3x7xjzgn	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-17 11:22:53.224668+00	2025-09-17 12:16:20.172781+00	\N	c2576234-3e34-493f-9d57-2cea5e39aa05
00000000-0000-0000-0000-000000000000	723	st5qpuu62dfy	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-17 12:16:20.185987+00	2025-09-17 12:20:31.643121+00	bxwy3x7xjzgn	c2576234-3e34-493f-9d57-2cea5e39aa05
00000000-0000-0000-0000-000000000000	722	bujr426k6szd	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 11:41:39.759606+00	2025-09-17 12:41:29.087946+00	3o5ps3c6w4ij	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	725	6qct74gpxpih	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 12:41:29.110012+00	2025-09-17 12:41:29.203124+00	bujr426k6szd	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	726	j6zhlvgjffcl	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 12:41:29.203493+00	2025-09-17 13:41:20.051393+00	6qct74gpxpih	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	727	6l2jmg4z3psv	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 13:41:20.073891+00	2025-09-17 13:41:20.25613+00	j6zhlvgjffcl	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	728	34ahodokfyts	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 13:41:20.257838+00	2025-09-17 14:41:10.859352+00	6l2jmg4z3psv	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	729	szxy767s5btq	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 14:41:10.871776+00	2025-09-17 14:41:11.099822+00	34ahodokfyts	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	730	hrpoi5fx6qja	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 14:41:11.101234+00	2025-09-17 15:41:01.794661+00	szxy767s5btq	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	731	d52xdfwlgfeq	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 15:41:01.808262+00	2025-09-17 15:41:02.003802+00	hrpoi5fx6qja	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	737	ynri47hj3pc2	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-17 20:18:29.061961+00	2025-09-17 20:18:29.061961+00	j2rauuuttk3n	c2576234-3e34-493f-9d57-2cea5e39aa05
00000000-0000-0000-0000-000000000000	738	4m3polpfaa7z	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-17 20:29:18.751975+00	2025-09-17 21:11:18.549795+00	\N	e4de159c-a466-4f2c-b85c-ecb24e4e72aa
00000000-0000-0000-0000-000000000000	739	4o7muxvs4wbh	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-17 21:11:18.566235+00	2025-09-17 21:28:55.711003+00	4m3polpfaa7z	e4de159c-a466-4f2c-b85c-ecb24e4e72aa
00000000-0000-0000-0000-000000000000	740	4hz3zsx2u7uz	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-17 21:28:55.727443+00	2025-09-17 22:28:48.285819+00	4o7muxvs4wbh	e4de159c-a466-4f2c-b85c-ecb24e4e72aa
00000000-0000-0000-0000-000000000000	741	ltztrdydnent	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-17 22:28:48.307095+00	2025-09-17 22:28:48.41023+00	4hz3zsx2u7uz	e4de159c-a466-4f2c-b85c-ecb24e4e72aa
00000000-0000-0000-0000-000000000000	742	efebwpgvhble	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-17 22:28:48.411127+00	2025-09-17 23:28:40.661099+00	ltztrdydnent	e4de159c-a466-4f2c-b85c-ecb24e4e72aa
00000000-0000-0000-0000-000000000000	743	54ojylxf6kjr	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-17 23:28:40.686646+00	2025-09-17 23:28:41.532136+00	efebwpgvhble	e4de159c-a466-4f2c-b85c-ecb24e4e72aa
00000000-0000-0000-0000-000000000000	736	hfbfcgvg7ic5	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-17 17:40:43.859667+00	2025-09-18 00:11:44.400236+00	vi5mhzna6yj7	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	745	iy2tkvyqflkx	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-18 00:11:44.421675+00	2025-09-18 00:11:44.597225+00	hfbfcgvg7ic5	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	744	ws22siqid5dk	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-17 23:28:41.532499+00	2025-09-18 00:28:33.734804+00	54ojylxf6kjr	e4de159c-a466-4f2c-b85c-ecb24e4e72aa
00000000-0000-0000-0000-000000000000	747	o5tvzvqdbc3i	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-18 00:28:33.740708+00	2025-09-18 00:28:34.22133+00	ws22siqid5dk	e4de159c-a466-4f2c-b85c-ecb24e4e72aa
00000000-0000-0000-0000-000000000000	746	hzojnewf6l72	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-18 00:11:44.59831+00	2025-09-18 01:11:34.147462+00	iy2tkvyqflkx	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	748	psqkd5zyfhaf	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-18 00:28:34.221706+00	2025-09-18 01:28:26.256124+00	o5tvzvqdbc3i	e4de159c-a466-4f2c-b85c-ecb24e4e72aa
00000000-0000-0000-0000-000000000000	750	hsy4neezcund	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-18 01:28:26.259981+00	2025-09-18 01:28:27.077872+00	psqkd5zyfhaf	e4de159c-a466-4f2c-b85c-ecb24e4e72aa
00000000-0000-0000-0000-000000000000	751	zszyvrvzwlca	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-18 01:28:27.078258+00	2025-09-18 01:58:05.470142+00	hsy4neezcund	e4de159c-a466-4f2c-b85c-ecb24e4e72aa
00000000-0000-0000-0000-000000000000	749	7e2pufx7huj3	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-18 01:11:34.155327+00	2025-09-18 02:11:24.585998+00	hzojnewf6l72	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	753	el2iaikletnh	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-18 02:11:24.596741+00	2025-09-18 02:11:24.702078+00	7e2pufx7huj3	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	755	oknesmiwgjmc	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-18 02:38:39.011463+00	2025-09-18 02:38:39.011463+00	4gcbeqqqxg42	833d1385-ba1f-4557-9021-cac4e0c889a0
00000000-0000-0000-0000-000000000000	756	vbbvmqqzyatm	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-18 02:49:26.531415+00	2025-09-18 02:49:26.531415+00	\N	f52e50dc-6451-4aab-9300-5ee3d12aa663
00000000-0000-0000-0000-000000000000	757	h4q4vu34xq4m	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-18 02:56:08.588008+00	2025-09-18 02:56:35.77871+00	\N	28a8c730-a855-4703-a909-44ab4600f2e4
00000000-0000-0000-0000-000000000000	752	6mncfmwbcqas	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-18 01:58:23.694126+00	2025-09-18 02:58:14.186732+00	\N	89c141a2-771c-4a9e-8f6d-4f52416a71a7
00000000-0000-0000-0000-000000000000	759	3irxjdfcdbg4	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-18 02:58:14.187442+00	2025-09-18 02:58:14.313858+00	6mncfmwbcqas	89c141a2-771c-4a9e-8f6d-4f52416a71a7
00000000-0000-0000-0000-000000000000	760	rcgyukozocrx	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-18 02:58:14.314304+00	2025-09-18 03:16:45.251372+00	3irxjdfcdbg4	89c141a2-771c-4a9e-8f6d-4f52416a71a7
00000000-0000-0000-0000-000000000000	761	zzuw7gcdfdcd	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-18 03:17:11.84356+00	2025-09-18 03:17:11.84356+00	\N	02874424-dba7-4ae0-a20d-6e7796ddd1df
00000000-0000-0000-0000-000000000000	758	75gcinhbwgmt	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-18 02:56:35.786802+00	2025-09-18 03:24:55.159011+00	h4q4vu34xq4m	28a8c730-a855-4703-a909-44ab4600f2e4
00000000-0000-0000-0000-000000000000	762	b2cphjtgwjz5	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-18 03:24:55.167027+00	2025-09-18 03:24:55.167027+00	75gcinhbwgmt	28a8c730-a855-4703-a909-44ab4600f2e4
00000000-0000-0000-0000-000000000000	763	xszq6yyqhxwi	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-18 03:27:28.361864+00	2025-09-18 03:27:28.361864+00	\N	28cf8058-092a-4f12-bb42-0a6e8991cbea
00000000-0000-0000-0000-000000000000	764	ubjsfwlpsii3	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-18 03:27:52.581042+00	2025-09-18 03:27:52.581042+00	\N	7e5094e9-81c6-4a62-abaf-6908e3a6a081
00000000-0000-0000-0000-000000000000	765	bz4mlb7qm555	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-18 03:47:24.840332+00	2025-09-18 03:57:26.010317+00	\N	805cebc3-d1ff-4b9f-a5df-39ccd4542414
00000000-0000-0000-0000-000000000000	767	qifyimf3noll	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-18 03:57:26.014835+00	2025-09-18 03:57:29.677525+00	bz4mlb7qm555	805cebc3-d1ff-4b9f-a5df-39ccd4542414
00000000-0000-0000-0000-000000000000	769	kopckh7nes2e	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-18 03:58:20.871655+00	2025-09-18 03:58:20.871655+00	\N	33dfc82b-a471-4f29-9c3b-f74b730767ea
00000000-0000-0000-0000-000000000000	770	5rjon7u7msl5	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-18 04:12:44.206451+00	2025-09-18 04:33:02.433591+00	\N	4796cb6f-ea55-4a9b-90a0-785f594b14bd
00000000-0000-0000-0000-000000000000	771	sh6ybwt2yl7b	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-18 04:33:02.445688+00	2025-09-18 04:33:02.445688+00	5rjon7u7msl5	4796cb6f-ea55-4a9b-90a0-785f594b14bd
00000000-0000-0000-0000-000000000000	754	i47ovdzwxcge	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-18 02:11:24.702496+00	2025-09-18 04:40:52.046321+00	el2iaikletnh	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	773	ges4lkou5qxj	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-18 04:40:52.048318+00	2025-09-18 04:40:52.174095+00	i47ovdzwxcge	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	772	mindbzw55y7z	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-18 04:33:25.182285+00	2025-09-18 05:25:10.774561+00	\N	046128ff-faa8-4529-b9c2-a78cb9d29349
00000000-0000-0000-0000-000000000000	775	wcfckmq7inb6	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-18 05:25:10.789674+00	2025-09-18 05:25:10.789674+00	mindbzw55y7z	046128ff-faa8-4529-b9c2-a78cb9d29349
00000000-0000-0000-0000-000000000000	774	2am7kevmn577	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-18 04:40:52.174519+00	2025-09-18 05:40:42.466868+00	ges4lkou5qxj	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	777	tyeuews3ft3u	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-18 05:40:42.470527+00	2025-09-18 05:40:42.554881+00	2am7kevmn577	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	776	tqmcytnc3fja	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-18 05:32:54.77517+00	2025-09-18 06:09:35.027117+00	\N	cbf96df9-654c-4371-ac5f-8df35cc85703
00000000-0000-0000-0000-000000000000	779	zolq67fqokpu	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-18 06:09:35.03863+00	2025-09-18 06:19:42.958504+00	tqmcytnc3fja	cbf96df9-654c-4371-ac5f-8df35cc85703
00000000-0000-0000-0000-000000000000	780	yhain5tmssfs	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-18 06:19:42.96713+00	2025-09-18 06:20:02.085092+00	zolq67fqokpu	cbf96df9-654c-4371-ac5f-8df35cc85703
00000000-0000-0000-0000-000000000000	781	u4pymuei5ob4	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-18 06:20:02.085434+00	2025-09-18 06:20:02.085434+00	yhain5tmssfs	cbf96df9-654c-4371-ac5f-8df35cc85703
00000000-0000-0000-0000-000000000000	778	6d5ivit3cyjr	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-18 05:40:42.555281+00	2025-09-18 06:40:32.083234+00	tyeuews3ft3u	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	782	iq35cwgajkna	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-18 06:40:32.106521+00	2025-09-18 06:40:32.216055+00	6d5ivit3cyjr	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	784	bpfybzo4ot3v	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-18 06:47:40.528516+00	2025-09-18 06:47:40.528516+00	\N	e881b73c-0cde-4f35-bf6b-710e7ffb78c0
00000000-0000-0000-0000-000000000000	783	pzpliheah2ka	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-18 06:40:32.217071+00	2025-09-18 07:40:22.578876+00	iq35cwgajkna	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	786	p3ylq34z4i7h	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-18 07:40:22.591269+00	2025-09-18 07:40:22.696277+00	pzpliheah2ka	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	766	3d2nbd447htp	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-18 03:52:01.131721+00	2025-09-18 07:42:29.570314+00	\N	3e8ee467-5b06-4fa6-9fa8-ec1171a577b6
00000000-0000-0000-0000-000000000000	785	2fksfugn5cdw	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-18 07:20:34.612951+00	2025-09-18 07:42:42.328216+00	\N	a59fc041-975e-40d8-b6b4-d2a234684e69
00000000-0000-0000-0000-000000000000	768	rybojr2ckxiw	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-18 03:57:29.680997+00	2025-09-19 06:31:15.589031+00	qifyimf3noll	805cebc3-d1ff-4b9f-a5df-39ccd4542414
00000000-0000-0000-0000-000000000000	788	jwu64hzpjqtr	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-18 07:42:29.574136+00	2025-09-18 07:42:29.574136+00	3d2nbd447htp	3e8ee467-5b06-4fa6-9fa8-ec1171a577b6
00000000-0000-0000-0000-000000000000	787	gmztzpn573zg	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-18 07:40:22.69665+00	2025-09-19 03:30:47.004523+00	p3ylq34z4i7h	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	790	lardq5mavv3m	78467702-b492-451b-a9f1-2059dbdd433e	t	2025-09-19 03:30:47.026297+00	2025-09-19 03:30:47.249333+00	gmztzpn573zg	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	791	5fhsnpnsq4d4	78467702-b492-451b-a9f1-2059dbdd433e	f	2025-09-19 03:30:47.250395+00	2025-09-19 03:30:47.250395+00	lardq5mavv3m	9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0
00000000-0000-0000-0000-000000000000	789	3f5v2mmk2qpx	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-18 07:42:42.329049+00	2025-09-20 00:47:33.259603+00	2fksfugn5cdw	a59fc041-975e-40d8-b6b4-d2a234684e69
00000000-0000-0000-0000-000000000000	793	ci4kl2p2a2ca	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-20 00:47:33.28812+00	2025-09-20 00:47:33.28812+00	3f5v2mmk2qpx	a59fc041-975e-40d8-b6b4-d2a234684e69
00000000-0000-0000-0000-000000000000	794	vqejhbeuinqz	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-20 00:47:41.650055+00	2025-09-20 00:48:29.503875+00	\N	9fa5cb6d-9a4c-428a-8244-d06adc0ff85e
00000000-0000-0000-0000-000000000000	795	uf6sni2efya2	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-20 00:48:29.505305+00	2025-09-24 00:47:14.014342+00	vqejhbeuinqz	9fa5cb6d-9a4c-428a-8244-d06adc0ff85e
00000000-0000-0000-0000-000000000000	796	tgefyslaoyad	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-24 00:47:14.046423+00	2025-09-24 00:47:14.046423+00	uf6sni2efya2	9fa5cb6d-9a4c-428a-8244-d06adc0ff85e
00000000-0000-0000-0000-000000000000	797	xs4arzkg7myh	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-24 00:47:21.059056+00	2025-09-24 00:47:21.059056+00	\N	4212192e-cf57-4127-b5c4-8dad2a050b90
00000000-0000-0000-0000-000000000000	798	ezlthaqqmzn2	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-24 01:46:18.586493+00	2025-09-24 01:46:18.586493+00	\N	0d8c0c02-2b51-4531-a204-f1191f5cc218
00000000-0000-0000-0000-000000000000	799	7exrjivozapj	c607bf29-70df-4b8d-9ffe-1f7329a76880	f	2025-09-26 22:39:16.356874+00	2025-09-26 22:39:16.356874+00	\N	306d892a-7a17-42b9-b223-f892f3161f68
00000000-0000-0000-0000-000000000000	800	2rp32s37ojhl	c607bf29-70df-4b8d-9ffe-1f7329a76880	f	2025-09-26 22:42:22.746386+00	2025-09-26 22:42:22.746386+00	\N	20e5429d-b26f-49b4-ab5d-afeecf16af18
00000000-0000-0000-0000-000000000000	801	swff4cjja3uv	c607bf29-70df-4b8d-9ffe-1f7329a76880	f	2025-09-26 22:43:51.513688+00	2025-09-26 22:43:51.513688+00	\N	68144ade-084b-4a77-83f3-3b6dc183c592
00000000-0000-0000-0000-000000000000	802	sad3ekbodakz	c607bf29-70df-4b8d-9ffe-1f7329a76880	f	2025-09-26 22:55:35.456616+00	2025-09-26 22:55:35.456616+00	\N	1451e5b3-46c3-4733-bc13-688bbe8d4919
00000000-0000-0000-0000-000000000000	803	opbdsdpkcjym	c607bf29-70df-4b8d-9ffe-1f7329a76880	f	2025-09-26 22:58:14.912732+00	2025-09-26 22:58:14.912732+00	\N	6aea7bb2-7a28-4cf2-aaf4-59045b6449de
00000000-0000-0000-0000-000000000000	804	rfpkcqgemhdh	c607bf29-70df-4b8d-9ffe-1f7329a76880	f	2025-09-26 23:01:18.980018+00	2025-09-26 23:01:18.980018+00	\N	bfea420d-890e-439b-a343-8d1870d9e102
00000000-0000-0000-0000-000000000000	805	albwb4cz6jhq	c607bf29-70df-4b8d-9ffe-1f7329a76880	f	2025-09-26 23:02:17.268705+00	2025-09-26 23:02:17.268705+00	\N	62e9c3b7-4827-4f2d-b3f9-5f0b4559313c
00000000-0000-0000-0000-000000000000	806	6egbrir2wge5	c607bf29-70df-4b8d-9ffe-1f7329a76880	f	2025-09-26 23:08:32.535846+00	2025-09-26 23:08:32.535846+00	\N	fcfa0146-570f-4dc9-978f-452902ae3f5f
00000000-0000-0000-0000-000000000000	807	eameynol3o7l	c607bf29-70df-4b8d-9ffe-1f7329a76880	f	2025-09-26 23:09:57.997547+00	2025-09-26 23:09:57.997547+00	\N	1c592d80-e271-4f25-973b-bf073c088cbd
00000000-0000-0000-0000-000000000000	808	3beuf2oei236	c607bf29-70df-4b8d-9ffe-1f7329a76880	f	2025-09-26 23:15:08.501153+00	2025-09-26 23:15:08.501153+00	\N	eb7bd3b3-6106-42cc-bc2a-8919da90a8b4
00000000-0000-0000-0000-000000000000	810	yuoiwepsanwk	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-27 20:12:52.579795+00	2025-09-27 20:12:53.609382+00	\N	40e19829-7ebc-49a5-8c00-67ebdcd4eeb8
00000000-0000-0000-0000-000000000000	811	6nqcn2nssk7w	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-27 20:12:53.610077+00	2025-09-27 20:13:00.914865+00	yuoiwepsanwk	40e19829-7ebc-49a5-8c00-67ebdcd4eeb8
00000000-0000-0000-0000-000000000000	812	p243655i5ee7	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-27 20:13:00.916564+00	2025-09-27 20:13:06.520129+00	6nqcn2nssk7w	40e19829-7ebc-49a5-8c00-67ebdcd4eeb8
00000000-0000-0000-0000-000000000000	813	3xjdu4o3x4f3	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-27 20:13:06.521237+00	2025-09-27 20:13:07.888509+00	p243655i5ee7	40e19829-7ebc-49a5-8c00-67ebdcd4eeb8
00000000-0000-0000-0000-000000000000	814	aexot3aweeqt	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-27 20:13:07.889868+00	2025-09-27 20:13:07.889868+00	3xjdu4o3x4f3	40e19829-7ebc-49a5-8c00-67ebdcd4eeb8
00000000-0000-0000-0000-000000000000	815	4uh2mgkxtwa7	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-27 21:28:58.29715+00	2025-09-27 21:28:58.29715+00	\N	066bf61d-4e0e-448b-94f5-f30011d17fa7
00000000-0000-0000-0000-000000000000	816	fhoxggg3s3af	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-27 21:55:41.962255+00	2025-09-28 03:27:17.548058+00	\N	17d0de8c-131c-4812-8335-043e43a0ddea
00000000-0000-0000-0000-000000000000	817	kzhlpjau2jzh	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-28 03:27:17.567827+00	2025-09-28 03:27:17.728505+00	fhoxggg3s3af	17d0de8c-131c-4812-8335-043e43a0ddea
00000000-0000-0000-0000-000000000000	818	2hsqq2t47aui	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-28 03:27:17.729861+00	2025-09-28 18:18:46.196451+00	kzhlpjau2jzh	17d0de8c-131c-4812-8335-043e43a0ddea
00000000-0000-0000-0000-000000000000	819	zyrff7eooxot	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-28 18:18:56.761364+00	2025-09-28 22:01:44.998342+00	\N	9a8ef10a-14d6-4559-b587-c26b40618cb5
00000000-0000-0000-0000-000000000000	820	or37e2livhxm	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-28 22:01:45.028232+00	2025-09-28 22:01:54.751279+00	zyrff7eooxot	9a8ef10a-14d6-4559-b587-c26b40618cb5
00000000-0000-0000-0000-000000000000	821	ik4y7wuxdkxx	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-28 22:01:54.752027+00	2025-09-28 22:01:54.752027+00	or37e2livhxm	9a8ef10a-14d6-4559-b587-c26b40618cb5
00000000-0000-0000-0000-000000000000	822	p4jamuq7j3ft	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-28 22:02:33.698911+00	2025-09-28 22:02:41.508365+00	\N	725cd264-5811-4e1d-b9a8-3e00696ca092
00000000-0000-0000-0000-000000000000	823	cxukwcjszt5c	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-28 22:02:41.513301+00	2025-09-28 22:03:54.171859+00	p4jamuq7j3ft	725cd264-5811-4e1d-b9a8-3e00696ca092
00000000-0000-0000-0000-000000000000	824	kmll32ehe2sx	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-28 22:03:54.172893+00	2025-09-28 22:05:12.482515+00	cxukwcjszt5c	725cd264-5811-4e1d-b9a8-3e00696ca092
00000000-0000-0000-0000-000000000000	825	ifqycwbgc4ok	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-28 22:05:12.48287+00	2025-09-28 22:05:23.128657+00	kmll32ehe2sx	725cd264-5811-4e1d-b9a8-3e00696ca092
00000000-0000-0000-0000-000000000000	826	3pj6tmubeala	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-28 22:05:23.129052+00	2025-09-28 22:17:39.942805+00	ifqycwbgc4ok	725cd264-5811-4e1d-b9a8-3e00696ca092
00000000-0000-0000-0000-000000000000	827	zhg24sr4gssj	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-28 22:17:39.953645+00	2025-09-29 00:15:57.730263+00	3pj6tmubeala	725cd264-5811-4e1d-b9a8-3e00696ca092
00000000-0000-0000-0000-000000000000	828	r7zhxaviz3fv	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-29 00:15:57.759727+00	2025-09-29 00:16:41.948903+00	zhg24sr4gssj	725cd264-5811-4e1d-b9a8-3e00696ca092
00000000-0000-0000-0000-000000000000	829	u47vs4davqpg	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-29 00:16:41.949978+00	2025-09-29 01:17:58.709516+00	r7zhxaviz3fv	725cd264-5811-4e1d-b9a8-3e00696ca092
00000000-0000-0000-0000-000000000000	830	6ozwjbe6zvb2	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-29 01:17:58.731466+00	2025-09-29 01:18:11.879328+00	u47vs4davqpg	725cd264-5811-4e1d-b9a8-3e00696ca092
00000000-0000-0000-0000-000000000000	831	j3tfcxyqcpjf	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 01:18:11.88103+00	2025-09-29 01:18:11.88103+00	6ozwjbe6zvb2	725cd264-5811-4e1d-b9a8-3e00696ca092
00000000-0000-0000-0000-000000000000	832	wonpqboqmoyp	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 01:18:16.3194+00	2025-09-29 01:18:16.3194+00	\N	84eaf787-0d12-4a76-906d-35d89f1551b7
00000000-0000-0000-0000-000000000000	833	w4ustsmv2y4b	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 01:18:56.819465+00	2025-09-29 01:18:56.819465+00	\N	ef632746-7bd6-4459-a497-06e7df6f1046
00000000-0000-0000-0000-000000000000	834	jhlx7xw2yn7q	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 01:52:20.388151+00	2025-09-29 01:52:20.388151+00	\N	d9a70e68-8fc2-452f-8a23-5d982be83ec2
00000000-0000-0000-0000-000000000000	835	5fmyhvpyq7yp	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 01:55:24.108563+00	2025-09-29 01:55:24.108563+00	\N	903b85d5-f326-4dae-b496-1f46328f31a6
00000000-0000-0000-0000-000000000000	836	re7oi4a44ddz	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 01:55:27.067871+00	2025-09-29 01:55:27.067871+00	\N	5a41f105-4990-4ef1-88ac-82b2bbc00d04
00000000-0000-0000-0000-000000000000	837	uaetuhg3asp7	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-29 01:55:39.636988+00	2025-09-29 02:56:51.059063+00	\N	8b042945-b6f4-4887-a76c-9565c3c2327b
00000000-0000-0000-0000-000000000000	792	m6ejneoouxh2	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-19 06:31:15.613421+00	2025-09-29 03:43:52.81516+00	rybojr2ckxiw	805cebc3-d1ff-4b9f-a5df-39ccd4542414
00000000-0000-0000-0000-000000000000	838	c6rvp6gehwo3	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-29 01:58:48.67222+00	2025-09-29 02:38:08.36572+00	\N	2c7c85b8-be0f-48d8-b075-49f62c720f54
00000000-0000-0000-0000-000000000000	839	lycwhrutuk2w	1dc56294-d8f6-4fc9-984a-6d176d125856	f	2025-09-29 02:38:08.391803+00	2025-09-29 02:38:08.391803+00	c6rvp6gehwo3	2c7c85b8-be0f-48d8-b075-49f62c720f54
00000000-0000-0000-0000-000000000000	842	ympnpcwpyc5u	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-29 03:43:52.828755+00	2025-09-29 03:43:52.828755+00	m6ejneoouxh2	805cebc3-d1ff-4b9f-a5df-39ccd4542414
00000000-0000-0000-0000-000000000000	840	sv2mttl26my7	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-29 02:38:13.948614+00	2025-09-29 03:43:54.554026+00	\N	e2698428-dc8e-4886-8f28-0b7b7fb866f8
00000000-0000-0000-0000-000000000000	844	vjjjuppk3bzr	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-29 03:43:58.976835+00	2025-09-29 03:43:58.976835+00	\N	942a51d2-470e-410f-aa70-f03d985658d3
00000000-0000-0000-0000-000000000000	841	gjslewtjscl4	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-29 02:56:51.073419+00	2025-09-29 03:56:41.528185+00	uaetuhg3asp7	8b042945-b6f4-4887-a76c-9565c3c2327b
00000000-0000-0000-0000-000000000000	845	55rj4alt4ey2	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-29 03:56:41.553161+00	2025-09-29 03:56:41.674042+00	gjslewtjscl4	8b042945-b6f4-4887-a76c-9565c3c2327b
00000000-0000-0000-0000-000000000000	846	lal5sxz2tmqf	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 03:56:41.675078+00	2025-09-29 03:56:41.675078+00	55rj4alt4ey2	8b042945-b6f4-4887-a76c-9565c3c2327b
00000000-0000-0000-0000-000000000000	847	qf6hugyh4hes	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 04:01:50.691261+00	2025-09-29 04:01:50.691261+00	\N	288094a8-de3b-45f4-9d5b-ff25f4eed972
00000000-0000-0000-0000-000000000000	848	oqgskhblt7op	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 04:03:44.814826+00	2025-09-29 04:03:44.814826+00	\N	126ff890-43f6-4cf5-9b58-c83af2d95205
00000000-0000-0000-0000-000000000000	849	4k77cosoaew6	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 04:16:11.625572+00	2025-09-29 04:16:11.625572+00	\N	07c2ba0b-4b7a-4580-8631-ce0cfd59b5be
00000000-0000-0000-0000-000000000000	850	33tniafky467	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 04:21:13.063216+00	2025-09-29 04:21:13.063216+00	\N	d9d0793e-377e-4b2d-9855-f4b9f1585dc0
00000000-0000-0000-0000-000000000000	843	qbgdofhr7v4t	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-29 03:43:54.557379+00	2025-09-29 04:46:15.881707+00	sv2mttl26my7	e2698428-dc8e-4886-8f28-0b7b7fb866f8
00000000-0000-0000-0000-000000000000	852	x763yf3d5eef	1dc56294-d8f6-4fc9-984a-6d176d125856	f	2025-09-29 04:46:15.89907+00	2025-09-29 04:46:15.89907+00	qbgdofhr7v4t	e2698428-dc8e-4886-8f28-0b7b7fb866f8
00000000-0000-0000-0000-000000000000	853	aakka7f5yunh	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 04:52:15.793197+00	2025-09-29 04:52:15.793197+00	\N	e56b6eb8-7d1d-4501-8474-a3b85e8a53a5
00000000-0000-0000-0000-000000000000	854	trtrjrza6n3e	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 04:52:36.366358+00	2025-09-29 04:52:36.366358+00	\N	a478b1da-611c-422c-af62-5f8718cf9433
00000000-0000-0000-0000-000000000000	855	g4dqb22t6vnu	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 04:52:38.281493+00	2025-09-29 04:52:38.281493+00	\N	f503e6f2-6a96-4318-9133-6779f36469f1
00000000-0000-0000-0000-000000000000	857	cvtnsmzy7226	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 05:36:54.34739+00	2025-09-29 05:36:54.34739+00	\N	c5d90591-bf5b-4abf-ba1f-cc22844f2527
00000000-0000-0000-0000-000000000000	858	sgqwdl6l5gqc	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-29 05:36:56.527134+00	2025-09-29 05:37:00.156209+00	\N	fc4fc8b3-d213-4a6b-bb9d-5cecb8ee85d2
00000000-0000-0000-0000-000000000000	859	jqhzhd6t6gm4	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 05:37:00.158992+00	2025-09-29 05:37:00.158992+00	sgqwdl6l5gqc	fc4fc8b3-d213-4a6b-bb9d-5cecb8ee85d2
00000000-0000-0000-0000-000000000000	851	tlrnjsxd5hfw	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 04:40:32.375962+00	2025-09-29 05:40:23.818554+00	\N	1cc4ef10-f2e9-4df9-88cf-afba444b7592
00000000-0000-0000-0000-000000000000	861	todbsbrnouau	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 05:40:23.82461+00	2025-09-29 05:40:23.975108+00	tlrnjsxd5hfw	1cc4ef10-f2e9-4df9-88cf-afba444b7592
00000000-0000-0000-0000-000000000000	856	pe5l2gaylc66	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-29 05:20:52.013876+00	2025-09-29 06:20:44.411203+00	\N	d6f6c0ec-5577-475a-afb6-3c6ec9134da7
00000000-0000-0000-0000-000000000000	863	lpu3jztnilga	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-29 06:20:44.443138+00	2025-09-29 06:20:44.539742+00	pe5l2gaylc66	d6f6c0ec-5577-475a-afb6-3c6ec9134da7
00000000-0000-0000-0000-000000000000	864	mgujdmqook65	1dc56294-d8f6-4fc9-984a-6d176d125856	t	2025-09-29 06:20:44.540215+00	2025-09-29 06:22:17.073354+00	lpu3jztnilga	d6f6c0ec-5577-475a-afb6-3c6ec9134da7
00000000-0000-0000-0000-000000000000	865	5lxi7fzbrihd	1dc56294-d8f6-4fc9-984a-6d176d125856	f	2025-09-29 06:22:49.777755+00	2025-09-29 06:22:49.777755+00	\N	3b6a6ad8-d19b-42d6-be4b-f7d59757ad8f
00000000-0000-0000-0000-000000000000	860	54dryl5nphob	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-29 05:39:04.963548+00	2025-09-29 06:39:58.693964+00	\N	d586d7e6-5428-4c91-8fd2-19d522a98a1f
00000000-0000-0000-0000-000000000000	866	mrimhte7fsb7	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-29 06:39:58.704978+00	2025-09-29 06:39:58.845042+00	54dryl5nphob	d586d7e6-5428-4c91-8fd2-19d522a98a1f
00000000-0000-0000-0000-000000000000	862	joldxo2gowvm	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 05:40:23.97658+00	2025-09-29 06:40:15.295618+00	todbsbrnouau	1cc4ef10-f2e9-4df9-88cf-afba444b7592
00000000-0000-0000-0000-000000000000	868	z2lwscxpxywt	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 06:40:15.297595+00	2025-09-29 06:40:15.453063+00	joldxo2gowvm	1cc4ef10-f2e9-4df9-88cf-afba444b7592
00000000-0000-0000-0000-000000000000	867	mczkvxfmgg3m	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-29 06:39:58.845395+00	2025-09-29 06:43:33.904456+00	mrimhte7fsb7	d586d7e6-5428-4c91-8fd2-19d522a98a1f
00000000-0000-0000-0000-000000000000	870	n4xjusiy5bfy	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 06:43:40.841009+00	2025-09-29 06:43:40.841009+00	\N	c26859af-aa74-4c16-953d-73bd7eaf905d
00000000-0000-0000-0000-000000000000	869	oq66cvzhxigg	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 06:40:15.453427+00	2025-09-29 07:05:40.725083+00	z2lwscxpxywt	1cc4ef10-f2e9-4df9-88cf-afba444b7592
00000000-0000-0000-0000-000000000000	872	spsgyy6o2itj	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 07:05:54.294079+00	2025-09-29 07:05:59.31392+00	\N	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	873	nfzr7g4i5r7d	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 07:05:59.315515+00	2025-09-29 08:05:51.260482+00	spsgyy6o2itj	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	874	uo4ytvnpvoxq	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 08:05:51.285702+00	2025-09-29 08:05:51.411878+00	nfzr7g4i5r7d	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	875	c7lpsw2d6l5d	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 08:05:51.412813+00	2025-09-29 09:05:44.355888+00	uo4ytvnpvoxq	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	876	zfgyjgl3emcx	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 09:05:44.371371+00	2025-09-29 09:05:44.520273+00	c7lpsw2d6l5d	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	877	qiyom55jlqxi	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 09:05:44.520668+00	2025-09-29 10:05:37.404623+00	zfgyjgl3emcx	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	878	iegd3zdsiw7t	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 10:05:37.422013+00	2025-09-29 10:05:37.54403+00	qiyom55jlqxi	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	879	7azzthusfrwg	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 10:05:37.544427+00	2025-09-29 11:05:30.479648+00	iegd3zdsiw7t	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	880	kpqpnlbzlrbz	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 11:05:30.499664+00	2025-09-29 11:05:30.65062+00	7azzthusfrwg	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	881	m6jddmxvrz7q	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 11:05:30.651046+00	2025-09-29 12:05:23.524594+00	kpqpnlbzlrbz	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	882	xlpks4se6jn2	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 12:05:23.545596+00	2025-09-29 12:05:23.680273+00	m6jddmxvrz7q	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	883	yr6w5eemt2yw	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 12:05:23.680673+00	2025-09-29 13:05:16.642082+00	xlpks4se6jn2	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	884	fl7xxgflfafs	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 13:05:16.65895+00	2025-09-29 13:05:16.799491+00	yr6w5eemt2yw	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	885	ipuvvzc6eqcs	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 13:05:16.800475+00	2025-09-29 14:05:09.740257+00	fl7xxgflfafs	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	886	zxv4sw6y2dpv	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 14:05:09.752558+00	2025-09-29 14:05:09.911695+00	ipuvvzc6eqcs	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	887	dlh5pu7kblzk	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 14:05:09.912146+00	2025-09-29 15:05:02.851923+00	zxv4sw6y2dpv	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	888	ok6qtyd6g4sx	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 15:05:02.864444+00	2025-09-29 15:05:03.129344+00	dlh5pu7kblzk	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	871	6qbbgnjolljh	05498f83-18ab-4ba9-b663-767df738a0da	t	2025-09-29 06:57:46.405707+00	2025-09-29 19:33:08.062063+00	\N	7a2d5f1b-2bd6-415d-a942-f08c72628d28
00000000-0000-0000-0000-000000000000	889	sp2ofo5n7ang	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 15:05:03.130388+00	2025-09-29 16:04:57.074313+00	ok6qtyd6g4sx	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	890	gczpaaz6hkrj	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 16:04:57.097365+00	2025-09-29 16:04:57.258196+00	sp2ofo5n7ang	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	891	mdzesb7mulrj	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 16:04:57.260482+00	2025-09-29 17:04:51.218431+00	gczpaaz6hkrj	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	892	xbmqons6fbxz	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 17:04:51.238868+00	2025-09-29 17:04:51.38664+00	mdzesb7mulrj	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	893	ob4ezxcpuhji	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 17:04:51.387093+00	2025-09-29 18:04:45.346038+00	xbmqons6fbxz	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	894	7gavn2hp3k4y	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 18:04:45.366676+00	2025-09-29 18:04:45.510339+00	ob4ezxcpuhji	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	895	5rk6l2cvkngc	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 18:04:45.510822+00	2025-09-29 19:04:39.416599+00	7gavn2hp3k4y	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	896	4p6574smc5pd	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 19:04:39.434647+00	2025-09-29 19:04:39.55445+00	5rk6l2cvkngc	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	898	j2c6mwpnovng	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 19:33:08.077738+00	2025-09-29 19:33:08.077738+00	6qbbgnjolljh	7a2d5f1b-2bd6-415d-a942-f08c72628d28
00000000-0000-0000-0000-000000000000	899	wptqogytd42x	05498f83-18ab-4ba9-b663-767df738a0da	f	2025-09-29 19:33:08.664663+00	2025-09-29 19:33:08.664663+00	\N	c069bef0-ef33-42b6-927d-78c318f7db27
00000000-0000-0000-0000-000000000000	897	iipbeu4wa72t	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 19:04:39.556058+00	2025-09-29 20:04:33.281867+00	4p6574smc5pd	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	900	hd5aqobwabkm	3d05eadb-9eb9-4368-8928-87ccd7783f32	t	2025-09-29 20:04:33.29447+00	2025-09-29 20:04:33.396695+00	iipbeu4wa72t	64a6b0e6-a071-4930-a370-1db3357d6ba9
00000000-0000-0000-0000-000000000000	901	x2vfmut5k4mz	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-29 20:04:33.397172+00	2025-09-29 20:04:33.397172+00	hd5aqobwabkm	64a6b0e6-a071-4930-a370-1db3357d6ba9
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag) FROM stdin;
5776bee8-ded7-430c-a312-9f9766075c77	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-05-03 20:40:18.836999+00	2025-05-03 20:40:18.836999+00	\N	aal1	\N	\N	python-httpx/0.27.0	67.187.189.32	\N
c3cae0ec-4c4c-4aba-b65f-2a435ccc53a8	bf250d15-2188-413b-b954-120a31ca5840	2025-04-10 00:03:25.807828+00	2025-04-10 04:02:40.69701+00	\N	aal1	\N	2025-04-10 04:02:40.696938	python-httpx/0.28.1	73.151.135.139	\N
8ad101cf-f5a4-48dd-a3be-d8a3544bd24e	bf250d15-2188-413b-b954-120a31ca5840	2025-04-11 15:08:52.902464+00	2025-04-11 15:08:52.902464+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
90f1e9d5-bb09-4b6f-8926-7eec1c9dfd51	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-05-03 20:41:27.114859+00	2025-05-03 20:41:27.114859+00	\N	aal1	\N	\N	python-httpx/0.27.0	67.187.189.32	\N
9cae04dd-8e75-4c99-ad80-1091efb3a205	bf250d15-2188-413b-b954-120a31ca5840	2025-04-01 21:43:47.558487+00	2025-04-01 21:43:47.558487+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
6906e6bc-384f-4207-8e5d-a9fb307a186f	bf250d15-2188-413b-b954-120a31ca5840	2025-04-01 21:44:34.188937+00	2025-04-01 21:44:34.188937+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
ea0776cb-bf09-4e44-bc53-0ff669ab2e1b	bf250d15-2188-413b-b954-120a31ca5840	2025-04-01 21:47:06.658303+00	2025-04-01 21:47:06.658303+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
0ef81737-c780-4166-9ee7-f23ded438cf8	bf250d15-2188-413b-b954-120a31ca5840	2025-04-01 21:48:52.681605+00	2025-04-01 21:48:52.681605+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
0a69daaa-bc93-42a0-a8c9-11737c9e9b57	bf250d15-2188-413b-b954-120a31ca5840	2025-04-01 22:06:03.514282+00	2025-04-01 22:06:03.514282+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
195c9e8c-8e78-41ec-885b-4d76ae239418	bf250d15-2188-413b-b954-120a31ca5840	2025-04-11 15:10:49.752073+00	2025-04-11 15:10:49.752073+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
a226a2e9-60aa-448b-959d-9721d44caad1	bf250d15-2188-413b-b954-120a31ca5840	2025-04-11 15:43:44.670244+00	2025-04-11 15:43:44.670244+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
91fdfa03-d938-463c-864e-6c38eaab7f6f	bf250d15-2188-413b-b954-120a31ca5840	2025-04-11 15:51:49.247299+00	2025-04-11 15:51:49.247299+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
220e457f-5908-4039-a283-ce75ca266382	bf250d15-2188-413b-b954-120a31ca5840	2025-04-14 19:06:17.064584+00	2025-04-14 20:06:08.368008+00	\N	aal1	\N	2025-04-14 20:06:08.367936	python-httpx/0.28.1	73.151.135.139	\N
935c6082-2e84-45d8-8067-dac5cadd189a	bf250d15-2188-413b-b954-120a31ca5840	2025-04-14 22:13:32.685568+00	2025-04-14 22:13:32.685568+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
16ce9913-e975-4bd6-b4cf-02c215639946	bf250d15-2188-413b-b954-120a31ca5840	2025-04-14 22:15:46.825443+00	2025-04-14 22:15:46.825443+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
96e6199a-bd27-452e-bf9c-9011e9bc92bf	bf250d15-2188-413b-b954-120a31ca5840	2025-05-03 20:42:27.10747+00	2025-05-03 20:59:46.085901+00	\N	aal1	\N	2025-05-03 20:59:46.085829	python-httpx/0.28.1	73.151.135.139	\N
e971e0d2-9215-4868-a3ec-45a61f772cad	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-05-04 01:33:38.428908+00	2025-05-04 01:33:38.428908+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
02c09fa3-41db-483d-9e6e-d85ab6d9ff93	bf250d15-2188-413b-b954-120a31ca5840	2025-03-26 19:24:16.245431+00	2025-03-26 19:24:16.245431+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 OPR/117.0.0.0 (Edition std-1)	73.151.135.139	\N
8b0e4112-b5cb-4d46-bd52-ef26600897c9	bf250d15-2188-413b-b954-120a31ca5840	2025-03-26 19:27:20.802161+00	2025-03-26 19:27:20.802161+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 OPR/117.0.0.0 (Edition std-1)	73.151.135.139	\N
074ed4bc-16ee-4fdd-9640-a1ddcd5151f0	bf250d15-2188-413b-b954-120a31ca5840	2025-03-26 20:08:18.227871+00	2025-03-26 20:08:18.227871+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
9e4248da-131b-4abf-87b7-a496b37f3c4b	bf250d15-2188-413b-b954-120a31ca5840	2025-03-26 20:10:28.487628+00	2025-03-26 20:10:28.487628+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
aea4c651-4e1e-48f4-8afb-9c45d73eede6	bf250d15-2188-413b-b954-120a31ca5840	2025-03-26 20:17:08.721042+00	2025-03-26 20:17:08.721042+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
e693787e-1c24-41f8-bfb2-8b0d295ef3e6	bf250d15-2188-413b-b954-120a31ca5840	2025-03-26 20:19:03.114169+00	2025-03-26 20:19:03.114169+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
b2029b81-a467-48ea-b4b0-861153e7142b	bf250d15-2188-413b-b954-120a31ca5840	2025-03-26 20:20:45.359252+00	2025-03-26 20:20:45.359252+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
cb9360a6-b75e-46f2-bac0-8ed97e005f34	bf250d15-2188-413b-b954-120a31ca5840	2025-03-26 20:21:44.538523+00	2025-03-26 20:21:44.538523+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
f42520ce-6019-41f6-936a-4cf2c410a0b0	bf250d15-2188-413b-b954-120a31ca5840	2025-03-26 20:23:34.686736+00	2025-03-26 20:23:34.686736+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
6b96f06a-c6d9-4516-ba2f-c023c0ad791a	bf250d15-2188-413b-b954-120a31ca5840	2025-03-26 20:25:34.479376+00	2025-03-26 20:25:34.479376+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
a8383d5f-611d-46f6-9620-2162b6ce5193	bf250d15-2188-413b-b954-120a31ca5840	2025-03-26 20:31:03.206113+00	2025-03-26 20:31:03.206113+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
91875e7d-8757-44c5-a78a-0e584b1c1b33	bf250d15-2188-413b-b954-120a31ca5840	2025-03-26 20:50:23.395482+00	2025-03-26 20:50:23.395482+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
ebd413d7-1e0f-4caa-bf72-b9c7fbdc4879	bf250d15-2188-413b-b954-120a31ca5840	2025-03-26 21:10:15.543518+00	2025-03-26 21:10:15.543518+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
ac701636-1b72-403b-b3e1-ebda28c5e9be	bf250d15-2188-413b-b954-120a31ca5840	2025-03-26 20:31:11.336349+00	2025-03-26 21:31:01.654666+00	\N	aal1	\N	2025-03-26 21:31:01.654595	python-httpx/0.28.1	73.151.135.139	\N
81975daa-dd3c-4217-8e0d-8d472a80cfbe	bf250d15-2188-413b-b954-120a31ca5840	2025-03-30 00:36:20.754311+00	2025-03-30 00:36:20.754311+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
b0fbf591-fb54-4997-82e5-7a542ba06807	bf250d15-2188-413b-b954-120a31ca5840	2025-03-30 00:37:59.512969+00	2025-03-30 00:37:59.512969+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
1238fb8a-1436-4854-abe2-ff446b715299	bf250d15-2188-413b-b954-120a31ca5840	2025-03-30 17:48:23.873918+00	2025-03-30 17:48:23.873918+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
10c685d6-0361-49d9-8796-072dde50fd33	bf250d15-2188-413b-b954-120a31ca5840	2025-03-30 21:47:55.774193+00	2025-03-30 21:47:55.774193+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
7de13324-c133-4b8f-be02-45c9d92f3a9f	bf250d15-2188-413b-b954-120a31ca5840	2025-03-30 22:10:12.712965+00	2025-03-30 22:10:12.712965+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
6ddb6c89-caca-4386-bbd0-0fa7bf35e39a	bf250d15-2188-413b-b954-120a31ca5840	2025-03-30 22:11:51.701298+00	2025-03-30 22:11:51.701298+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
f260b724-f528-42a7-8db4-6fd799b996a7	bf250d15-2188-413b-b954-120a31ca5840	2025-03-30 22:14:23.701019+00	2025-03-30 22:14:23.701019+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
5abd24b2-f3c0-40fc-9004-5b26c7543d8c	bf250d15-2188-413b-b954-120a31ca5840	2025-03-31 05:22:34.225394+00	2025-03-31 05:22:34.225394+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
cfeae367-5189-4bec-8686-d49aec3ec71b	bf250d15-2188-413b-b954-120a31ca5840	2025-03-31 05:38:27.526173+00	2025-03-31 05:38:27.526173+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
6f92ec87-8705-4fe4-ace2-aef03c67a7f9	bf250d15-2188-413b-b954-120a31ca5840	2025-04-14 22:42:52.229751+00	2025-04-14 23:42:42.572098+00	\N	aal1	\N	2025-04-14 23:42:42.572022	python-httpx/0.28.1	73.151.135.139	\N
3901fc23-e282-4c9c-bb47-c029f4903ff3	bf250d15-2188-413b-b954-120a31ca5840	2025-04-13 17:43:50.837876+00	2025-04-13 17:43:50.837876+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
deaa56d3-2c18-45ed-8ede-2b6ca1261c07	bf250d15-2188-413b-b954-120a31ca5840	2025-04-13 17:46:34.7562+00	2025-04-13 17:46:34.7562+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
ca5bf2f7-be3d-42de-aa85-36467dad35e3	bf250d15-2188-413b-b954-120a31ca5840	2025-04-10 03:51:21.523209+00	2025-04-10 03:51:21.523209+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
b948d350-ff7a-47cb-b4d4-8d78994c4620	bf250d15-2188-413b-b954-120a31ca5840	2025-04-13 17:47:19.026246+00	2025-04-13 17:47:19.026246+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
00ae48b1-545f-4471-a712-f1b2ade005d2	bf250d15-2188-413b-b954-120a31ca5840	2025-04-10 00:03:15.050455+00	2025-04-10 04:02:30.466589+00	\N	aal1	\N	2025-04-10 04:02:30.466511	python-httpx/0.28.1	73.151.135.139	\N
c81018f0-4aaf-4693-9d5d-5675296e941c	bf250d15-2188-413b-b954-120a31ca5840	2025-04-14 19:06:13.261408+00	2025-04-14 19:06:13.261408+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
e510a996-77ce-4e18-a594-55465a03b986	bf250d15-2188-413b-b954-120a31ca5840	2025-04-14 19:06:15.647329+00	2025-04-14 19:06:15.647329+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
63a45b0d-f621-44e1-9881-4b543b1a26ee	bf250d15-2188-413b-b954-120a31ca5840	2025-04-15 00:28:13.660175+00	2025-04-15 00:28:13.660175+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
c43643fd-1a50-484d-912b-c7d5b827a211	bf250d15-2188-413b-b954-120a31ca5840	2025-04-15 00:56:47.878697+00	2025-04-15 00:56:47.878697+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
ba10fb1b-cc7f-45b7-92fd-e7d47aacfcc5	bf250d15-2188-413b-b954-120a31ca5840	2025-04-15 00:57:57.830693+00	2025-04-15 00:57:57.830693+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
d61a2d50-298a-41ad-9a46-19e69af57515	bf250d15-2188-413b-b954-120a31ca5840	2025-04-19 00:43:08.191369+00	2025-04-19 00:43:08.191369+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
46b83fa0-9db7-4e07-add9-d7006e2021d7	bf250d15-2188-413b-b954-120a31ca5840	2025-04-19 16:35:53.459938+00	2025-04-19 16:35:53.459938+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
18242170-cf07-4ef9-a1ea-172e2352802b	bf250d15-2188-413b-b954-120a31ca5840	2025-04-19 16:46:33.587956+00	2025-04-19 16:46:33.587956+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
e36f9dba-faed-4545-a2e1-fb3b442733d5	bf250d15-2188-413b-b954-120a31ca5840	2025-04-19 16:48:31.802798+00	2025-04-19 16:48:31.802798+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
860dd21b-60d7-41ec-80c7-c9ea0aadd529	bf250d15-2188-413b-b954-120a31ca5840	2025-04-19 16:48:36.147359+00	2025-04-19 16:48:36.147359+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
957ae2ce-6e6f-4f7b-b32b-8d1bb7c39be0	bf250d15-2188-413b-b954-120a31ca5840	2025-04-19 17:15:39.785914+00	2025-04-19 17:15:39.785914+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
50540fee-1412-4f40-b4de-9b34eb2942d2	bf250d15-2188-413b-b954-120a31ca5840	2025-04-19 17:15:42.141289+00	2025-04-19 17:15:42.141289+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
6af7747d-b891-4b55-99b0-1d1422e7ee65	bf250d15-2188-413b-b954-120a31ca5840	2025-04-19 18:04:26.897+00	2025-04-19 18:04:26.897+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
c34b90d7-cd6a-4df9-b5a5-2053d7a42e6f	bf250d15-2188-413b-b954-120a31ca5840	2025-04-20 23:18:56.86121+00	2025-04-20 23:18:56.86121+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
d0b51716-7860-43ce-8dd3-6ba415217384	bf250d15-2188-413b-b954-120a31ca5840	2025-04-20 23:19:00.320537+00	2025-04-20 23:19:00.320537+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
fe367ed1-0301-48b1-803a-71aafc0a2611	bf250d15-2188-413b-b954-120a31ca5840	2025-05-03 21:00:50.447875+00	2025-05-03 21:00:50.447875+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
792b6c44-22cf-4a9b-ba8a-a09e6c4ff9d5	bf250d15-2188-413b-b954-120a31ca5840	2025-05-08 17:31:22.782586+00	2025-05-08 17:33:51.537974+00	\N	aal1	\N	2025-05-08 17:33:51.537906	python-httpx/0.28.1	73.151.135.139	\N
e03c19f5-ffe2-4a63-942b-451f48840200	bf250d15-2188-413b-b954-120a31ca5840	2025-05-03 21:03:12.112408+00	2025-05-03 21:13:16.182214+00	\N	aal1	\N	2025-05-03 21:13:16.182145	python-httpx/0.28.1	73.151.135.139	\N
6081e976-fbcb-4d9b-84d6-215ac319094d	bf250d15-2188-413b-b954-120a31ca5840	2025-04-28 01:51:56.113111+00	2025-04-28 02:51:46.542076+00	\N	aal1	\N	2025-04-28 02:51:46.542003	python-httpx/0.28.1	73.151.135.139	\N
7006555d-0a48-41e6-80d7-bc78441f4cc0	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-05-03 20:36:11.817703+00	2025-05-03 20:39:39.022311+00	\N	aal1	\N	2025-05-03 20:39:39.022244	python-httpx/0.27.0	67.187.189.32	\N
9711f210-f944-436f-94f0-e4c4caa489c2	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-05-04 00:27:25.879885+00	2025-05-04 01:27:16.434186+00	\N	aal1	\N	2025-05-04 01:27:16.434118	python-httpx/0.27.0	73.2.33.92	\N
4d6f494b-9739-4be0-8225-7191e57fed6d	bf250d15-2188-413b-b954-120a31ca5840	2025-07-26 00:39:46.945528+00	2025-07-26 00:39:59.731715+00	\N	aal1	\N	2025-07-26 00:39:59.731649	python-httpx/0.28.1	73.151.135.139	\N
a410fe17-ff1b-41bf-be10-2e2bcdacfdf7	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 10:34:54.740396+00	2025-09-12 10:34:54.740396+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
cd2b73d6-4d7a-42fe-884b-0d3161edd8a3	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 10:35:01.225136+00	2025-09-12 10:35:01.225136+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
e69ddca4-bbed-433b-984e-3ea987690e4a	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 10:39:15.583731+00	2025-09-12 10:39:15.583731+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
5c08900e-5e31-4d22-b308-453c37e8ea89	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 10:43:58.842771+00	2025-09-12 10:43:58.842771+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
a4612ea7-c20f-4208-887a-ddd1af8d5dc1	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 10:47:16.587376+00	2025-09-12 10:47:16.587376+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
927b66b3-5c04-40b7-948c-eba020033fc1	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 10:53:35.387716+00	2025-09-12 10:53:35.387716+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
75429ef2-9e61-4726-91a3-f82dcf3e45d4	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 10:56:10.198161+00	2025-09-12 10:56:10.198161+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
f3037ca4-77c0-4df2-bf32-3b854d39989f	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 11:02:19.968026+00	2025-09-12 11:02:19.968026+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
accfe3d0-8ee6-47c3-96ac-5847f4acff13	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 11:03:06.859716+00	2025-09-12 11:03:06.859716+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
1a9f0bad-6fe3-4494-a78b-fd90b1f1ffe0	bf250d15-2188-413b-b954-120a31ca5840	2025-08-29 16:38:41.918759+00	2025-08-29 16:40:20.507101+00	\N	aal1	\N	2025-08-29 16:40:20.507012	python-httpx/0.28.1	73.151.135.139	\N
72c3ee15-f774-4706-9f43-c60a75b3f7e3	bf250d15-2188-413b-b954-120a31ca5840	2025-09-04 02:57:31.609598+00	2025-09-04 02:57:31.609598+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
f86a41b9-2a45-41a5-914a-ae44c0604574	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 11:05:53.227906+00	2025-09-12 11:05:53.227906+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
8b7fb74f-bb08-4844-b546-a039820809c6	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 11:08:15.276882+00	2025-09-12 11:08:15.276882+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
a5bdff3a-8034-4930-93d0-83ca2b69f9a0	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 08:12:53.785506+00	2025-09-12 11:21:23.510942+00	\N	aal1	\N	2025-09-12 11:21:23.510252	python-httpx/0.27.0	73.2.33.92	\N
e3dd638f-dd2c-483c-8b9e-ff2bd331fc05	bf250d15-2188-413b-b954-120a31ca5840	2025-09-04 03:00:22.148628+00	2025-09-04 03:10:05.55753+00	\N	aal1	\N	2025-09-04 03:10:05.557452	python-httpx/0.28.1	73.151.135.139	\N
4bbd7775-d0d7-481a-bf6e-12ae59b6ee93	bf250d15-2188-413b-b954-120a31ca5840	2025-09-04 03:16:14.557573+00	2025-09-04 03:16:14.557573+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
fd23a616-ec28-4cd8-a631-f5d633a0003a	bf250d15-2188-413b-b954-120a31ca5840	2025-09-04 03:26:35.855457+00	2025-09-04 03:26:35.855457+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
ce457df0-bfc4-4d66-86eb-3af1def5e9fb	bf250d15-2188-413b-b954-120a31ca5840	2025-09-04 03:28:55.549204+00	2025-09-04 03:28:55.549204+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
fd591671-c3b2-44c0-b7b6-170580b690a6	bf250d15-2188-413b-b954-120a31ca5840	2025-09-04 03:30:53.730969+00	2025-09-04 03:30:53.730969+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
a4990197-3b49-4588-b5b6-8b773b2b1eeb	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 11:47:42.188834+00	2025-09-12 11:47:42.188834+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
09ee0a1b-d5d7-4142-9b24-488af18563a4	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 11:51:04.058598+00	2025-09-12 11:51:04.058598+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
dc75c993-d127-4e85-9581-d33f71263cea	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-13 02:59:17.130662+00	2025-09-13 03:49:21.999548+00	\N	aal1	\N	2025-09-13 03:49:21.997764	python-httpx/0.27.0	73.2.33.92	\N
9d65e46e-1d59-4ffd-a0c2-e3d91d8a5458	bf250d15-2188-413b-b954-120a31ca5840	2025-09-04 03:33:00.082008+00	2025-09-04 04:42:48.300833+00	\N	aal1	\N	2025-09-04 04:42:48.300759	python-httpx/0.28.1	73.151.135.139	\N
65fc0d10-851d-4b88-8e65-882499cf7bb6	bf250d15-2188-413b-b954-120a31ca5840	2025-09-04 04:43:28.42758+00	2025-09-04 04:43:28.42758+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
b789fcba-eb67-4ddd-9fea-cbcafa4a2fc1	bf250d15-2188-413b-b954-120a31ca5840	2025-09-04 06:52:45.980894+00	2025-09-04 06:52:45.980894+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
fc372ee1-b75f-4e37-a6e1-232840d27149	bf250d15-2188-413b-b954-120a31ca5840	2025-09-04 07:47:19.585714+00	2025-09-04 07:47:19.585714+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
314d3388-00c5-48c5-babe-8c70fb84535a	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-13 05:15:41.237432+00	2025-09-13 05:15:41.237432+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
6419843a-fc06-40cd-98ad-391e91a8137d	bf250d15-2188-413b-b954-120a31ca5840	2025-09-05 00:00:28.725666+00	2025-09-05 01:00:19.766473+00	\N	aal1	\N	2025-09-05 01:00:19.766405	python-httpx/0.28.1	73.151.135.139	\N
bab38d1e-4e2b-43bb-81cd-8abaccaec8da	bf250d15-2188-413b-b954-120a31ca5840	2025-09-05 01:16:22.733394+00	2025-09-05 01:16:22.733394+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
79e0fa6c-dbcd-4c7f-aed8-d7abd74c935b	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-13 05:15:02.196206+00	2025-09-13 06:19:37.322981+00	\N	aal1	\N	2025-09-13 06:19:37.322424	python-httpx/0.27.0	73.2.33.92	\N
91d8b177-bae2-4841-b0ca-0c33fe976a1c	bf250d15-2188-413b-b954-120a31ca5840	2025-09-05 05:26:17.157158+00	2025-09-05 06:26:08.154896+00	\N	aal1	\N	2025-09-05 06:26:08.154831	python-httpx/0.28.1	73.151.135.139	\N
5daffb69-09f0-4706-a823-e4ee235600b9	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-13 08:33:49.53383+00	2025-09-13 08:33:49.53383+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
051f8903-3e13-4345-82d1-e123318dbc20	bf250d15-2188-413b-b954-120a31ca5840	2025-09-14 19:33:03.898512+00	2025-09-14 19:33:03.898512+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
104e3d9e-15e9-4f01-b2a5-1ad9b02a6bd5	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-13 21:26:35.013822+00	2025-09-13 22:26:26.072012+00	\N	aal1	\N	2025-09-13 22:26:26.070547	python-httpx/0.27.0	73.2.33.92	\N
5cdc7063-dfdf-4f8a-ac00-118100fa5ad1	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-14 06:06:15.644082+00	2025-09-14 06:06:15.644082+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
8434698b-7bf5-4401-a6db-2968f956f61c	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-14 06:47:42.205393+00	2025-09-14 06:47:42.205393+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
3d3d0f8b-eef6-469c-b333-722c32b3aa9a	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-14 08:24:25.748031+00	2025-09-14 09:02:25.255629+00	\N	aal1	\N	2025-09-14 09:02:25.255561	python-httpx/0.27.0	73.2.33.92	\N
21afe93a-435c-42df-97fa-67ea6be55f69	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 06:51:29.104369+00	2025-09-12 07:22:23.295059+00	\N	aal1	\N	2025-09-12 07:22:23.294993	python-httpx/0.27.0	73.2.33.92	\N
a220fcaf-6c3d-43f1-87b8-6a8197667c54	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 08:16:15.015299+00	2025-09-12 08:16:15.015299+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
c553d554-172d-418c-ace5-acf8953b5867	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 08:17:48.442658+00	2025-09-12 08:17:48.442658+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
964677c1-610a-429a-a6a9-56980139259a	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 08:22:28.949786+00	2025-09-12 08:22:28.949786+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
ac34c1a7-8bff-4836-b952-48b0cdade96e	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-14 07:11:23.278391+00	2025-09-14 08:06:36.673342+00	\N	aal1	\N	2025-09-14 08:06:36.673271	python-httpx/0.27.0	73.2.33.92	\N
2ee64cf8-a1a6-4053-a778-6ed2cc97aa1f	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 08:31:59.411793+00	2025-09-12 09:31:51.574464+00	\N	aal1	\N	2025-09-12 09:31:51.574381	python-httpx/0.27.0	73.2.33.92	\N
47387d9c-a03b-497c-92ca-c7e33d1436c3	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 10:29:04.804953+00	2025-09-12 10:29:04.804953+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
f716839c-35ab-48f0-92cb-6e0db330368a	bf250d15-2188-413b-b954-120a31ca5840	2025-09-05 06:41:54.118954+00	2025-09-14 18:36:28.288418+00	\N	aal1	\N	2025-09-14 18:36:28.288347	python-httpx/0.28.1	73.151.135.139	\N
4e2712c9-7762-4cab-87e4-dd95c76b0a9a	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 11:21:31.857077+00	2025-09-12 18:01:43.616559+00	\N	aal1	\N	2025-09-12 18:01:43.616488	python-httpx/0.27.0	73.2.33.92	\N
76140067-cb3f-43a6-9838-1229ba6a69ce	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 18:13:14.931471+00	2025-09-12 18:13:14.931471+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
e2d152b3-e4b6-4cc6-8c35-ade398896c11	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 19:01:28.963725+00	2025-09-12 19:01:28.963725+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
5f3dcba5-bc20-49f8-a141-b381f9feca61	bf250d15-2188-413b-b954-120a31ca5840	2025-09-14 18:36:57.525335+00	2025-09-14 18:43:14.959568+00	\N	aal1	\N	2025-09-14 18:43:14.959496	python-httpx/0.28.1	73.151.135.139	\N
83a8ae57-6717-4831-857e-6a3ea8165224	bf250d15-2188-413b-b954-120a31ca5840	2025-09-14 19:15:38.840275+00	2025-09-14 19:54:02.377447+00	\N	aal1	\N	2025-09-14 19:54:02.377373	python-httpx/0.28.1	73.151.135.139	\N
fb430cc6-333d-48ad-8632-86ef5ca510c8	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-15 02:05:12.401053+00	2025-09-15 02:05:12.401053+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.71.71.87	\N
230eb5c4-a702-4a81-a32f-31bc53ac82a6	bf250d15-2188-413b-b954-120a31ca5840	2025-09-14 19:17:08.165457+00	2025-09-14 19:17:08.165457+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
7f0c84ac-90b1-4149-ab8f-29fe67198d16	bf250d15-2188-413b-b954-120a31ca5840	2025-09-14 19:54:58.648683+00	2025-09-14 19:54:58.648683+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
905b2c4b-69fb-4d42-a89c-62e76b6e044b	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-14 22:11:26.695797+00	2025-09-15 07:32:26.775405+00	\N	aal1	\N	2025-09-15 07:32:26.775338	python-httpx/0.27.0	73.2.33.92	\N
b030bc4b-89dd-429d-8f1a-de455c3015eb	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-15 02:05:02.251007+00	2025-09-15 02:05:02.251007+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.71.71.87	\N
f17da7ad-4ba1-471d-a3d0-7225537f8aa5	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-14 09:31:44.611384+00	2025-09-14 22:00:06.22878+00	\N	aal1	\N	2025-09-14 22:00:06.228701	python-httpx/0.27.0	73.2.33.92	\N
981dcbe1-f199-4e65-abf9-c53beaf6637d	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-14 22:08:05.102384+00	2025-09-14 22:08:05.102384+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
e986b82b-50ec-4d86-839a-c345d3179c07	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-15 02:05:16.207955+00	2025-09-15 03:05:06.756731+00	\N	aal1	\N	2025-09-15 03:05:06.755595	python-httpx/0.28.1	73.71.71.87	\N
0eca28be-4686-4dd3-887d-49f56060f062	1dc56294-d8f6-4fc9-984a-6d176d125856	2025-09-15 07:05:54.801107+00	2025-09-15 07:05:54.801107+00	\N	aal1	\N	\N	python-httpx/0.28.1	207.231.76.218	\N
76367272-6b3c-4059-8faf-3ae7f807ecf9	1dc56294-d8f6-4fc9-984a-6d176d125856	2025-09-15 07:51:24.581926+00	2025-09-15 23:19:00.951841+00	\N	aal1	\N	2025-09-15 23:19:00.951775	python-httpx/0.28.1	207.231.76.218	\N
b645d2ad-52f2-4f09-859b-7afa13adc3a9	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-15 08:09:29.638973+00	2025-09-15 08:09:29.638973+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
ce51c5d5-8061-4ef9-a7dd-9725b3bc4477	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-15 08:23:40.129953+00	2025-09-15 08:23:40.129953+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
f6553552-7c87-4bcb-a859-3a48870d116c	1dc56294-d8f6-4fc9-984a-6d176d125856	2025-09-15 06:23:33.053185+00	2025-09-16 04:00:39.914972+00	\N	aal1	\N	2025-09-16 04:00:39.913653	python-httpx/0.28.1	207.231.76.218	\N
ecbccb35-5476-4d47-8146-3e7859417cd4	1dc56294-d8f6-4fc9-984a-6d176d125856	2025-09-15 23:19:23.360446+00	2025-09-16 03:18:48.10133+00	\N	aal1	\N	2025-09-16 03:18:48.101263	python-httpx/0.28.1	207.231.76.218	\N
43a1d000-fa65-49bf-9581-9a0028e132ab	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-16 16:32:31.854733+00	2025-09-16 18:06:51.827789+00	\N	aal1	\N	2025-09-16 18:06:51.827721	python-httpx/0.28.1	73.71.71.87	\N
5a07f556-71c5-48b4-9ae0-1882cc9d34db	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-16 03:09:55.103771+00	2025-09-16 04:09:45.817801+00	\N	aal1	\N	2025-09-16 04:09:45.817727	python-httpx/0.28.1	73.71.71.87	\N
60e6db0b-9148-4e3d-8fc6-6bcfc79505f6	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-15 08:14:04.64414+00	2025-09-15 10:38:28.233768+00	\N	aal1	\N	2025-09-15 10:38:28.2337	python-httpx/0.27.0	73.2.33.92	\N
3a6b85e2-1903-43ea-a0eb-fdf04dd3e96c	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-15 10:52:13.584081+00	2025-09-15 10:52:13.584081+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
f661643e-a468-42ce-b654-fc1a2e8d098c	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-15 11:12:06.7324+00	2025-09-15 11:12:06.7324+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
c0c21c5c-3898-46d3-8369-084efe12f2cc	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-15 11:17:26.46969+00	2025-09-15 11:17:26.46969+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
7e5094e9-81c6-4a62-abaf-6908e3a6a081	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-18 03:27:52.5803+00	2025-09-18 03:27:52.5803+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
45471ddd-1817-4460-bd43-1ea8df8ae99f	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-16 19:29:22.00386+00	2025-09-16 21:38:59.480718+00	\N	aal1	\N	2025-09-16 21:38:59.480636	python-httpx/0.28.1	73.71.71.87	\N
ba43f993-07b3-4b9d-817b-d1105c31ed8a	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-15 18:05:47.707547+00	2025-09-15 20:05:27.514655+00	\N	aal1	\N	2025-09-15 20:05:27.51459	python-httpx/0.28.1	73.71.71.87	\N
e79f7d9f-d2cb-4d6e-bb1e-095606cdb783	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-16 18:38:05.693597+00	2025-09-16 18:38:32.6218+00	\N	aal1	\N	2025-09-16 18:38:32.62173	python-httpx/0.28.1	73.71.71.87	\N
f352a10d-320a-47c1-a8b4-98d34b9d5940	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-15 21:09:40.487107+00	2025-09-15 23:15:39.009999+00	\N	aal1	\N	2025-09-15 23:15:39.008769	python-httpx/0.28.1	73.71.71.87	\N
dfd646ea-2159-4796-8833-60f9e2c2d65f	1dc56294-d8f6-4fc9-984a-6d176d125856	2025-09-16 04:01:07.558407+00	2025-09-16 05:03:45.78638+00	\N	aal1	\N	2025-09-16 05:03:45.78629	python-httpx/0.28.1	207.231.76.218	\N
38d3e981-380e-47e6-bd42-8a9e988fe778	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-15 19:17:07.294599+00	2025-09-17 11:21:39.665319+00	\N	aal1	\N	2025-09-17 11:21:39.665249	python-httpx/0.27.0	73.2.33.92	\N
de277f17-ceb3-426d-b990-b55199b0b0c6	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-16 02:02:34.300031+00	2025-09-16 05:52:39.314852+00	\N	aal1	\N	2025-09-16 05:52:39.314774	python-httpx/0.28.1	73.71.71.87	\N
b7702bbe-80d8-4ab8-9b8e-36d1df1a9fcf	1dc56294-d8f6-4fc9-984a-6d176d125856	2025-09-16 05:58:38.751711+00	2025-09-16 05:58:38.751711+00	\N	aal1	\N	\N	python-httpx/0.28.1	207.231.76.218	\N
5ceac1b5-dc39-46dd-b56f-63ea02d13f99	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-16 18:38:51.395423+00	2025-09-16 18:38:59.83152+00	\N	aal1	\N	2025-09-16 18:38:59.831424	python-httpx/0.28.1	73.71.71.87	\N
ae572a98-4030-4fc5-ad51-b5f899cc8f30	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-16 22:03:04.074776+00	2025-09-16 23:02:55.143796+00	\N	aal1	\N	2025-09-16 23:02:55.143721	python-httpx/0.28.1	73.71.71.87	\N
4cb8e984-0e7e-43d7-a1e7-0e97132e1b8e	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-16 18:47:10.311052+00	2025-09-16 18:47:18.390774+00	\N	aal1	\N	2025-09-16 18:47:18.390707	python-httpx/0.28.1	73.71.71.87	\N
9fa307ea-1bbb-4f3d-8c46-a29335e56982	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-16 06:16:00.567558+00	2025-09-16 08:01:27.655181+00	\N	aal1	\N	2025-09-16 08:01:27.655108	python-httpx/0.28.1	73.71.71.87	\N
2d8a65d9-fd7b-4fff-8802-3498e456b389	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-16 08:14:37.490361+00	2025-09-16 08:14:37.490361+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.71.71.87	\N
af1a1548-ef1a-4d2e-9797-febf86aa21aa	bf250d15-2188-413b-b954-120a31ca5840	2025-09-16 00:34:48.603175+00	2025-09-16 00:34:48.603175+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
4267d7c0-091c-467c-b153-6339c4ec6b93	bf250d15-2188-413b-b954-120a31ca5840	2025-09-16 00:50:22.411437+00	2025-09-16 00:50:22.411437+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
a0f895b3-d892-4034-a7e9-5906d8e2085a	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-16 18:48:18.170601+00	2025-09-16 18:49:28.574055+00	\N	aal1	\N	2025-09-16 18:49:28.573978	python-httpx/0.28.1	73.71.71.87	\N
fb3aa1ed-2104-49d0-8d5c-ffa6f7c2796a	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-15 23:43:39.352779+00	2025-09-16 00:57:56.323043+00	\N	aal1	\N	2025-09-16 00:57:56.322971	python-httpx/0.28.1	73.71.71.87	\N
ffa44850-ca30-4c58-a6fc-d771833667dc	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-16 08:23:46.773168+00	2025-09-16 16:06:34.274976+00	\N	aal1	\N	2025-09-16 16:06:34.274345	python-httpx/0.28.1	73.71.71.87	\N
306d892a-7a17-42b9-b223-f892f3161f68	c607bf29-70df-4b8d-9ffe-1f7329a76880	2025-09-26 22:39:16.331755+00	2025-09-26 22:39:16.331755+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.220.16.149	\N
20e5429d-b26f-49b4-ab5d-afeecf16af18	c607bf29-70df-4b8d-9ffe-1f7329a76880	2025-09-26 22:42:22.737191+00	2025-09-26 22:42:22.737191+00	\N	aal1	\N	\N	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36	98.89.240.228	\N
9ac5f24a-9bd9-4031-bf99-be35ae4fd9d0	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-16 23:43:39.874132+00	2025-09-19 03:30:47.253578+00	\N	aal1	\N	2025-09-19 03:30:47.253505	python-httpx/0.28.1	73.71.71.87	\N
ae732e60-c8e3-4228-afdb-7aa8adcfb974	78467702-b492-451b-a9f1-2059dbdd433e	2025-09-16 18:56:06.966198+00	2025-09-16 19:29:19.885512+00	\N	aal1	\N	2025-09-16 19:29:19.885444	python-httpx/0.28.1	73.71.71.87	\N
68144ade-084b-4a77-83f3-3b6dc183c592	c607bf29-70df-4b8d-9ffe-1f7329a76880	2025-09-26 22:43:51.512962+00	2025-09-26 22:43:51.512962+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.220.16.149	\N
33dfc82b-a471-4f29-9c3b-f74b730767ea	bf250d15-2188-413b-b954-120a31ca5840	2025-09-18 03:58:20.870174+00	2025-09-18 03:58:20.870174+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
cbf96df9-654c-4371-ac5f-8df35cc85703	bf250d15-2188-413b-b954-120a31ca5840	2025-09-18 05:32:54.764273+00	2025-09-18 06:20:02.098232+00	\N	aal1	\N	2025-09-18 06:20:02.098163	python-httpx/0.28.1	73.151.135.139	\N
e4de159c-a466-4f2c-b85c-ecb24e4e72aa	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-17 20:29:18.747869+00	2025-09-18 01:28:27.082785+00	\N	aal1	\N	2025-09-18 01:28:27.082708	python-httpx/0.27.0	45.80.187.80	\N
4796cb6f-ea55-4a9b-90a0-785f594b14bd	bf250d15-2188-413b-b954-120a31ca5840	2025-09-18 04:12:44.1844+00	2025-09-18 04:33:02.475376+00	\N	aal1	\N	2025-09-18 04:33:02.475304	python-httpx/0.28.1	73.151.135.139	\N
833d1385-ba1f-4557-9021-cac4e0c889a0	bf250d15-2188-413b-b954-120a31ca5840	2025-09-16 23:46:04.139904+00	2025-09-18 02:38:39.028987+00	\N	aal1	\N	2025-09-18 02:38:39.028901	python-httpx/0.28.1	73.151.135.139	\N
f52e50dc-6451-4aab-9300-5ee3d12aa663	bf250d15-2188-413b-b954-120a31ca5840	2025-09-18 02:49:26.518138+00	2025-09-18 02:49:26.518138+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
a59fc041-975e-40d8-b6b4-d2a234684e69	bf250d15-2188-413b-b954-120a31ca5840	2025-09-18 07:20:34.60417+00	2025-09-20 00:47:33.308075+00	\N	aal1	\N	2025-09-20 00:47:33.307975	python-httpx/0.28.1	73.151.135.139	\N
c2576234-3e34-493f-9d57-2cea5e39aa05	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-17 11:22:53.22043+00	2025-09-17 20:18:29.079684+00	\N	aal1	\N	2025-09-17 20:18:29.078365	python-httpx/0.27.0	73.2.33.92	\N
4528bae3-3f44-4e75-a3cd-654ace35ffc0	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-17 10:11:09.07068+00	2025-09-17 10:11:09.07068+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
e881b73c-0cde-4f35-bf6b-710e7ffb78c0	bf250d15-2188-413b-b954-120a31ca5840	2025-09-18 06:47:40.522701+00	2025-09-18 06:47:40.522701+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
bc3647d9-c7d0-4f53-bea8-8b9158cab35c	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-17 10:28:05.217977+00	2025-09-17 10:28:05.217977+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
89c141a2-771c-4a9e-8f6d-4f52416a71a7	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-18 01:58:23.689083+00	2025-09-18 02:58:14.316266+00	\N	aal1	\N	2025-09-18 02:58:14.316201	python-httpx/0.27.0	73.2.33.92	\N
02874424-dba7-4ae0-a20d-6e7796ddd1df	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-18 03:17:11.836112+00	2025-09-18 03:17:11.836112+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
046128ff-faa8-4529-b9c2-a78cb9d29349	bf250d15-2188-413b-b954-120a31ca5840	2025-09-18 04:33:25.178947+00	2025-09-18 05:25:10.821863+00	\N	aal1	\N	2025-09-18 05:25:10.821713	python-httpx/0.28.1	73.151.135.139	\N
28a8c730-a855-4703-a909-44ab4600f2e4	bf250d15-2188-413b-b954-120a31ca5840	2025-09-18 02:56:08.576847+00	2025-09-18 03:24:55.194346+00	\N	aal1	\N	2025-09-18 03:24:55.193602	python-httpx/0.28.1	73.151.135.139	\N
28cf8058-092a-4f12-bb42-0a6e8991cbea	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-18 03:27:28.360281+00	2025-09-18 03:27:28.360281+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
1451e5b3-46c3-4733-bc13-688bbe8d4919	c607bf29-70df-4b8d-9ffe-1f7329a76880	2025-09-26 22:55:35.454631+00	2025-09-26 22:55:35.454631+00	\N	aal1	\N	\N	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36	54.85.171.178	\N
6aea7bb2-7a28-4cf2-aaf4-59045b6449de	c607bf29-70df-4b8d-9ffe-1f7329a76880	2025-09-26 22:58:14.911636+00	2025-09-26 22:58:14.911636+00	\N	aal1	\N	\N	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36	44.216.66.238	\N
bfea420d-890e-439b-a343-8d1870d9e102	c607bf29-70df-4b8d-9ffe-1f7329a76880	2025-09-26 23:01:18.977063+00	2025-09-26 23:01:18.977063+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.220.16.149	\N
9fa5cb6d-9a4c-428a-8244-d06adc0ff85e	bf250d15-2188-413b-b954-120a31ca5840	2025-09-20 00:47:41.644084+00	2025-09-24 00:47:14.064372+00	\N	aal1	\N	2025-09-24 00:47:14.064301	python-httpx/0.28.1	73.151.135.139	\N
3e8ee467-5b06-4fa6-9fa8-ec1171a577b6	bf250d15-2188-413b-b954-120a31ca5840	2025-09-18 03:52:01.127536+00	2025-09-18 07:42:29.611772+00	\N	aal1	\N	2025-09-18 07:42:29.611706	python-httpx/0.28.1	73.151.135.139	\N
62e9c3b7-4827-4f2d-b3f9-5f0b4559313c	c607bf29-70df-4b8d-9ffe-1f7329a76880	2025-09-26 23:02:17.267724+00	2025-09-26 23:02:17.267724+00	\N	aal1	\N	\N	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36	52.202.42.97	\N
4212192e-cf57-4127-b5c4-8dad2a050b90	bf250d15-2188-413b-b954-120a31ca5840	2025-09-24 00:47:21.052581+00	2025-09-24 00:47:21.052581+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
0d8c0c02-2b51-4531-a204-f1191f5cc218	bf250d15-2188-413b-b954-120a31ca5840	2025-09-24 01:46:18.576489+00	2025-09-24 01:46:18.576489+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
fcfa0146-570f-4dc9-978f-452902ae3f5f	c607bf29-70df-4b8d-9ffe-1f7329a76880	2025-09-26 23:08:32.53278+00	2025-09-26 23:08:32.53278+00	\N	aal1	\N	\N	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36	44.194.229.12	\N
1c592d80-e271-4f25-973b-bf073c088cbd	c607bf29-70df-4b8d-9ffe-1f7329a76880	2025-09-26 23:09:57.994762+00	2025-09-26 23:09:57.994762+00	\N	aal1	\N	\N	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36	98.90.160.67	\N
eb7bd3b3-6106-42cc-bc2a-8919da90a8b4	c607bf29-70df-4b8d-9ffe-1f7329a76880	2025-09-26 23:15:08.496746+00	2025-09-26 23:15:08.496746+00	\N	aal1	\N	\N	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36	35.174.67.44	\N
942a51d2-470e-410f-aa70-f03d985658d3	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-29 03:43:58.97398+00	2025-09-29 03:43:58.97398+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
8b042945-b6f4-4887-a76c-9565c3c2327b	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 01:55:39.633207+00	2025-09-29 03:56:41.680072+00	\N	aal1	\N	2025-09-29 03:56:41.680003	python-httpx/0.28.1	73.2.23.248	\N
288094a8-de3b-45f4-9d5b-ff25f4eed972	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 04:01:50.682459+00	2025-09-29 04:01:50.682459+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.2.23.248	\N
126ff890-43f6-4cf5-9b58-c83af2d95205	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 04:03:44.804426+00	2025-09-29 04:03:44.804426+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.2.23.248	\N
07c2ba0b-4b7a-4580-8631-ce0cfd59b5be	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 04:16:11.61305+00	2025-09-29 04:16:11.61305+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.2.23.248	\N
40e19829-7ebc-49a5-8c00-67ebdcd4eeb8	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-27 20:12:52.565485+00	2025-09-27 20:13:07.912177+00	\N	aal1	\N	2025-09-27 20:13:07.912106	python-httpx/0.28.1	67.182.107.178	\N
066bf61d-4e0e-448b-94f5-f30011d17fa7	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-27 21:28:58.280013+00	2025-09-27 21:28:58.280013+00	\N	aal1	\N	\N	python-httpx/0.28.1	67.182.107.178	\N
d9d0793e-377e-4b2d-9855-f4b9f1585dc0	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 04:21:13.055071+00	2025-09-29 04:21:13.055071+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.2.23.248	\N
17d0de8c-131c-4812-8335-043e43a0ddea	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-27 21:55:41.951199+00	2025-09-28 03:27:17.735778+00	\N	aal1	\N	2025-09-28 03:27:17.735135	python-httpx/0.28.1	73.2.23.248	\N
e2698428-dc8e-4886-8f28-0b7b7fb866f8	1dc56294-d8f6-4fc9-984a-6d176d125856	2025-09-29 02:38:13.944804+00	2025-09-29 04:46:15.912715+00	\N	aal1	\N	2025-09-29 04:46:15.911442	python-httpx/0.28.1	207.231.76.218	\N
e56b6eb8-7d1d-4501-8474-a3b85e8a53a5	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 04:52:15.787095+00	2025-09-29 04:52:15.787095+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.2.23.248	\N
a478b1da-611c-422c-af62-5f8718cf9433	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 04:52:36.365617+00	2025-09-29 04:52:36.365617+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.2.23.248	\N
f503e6f2-6a96-4318-9133-6779f36469f1	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 04:52:38.28074+00	2025-09-29 04:52:38.28074+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.2.23.248	\N
9a8ef10a-14d6-4559-b587-c26b40618cb5	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-28 18:18:56.753829+00	2025-09-28 22:01:54.76647+00	\N	aal1	\N	2025-09-28 22:01:54.766398	python-httpx/0.28.1	73.2.23.248	\N
c5d90591-bf5b-4abf-ba1f-cc22844f2527	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 05:36:54.344052+00	2025-09-29 05:36:54.344052+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.2.23.248	\N
fc4fc8b3-d213-4a6b-bb9d-5cecb8ee85d2	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 05:36:56.525591+00	2025-09-29 05:37:00.182048+00	\N	aal1	\N	2025-09-29 05:37:00.181981	python-httpx/0.28.1	73.2.23.248	\N
d6f6c0ec-5577-475a-afb6-3c6ec9134da7	1dc56294-d8f6-4fc9-984a-6d176d125856	2025-09-29 05:20:52.003121+00	2025-09-29 06:20:44.542131+00	\N	aal1	\N	2025-09-29 06:20:44.542061	python-httpx/0.28.1	207.231.76.218	\N
3b6a6ad8-d19b-42d6-be4b-f7d59757ad8f	1dc56294-d8f6-4fc9-984a-6d176d125856	2025-09-29 06:22:49.769782+00	2025-09-29 06:22:49.769782+00	\N	aal1	\N	\N	python-httpx/0.28.1	207.231.76.218	\N
d586d7e6-5428-4c91-8fd2-19d522a98a1f	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 05:39:04.962578+00	2025-09-29 06:39:58.850086+00	\N	aal1	\N	2025-09-29 06:39:58.849998	python-httpx/0.28.1	73.2.23.248	\N
1cc4ef10-f2e9-4df9-88cf-afba444b7592	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-29 04:40:32.363888+00	2025-09-29 06:40:15.455847+00	\N	aal1	\N	2025-09-29 06:40:15.455773	python-httpx/0.27.0	73.2.33.92	\N
c26859af-aa74-4c16-953d-73bd7eaf905d	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 06:43:40.835741+00	2025-09-29 06:43:40.835741+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.2.23.248	\N
7a2d5f1b-2bd6-415d-a942-f08c72628d28	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 06:57:46.398036+00	2025-09-29 19:33:08.094046+00	\N	aal1	\N	2025-09-29 19:33:08.093347	python-httpx/0.28.1	73.2.23.248	\N
725cd264-5811-4e1d-b9a8-3e00696ca092	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-28 22:02:33.684916+00	2025-09-29 01:18:11.943153+00	\N	aal1	\N	2025-09-29 01:18:11.943074	python-httpx/0.28.1	73.2.23.248	\N
84eaf787-0d12-4a76-906d-35d89f1551b7	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 01:18:16.31348+00	2025-09-29 01:18:16.31348+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.2.23.248	\N
ef632746-7bd6-4459-a497-06e7df6f1046	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 01:18:56.818737+00	2025-09-29 01:18:56.818737+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.2.23.248	\N
d9a70e68-8fc2-452f-8a23-5d982be83ec2	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 01:52:20.379707+00	2025-09-29 01:52:20.379707+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.2.23.248	\N
903b85d5-f326-4dae-b496-1f46328f31a6	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 01:55:24.105347+00	2025-09-29 01:55:24.105347+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.2.23.248	\N
5a41f105-4990-4ef1-88ac-82b2bbc00d04	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 01:55:27.067099+00	2025-09-29 01:55:27.067099+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.2.23.248	\N
2c7c85b8-be0f-48d8-b075-49f62c720f54	1dc56294-d8f6-4fc9-984a-6d176d125856	2025-09-29 01:58:48.670922+00	2025-09-29 02:38:08.410033+00	\N	aal1	\N	2025-09-29 02:38:08.409965	python-httpx/0.28.1	207.231.76.218	\N
c069bef0-ef33-42b6-927d-78c318f7db27	05498f83-18ab-4ba9-b663-767df738a0da	2025-09-29 19:33:08.658599+00	2025-09-29 19:33:08.658599+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.2.23.248	\N
805cebc3-d1ff-4b9f-a5df-39ccd4542414	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-18 03:47:24.835245+00	2025-09-29 03:43:52.842992+00	\N	aal1	\N	2025-09-29 03:43:52.842911	python-httpx/0.27.0	73.2.33.92	\N
64a6b0e6-a071-4930-a370-1db3357d6ba9	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-29 07:05:54.290487+00	2025-09-29 20:04:33.400051+00	\N	aal1	\N	2025-09-29 20:04:33.39998	python-httpx/0.27.0	73.2.33.92	\N
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	bf250d15-2188-413b-b954-120a31ca5840	authenticated	authenticated	mikefeschenko@yahoo.com	$2a$10$4S/tF085PY7b3EcCYfSVruQl/Gh2MBF8dYGsTt6/YipivEtgC3686	2025-03-26 18:53:16.04825+00	\N		\N		\N			\N	2025-09-24 01:46:18.575814+00	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2025-03-26 18:53:15.988504+00	2025-09-24 01:46:18.611035+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	c607bf29-70df-4b8d-9ffe-1f7329a76880	authenticated	authenticated	corbinwest@csus.edu	$2a$10$/uBmJjtkxab9aZvNQFNJXOaOOTMbtFQpun1Iq/57fvC0I/wC6P3Fm	2025-09-26 22:05:34.986244+00	\N		\N		2025-09-26 23:15:04.10477+00			\N	2025-09-26 23:15:08.496032+00	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2025-09-26 22:05:34.942926+00	2025-09-26 23:15:08.508336+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	78467702-b492-451b-a9f1-2059dbdd433e	authenticated	authenticated	faithmontemayor@csus.edu	$2a$10$YJ40FSD2Jj8Km.CtlFLmFOGHv8kNcwNrUHmaM/WHFOeCgPWy7niGq	2025-09-15 02:03:38.677234+00	\N		\N		\N			\N	2025-09-16 23:43:39.873376+00	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2025-09-15 02:03:38.631795+00	2025-09-19 03:30:47.252394+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	05498f83-18ab-4ba9-b663-767df738a0da	authenticated	authenticated	xiangfeng@csus.edu	$2a$10$x2WNDCsIRluxr0A0G1ZeVu7qPzmqN8ZD1QLYPsA0ZL/5t9Qat/aLK	2025-09-27 20:00:34.630173+00	\N		\N		\N			\N	2025-09-29 19:33:08.657971+00	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2025-09-27 20:00:34.561043+00	2025-09-29 19:33:08.668823+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	1dc56294-d8f6-4fc9-984a-6d176d125856	authenticated	authenticated	phernandez4@csus.edu	$2a$10$a7IawhirdLpMJwtVZnvfi.rU3tP4FyMO76xJxevuF84NiUsnzJzrS	2025-09-15 06:08:36.441731+00	\N		\N		\N			\N	2025-09-29 06:22:49.76909+00	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2025-09-15 06:08:36.428595+00	2025-09-29 06:22:49.783592+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3d05eadb-9eb9-4368-8928-87ccd7783f32	authenticated	authenticated	nguyenphuctran@csus.edu	$2a$10$9kRVXnt.pc/FcdYECD5NMuETcvVxGVwdVOp2vSev12A4vjPOLpbUy	2025-03-22 07:52:49.13657+00	\N		\N		\N			\N	2025-09-29 07:05:54.290406+00	{"role": "super-admin", "provider": "email", "providers": ["email"]}	{"sub": "3d05eadb-9eb9-4368-8928-87ccd7783f32", "email": "nguyenphuctran@csus.edu", "email_verified": true, "phone_verified": false}	\N	2025-03-22 07:51:10.77988+00	2025-09-29 20:04:33.398898+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: key; Type: TABLE DATA; Schema: pgsodium; Owner: supabase_admin
--

COPY pgsodium.key (id, status, created, expires, key_type, key_id, key_context, name, associated_data, raw_key, raw_key_nonce, parent_key, comment, user_data) FROM stdin;
\.


--
-- Data for Name: ai_detections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ai_detections (id, session_id, camera_id, room_id, detection_type, confidence_score, detection_data, detected_patient_id, patient_biometrics, frame_timestamp, sequence_number, model_used, processing_time_ms, processed_on, created_at) FROM stdin;
\.


--
-- Data for Name: ambulance_streaming_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ambulance_streaming_sessions (id, ambulance_id, session_name, session_type, is_active, incident_id, priority_level, call_type, origin_location, destination_location, route_data, detected_patients, patient_count, started_at, ended_at, duration_minutes, avg_connection_quality, total_cameras_used, data_transferred_mb, notes, created_at, updated_at, created_by) FROM stdin;
\.


--
-- Data for Name: ambulances; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ambulances (id, ambulance_number, license_plate, vehicle_model, manufacturer, year_manufactured, status, current_location, assigned_hospital_id, assigned_team, equipment_list, camera_count, max_camera_capacity, mileage, last_maintenance, next_maintenance, insurance_info, notes, created_at, updated_at, created_by) FROM stdin;
4d0f9016-8a7f-41a0-9c62-14f32d1f9ce7	AMB-003	EMR-003	Advanced Life Support	Chevrolet	2024	active	\N	\N	\N	["advanced_cardiac_monitor", "intubation_kit", "surgical_kit"]	0	8	\N	\N	\N	\N	\N	2025-09-29 20:28:10.230926+00	2025-09-29 20:28:10.230926+00	\N
8f2dcf09-b8fa-480a-8bfa-aeab49b3dd57	AMB-001	EMR-001	Sprinter Ambulance	Mercedes-Benz	2023	active	\N	\N	\N	["defibrillator", "ventilator", "patient_monitor", "oxygen_tank"]	4	6	\N	\N	\N	\N	\N	2025-09-29 20:28:10.230926+00	2025-09-29 20:28:10.230926+00	\N
0ba08402-937b-47cb-9385-417fd471b6da	AMB-002	EMR-002	Type III Ambulance	Ford	2022	active	\N	\N	\N	["defibrillator", "stretcher", "iv_equipment", "medication_kit"]	3	4	\N	\N	\N	\N	\N	2025-09-29 20:28:10.230926+00	2025-09-29 20:28:10.230926+00	\N
\.


--
-- Data for Name: camera_streaming_rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.camera_streaming_rooms (id, session_id, camera_id, room_id, device_name, connected, connection_started_at, connection_ended_at, last_seen, current_fps, current_bitrate, packet_loss_rate, latency_ms, ai_processing_active, detections_count, last_detection_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: cameras; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cameras (id, camera_id, ambulance_id, camera_name, camera_type, position_in_ambulance, device_model, resolution, max_fps, has_night_vision, has_audio, mac_address, ip_address, streaming_port, rtc_config, status, last_seen, connection_quality, ai_enabled, detection_types, processing_mode, installation_date, warranty_expires, notes, created_at, updated_at) FROM stdin;
c1f91ff4-3425-4030-ac78-ef955806553d	AMB-001-CAM-01	8f2dcf09-b8fa-480a-8bfa-aeab49b3dd57	Patient Area Camera	medical	patient-area	Raspberry Pi Camera v3	1920x1080	30	f	t	AA:BB:CC:DD:EE:11	\N	8000	\N	active	\N	\N	t	["pose", "movement", "activity"]	edge	\N	\N	\N	2025-09-29 20:28:10.230926+00	2025-09-29 20:28:10.230926+00
1ade6513-e0b4-4495-a6e4-c6cb6054fb03	AMB-001-CAM-02	8f2dcf09-b8fa-480a-8bfa-aeab49b3dd57	Equipment Monitor	surveillance	equipment-bay	Raspberry Pi Camera v3	1920x1080	30	f	t	AA:BB:CC:DD:EE:12	\N	8000	\N	active	\N	\N	t	["pose", "movement", "activity"]	edge	\N	\N	\N	2025-09-29 20:28:10.230926+00	2025-09-29 20:28:10.230926+00
8cb31367-6b1b-416d-b00b-081f3dc2a43a	AMB-001-CAM-03	8f2dcf09-b8fa-480a-8bfa-aeab49b3dd57	Dashboard Camera	dashboard	dashboard	Raspberry Pi Camera v3	1920x1080	30	f	t	AA:BB:CC:DD:EE:13	\N	8000	\N	active	\N	\N	t	["pose", "movement", "activity"]	edge	\N	\N	\N	2025-09-29 20:28:10.230926+00	2025-09-29 20:28:10.230926+00
df800cf4-acb0-47bf-9e6a-a409f3c2f2a0	AMB-001-CAM-04	8f2dcf09-b8fa-480a-8bfa-aeab49b3dd57	Rear Door Camera	exterior	rear-exterior	Raspberry Pi Camera v3	1920x1080	30	f	t	AA:BB:CC:DD:EE:14	\N	8000	\N	active	\N	\N	t	["pose", "movement", "activity"]	edge	\N	\N	\N	2025-09-29 20:28:10.230926+00	2025-09-29 20:28:10.230926+00
0d7868cd-659f-454a-b0c9-d0e188eca463	AMB-002-CAM-01	0ba08402-937b-47cb-9385-417fd471b6da	Main Patient Camera	medical	patient-area	Raspberry Pi Camera v3	1920x1080	30	f	t	AA:BB:CC:DD:FF:21	\N	8000	\N	active	\N	\N	t	["pose", "movement", "activity"]	edge	\N	\N	\N	2025-09-29 20:28:10.230926+00	2025-09-29 20:28:10.230926+00
61b11cf6-2efd-4b43-9c6a-7b0f0e688e38	AMB-002-CAM-02	0ba08402-937b-47cb-9385-417fd471b6da	Front Cabin Camera	medical	front-cabin	Raspberry Pi Camera v3	1920x1080	30	f	t	AA:BB:CC:DD:FF:22	\N	8000	\N	active	\N	\N	t	["pose", "movement", "activity"]	edge	\N	\N	\N	2025-09-29 20:28:10.230926+00	2025-09-29 20:28:10.230926+00
ef2429a1-29d1-41c6-9c93-bc8bdf0abd43	AMB-002-CAM-03	0ba08402-937b-47cb-9385-417fd471b6da	Side Equipment Camera	medical	side-equipment	Raspberry Pi Camera v3	1920x1080	30	f	t	AA:BB:CC:DD:FF:23	\N	8000	\N	active	\N	\N	t	["pose", "movement", "activity"]	edge	\N	\N	\N	2025-09-29 20:28:10.230926+00	2025-09-29 20:28:10.230926+00
\.


--
-- Data for Name: doctor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.doctor (id, first_name, middle_name, last_name, specialization, email, primary_phone, created_at, updated_at) FROM stdin;
d86f06ec-fd0a-42a7-872c-e8224a4b18f1	Henry	\N	MD	neurosurgeon	henryMD@fakeemail.com	9167777777	2025-04-19 17:21:38+00	2025-04-19 17:21:44.882569
\.


--
-- Data for Name: medical_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medical_history (id, patient_id, doctor_id, diagnosis, note, created_at, updated_at) FROM stdin;
3fcc6674-23ec-4686-92d5-18ede67eb60c	0cabaa76-b0cb-4785-ae2a-9b5e96739ae3	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	you also have gingevitis	im sorry ):, it really sucks\n	2025-04-19 18:42:22.146275+00	2025-04-19 18:42:22.146275
368a76e8-f765-43de-accc-917ab19a923b	0cabaa76-b0cb-4785-ae2a-9b5e96739ae3	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	hello world	not just a note boys	2025-04-19 18:48:56.242765+00	2025-04-19 18:48:56.242765
47f76659-a404-4302-9571-a98505061c98	2e478e2e-7157-4fae-b5ef-c91973c83c8d	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	we edited this	cool =	2025-04-19 18:53:01.060203+00	2025-04-19 18:53:01.060203
7682c32a-e32f-49d5-b894-dd138a4996b8	0cabaa76-b0cb-4785-ae2a-9b5e96739ae3	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	aa	aa	2025-04-19 19:19:15.010333+00	2025-04-19 19:19:15.010333
2e93c1bc-1564-4bfd-88c5-dcf3b6c593d8	0cabaa76-b0cb-4785-ae2a-9b5e96739ae3	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	bad brain	wow new updated note x2 database style x4\n	2025-04-19 17:22:28.291222+00	2025-04-19 17:22:28.291222
67a9be32-ed11-4fb5-a659-06dad817f9e9	83ecf258-863d-4a22-b0d2-58a215afcdc1	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	its not good	shes doneso	2025-04-19 19:45:12.232722+00	2025-04-19 19:45:12.232722
3eb6401e-3ab8-42a2-a516-fc753ba7c722	7af46bd0-934f-4f03-8c73-0fe3d68677b3	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	big brain	brainitis	2025-04-20 23:19:23.602488+00	2025-04-20 23:19:23.602488
6a94ef84-5d46-4b68-bb88-d2ad511d26cd	7af46bd0-934f-4f03-8c73-0fe3d68677b3	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	mom	wow	2025-04-20 23:20:16.205974+00	2025-04-20 23:20:16.205974
07a9b103-7881-47f6-b22c-71da7a35711f	7af46bd0-934f-4f03-8c73-0fe3d68677b3	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	string	string	2025-04-20 23:21:56.980717+00	2025-04-20 23:21:56.980717
48d438f1-1faa-420f-9ec4-a696f76c8173	15d58fbc-2fdb-4b97-b63f-2e84a0c3b50c	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	hmmmm	some notes	2025-09-05 01:19:53.053612+00	2025-09-05 01:19:53.053612
eb7f8b72-7dbb-46c7-9d0a-3dd1ba04a11c	64f695c4-9909-40ba-8374-e74f6b3a5df0	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	wowzer	ok ok	2025-09-05 05:26:38.4464+00	2025-09-05 05:26:38.4464
13f8a37d-b594-4a04-9344-9cd34ad4fa84	64f695c4-9909-40ba-8374-e74f6b3a5df0	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	who cares about me?	no-one	2025-09-05 05:26:59.477195+00	2025-09-05 05:26:59.477195
a3e75758-985d-4086-a167-c792ef8e552c	64f695c4-9909-40ba-8374-e74f6b3a5df0	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	will anyone see this?	not likely	2025-09-05 05:27:16.037868+00	2025-09-05 05:27:16.037868
74544179-c34f-4ffc-ae2e-8cae534af051	0eab151a-e6c8-486b-940e-554736135cb5	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	hmmm	ok then	2025-09-05 05:27:33.658822+00	2025-09-05 05:27:33.658822
a251c004-4d30-422c-9a7d-5a43d0b31a3f	0cabaa76-b0cb-4785-ae2a-9b5e96739ae3	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	hello	test uh ok	2025-09-14 19:34:10.421871+00	2025-09-14 19:34:10.421871
97d9bde0-3f11-4459-8d31-e4a9503d99bf	6f006438-8301-4364-bbf9-88f07cda6530	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	wowzer	sdasdwoiw	2025-09-16 00:48:57.57802+00	2025-09-16 00:48:57.57802
\.


--
-- Data for Name: note; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.note (id, created_at, content, patient_id, video_id, author, timestamp_seconds, updated_at) FROM stdin;
4d8cc01c-29b2-4408-9c3e-51af87875dca	2025-04-19 21:02:10.430486+00	Tremor appears to have subsided.	e9d03106-b91b-400b-9e62-433815125368	25273293-c532-4bd2-9ccf-e57dfd94c8bf	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	75	2025-04-19 21:02:10.430486
b9858da9-12e8-4a4f-b0b5-e998316da2ce	2025-04-19 21:04:48.555642+00	Decerebrate posturing observed during transport	60ed81da-0d98-4283-9f33-c9af7cd06147	437401d0-674e-45b9-a175-ff0c7de449fb	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	33	2025-04-19 21:04:48.555642
663da413-3f50-473f-8e7f-a8075107028d	2025-04-21 04:42:22.497718+00	hello	2180abd2-1a06-4c37-bb00-627b28b58442	25273293-c532-4bd2-9ccf-e57dfd94c8bf	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	194.730902	2025-04-21 04:42:22.497718
ff1585f1-0c52-4f2b-ab17-9ac997a71ecb	2025-09-02 02:20:45.380878+00	fff	2180abd2-1a06-4c37-bb00-627b28b58442	25273293-c532-4bd2-9ccf-e57dfd94c8bf	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	150.017651	2025-09-02 02:20:45.380878
33084fbb-afef-4a5b-88c3-a726dc0efc7e	2025-09-02 02:25:07.835752+00	hihgbiygiuyg	0cabaa76-b0cb-4785-ae2a-9b5e96739ae3	8513c73d-6e90-4968-8401-85b71aa208a6	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	83.113968	2025-09-02 02:25:07.835752
fe527cf8-9801-4f53-a370-c29e60103203	2025-09-15 21:11:39.737645+00	Note for Arley 	11b588ef-5dfb-49b6-82bb-253752f1c119	59ed9078-a1e6-44fa-b232-bf5c318cb601	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	\N	2025-09-15 21:11:39.737645
10381f95-9b21-4723-b11d-15f3f119db10	2025-09-16 06:21:53.428769+00	new note for stephan dows\n	2e478e2e-7157-4fae-b5ef-c91973c83c8d	e6d01a85-8e5a-4d84-8556-fc19fdb9c11f	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	\N	2025-09-16 06:21:53.428769
ec0656e5-c2ca-4079-b6c8-d92b34d8b7a5	2025-09-16 08:16:07.962222+00	adding a time stamp to 3:12 (3:07 on timer video) for wrennie	60ed81da-0d98-4283-9f33-c9af7cd06147	437401d0-674e-45b9-a175-ff0c7de449fb	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	\N	2025-09-16 08:16:07.962222
1e0a8de8-6f53-4445-a61f-2ba90074ea89	2025-09-16 17:02:17.110432+00	adding note for pearla	15d58fbc-2fdb-4b97-b63f-2e84a0c3b50c	64c4258c-dd8d-4388-af16-5675865d28f8	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	\N	2025-09-16 17:02:17.110432
7f275ebc-487e-4025-9d92-fc169de22455	2025-09-16 17:07:50.654881+00	new notee\n	15d58fbc-2fdb-4b97-b63f-2e84a0c3b50c	64c4258c-dd8d-4388-af16-5675865d28f8	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	\N	2025-09-16 17:07:50.654881
3f597fc3-4a19-4a5e-b87e-54f631f43d95	2025-09-16 17:14:34.008667+00	123	15d58fbc-2fdb-4b97-b63f-2e84a0c3b50c	64c4258c-dd8d-4388-af16-5675865d28f8	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	\N	2025-09-16 17:14:34.008667
7e6eb0ae-0f9f-43ed-9cba-dd9770f6b44c	2025-09-16 18:57:06.908866+00	Detection on video 2\n	6f006438-8301-4364-bbf9-88f07cda6530	180e15ab-7671-414b-bb1f-e99986b52a87	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	121.214862	2025-09-16 18:57:06.908866
7a99c6f3-163f-4f6b-968e-199e3792ab04	2025-09-16 22:16:15.048484+00	note for Carmelle Fryd	83ecf258-863d-4a22-b0d2-58a215afcdc1	043db1d5-7526-49dd-ae9b-476d9b7b4242	d86f06ec-fd0a-42a7-872c-e8224a4b18f1	59.939105	2025-09-16 22:16:15.048484
\.


--
-- Data for Name: patient_event; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_event (id, type, confidence, validation_status, created_at, video_id, "timestamp") FROM stdin;
3203a6d5-7286-4abe-89e3-aacd7f9dbffc	tremor	95	pending	2025-04-21 01:23:59.632322+00	25273293-c532-4bd2-9ccf-e57dfd94c8bf	30
ce8d1307-0a27-482f-be02-fe854a44cf01	decerebrate	92	confirmed	2025-09-16 16:46:55.02977+00	64c4258c-dd8d-4388-af16-5675865d28f8	127
1ce8b42a-d166-48cd-b5f3-5f12bc6afd97	tremor	71	confirmed	2025-09-16 16:46:55.02977+00	64c4258c-dd8d-4388-af16-5675865d28f8	198
39ac5f4a-ab8f-4880-b9fc-59dd8227ede8	myoclonus	79	pending	2025-09-16 16:46:55.02977+00	64c4258c-dd8d-4388-af16-5675865d28f8	43
c25744d4-8564-4a09-a532-1d0ef9d8c779	tremor	68	pending	2025-09-16 18:52:50.72449+00	60dc4352-588c-49c1-a599-fcefffe83ff8	95
07bcc2b3-378b-48d0-a1e9-9bcbb110ad0d	myoclonus	73	pending	2025-09-16 18:52:50.72449+00	e03d79ea-ccf0-46bc-99ac-f5c8c0e8c3ef	61
e5b0f0a1-ca97-40cc-af93-c9ce8caba190	tremor	65	pending	2025-09-16 18:52:50.72449+00	b1cfb1f3-7d43-45c1-a670-d12d069b0ab6	138
2ac460ef-3599-4e83-8fbf-fef0b93eefcb	tremor	74	pending	2025-09-16 18:52:50.72449+00	8be2f72a-c89d-4f7a-879f-4474ce77f4f4	136
b58ecf74-7b2b-4264-b5f0-db8db9520921	tremor	83	pending	2025-09-16 18:52:50.72449+00	e7da892b-ef54-43c5-9ced-81808a1a55bf	125
d854e93e-26bc-44fd-ac03-da242d7300f0	abnormal_movement	77	pending	2025-09-16 18:52:50.72449+00	6b41f451-f08f-4513-8b5d-c2c1c446d8f1	127
e44e7686-6202-46d2-b14e-fbe74337dfcd	tremor	89	pending	2025-09-16 18:52:50.72449+00	fc20be51-6472-41df-863b-271a5c450cf5	138
6d59f80b-477a-4aa7-985e-4d1bee1ea88c	abnormal_movement	88	pending	2025-09-16 18:52:50.72449+00	571d498f-70d3-4d2c-bdf2-75a598484100	64
bff9c3eb-f371-4864-8135-c67c2899850b	myoclonus	74	pending	2025-09-16 18:52:50.72449+00	043db1d5-7526-49dd-ae9b-476d9b7b4242	145
ed7aa1f1-e609-4dbd-9bca-0c66a3966ac7	abnormal_movement	88	pending	2025-09-16 18:52:50.72449+00	ff87e084-90d8-4b6b-a998-c7547ce73761	118
559404c5-4bb9-4a36-babe-499105d6c3a4	tremor	71	pending	2025-09-16 18:52:50.72449+00	c67c7d3b-40f4-44b0-85b9-522bc92ad907	179
3fe1f981-03cf-4a8c-887e-72f0c1707a02	tremor	86	pending	2025-09-16 18:52:50.72449+00	3eb203d5-59d8-4cbd-9501-7dfbd3177d6e	68
7da46285-a318-4c50-a99d-246f45e23ba6	abnormal_movement	74	pending	2025-09-16 18:52:50.72449+00	4212b08a-bd28-401e-aae3-c3a3b0437d4e	46
b2070846-d200-4aea-9c05-b9d2c7b3b88e	myoclonus	77	pending	2025-09-16 18:52:50.72449+00	e8e14abc-72ef-40f0-ba9b-1d948dc9afa2	78
124e7b2a-0554-4309-b9b3-31394a8ce5cd	abnormal_movement	81	pending	2025-09-16 18:52:50.72449+00	57fb9487-f278-45ea-8cda-dd649c5230f9	165
d80c174e-d775-42dc-8561-54a66d6acb63	tremor	72	pending	2025-09-16 18:52:50.72449+00	056d59e2-6c7c-4607-9e9a-d4a7c74032c8	157
38ec53f5-06c6-45e6-9d2c-4c3c906d33eb	myoclonus	76	pending	2025-09-16 18:52:50.72449+00	e6b5d47d-804e-408b-9fc6-eea7c865c0dd	84
1856100d-62ab-4fe9-a68f-889901903361	tremor	78	pending	2025-09-16 18:52:50.72449+00	f194cdd8-a5b7-4cde-bfcc-bb8461c04851	56
b9b71c9b-3cd9-4b39-93e1-9ee4c5d2bb8f	tremor	78	pending	2025-09-16 18:52:50.72449+00	300479dd-8999-4963-8e97-85fc8fe36bd2	130
2679fb4b-ddf4-40cc-acb5-c9ba6a988420	tremor	74	pending	2025-09-16 18:52:50.72449+00	79842dbe-2401-4720-93f8-3b1411470296	175
c8e3d572-8842-4de3-a1f1-907dc2d7d43b	decerebrate	78	pending	2025-09-16 18:52:50.72449+00	e2bbab7c-98b0-4967-8f0a-81772a721061	124
55fca975-dff4-447a-a864-90aab3c7cfc0	abnormal_movement	78	pending	2025-09-16 18:52:50.72449+00	c1915d75-6e57-4ce1-8d32-83b6facb30df	174
c853abc2-29ea-482c-b5bd-3f59e563ac22	abnormal_movement	80	pending	2025-09-16 18:52:50.72449+00	9ea86dda-334e-4a56-a3f7-3b9e660a2df8	127
49d019bb-17dc-4d13-92c5-fa1199a95e57	myoclonus	81	pending	2025-09-16 18:52:50.72449+00	d0464db3-044e-4207-becf-eec47f79bf44	33
f0fe78e0-f495-404b-9890-f9f497fbe04d	decerebrate	66	pending	2025-09-16 18:52:50.72449+00	7b594f0e-6cde-4361-8735-37bfe9b79492	157
7e5e0453-1efa-4e8f-8778-7d2f1f78bcda	tremor	85	pending	2025-09-16 16:46:55.02977+00	8513c73d-6e90-4968-8401-85b71aa208a6	45
71301e2f-a5d7-4b0f-9349-64c786db3ff4	myoclonus	72	pending	2025-09-16 16:46:55.02977+00	8513c73d-6e90-4968-8401-85b71aa208a6	98
b6ba7059-69b4-457c-b01e-0789d357cb7c	abnormal_movement	90	confirmed	2025-09-16 16:46:55.02977+00	8513c73d-6e90-4968-8401-85b71aa208a6	142
4d282a7e-4832-4ece-82c3-e152f28ab842	decerebrate	88	pending	2025-09-16 16:46:55.02977+00	59ed9078-a1e6-44fa-b232-bf5c318cb601	67
5bf81573-972f-44df-8a78-89835eb236d6	tremor	76	dismissed	2025-09-16 16:46:55.02977+00	59ed9078-a1e6-44fa-b232-bf5c318cb601	134
3987ddee-c052-4c20-8a39-ee05f7387de9	seizure	94	confirmed	2025-09-16 16:46:55.02977+00	59ed9078-a1e6-44fa-b232-bf5c318cb601	189
82b41d8d-c563-4541-86ff-5ee2f6cde8f2	myoclonus	68	pending	2025-09-16 16:46:55.02977+00	59ed9078-a1e6-44fa-b232-bf5c318cb601	221
d34dcf4e-8d40-4a31-bcd8-4307febd8d0a	abnormal_movement	77	pending	2025-09-16 16:46:55.02977+00	437401d0-674e-45b9-a175-ff0c7de449fb	198
c4a97ce7-6511-4cde-8f46-6ccc57a5ebda	myoclonus	85	pending	2025-09-16 16:46:55.02977+00	437401d0-674e-45b9-a175-ff0c7de449fb	267
382f5de9-2b9c-48d8-8554-f82311125cf1	decerebrate	73	dismissed	2025-09-16 16:46:55.02977+00	437401d0-674e-45b9-a175-ff0c7de449fb	289
c680e1a5-da45-46d4-8a5b-6bbdf9bec1eb	seizure	96	confirmed	2025-09-16 16:46:55.02977+00	25273293-c532-4bd2-9ccf-e57dfd94c8bf	78
1a25af45-58b6-4177-9584-0342b29a699f	tremor	84	pending	2025-09-16 16:46:55.02977+00	25273293-c532-4bd2-9ccf-e57dfd94c8bf	156
a2eac9cb-dd1c-4600-bc11-036b723e3ded	myoclonus	69	pending	2025-09-16 16:46:55.02977+00	25273293-c532-4bd2-9ccf-e57dfd94c8bf	203
46d833cb-41ef-4718-98e8-7e5ae94aa0e8	decorticate	87	pending	2025-09-16 16:46:55.02977+00	c12fc43a-f943-48aa-8520-873b2af3bf6b	92
66662b98-6531-4466-ac13-7e983e2275e2	abnormal_movement	75	confirmed	2025-09-16 16:46:55.02977+00	c12fc43a-f943-48aa-8520-873b2af3bf6b	164
ae721c9f-5264-4ffb-89ff-02f0cf81825b	tremor	83	pending	2025-09-16 16:46:55.02977+00	c12fc43a-f943-48aa-8520-873b2af3bf6b	245
711b6e83-3f7a-412f-b170-4ae4e2d66420	seizure	89	pending	2025-09-16 16:46:55.02977+00	3bb55180-0bb0-4f34-acd5-ef212aaa36f3	56
b0043e7e-da0b-40a3-974c-ac9d2d44568f	abnormal_movement	74	pending	2025-09-16 16:46:55.02977+00	3bb55180-0bb0-4f34-acd5-ef212aaa36f3	178
6a94d80f-397f-47a3-9730-e31019098e6e	decorticate	86	confirmed	2025-09-16 16:46:55.02977+00	3bb55180-0bb0-4f34-acd5-ef212aaa36f3	234
2ceb5d0f-19bf-4c21-9f9c-c1ee0a1ed5c9	tremor	88	pending	2025-09-16 16:46:55.02977+00	15510d91-d443-4cc4-a248-227e6b22edc6	67
ce62aaf4-70d5-4c49-b1a6-19359c75053e	myoclonus	72	confirmed	2025-09-16 16:46:55.02977+00	15510d91-d443-4cc4-a248-227e6b22edc6	145
65431b01-30bd-4f1d-bf17-1eb626973c23	abnormal_movement	81	pending	2025-09-16 16:46:55.02977+00	15510d91-d443-4cc4-a248-227e6b22edc6	211
d3a9e0e4-71c2-430e-a294-2b32b35e5757	decerebrate	93	confirmed	2025-09-16 16:46:55.02977+00	e6d01a85-8e5a-4d84-8556-fc19fdb9c11f	89
6f4275e4-efb1-4a32-8a37-0c421447b2c3	seizure	78	pending	2025-09-16 16:46:55.02977+00	e6d01a85-8e5a-4d84-8556-fc19fdb9c11f	167
e9d06acd-2e6d-455b-848d-64a64b5bc09d	tremor	85	dismissed	2025-09-16 16:46:55.02977+00	e6d01a85-8e5a-4d84-8556-fc19fdb9c11f	256
a838028d-517f-42ce-be66-af3874d323b2	myoclonus	76	pending	2025-09-16 16:46:55.02977+00	7d0410da-50f0-40fc-8b8f-fb8d56dcf6e2	112
6a9ca8f3-5f32-4b7d-8bc5-335a1bac19ea	decorticate	84	confirmed	2025-09-16 16:46:55.02977+00	7d0410da-50f0-40fc-8b8f-fb8d56dcf6e2	201
1b4def61-c3f2-4da5-aa9c-f395579fd93c	abnormal_movement	70	pending	2025-09-16 16:46:55.02977+00	7d0410da-50f0-40fc-8b8f-fb8d56dcf6e2	278
11f1960b-fb50-4767-81a2-b86f0e7c5139	tremor	91	pending	2025-09-16 16:46:55.02977+00	437401d0-674e-45b9-a175-ff0c7de449fb	123
8aeebfad-0a94-4a5d-9f9a-c0a5ed3d0acd	tremor	76	pending	2025-09-16 18:52:50.72449+00	f9a7ecd1-4ba3-40e8-8ac2-f8cacf25e50f	73
23ff380e-f8fb-4933-8d9b-dbaef4bb8d20	myoclonus	79	pending	2025-09-16 18:52:50.72449+00	de6614f6-59c9-489f-b187-e8a35c0545c7	165
1dbed71e-df98-424e-ad75-43e75ae74023	myoclonus	77	pending	2025-09-16 18:52:50.72449+00	359474e9-ffd6-46a0-8750-77829306ffe5	68
02795c3b-fdea-4f0b-b7d6-d93714d831fd	decorticate	82	dismissed	2025-09-16 16:46:55.02977+00	437401d0-674e-45b9-a175-ff0c7de449fb	34
50ece3e9-1fe6-44b9-9d7e-0aa14c4448e2	abnormal_movement	66	confirmed	2025-09-16 18:52:50.72449+00	180e15ab-7671-414b-bb1f-e99986b52a87	62
\.


--
-- Data for Name: patients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patients (id, first_name, middle_name, last_name, dob, primary_phone, address, created_at, updated_at) FROM stdin;
6f006438-8301-4364-bbf9-88f07cda6530	Trevar	James	Duke	1977-04-08	+14348091065	5 Susan Center	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
15d58fbc-2fdb-4b97-b63f-2e84a0c3b50c	Pearla	Harper	Fairham	2020-01-10	+18505766662	4229 Golf Junction	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
aedac1c1-910e-44e8-ac71-deef62f42516	Russ	Brooke	Hannon	1997-11-27	+14546862124	13950 Lotheville Plaza	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
0eab151a-e6c8-486b-940e-554736135cb5	Jemimah	Morgan	Mably	1967-03-08	+13077543622	12248 Sloan Terrace	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
83ecf258-863d-4a22-b0d2-58a215afcdc1	Carmelle	James	Fryd	1994-08-29	+15457231424	9 Nelson Crossing	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
2d5d5ed1-9017-4687-8cc9-83fe2b124bf8	Raimondo	Rose	Newband	2021-12-15	+10344338706	515 Pearson Parkway	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
3d42a6da-40f4-485d-9271-1389cc019455	Amandi	Marie	Arrow	1992-02-11	+16688278849	1 Killdeer Plaza	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
472947a1-e127-46e1-a220-0df8f5cd8aee	Thayne	Mackenzie	Steart	1981-09-12	+19648838714	578 Dennis Crossing	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
2e478e2e-7157-4fae-b5ef-c91973c83c8d	Stephan	Riley	Dows	1997-12-07	+12353748853	87534 Mockingbird Avenue	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
b78d51fa-e50f-49f9-a5fe-1fcc435156fb	Zorana	Patrick	Rowles	2014-03-13	+12297188079	80386 Luster Center	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
2180abd2-1a06-4c37-bb00-627b28b58442	Ronda	Quinn	Lebond	1987-01-07	+16830638905	5786 Brown Hill	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
60ed81da-0d98-4283-9f33-c9af7cd06147	Wrennie	Mackenzie	Gready	2014-04-12	+11631413241	0575 Elmside Parkway	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
64f695c4-9909-40ba-8374-e74f6b3a5df0	Caresa	Jamie	Reolfo	1962-11-28	+19911106300	4 Pawling Drive	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
c8c2d32b-c7bc-4dcb-91e1-b505998aac7f	Eb	Parker	Shelborne	1962-04-10	+16992612742	2962 Forest Dale Terrace	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
9676c8c5-83cc-4a4a-8113-15fbec4bc835	Skipper	James	Maxstead	2018-12-27	+16325256751	9 Haas Way	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
6fd27f79-356d-478d-8771-4e9f950b9389	Alex	Patrick	McVittie	2003-09-06	+13750840822	51 Manufacturers Street	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
d1096158-e832-427e-9cf8-a247f7f8df37	Leoine	Charlie	Skittrell	1984-06-04	+14310575828	11671 Corry Circle	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
f700c4d8-09c9-4ee2-a9e2-be5dbb680588	Cly	Riley	Shovelbottom	2015-05-08	+15858105414	9698 Crest Line Court	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
b8f5fefb-00d9-4342-9cc5-240aa457c035	Inessa	Bailey	Gradley	1974-07-15	+15059020908	5 Melby Parkway	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
301f2d90-29c8-4560-9cbe-85697988cbb9	Regan	Alexis	Elland	2008-10-09	+17446495847	9264 Fairfield Way	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
adba910c-77f2-4a66-b05f-72988acd6d81	Viviyan	Cameron	Dunnion	1996-03-24	+15974713503	28539 Green Point	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
18d6c1bd-8174-42aa-af63-c3f0c7cc7853	Eziechiele	Bailey	Southon	2010-01-02	+11729717535	0 Bashford Point	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
3241e9b4-33cd-43ad-9974-b4e537701e8d	Hyacinthe	Marie	Beurich	1983-04-19	+13614434932	095 Farragut Park	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
c89bd079-4d5f-45e6-9c68-6e74340bedea	Perceval	Jamie	Gildersleaves	2014-01-05	+16037076792	8968 Bobwhite Parkway	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
9e0345cf-84a6-4301-a9b8-1ce5547951df	Shellie	Dylan	Domesday	1969-09-19	+17745357898	72185 John Wall Trail	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
11b588ef-5dfb-49b6-82bb-253752f1c119	Arley	Skyler	Biddiss	2002-05-15	+17503347946	6 Buena Vista Terrace	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
e18e7f65-8a25-45fb-9845-a1a4c3472956	Coralyn	Reese	Battle	2003-11-29	+15888547444	994 Bluestem Avenue	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
9fc8d6cc-bcb8-433d-a331-7519268d0bfa	Irwin	Scott	Jenson	1973-09-21	+15455119513	3 Superior Trail	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
e9fa5b22-0429-4580-bd5c-b4170de369bc	Verina	Charlie	Gianinotti	1991-11-15	+19415738934	14654 Fremont Junction	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
7af46bd0-934f-4f03-8c73-0fe3d68677b3	Iseabal	Alex	Iashvili	2016-10-06	+13712632599	47 Kings Crossing	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
981f593b-4a9f-4046-a319-1f4b18d4cb70	Dareen	Grace	Winscom	2022-07-29	+16292397379	794 Mccormick Court	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
9c2bd98f-b5b8-49fd-a952-d36cc27a635f	Birgitta	Lee	Kellet	2014-07-14	+13046623111	0 Bluejay Plaza	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
252172e1-46a8-4f6b-97b8-0ce7ea0b5189	Haroun	Ryan	Surcomb	1978-04-21	+11246078539	6371 Memorial Center	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
0cabaa76-b0cb-4785-ae2a-9b5e96739ae3	Benedikta	Grace	Lawley	1961-03-16	+19461808477	2 American Road	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
43311ca8-a60d-42f0-9dc3-ecec9bb98382	Leland	Scott	Daudray	1967-04-27	+14618659081	29553 Kingsford Junction	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
3ee35f96-d497-498a-b7c0-babe9e5247cb	Marianne	James	Bettaney	2006-11-24	+14740483725	56 Mariners Cove Trail	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
e9d03106-b91b-400b-9e62-433815125368	Harrie	Morgan	Thackray	1968-09-13	+14401524761	3335 Nobel Junction	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
d14d4b09-3bcd-44bf-8e42-b35a949b9aaa	Daloris	Patrick	Tomaszewicz	1978-07-20	+10941433925	03490 Pond Junction	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
6be7fc85-1e5e-44c1-a2b5-14d2f36264b0	Jamil	Ryan	Penhaligon	2006-03-22	+18280420826	53890 Village Road	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
9c404222-4ae7-4463-b768-f52b8fcee62f	Nicolai	Jordan	Gregorowicz	1998-11-16	+13561146553	771 Roth Park	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
d885408c-ef34-4238-8e38-9f7327f481ee	Janey	Marie	Mazzia	1979-08-29	+10705918849	6 Harper Park	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
a0bc193d-ffd8-4d90-891e-98e3b1a2ca47	Madelena	Alexis	Aynscombe	1973-09-15	+17030877759	2 Continental Road	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
801d0442-802c-4bbe-b168-fb5292da520b	Kristal	Casey	Shorey	1998-11-14	+12092771632	3 Meadow Vale Crossing	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
ba29aff6-c2cf-4029-9c3b-62fa95ea8093	Sharline	Sawyer	Deetlof	1978-11-09	+12873444870	904 Northfield Hill	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
e1af7621-17b1-436b-9dd0-1a7043d8c988	Sybyl	Grace	Duffy	2022-06-13	+10853278545	629 Randy Street	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
dc2622a8-b105-4194-acca-f4e6387a2f11	Francis	Sawyer	Cusiter	1975-12-24	+13043780038	0944 Burning Wood Parkway	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
e2907e9b-b1d9-4871-8223-81c1994a16ad	Benetta	Ryan	Cutmore	1973-05-08	+10673482418	672 Lake View Park	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
2cf7c036-e949-4576-9a3a-7ddbd8210b2a	Jard	Mackenzie	Beadham	1977-08-26	+17893207786	32 Hoard Parkway	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
ff5ca674-e366-42e1-b705-7b416beea42f	Harp	Alex	Espinay	1987-04-11	+13234183362	127 Shasta Way	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
b3d8e5ad-e62c-4549-a77c-07b48230d1d8	Tore	Brooke	Studdeard	2020-03-16	+15142006007	927 Havey Center	2025-03-19 09:03:22.025514+00	2025-03-19 09:03:22.025514+00
fdb16c4f-0013-4077-87a5-5d5de148051a	fdfrfr	\N	frfr	2025-08-07	1112223344	4424 j st	2025-09-29 07:19:09.220169+00	2025-09-29 07:19:09.220169+00
21d13a14-fc21-4e9c-b137-56e43673fdbe	Pablo	\N	Hernandez	2025-08-07	1112223344	6001 J st	2025-09-29 07:19:42.690503+00	2025-09-29 07:19:42.690503+00
\.


--
-- Data for Name: video; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.video (patient_id, description, created_at, id, file_path, duration) FROM stdin;
0cabaa76-b0cb-4785-ae2a-9b5e96739ae3	\N	2025-04-19 20:29:29.361608+00	8513c73d-6e90-4968-8401-85b71aa208a6	timer-videos/3min-timer.mp4	0
11b588ef-5dfb-49b6-82bb-253752f1c119	\N	2025-04-19 20:31:29.14161+00	59ed9078-a1e6-44fa-b232-bf5c318cb601	timer-videos/4min-timer.mp4	0
60ed81da-0d98-4283-9f33-c9af7cd06147	\N	2025-04-19 20:38:59.88791+00	437401d0-674e-45b9-a175-ff0c7de449fb	timer-videos/5min-timer(1).mp4	0
2180abd2-1a06-4c37-bb00-627b28b58442	\N	2025-04-19 20:50:06.138916+00	25273293-c532-4bd2-9ccf-e57dfd94c8bf	timer-videos/5min-timer.mp4	0
0eab151a-e6c8-486b-940e-554736135cb5	\N	2025-09-15 23:41:36.270433+00	c12fc43a-f943-48aa-8520-873b2af3bf6b	timer-videos/5min-timer(1).mp4	0
15d58fbc-2fdb-4b97-b63f-2e84a0c3b50c	\N	2025-09-15 23:41:36.270433+00	64c4258c-dd8d-4388-af16-5675865d28f8	timer-videos/4min-timer.mp4	0
252172e1-46a8-4f6b-97b8-0ce7ea0b5189	\N	2025-09-15 23:41:36.270433+00	3bb55180-0bb0-4f34-acd5-ef212aaa36f3	timer-videos/5min-timer.mp4	0
2cf7c036-e949-4576-9a3a-7ddbd8210b2a	\N	2025-09-15 23:41:36.270433+00	15510d91-d443-4cc4-a248-227e6b22edc6	timer-videos/4min-timer.mp4	0
2e478e2e-7157-4fae-b5ef-c91973c83c8d	\N	2025-09-15 23:41:36.270433+00	e6d01a85-8e5a-4d84-8556-fc19fdb9c11f	timer-videos/5min-timer(1).mp4	0
301f2d90-29c8-4560-9cbe-85697988cbb9	\N	2025-09-15 23:41:36.270433+00	7d0410da-50f0-40fc-8b8f-fb8d56dcf6e2	timer-videos/5min-timer.mp4	0
3241e9b4-33cd-43ad-9974-b4e537701e8d	\N	2025-09-15 23:41:36.270433+00	60dc4352-588c-49c1-a599-fcefffe83ff8	timer-videos/4min-timer.mp4	0
3ee35f96-d497-498a-b7c0-babe9e5247cb	\N	2025-09-15 23:41:36.270433+00	e03d79ea-ccf0-46bc-99ac-f5c8c0e8c3ef	timer-videos/5min-timer(1).mp4	0
43311ca8-a60d-42f0-9dc3-ecec9bb98382	\N	2025-09-15 23:41:36.270433+00	b1cfb1f3-7d43-45c1-a670-d12d069b0ab6	timer-videos/5min-timer.mp4	0
472947a1-e127-46e1-a220-0df8f5cd8aee	\N	2025-09-15 23:41:36.270433+00	8be2f72a-c89d-4f7a-879f-4474ce77f4f4	timer-videos/4min-timer.mp4	0
64f695c4-9909-40ba-8374-e74f6b3a5df0	\N	2025-09-15 23:41:36.270433+00	e7da892b-ef54-43c5-9ced-81808a1a55bf	timer-videos/5min-timer(1).mp4	0
6be7fc85-1e5e-44c1-a2b5-14d2f36264b0	\N	2025-09-15 23:41:36.270433+00	6b41f451-f08f-4513-8b5d-c2c1c446d8f1	timer-videos/5min-timer.mp4	0
6f006438-8301-4364-bbf9-88f07cda6530	\N	2025-09-15 23:41:36.270433+00	dff8d1c2-dff5-4823-8171-63e97efe0f9d	timer-videos/4min-timer.mp4	0
7af46bd0-934f-4f03-8c73-0fe3d68677b3	\N	2025-09-15 23:41:36.270433+00	fc20be51-6472-41df-863b-271a5c450cf5	timer-videos/5min-timer(1).mp4	0
801d0442-802c-4bbe-b168-fb5292da520b	\N	2025-09-15 23:41:36.270433+00	571d498f-70d3-4d2c-bdf2-75a598484100	timer-videos/5min-timer.mp4	0
83ecf258-863d-4a22-b0d2-58a215afcdc1	\N	2025-09-15 23:41:36.270433+00	043db1d5-7526-49dd-ae9b-476d9b7b4242	timer-videos/4min-timer.mp4	0
981f593b-4a9f-4046-a319-1f4b18d4cb70	\N	2025-09-15 23:41:36.270433+00	ff87e084-90d8-4b6b-a998-c7547ce73761	timer-videos/5min-timer(1).mp4	0
9c2bd98f-b5b8-49fd-a952-d36cc27a635f	\N	2025-09-15 23:41:36.270433+00	c67c7d3b-40f4-44b0-85b9-522bc92ad907	timer-videos/5min-timer.mp4	0
9c404222-4ae7-4463-b768-f52b8fcee62f	\N	2025-09-15 23:41:36.270433+00	3eb203d5-59d8-4cbd-9501-7dfbd3177d6e	timer-videos/4min-timer.mp4	0
9fc8d6cc-bcb8-433d-a331-7519268d0bfa	\N	2025-09-15 23:41:36.270433+00	4212b08a-bd28-401e-aae3-c3a3b0437d4e	timer-videos/5min-timer(1).mp4	0
a0bc193d-ffd8-4d90-891e-98e3b1a2ca47	\N	2025-09-15 23:41:36.270433+00	e8e14abc-72ef-40f0-ba9b-1d948dc9afa2	timer-videos/5min-timer.mp4	0
adba910c-77f2-4a66-b05f-72988acd6d81	\N	2025-09-15 23:41:36.270433+00	57fb9487-f278-45ea-8cda-dd649c5230f9	timer-videos/4min-timer.mp4	0
b3d8e5ad-e62c-4549-a77c-07b48230d1d8	\N	2025-09-15 23:41:36.270433+00	056d59e2-6c7c-4607-9e9a-d4a7c74032c8	timer-videos/5min-timer(1).mp4	0
b78d51fa-e50f-49f9-a5fe-1fcc435156fb	\N	2025-09-15 23:41:36.270433+00	e6b5d47d-804e-408b-9fc6-eea7c865c0dd	timer-videos/5min-timer.mp4	0
b8f5fefb-00d9-4342-9cc5-240aa457c035	\N	2025-09-15 23:41:36.270433+00	f194cdd8-a5b7-4cde-bfcc-bb8461c04851	timer-videos/4min-timer.mp4	0
c89bd079-4d5f-45e6-9c68-6e74340bedea	\N	2025-09-15 23:41:36.270433+00	300479dd-8999-4963-8e97-85fc8fe36bd2	timer-videos/5min-timer(1).mp4	0
c8c2d32b-c7bc-4dcb-91e1-b505998aac7f	\N	2025-09-15 23:41:36.270433+00	79842dbe-2401-4720-93f8-3b1411470296	timer-videos/5min-timer.mp4	0
d1096158-e832-427e-9cf8-a247f7f8df37	\N	2025-09-15 23:41:36.270433+00	e2bbab7c-98b0-4967-8f0a-81772a721061	timer-videos/4min-timer.mp4	0
d885408c-ef34-4238-8e38-9f7327f481ee	\N	2025-09-15 23:41:36.270433+00	c1915d75-6e57-4ce1-8d32-83b6facb30df	timer-videos/5min-timer(1).mp4	0
dc2622a8-b105-4194-acca-f4e6387a2f11	\N	2025-09-15 23:41:36.270433+00	9ea86dda-334e-4a56-a3f7-3b9e660a2df8	timer-videos/5min-timer.mp4	0
e18e7f65-8a25-45fb-9845-a1a4c3472956	\N	2025-09-15 23:41:36.270433+00	d0464db3-044e-4207-becf-eec47f79bf44	timer-videos/4min-timer.mp4	0
e2907e9b-b1d9-4871-8223-81c1994a16ad	\N	2025-09-15 23:41:36.270433+00	7b594f0e-6cde-4361-8735-37bfe9b79492	timer-videos/5min-timer(1).mp4	0
e9d03106-b91b-400b-9e62-433815125368	\N	2025-09-15 23:41:36.270433+00	f9a7ecd1-4ba3-40e8-8ac2-f8cacf25e50f	timer-videos/5min-timer.mp4	0
e9fa5b22-0429-4580-bd5c-b4170de369bc	\N	2025-09-15 23:41:36.270433+00	de6614f6-59c9-489f-b187-e8a35c0545c7	timer-videos/4min-timer.mp4	0
ff5ca674-e366-42e1-b705-7b416beea42f	\N	2025-09-15 23:41:36.270433+00	359474e9-ffd6-46a0-8750-77829306ffe5	timer-videos/5min-timer(1).mp4	0
6f006438-8301-4364-bbf9-88f07cda6530	\N	2025-09-16 05:56:12.338199+00	180e15ab-7671-414b-bb1f-e99986b52a87	timer-videos/3min-timer.mp4	0
\.


--
-- Data for Name: messages_2025_09_26; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_09_26 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_09_27; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_09_27 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_09_28; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_09_28 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_09_29; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_09_29 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_09_30; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_09_30 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_10_01; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_10_01 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_10_02; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_10_02 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2025-03-12 21:59:43
20211116045059	2025-03-12 21:59:43
20211116050929	2025-03-12 21:59:43
20211116051442	2025-03-12 21:59:43
20211116212300	2025-03-12 21:59:43
20211116213355	2025-03-12 21:59:43
20211116213934	2025-03-12 21:59:43
20211116214523	2025-03-12 21:59:43
20211122062447	2025-03-12 21:59:43
20211124070109	2025-03-12 21:59:43
20211202204204	2025-03-12 21:59:43
20211202204605	2025-03-12 21:59:43
20211210212804	2025-03-12 21:59:43
20211228014915	2025-03-12 21:59:43
20220107221237	2025-03-12 21:59:43
20220228202821	2025-03-12 21:59:43
20220312004840	2025-03-12 21:59:43
20220603231003	2025-03-12 21:59:43
20220603232444	2025-03-12 21:59:44
20220615214548	2025-03-12 21:59:44
20220712093339	2025-03-12 21:59:44
20220908172859	2025-03-12 21:59:44
20220916233421	2025-03-12 21:59:44
20230119133233	2025-03-12 21:59:44
20230128025114	2025-03-12 21:59:44
20230128025212	2025-03-12 21:59:44
20230227211149	2025-03-12 21:59:44
20230228184745	2025-03-12 21:59:44
20230308225145	2025-03-12 21:59:44
20230328144023	2025-03-12 21:59:44
20231018144023	2025-03-12 21:59:44
20231204144023	2025-03-12 21:59:44
20231204144024	2025-03-12 21:59:44
20231204144025	2025-03-12 21:59:44
20240108234812	2025-03-12 21:59:44
20240109165339	2025-03-12 21:59:44
20240227174441	2025-03-12 21:59:44
20240311171622	2025-03-12 21:59:44
20240321100241	2025-03-12 21:59:44
20240401105812	2025-03-12 21:59:44
20240418121054	2025-03-12 21:59:44
20240523004032	2025-03-12 21:59:44
20240618124746	2025-03-12 21:59:44
20240801235015	2025-03-12 21:59:44
20240805133720	2025-03-12 21:59:44
20240827160934	2025-03-12 21:59:44
20240919163303	2025-03-12 21:59:44
20240919163305	2025-03-12 21:59:44
20241019105805	2025-03-12 21:59:44
20241030150047	2025-03-12 21:59:44
20241108114728	2025-03-12 21:59:44
20241121104152	2025-03-12 21:59:44
20241130184212	2025-03-12 21:59:44
20241220035512	2025-03-12 21:59:44
20241220123912	2025-03-12 21:59:44
20241224161212	2025-03-12 21:59:44
20250107150512	2025-03-12 21:59:44
20250110162412	2025-03-12 21:59:44
20250123174212	2025-03-12 21:59:44
20250128220012	2025-03-12 21:59:44
20250506224012	2025-05-28 01:36:40
20250523164012	2025-07-26 00:36:12
20250714121412	2025-07-26 00:36:12
20250905041441	2025-09-24 00:47:28
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) FROM stdin;
recorded.videos	recorded.videos	\N	2025-04-01 01:13:52.56732+00	2025-04-01 01:13:52.56732+00	t	f	\N	\N	\N	STANDARD
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets_analytics (id, type, format, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-03-12 21:51:17.047401
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-03-12 21:51:17.052301
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2025-03-12 21:51:17.056463
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-03-12 21:51:17.076128
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-03-12 21:51:17.130715
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-03-12 21:51:17.133491
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2025-03-12 21:51:17.136734
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-03-12 21:51:17.140784
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-03-12 21:51:17.143741
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2025-03-12 21:51:17.147284
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2025-03-12 21:51:17.151308
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-03-12 21:51:17.162525
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-03-12 21:51:17.171667
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-03-12 21:51:17.183458
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-03-12 21:51:17.188027
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-03-12 21:51:17.215385
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-03-12 21:51:17.219017
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-03-12 21:51:17.222229
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-03-12 21:51:17.230804
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-03-12 21:51:17.235733
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-03-12 21:51:17.240402
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-03-12 21:51:17.249618
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-03-12 21:51:17.279678
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-03-12 21:51:17.308423
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-03-12 21:51:17.312229
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2025-03-12 21:51:17.315773
26	objects-prefixes	ef3f7871121cdc47a65308e6702519e853422ae2	2025-09-09 20:23:03.051869
27	search-v2	33b8f2a7ae53105f028e13e9fcda9dc4f356b4a2	2025-09-09 20:23:03.555285
28	object-bucket-name-sorting	ba85ec41b62c6a30a3f136788227ee47f311c436	2025-09-09 20:23:03.630419
29	create-prefixes	a7b1a22c0dc3ab630e3055bfec7ce7d2045c5b7b	2025-09-09 20:23:03.673867
30	update-object-levels	6c6f6cc9430d570f26284a24cf7b210599032db7	2025-09-09 20:23:03.727318
31	objects-level-index	33f1fef7ec7fea08bb892222f4f0f5d79bab5eb8	2025-09-09 20:23:03.742723
32	backward-compatible-index-on-objects	2d51eeb437a96868b36fcdfb1ddefdf13bef1647	2025-09-09 20:23:03.778788
33	backward-compatible-index-on-prefixes	fe473390e1b8c407434c0e470655945b110507bf	2025-09-09 20:23:03.829353
34	optimize-search-function-v1	82b0e469a00e8ebce495e29bfa70a0797f7ebd2c	2025-09-09 20:23:03.835105
35	add-insert-trigger-prefixes	63bb9fd05deb3dc5e9fa66c83e82b152f0caf589	2025-09-09 20:23:03.851538
36	optimise-existing-functions	81cf92eb0c36612865a18016a38496c530443899	2025-09-09 20:23:03.858489
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2025-09-09 20:23:03.891302
38	iceberg-catalog-flag-on-buckets	19a8bd89d5dfa69af7f222a46c726b7c41e462c5	2025-09-09 20:23:03.902112
39	add-search-v2-sort-support	39cf7d1e6bf515f4b02e41237aba845a7b492853	2025-09-29 04:43:50.803004
40	fix-prefix-race-conditions-optimized	fd02297e1c67df25a9fc110bf8c8a9af7fb06d1f	2025-09-29 04:43:50.928751
41	add-object-level-update-trigger	44c22478bf01744b2129efc480cd2edc9a7d60e9	2025-09-29 04:43:50.981224
42	rollback-prefix-triggers	f2ab4f526ab7f979541082992593938c05ee4b47	2025-09-29 04:43:50.994883
43	fix-object-level	ab837ad8f1c7d00cc0b7310e989a23388ff29fc6	2025-09-29 04:43:51.011449
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata, level) FROM stdin;
834fa1e7-0f54-4d81-918a-085810670381	recorded.videos	timer-videos/.emptyFolderPlaceholder	\N	2025-04-19 20:05:02.074584+00	2025-09-09 20:23:03.679575+00	2025-04-19 20:05:02.074584+00	{"eTag": "\\"d41d8cd98f00b204e9800998ecf8427e\\"", "size": 0, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2025-04-19T20:05:03.000Z", "contentLength": 0, "httpStatusCode": 200}	a6bb6f93-6a68-4059-ba6d-4b426326241c	\N	{}	2
0932edeb-0e1d-44ff-a66d-8e8e024cdbd0	recorded.videos	timer-videos/5min-timer(1).mp4	\N	2025-04-19 20:02:38.827079+00	2025-09-09 20:23:03.679575+00	2025-04-19 20:02:38.827079+00	{"eTag": "\\"82b103b31e17f58fc28328ad08a8a41e\\"", "size": 6543692, "mimetype": "video/mp4", "cacheControl": "max-age=3600", "lastModified": "2025-04-19T20:16:42.000Z", "contentLength": 6543692, "httpStatusCode": 200}	f9303e89-4443-4676-8725-416b2b90dcfa	\N	\N	2
63e3c26c-977b-4953-91cf-f7662a6808ec	recorded.videos	timer-videos/5min-timer.mp4	\N	2025-04-19 20:02:27.029005+00	2025-09-09 20:23:03.679575+00	2025-04-19 20:02:27.029005+00	{"eTag": "\\"d273cb74356a25625a19c9ca8a0e31ed\\"", "size": 5318600, "mimetype": "video/mp4", "cacheControl": "max-age=3600", "lastModified": "2025-04-19T20:17:04.000Z", "contentLength": 5318600, "httpStatusCode": 200}	d5b4201f-44d9-4171-92b2-09c05d90fc98	\N	\N	2
6792b1e0-713c-430f-8644-eb2546747b59	recorded.videos	timer-videos/4min-timer.mp4	\N	2025-04-19 20:02:14.330611+00	2025-09-09 20:23:03.679575+00	2025-04-19 20:02:14.330611+00	{"eTag": "\\"af60b97514c4f060f604ca1f458470fb\\"", "size": 4531963, "mimetype": "video/mp4", "cacheControl": "max-age=3600", "lastModified": "2025-04-19T20:17:13.000Z", "contentLength": 4531963, "httpStatusCode": 200}	f6dd8981-32c9-4825-92ef-be4facbe2b7e	\N	\N	2
54a3551e-fbad-49f2-9057-f533958c3590	recorded.videos	timer-videos/3min-timer.mp4	\N	2025-04-19 20:02:09.413444+00	2025-09-09 20:23:03.679575+00	2025-04-19 20:02:09.413444+00	{"eTag": "\\"06ac593a70c5b0d784127b194e29ccae\\"", "size": 4321926, "mimetype": "video/mp4", "cacheControl": "max-age=3600", "lastModified": "2025-04-19T20:17:19.000Z", "contentLength": 4321926, "httpStatusCode": 200}	eba3e94e-8ca6-40e9-b2ee-e94729cc65b4	\N	\N	2
\.


--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.prefixes (bucket_id, name, created_at, updated_at) FROM stdin;
recorded.videos	timer-videos	2025-09-09 20:23:03.635554+00	2025-09-09 20:23:03.635554+00
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: supabase_admin
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 901, true);


--
-- Name: key_key_id_seq; Type: SEQUENCE SET; Schema: pgsodium; Owner: supabase_admin
--

SELECT pg_catalog.setval('pgsodium.key_key_id_seq', 1, false);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: supabase_admin
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 748, true);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_client_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_client_id_key UNIQUE (client_id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ai_detections ai_detections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_detections
    ADD CONSTRAINT ai_detections_pkey PRIMARY KEY (id);


--
-- Name: ambulance_streaming_sessions ambulance_streaming_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ambulance_streaming_sessions
    ADD CONSTRAINT ambulance_streaming_sessions_pkey PRIMARY KEY (id);


--
-- Name: ambulances ambulances_ambulance_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ambulances
    ADD CONSTRAINT ambulances_ambulance_number_key UNIQUE (ambulance_number);


--
-- Name: ambulances ambulances_license_plate_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ambulances
    ADD CONSTRAINT ambulances_license_plate_key UNIQUE (license_plate);


--
-- Name: ambulances ambulances_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ambulances
    ADD CONSTRAINT ambulances_pkey PRIMARY KEY (id);


--
-- Name: camera_streaming_rooms camera_streaming_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.camera_streaming_rooms
    ADD CONSTRAINT camera_streaming_rooms_pkey PRIMARY KEY (id);


--
-- Name: camera_streaming_rooms camera_streaming_rooms_room_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.camera_streaming_rooms
    ADD CONSTRAINT camera_streaming_rooms_room_id_key UNIQUE (room_id);


--
-- Name: cameras cameras_camera_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cameras
    ADD CONSTRAINT cameras_camera_id_key UNIQUE (camera_id);


--
-- Name: cameras cameras_mac_address_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cameras
    ADD CONSTRAINT cameras_mac_address_key UNIQUE (mac_address);


--
-- Name: cameras cameras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cameras
    ADD CONSTRAINT cameras_pkey PRIMARY KEY (id);


--
-- Name: doctor doctor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_pkey PRIMARY KEY (id);


--
-- Name: medical_history medical_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_history
    ADD CONSTRAINT medical_history_pkey PRIMARY KEY (id);


--
-- Name: note note_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.note
    ADD CONSTRAINT note_pkey PRIMARY KEY (id);


--
-- Name: patient_event patient_event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_event
    ADD CONSTRAINT patient_event_pkey PRIMARY KEY (id);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- Name: video video_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video
    ADD CONSTRAINT video_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_09_26 messages_2025_09_26_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_09_26
    ADD CONSTRAINT messages_2025_09_26_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_09_27 messages_2025_09_27_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_09_27
    ADD CONSTRAINT messages_2025_09_27_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_09_28 messages_2025_09_28_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_09_28
    ADD CONSTRAINT messages_2025_09_28_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_09_29 messages_2025_09_29_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_09_29
    ADD CONSTRAINT messages_2025_09_29_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_09_30 messages_2025_09_30_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_09_30
    ADD CONSTRAINT messages_2025_09_30_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_10_01 messages_2025_10_01_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_10_01
    ADD CONSTRAINT messages_2025_10_01_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_10_02 messages_2025_10_02_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_10_02
    ADD CONSTRAINT messages_2025_10_02_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: prefixes prefixes_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT prefixes_pkey PRIMARY KEY (bucket_id, level, name);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_clients_client_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_clients_client_id_idx ON auth.oauth_clients USING btree (client_id);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: idx_ai_detections_camera_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ai_detections_camera_id ON public.ai_detections USING btree (camera_id);


--
-- Name: idx_ai_detections_patient_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ai_detections_patient_id ON public.ai_detections USING btree (detected_patient_id);


--
-- Name: idx_ai_detections_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ai_detections_session_id ON public.ai_detections USING btree (session_id);


--
-- Name: idx_ai_detections_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ai_detections_timestamp ON public.ai_detections USING btree (frame_timestamp);


--
-- Name: idx_ai_detections_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ai_detections_type ON public.ai_detections USING btree (detection_type);


--
-- Name: idx_ambulance_sessions_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ambulance_sessions_active ON public.ambulance_streaming_sessions USING btree (is_active);


--
-- Name: idx_ambulance_sessions_ambulance_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ambulance_sessions_ambulance_id ON public.ambulance_streaming_sessions USING btree (ambulance_id);


--
-- Name: idx_ambulance_sessions_incident_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ambulance_sessions_incident_id ON public.ambulance_streaming_sessions USING btree (incident_id);


--
-- Name: idx_ambulance_sessions_started_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ambulance_sessions_started_at ON public.ambulance_streaming_sessions USING btree (started_at);


--
-- Name: idx_ambulances_license; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ambulances_license ON public.ambulances USING btree (license_plate);


--
-- Name: idx_ambulances_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ambulances_number ON public.ambulances USING btree (ambulance_number);


--
-- Name: idx_ambulances_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ambulances_status ON public.ambulances USING btree (status);


--
-- Name: idx_camera_rooms_camera_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_camera_rooms_camera_id ON public.camera_streaming_rooms USING btree (camera_id);


--
-- Name: idx_camera_rooms_connected; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_camera_rooms_connected ON public.camera_streaming_rooms USING btree (connected);


--
-- Name: idx_camera_rooms_room_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_camera_rooms_room_id ON public.camera_streaming_rooms USING btree (room_id);


--
-- Name: idx_camera_rooms_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_camera_rooms_session_id ON public.camera_streaming_rooms USING btree (session_id);


--
-- Name: idx_cameras_ambulance_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cameras_ambulance_id ON public.cameras USING btree (ambulance_id);


--
-- Name: idx_cameras_camera_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cameras_camera_id ON public.cameras USING btree (camera_id);


--
-- Name: idx_cameras_mac_address; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cameras_mac_address ON public.cameras USING btree (mac_address);


--
-- Name: idx_cameras_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cameras_status ON public.cameras USING btree (status);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_09_26_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2025_09_26_inserted_at_topic_idx ON realtime.messages_2025_09_26 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_09_27_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2025_09_27_inserted_at_topic_idx ON realtime.messages_2025_09_27 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_09_28_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2025_09_28_inserted_at_topic_idx ON realtime.messages_2025_09_28 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_09_29_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2025_09_29_inserted_at_topic_idx ON realtime.messages_2025_09_29 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_09_30_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2025_09_30_inserted_at_topic_idx ON realtime.messages_2025_09_30 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_10_01_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2025_10_01_inserted_at_topic_idx ON realtime.messages_2025_10_01 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_10_02_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2025_10_02_inserted_at_topic_idx ON realtime.messages_2025_10_02 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_name_bucket_level_unique; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX idx_name_bucket_level_unique ON storage.objects USING btree (name COLLATE "C", bucket_id, level);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_lower_name ON storage.objects USING btree ((path_tokens[level]), lower(name) text_pattern_ops, bucket_id, level);


--
-- Name: idx_prefixes_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_prefixes_lower_name ON storage.prefixes USING btree (bucket_id, level, ((string_to_array(name, '/'::text))[level]), lower(name) text_pattern_ops);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: objects_bucket_id_level_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX objects_bucket_id_level_idx ON storage.objects USING btree (bucket_id, level, name COLLATE "C");


--
-- Name: messages_2025_09_26_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_09_26_inserted_at_topic_idx;


--
-- Name: messages_2025_09_26_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_09_26_pkey;


--
-- Name: messages_2025_09_27_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_09_27_inserted_at_topic_idx;


--
-- Name: messages_2025_09_27_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_09_27_pkey;


--
-- Name: messages_2025_09_28_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_09_28_inserted_at_topic_idx;


--
-- Name: messages_2025_09_28_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_09_28_pkey;


--
-- Name: messages_2025_09_29_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_09_29_inserted_at_topic_idx;


--
-- Name: messages_2025_09_29_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_09_29_pkey;


--
-- Name: messages_2025_09_30_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_09_30_inserted_at_topic_idx;


--
-- Name: messages_2025_09_30_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_09_30_pkey;


--
-- Name: messages_2025_10_01_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_10_01_inserted_at_topic_idx;


--
-- Name: messages_2025_10_01_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_10_01_pkey;


--
-- Name: messages_2025_10_02_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_10_02_inserted_at_topic_idx;


--
-- Name: messages_2025_10_02_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_10_02_pkey;


--
-- Name: ambulance_streaming_sessions calculate_ambulance_session_duration; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER calculate_ambulance_session_duration BEFORE UPDATE ON public.ambulance_streaming_sessions FOR EACH ROW EXECUTE FUNCTION public.calculate_session_duration();


--
-- Name: ambulance_streaming_sessions update_ambulance_sessions_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_ambulance_sessions_updated_at BEFORE UPDATE ON public.ambulance_streaming_sessions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: ambulances update_ambulances_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_ambulances_updated_at BEFORE UPDATE ON public.ambulances FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: cameras update_camera_count_on_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_camera_count_on_delete AFTER DELETE ON public.cameras FOR EACH ROW EXECUTE FUNCTION public.update_ambulance_camera_count();


--
-- Name: cameras update_camera_count_on_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_camera_count_on_insert AFTER INSERT ON public.cameras FOR EACH ROW EXECUTE FUNCTION public.update_ambulance_camera_count();


--
-- Name: camera_streaming_rooms update_camera_rooms_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_camera_rooms_updated_at BEFORE UPDATE ON public.camera_streaming_rooms FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: cameras update_cameras_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_cameras_updated_at BEFORE UPDATE ON public.cameras FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: objects objects_delete_delete_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_delete_delete_prefix AFTER DELETE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects objects_insert_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_insert_create_prefix BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.objects_insert_prefix_trigger();


--
-- Name: objects objects_update_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_update_create_prefix BEFORE UPDATE ON storage.objects FOR EACH ROW WHEN (((new.name <> old.name) OR (new.bucket_id <> old.bucket_id))) EXECUTE FUNCTION storage.objects_update_prefix_trigger();


--
-- Name: prefixes prefixes_create_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_create_hierarchy BEFORE INSERT ON storage.prefixes FOR EACH ROW WHEN ((pg_trigger_depth() < 1)) EXECUTE FUNCTION storage.prefixes_insert_trigger();


--
-- Name: prefixes prefixes_delete_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_delete_hierarchy AFTER DELETE ON storage.prefixes FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: ai_detections ai_detections_camera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_detections
    ADD CONSTRAINT ai_detections_camera_id_fkey FOREIGN KEY (camera_id) REFERENCES public.cameras(id) ON DELETE CASCADE;


--
-- Name: ai_detections ai_detections_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_detections
    ADD CONSTRAINT ai_detections_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.camera_streaming_rooms(id) ON DELETE CASCADE;


--
-- Name: ai_detections ai_detections_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_detections
    ADD CONSTRAINT ai_detections_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.ambulance_streaming_sessions(id) ON DELETE CASCADE;


--
-- Name: ambulance_streaming_sessions ambulance_streaming_sessions_ambulance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ambulance_streaming_sessions
    ADD CONSTRAINT ambulance_streaming_sessions_ambulance_id_fkey FOREIGN KEY (ambulance_id) REFERENCES public.ambulances(id) ON DELETE CASCADE;


--
-- Name: camera_streaming_rooms camera_streaming_rooms_camera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.camera_streaming_rooms
    ADD CONSTRAINT camera_streaming_rooms_camera_id_fkey FOREIGN KEY (camera_id) REFERENCES public.cameras(id) ON DELETE CASCADE;


--
-- Name: camera_streaming_rooms camera_streaming_rooms_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.camera_streaming_rooms
    ADD CONSTRAINT camera_streaming_rooms_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.ambulance_streaming_sessions(id) ON DELETE CASCADE;


--
-- Name: cameras cameras_ambulance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cameras
    ADD CONSTRAINT cameras_ambulance_id_fkey FOREIGN KEY (ambulance_id) REFERENCES public.ambulances(id) ON DELETE CASCADE;


--
-- Name: medical_history medical_history_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_history
    ADD CONSTRAINT medical_history_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctor(id) ON UPDATE CASCADE;


--
-- Name: medical_history medical_history_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_history
    ADD CONSTRAINT medical_history_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: note note_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.note
    ADD CONSTRAINT note_author_fkey FOREIGN KEY (author) REFERENCES public.doctor(id);


--
-- Name: note note_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.note
    ADD CONSTRAINT note_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: note note_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.note
    ADD CONSTRAINT note_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.video(id);


--
-- Name: patient_event patient_event_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_event
    ADD CONSTRAINT patient_event_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.video(id) ON DELETE CASCADE;


--
-- Name: video video_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video
    ADD CONSTRAINT video_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: prefixes prefixes_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: ambulances ambulances_select_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ambulances_select_policy ON public.ambulances FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: ambulances ambulances_service_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ambulances_service_policy ON public.ambulances USING (((auth.jwt() ->> 'role'::text) = 'service_role'::text));


--
-- Name: cameras cameras_select_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY cameras_select_policy ON public.cameras FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: cameras cameras_service_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY cameras_service_policy ON public.cameras USING (((auth.jwt() ->> 'role'::text) = 'service_role'::text));


--
-- Name: ai_detections detections_select_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY detections_select_policy ON public.ai_detections FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: ai_detections detections_service_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY detections_service_policy ON public.ai_detections USING (((auth.jwt() ->> 'role'::text) = 'service_role'::text));


--
-- Name: camera_streaming_rooms rooms_select_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rooms_select_policy ON public.camera_streaming_rooms FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: camera_streaming_rooms rooms_service_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rooms_service_policy ON public.camera_streaming_rooms USING (((auth.jwt() ->> 'role'::text) = 'service_role'::text));


--
-- Name: ambulance_streaming_sessions sessions_select_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY sessions_select_policy ON public.ambulance_streaming_sessions FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: ambulance_streaming_sessions sessions_service_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY sessions_service_policy ON public.ambulance_streaming_sessions USING (((auth.jwt() ->> 'role'::text) = 'service_role'::text));


--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: prefixes; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.prefixes ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- Name: supabase_realtime_messages_publication; Type: PUBLICATION; Schema: -; Owner: supabase_admin
--

CREATE PUBLICATION supabase_realtime_messages_publication WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime_messages_publication OWNER TO supabase_admin;

--
-- Name: supabase_realtime_messages_publication messages; Type: PUBLICATION TABLE; Schema: realtime; Owner: supabase_admin
--

ALTER PUBLICATION supabase_realtime_messages_publication ADD TABLE ONLY realtime.messages;


--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT USAGE ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;


--
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA storage TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- Name: SCHEMA vault; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA vault TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA vault TO service_role;


--
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;
GRANT ALL ON FUNCTION auth.email() TO postgres;


--
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;
GRANT ALL ON FUNCTION auth.role() TO postgres;


--
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;
GRANT ALL ON FUNCTION auth.uid() TO postgres;


--
-- Name: FUNCTION algorithm_sign(signables text, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) TO dashboard_user;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint) TO dashboard_user;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION sign(payload json, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) TO dashboard_user;


--
-- Name: FUNCTION try_cast_double(inp text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.try_cast_double(inp text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.try_cast_double(inp text) TO dashboard_user;


--
-- Name: FUNCTION url_decode(data text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.url_decode(data text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.url_decode(data text) TO dashboard_user;


--
-- Name: FUNCTION url_encode(data bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.url_encode(data bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.url_encode(data bytea) TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;


--
-- Name: FUNCTION verify(token text, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) TO dashboard_user;


--
-- Name: FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;


--
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO postgres;


--
-- Name: FUNCTION crypto_aead_det_decrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea); Type: ACL; Schema: pgsodium; Owner: pgsodium_keymaker
--

GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_decrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea) TO service_role;


--
-- Name: FUNCTION crypto_aead_det_encrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea); Type: ACL; Schema: pgsodium; Owner: pgsodium_keymaker
--

GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_encrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea) TO service_role;


--
-- Name: FUNCTION crypto_aead_det_keygen(); Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_keygen() TO service_role;


--
-- Name: FUNCTION calculate_session_duration(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.calculate_session_duration() TO anon;
GRANT ALL ON FUNCTION public.calculate_session_duration() TO authenticated;
GRANT ALL ON FUNCTION public.calculate_session_duration() TO service_role;


--
-- Name: FUNCTION disconnect_rooms_on_session_end(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.disconnect_rooms_on_session_end() TO anon;
GRANT ALL ON FUNCTION public.disconnect_rooms_on_session_end() TO authenticated;
GRANT ALL ON FUNCTION public.disconnect_rooms_on_session_end() TO service_role;


--
-- Name: FUNCTION manual_disconnect_session_rooms(session_uuid uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.manual_disconnect_session_rooms(session_uuid uuid) TO anon;
GRANT ALL ON FUNCTION public.manual_disconnect_session_rooms(session_uuid uuid) TO authenticated;
GRANT ALL ON FUNCTION public.manual_disconnect_session_rooms(session_uuid uuid) TO service_role;


--
-- Name: FUNCTION update_ambulance_camera_count(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_ambulance_camera_count() TO anon;
GRANT ALL ON FUNCTION public.update_ambulance_camera_count() TO authenticated;
GRANT ALL ON FUNCTION public.update_ambulance_camera_count() TO service_role;


--
-- Name: FUNCTION update_room_last_seen(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_room_last_seen() TO anon;
GRANT ALL ON FUNCTION public.update_room_last_seen() TO authenticated;
GRANT ALL ON FUNCTION public.update_room_last_seen() TO service_role;


--
-- Name: FUNCTION update_session_status(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_session_status() TO anon;
GRANT ALL ON FUNCTION public.update_session_status() TO authenticated;
GRANT ALL ON FUNCTION public.update_session_status() TO service_role;


--
-- Name: FUNCTION update_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_updated_at() TO anon;
GRANT ALL ON FUNCTION public.update_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.update_updated_at() TO service_role;


--
-- Name: FUNCTION update_updated_at_column(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_updated_at_column() TO anon;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO authenticated;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO service_role;


--
-- Name: FUNCTION apply_rls(wal jsonb, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO postgres;
GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO dashboard_user;


--
-- Name: FUNCTION build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO anon;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO service_role;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION "cast"(val text, type_ regtype); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO service_role;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO supabase_realtime_admin;


--
-- Name: FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO service_role;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO supabase_realtime_admin;


--
-- Name: FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO service_role;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION quote_wal2json(entity regclass); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO service_role;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO supabase_realtime_admin;


--
-- Name: FUNCTION send(payload jsonb, event text, topic text, private boolean); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO dashboard_user;


--
-- Name: FUNCTION subscription_check_filters(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_realtime_admin;


--
-- Name: FUNCTION to_regrole(role_name text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO service_role;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO supabase_realtime_admin;


--
-- Name: FUNCTION topic(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;


--
-- Name: FUNCTION can_insert_object(bucketid text, name text, owner uuid, metadata jsonb); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) TO postgres;


--
-- Name: FUNCTION extension(name text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.extension(name text) TO postgres;


--
-- Name: FUNCTION filename(name text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.filename(name text) TO postgres;


--
-- Name: FUNCTION foldername(name text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.foldername(name text) TO postgres;


--
-- Name: FUNCTION list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text) TO postgres;


--
-- Name: FUNCTION list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text) TO postgres;


--
-- Name: FUNCTION operation(); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.operation() TO postgres;


--
-- Name: FUNCTION search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) TO postgres;


--
-- Name: FUNCTION update_updated_at_column(); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.update_updated_at_column() TO postgres;


--
-- Name: FUNCTION _crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO service_role;


--
-- Name: FUNCTION create_secret(new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- Name: FUNCTION update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.flow_state TO dashboard_user;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE oauth_clients; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.oauth_clients TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.oauth_clients TO dashboard_user;


--
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


--
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE extensions.pg_stat_statements TO dashboard_user;


--
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE extensions.pg_stat_statements_info TO dashboard_user;


--
-- Name: TABLE decrypted_key; Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE pgsodium.decrypted_key TO pgsodium_keyholder;


--
-- Name: TABLE masking_rule; Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE pgsodium.masking_rule TO pgsodium_keyholder;


--
-- Name: TABLE mask_columns; Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE pgsodium.mask_columns TO pgsodium_keyholder;


--
-- Name: TABLE ai_detections; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.ai_detections TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.ai_detections TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.ai_detections TO service_role;


--
-- Name: TABLE ambulance_streaming_sessions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.ambulance_streaming_sessions TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.ambulance_streaming_sessions TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.ambulance_streaming_sessions TO service_role;


--
-- Name: TABLE ambulances; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.ambulances TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.ambulances TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.ambulances TO service_role;


--
-- Name: TABLE camera_streaming_rooms; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.camera_streaming_rooms TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.camera_streaming_rooms TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.camera_streaming_rooms TO service_role;


--
-- Name: TABLE cameras; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.cameras TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.cameras TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.cameras TO service_role;


--
-- Name: TABLE ambulance_streaming_status; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.ambulance_streaming_status TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.ambulance_streaming_status TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.ambulance_streaming_status TO service_role;


--
-- Name: TABLE camera_health_status; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.camera_health_status TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.camera_health_status TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.camera_health_status TO service_role;


--
-- Name: TABLE doctor; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.doctor TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.doctor TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.doctor TO service_role;


--
-- Name: TABLE medical_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.medical_history TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.medical_history TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.medical_history TO service_role;


--
-- Name: TABLE note; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.note TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.note TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.note TO service_role;


--
-- Name: TABLE patient_event; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.patient_event TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.patient_event TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.patient_event TO service_role;


--
-- Name: TABLE patients; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.patients TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.patients TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.patients TO service_role;


--
-- Name: TABLE video; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.video TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.video TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.video TO service_role;


--
-- Name: TABLE messages; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO service_role;


--
-- Name: TABLE messages_2025_09_26; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_09_26 TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_09_26 TO dashboard_user;


--
-- Name: TABLE messages_2025_09_27; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_09_27 TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_09_27 TO dashboard_user;


--
-- Name: TABLE messages_2025_09_28; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_09_28 TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_09_28 TO dashboard_user;


--
-- Name: TABLE messages_2025_09_29; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_09_29 TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_09_29 TO dashboard_user;


--
-- Name: TABLE messages_2025_09_30; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_09_30 TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_09_30 TO dashboard_user;


--
-- Name: TABLE messages_2025_10_01; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_01 TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_01 TO dashboard_user;


--
-- Name: TABLE messages_2025_10_02; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_02 TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_02 TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.schema_migrations TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.schema_migrations TO dashboard_user;
GRANT SELECT ON TABLE realtime.schema_migrations TO anon;
GRANT SELECT ON TABLE realtime.schema_migrations TO authenticated;
GRANT SELECT ON TABLE realtime.schema_migrations TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.schema_migrations TO supabase_realtime_admin;


--
-- Name: TABLE subscription; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.subscription TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.subscription TO dashboard_user;
GRANT SELECT ON TABLE realtime.subscription TO anon;
GRANT SELECT ON TABLE realtime.subscription TO authenticated;
GRANT SELECT ON TABLE realtime.subscription TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.subscription TO supabase_realtime_admin;


--
-- Name: SEQUENCE subscription_id_seq; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_realtime_admin;


--
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets TO postgres WITH GRANT OPTION;


--
-- Name: TABLE buckets_analytics; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets_analytics TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets_analytics TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets_analytics TO anon;


--
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.objects TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.objects TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.objects TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.objects TO postgres WITH GRANT OPTION;


--
-- Name: TABLE prefixes; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.prefixes TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.prefixes TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.prefixes TO anon;


--
-- Name: TABLE s3_multipart_uploads; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.s3_multipart_uploads TO postgres;


--
-- Name: TABLE s3_multipart_uploads_parts; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.s3_multipart_uploads_parts TO postgres;


--
-- Name: TABLE secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.secrets TO service_role;


--
-- Name: TABLE decrypted_secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.decrypted_secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.decrypted_secrets TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: pgsodium; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium GRANT ALL ON SEQUENCES TO pgsodium_keyholder;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: pgsodium; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO pgsodium_keyholder;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: pgsodium_masks; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium_masks GRANT ALL ON SEQUENCES TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: pgsodium_masks; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium_masks GRANT ALL ON FUNCTIONS TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: pgsodium_masks; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium_masks GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


ALTER EVENT TRIGGER issue_graphql_placeholder OWNER TO supabase_admin;

--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


ALTER EVENT TRIGGER issue_pg_cron_access OWNER TO supabase_admin;

--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


ALTER EVENT TRIGGER issue_pg_graphql_access OWNER TO supabase_admin;

--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


ALTER EVENT TRIGGER issue_pg_net_access OWNER TO supabase_admin;

--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


ALTER EVENT TRIGGER pgrst_ddl_watch OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


ALTER EVENT TRIGGER pgrst_drop_watch OWNER TO supabase_admin;

--
-- PostgreSQL database dump complete
--

