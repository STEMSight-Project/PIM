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
-- Name: search_v2(text, text, integer, integer, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
BEGIN
    RETURN query EXECUTE
        $sql$
        SELECT * FROM (
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name || '/' AS name,
                    NULL::uuid AS id,
                    NULL::timestamptz AS updated_at,
                    NULL::timestamptz AS created_at,
                    NULL::jsonb AS metadata
                FROM storage.prefixes
                WHERE name COLLATE "C" LIKE $1 || '%'
                AND bucket_id = $2
                AND level = $4
                AND name COLLATE "C" > $5
                ORDER BY prefixes.name COLLATE "C" LIMIT $3
            )
            UNION ALL
            (SELECT split_part(name, '/', $4) AS key,
                name,
                id,
                updated_at,
                created_at,
                metadata
            FROM storage.objects
            WHERE name COLLATE "C" LIKE $1 || '%'
                AND bucket_id = $2
                AND level = $4
                AND name COLLATE "C" > $5
            ORDER BY name COLLATE "C" LIMIT $3)
        ) obj
        ORDER BY name COLLATE "C" LIMIT $3;
        $sql$
        USING prefix, bucket_name, limits, levels, start_after;
END;
$_$;


ALTER FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer, levels integer, start_after text) OWNER TO supabase_storage_admin;

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
00000000-0000-0000-0000-000000000000	a4bba810-8ea5-4a69-ba0c-13c3bada95ad	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 08:16:15.014054+00	
00000000-0000-0000-0000-000000000000	75617485-2102-4ace-80fe-daacc09907e8	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 08:17:48.441436+00	
00000000-0000-0000-0000-000000000000	bf93668c-36c2-4962-8956-99de0f65eab7	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 08:22:28.947741+00	
00000000-0000-0000-0000-000000000000	db431328-0c5a-42f5-9a9f-cb6d933f8a1c	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 08:31:59.385175+00	
00000000-0000-0000-0000-000000000000	d1823d5b-736a-48bb-9e2a-5c76bea59252	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 09:31:51.376467+00	
00000000-0000-0000-0000-000000000000	bfb73a0b-50c3-49d3-aa95-42323b8cf915	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 09:31:51.401689+00	
00000000-0000-0000-0000-000000000000	d2481269-5a27-4b9d-aacc-d949c9842884	{"action":"token_refreshed","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 09:31:51.564843+00	
00000000-0000-0000-0000-000000000000	6846c6cb-9e50-4119-a930-718610208308	{"action":"token_revoked","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"token"}	2025-09-12 09:31:51.56689+00	
00000000-0000-0000-0000-000000000000	e7d1158d-859c-40d9-9c06-1713fcc0120b	{"action":"login","actor_id":"3d05eadb-9eb9-4368-8928-87ccd7783f32","actor_username":"nguyenphuctran@csus.edu","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-12 10:29:04.773388+00	
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
c96981e5-0436-43d2-b096-79dc929f0fb5	c96981e5-0436-43d2-b096-79dc929f0fb5	{"sub": "c96981e5-0436-43d2-b096-79dc929f0fb5", "email": "phernandez4@csus.edu", "email_verified": false, "phone_verified": false}	email	2025-05-03 20:41:08.585371+00	2025-05-03 20:41:08.585434+00	2025-05-03 20:41:08.585434+00	971a9c76-5276-4636-ac92-8d8a248a2d1e
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
00000000-0000-0000-0000-000000000000	430	upfujyb5adop	bf250d15-2188-413b-b954-120a31ca5840	t	2025-08-29 16:39:12.5573+00	2025-08-29 16:39:33.430021+00	lta7g2pjymz6	1a9f0bad-6fe3-4494-a78b-fd90b1f1ffe0
00000000-0000-0000-0000-000000000000	431	eiv6ad7363xg	bf250d15-2188-413b-b954-120a31ca5840	t	2025-08-29 16:39:33.433173+00	2025-08-29 16:40:12.566799+00	upfujyb5adop	1a9f0bad-6fe3-4494-a78b-fd90b1f1ffe0
00000000-0000-0000-0000-000000000000	432	grnnwiepurmn	bf250d15-2188-413b-b954-120a31ca5840	t	2025-08-29 16:40:12.567194+00	2025-08-29 16:40:14.650591+00	eiv6ad7363xg	1a9f0bad-6fe3-4494-a78b-fd90b1f1ffe0
00000000-0000-0000-0000-000000000000	433	7lp2sotyykt6	bf250d15-2188-413b-b954-120a31ca5840	t	2025-08-29 16:40:14.651347+00	2025-08-29 16:40:20.459663+00	grnnwiepurmn	1a9f0bad-6fe3-4494-a78b-fd90b1f1ffe0
00000000-0000-0000-0000-000000000000	434	lhrnqr3u2chj	bf250d15-2188-413b-b954-120a31ca5840	f	2025-08-29 16:40:20.460706+00	2025-08-29 16:40:20.460706+00	7lp2sotyykt6	1a9f0bad-6fe3-4494-a78b-fd90b1f1ffe0
00000000-0000-0000-0000-000000000000	435	un544z5fycp6	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-04 02:57:31.633346+00	2025-09-04 02:57:31.633346+00	\N	72c3ee15-f774-4706-9f43-c60a75b3f7e3
00000000-0000-0000-0000-000000000000	436	n2fillpy2vhw	bf250d15-2188-413b-b954-120a31ca5840	t	2025-09-04 03:00:22.149971+00	2025-09-04 03:00:24.786952+00	\N	e3dd638f-dd2c-483c-8b9e-ff2bd331fc05
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
00000000-0000-0000-0000-000000000000	461	svag4qeim7lc	bf250d15-2188-413b-b954-120a31ca5840	f	2025-09-05 06:41:54.123108+00	2025-09-05 06:41:54.123108+00	\N	f716839c-35ab-48f0-92cb-6e0db330368a
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
00000000-0000-0000-0000-000000000000	515	px2h2h33w4mb	3d05eadb-9eb9-4368-8928-87ccd7783f32	f	2025-09-14 07:11:23.28809+00	2025-09-14 07:11:23.28809+00	\N	ac34c1a7-8bff-4836-b952-48b0cdade96e
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
f716839c-35ab-48f0-92cb-6e0db330368a	bf250d15-2188-413b-b954-120a31ca5840	2025-09-05 06:41:54.118954+00	2025-09-05 06:41:54.118954+00	\N	aal1	\N	\N	python-httpx/0.28.1	73.151.135.139	\N
5daffb69-09f0-4706-a823-e4ee235600b9	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-13 08:33:49.53383+00	2025-09-13 08:33:49.53383+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
104e3d9e-15e9-4f01-b2a5-1ad9b02a6bd5	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-13 21:26:35.013822+00	2025-09-13 22:26:26.072012+00	\N	aal1	\N	2025-09-13 22:26:26.070547	python-httpx/0.27.0	73.2.33.92	\N
5cdc7063-dfdf-4f8a-ac00-118100fa5ad1	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-14 06:06:15.644082+00	2025-09-14 06:06:15.644082+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
8434698b-7bf5-4401-a6db-2968f956f61c	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-14 06:47:42.205393+00	2025-09-14 06:47:42.205393+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
ac34c1a7-8bff-4836-b952-48b0cdade96e	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-14 07:11:23.278391+00	2025-09-14 07:11:23.278391+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
21afe93a-435c-42df-97fa-67ea6be55f69	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 06:51:29.104369+00	2025-09-12 07:22:23.295059+00	\N	aal1	\N	2025-09-12 07:22:23.294993	python-httpx/0.27.0	73.2.33.92	\N
a220fcaf-6c3d-43f1-87b8-6a8197667c54	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 08:16:15.015299+00	2025-09-12 08:16:15.015299+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
c553d554-172d-418c-ace5-acf8953b5867	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 08:17:48.442658+00	2025-09-12 08:17:48.442658+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
964677c1-610a-429a-a6a9-56980139259a	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 08:22:28.949786+00	2025-09-12 08:22:28.949786+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
2ee64cf8-a1a6-4053-a778-6ed2cc97aa1f	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 08:31:59.411793+00	2025-09-12 09:31:51.574464+00	\N	aal1	\N	2025-09-12 09:31:51.574381	python-httpx/0.27.0	73.2.33.92	\N
47387d9c-a03b-497c-92ca-c7e33d1436c3	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 10:29:04.804953+00	2025-09-12 10:29:04.804953+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
4e2712c9-7762-4cab-87e4-dd95c76b0a9a	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 11:21:31.857077+00	2025-09-12 18:01:43.616559+00	\N	aal1	\N	2025-09-12 18:01:43.616488	python-httpx/0.27.0	73.2.33.92	\N
76140067-cb3f-43a6-9838-1229ba6a69ce	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 18:13:14.931471+00	2025-09-12 18:13:14.931471+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
e2d152b3-e4b6-4cc6-8c35-ade398896c11	3d05eadb-9eb9-4368-8928-87ccd7783f32	2025-09-12 19:01:28.963725+00	2025-09-12 19:01:28.963725+00	\N	aal1	\N	\N	python-httpx/0.27.0	73.2.33.92	\N
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
00000000-0000-0000-0000-000000000000	c96981e5-0436-43d2-b096-79dc929f0fb5	authenticated	authenticated	phernandez4@csus.edu	$2a$10$gfsZqSgrf4KzdsSnFDBw/ulJlpVhhXSNTACfqx0haQsUb.KRf3h3C	2025-05-03 20:41:08.589336+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2025-05-03 20:41:08.578781+00	2025-05-03 20:41:08.590198+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3d05eadb-9eb9-4368-8928-87ccd7783f32	authenticated	authenticated	nguyenphuctran@csus.edu	$2a$10$9kRVXnt.pc/FcdYECD5NMuETcvVxGVwdVOp2vSev12A4vjPOLpbUy	2025-03-22 07:52:49.13657+00	\N		\N		\N			\N	2025-09-14 07:11:23.278294+00	{"role": "super-admin", "provider": "email", "providers": ["email"]}	{"sub": "3d05eadb-9eb9-4368-8928-87ccd7783f32", "email": "nguyenphuctran@csus.edu", "email_verified": true, "phone_verified": false}	\N	2025-03-22 07:51:10.77988+00	2025-09-14 07:11:23.30112+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	bf250d15-2188-413b-b954-120a31ca5840	authenticated	authenticated	mikefeschenko@yahoo.com	$2a$10$4S/tF085PY7b3EcCYfSVruQl/Gh2MBF8dYGsTt6/YipivEtgC3686	2025-03-26 18:53:16.04825+00	\N		\N		\N			\N	2025-09-05 06:41:54.117611+00	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2025-03-26 18:53:15.988504+00	2025-09-05 06:41:54.12723+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: key; Type: TABLE DATA; Schema: pgsodium; Owner: supabase_admin
--

COPY pgsodium.key (id, status, created, expires, key_type, key_id, key_context, name, associated_data, raw_key, raw_key_nonce, parent_key, comment, user_data) FROM stdin;
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
\.


--
-- Data for Name: patient_event; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_event (id, type, confidence, validation_status, created_at, video_id, "timestamp") FROM stdin;
3203a6d5-7286-4abe-89e3-aacd7f9dbffc	tremor	95	pending	2025-04-21 01:23:59.632322+00	25273293-c532-4bd2-9ccf-e57dfd94c8bf	30
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
\.


--
-- Data for Name: video; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.video (patient_id, description, created_at, id, file_path, duration) FROM stdin;
0cabaa76-b0cb-4785-ae2a-9b5e96739ae3	\N	2025-04-19 20:29:29.361608+00	8513c73d-6e90-4968-8401-85b71aa208a6	timer-videos/3min-timer.mp4	0
11b588ef-5dfb-49b6-82bb-253752f1c119	\N	2025-04-19 20:31:29.14161+00	59ed9078-a1e6-44fa-b232-bf5c318cb601	timer-videos/4min-timer.mp4	0
60ed81da-0d98-4283-9f33-c9af7cd06147	\N	2025-04-19 20:38:59.88791+00	437401d0-674e-45b9-a175-ff0c7de449fb	timer-videos/5min-timer(1).mp4	0
2180abd2-1a06-4c37-bb00-627b28b58442	\N	2025-04-19 20:50:06.138916+00	25273293-c532-4bd2-9ccf-e57dfd94c8bf	timer-videos/5min-timer.mp4	0
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

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 515, true);


--
-- Name: key_key_id_seq; Type: SEQUENCE SET; Schema: pgsodium; Owner: supabase_admin
--

SELECT pg_catalog.setval('pgsodium.key_key_id_seq', 1, false);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: supabase_admin
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


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
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


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

GRANT USAGE ON SCHEMA storage TO postgres;
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

