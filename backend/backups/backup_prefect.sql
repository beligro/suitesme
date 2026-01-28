--
-- PostgreSQL database dump
--

\restrict KBm4kACmr2DBlG8lQQGqTxAz4gQGpXyfBOdVYpjBVF0grX2Xls8xarOwvS5WE9p

-- Dumped from database version 15.14
-- Dumped by pg_dump version 15.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: deployment_status; Type: TYPE; Schema: public; Owner: prefect
--

CREATE TYPE public.deployment_status AS ENUM (
    'READY',
    'NOT_READY'
);


ALTER TYPE public.deployment_status OWNER TO prefect;

--
-- Name: state_type; Type: TYPE; Schema: public; Owner: prefect
--

CREATE TYPE public.state_type AS ENUM (
    'SCHEDULED',
    'PENDING',
    'RUNNING',
    'COMPLETED',
    'FAILED',
    'CANCELLED',
    'CRASHED',
    'PAUSED',
    'CANCELLING'
);


ALTER TYPE public.state_type OWNER TO prefect;

--
-- Name: work_pool_status; Type: TYPE; Schema: public; Owner: prefect
--

CREATE TYPE public.work_pool_status AS ENUM (
    'READY',
    'NOT_READY',
    'PAUSED'
);


ALTER TYPE public.work_pool_status OWNER TO prefect;

--
-- Name: work_queue_status; Type: TYPE; Schema: public; Owner: prefect
--

CREATE TYPE public.work_queue_status AS ENUM (
    'READY',
    'NOT_READY',
    'PAUSED'
);


ALTER TYPE public.work_queue_status OWNER TO prefect;

--
-- Name: worker_status; Type: TYPE; Schema: public; Owner: prefect
--

CREATE TYPE public.worker_status AS ENUM (
    'ONLINE',
    'OFFLINE'
);


ALTER TYPE public.worker_status OWNER TO prefect;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agent; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.agent (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    last_activity_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    work_queue_id uuid NOT NULL
);


ALTER TABLE public.agent OWNER TO prefect;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO prefect;

--
-- Name: artifact; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.artifact (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    key character varying,
    type character varying,
    data json,
    metadata_ json,
    task_run_id uuid,
    flow_run_id uuid,
    description character varying
);


ALTER TABLE public.artifact OWNER TO prefect;

--
-- Name: artifact_collection; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.artifact_collection (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    key character varying NOT NULL,
    latest_id uuid,
    task_run_id uuid,
    flow_run_id uuid,
    type character varying,
    data json,
    description character varying,
    metadata_ json
);


ALTER TABLE public.artifact_collection OWNER TO prefect;

--
-- Name: automation; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.automation (
    name character varying NOT NULL,
    description character varying NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    trigger jsonb NOT NULL,
    actions jsonb NOT NULL,
    actions_on_trigger jsonb DEFAULT '[]'::jsonb NOT NULL,
    actions_on_resolve jsonb DEFAULT '[]'::jsonb NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.automation OWNER TO prefect;

--
-- Name: automation_bucket; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.automation_bucket (
    automation_id uuid NOT NULL,
    trigger_id uuid NOT NULL,
    bucketing_key jsonb NOT NULL,
    last_event jsonb,
    start timestamp with time zone NOT NULL,
    "end" timestamp with time zone NOT NULL,
    count integer NOT NULL,
    last_operation character varying,
    triggered_at timestamp with time zone,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.automation_bucket OWNER TO prefect;

--
-- Name: automation_event_follower; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.automation_event_follower (
    leader_event_id uuid NOT NULL,
    follower_event_id uuid NOT NULL,
    received timestamp with time zone NOT NULL,
    follower jsonb NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.automation_event_follower OWNER TO prefect;

--
-- Name: automation_related_resource; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.automation_related_resource (
    automation_id uuid NOT NULL,
    resource_id character varying,
    automation_owned_by_resource boolean DEFAULT false NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.automation_related_resource OWNER TO prefect;

--
-- Name: block_document; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.block_document (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    block_schema_id uuid NOT NULL,
    block_type_id uuid NOT NULL,
    is_anonymous boolean DEFAULT false NOT NULL,
    block_type_name character varying
);


ALTER TABLE public.block_document OWNER TO prefect;

--
-- Name: block_document_reference; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.block_document_reference (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    parent_block_document_id uuid NOT NULL,
    reference_block_document_id uuid NOT NULL
);


ALTER TABLE public.block_document_reference OWNER TO prefect;

--
-- Name: block_schema; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.block_schema (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fields jsonb DEFAULT '{}'::jsonb NOT NULL,
    checksum character varying NOT NULL,
    block_type_id uuid NOT NULL,
    capabilities jsonb DEFAULT '[]'::jsonb NOT NULL,
    version character varying DEFAULT 'non-versioned'::character varying NOT NULL
);


ALTER TABLE public.block_schema OWNER TO prefect;

--
-- Name: block_schema_reference; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.block_schema_reference (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    parent_block_schema_id uuid NOT NULL,
    reference_block_schema_id uuid NOT NULL
);


ALTER TABLE public.block_schema_reference OWNER TO prefect;

--
-- Name: block_type; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.block_type (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    logo_url character varying,
    documentation_url character varying,
    description character varying,
    code_example character varying,
    is_protected boolean DEFAULT false NOT NULL,
    slug character varying NOT NULL
);


ALTER TABLE public.block_type OWNER TO prefect;

--
-- Name: composite_trigger_child_firing; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.composite_trigger_child_firing (
    automation_id uuid NOT NULL,
    parent_trigger_id uuid NOT NULL,
    child_trigger_id uuid NOT NULL,
    child_firing_id uuid NOT NULL,
    child_fired_at timestamp with time zone,
    child_firing jsonb NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.composite_trigger_child_firing OWNER TO prefect;

--
-- Name: concurrency_limit; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.concurrency_limit (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    tag character varying NOT NULL,
    concurrency_limit integer NOT NULL,
    active_slots jsonb DEFAULT '[]'::jsonb NOT NULL
);


ALTER TABLE public.concurrency_limit OWNER TO prefect;

--
-- Name: concurrency_limit_v2; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.concurrency_limit_v2 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    active boolean NOT NULL,
    name character varying NOT NULL,
    "limit" integer NOT NULL,
    active_slots integer NOT NULL,
    denied_slots integer NOT NULL,
    slot_decay_per_second double precision NOT NULL,
    avg_slot_occupancy_seconds double precision NOT NULL
);


ALTER TABLE public.concurrency_limit_v2 OWNER TO prefect;

--
-- Name: configuration; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.configuration (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    key character varying NOT NULL,
    value jsonb NOT NULL
);


ALTER TABLE public.configuration OWNER TO prefect;

--
-- Name: csrf_token; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.csrf_token (
    token character varying NOT NULL,
    client character varying NOT NULL,
    expiration timestamp with time zone NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.csrf_token OWNER TO prefect;

--
-- Name: deployment; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.deployment (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    schedule jsonb,
    is_schedule_active boolean DEFAULT true NOT NULL,
    tags jsonb DEFAULT '[]'::jsonb NOT NULL,
    parameters jsonb DEFAULT '{}'::jsonb NOT NULL,
    flow_data jsonb,
    flow_id uuid NOT NULL,
    infrastructure_document_id uuid,
    description text,
    manifest_path character varying,
    parameter_openapi_schema jsonb,
    storage_document_id uuid,
    version character varying,
    infra_overrides jsonb DEFAULT '{}'::jsonb NOT NULL,
    path character varying,
    entrypoint character varying,
    work_queue_name character varying,
    created_by jsonb,
    updated_by jsonb,
    work_queue_id uuid,
    pull_steps jsonb,
    enforce_parameter_schema boolean DEFAULT false NOT NULL,
    last_polled timestamp with time zone,
    paused boolean DEFAULT false NOT NULL,
    status public.deployment_status DEFAULT 'NOT_READY'::public.deployment_status NOT NULL
);


ALTER TABLE public.deployment OWNER TO prefect;

--
-- Name: deployment_schedule; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.deployment_schedule (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    schedule jsonb NOT NULL,
    active boolean NOT NULL,
    deployment_id uuid NOT NULL,
    max_active_runs integer,
    max_scheduled_runs integer,
    catchup boolean DEFAULT false NOT NULL
);


ALTER TABLE public.deployment_schedule OWNER TO prefect;

--
-- Name: event_resources; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.event_resources (
    occurred timestamp with time zone NOT NULL,
    resource_id text NOT NULL,
    resource_role text NOT NULL,
    resource json NOT NULL,
    event_id uuid NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.event_resources OWNER TO prefect;

--
-- Name: events; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.events (
    occurred timestamp with time zone NOT NULL,
    event text NOT NULL,
    resource_id text NOT NULL,
    resource jsonb NOT NULL,
    related_resource_ids jsonb DEFAULT '[]'::jsonb NOT NULL,
    related jsonb DEFAULT '[]'::jsonb NOT NULL,
    payload jsonb NOT NULL,
    received timestamp with time zone NOT NULL,
    recorded timestamp with time zone NOT NULL,
    follows uuid,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.events OWNER TO prefect;

--
-- Name: flow; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.flow (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    tags jsonb DEFAULT '[]'::jsonb NOT NULL
);


ALTER TABLE public.flow OWNER TO prefect;

--
-- Name: flow_run; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.flow_run (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    state_type public.state_type,
    run_count integer DEFAULT 0 NOT NULL,
    expected_start_time timestamp with time zone,
    next_scheduled_start_time timestamp with time zone,
    start_time timestamp with time zone,
    end_time timestamp with time zone,
    total_run_time interval DEFAULT '00:00:00'::interval NOT NULL,
    flow_version character varying,
    parameters jsonb DEFAULT '{}'::jsonb NOT NULL,
    idempotency_key character varying,
    context jsonb DEFAULT '{}'::jsonb NOT NULL,
    empirical_policy jsonb DEFAULT '{}'::jsonb NOT NULL,
    tags jsonb DEFAULT '[]'::jsonb NOT NULL,
    auto_scheduled boolean DEFAULT false NOT NULL,
    flow_id uuid NOT NULL,
    deployment_id uuid,
    parent_task_run_id uuid,
    state_id uuid,
    state_name character varying,
    infrastructure_document_id uuid,
    work_queue_name character varying,
    state_timestamp timestamp with time zone,
    created_by jsonb,
    infrastructure_pid character varying,
    work_queue_id uuid,
    job_variables jsonb DEFAULT '{}'::jsonb,
    deployment_version character varying
);


ALTER TABLE public.flow_run OWNER TO prefect;

--
-- Name: flow_run_input; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.flow_run_input (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    key character varying NOT NULL,
    value text NOT NULL,
    flow_run_id uuid NOT NULL,
    sender character varying
);


ALTER TABLE public.flow_run_input OWNER TO prefect;

--
-- Name: flow_run_notification_policy; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.flow_run_notification_policy (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    state_names jsonb DEFAULT '[]'::jsonb NOT NULL,
    tags jsonb DEFAULT '[]'::jsonb NOT NULL,
    message_template character varying,
    block_document_id uuid NOT NULL
);


ALTER TABLE public.flow_run_notification_policy OWNER TO prefect;

--
-- Name: flow_run_notification_queue; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.flow_run_notification_queue (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    flow_run_notification_policy_id uuid NOT NULL,
    flow_run_state_id uuid NOT NULL
);


ALTER TABLE public.flow_run_notification_queue OWNER TO prefect;

--
-- Name: flow_run_state; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.flow_run_state (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    type public.state_type NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    message character varying,
    state_details jsonb DEFAULT '{}'::jsonb NOT NULL,
    data jsonb,
    flow_run_id uuid NOT NULL,
    result_artifact_id uuid
);


ALTER TABLE public.flow_run_state OWNER TO prefect;

--
-- Name: log; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    level smallint NOT NULL,
    flow_run_id uuid,
    task_run_id uuid,
    message text NOT NULL,
    "timestamp" timestamp with time zone NOT NULL
);


ALTER TABLE public.log OWNER TO prefect;

--
-- Name: saved_search; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.saved_search (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    filters jsonb DEFAULT '[]'::jsonb NOT NULL
);


ALTER TABLE public.saved_search OWNER TO prefect;

--
-- Name: task_run; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.task_run (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    state_type public.state_type,
    run_count integer DEFAULT 0 NOT NULL,
    expected_start_time timestamp with time zone,
    next_scheduled_start_time timestamp with time zone,
    start_time timestamp with time zone,
    end_time timestamp with time zone,
    total_run_time interval DEFAULT '00:00:00'::interval NOT NULL,
    task_key character varying NOT NULL,
    dynamic_key character varying NOT NULL,
    cache_key character varying,
    cache_expiration timestamp with time zone,
    task_version character varying,
    empirical_policy jsonb DEFAULT '{}'::jsonb NOT NULL,
    task_inputs jsonb DEFAULT '{}'::jsonb NOT NULL,
    tags jsonb DEFAULT '[]'::jsonb NOT NULL,
    flow_run_id uuid,
    state_id uuid,
    state_name character varying,
    state_timestamp timestamp with time zone,
    flow_run_run_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.task_run OWNER TO prefect;

--
-- Name: task_run_state; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.task_run_state (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    type public.state_type NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    message character varying,
    state_details jsonb DEFAULT '{}'::jsonb NOT NULL,
    data jsonb,
    task_run_id uuid NOT NULL,
    result_artifact_id uuid
);


ALTER TABLE public.task_run_state OWNER TO prefect;

--
-- Name: task_run_state_cache; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.task_run_state_cache (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    cache_key character varying NOT NULL,
    cache_expiration timestamp with time zone,
    task_run_state_id uuid NOT NULL
);


ALTER TABLE public.task_run_state_cache OWNER TO prefect;

--
-- Name: variable; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.variable (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    value character varying NOT NULL,
    tags jsonb DEFAULT '[]'::jsonb NOT NULL
);


ALTER TABLE public.variable OWNER TO prefect;

--
-- Name: work_pool; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.work_pool (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    description character varying,
    type character varying NOT NULL,
    base_job_template jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_paused boolean DEFAULT false NOT NULL,
    concurrency_limit integer,
    default_queue_id uuid,
    status public.work_pool_status DEFAULT 'NOT_READY'::public.work_pool_status NOT NULL,
    last_transitioned_status_at timestamp with time zone,
    last_status_event_id uuid
);


ALTER TABLE public.work_pool OWNER TO prefect;

--
-- Name: work_queue; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.work_queue (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    filter jsonb,
    description character varying DEFAULT ''::character varying NOT NULL,
    is_paused boolean DEFAULT false NOT NULL,
    concurrency_limit integer,
    last_polled timestamp with time zone,
    priority integer DEFAULT 1 NOT NULL,
    work_pool_id uuid NOT NULL,
    status public.work_queue_status DEFAULT 'NOT_READY'::public.work_queue_status NOT NULL
);


ALTER TABLE public.work_queue OWNER TO prefect;

--
-- Name: worker; Type: TABLE; Schema: public; Owner: prefect
--

CREATE TABLE public.worker (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying NOT NULL,
    last_heartbeat_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    work_pool_id uuid NOT NULL,
    heartbeat_interval_seconds integer,
    status public.worker_status DEFAULT 'OFFLINE'::public.worker_status NOT NULL
);


ALTER TABLE public.worker OWNER TO prefect;

--
-- Data for Name: agent; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.agent (id, created, updated, name, last_activity_time, work_queue_id) FROM stdin;
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.alembic_version (version_num) FROM stdin;
b23c83a12cb4
\.


--
-- Data for Name: artifact; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.artifact (id, created, updated, key, type, data, metadata_, task_run_id, flow_run_id, description) FROM stdin;
\.


--
-- Data for Name: artifact_collection; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.artifact_collection (id, created, updated, key, latest_id, task_run_id, flow_run_id, type, data, description, metadata_) FROM stdin;
\.


--
-- Data for Name: automation; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.automation (name, description, enabled, trigger, actions, actions_on_trigger, actions_on_resolve, id, created, updated) FROM stdin;
\.


--
-- Data for Name: automation_bucket; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.automation_bucket (automation_id, trigger_id, bucketing_key, last_event, start, "end", count, last_operation, triggered_at, id, created, updated) FROM stdin;
\.


--
-- Data for Name: automation_event_follower; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.automation_event_follower (leader_event_id, follower_event_id, received, follower, id, created, updated) FROM stdin;
\.


--
-- Data for Name: automation_related_resource; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.automation_related_resource (automation_id, resource_id, automation_owned_by_resource, id, created, updated) FROM stdin;
\.


--
-- Data for Name: block_document; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.block_document (id, created, updated, name, data, block_schema_id, block_type_id, is_anonymous, block_type_name) FROM stdin;
23aa794b-4a92-434f-b10f-ec6fa8d17348	2025-11-12 11:45:04.154963+00	2025-11-12 11:45:04.154992+00	anonymous-3301f983-b7c4-46e3-bc7c-91132278ebf7	"gAAAAABpFHNA0nMzDeFn4MzQ5JpmrU1qVN6u1OX_Zjsnv_fL7rCRKiDUSXeaHEOW5dwDvbVV2RLV-pCi_Lyjda722AIyLVWHypqP67J15BaNh7BaKP7_rM4ho34BOMEoQQrJ-cxQguaT8mE_BQCI4RMtKiecGhv_IW1Xi69gQKXlM24pnWFCKz6smqHfJzem_m8lgj_Luiq0venW6uY25vFL4hnVZnqdlcAUCsky_jELvI6PXFmh3BQ="	1fee1371-af9b-44bc-99f2-253f8f592c33	8b809681-f571-4206-a179-9681d5c5cbfb	t	Process
06f61094-d1c3-4990-b0af-3aecc56293ad	2025-11-12 11:45:04.689933+00	2025-11-12 11:45:04.689954+00	anonymous-b84d7952-1a0f-437b-ae27-5d4991b68baa	"gAAAAABpFHNAJMYFIO_MXKjpPjmCi73KAmZ9ekc6ljJCkFddlIvVF_iL2GaDQziQm1NDwZI0Xa1SiZJIR3Hg49-0KlvTDhlyJu5snrSrxhifqRtEeOpRogPamMn1_XC1KcKKNgtixRIBw8vhkgH2H3_-ULWtKVdvHTl96nfhniTm06vwKu5GG1KRsC4EG3YfpGblKUDVzuVhYyRZuP9CIo1DHzi3ciEHiU7SQ9FHDQbw211Fvo0tRRQ="	1fee1371-af9b-44bc-99f2-253f8f592c33	8b809681-f571-4206-a179-9681d5c5cbfb	t	Process
efd456dc-5023-40b4-8a75-a793be43a0b8	2025-11-12 11:47:45.673195+00	2025-11-12 11:47:45.673218+00	anonymous-d66c00e4-ee5e-45a8-a9ed-f9541dc24ca7	"gAAAAABpFHPhG9znEQVOqpBKMx5358L4ZhHdZTwRUyweBAkcbtR6dd53-8OscceM0O81tipgyMdGdqq0Qg2NkGqmqcUNicSY-DIXuSJpN3_JHWPBeOrHZWK4kTaQmMf_l1dY4O5_GL8VXD04IIqQHFZG8ryk76P7qW1XwdtA6gmdLWkfzzrCoyMPmoFxjXAmfaTmIyBZHuXxTw06qLiCHnY7rzXvIiQqHgyvZKVYyNHF1sh_dbyQM3o="	1fee1371-af9b-44bc-99f2-253f8f592c33	8b809681-f571-4206-a179-9681d5c5cbfb	t	Process
\.


--
-- Data for Name: block_document_reference; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.block_document_reference (id, created, updated, name, parent_block_document_id, reference_block_document_id) FROM stdin;
\.


--
-- Data for Name: block_schema; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.block_schema (id, created, updated, fields, checksum, block_type_id, capabilities, version) FROM stdin;
057a67c7-6fd1-4abf-827e-ba4f198224a2	2025-11-10 15:29:43.969975+00	2025-11-10 15:29:43.969996+00	{"type": "object", "title": "Webhook", "required": ["url"], "properties": {"url": {"type": "string", "title": "Webhook URL", "format": "password", "examples": ["https://hooks.slack.com/XXX"], "writeOnly": true, "description": "The webhook URL."}, "method": {"enum": ["GET", "POST", "PUT", "PATCH", "DELETE"], "type": "string", "title": "Method", "default": "POST", "description": "The webhook request method. Defaults to `POST`."}, "headers": {"type": "object", "title": "Webhook Headers", "description": "A dictionary of headers to send with the webhook request."}, "allow_private_urls": {"type": "boolean", "title": "Allow Private Urls", "default": true, "description": "Whether to allow notifications to private URLs. Defaults to True."}}, "description": "Block that enables calling webhooks.", "secret_fields": ["url", "headers.*"], "block_type_slug": "webhook"}	sha256:9d0b4706b4c7a297b8e21bd5c95fcc6446357d5c310c257f2f99f025b61ee977	cf809fdf-fd78-4090-9687-f9f0ee245ecd	[]	2.20.18
4557cfab-4f31-4be7-80d7-970673574a77	2025-11-10 15:29:43.992929+00	2025-11-10 15:29:43.992942+00	{"type": "object", "title": "JSON", "required": ["value"], "properties": {"value": {"title": "Value", "description": "A JSON-compatible value."}}, "description": "A block that represents JSON", "secret_fields": [], "block_type_slug": "json"}	sha256:ef9b76010e0545bd7f2212029460731f66ccfce289affe4b504cbeb702fc8ea3	ae892096-ad00-46e6-83d8-83db23b85797	[]	2.20.18
580a8185-38e7-438e-9c3f-1f10f73b3793	2025-11-10 15:29:44.010767+00	2025-11-10 15:29:44.010781+00	{"type": "object", "title": "DateTime", "required": ["value"], "properties": {"value": {"type": "string", "title": "Value", "format": "date-time", "description": "An ISO 8601-compatible datetime value."}}, "description": "A block that represents a datetime", "secret_fields": [], "block_type_slug": "date-time"}	sha256:7943c88ca6ab22804082b595b9847d035a1364bdb23474c927317bcab9cb5d9c	e09eed89-2851-4abe-baa7-5dcb4eca8229	[]	2.20.18
bd1c0a5c-6b0e-4ec7-a6e3-c4f8a01ea1aa	2025-11-10 15:29:44.064703+00	2025-11-10 15:29:44.064717+00	{"type": "object", "title": "Secret", "required": ["value"], "properties": {"value": {"type": "string", "title": "Value", "format": "password", "writeOnly": true, "description": "A string value that should be kept secret."}}, "description": "A block that represents a secret value. The value stored in this block will be obfuscated when\\nthis block is logged or shown in the UI.", "secret_fields": ["value"], "block_type_slug": "secret"}	sha256:e6b26e0a0240eb112e604608338f863e5ca2f137936e310014bfa2139d0a9b6c	ebd43b6d-5bb8-4582-9001-5b658fbd70f0	[]	2.20.18
6aa2fe43-3bda-4a0c-ac31-bba9a3afbe8d	2025-11-10 15:29:44.088346+00	2025-11-10 15:29:44.088359+00	{"type": "object", "title": "LocalFileSystem", "properties": {"basepath": {"type": "string", "title": "Basepath", "description": "Default local path for this block to write to."}}, "description": "Store data as a file on a local file system.", "secret_fields": [], "block_type_slug": "local-file-system"}	sha256:6db1ab242e7b2b88a52dc137a7da3a373af63e0a103b9a91e060ed54a26f395a	3ce57538-7b29-4aa2-9ff7-cb5e26d01935	["put-directory", "read-path", "write-path", "get-directory"]	2.20.18
1fee1371-af9b-44bc-99f2-253f8f592c33	2025-11-10 15:29:44.101851+00	2025-11-10 15:29:44.101865+00	{"type": "object", "title": "Process", "properties": {"env": {"type": "object", "title": "Environment", "description": "Environment variables to set in the configured infrastructure.", "additionalProperties": {"type": "string"}}, "name": {"type": "string", "title": "Name", "description": "Name applied to the infrastructure for identification."}, "type": {"enum": ["process"], "type": "string", "title": "Type", "default": "process", "description": "The type of infrastructure."}, "labels": {"type": "object", "title": "Labels", "description": "Labels applied to the infrastructure for metadata purposes.", "additionalProperties": {"type": "string"}}, "command": {"type": "array", "items": {"type": "string"}, "title": "Command", "description": "The command to run in the infrastructure."}, "working_dir": {"anyOf": [{"type": "string"}, {"type": "string", "format": "path"}], "title": "Working Dir", "description": "If set, the process will open within the specified path as the working directory. Otherwise, a temporary directory will be created."}, "stream_output": {"type": "boolean", "title": "Stream Output", "default": true, "description": "If set, output will be streamed from the process to local standard output."}}, "description": "Run a command in a new process.\\n\\nCurrent environment variables and Prefect settings will be included in the created\\nprocess. Configured environment variables will override any current environment\\nvariables.", "secret_fields": [], "block_type_slug": "process"}	sha256:47c4ac364708f4a6f27fb10b18086ad92c0a53fbbdd9ba07c030467067979f84	8b809681-f571-4206-a179-9681d5c5cbfb	["run-infrastructure"]	2.20.18
0a64b8fd-eeac-4e70-9c7b-18e6f651d21c	2025-11-10 15:29:44.11951+00	2025-11-10 15:29:44.119522+00	{"type": "object", "title": "SlackWebhook", "required": ["url"], "properties": {"url": {"type": "string", "title": "Webhook URL", "format": "password", "examples": ["https://hooks.slack.com/XXX"], "writeOnly": true, "description": "Slack incoming webhook URL used to send notifications."}, "notify_type": {"enum": ["prefect_default", "info", "success", "warning", "failure"], "type": "string", "title": "Notify Type", "default": "prefect_default", "description": "The type of notification being performed; the prefect_default is a plain notification that does not attach an image."}, "allow_private_urls": {"type": "boolean", "title": "Allow Private Urls", "default": true, "description": "Whether to allow notifications to private URLs. Defaults to True."}}, "description": "Enables sending notifications via a provided Slack webhook.", "secret_fields": ["url"], "block_type_slug": "slack-webhook"}	sha256:27d4fa59cceca2b98793d6ef0f97fd3b416f9cacd26912573d8edc05ca1666b4	01b2484d-187f-4a91-b0de-a0a2fa054bbf	["notify"]	2.20.18
24070045-1811-4756-a97e-5fc5a06b3e06	2025-11-10 15:29:44.136338+00	2025-11-10 15:29:44.136353+00	{"type": "object", "title": "MicrosoftTeamsWebhook", "required": ["url"], "properties": {"url": {"type": "string", "title": "Webhook URL", "format": "password", "examples": ["https://prod-NO.LOCATION.logic.azure.com:443/workflows/WFID/triggers/manual/paths/invoke?sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=SIGNATURE"], "writeOnly": true, "description": "The Microsoft Power Automate (Workflows) URL used to send notifications to Teams."}, "wrap": {"type": "boolean", "title": "Wrap", "default": true, "description": "Wrap the notification text."}, "notify_type": {"enum": ["prefect_default", "info", "success", "warning", "failure"], "type": "string", "title": "Notify Type", "default": "prefect_default", "description": "The type of notification being performed; the prefect_default is a plain notification that does not attach an image."}, "include_image": {"type": "boolean", "title": "Include Image", "default": true, "description": "Include an image with the notification."}, "allow_private_urls": {"type": "boolean", "title": "Allow Private Urls", "default": true, "description": "Whether to allow notifications to private URLs. Defaults to True."}}, "description": "Enables sending notifications via a provided Microsoft Teams webhook.", "secret_fields": ["url"], "block_type_slug": "ms-teams-webhook"}	sha256:44ccbb7dde28e24524e192f9bc3d5fbca760e2230dd8732d51fa96d0f88e49e6	60f1a1ed-3cf7-44ea-82a4-161972502a8e	["notify"]	2.20.18
0ba3cdd4-a03f-452a-aa9b-76f8f06d25a0	2025-11-10 15:29:44.160801+00	2025-11-10 15:29:44.160815+00	{"type": "object", "title": "PagerDutyWebHook", "required": ["integration_key", "api_key"], "properties": {"group": {"type": "string", "title": "Group", "description": "The group string as part of the payload."}, "source": {"type": "string", "title": "Source", "default": "Prefect", "description": "The source string as part of the payload."}, "api_key": {"type": "string", "title": "API Key", "format": "password", "writeOnly": true, "description": "This can be found under Integrations. This must be provided alongside `integration_key`, but will error if provided alongside `url`."}, "class_id": {"type": "string", "title": "Class ID", "description": "The class string as part of the payload."}, "component": {"type": "string", "title": "Component", "default": "Notification", "description": "The component string as part of the payload."}, "notify_type": {"enum": ["info", "success", "warning", "failure"], "type": "string", "title": "Notify Type", "default": "info", "description": "The severity of the notification."}, "region_name": {"enum": ["us", "eu"], "type": "string", "title": "Region Name", "default": "us", "description": "The region name."}, "clickable_url": {"type": "string", "title": "Clickable URL", "format": "uri", "maxLength": 65536, "minLength": 1, "description": "A clickable URL to associate with the notice."}, "include_image": {"type": "boolean", "title": "Include Image", "default": true, "description": "Associate the notification status via a represented icon."}, "custom_details": {"type": "object", "title": "Custom Details", "examples": ["{\\"disk_space_left\\": \\"145GB\\"}"], "description": "Additional details to include as part of the payload.", "additionalProperties": {"type": "string"}}, "integration_key": {"type": "string", "title": "Integration Key", "format": "password", "writeOnly": true, "description": "This can be found on the Events API V2 integration's detail page, and is also referred to as a Routing Key. This must be provided alongside `api_key`, but will error if provided alongside `url`."}}, "description": "Enables sending notifications via a provided PagerDuty webhook.", "secret_fields": ["integration_key", "api_key"], "block_type_slug": "pager-duty-webhook"}	sha256:e740fec7e031645ea97ee769eb37b66ee15b8a353e5e1723ef708b4cd5433069	902e22cb-0d10-4ff5-a7fe-3d6ee23e5998	["notify"]	2.20.18
3c9eb68f-2451-469e-9b9e-5989d7719037	2025-11-10 15:29:44.276032+00	2025-11-10 15:29:44.276049+00	{"type": "object", "title": "TwilioSMS", "required": ["account_sid", "auth_token", "from_phone_number", "to_phone_numbers"], "properties": {"auth_token": {"type": "string", "title": "Auth Token", "format": "password", "writeOnly": true, "description": "The Twilio Authentication Token - it can be found on the homepage of the Twilio console."}, "account_sid": {"type": "string", "title": "Account Sid", "description": "The Twilio Account SID - it can be found on the homepage of the Twilio console."}, "notify_type": {"enum": ["prefect_default", "info", "success", "warning", "failure"], "type": "string", "title": "Notify Type", "default": "prefect_default", "description": "The type of notification being performed; the prefect_default is a plain notification that does not attach an image."}, "to_phone_numbers": {"type": "array", "items": {"type": "string"}, "title": "To Phone Numbers", "examples": ["18004242424"], "description": "A list of valid Twilio phone number(s) to send the message to."}, "from_phone_number": {"type": "string", "title": "From Phone Number", "examples": ["18001234567"], "description": "The valid Twilio phone number to send the message from."}}, "description": "Enables sending notifications via Twilio SMS.", "secret_fields": ["auth_token"], "block_type_slug": "twilio-sms"}	sha256:a3c827e6f0554918bbd7a4161795ad86a5e5baf980993cdc6e9e0d58c08b9aec	76448f87-b13d-4253-9705-636fc297c7c2	["notify"]	2.20.18
a45fdb41-4a79-4c7f-8f24-718290fb6bbc	2025-11-10 15:29:44.294454+00	2025-11-10 15:29:44.29447+00	{"type": "object", "title": "OpsgenieWebhook", "required": ["apikey"], "properties": {"tags": {"type": "array", "items": {}, "title": "Tags", "examples": ["[\\"tag1\\", \\"tag2\\"]"], "description": "A comma-separated list of tags you can associate with your Opsgenie message."}, "alias": {"type": "string", "title": "Alias", "description": "The alias to associate with the message."}, "batch": {"type": "boolean", "title": "Batch", "default": false, "description": "Notify all targets in batches (instead of individually)."}, "apikey": {"type": "string", "title": "API Key", "format": "password", "writeOnly": true, "description": "The API Key associated with your Opsgenie account."}, "entity": {"type": "string", "title": "Entity", "description": "The entity to associate with the message."}, "details": {"type": "object", "title": "Details", "examples": ["{\\"key1\\": \\"value1\\", \\"key2\\": \\"value2\\"}"], "description": "Additional details composed of key/values pairs.", "additionalProperties": {"type": "string"}}, "priority": {"type": "string", "title": "Priority", "default": 3, "description": "The priority to associate with the message. It is on a scale between 1 (LOW) and 5 (EMERGENCY)."}, "notify_type": {"enum": ["prefect_default", "info", "success", "warning", "failure"], "type": "string", "title": "Notify Type", "default": "prefect_default", "description": "The type of notification being performed; the prefect_default is a plain notification that does not attach an image."}, "region_name": {"enum": ["us", "eu"], "type": "string", "title": "Region Name", "default": "us", "description": "The 2-character region code."}, "target_team": {"type": "array", "items": {}, "title": "Target Team", "description": "The team(s) you wish to notify."}, "target_user": {"type": "array", "items": {}, "title": "Target User", "description": "The user(s) you wish to notify."}, "target_schedule": {"type": "array", "items": {}, "title": "Target Schedule", "description": "The schedule(s) you wish to notify."}, "target_escalation": {"type": "array", "items": {}, "title": "Target Escalation", "description": "The escalation(s) you wish to notify."}}, "description": "Enables sending notifications via a provided Opsgenie webhook.", "secret_fields": ["apikey"], "block_type_slug": "opsgenie-webhook"}	sha256:d4f132a133952ed6e73dfd5727ce318c5f1de089cdc542f89e4a74c0a40bfa00	9a6bfc6d-174c-4464-819a-ad1e4a7b9b11	["notify"]	2.20.18
09d749c5-5ac0-4690-8895-302cdf7889ea	2025-11-10 15:29:44.313758+00	2025-11-10 15:29:44.313771+00	{"type": "object", "title": "MattermostWebhook", "required": ["hostname", "token"], "properties": {"path": {"type": "string", "title": "Path", "description": "An optional sub-path specification to append to the hostname."}, "port": {"type": "integer", "title": "Port", "default": 8065, "description": "The port of your Mattermost server."}, "token": {"type": "string", "title": "Token", "format": "password", "writeOnly": true, "description": "The token associated with your Mattermost webhook."}, "botname": {"type": "string", "title": "Bot name", "description": "The name of the bot that will send the message."}, "channels": {"type": "array", "items": {"type": "string"}, "title": "Channels", "description": "The channel(s) you wish to notify."}, "hostname": {"type": "string", "title": "Hostname", "examples": ["Mattermost.example.com"], "description": "The hostname of your Mattermost server."}, "notify_type": {"enum": ["prefect_default", "info", "success", "warning", "failure"], "type": "string", "title": "Notify Type", "default": "prefect_default", "description": "The type of notification being performed; the prefect_default is a plain notification that does not attach an image."}, "include_image": {"type": "boolean", "title": "Include Image", "default": false, "description": "Whether to include the Apprise status image in the message."}}, "description": "Enables sending notifications via a provided Mattermost webhook.", "secret_fields": ["token"], "block_type_slug": "mattermost-webhook"}	sha256:1ee75a85f08d5a50b762c1fe3c067f9e6e173d3630b3994646e6278ee75a7fdb	7e20de36-9198-4df7-9006-cd76601cd6b8	["notify"]	2.20.18
0f687c8b-0781-4422-a3d1-84c01a45e5a2	2025-11-10 15:29:44.349029+00	2025-11-10 15:29:44.349044+00	{"type": "object", "title": "DiscordWebhook", "required": ["webhook_id", "webhook_token"], "properties": {"tts": {"type": "boolean", "title": "Tts", "default": false, "description": "Whether to enable Text-To-Speech."}, "avatar": {"type": "boolean", "title": "Avatar", "default": false, "description": "Whether to override the default discord avatar icon."}, "botname": {"type": "string", "title": "Bot name", "description": "Identify the name of the bot that should issue the message. If one isn't specified then the default is to just use your account (associated with the incoming-webhook)."}, "avatar_url": {"type": "string", "title": "Avatar URL", "default": false, "description": "Over-ride the default discord avatar icon URL. By default this is not set and Apprise chooses the URL dynamically based on the type of message (info, success, warning, or error)."}, "webhook_id": {"type": "string", "title": "Webhook Id", "format": "password", "writeOnly": true, "description": "The first part of 2 tokens provided to you after creating a incoming-webhook."}, "notify_type": {"enum": ["prefect_default", "info", "success", "warning", "failure"], "type": "string", "title": "Notify Type", "default": "prefect_default", "description": "The type of notification being performed; the prefect_default is a plain notification that does not attach an image."}, "include_image": {"type": "boolean", "title": "Include Image", "default": false, "description": "Whether to include an image in-line with the message describing the notification type."}, "webhook_token": {"type": "string", "title": "Webhook Token", "format": "password", "writeOnly": true, "description": "The second part of 2 tokens provided to you after creating a incoming-webhook."}}, "description": "Enables sending notifications via a provided Discord webhook.", "secret_fields": ["webhook_id", "webhook_token"], "block_type_slug": "discord-webhook"}	sha256:d618d2f8553ac78a1d23fbcda4080e2b2e22bc38d45da21dc1f074cb85384e11	b3c9aa4c-9ac5-44e0-a944-d7169133d4c3	["notify"]	2.20.18
b0196177-02b5-47fe-ad53-d20fa85e88fd	2025-11-10 15:29:44.365894+00	2025-11-10 15:29:44.365908+00	{"type": "object", "title": "CustomWebhookNotificationBlock", "required": ["name", "url"], "properties": {"url": {"type": "string", "title": "Webhook URL", "examples": ["https://hooks.slack.com/XXX"], "description": "The webhook URL."}, "name": {"type": "string", "title": "Name", "description": "Name of the webhook."}, "method": {"enum": ["GET", "POST", "PUT", "PATCH", "DELETE"], "type": "string", "title": "Method", "default": "POST", "description": "The webhook request method. Defaults to `POST`."}, "params": {"type": "object", "title": "Query Params", "description": "Custom query params.", "additionalProperties": {"type": "string"}}, "cookies": {"type": "object", "title": "Cookies", "description": "Custom cookies.", "additionalProperties": {"type": "string"}}, "headers": {"type": "object", "title": "Headers", "description": "Custom headers.", "additionalProperties": {"type": "string"}}, "secrets": {"type": "object", "title": "Custom Secret Values", "examples": ["{\\"tokenFromSecrets\\":\\"SomeSecretToken\\"}"], "description": "A dictionary of secret values to be substituted in other configs."}, "timeout": {"type": "number", "title": "Timeout", "default": 10, "description": "Request timeout in seconds. Defaults to 10."}, "form_data": {"type": "object", "title": "Form Data", "examples": ["{\\"text\\": \\"{{subject}}\\\\n{{body}}\\", \\"title\\": \\"{{name}}\\", \\"token\\": \\"{{tokenFromSecrets}}\\"}"], "description": "Send form data as payload. Should not be used together with _JSON Data_.", "additionalProperties": {"type": "string"}}, "json_data": {"type": "object", "title": "JSON Data", "examples": ["{\\"text\\": \\"{{subject}}\\\\n{{body}}\\", \\"title\\": \\"{{name}}\\", \\"token\\": \\"{{tokenFromSecrets}}\\"}"], "description": "Send json data as payload."}}, "description": "Enables sending notifications via any custom webhook.\\n\\nAll nested string param contains `{{key}}` will be substituted with value from context/secrets.\\n\\nContext values include: `subject`, `body` and `name`.", "secret_fields": ["secrets.*"], "block_type_slug": "custom-webhook"}	sha256:f8bd7b0781bf92dbf59e48e0944bb600c18db8004f3fc664f6f9bf5024fe2c8e	286e622d-0b9e-4fad-9c99-a4f2ddbddacc	["notify"]	2.20.18
f945057c-65f3-464e-aea2-7572fa558693	2025-11-10 15:29:44.382616+00	2025-11-10 15:29:44.382629+00	{"type": "object", "title": "SendgridEmail", "required": ["api_key", "sender_email", "to_emails"], "properties": {"api_key": {"type": "string", "title": "API Key", "format": "password", "writeOnly": true, "description": "The API Key associated with your sendgrid account."}, "to_emails": {"type": "array", "items": {"type": "string"}, "title": "Recipient emails", "examples": ["\\"recipient1@gmail.com\\""], "description": "Email ids of all recipients."}, "notify_type": {"enum": ["prefect_default", "info", "success", "warning", "failure"], "type": "string", "title": "Notify Type", "default": "prefect_default", "description": "The type of notification being performed; the prefect_default is a plain notification that does not attach an image."}, "sender_email": {"type": "string", "title": "Sender email id", "examples": ["test-support@gmail.com"], "description": "The sender email id."}}, "description": "Enables sending notifications via Sendgrid email service.", "secret_fields": ["api_key"], "block_type_slug": "sendgrid-email"}	sha256:ca1ce43172228b65a570b1a5de9cdbd9813945e672807dc42d21b69d9d3977e7	90a36992-37de-48e5-b490-af103b20b771	["notify"]	2.20.18
0ea08aab-1497-4cf2-b5d4-c626ce4de972	2025-11-10 15:29:44.412025+00	2025-11-10 15:29:44.412041+00	{"type": "object", "title": "String", "required": ["value"], "properties": {"value": {"type": "string", "title": "Value", "description": "A string value."}}, "description": "A block that represents a string", "secret_fields": [], "block_type_slug": "string"}	sha256:e9f3f43e55b73bc94ee2a355f1e4ef7064645268cba22571c2a95d90a2af8dd0	b124696c-96b4-4977-b256-ad9831ba1f29	[]	2.20.18
6505d605-7b7f-4775-aca8-82a96b2a7ee9	2025-11-10 15:29:44.475914+00	2025-11-10 15:29:44.475931+00	{"type": "object", "title": "RemoteFileSystem", "required": ["basepath"], "properties": {"basepath": {"type": "string", "title": "Basepath", "examples": ["s3://my-bucket/my-folder/"], "description": "Default path for this block to write to."}, "settings": {"type": "object", "title": "Settings", "description": "Additional settings to pass through to fsspec."}}, "description": "Store data as a file on a remote file system.\\n\\nSupports any remote file system supported by `fsspec`. The file system is specified\\nusing a protocol. For example, \\"s3://my-bucket/my-folder/\\" will use S3.", "secret_fields": [], "block_type_slug": "remote-file-system"}	sha256:efb6b7304d9cadaf09a18abc60be7ae86aec60dbd7dba345faa7ba1e960b211f	7c148288-67ac-4e26-b9eb-503ac5a8634c	["put-directory", "read-path", "write-path", "get-directory"]	2.20.18
a7d019e8-4f18-4518-be27-44093fbff27c	2025-11-10 15:29:44.494685+00	2025-11-10 15:29:44.494699+00	{"type": "object", "title": "S3", "required": ["bucket_path"], "properties": {"bucket_path": {"type": "string", "title": "Bucket Path", "examples": ["my-bucket/a-directory-within"], "description": "An S3 bucket path."}, "aws_access_key_id": {"type": "string", "title": "AWS Access Key ID", "format": "password", "examples": ["AKIAIOSFODNN7EXAMPLE"], "writeOnly": true, "description": "Equivalent to the AWS_ACCESS_KEY_ID environment variable."}, "aws_secret_access_key": {"type": "string", "title": "AWS Secret Access Key", "format": "password", "examples": ["wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"], "writeOnly": true, "description": "Equivalent to the AWS_SECRET_ACCESS_KEY environment variable."}}, "description": "DEPRECATION WARNING:\\n\\nThis class is deprecated as of March 2024 and will not be available after September 2024.\\nIt has been replaced by `S3Bucket` from the `prefect-aws` package, which offers enhanced functionality\\nand better a better user experience.\\n\\nStore data as a file on AWS S3.", "secret_fields": ["aws_access_key_id", "aws_secret_access_key"], "block_type_slug": "s3"}	sha256:43f3850279e9ff1844e84099832a5f5190aa0f2e2331959b1d891e9c65e9107b	cb102f3e-d893-4d51-84f0-16e169c45e1e	["put-directory", "read-path", "write-path", "get-directory"]	2.20.18
d57729df-229c-4c43-810e-398bd7639dae	2025-11-10 15:29:44.513165+00	2025-11-10 15:29:44.513179+00	{"type": "object", "title": "GCS", "required": ["bucket_path"], "properties": {"project": {"type": "string", "title": "Project", "description": "The project the GCS bucket resides in. If not provided, the project will be inferred from the credentials or environment."}, "bucket_path": {"type": "string", "title": "Bucket Path", "examples": ["my-bucket/a-directory-within"], "description": "A GCS bucket path."}, "service_account_info": {"type": "string", "title": "Service Account Info", "format": "password", "writeOnly": true, "description": "The contents of a service account keyfile as a JSON string."}}, "description": "DEPRECATION WARNING:\\n\\nThis class is deprecated as of March 2024 and will not be available after September 2024.\\nIt has been replaced by `GcsBucket` from the `prefect-gcp` package, which offers enhanced functionality\\nand better a better user experience.\\nStore data as a file on Google Cloud Storage.", "secret_fields": ["service_account_info"], "block_type_slug": "gcs"}	sha256:a283caa25f404ba9fc5690334e556a68bc09ce85fcd2a3f8452205b68281a85b	3c62bc9a-694b-4d85-b85a-73687aac52ee	["put-directory", "read-path", "write-path", "get-directory"]	2.20.18
4a4ffe4a-3f47-4adb-80a2-b8e024e233ac	2025-11-10 15:29:45.086406+00	2025-11-10 15:29:45.08642+00	{"type": "object", "title": "DockerRegistry", "required": ["username", "password", "registry_url"], "properties": {"reauth": {"type": "boolean", "title": "Reauth", "default": true, "description": "Whether or not to reauthenticate on each interaction."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password to log into the registry with."}, "username": {"type": "string", "title": "Username", "description": "The username to log into the registry with."}, "registry_url": {"type": "string", "title": "Registry Url", "description": "The URL to the registry. Generally, \\"http\\" or \\"https\\" can be omitted."}}, "description": "Connects to a Docker registry.\\n\\nRequires a Docker Engine to be connectable.", "secret_fields": ["password"], "block_type_slug": "docker-registry"}	sha256:6db1457676eee0b54ca2834b06f80a80f7c90112e64f1bdd26afb2e62fcceed9	e6bea070-5b7b-49a4-9c8c-8e799929ee62	[]	non-versioned
017b8d1e-37be-48ab-ac93-9d197deb864b	2025-11-10 15:29:44.530536+00	2025-11-10 15:29:44.530549+00	{"type": "object", "title": "Azure", "required": ["bucket_path"], "properties": {"bucket_path": {"type": "string", "title": "Bucket Path", "examples": ["my-bucket/a-directory-within"], "description": "An Azure storage bucket path."}, "azure_storage_anon": {"type": "boolean", "title": "Azure storage anonymous connection", "default": true, "description": "Set the 'anon' flag for ADLFS. This should be False for systems that require ADLFS to use DefaultAzureCredentials."}, "azure_storage_client_id": {"type": "string", "title": "Azure storage client ID", "format": "password", "writeOnly": true, "description": "Equivalent to the AZURE_CLIENT_ID environment variable."}, "azure_storage_container": {"type": "string", "title": "Azure storage container", "format": "password", "writeOnly": true, "description": "Blob Container in Azure Storage Account. If set the 'bucket_path' will be interpreted using the following URL format:'az://<container>@<storage_account>.dfs.core.windows.net/<bucket_path>'."}, "azure_storage_tenant_id": {"type": "string", "title": "Azure storage tenant ID", "format": "password", "writeOnly": true, "description": "Equivalent to the AZURE_TENANT_ID environment variable."}, "azure_storage_account_key": {"type": "string", "title": "Azure storage account key", "format": "password", "writeOnly": true, "description": "Equivalent to the AZURE_STORAGE_ACCOUNT_KEY environment variable."}, "azure_storage_account_name": {"type": "string", "title": "Azure storage account name", "format": "password", "writeOnly": true, "description": "Equivalent to the AZURE_STORAGE_ACCOUNT_NAME environment variable."}, "azure_storage_client_secret": {"type": "string", "title": "Azure storage client secret", "format": "password", "writeOnly": true, "description": "Equivalent to the AZURE_CLIENT_SECRET environment variable."}, "azure_storage_connection_string": {"type": "string", "title": "Azure storage connection string", "format": "password", "writeOnly": true, "description": "Equivalent to the AZURE_STORAGE_CONNECTION_STRING environment variable."}}, "description": "DEPRECATION WARNING:\\n\\nThis class is deprecated as of March 2024 and will not be available after September 2024.\\nIt has been replaced by `AzureBlobStorageContainer` from the `prefect-azure` package, which\\noffers enhanced functionality and better a better user experience.\\n\\nStore data as a file on Azure Datalake and Azure Blob Storage.", "secret_fields": ["azure_storage_connection_string", "azure_storage_account_name", "azure_storage_account_key", "azure_storage_tenant_id", "azure_storage_client_id", "azure_storage_client_secret", "azure_storage_container"], "block_type_slug": "azure"}	sha256:bb71661a7d11812c5e31fe5143a04bd6d4879a4913a7ae0f0dc5122092e3b98a	a1bf8f7c-6b21-49f5-9647-54cc82660747	["put-directory", "read-path", "write-path", "get-directory"]	2.20.18
beca3369-d759-449e-9ed7-d859b0f86f27	2025-11-10 15:29:44.547648+00	2025-11-10 15:29:44.547662+00	{"type": "object", "title": "SMB", "required": ["share_path", "smb_host"], "properties": {"smb_host": {"tile": "SMB server/hostname", "type": "string", "title": "Smb Host", "description": "SMB server/hostname."}, "smb_port": {"type": "integer", "title": "SMB port", "description": "SMB port (default: 445)."}, "share_path": {"type": "string", "title": "Share Path", "examples": ["/SHARE/dir/subdir"], "description": "SMB target (requires <SHARE>, followed by <PATH>)."}, "smb_password": {"type": "string", "title": "SMB Password", "format": "password", "writeOnly": true, "description": "Password for SMB access."}, "smb_username": {"type": "string", "title": "SMB Username", "format": "password", "writeOnly": true, "description": "Username with access to the target SMB SHARE."}}, "description": "Store data as a file on a SMB share.", "secret_fields": ["smb_username", "smb_password"], "block_type_slug": "smb"}	sha256:75c58ad4a657fcb859ee31662b04f7bbbe515bffc037c741e57072d28b9b0816	196c5e59-718b-4dee-8255-e51337113be3	["put-directory", "read-path", "write-path", "get-directory"]	2.20.18
0f6ecdd2-d9cc-487d-a231-e3075c1ced86	2025-11-10 15:29:44.569047+00	2025-11-10 15:29:44.569061+00	{"type": "object", "title": "GitHub", "required": ["repository"], "properties": {"reference": {"type": "string", "title": "Reference", "description": "An optional reference to pin to; can be a branch name or tag."}, "repository": {"type": "string", "title": "Repository", "description": "The URL of a GitHub repository to read from, in either HTTPS or SSH format."}, "access_token": {"name": "Personal Access Token", "type": "string", "title": "Access Token", "format": "password", "writeOnly": true, "description": "A GitHub Personal Access Token (PAT) with repo scope. To use a fine-grained PAT, provide '{username}:{PAT}' as the value."}, "include_git_objects": {"type": "boolean", "title": "Include Git Objects", "default": true, "description": "Whether to include git objects when copying the repo contents to a directory."}}, "description": "DEPRECATION WARNING:\\n\\n    This class is deprecated as of March 2024 and will not be available after September 2024.\\n    It has been replaced by `GitHubRepository` from the `prefect-github` package, which offers\\n    enhanced functionality and better a better user experience.\\nq\\n    Interact with files stored on GitHub repositories.", "secret_fields": ["access_token"], "block_type_slug": "github"}	sha256:1a646071d2e07191f2d3934dd7a15a38c27dd60e5e6f74b21c550437b471b8ef	17f4cff0-c848-4e3e-bcd5-88da5d2ea263	["get-directory"]	2.20.18
c2ed2b93-4c0f-4cff-a08e-c91e52f5bf9d	2025-11-10 15:29:44.585494+00	2025-11-10 15:29:44.585508+00	{"type": "object", "title": "DockerRegistry", "required": ["username", "password", "registry_url"], "properties": {"reauth": {"type": "boolean", "title": "Reauth", "default": true, "description": "Whether or not to reauthenticate on each interaction."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password to log into the registry with."}, "username": {"type": "string", "title": "Username", "description": "The username to log into the registry with."}, "registry_url": {"type": "string", "title": "Registry Url", "description": "The URL to the registry. Generally, \\"http\\" or \\"https\\" can be omitted."}}, "description": "DEPRECATION WARNING:\\n\\nThis class is deprecated as of March 2024 and will not be available after September 2024.\\nIt has been replaced by `DockerRegistryCredentials` from the `prefect-docker` package, which\\noffers enhanced functionality and better a better user experience.\\n\\nConnects to a Docker registry.\\n\\nRequires a Docker Engine to be connectable.", "secret_fields": ["password"], "block_type_slug": "docker-registry"}	sha256:7f51876d1b567d9c712e2f72ab76b078b2f288503e4ba3a68aca478d368a982d	e6bea070-5b7b-49a4-9c8c-8e799929ee62	["docker-login"]	2.20.18
69b4881e-e5d6-432c-9c4d-4e38e2d56076	2025-11-10 15:29:44.603526+00	2025-11-10 15:29:44.60354+00	{"type": "object", "title": "DockerContainer", "properties": {"env": {"type": "object", "title": "Environment", "description": "Environment variables to set in the configured infrastructure.", "additionalProperties": {"type": "string"}}, "name": {"type": "string", "title": "Name", "description": "Name applied to the infrastructure for identification."}, "type": {"enum": ["docker-container"], "type": "string", "title": "Type", "default": "docker-container", "description": "The type of infrastructure."}, "image": {"type": "string", "title": "Image", "description": "Tag of a Docker image to use. Defaults to the Prefect image."}, "labels": {"type": "object", "title": "Labels", "description": "Labels applied to the infrastructure for metadata purposes.", "additionalProperties": {"type": "string"}}, "command": {"type": "array", "items": {"type": "string"}, "title": "Command", "description": "The command to run in the infrastructure."}, "volumes": {"type": "array", "items": {"type": "string"}, "title": "Volumes", "description": "A list of volume mount strings in the format of \\"local_path:container_path\\"."}, "networks": {"type": "array", "items": {"type": "string"}, "title": "Networks", "description": "A list of strings specifying Docker networks to connect the container to."}, "mem_limit": {"anyOf": [{"type": "number"}, {"type": "string"}], "title": "Mem Limit", "description": "Memory limit of the created container. Accepts float values to enforce a limit in bytes or a string with a unit e.g. 100000b, 1000k, 128m, 1g. If a string is given without a unit, bytes are assumed."}, "privileged": {"type": "boolean", "title": "Privileged", "default": false, "description": "Give extended privileges to this container."}, "auto_remove": {"type": "boolean", "title": "Auto Remove", "default": false, "description": "If set, the container will be removed on completion."}, "network_mode": {"type": "string", "title": "Network Mode", "description": "The network mode for the created container (e.g. host, bridge). If 'networks' is set, this cannot be set."}, "memswap_limit": {"anyOf": [{"type": "integer"}, {"type": "string"}], "title": "Memswap Limit", "description": "Total memory (memory + swap), -1 to disable swap. Should only be set if `mem_limit` is also set. If `mem_limit` is set, this defaults toallowing the container to use as much swap as memory. For example, if `mem_limit` is 300m and `memswap_limit` is not set, the container can use 600m in total of memory and swap."}, "stream_output": {"type": "boolean", "title": "Stream Output", "default": true, "description": "If set, the output will be streamed from the container to local standard output."}, "image_registry": {"$ref": "#/definitions/DockerRegistry"}, "image_pull_policy": {"allOf": [{"$ref": "#/definitions/ImagePullPolicy"}], "description": "Specifies if the image should be pulled."}}, "definitions": {"ImagePullPolicy": {"enum": ["IF_NOT_PRESENT", "ALWAYS", "NEVER"], "type": "string", "title": "ImagePullPolicy", "description": "An enumeration."}}, "description": "Runs a command in a container.\\n\\nRequires a Docker Engine to be connectable. Docker settings will be retrieved from\\nthe environment.\\n\\nClick [here](https://docs.prefect.io/guides/deployment/docker) to see a tutorial.", "secret_fields": ["image_registry.password"], "block_type_slug": "docker-container"}	sha256:8492ae879cf429c54f27816717769d4348e05eafdfd579158a2d0a6406ec08eb	8aa11860-cae9-4b42-bced-e99fbd46c373	["run-infrastructure"]	2.20.18
777093a3-baa6-4c54-a149-23a472b59aa6	2025-11-10 15:29:44.639991+00	2025-11-10 15:29:44.640006+00	{"type": "object", "title": "KubernetesClusterConfig", "required": ["config", "context_name"], "properties": {"config": {"type": "object", "title": "Config", "description": "The entire contents of a kubectl config file."}, "context_name": {"type": "string", "title": "Context Name", "description": "The name of the kubectl context to use."}}, "description": "Stores configuration for interaction with Kubernetes clusters.\\n\\nSee `from_file` for creation.", "secret_fields": [], "block_type_slug": "kubernetes-cluster-config"}	sha256:90d421e948bfbe4cdc98b124995f0edd0f84b0837549ad1390423bad8e31cf3b	0626cd1e-a7c2-4686-8885-ced4b5eceac2	[]	2.20.18
eb638633-fd66-4dca-b87e-ad5eddd89d2e	2025-11-10 15:29:44.658068+00	2025-11-10 15:29:44.658082+00	{"type": "object", "title": "KubernetesJob", "properties": {"env": {"type": "object", "title": "Environment", "description": "Environment variables to set in the configured infrastructure.", "additionalProperties": {"type": "string"}}, "job": {"type": "object", "title": "Base Job Manifest", "description": "The base manifest for the Kubernetes Job."}, "name": {"type": "string", "title": "Name", "description": "Name applied to the infrastructure for identification."}, "type": {"enum": ["kubernetes-job"], "type": "string", "title": "Type", "default": "kubernetes-job", "description": "The type of infrastructure."}, "image": {"type": "string", "title": "Image", "description": "The image reference of a container image to use for the job, for example, `docker.io/prefecthq/prefect:2-latest`.The behavior is as described in the Kubernetes documentation and uses the latest version of Prefect by default, unless an image is already present in a provided job manifest."}, "labels": {"type": "object", "title": "Labels", "description": "Labels applied to the infrastructure for metadata purposes.", "additionalProperties": {"type": "string"}}, "command": {"type": "array", "items": {"type": "string"}, "title": "Command", "description": "The command to run in the infrastructure."}, "namespace": {"type": "string", "title": "Namespace", "description": "The Kubernetes namespace to use for this job. Defaults to 'default' unless a namespace is already present in a provided job manifest."}, "stream_output": {"type": "boolean", "title": "Stream Output", "default": true, "description": "If set, output will be streamed from the job to local standard output."}, "cluster_config": {"allOf": [{"$ref": "#/definitions/KubernetesClusterConfig"}], "title": "Cluster Config", "description": "The Kubernetes cluster config to use for this job."}, "customizations": {"type": "array", "items": {"type": "object", "additionalProperties": {"type": "string"}}, "title": "Customizations", "format": "rfc6902", "description": "A list of JSON 6902 patches to apply to the base Job manifest."}, "finished_job_ttl": {"type": "integer", "title": "Finished Job Ttl", "description": "The number of seconds to retain jobs after completion. If set, finished jobs will be cleaned up by Kubernetes after the given delay. If None (default), jobs will need to be manually removed."}, "image_pull_policy": {"allOf": [{"$ref": "#/definitions/KubernetesImagePullPolicy"}], "description": "The Kubernetes image pull policy to use for job containers."}, "service_account_name": {"type": "string", "title": "Service Account Name", "description": "The Kubernetes service account to use for this job."}, "job_watch_timeout_seconds": {"type": "integer", "title": "Job Watch Timeout Seconds", "description": "Number of seconds to wait for the job to complete before marking it as crashed. Defaults to `None`, which means no timeout will be enforced."}, "pod_watch_timeout_seconds": {"type": "integer", "title": "Pod Watch Timeout Seconds", "default": 60, "description": "Number of seconds to watch for pod creation before timing out."}}, "definitions": {"KubernetesImagePullPolicy": {"enum": ["IfNotPresent", "Always", "Never"], "title": "KubernetesImagePullPolicy", "description": "An enumeration."}}, "description": "Runs a command as a Kubernetes Job.\\n\\nFor a guided tutorial, see [How to use Kubernetes with Prefect](https://medium.com/the-prefect-blog/how-to-use-kubernetes-with-prefect-419b2e8b8cb2/).\\nFor more information, including examples for customizing the resulting manifest, see [`KubernetesJob` infrastructure concepts](https://docs.prefect.io/concepts/infrastructure/#kubernetesjob).", "secret_fields": [], "block_type_slug": "kubernetes-job"}	sha256:6323febcd3533e86e1a062793f3ce17d40a132388e1ddc16d3bb1a30d3ea0a6b	18a5e907-afc2-4805-ab8b-da4c81cc6edb	["run-infrastructure"]	2.20.18
5bbd1795-3796-425c-987a-c4cba38a8561	2025-11-10 15:29:44.902678+00	2025-11-10 15:29:44.902696+00	{"type": "object", "title": "AwsCredentials", "properties": {"region_name": {"type": "string", "title": "Region Name", "description": "The AWS Region where you want to create new connections."}, "profile_name": {"type": "string", "title": "Profile Name", "description": "The profile to use when creating your session."}, "aws_access_key_id": {"type": "string", "title": "AWS Access Key ID", "description": "A specific AWS access key ID."}, "aws_session_token": {"type": "string", "title": "AWS Session Token", "description": "The session key for your AWS account. This is only needed when you are using temporary credentials."}, "aws_client_parameters": {"allOf": [{"$ref": "#/definitions/AwsClientParameters"}], "title": "AWS Client Parameters", "description": "Extra parameters to initialize the Client."}, "aws_secret_access_key": {"type": "string", "title": "AWS Access Key Secret", "format": "password", "writeOnly": true, "description": "A specific AWS secret access key."}}, "definitions": {"AwsClientParameters": {"type": "object", "title": "AwsClientParameters", "properties": {"config": {"type": "object", "title": "Botocore Config", "description": "Advanced configuration for Botocore clients."}, "verify": {"anyOf": [{"type": "boolean"}, {"type": "string", "format": "file-path"}], "title": "Verify", "default": true, "description": "Whether or not to verify SSL certificates."}, "use_ssl": {"type": "boolean", "title": "Use SSL", "default": true, "description": "Whether or not to use SSL."}, "api_version": {"type": "string", "title": "API Version", "description": "The API version to use."}, "endpoint_url": {"type": "string", "title": "Endpoint URL", "description": "The complete URL to use for the constructed client."}, "verify_cert_path": {"type": "string", "title": "Certificate Authority Bundle File Path", "format": "file-path", "description": "Path to the CA cert bundle to use."}}, "description": "Model used to manage extra parameters that you can pass when you initialize\\nthe Client. If you want to find more information, see\\n[boto3 docs](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/core/session.html)\\nfor more info about the possible client configurations.\\n\\nAttributes:\\n    api_version: The API version to use. By default, botocore will\\n        use the latest API version when creating a client. You only need\\n        to specify this parameter if you want to use a previous API version\\n        of the client.\\n    use_ssl: Whether or not to use SSL. By default, SSL is used.\\n        Note that not all services support non-ssl connections.\\n    verify: Whether or not to verify SSL certificates. By default\\n        SSL certificates are verified. If False, SSL will still be used\\n        (unless use_ssl is False), but SSL certificates\\n        will not be verified. Passing a file path to this is deprecated.\\n    verify_cert_path: A filename of the CA cert bundle to\\n        use. You can specify this argument if you want to use a\\n        different CA cert bundle than the one used by botocore.\\n    endpoint_url: The complete URL to use for the constructed\\n        client. Normally, botocore will automatically construct the\\n        appropriate URL to use when communicating with a service. You\\n        can specify a complete URL (including the \\"http/https\\" scheme)\\n        to override this behavior. If this value is provided,\\n        then ``use_ssl`` is ignored.\\n    config: Advanced configuration for Botocore clients. See\\n        [botocore docs](https://botocore.amazonaws.com/v1/documentation/api/latest/reference/config.html)\\n        for more details."}}, "description": "Block used to manage authentication with AWS. AWS authentication is\\nhandled via the `boto3` module. Refer to the\\n[boto3 docs](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/credentials.html)\\nfor more info about the possible credential configurations.", "secret_fields": ["aws_secret_access_key"], "block_type_slug": "aws-credentials"}	sha256:17b73297ed60f080fb235b3a5a145a6d9b28a09b3ff2d9d17810b5e2c2075ebe	e82bceb3-a910-4862-a4fc-47f2531c2aad	[]	0.4.14
f2bcb6ff-efc8-4b57-827d-a38f4803a6af	2025-11-10 15:29:45.099443+00	2025-11-10 15:29:45.099459+00	{"type": "object", "title": "AzureCosmosDbCredentials", "required": ["connection_string"], "properties": {"connection_string": {"type": "string", "title": "Connection String", "format": "password", "writeOnly": true, "description": "Includes the authorization information required."}}, "description": "Block used to manage Cosmos DB authentication with Azure.\\nAzure authentication is handled via the `azure` module through\\na connection string.", "secret_fields": ["connection_string"], "block_type_slug": "azure-cosmos-db-credentials"}	sha256:2f9f6e6f6c2eb570a05113638e6237fe74f7684993a351018657211d4705a83a	724d142c-551c-49c5-95d9-602a79dd08a8	[]	0.3.7
f94a7aed-416c-4293-8503-88bd4da6d206	2025-11-10 15:29:44.913919+00	2025-11-10 15:29:44.913932+00	{"type": "object", "title": "AwsSecret", "required": ["aws_credentials", "secret_name"], "properties": {"secret_name": {"type": "string", "title": "Secret Name", "description": "The name of the secret."}, "aws_credentials": {"$ref": "#/definitions/AwsCredentials"}}, "definitions": {"AwsClientParameters": {"type": "object", "title": "AwsClientParameters", "properties": {"config": {"type": "object", "title": "Botocore Config", "description": "Advanced configuration for Botocore clients."}, "verify": {"anyOf": [{"type": "boolean"}, {"type": "string", "format": "file-path"}], "title": "Verify", "default": true, "description": "Whether or not to verify SSL certificates."}, "use_ssl": {"type": "boolean", "title": "Use SSL", "default": true, "description": "Whether or not to use SSL."}, "api_version": {"type": "string", "title": "API Version", "description": "The API version to use."}, "endpoint_url": {"type": "string", "title": "Endpoint URL", "description": "The complete URL to use for the constructed client."}, "verify_cert_path": {"type": "string", "title": "Certificate Authority Bundle File Path", "format": "file-path", "description": "Path to the CA cert bundle to use."}}, "description": "Model used to manage extra parameters that you can pass when you initialize\\nthe Client. If you want to find more information, see\\n[boto3 docs](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/core/session.html)\\nfor more info about the possible client configurations.\\n\\nAttributes:\\n    api_version: The API version to use. By default, botocore will\\n        use the latest API version when creating a client. You only need\\n        to specify this parameter if you want to use a previous API version\\n        of the client.\\n    use_ssl: Whether or not to use SSL. By default, SSL is used.\\n        Note that not all services support non-ssl connections.\\n    verify: Whether or not to verify SSL certificates. By default\\n        SSL certificates are verified. If False, SSL will still be used\\n        (unless use_ssl is False), but SSL certificates\\n        will not be verified. Passing a file path to this is deprecated.\\n    verify_cert_path: A filename of the CA cert bundle to\\n        use. You can specify this argument if you want to use a\\n        different CA cert bundle than the one used by botocore.\\n    endpoint_url: The complete URL to use for the constructed\\n        client. Normally, botocore will automatically construct the\\n        appropriate URL to use when communicating with a service. You\\n        can specify a complete URL (including the \\"http/https\\" scheme)\\n        to override this behavior. If this value is provided,\\n        then ``use_ssl`` is ignored.\\n    config: Advanced configuration for Botocore clients. See\\n        [botocore docs](https://botocore.amazonaws.com/v1/documentation/api/latest/reference/config.html)\\n        for more details."}}, "description": "Manages a secret in AWS's Secrets Manager.", "secret_fields": ["aws_credentials.aws_secret_access_key"], "block_type_slug": "aws-secret"}	sha256:d10fde5ac25b10edca4859c4d0bf61b4a9106215cd79ab80997f29859b190b7d	72929781-17d9-40df-8f19-1f5cf2baa4cf	[]	0.4.14
665db009-862b-41db-bd53-b1cddf44f358	2025-11-10 15:29:44.935335+00	2025-11-10 15:29:44.935349+00	{"type": "object", "title": "ECSTask", "properties": {"cpu": {"type": "integer", "title": "CPU", "description": "The amount of CPU to provide to the ECS task. Valid amounts are specified in the AWS documentation. If not provided, a default value of 1024 will be used unless present on the task definition."}, "env": {"type": "object", "title": "Environment Variables", "description": "Environment variables to provide to the task run. These variables are set on the Prefect container at task runtime. These will not be set on the task definition.", "additionalProperties": {"type": "string"}}, "name": {"type": "string", "title": "Name", "description": "Name applied to the infrastructure for identification."}, "type": {"enum": ["ecs-task"], "type": "string", "title": "Type", "default": "ecs-task", "description": "The slug for this task type."}, "image": {"type": "string", "title": "Image", "description": "The image to use for the Prefect container in the task. If this value is not null, it will override the value in the task definition. This value defaults to a Prefect base image matching your local versions."}, "family": {"type": "string", "title": "Family", "description": "A family for the task definition. If not provided, it will be inferred from the task definition. If the task definition does not have a family, the name will be generated. When flow and deployment metadata is available, the generated name will include their names. Values for this field will be slugified to match AWS character requirements."}, "labels": {"type": "object", "title": "Labels", "description": "Labels applied to the infrastructure for metadata purposes.", "additionalProperties": {"type": "string"}}, "memory": {"type": "integer", "title": "Memory", "description": "The amount of memory to provide to the ECS task. Valid amounts are specified in the AWS documentation. If not provided, a default value of 2048 will be used unless present on the task definition."}, "vpc_id": {"type": "string", "title": "VPC ID", "description": "The AWS VPC to link the task run to. This is only applicable when using the 'awsvpc' network mode for your task. FARGATE tasks require this network  mode, but for EC2 tasks the default network mode is 'bridge'. If using the 'awsvpc' network mode and this field is null, your default VPC will be used. If no default VPC can be found, the task run will fail."}, "cluster": {"type": "string", "title": "Cluster", "description": "The ECS cluster to run the task in. The ARN or name may be provided. If not provided, the default cluster will be used."}, "command": {"type": "array", "items": {"type": "string"}, "title": "Command", "description": "The command to run in the infrastructure."}, "launch_type": {"enum": ["FARGATE", "EC2", "EXTERNAL", "FARGATE_SPOT"], "type": "string", "title": "Launch Type", "default": "FARGATE", "description": "The type of ECS task run infrastructure that should be used. Note that 'FARGATE_SPOT' is not a formal ECS launch type, but we will configure the proper capacity provider strategy if set here."}, "stream_output": {"type": "boolean", "title": "Stream Output", "description": "If `True`, logs will be streamed from the Prefect container to the local console. Unless you have configured AWS CloudWatch logs manually on your task definition, this requires the same prerequisites outlined in `configure_cloudwatch_logs`."}, "task_role_arn": {"type": "string", "title": "Task Role ARN", "description": "A role to attach to the task run. This controls the permissions of the task while it is running."}, "aws_credentials": {"allOf": [{"$ref": "#/definitions/AwsCredentials"}], "title": "AWS Credentials", "description": "The AWS credentials to use to connect to ECS."}, "task_definition": {"type": "object", "title": "Task Definition", "description": "An ECS task definition to use. Prefect may set defaults or override fields on this task definition to match other `ECSTask` fields. Cannot be used with `task_definition_arn`. If not provided, Prefect will generate and register a minimal task definition."}, "execution_role_arn": {"type": "string", "title": "Execution Role ARN", "description": "An execution role to use for the task. This controls the permissions of the task when it is launching. If this value is not null, it will override the value in the task definition. An execution role must be provided to capture logs from the container."}, "task_customizations": {"type": "array", "items": {"type": "object", "additionalProperties": {"type": "string"}}, "title": "Task Customizations", "format": "rfc6902", "description": "A list of JSON 6902 patches to apply to the task run request. If a string is given, it will parsed as a JSON expression."}, "task_definition_arn": {"type": "string", "title": "Task Definition Arn", "description": "An identifier for an existing task definition to use. If fields are set on the `ECSTask` that conflict with the task definition, a new copy will be registered with the required values. Cannot be used with `task_definition`. If not provided, Prefect will generate and register a minimal task definition."}, "cloudwatch_logs_options": {"type": "object", "title": "Cloudwatch Logs Options", "description": "When `configure_cloudwatch_logs` is enabled, this setting may be used to pass additional options to the CloudWatch logs configuration or override the default options. See the AWS documentation for available options. https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html#create_awslogs_logdriver_options.", "additionalProperties": {"type": "string"}}, "task_watch_poll_interval": {"type": "number", "title": "Task Watch Poll Interval", "default": 5.0, "description": "The amount of time to wait between AWS API calls while monitoring the state of an ECS task."}, "configure_cloudwatch_logs": {"type": "boolean", "title": "Configure Cloudwatch Logs", "description": "If `True`, the Prefect container will be configured to send its output to the AWS CloudWatch logs service. This functionality requires an execution role with logs:CreateLogStream, logs:CreateLogGroup, and logs:PutLogEvents permissions. The default for this field is `False` unless `stream_output` is set."}, "task_start_timeout_seconds": {"type": "integer", "title": "Task Start Timeout Seconds", "default": 120, "description": "The amount of time to watch for the start of the ECS task before marking it as failed. The task must enter a RUNNING state to be considered started."}, "auto_deregister_task_definition": {"type": "boolean", "title": "Auto Deregister Task Definition", "default": true, "description": "If set, any task definitions that are created by this block will be deregistered. Existing task definitions linked by ARN will never be deregistered. Deregistering a task definition does not remove it from your AWS account, instead it will be marked as INACTIVE."}}, "definitions": {"AwsClientParameters": {"type": "object", "title": "AwsClientParameters", "properties": {"config": {"type": "object", "title": "Botocore Config", "description": "Advanced configuration for Botocore clients."}, "verify": {"anyOf": [{"type": "boolean"}, {"type": "string", "format": "file-path"}], "title": "Verify", "default": true, "description": "Whether or not to verify SSL certificates."}, "use_ssl": {"type": "boolean", "title": "Use SSL", "default": true, "description": "Whether or not to use SSL."}, "api_version": {"type": "string", "title": "API Version", "description": "The API version to use."}, "endpoint_url": {"type": "string", "title": "Endpoint URL", "description": "The complete URL to use for the constructed client."}, "verify_cert_path": {"type": "string", "title": "Certificate Authority Bundle File Path", "format": "file-path", "description": "Path to the CA cert bundle to use."}}, "description": "Model used to manage extra parameters that you can pass when you initialize\\nthe Client. If you want to find more information, see\\n[boto3 docs](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/core/session.html)\\nfor more info about the possible client configurations.\\n\\nAttributes:\\n    api_version: The API version to use. By default, botocore will\\n        use the latest API version when creating a client. You only need\\n        to specify this parameter if you want to use a previous API version\\n        of the client.\\n    use_ssl: Whether or not to use SSL. By default, SSL is used.\\n        Note that not all services support non-ssl connections.\\n    verify: Whether or not to verify SSL certificates. By default\\n        SSL certificates are verified. If False, SSL will still be used\\n        (unless use_ssl is False), but SSL certificates\\n        will not be verified. Passing a file path to this is deprecated.\\n    verify_cert_path: A filename of the CA cert bundle to\\n        use. You can specify this argument if you want to use a\\n        different CA cert bundle than the one used by botocore.\\n    endpoint_url: The complete URL to use for the constructed\\n        client. Normally, botocore will automatically construct the\\n        appropriate URL to use when communicating with a service. You\\n        can specify a complete URL (including the \\"http/https\\" scheme)\\n        to override this behavior. If this value is provided,\\n        then ``use_ssl`` is ignored.\\n    config: Advanced configuration for Botocore clients. See\\n        [botocore docs](https://botocore.amazonaws.com/v1/documentation/api/latest/reference/config.html)\\n        for more details."}}, "description": "Run a command as an ECS task.", "secret_fields": ["aws_credentials.aws_secret_access_key"], "block_type_slug": "ecs-task"}	sha256:d72b495859da39536d3e1119ddabd42a10866867b97c4834956ae231120858ca	b8ee79c1-434d-4786-9872-0bd9154f3445	["run-infrastructure"]	0.4.14
afadaa63-8a13-40bf-bf9e-28c86c36ff31	2025-11-10 15:29:44.957118+00	2025-11-10 15:29:44.957133+00	{"type": "object", "title": "LambdaFunction", "required": ["function_name"], "properties": {"qualifier": {"type": "string", "title": "Qualifier", "description": "The version or alias of the Lambda function to use when invoked. If not specified, the latest (unqualified) version of the Lambda function will be used."}, "function_name": {"type": "string", "title": "Function Name", "description": "The name, ARN, or partial ARN of the Lambda function to run. This must be the name of a function that is already deployed to AWS Lambda."}, "aws_credentials": {"allOf": [{"$ref": "#/definitions/AwsCredentials"}], "title": "AWS Credentials", "description": "The AWS credentials to invoke the Lambda with."}}, "definitions": {"AwsClientParameters": {"type": "object", "title": "AwsClientParameters", "properties": {"config": {"type": "object", "title": "Botocore Config", "description": "Advanced configuration for Botocore clients."}, "verify": {"anyOf": [{"type": "boolean"}, {"type": "string", "format": "file-path"}], "title": "Verify", "default": true, "description": "Whether or not to verify SSL certificates."}, "use_ssl": {"type": "boolean", "title": "Use SSL", "default": true, "description": "Whether or not to use SSL."}, "api_version": {"type": "string", "title": "API Version", "description": "The API version to use."}, "endpoint_url": {"type": "string", "title": "Endpoint URL", "description": "The complete URL to use for the constructed client."}, "verify_cert_path": {"type": "string", "title": "Certificate Authority Bundle File Path", "format": "file-path", "description": "Path to the CA cert bundle to use."}}, "description": "Model used to manage extra parameters that you can pass when you initialize\\nthe Client. If you want to find more information, see\\n[boto3 docs](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/core/session.html)\\nfor more info about the possible client configurations.\\n\\nAttributes:\\n    api_version: The API version to use. By default, botocore will\\n        use the latest API version when creating a client. You only need\\n        to specify this parameter if you want to use a previous API version\\n        of the client.\\n    use_ssl: Whether or not to use SSL. By default, SSL is used.\\n        Note that not all services support non-ssl connections.\\n    verify: Whether or not to verify SSL certificates. By default\\n        SSL certificates are verified. If False, SSL will still be used\\n        (unless use_ssl is False), but SSL certificates\\n        will not be verified. Passing a file path to this is deprecated.\\n    verify_cert_path: A filename of the CA cert bundle to\\n        use. You can specify this argument if you want to use a\\n        different CA cert bundle than the one used by botocore.\\n    endpoint_url: The complete URL to use for the constructed\\n        client. Normally, botocore will automatically construct the\\n        appropriate URL to use when communicating with a service. You\\n        can specify a complete URL (including the \\"http/https\\" scheme)\\n        to override this behavior. If this value is provided,\\n        then ``use_ssl`` is ignored.\\n    config: Advanced configuration for Botocore clients. See\\n        [botocore docs](https://botocore.amazonaws.com/v1/documentation/api/latest/reference/config.html)\\n        for more details."}}, "description": "Invoke a Lambda function. This block is part of the prefect-aws\\ncollection. Install prefect-aws with `pip install prefect-aws` to use this\\nblock.", "secret_fields": ["aws_credentials.aws_secret_access_key"], "block_type_slug": "lambda-function"}	sha256:93fb424309b85c0ef9a8e69cc9d0df1e0afa0f2ed15f1ecc710ec3463513b2e4	4ca24a8e-7af9-4bde-90e2-6c53ba9037fc	[]	0.4.14
4e00ee81-e5e6-4f18-8487-a02e1212fde5	2025-11-10 15:29:44.977847+00	2025-11-10 15:29:44.977862+00	{"type": "object", "title": "MinIOCredentials", "required": ["minio_root_user", "minio_root_password"], "properties": {"region_name": {"type": "string", "title": "Region Name", "description": "The AWS Region where you want to create new connections."}, "minio_root_user": {"type": "string", "title": "Minio Root User", "description": "Admin or root user."}, "minio_root_password": {"type": "string", "title": "Minio Root Password", "format": "password", "writeOnly": true, "description": "Admin or root password."}, "aws_client_parameters": {"allOf": [{"$ref": "#/definitions/AwsClientParameters"}], "title": "Aws Client Parameters", "description": "Extra parameters to initialize the Client."}}, "definitions": {"AwsClientParameters": {"type": "object", "title": "AwsClientParameters", "properties": {"config": {"type": "object", "title": "Botocore Config", "description": "Advanced configuration for Botocore clients."}, "verify": {"anyOf": [{"type": "boolean"}, {"type": "string", "format": "file-path"}], "title": "Verify", "default": true, "description": "Whether or not to verify SSL certificates."}, "use_ssl": {"type": "boolean", "title": "Use SSL", "default": true, "description": "Whether or not to use SSL."}, "api_version": {"type": "string", "title": "API Version", "description": "The API version to use."}, "endpoint_url": {"type": "string", "title": "Endpoint URL", "description": "The complete URL to use for the constructed client."}, "verify_cert_path": {"type": "string", "title": "Certificate Authority Bundle File Path", "format": "file-path", "description": "Path to the CA cert bundle to use."}}, "description": "Model used to manage extra parameters that you can pass when you initialize\\nthe Client. If you want to find more information, see\\n[boto3 docs](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/core/session.html)\\nfor more info about the possible client configurations.\\n\\nAttributes:\\n    api_version: The API version to use. By default, botocore will\\n        use the latest API version when creating a client. You only need\\n        to specify this parameter if you want to use a previous API version\\n        of the client.\\n    use_ssl: Whether or not to use SSL. By default, SSL is used.\\n        Note that not all services support non-ssl connections.\\n    verify: Whether or not to verify SSL certificates. By default\\n        SSL certificates are verified. If False, SSL will still be used\\n        (unless use_ssl is False), but SSL certificates\\n        will not be verified. Passing a file path to this is deprecated.\\n    verify_cert_path: A filename of the CA cert bundle to\\n        use. You can specify this argument if you want to use a\\n        different CA cert bundle than the one used by botocore.\\n    endpoint_url: The complete URL to use for the constructed\\n        client. Normally, botocore will automatically construct the\\n        appropriate URL to use when communicating with a service. You\\n        can specify a complete URL (including the \\"http/https\\" scheme)\\n        to override this behavior. If this value is provided,\\n        then ``use_ssl`` is ignored.\\n    config: Advanced configuration for Botocore clients. See\\n        [botocore docs](https://botocore.amazonaws.com/v1/documentation/api/latest/reference/config.html)\\n        for more details."}}, "description": "Block used to manage authentication with MinIO. Refer to the MinIO docs: https://docs.min.io/docs/minio-server-configuration-guide.html for more info about the possible credential configurations.", "secret_fields": ["minio_root_password"], "block_type_slug": "minio-credentials"}	sha256:5b4f1e5270f3a3670ff3d06b7e6e8246d54dacba976321dec42abe51c33415fb	badae73b-45cc-4d37-b133-3aceeeb9b4c4	[]	0.4.14
0c26191e-e1b7-4b0c-9c0d-c209e5f1a846	2025-11-10 15:29:44.988827+00	2025-11-10 15:29:44.988842+00	{"type": "object", "title": "S3Bucket", "required": ["bucket_name"], "properties": {"bucket_name": {"type": "string", "title": "Bucket Name", "description": "Name of your bucket."}, "credentials": {"anyOf": [{"$ref": "#/definitions/MinIOCredentials"}, {"$ref": "#/definitions/AwsCredentials"}], "title": "Credentials", "description": "A block containing your credentials to AWS or MinIO."}, "bucket_folder": {"type": "string", "title": "Bucket Folder", "default": "", "description": "A default path to a folder within the S3 bucket to use for reading and writing objects."}}, "definitions": {"AwsClientParameters": {"type": "object", "title": "AwsClientParameters", "properties": {"config": {"type": "object", "title": "Botocore Config", "description": "Advanced configuration for Botocore clients."}, "verify": {"anyOf": [{"type": "boolean"}, {"type": "string", "format": "file-path"}], "title": "Verify", "default": true, "description": "Whether or not to verify SSL certificates."}, "use_ssl": {"type": "boolean", "title": "Use SSL", "default": true, "description": "Whether or not to use SSL."}, "api_version": {"type": "string", "title": "API Version", "description": "The API version to use."}, "endpoint_url": {"type": "string", "title": "Endpoint URL", "description": "The complete URL to use for the constructed client."}, "verify_cert_path": {"type": "string", "title": "Certificate Authority Bundle File Path", "format": "file-path", "description": "Path to the CA cert bundle to use."}}, "description": "Model used to manage extra parameters that you can pass when you initialize\\nthe Client. If you want to find more information, see\\n[boto3 docs](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/core/session.html)\\nfor more info about the possible client configurations.\\n\\nAttributes:\\n    api_version: The API version to use. By default, botocore will\\n        use the latest API version when creating a client. You only need\\n        to specify this parameter if you want to use a previous API version\\n        of the client.\\n    use_ssl: Whether or not to use SSL. By default, SSL is used.\\n        Note that not all services support non-ssl connections.\\n    verify: Whether or not to verify SSL certificates. By default\\n        SSL certificates are verified. If False, SSL will still be used\\n        (unless use_ssl is False), but SSL certificates\\n        will not be verified. Passing a file path to this is deprecated.\\n    verify_cert_path: A filename of the CA cert bundle to\\n        use. You can specify this argument if you want to use a\\n        different CA cert bundle than the one used by botocore.\\n    endpoint_url: The complete URL to use for the constructed\\n        client. Normally, botocore will automatically construct the\\n        appropriate URL to use when communicating with a service. You\\n        can specify a complete URL (including the \\"http/https\\" scheme)\\n        to override this behavior. If this value is provided,\\n        then ``use_ssl`` is ignored.\\n    config: Advanced configuration for Botocore clients. See\\n        [botocore docs](https://botocore.amazonaws.com/v1/documentation/api/latest/reference/config.html)\\n        for more details."}}, "description": "Block used to store data using AWS S3 or S3-compatible object storage like MinIO.", "secret_fields": ["credentials.minio_root_password", "credentials.aws_secret_access_key"], "block_type_slug": "s3-bucket"}	sha256:da1e638612365b12ec83b6102986cc5efe54e84b7144bd668629f6972afe748f	1e2fc80f-bd6f-48ce-821a-f5ea0ef14445	["get-directory", "put-directory", "read-path", "write-path"]	0.4.14
4a298ce8-bc6b-4657-a725-e8bf8a4d92d8	2025-11-10 15:29:45.018529+00	2025-11-10 15:29:45.018545+00	{"type": "object", "title": "AzureBlobStorageContainer", "required": ["container_name"], "properties": {"base_folder": {"type": "string", "title": "Base Folder", "description": "A base path to a folder within the container to use for reading and writing objects."}, "credentials": {"allOf": [{"$ref": "#/definitions/AzureBlobStorageCredentials"}], "title": "Credentials", "description": "The credentials to use for authentication with Azure."}, "container_name": {"type": "string", "title": "Container Name", "description": "The name of a Azure Blob Storage container."}}, "description": "Represents a container in Azure Blob Storage.\\n\\nThis class provides methods for downloading and uploading files and folders\\nto and from the Azure Blob Storage container.", "secret_fields": ["credentials.connection_string"], "block_type_slug": "azure-blob-storage-container"}	sha256:dcb604fba31292177868c0998110c7b4c0ba0b5601ee39679b2936adfd836f19	d9c19e52-a0e7-49e6-bda5-2ae3ce2cbae2	["get-directory", "put-directory", "read-path", "write-path"]	0.3.7
039b7e5b-35cc-4c78-818b-db95f2162317	2025-11-10 15:29:45.029714+00	2025-11-10 15:29:45.029729+00	{"type": "object", "title": "AzureBlobStorageCredentials", "properties": {"account_url": {"type": "string", "title": "Account URL", "description": "The URL for your Azure storage account. If provided, the account URL will be used to authenticate with the discovered default Azure credentials."}, "connection_string": {"type": "string", "title": "Connection String", "format": "password", "writeOnly": true, "description": "The connection string to your Azure storage account. If provided, the connection string will take precedence over the account URL."}}, "description": "Stores credentials for authenticating with Azure Blob Storage.", "secret_fields": ["connection_string"], "block_type_slug": "azure-blob-storage-credentials"}	sha256:73e835b6cb9a1902fd869037fb7f8a90f974508dda7a168e748a1206e7c325eb	2c10e829-8234-4143-80f2-a9ab5f794e76	[]	non-versioned
08aed50c-e6db-4c9d-8b59-5c7b5a8b63bd	2025-11-10 15:29:45.044854+00	2025-11-10 15:29:45.044872+00	{"type": "object", "title": "AzureBlobStorageCredentials", "properties": {"account_url": {"type": "string", "title": "Account URL", "description": "The URL for your Azure storage account. If provided, the account URL will be used to authenticate with the discovered default Azure credentials."}, "connection_string": {"type": "string", "title": "Connection String", "format": "password", "writeOnly": true, "description": "The connection string to your Azure storage account. If provided, the connection string will take precedence over the account URL."}}, "description": "Stores credentials for authenticating with Azure Blob Storage.", "secret_fields": ["connection_string"], "block_type_slug": "azure-blob-storage-credentials"}	sha256:73e835b6cb9a1902fd869037fb7f8a90f974508dda7a168e748a1206e7c325eb	2c10e829-8234-4143-80f2-a9ab5f794e76	[]	0.3.7
ad7a0d94-fd29-4eac-ba04-03472b1c7b56	2025-11-10 15:29:45.054852+00	2025-11-10 15:29:45.054867+00	{"type": "object", "title": "AzureContainerInstanceCredentials", "properties": {"client_id": {"type": "string", "title": "Client ID", "description": "The service principal client ID. If none of client_id, tenant_id, and client_secret are provided, will use DefaultAzureCredential; else will need to provide all three to use ClientSecretCredential."}, "tenant_id": {"type": "string", "title": "Tenant ID", "description": "The service principal tenant ID.If none of client_id, tenant_id, and client_secret are provided, will use DefaultAzureCredential; else will need to provide all three to use ClientSecretCredential."}, "client_secret": {"type": "string", "title": "Client Secret", "format": "password", "writeOnly": true, "description": "The service principal client secret.If none of client_id, tenant_id, and client_secret are provided, will use DefaultAzureCredential; else will need to provide all three to use ClientSecretCredential."}, "credential_kwargs": {"type": "object", "title": "Additional Credential Keyword Arguments", "description": "Additional keyword arguments to pass to `ClientSecretCredential` or `DefaultAzureCredential`."}}, "description": "Block used to manage Azure Container Instances authentication. Stores Azure Service\\nPrincipal authentication data.", "secret_fields": ["client_secret"], "block_type_slug": "azure-container-instance-credentials"}	sha256:17a9122f9f345a4547128cc05f7ff7146da9a72c4bac2850004fcc6c8d9be2d1	4b49a287-9159-4d7c-ba22-88bb09356b01	[]	0.3.7
06fb9814-4ade-4689-84a2-2a073e8e322d	2025-11-10 15:29:45.06574+00	2025-11-10 15:29:45.065756+00	{"type": "object", "title": "AzureContainerInstanceJob", "required": ["resource_group_name", "subscription_id"], "properties": {"cpu": {"type": "number", "title": "CPU", "default": 1.0, "description": "The number of virtual CPUs to assign to the task container. If not provided, a default value of 1.0 will be used."}, "env": {"type": "object", "title": "Environment Variables", "description": "Environment variables to provide to the task run. These variables are set on the Prefect container at task runtime. These will not be set on the task definition.", "additionalProperties": {"type": "string"}}, "name": {"type": "string", "title": "Name", "description": "Name applied to the infrastructure for identification."}, "type": {"enum": ["container-instance-job"], "type": "string", "title": "Type", "default": "container-instance-job", "description": "The slug for this task type."}, "image": {"type": "string", "title": "Image", "description": "The image to use for the Prefect container in the task. This value defaults to a Prefect base image matching your local versions."}, "labels": {"type": "object", "title": "Labels", "description": "Labels applied to the infrastructure for metadata purposes.", "additionalProperties": {"type": "string"}}, "memory": {"type": "number", "title": "Memory", "default": 1.0, "description": "The amount of memory in gigabytes to provide to the ACI task. Valid amounts are specified in the Azure documentation. If not provided, a default value of  1.0 will be used unless present on the task definition."}, "command": {"type": "array", "items": {"type": "string"}, "title": "Command", "description": "The command to run in the infrastructure."}, "gpu_sku": {"type": "string", "title": "GPU SKU", "description": "The Azure GPU SKU to use. See the ACI documentation for a list of GPU SKUs available in each Azure region."}, "gpu_count": {"type": "integer", "title": "GPU Count", "description": "The number of GPUs to assign to the task container. If not provided, no GPU will be used."}, "entrypoint": {"type": "string", "title": "Entrypoint", "default": "/opt/prefect/entrypoint.sh", "description": "The entrypoint of the container you wish you run. This value defaults to the entrypoint used by Prefect images and should only be changed when using a custom image that is not based on an official Prefect image. Any commands set on deployments will be passed to the entrypoint as parameters."}, "identities": {"type": "array", "items": {"type": "string"}, "title": "Identities", "description": "A list of user-assigned identities to associate with the container group. The identities should be an ARM resource IDs in the form: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identityName}'."}, "subnet_ids": {"type": "array", "items": {"type": "string"}, "title": "Subnet IDs", "description": "A list of Azure subnet IDs the container should be connected to."}, "dns_servers": {"type": "array", "items": {"type": "string"}, "title": "DNS Servers", "description": "A list of custom DNS Servers the container should use."}, "stream_output": {"type": "boolean", "title": "Stream Output", "description": "If `True`, logs will be streamed from the Prefect container to the local console."}, "image_registry": {"anyOf": [{"$ref": "#/definitions/DockerRegistry"}, {"$ref": "#/definitions/ACRManagedIdentity"}], "title": "Image Registry (Optional)", "description": "To use any private container registry with a username and password, choose DockerRegistry. To use a private Azure Container Registry with a managed identity, choose ACRManagedIdentity."}, "aci_credentials": {"allOf": [{"$ref": "#/definitions/AzureContainerInstanceCredentials"}], "title": "Aci Credentials", "description": "Credentials for Azure Container Instances; if not provided will attempt to use DefaultAzureCredentials."}, "subscription_id": {"type": "string", "title": "Azure Subscription ID", "format": "password", "writeOnly": true, "description": "The ID of the Azure subscription to create containers under."}, "resource_group_name": {"type": "string", "title": "Azure Resource Group Name", "description": "The name of the Azure Resource Group in which to run Prefect ACI tasks."}, "task_watch_poll_interval": {"type": "number", "title": "Task Watch Poll Interval", "default": 5.0, "description": "The number of seconds to wait between Azure API calls while monitoring the state of an Azure Container Instances task."}, "task_start_timeout_seconds": {"type": "integer", "title": "Task Start Timeout Seconds", "default": 240, "description": "The amount of time to watch for the start of the ACI container. before marking it as failed."}}, "definitions": {"ACRManagedIdentity": {"type": "object", "title": "ACRManagedIdentity", "required": ["registry_url", "identity"], "properties": {"identity": {"type": "string", "title": "Identity", "description": "The user-assigned Azure managed identity for the private registry."}, "registry_url": {"type": "string", "title": "Registry URL", "description": "The URL to the registry, such as myregistry.azurecr.io. Generally, 'http' or 'https' can be omitted."}}, "description": "Use a Managed Identity to access Azure Container registry. Requires the\\nuser-assigned managed identity be available to the ACI container group."}}, "description": "Run tasks using Azure Container Instances. Note this block is experimental. The interface may change without notice.", "secret_fields": ["aci_credentials.client_secret", "subscription_id", "image_registry.password"], "block_type_slug": "azure-container-instance-job"}	sha256:367f8171cce7f4937a49fe19febd1752cb95a2eed83e91ec40dd6120d90eff2f	2def6597-968c-4f82-9286-ad251512ec7e	["run-infrastructure"]	0.3.7
a63bd2cb-e9b7-4b3b-8c37-f1323f9c1c56	2025-11-10 15:29:45.109772+00	2025-11-10 15:29:45.109786+00	{"type": "object", "title": "AzureMlCredentials", "required": ["tenant_id", "service_principal_id", "service_principal_password", "subscription_id", "resource_group", "workspace_name"], "properties": {"tenant_id": {"type": "string", "title": "Tenant Id", "description": "The active directory tenant that the service identity belongs to."}, "resource_group": {"type": "string", "title": "Resource Group", "description": "The resource group containing the workspace."}, "workspace_name": {"type": "string", "title": "Workspace Name", "description": "The existing workspace name."}, "subscription_id": {"type": "string", "title": "Subscription Id", "description": "The Azure subscription ID containing the workspace, in format: '00000000-0000-0000-0000-000000000000'."}, "service_principal_id": {"type": "string", "title": "Service Principal Id", "description": "The service principal ID."}, "service_principal_password": {"type": "string", "title": "Service Principal Password", "format": "password", "writeOnly": true, "description": "The service principal password/key."}}, "description": "Block used to manage authentication with AzureML. Azure authentication is\\nhandled via the `azure` module.", "secret_fields": ["service_principal_password"], "block_type_slug": "azureml-credentials"}	sha256:11338ccb5cd90992ac378f9b7a73cbf1942fae58343ac2026b3718ed688b52e6	7c0bc1a2-2364-4826-abaa-a9cce10bafa1	[]	0.3.7
b2313c80-ac19-4ad9-a087-778dbe199161	2025-11-10 15:29:45.119959+00	2025-11-10 15:29:45.119974+00	{"type": "object", "title": "BitBucketCredentials", "properties": {"url": {"type": "string", "title": "URL", "default": "https://api.bitbucket.org/", "description": "The base URL of your BitBucket instance."}, "token": {"name": "Personal Access Token", "type": "string", "title": "Token", "format": "password", "example": "x-token-auth:my-token", "writeOnly": true, "description": "A BitBucket Personal Access Token - required for private repositories."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password to authenticate to BitBucket."}, "username": {"type": "string", "title": "Username", "description": "Identification name unique across entire BitBucket site."}}, "description": "Store BitBucket credentials to interact with private BitBucket repositories.", "secret_fields": ["token", "password"], "block_type_slug": "bitbucket-credentials"}	sha256:ef96bdc56cde651f152e3f8938018d53d725b25b5ae98777872c0962250ba0fc	1d9bea68-b0da-42db-92cc-fe5316e2955b	[]	0.2.2
d1c69885-1704-4987-95d7-07025875f154	2025-11-10 15:29:45.130299+00	2025-11-10 15:29:45.130316+00	{"type": "object", "title": "BitBucketRepository", "required": ["repository"], "properties": {"reference": {"type": "string", "title": "Reference", "description": "An optional reference to pin to; can be a branch or tag."}, "repository": {"type": "string", "title": "Repository", "description": "The URL of a BitBucket repository to read from in HTTPS format"}, "bitbucket_credentials": {"allOf": [{"$ref": "#/definitions/BitBucketCredentials"}], "title": "Bitbucket Credentials", "description": "An optional BitBucketCredentials block for authenticating with private BitBucket repos."}}, "description": "Interact with files stored in BitBucket repositories.", "secret_fields": ["bitbucket_credentials.token", "bitbucket_credentials.password"], "block_type_slug": "bitbucket-repository"}	sha256:b159a8f21358b694f13fb67b73f20bf3f8b74138940fc0f16ab08107e78d5237	11d0c5c7-c932-4438-b0b7-38e1365e0505	["get-directory"]	0.2.2
303c0755-7aa7-43d7-8438-29c2cfadc381	2025-11-10 15:29:45.149415+00	2025-11-10 15:29:45.14943+00	{"type": "object", "title": "DatabricksCredentials", "required": ["databricks_instance", "token"], "properties": {"token": {"type": "string", "title": "Token", "format": "password", "writeOnly": true, "description": "The token to authenticate with Databricks."}, "client_kwargs": {"type": "object", "title": "Client Kwargs", "description": "Additional keyword arguments to pass to AsyncClient."}, "databricks_instance": {"type": "string", "title": "Databricks Instance", "description": "Databricks instance used in formatting the endpoint URL."}}, "description": "Block used to manage Databricks authentication.", "secret_fields": ["token"], "block_type_slug": "databricks-credentials"}	sha256:58bae1446ee7a01ec90d15cf756f8acc221329e3b3580b077b508ff0f2425e35	51d69e36-e1f5-4696-aba4-da2840e8e144	[]	0.2.3
199d33e2-63f3-44fb-8c56-37daa90c3b9c	2025-11-10 15:29:45.159931+00	2025-11-10 15:29:45.159948+00	{"type": "object", "title": "BigQueryTargetConfigs", "required": ["schema"], "properties": {"type": {"enum": ["bigquery"], "type": "string", "title": "Type", "default": "bigquery", "description": "The type of target."}, "extras": {"type": "object", "title": "Extras", "description": "Extra target configs' keywords, not yet exposed in prefect-dbt, but available in dbt."}, "schema": {"type": "string", "title": "Schema", "description": "The schema that dbt will build objects into; in BigQuery, a schema is actually a dataset."}, "project": {"type": "string", "title": "Project", "description": "The project to use."}, "threads": {"type": "integer", "title": "Threads", "default": 4, "description": "The number of threads representing the max number of paths through the graph dbt may work on at once."}, "credentials": {"allOf": [{"$ref": "#/definitions/GcpCredentials"}], "title": "Credentials", "description": "The credentials to use to authenticate."}, "allow_field_overrides": {"type": "boolean", "title": "Allow Field Overrides", "default": false, "description": "If enabled, fields from dbt target configs will override fields provided in extras and credentials."}}, "description": "dbt CLI target configs containing credentials and settings, specific to BigQuery.", "secret_fields": ["credentials.service_account_info.*"], "block_type_slug": "dbt-cli-bigquery-target-configs"}	sha256:842c5dc7d4d1557eedff36982eafeda7b0803915942f72224a7f627efdbe5ff5	d01de82c-ebf0-4b23-8d30-1aafc2670610	[]	0.4.1
27ebbf43-2ea7-49fe-a4f4-aa08b2e54dd0	2025-11-10 15:29:45.171269+00	2025-11-10 15:29:45.1713+00	{"type": "object", "title": "GcpCredentials", "properties": {"project": {"type": "string", "title": "Project", "description": "The GCP project to use for the client."}, "service_account_file": {"type": "string", "title": "Service Account File", "format": "path", "description": "Path to the service account JSON keyfile."}, "service_account_info": {"type": "object", "title": "Service Account Info", "description": "The contents of the keyfile as a dict."}}, "description": "Block used to manage authentication with GCP. Google authentication is\\nhandled via the `google.oauth2` module or through the CLI.\\nSpecify either one of service `account_file` or `service_account_info`; if both\\nare not specified, the client will try to detect the credentials following Google's\\n[Application Default Credentials](https://cloud.google.com/docs/authentication/application-default-credentials).\\nSee Google's [Authentication documentation](https://cloud.google.com/docs/authentication#service-accounts)\\nfor details on inference and recommended authentication patterns.", "secret_fields": ["service_account_info.*"], "block_type_slug": "gcp-credentials"}	sha256:f764f9c506a2bed9e5ed7cc9083d06d95f13c01c8c9a9e45bae5d9b4dc522624	4817e94d-e90f-4489-b87b-a5e4595f3e92	[]	non-versioned
2e359870-7534-4bf8-ae7a-c6c5613b8f97	2025-11-10 15:29:45.185785+00	2025-11-10 15:29:45.185801+00	{"type": "object", "title": "GlobalConfigs", "properties": {"debug": {"type": "boolean", "title": "Debug", "description": "Whether to redirect dbt's debug logs to standard out."}, "extras": {"type": "object", "title": "Extras", "description": "Extra target configs' keywords, not yet exposed in prefect-dbt, but available in dbt."}, "fail_fast": {"type": "boolean", "title": "Fail Fast", "description": "Make dbt exit immediately if a single resource fails to build."}, "log_format": {"type": "string", "title": "Log Format", "description": "The LOG_FORMAT config specifies how dbt's logs should be formatted. If the value of this config is json, dbt will output fully structured logs in JSON format."}, "use_colors": {"type": "boolean", "title": "Use Colors", "description": "Colorize the output it prints in your terminal."}, "warn_error": {"type": "boolean", "title": "Warn Error", "description": "Whether to convert dbt warnings into errors."}, "write_json": {"type": "boolean", "title": "Write Json", "description": "Determines whether dbt writes JSON artifacts to the target/ directory."}, "partial_parse": {"type": "boolean", "title": "Partial Parse", "description": "When partial parsing is enabled, dbt will use an stored internal manifest to determine which files have been changed (if any) since it last parsed the project."}, "printer_width": {"type": "integer", "title": "Printer Width", "description": "Length of characters before starting a new line."}, "static_parser": {"type": "boolean", "title": "Static Parser", "description": "Whether to use the [static parser](https://docs.getdbt.com/reference/parsing#static-parser)."}, "version_check": {"type": "boolean", "title": "Version Check", "description": "Whether to raise an error if a project's version is used with an incompatible dbt version."}, "allow_field_overrides": {"type": "boolean", "title": "Allow Field Overrides", "default": false, "description": "If enabled, fields from dbt target configs will override fields provided in extras and credentials."}, "use_experimental_parser": {"type": "boolean", "title": "Use Experimental Parser", "description": "Opt into the latest experimental version of the static parser."}, "send_anonymous_usage_stats": {"type": "boolean", "title": "Send Anonymous Usage Stats", "description": "Whether usage stats are sent to dbt."}}, "description": "Global configs control things like the visual output\\nof logs, the manner in which dbt parses your project,\\nand what to do when dbt finds a version mismatch\\nor a failing model. Docs can be found [here](\\nhttps://docs.getdbt.com/reference/global-configs).", "secret_fields": [], "block_type_slug": "dbt-cli-global-configs"}	sha256:63df9d18a1aafde1cc8330cd49f81f6600b4ce6db92955973bbf341cc86e916d	107cc660-78c3-4c3e-b976-05470e6b0883	[]	0.4.1
b0dd96ec-a223-439e-906b-705e61aec3d8	2025-11-10 15:29:45.197317+00	2025-11-10 15:29:45.197333+00	{"type": "object", "title": "PostgresTargetConfigs", "required": ["schema", "credentials"], "properties": {"type": {"enum": ["postgres"], "type": "string", "title": "Type", "default": "postgres", "description": "The type of the target."}, "extras": {"type": "object", "title": "Extras", "description": "Extra target configs' keywords, not yet exposed in prefect-dbt, but available in dbt."}, "schema": {"type": "string", "title": "Schema", "description": "The schema that dbt will build objects into; in BigQuery, a schema is actually a dataset."}, "threads": {"type": "integer", "title": "Threads", "default": 4, "description": "The number of threads representing the max number of paths through the graph dbt may work on at once."}, "credentials": {"anyOf": [{"$ref": "#/definitions/SqlAlchemyConnector"}, {"$ref": "#/definitions/DatabaseCredentials"}], "title": "Credentials", "description": "The credentials to use to authenticate; if there are duplicate keys between credentials and TargetConfigs, e.g. schema, an error will be raised."}, "allow_field_overrides": {"type": "boolean", "title": "Allow Field Overrides", "default": false, "description": "If enabled, fields from dbt target configs will override fields provided in extras and credentials."}}, "definitions": {"SyncDriver": {"enum": ["postgresql+psycopg2", "postgresql+pg8000", "postgresql+psycopg2cffi", "postgresql+pypostgresql", "postgresql+pygresql", "mysql+mysqldb", "mysql+pymysql", "mysql+mysqlconnector", "mysql+cymysql", "mysql+oursql", "mysql+pyodbc", "sqlite+pysqlite", "sqlite+pysqlcipher", "oracle+cx_oracle", "mssql+pyodbc", "mssql+mxodbc", "mssql+pymssql"], "title": "SyncDriver", "description": "Known dialects with their corresponding sync drivers.\\n\\nAttributes:\\n    POSTGRESQL_PSYCOPG2 (Enum): [postgresql+psycopg2](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2)\\n    POSTGRESQL_PG8000 (Enum): [postgresql+pg8000](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pg8000)\\n    POSTGRESQL_PSYCOPG2CFFI (Enum): [postgresql+psycopg2cffi](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2cffi)\\n    POSTGRESQL_PYPOSTGRESQL (Enum): [postgresql+pypostgresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pypostgresql)\\n    POSTGRESQL_PYGRESQL (Enum): [postgresql+pygresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pygresql)\\n\\n    MYSQL_MYSQLDB (Enum): [mysql+mysqldb](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqldb)\\n    MYSQL_PYMYSQL (Enum): [mysql+pymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pymysql)\\n    MYSQL_MYSQLCONNECTOR (Enum): [mysql+mysqlconnector](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqlconnector)\\n    MYSQL_CYMYSQL (Enum): [mysql+cymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.cymysql)\\n    MYSQL_OURSQL (Enum): [mysql+oursql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.oursql)\\n    MYSQL_PYODBC (Enum): [mysql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pyodbc)\\n\\n    SQLITE_PYSQLITE (Enum): [sqlite+pysqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlite)\\n    SQLITE_PYSQLCIPHER (Enum): [sqlite+pysqlcipher](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlcipher)\\n\\n    ORACLE_CX_ORACLE (Enum): [oracle+cx_oracle](https://docs.sqlalchemy.org/en/14/dialects/oracle.html#module-sqlalchemy.dialects.oracle.cx_oracle)\\n\\n    MSSQL_PYODBC (Enum): [mssql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pyodbc)\\n    MSSQL_MXODBC (Enum): [mssql+mxodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.mxodbc)\\n    MSSQL_PYMSSQL (Enum): [mssql+pymssql](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pymssql)"}, "AsyncDriver": {"enum": ["postgresql+asyncpg", "sqlite+aiosqlite", "mysql+asyncmy", "mysql+aiomysql"], "title": "AsyncDriver", "description": "Known dialects with their corresponding async drivers.\\n\\nAttributes:\\n    POSTGRESQL_ASYNCPG (Enum): [postgresql+asyncpg](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.asyncpg)\\n\\n    SQLITE_AIOSQLITE (Enum): [sqlite+aiosqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.aiosqlite)\\n\\n    MYSQL_ASYNCMY (Enum): [mysql+asyncmy](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.asyncmy)\\n    MYSQL_AIOMYSQL (Enum): [mysql+aiomysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.aiomysql)"}, "ConnectionComponents": {"type": "object", "title": "ConnectionComponents", "required": ["driver", "database"], "properties": {"host": {"type": "string", "title": "Host", "description": "The host address of the database."}, "port": {"type": "string", "title": "Port", "description": "The port to connect to the database."}, "query": {"type": "object", "title": "Query", "description": "A dictionary of string keys to string values to be passed to the dialect and/or the DBAPI upon connect. To specify non-string parameters to a Python DBAPI directly, use connect_args.", "additionalProperties": {"type": "string"}}, "driver": {"anyOf": [{"$ref": "#/definitions/AsyncDriver"}, {"$ref": "#/definitions/SyncDriver"}, {"type": "string"}], "title": "Driver", "description": "The driver name to use."}, "database": {"type": "string", "title": "Database", "description": "The name of the database to use."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password used to authenticate."}, "username": {"type": "string", "title": "Username", "description": "The user name used to authenticate."}}, "description": "Parameters to use to create a SQLAlchemy engine URL.\\n\\nAttributes:\\n    driver: The driver name to use.\\n    database: The name of the database to use.\\n    username: The user name used to authenticate.\\n    password: The password used to authenticate.\\n    host: The host address of the database.\\n    port: The port to connect to the database.\\n    query: A dictionary of string keys to string values to be passed to the dialect\\n        and/or the DBAPI upon connect."}}, "description": "dbt CLI target configs containing credentials and settings specific to Postgres.", "secret_fields": ["credentials.connection_info.password", "credentials.password"], "block_type_slug": "dbt-cli-postgres-target-configs"}	sha256:1552a2d5c102961df4082329f39c10b8a51e26ee687148efd6d71ce8be8850c0	518f9ede-528c-407e-b435-7d4a22a7752f	[]	0.4.1
e89af390-ba32-47a2-9407-23d82026ccb1	2025-11-10 15:29:45.209975+00	2025-11-10 15:29:45.20999+00	{"type": "object", "title": "SqlAlchemyConnector", "required": ["connection_info"], "properties": {"fetch_size": {"type": "integer", "title": "Fetch Size", "default": 1, "description": "The number of rows to fetch at a time."}, "connect_args": {"type": "object", "title": "Additional Connection Arguments", "description": "The options which will be passed directly to the DBAPI's connect() method as additional keyword arguments."}, "connection_info": {"anyOf": [{"$ref": "#/definitions/ConnectionComponents"}, {"type": "string", "format": "uri", "maxLength": 65536, "minLength": 1}], "title": "Connection Info", "description": "SQLAlchemy URL to create the engine; either create from components or create from a string."}}, "definitions": {"SyncDriver": {"enum": ["postgresql+psycopg2", "postgresql+pg8000", "postgresql+psycopg2cffi", "postgresql+pypostgresql", "postgresql+pygresql", "mysql+mysqldb", "mysql+pymysql", "mysql+mysqlconnector", "mysql+cymysql", "mysql+oursql", "mysql+pyodbc", "sqlite+pysqlite", "sqlite+pysqlcipher", "oracle+cx_oracle", "mssql+pyodbc", "mssql+mxodbc", "mssql+pymssql"], "title": "SyncDriver", "description": "Known dialects with their corresponding sync drivers.\\n\\nAttributes:\\n    POSTGRESQL_PSYCOPG2 (Enum): [postgresql+psycopg2](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2)\\n    POSTGRESQL_PG8000 (Enum): [postgresql+pg8000](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pg8000)\\n    POSTGRESQL_PSYCOPG2CFFI (Enum): [postgresql+psycopg2cffi](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2cffi)\\n    POSTGRESQL_PYPOSTGRESQL (Enum): [postgresql+pypostgresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pypostgresql)\\n    POSTGRESQL_PYGRESQL (Enum): [postgresql+pygresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pygresql)\\n\\n    MYSQL_MYSQLDB (Enum): [mysql+mysqldb](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqldb)\\n    MYSQL_PYMYSQL (Enum): [mysql+pymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pymysql)\\n    MYSQL_MYSQLCONNECTOR (Enum): [mysql+mysqlconnector](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqlconnector)\\n    MYSQL_CYMYSQL (Enum): [mysql+cymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.cymysql)\\n    MYSQL_OURSQL (Enum): [mysql+oursql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.oursql)\\n    MYSQL_PYODBC (Enum): [mysql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pyodbc)\\n\\n    SQLITE_PYSQLITE (Enum): [sqlite+pysqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlite)\\n    SQLITE_PYSQLCIPHER (Enum): [sqlite+pysqlcipher](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlcipher)\\n\\n    ORACLE_CX_ORACLE (Enum): [oracle+cx_oracle](https://docs.sqlalchemy.org/en/14/dialects/oracle.html#module-sqlalchemy.dialects.oracle.cx_oracle)\\n\\n    MSSQL_PYODBC (Enum): [mssql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pyodbc)\\n    MSSQL_MXODBC (Enum): [mssql+mxodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.mxodbc)\\n    MSSQL_PYMSSQL (Enum): [mssql+pymssql](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pymssql)"}, "AsyncDriver": {"enum": ["postgresql+asyncpg", "sqlite+aiosqlite", "mysql+asyncmy", "mysql+aiomysql"], "title": "AsyncDriver", "description": "Known dialects with their corresponding async drivers.\\n\\nAttributes:\\n    POSTGRESQL_ASYNCPG (Enum): [postgresql+asyncpg](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.asyncpg)\\n\\n    SQLITE_AIOSQLITE (Enum): [sqlite+aiosqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.aiosqlite)\\n\\n    MYSQL_ASYNCMY (Enum): [mysql+asyncmy](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.asyncmy)\\n    MYSQL_AIOMYSQL (Enum): [mysql+aiomysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.aiomysql)"}, "ConnectionComponents": {"type": "object", "title": "ConnectionComponents", "required": ["driver", "database"], "properties": {"host": {"type": "string", "title": "Host", "description": "The host address of the database."}, "port": {"type": "string", "title": "Port", "description": "The port to connect to the database."}, "query": {"type": "object", "title": "Query", "description": "A dictionary of string keys to string values to be passed to the dialect and/or the DBAPI upon connect. To specify non-string parameters to a Python DBAPI directly, use connect_args.", "additionalProperties": {"type": "string"}}, "driver": {"anyOf": [{"$ref": "#/definitions/AsyncDriver"}, {"$ref": "#/definitions/SyncDriver"}, {"type": "string"}], "title": "Driver", "description": "The driver name to use."}, "database": {"type": "string", "title": "Database", "description": "The name of the database to use."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password used to authenticate."}, "username": {"type": "string", "title": "Username", "description": "The user name used to authenticate."}}, "description": "Parameters to use to create a SQLAlchemy engine URL.\\n\\nAttributes:\\n    driver: The driver name to use.\\n    database: The name of the database to use.\\n    username: The user name used to authenticate.\\n    password: The password used to authenticate.\\n    host: The host address of the database.\\n    port: The port to connect to the database.\\n    query: A dictionary of string keys to string values to be passed to the dialect\\n        and/or the DBAPI upon connect."}}, "description": "Block used to manage authentication with a database.\\n\\nUpon instantiating, an engine is created and maintained for the life of\\nthe object until the close method is called.\\n\\nIt is recommended to use this block as a context manager, which will automatically\\nclose the engine and its connections when the context is exited.\\n\\nIt is also recommended that this block is loaded and consumed within a single task\\nor flow because if the block is passed across separate tasks and flows,\\nthe state of the block's connection and cursor could be lost.", "secret_fields": ["connection_info.password"], "block_type_slug": "sqlalchemy-connector"}	sha256:01e6c0bdaac125860811b201f5a5e98ffefd5f8a49f1398b6996aec362643acc	26e2a9b6-d402-4582-96b5-2e830228705f	[]	non-versioned
ecc358cf-363c-44db-859e-d38cb196620a	2025-11-10 15:29:45.225531+00	2025-11-10 15:29:45.225545+00	{"type": "object", "title": "DatabaseCredentials", "properties": {"url": {"type": "string", "title": "Url", "format": "uri", "maxLength": 65536, "minLength": 1, "description": "Manually create and provide a URL to create the engine, this is useful for external dialects, e.g. Snowflake, because some of the params, such as 'warehouse', is not directly supported in the vanilla `sqlalchemy.engine.URL.create` method; do not provide this alongside with other URL params as it will raise a `ValueError`."}, "host": {"type": "string", "title": "Host", "description": "The host address of the database."}, "port": {"type": "string", "title": "Port", "description": "The port to connect to the database."}, "query": {"type": "object", "title": "Query", "description": "A dictionary of string keys to string values to be passed to the dialect and/or the DBAPI upon connect. To specify non-string parameters to a Python DBAPI directly, use connect_args.", "additionalProperties": {"type": "string"}}, "driver": {"anyOf": [{"$ref": "#/definitions/AsyncDriver"}, {"$ref": "#/definitions/SyncDriver"}, {"type": "string"}], "title": "Driver", "description": "The driver name to use."}, "database": {"type": "string", "title": "Database", "description": "The name of the database to use."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password used to authenticate."}, "username": {"type": "string", "title": "Username", "description": "The user name used to authenticate."}, "connect_args": {"type": "object", "title": "Connect Args", "description": "The options which will be passed directly to the DBAPI's connect() method as additional keyword arguments."}}, "definitions": {"SyncDriver": {"enum": ["postgresql+psycopg2", "postgresql+pg8000", "postgresql+psycopg2cffi", "postgresql+pypostgresql", "postgresql+pygresql", "mysql+mysqldb", "mysql+pymysql", "mysql+mysqlconnector", "mysql+cymysql", "mysql+oursql", "mysql+pyodbc", "sqlite+pysqlite", "sqlite+pysqlcipher", "oracle+cx_oracle", "mssql+pyodbc", "mssql+mxodbc", "mssql+pymssql"], "title": "SyncDriver", "description": "Known dialects with their corresponding sync drivers.\\n\\nAttributes:\\n    POSTGRESQL_PSYCOPG2 (Enum): [postgresql+psycopg2](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2)\\n    POSTGRESQL_PG8000 (Enum): [postgresql+pg8000](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pg8000)\\n    POSTGRESQL_PSYCOPG2CFFI (Enum): [postgresql+psycopg2cffi](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2cffi)\\n    POSTGRESQL_PYPOSTGRESQL (Enum): [postgresql+pypostgresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pypostgresql)\\n    POSTGRESQL_PYGRESQL (Enum): [postgresql+pygresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pygresql)\\n\\n    MYSQL_MYSQLDB (Enum): [mysql+mysqldb](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqldb)\\n    MYSQL_PYMYSQL (Enum): [mysql+pymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pymysql)\\n    MYSQL_MYSQLCONNECTOR (Enum): [mysql+mysqlconnector](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqlconnector)\\n    MYSQL_CYMYSQL (Enum): [mysql+cymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.cymysql)\\n    MYSQL_OURSQL (Enum): [mysql+oursql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.oursql)\\n    MYSQL_PYODBC (Enum): [mysql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pyodbc)\\n\\n    SQLITE_PYSQLITE (Enum): [sqlite+pysqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlite)\\n    SQLITE_PYSQLCIPHER (Enum): [sqlite+pysqlcipher](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlcipher)\\n\\n    ORACLE_CX_ORACLE (Enum): [oracle+cx_oracle](https://docs.sqlalchemy.org/en/14/dialects/oracle.html#module-sqlalchemy.dialects.oracle.cx_oracle)\\n\\n    MSSQL_PYODBC (Enum): [mssql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pyodbc)\\n    MSSQL_MXODBC (Enum): [mssql+mxodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.mxodbc)\\n    MSSQL_PYMSSQL (Enum): [mssql+pymssql](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pymssql)"}, "AsyncDriver": {"enum": ["postgresql+asyncpg", "sqlite+aiosqlite", "mysql+asyncmy", "mysql+aiomysql"], "title": "AsyncDriver", "description": "Known dialects with their corresponding async drivers.\\n\\nAttributes:\\n    POSTGRESQL_ASYNCPG (Enum): [postgresql+asyncpg](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.asyncpg)\\n\\n    SQLITE_AIOSQLITE (Enum): [sqlite+aiosqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.aiosqlite)\\n\\n    MYSQL_ASYNCMY (Enum): [mysql+asyncmy](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.asyncmy)\\n    MYSQL_AIOMYSQL (Enum): [mysql+aiomysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.aiomysql)"}, "ConnectionComponents": {"type": "object", "title": "ConnectionComponents", "required": ["driver", "database"], "properties": {"host": {"type": "string", "title": "Host", "description": "The host address of the database."}, "port": {"type": "string", "title": "Port", "description": "The port to connect to the database."}, "query": {"type": "object", "title": "Query", "description": "A dictionary of string keys to string values to be passed to the dialect and/or the DBAPI upon connect. To specify non-string parameters to a Python DBAPI directly, use connect_args.", "additionalProperties": {"type": "string"}}, "driver": {"anyOf": [{"$ref": "#/definitions/AsyncDriver"}, {"$ref": "#/definitions/SyncDriver"}, {"type": "string"}], "title": "Driver", "description": "The driver name to use."}, "database": {"type": "string", "title": "Database", "description": "The name of the database to use."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password used to authenticate."}, "username": {"type": "string", "title": "Username", "description": "The user name used to authenticate."}}, "description": "Parameters to use to create a SQLAlchemy engine URL.\\n\\nAttributes:\\n    driver: The driver name to use.\\n    database: The name of the database to use.\\n    username: The user name used to authenticate.\\n    password: The password used to authenticate.\\n    host: The host address of the database.\\n    port: The port to connect to the database.\\n    query: A dictionary of string keys to string values to be passed to the dialect\\n        and/or the DBAPI upon connect."}}, "description": "Block used to manage authentication with a database.", "secret_fields": ["password"], "block_type_slug": "database-credentials"}	sha256:64175f83f2ae15bef7893a4d9a02658f2b5288747d54594ca6d356dc42e9993c	dd83a224-2277-4759-ba9b-490e3641e6a5	[]	non-versioned
9c1527cd-50cc-4767-a87a-0c1d98655776	2025-11-10 15:29:45.24219+00	2025-11-10 15:29:45.242206+00	{"type": "object", "title": "DbtCliProfile", "required": ["name", "target", "target_configs"], "properties": {"name": {"type": "string", "title": "Name", "description": "Profile name used for populating profiles.yml."}, "target": {"type": "string", "title": "Target", "description": "The default target your dbt project will use."}, "global_configs": {"allOf": [{"$ref": "#/definitions/GlobalConfigs"}], "title": "Global Configs", "description": "Global configs control things like the visual output of logs, the manner in which dbt parses your project, and what to do when dbt finds a version mismatch or a failing model."}, "target_configs": {"anyOf": [{"$ref": "#/definitions/SnowflakeTargetConfigs"}, {"$ref": "#/definitions/BigQueryTargetConfigs"}, {"$ref": "#/definitions/PostgresTargetConfigs"}, {"$ref": "#/definitions/TargetConfigs"}], "title": "Target Configs", "description": "Target configs contain credentials and settings, specific to the warehouse you're connecting to."}}, "definitions": {"SyncDriver": {"enum": ["postgresql+psycopg2", "postgresql+pg8000", "postgresql+psycopg2cffi", "postgresql+pypostgresql", "postgresql+pygresql", "mysql+mysqldb", "mysql+pymysql", "mysql+mysqlconnector", "mysql+cymysql", "mysql+oursql", "mysql+pyodbc", "sqlite+pysqlite", "sqlite+pysqlcipher", "oracle+cx_oracle", "mssql+pyodbc", "mssql+mxodbc", "mssql+pymssql"], "title": "SyncDriver", "description": "Known dialects with their corresponding sync drivers.\\n\\nAttributes:\\n    POSTGRESQL_PSYCOPG2 (Enum): [postgresql+psycopg2](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2)\\n    POSTGRESQL_PG8000 (Enum): [postgresql+pg8000](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pg8000)\\n    POSTGRESQL_PSYCOPG2CFFI (Enum): [postgresql+psycopg2cffi](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2cffi)\\n    POSTGRESQL_PYPOSTGRESQL (Enum): [postgresql+pypostgresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pypostgresql)\\n    POSTGRESQL_PYGRESQL (Enum): [postgresql+pygresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pygresql)\\n\\n    MYSQL_MYSQLDB (Enum): [mysql+mysqldb](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqldb)\\n    MYSQL_PYMYSQL (Enum): [mysql+pymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pymysql)\\n    MYSQL_MYSQLCONNECTOR (Enum): [mysql+mysqlconnector](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqlconnector)\\n    MYSQL_CYMYSQL (Enum): [mysql+cymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.cymysql)\\n    MYSQL_OURSQL (Enum): [mysql+oursql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.oursql)\\n    MYSQL_PYODBC (Enum): [mysql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pyodbc)\\n\\n    SQLITE_PYSQLITE (Enum): [sqlite+pysqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlite)\\n    SQLITE_PYSQLCIPHER (Enum): [sqlite+pysqlcipher](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlcipher)\\n\\n    ORACLE_CX_ORACLE (Enum): [oracle+cx_oracle](https://docs.sqlalchemy.org/en/14/dialects/oracle.html#module-sqlalchemy.dialects.oracle.cx_oracle)\\n\\n    MSSQL_PYODBC (Enum): [mssql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pyodbc)\\n    MSSQL_MXODBC (Enum): [mssql+mxodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.mxodbc)\\n    MSSQL_PYMSSQL (Enum): [mssql+pymssql](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pymssql)"}, "AsyncDriver": {"enum": ["postgresql+asyncpg", "sqlite+aiosqlite", "mysql+asyncmy", "mysql+aiomysql"], "title": "AsyncDriver", "description": "Known dialects with their corresponding async drivers.\\n\\nAttributes:\\n    POSTGRESQL_ASYNCPG (Enum): [postgresql+asyncpg](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.asyncpg)\\n\\n    SQLITE_AIOSQLITE (Enum): [sqlite+aiosqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.aiosqlite)\\n\\n    MYSQL_ASYNCMY (Enum): [mysql+asyncmy](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.asyncmy)\\n    MYSQL_AIOMYSQL (Enum): [mysql+aiomysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.aiomysql)"}, "ConnectionComponents": {"type": "object", "title": "ConnectionComponents", "required": ["driver", "database"], "properties": {"host": {"type": "string", "title": "Host", "description": "The host address of the database."}, "port": {"type": "string", "title": "Port", "description": "The port to connect to the database."}, "query": {"type": "object", "title": "Query", "description": "A dictionary of string keys to string values to be passed to the dialect and/or the DBAPI upon connect. To specify non-string parameters to a Python DBAPI directly, use connect_args.", "additionalProperties": {"type": "string"}}, "driver": {"anyOf": [{"$ref": "#/definitions/AsyncDriver"}, {"$ref": "#/definitions/SyncDriver"}, {"type": "string"}], "title": "Driver", "description": "The driver name to use."}, "database": {"type": "string", "title": "Database", "description": "The name of the database to use."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password used to authenticate."}, "username": {"type": "string", "title": "Username", "description": "The user name used to authenticate."}}, "description": "Parameters to use to create a SQLAlchemy engine URL.\\n\\nAttributes:\\n    driver: The driver name to use.\\n    database: The name of the database to use.\\n    username: The user name used to authenticate.\\n    password: The password used to authenticate.\\n    host: The host address of the database.\\n    port: The port to connect to the database.\\n    query: A dictionary of string keys to string values to be passed to the dialect\\n        and/or the DBAPI upon connect."}}, "description": "Profile for use across dbt CLI tasks and flows.", "secret_fields": ["target_configs.connector.credentials.password", "target_configs.connector.credentials.private_key", "target_configs.connector.credentials.private_key_passphrase", "target_configs.connector.credentials.token", "target_configs.credentials.service_account_info.*", "target_configs.credentials.connection_info.password", "target_configs.credentials.password"], "block_type_slug": "dbt-cli-profile"}	sha256:f55b0f96cb9e1cf2f508bb882b25d9246b351be8b0ad18140a73281674a40d6d	c7abb882-393a-43cc-b867-359a72a2fa5a	[]	0.4.1
cafbbe36-852a-4f37-8fed-ffb42c211fda	2025-11-10 15:29:45.255212+00	2025-11-10 15:29:45.255228+00	{"type": "object", "title": "SnowflakeTargetConfigs", "required": ["connector"], "properties": {"type": {"enum": ["snowflake"], "type": "string", "title": "Type", "default": "snowflake", "description": "The type of the target configs."}, "extras": {"type": "object", "title": "Extras", "description": "Extra target configs' keywords, not yet exposed in prefect-dbt, but available in dbt."}, "schema": {"type": "string", "title": "Schema", "description": "The schema to use for the target configs."}, "threads": {"type": "integer", "title": "Threads", "default": 4, "description": "The number of threads representing the max number of paths through the graph dbt may work on at once."}, "connector": {"allOf": [{"$ref": "#/definitions/SnowflakeConnector"}], "title": "Connector", "description": "The connector to use."}, "allow_field_overrides": {"type": "boolean", "title": "Allow Field Overrides", "default": false, "description": "If enabled, fields from dbt target configs will override fields provided in extras and credentials."}}, "definitions": {"SyncDriver": {"enum": ["postgresql+psycopg2", "postgresql+pg8000", "postgresql+psycopg2cffi", "postgresql+pypostgresql", "postgresql+pygresql", "mysql+mysqldb", "mysql+pymysql", "mysql+mysqlconnector", "mysql+cymysql", "mysql+oursql", "mysql+pyodbc", "sqlite+pysqlite", "sqlite+pysqlcipher", "oracle+cx_oracle", "mssql+pyodbc", "mssql+mxodbc", "mssql+pymssql"], "title": "SyncDriver", "description": "Known dialects with their corresponding sync drivers.\\n\\nAttributes:\\n    POSTGRESQL_PSYCOPG2 (Enum): [postgresql+psycopg2](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2)\\n    POSTGRESQL_PG8000 (Enum): [postgresql+pg8000](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pg8000)\\n    POSTGRESQL_PSYCOPG2CFFI (Enum): [postgresql+psycopg2cffi](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2cffi)\\n    POSTGRESQL_PYPOSTGRESQL (Enum): [postgresql+pypostgresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pypostgresql)\\n    POSTGRESQL_PYGRESQL (Enum): [postgresql+pygresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pygresql)\\n\\n    MYSQL_MYSQLDB (Enum): [mysql+mysqldb](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqldb)\\n    MYSQL_PYMYSQL (Enum): [mysql+pymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pymysql)\\n    MYSQL_MYSQLCONNECTOR (Enum): [mysql+mysqlconnector](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqlconnector)\\n    MYSQL_CYMYSQL (Enum): [mysql+cymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.cymysql)\\n    MYSQL_OURSQL (Enum): [mysql+oursql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.oursql)\\n    MYSQL_PYODBC (Enum): [mysql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pyodbc)\\n\\n    SQLITE_PYSQLITE (Enum): [sqlite+pysqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlite)\\n    SQLITE_PYSQLCIPHER (Enum): [sqlite+pysqlcipher](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlcipher)\\n\\n    ORACLE_CX_ORACLE (Enum): [oracle+cx_oracle](https://docs.sqlalchemy.org/en/14/dialects/oracle.html#module-sqlalchemy.dialects.oracle.cx_oracle)\\n\\n    MSSQL_PYODBC (Enum): [mssql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pyodbc)\\n    MSSQL_MXODBC (Enum): [mssql+mxodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.mxodbc)\\n    MSSQL_PYMSSQL (Enum): [mssql+pymssql](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pymssql)"}, "AsyncDriver": {"enum": ["postgresql+asyncpg", "sqlite+aiosqlite", "mysql+asyncmy", "mysql+aiomysql"], "title": "AsyncDriver", "description": "Known dialects with their corresponding async drivers.\\n\\nAttributes:\\n    POSTGRESQL_ASYNCPG (Enum): [postgresql+asyncpg](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.asyncpg)\\n\\n    SQLITE_AIOSQLITE (Enum): [sqlite+aiosqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.aiosqlite)\\n\\n    MYSQL_ASYNCMY (Enum): [mysql+asyncmy](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.asyncmy)\\n    MYSQL_AIOMYSQL (Enum): [mysql+aiomysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.aiomysql)"}, "ConnectionComponents": {"type": "object", "title": "ConnectionComponents", "required": ["driver", "database"], "properties": {"host": {"type": "string", "title": "Host", "description": "The host address of the database."}, "port": {"type": "string", "title": "Port", "description": "The port to connect to the database."}, "query": {"type": "object", "title": "Query", "description": "A dictionary of string keys to string values to be passed to the dialect and/or the DBAPI upon connect. To specify non-string parameters to a Python DBAPI directly, use connect_args.", "additionalProperties": {"type": "string"}}, "driver": {"anyOf": [{"$ref": "#/definitions/AsyncDriver"}, {"$ref": "#/definitions/SyncDriver"}, {"type": "string"}], "title": "Driver", "description": "The driver name to use."}, "database": {"type": "string", "title": "Database", "description": "The name of the database to use."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password used to authenticate."}, "username": {"type": "string", "title": "Username", "description": "The user name used to authenticate."}}, "description": "Parameters to use to create a SQLAlchemy engine URL.\\n\\nAttributes:\\n    driver: The driver name to use.\\n    database: The name of the database to use.\\n    username: The user name used to authenticate.\\n    password: The password used to authenticate.\\n    host: The host address of the database.\\n    port: The port to connect to the database.\\n    query: A dictionary of string keys to string values to be passed to the dialect\\n        and/or the DBAPI upon connect."}}, "description": "Target configs contain credentials and\\nsettings, specific to Snowflake.\\nTo find valid keys, head to the [Snowflake Profile](\\nhttps://docs.getdbt.com/reference/warehouse-profiles/snowflake-profile)\\npage.", "secret_fields": ["connector.credentials.password", "connector.credentials.private_key", "connector.credentials.private_key_passphrase", "connector.credentials.token"], "block_type_slug": "dbt-cli-snowflake-target-configs"}	sha256:a70fca75226dc280c38ab0dda3679d3b0ffdee21af4463f3fb1ad6278405e370	20385df2-5a9a-49d0-a44a-e63d3fdd9d30	[]	non-versioned
1c7bc499-8474-43e4-8aa5-e94cc63dfd8f	2025-11-10 15:29:45.268343+00	2025-11-10 15:29:45.268357+00	{"type": "object", "title": "SnowflakeConnector", "required": ["credentials", "database", "warehouse", "schema"], "properties": {"schema": {"type": "string", "title": "Schema", "description": "The name of the default schema to use."}, "database": {"type": "string", "title": "Database", "description": "The name of the default database to use."}, "warehouse": {"type": "string", "title": "Warehouse", "description": "The name of the default warehouse to use."}, "fetch_size": {"type": "integer", "title": "Fetch Size", "default": 1, "description": "The default number of rows to fetch at a time."}, "credentials": {"allOf": [{"$ref": "#/definitions/SnowflakeCredentials"}], "title": "Credentials", "description": "The credentials to authenticate with Snowflake."}, "poll_frequency_s": {"type": "integer", "title": "Poll Frequency [seconds]", "default": 1, "description": "The number of seconds between checking query status for long running queries."}}, "definitions": {"SyncDriver": {"enum": ["postgresql+psycopg2", "postgresql+pg8000", "postgresql+psycopg2cffi", "postgresql+pypostgresql", "postgresql+pygresql", "mysql+mysqldb", "mysql+pymysql", "mysql+mysqlconnector", "mysql+cymysql", "mysql+oursql", "mysql+pyodbc", "sqlite+pysqlite", "sqlite+pysqlcipher", "oracle+cx_oracle", "mssql+pyodbc", "mssql+mxodbc", "mssql+pymssql"], "title": "SyncDriver", "description": "Known dialects with their corresponding sync drivers.\\n\\nAttributes:\\n    POSTGRESQL_PSYCOPG2 (Enum): [postgresql+psycopg2](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2)\\n    POSTGRESQL_PG8000 (Enum): [postgresql+pg8000](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pg8000)\\n    POSTGRESQL_PSYCOPG2CFFI (Enum): [postgresql+psycopg2cffi](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2cffi)\\n    POSTGRESQL_PYPOSTGRESQL (Enum): [postgresql+pypostgresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pypostgresql)\\n    POSTGRESQL_PYGRESQL (Enum): [postgresql+pygresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pygresql)\\n\\n    MYSQL_MYSQLDB (Enum): [mysql+mysqldb](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqldb)\\n    MYSQL_PYMYSQL (Enum): [mysql+pymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pymysql)\\n    MYSQL_MYSQLCONNECTOR (Enum): [mysql+mysqlconnector](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqlconnector)\\n    MYSQL_CYMYSQL (Enum): [mysql+cymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.cymysql)\\n    MYSQL_OURSQL (Enum): [mysql+oursql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.oursql)\\n    MYSQL_PYODBC (Enum): [mysql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pyodbc)\\n\\n    SQLITE_PYSQLITE (Enum): [sqlite+pysqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlite)\\n    SQLITE_PYSQLCIPHER (Enum): [sqlite+pysqlcipher](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlcipher)\\n\\n    ORACLE_CX_ORACLE (Enum): [oracle+cx_oracle](https://docs.sqlalchemy.org/en/14/dialects/oracle.html#module-sqlalchemy.dialects.oracle.cx_oracle)\\n\\n    MSSQL_PYODBC (Enum): [mssql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pyodbc)\\n    MSSQL_MXODBC (Enum): [mssql+mxodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.mxodbc)\\n    MSSQL_PYMSSQL (Enum): [mssql+pymssql](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pymssql)"}, "AsyncDriver": {"enum": ["postgresql+asyncpg", "sqlite+aiosqlite", "mysql+asyncmy", "mysql+aiomysql"], "title": "AsyncDriver", "description": "Known dialects with their corresponding async drivers.\\n\\nAttributes:\\n    POSTGRESQL_ASYNCPG (Enum): [postgresql+asyncpg](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.asyncpg)\\n\\n    SQLITE_AIOSQLITE (Enum): [sqlite+aiosqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.aiosqlite)\\n\\n    MYSQL_ASYNCMY (Enum): [mysql+asyncmy](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.asyncmy)\\n    MYSQL_AIOMYSQL (Enum): [mysql+aiomysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.aiomysql)"}, "ConnectionComponents": {"type": "object", "title": "ConnectionComponents", "required": ["driver", "database"], "properties": {"host": {"type": "string", "title": "Host", "description": "The host address of the database."}, "port": {"type": "string", "title": "Port", "description": "The port to connect to the database."}, "query": {"type": "object", "title": "Query", "description": "A dictionary of string keys to string values to be passed to the dialect and/or the DBAPI upon connect. To specify non-string parameters to a Python DBAPI directly, use connect_args.", "additionalProperties": {"type": "string"}}, "driver": {"anyOf": [{"$ref": "#/definitions/AsyncDriver"}, {"$ref": "#/definitions/SyncDriver"}, {"type": "string"}], "title": "Driver", "description": "The driver name to use."}, "database": {"type": "string", "title": "Database", "description": "The name of the database to use."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password used to authenticate."}, "username": {"type": "string", "title": "Username", "description": "The user name used to authenticate."}}, "description": "Parameters to use to create a SQLAlchemy engine URL.\\n\\nAttributes:\\n    driver: The driver name to use.\\n    database: The name of the database to use.\\n    username: The user name used to authenticate.\\n    password: The password used to authenticate.\\n    host: The host address of the database.\\n    port: The port to connect to the database.\\n    query: A dictionary of string keys to string values to be passed to the dialect\\n        and/or the DBAPI upon connect."}}, "description": "Perform data operations against a Snowflake database.", "secret_fields": ["credentials.password", "credentials.private_key", "credentials.private_key_passphrase", "credentials.token"], "block_type_slug": "snowflake-connector"}	sha256:a8cba7cafe80dd13d0dc167f351c2dda8d17698b02c7a2f9e7e0fceb1da00994	23d7c017-9d6a-4544-aa2e-0290ba45a6d3	[]	non-versioned
f0bdd34a-b283-4435-8201-6e649a9d41ff	2025-11-10 15:29:45.28146+00	2025-11-10 15:29:45.281475+00	{"type": "object", "title": "SnowflakeCredentials", "required": ["account", "user"], "properties": {"role": {"type": "string", "title": "Role", "description": "The name of the default role to use."}, "user": {"type": "string", "title": "User", "description": "The user name used to authenticate."}, "token": {"type": "string", "title": "Token", "format": "password", "writeOnly": true, "description": "The OAuth or JWT Token to provide when authenticator is set to `oauth`."}, "account": {"type": "string", "title": "Account", "example": "nh12345.us-east-2.aws", "description": "The snowflake account name."}, "endpoint": {"type": "string", "title": "Endpoint", "description": "The Okta endpoint to use when authenticator is set to `okta_endpoint`."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password used to authenticate."}, "autocommit": {"type": "boolean", "title": "Autocommit", "description": "Whether to automatically commit."}, "private_key": {"type": "string", "title": "Private Key", "format": "password", "writeOnly": true, "description": "The PEM used to authenticate."}, "authenticator": {"enum": ["snowflake", "snowflake_jwt", "externalbrowser", "okta_endpoint", "oauth", "username_password_mfa"], "type": "string", "title": "Authenticator", "default": "snowflake", "description": "The type of authenticator to use for initializing connection."}, "private_key_path": {"type": "string", "title": "Private Key Path", "format": "path", "description": "The path to the private key."}, "private_key_passphrase": {"type": "string", "title": "Private Key Passphrase", "format": "password", "writeOnly": true, "description": "The password to use for the private key."}}, "definitions": {"SyncDriver": {"enum": ["postgresql+psycopg2", "postgresql+pg8000", "postgresql+psycopg2cffi", "postgresql+pypostgresql", "postgresql+pygresql", "mysql+mysqldb", "mysql+pymysql", "mysql+mysqlconnector", "mysql+cymysql", "mysql+oursql", "mysql+pyodbc", "sqlite+pysqlite", "sqlite+pysqlcipher", "oracle+cx_oracle", "mssql+pyodbc", "mssql+mxodbc", "mssql+pymssql"], "title": "SyncDriver", "description": "Known dialects with their corresponding sync drivers.\\n\\nAttributes:\\n    POSTGRESQL_PSYCOPG2 (Enum): [postgresql+psycopg2](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2)\\n    POSTGRESQL_PG8000 (Enum): [postgresql+pg8000](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pg8000)\\n    POSTGRESQL_PSYCOPG2CFFI (Enum): [postgresql+psycopg2cffi](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2cffi)\\n    POSTGRESQL_PYPOSTGRESQL (Enum): [postgresql+pypostgresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pypostgresql)\\n    POSTGRESQL_PYGRESQL (Enum): [postgresql+pygresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pygresql)\\n\\n    MYSQL_MYSQLDB (Enum): [mysql+mysqldb](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqldb)\\n    MYSQL_PYMYSQL (Enum): [mysql+pymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pymysql)\\n    MYSQL_MYSQLCONNECTOR (Enum): [mysql+mysqlconnector](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqlconnector)\\n    MYSQL_CYMYSQL (Enum): [mysql+cymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.cymysql)\\n    MYSQL_OURSQL (Enum): [mysql+oursql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.oursql)\\n    MYSQL_PYODBC (Enum): [mysql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pyodbc)\\n\\n    SQLITE_PYSQLITE (Enum): [sqlite+pysqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlite)\\n    SQLITE_PYSQLCIPHER (Enum): [sqlite+pysqlcipher](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlcipher)\\n\\n    ORACLE_CX_ORACLE (Enum): [oracle+cx_oracle](https://docs.sqlalchemy.org/en/14/dialects/oracle.html#module-sqlalchemy.dialects.oracle.cx_oracle)\\n\\n    MSSQL_PYODBC (Enum): [mssql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pyodbc)\\n    MSSQL_MXODBC (Enum): [mssql+mxodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.mxodbc)\\n    MSSQL_PYMSSQL (Enum): [mssql+pymssql](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pymssql)"}, "AsyncDriver": {"enum": ["postgresql+asyncpg", "sqlite+aiosqlite", "mysql+asyncmy", "mysql+aiomysql"], "title": "AsyncDriver", "description": "Known dialects with their corresponding async drivers.\\n\\nAttributes:\\n    POSTGRESQL_ASYNCPG (Enum): [postgresql+asyncpg](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.asyncpg)\\n\\n    SQLITE_AIOSQLITE (Enum): [sqlite+aiosqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.aiosqlite)\\n\\n    MYSQL_ASYNCMY (Enum): [mysql+asyncmy](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.asyncmy)\\n    MYSQL_AIOMYSQL (Enum): [mysql+aiomysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.aiomysql)"}, "ConnectionComponents": {"type": "object", "title": "ConnectionComponents", "required": ["driver", "database"], "properties": {"host": {"type": "string", "title": "Host", "description": "The host address of the database."}, "port": {"type": "string", "title": "Port", "description": "The port to connect to the database."}, "query": {"type": "object", "title": "Query", "description": "A dictionary of string keys to string values to be passed to the dialect and/or the DBAPI upon connect. To specify non-string parameters to a Python DBAPI directly, use connect_args.", "additionalProperties": {"type": "string"}}, "driver": {"anyOf": [{"$ref": "#/definitions/AsyncDriver"}, {"$ref": "#/definitions/SyncDriver"}, {"type": "string"}], "title": "Driver", "description": "The driver name to use."}, "database": {"type": "string", "title": "Database", "description": "The name of the database to use."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password used to authenticate."}, "username": {"type": "string", "title": "Username", "description": "The user name used to authenticate."}}, "description": "Parameters to use to create a SQLAlchemy engine URL.\\n\\nAttributes:\\n    driver: The driver name to use.\\n    database: The name of the database to use.\\n    username: The user name used to authenticate.\\n    password: The password used to authenticate.\\n    host: The host address of the database.\\n    port: The port to connect to the database.\\n    query: A dictionary of string keys to string values to be passed to the dialect\\n        and/or the DBAPI upon connect."}}, "description": "Block used to manage authentication with Snowflake.", "secret_fields": ["password", "private_key", "private_key_passphrase", "token"], "block_type_slug": "snowflake-credentials"}	sha256:35bea1e0ca2277b003ca6d1c220e59ce9a58330934c051fe26a549c2fa380b1f	adff8102-8bb1-4f2e-abd6-5e27e2660f56	[]	non-versioned
a246a55e-09e7-4283-b0b7-8a789653dad3	2025-11-10 15:29:45.324431+00	2025-11-10 15:29:45.324447+00	{"type": "object", "title": "TargetConfigs", "required": ["type", "schema"], "properties": {"type": {"type": "string", "title": "Type", "description": "The name of the database warehouse."}, "extras": {"type": "object", "title": "Extras", "description": "Extra target configs' keywords, not yet exposed in prefect-dbt, but available in dbt."}, "schema": {"type": "string", "title": "Schema", "description": "The schema that dbt will build objects into; in BigQuery, a schema is actually a dataset."}, "threads": {"type": "integer", "title": "Threads", "default": 4, "description": "The number of threads representing the max number of paths through the graph dbt may work on at once."}, "allow_field_overrides": {"type": "boolean", "title": "Allow Field Overrides", "default": false, "description": "If enabled, fields from dbt target configs will override fields provided in extras and credentials."}}, "definitions": {"SyncDriver": {"enum": ["postgresql+psycopg2", "postgresql+pg8000", "postgresql+psycopg2cffi", "postgresql+pypostgresql", "postgresql+pygresql", "mysql+mysqldb", "mysql+pymysql", "mysql+mysqlconnector", "mysql+cymysql", "mysql+oursql", "mysql+pyodbc", "sqlite+pysqlite", "sqlite+pysqlcipher", "oracle+cx_oracle", "mssql+pyodbc", "mssql+mxodbc", "mssql+pymssql"], "title": "SyncDriver", "description": "Known dialects with their corresponding sync drivers.\\n\\nAttributes:\\n    POSTGRESQL_PSYCOPG2 (Enum): [postgresql+psycopg2](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2)\\n    POSTGRESQL_PG8000 (Enum): [postgresql+pg8000](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pg8000)\\n    POSTGRESQL_PSYCOPG2CFFI (Enum): [postgresql+psycopg2cffi](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2cffi)\\n    POSTGRESQL_PYPOSTGRESQL (Enum): [postgresql+pypostgresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pypostgresql)\\n    POSTGRESQL_PYGRESQL (Enum): [postgresql+pygresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pygresql)\\n\\n    MYSQL_MYSQLDB (Enum): [mysql+mysqldb](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqldb)\\n    MYSQL_PYMYSQL (Enum): [mysql+pymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pymysql)\\n    MYSQL_MYSQLCONNECTOR (Enum): [mysql+mysqlconnector](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqlconnector)\\n    MYSQL_CYMYSQL (Enum): [mysql+cymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.cymysql)\\n    MYSQL_OURSQL (Enum): [mysql+oursql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.oursql)\\n    MYSQL_PYODBC (Enum): [mysql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pyodbc)\\n\\n    SQLITE_PYSQLITE (Enum): [sqlite+pysqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlite)\\n    SQLITE_PYSQLCIPHER (Enum): [sqlite+pysqlcipher](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlcipher)\\n\\n    ORACLE_CX_ORACLE (Enum): [oracle+cx_oracle](https://docs.sqlalchemy.org/en/14/dialects/oracle.html#module-sqlalchemy.dialects.oracle.cx_oracle)\\n\\n    MSSQL_PYODBC (Enum): [mssql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pyodbc)\\n    MSSQL_MXODBC (Enum): [mssql+mxodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.mxodbc)\\n    MSSQL_PYMSSQL (Enum): [mssql+pymssql](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pymssql)"}, "AsyncDriver": {"enum": ["postgresql+asyncpg", "sqlite+aiosqlite", "mysql+asyncmy", "mysql+aiomysql"], "title": "AsyncDriver", "description": "Known dialects with their corresponding async drivers.\\n\\nAttributes:\\n    POSTGRESQL_ASYNCPG (Enum): [postgresql+asyncpg](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.asyncpg)\\n\\n    SQLITE_AIOSQLITE (Enum): [sqlite+aiosqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.aiosqlite)\\n\\n    MYSQL_ASYNCMY (Enum): [mysql+asyncmy](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.asyncmy)\\n    MYSQL_AIOMYSQL (Enum): [mysql+aiomysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.aiomysql)"}, "ConnectionComponents": {"type": "object", "title": "ConnectionComponents", "required": ["driver", "database"], "properties": {"host": {"type": "string", "title": "Host", "description": "The host address of the database."}, "port": {"type": "string", "title": "Port", "description": "The port to connect to the database."}, "query": {"type": "object", "title": "Query", "description": "A dictionary of string keys to string values to be passed to the dialect and/or the DBAPI upon connect. To specify non-string parameters to a Python DBAPI directly, use connect_args.", "additionalProperties": {"type": "string"}}, "driver": {"anyOf": [{"$ref": "#/definitions/AsyncDriver"}, {"$ref": "#/definitions/SyncDriver"}, {"type": "string"}], "title": "Driver", "description": "The driver name to use."}, "database": {"type": "string", "title": "Database", "description": "The name of the database to use."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password used to authenticate."}, "username": {"type": "string", "title": "Username", "description": "The user name used to authenticate."}}, "description": "Parameters to use to create a SQLAlchemy engine URL.\\n\\nAttributes:\\n    driver: The driver name to use.\\n    database: The name of the database to use.\\n    username: The user name used to authenticate.\\n    password: The password used to authenticate.\\n    host: The host address of the database.\\n    port: The port to connect to the database.\\n    query: A dictionary of string keys to string values to be passed to the dialect\\n        and/or the DBAPI upon connect."}}, "description": "Target configs contain credentials and\\nsettings, specific to the warehouse you're connecting to.\\nTo find valid keys, head to the [Available adapters](\\nhttps://docs.getdbt.com/docs/available-adapters) page and\\nclick the desired adapter's \\"Profile Setup\\" hyperlink.", "secret_fields": [], "block_type_slug": "dbt-cli-target-configs"}	sha256:d0c8411280a2529a973b70fb86142959008aad2fe3844c63ab03190e232f776a	192b1b04-abd2-4ffb-8e7f-80345ab74be3	[]	non-versioned
0fc3f9ae-7e57-4409-aa64-a434d6b15cfd	2025-11-10 15:29:45.348278+00	2025-11-10 15:29:45.348313+00	{"type": "object", "title": "SnowflakeTargetConfigs", "required": ["connector"], "properties": {"type": {"enum": ["snowflake"], "type": "string", "title": "Type", "default": "snowflake", "description": "The type of the target configs."}, "extras": {"type": "object", "title": "Extras", "description": "Extra target configs' keywords, not yet exposed in prefect-dbt, but available in dbt."}, "schema": {"type": "string", "title": "Schema", "description": "The schema to use for the target configs."}, "threads": {"type": "integer", "title": "Threads", "default": 4, "description": "The number of threads representing the max number of paths through the graph dbt may work on at once."}, "connector": {"allOf": [{"$ref": "#/definitions/SnowflakeConnector"}], "title": "Connector", "description": "The connector to use."}, "allow_field_overrides": {"type": "boolean", "title": "Allow Field Overrides", "default": false, "description": "If enabled, fields from dbt target configs will override fields provided in extras and credentials."}}, "description": "Target configs contain credentials and\\nsettings, specific to Snowflake.\\nTo find valid keys, head to the [Snowflake Profile](\\nhttps://docs.getdbt.com/reference/warehouse-profiles/snowflake-profile)\\npage.", "secret_fields": ["connector.credentials.password", "connector.credentials.private_key", "connector.credentials.private_key_passphrase", "connector.credentials.token"], "block_type_slug": "dbt-cli-snowflake-target-configs"}	sha256:1e5be296bb63d7e2b04f0e9b99543db12521af269399d10e2bc290da4244a575	20385df2-5a9a-49d0-a44a-e63d3fdd9d30	[]	0.4.1
87857a20-0eff-4f19-b9e8-085a238b699a	2025-11-10 15:29:45.359976+00	2025-11-10 15:29:45.359991+00	{"type": "object", "title": "SnowflakeConnector", "required": ["credentials", "database", "warehouse", "schema"], "properties": {"schema": {"type": "string", "title": "Schema", "description": "The name of the default schema to use."}, "database": {"type": "string", "title": "Database", "description": "The name of the default database to use."}, "warehouse": {"type": "string", "title": "Warehouse", "description": "The name of the default warehouse to use."}, "fetch_size": {"type": "integer", "title": "Fetch Size", "default": 1, "description": "The default number of rows to fetch at a time."}, "credentials": {"allOf": [{"$ref": "#/definitions/SnowflakeCredentials"}], "title": "Credentials", "description": "The credentials to authenticate with Snowflake."}, "poll_frequency_s": {"type": "integer", "title": "Poll Frequency [seconds]", "default": 1, "description": "The number of seconds between checking query status for long running queries."}}, "description": "Perform data operations against a Snowflake database.", "secret_fields": ["credentials.password", "credentials.private_key", "credentials.private_key_passphrase", "credentials.token"], "block_type_slug": "snowflake-connector"}	sha256:dd0d36d69bbe0d44870fd754f3c00754e37e3f52209590083eaee4c585ce0bd0	23d7c017-9d6a-4544-aa2e-0290ba45a6d3	[]	non-versioned
78e327a0-aa1e-44da-acba-67cc09177dca	2025-11-10 15:29:45.372665+00	2025-11-10 15:29:45.37268+00	{"type": "object", "title": "SnowflakeCredentials", "required": ["account", "user"], "properties": {"role": {"type": "string", "title": "Role", "description": "The name of the default role to use."}, "user": {"type": "string", "title": "User", "description": "The user name used to authenticate."}, "token": {"type": "string", "title": "Token", "format": "password", "writeOnly": true, "description": "The OAuth or JWT Token to provide when authenticator is set to `oauth`."}, "account": {"type": "string", "title": "Account", "example": "nh12345.us-east-2.aws", "description": "The snowflake account name."}, "endpoint": {"type": "string", "title": "Endpoint", "description": "The Okta endpoint to use when authenticator is set to `okta_endpoint`."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password used to authenticate."}, "autocommit": {"type": "boolean", "title": "Autocommit", "description": "Whether to automatically commit."}, "private_key": {"type": "string", "title": "Private Key", "format": "password", "writeOnly": true, "description": "The PEM used to authenticate."}, "authenticator": {"enum": ["snowflake", "snowflake_jwt", "externalbrowser", "okta_endpoint", "oauth", "username_password_mfa"], "type": "string", "title": "Authenticator", "default": "snowflake", "description": "The type of authenticator to use for initializing connection."}, "private_key_path": {"type": "string", "title": "Private Key Path", "format": "path", "description": "The path to the private key."}, "private_key_passphrase": {"type": "string", "title": "Private Key Passphrase", "format": "password", "writeOnly": true, "description": "The password to use for the private key."}}, "description": "Block used to manage authentication with Snowflake.", "secret_fields": ["password", "private_key", "private_key_passphrase", "token"], "block_type_slug": "snowflake-credentials"}	sha256:b24edfb413527c951cb2a8b4b4c16aec096523f871d941889e29ac2e6e92e036	adff8102-8bb1-4f2e-abd6-5e27e2660f56	[]	non-versioned
3fb57de4-9c85-4663-8e1a-321491fc0c95	2025-11-10 15:29:45.388878+00	2025-11-10 15:29:45.388895+00	{"type": "object", "title": "TargetConfigs", "required": ["type", "schema"], "properties": {"type": {"type": "string", "title": "Type", "description": "The name of the database warehouse."}, "extras": {"type": "object", "title": "Extras", "description": "Extra target configs' keywords, not yet exposed in prefect-dbt, but available in dbt."}, "schema": {"type": "string", "title": "Schema", "description": "The schema that dbt will build objects into; in BigQuery, a schema is actually a dataset."}, "threads": {"type": "integer", "title": "Threads", "default": 4, "description": "The number of threads representing the max number of paths through the graph dbt may work on at once."}, "allow_field_overrides": {"type": "boolean", "title": "Allow Field Overrides", "default": false, "description": "If enabled, fields from dbt target configs will override fields provided in extras and credentials."}}, "description": "Target configs contain credentials and\\nsettings, specific to the warehouse you're connecting to.\\nTo find valid keys, head to the [Available adapters](\\nhttps://docs.getdbt.com/docs/available-adapters) page and\\nclick the desired adapter's \\"Profile Setup\\" hyperlink.", "secret_fields": [], "block_type_slug": "dbt-cli-target-configs"}	sha256:85f7476977e725617af89930889b843147320b2df37df911e24806dd6dacc870	192b1b04-abd2-4ffb-8e7f-80345ab74be3	[]	0.4.1
63341955-99c4-498d-acd0-a0406eb84a30	2025-11-10 15:29:45.399516+00	2025-11-10 15:29:45.399532+00	{"type": "object", "title": "DbtCloudCredentials", "required": ["api_key", "account_id"], "properties": {"domain": {"type": "string", "title": "Domain", "default": "cloud.getdbt.com", "description": "The base domain of your dbt Cloud instance."}, "api_key": {"type": "string", "title": "API Key", "format": "password", "writeOnly": true, "description": "A dbt Cloud API key to use for authentication."}, "account_id": {"type": "integer", "title": "Account ID", "description": "The ID of your dbt Cloud account."}}, "description": "Credentials block for credential use across dbt Cloud tasks and flows.", "secret_fields": ["api_key"], "block_type_slug": "dbt-cloud-credentials"}	sha256:0e1b2e94e09041e7d732822354503e87b99ddb31422d9d2c83c671be249aa231	3cd1fddb-bcdc-4238-a302-889f80715ad9	[]	0.4.1
f03eddbb-cf03-473f-99e9-d04d7f1a0345	2025-11-10 15:29:45.41216+00	2025-11-10 15:29:45.412177+00	{"type": "object", "title": "DbtCoreOperation", "required": ["commands"], "properties": {"env": {"type": "object", "title": "Environment Variables", "description": "Environment variables to use for the subprocess.", "additionalProperties": {"type": "string"}}, "shell": {"type": "string", "title": "Shell", "description": "The shell to run the command with; if unset, defaults to `powershell` on Windows and `bash` on other platforms."}, "commands": {"type": "array", "items": {"type": "string"}, "title": "Commands", "description": "A list of commands to execute sequentially."}, "extension": {"type": "string", "title": "Extension", "description": "The extension to use for the temporary file; if unset, defaults to `.ps1` on Windows and `.sh` on other platforms."}, "project_dir": {"type": "string", "title": "Project Dir", "format": "path", "description": "The directory to search for the dbt_project.yml file. Default is the current working directory and its parents."}, "working_dir": {"type": "string", "title": "Working Directory", "format": "directory-path", "description": "The absolute path to the working directory the command will be executed within."}, "profiles_dir": {"type": "string", "title": "Profiles Dir", "format": "path", "description": "The directory to search for the profiles.yml file. Setting this appends the `--profiles-dir` option to the dbt commands provided. If this is not set, will try using the DBT_PROFILES_DIR environment variable, but if that's also not set, will use the default directory `$HOME/.dbt/`."}, "stream_output": {"type": "boolean", "title": "Stream Output", "default": true, "description": "Whether to stream output."}, "dbt_cli_profile": {"allOf": [{"$ref": "#/definitions/DbtCliProfile"}], "title": "Dbt Cli Profile", "description": "Profiles class containing the profile written to profiles.yml. Note! This is optional and will raise an error if profiles.yml already exists under profile_dir and overwrite_profiles is set to False."}, "overwrite_profiles": {"type": "boolean", "title": "Overwrite Profiles", "default": false, "description": "Whether the existing profiles.yml file under profiles_dir should be overwritten with a new profile."}}, "definitions": {"SyncDriver": {"enum": ["postgresql+psycopg2", "postgresql+pg8000", "postgresql+psycopg2cffi", "postgresql+pypostgresql", "postgresql+pygresql", "mysql+mysqldb", "mysql+pymysql", "mysql+mysqlconnector", "mysql+cymysql", "mysql+oursql", "mysql+pyodbc", "sqlite+pysqlite", "sqlite+pysqlcipher", "oracle+cx_oracle", "mssql+pyodbc", "mssql+mxodbc", "mssql+pymssql"], "title": "SyncDriver", "description": "Known dialects with their corresponding sync drivers.\\n\\nAttributes:\\n    POSTGRESQL_PSYCOPG2 (Enum): [postgresql+psycopg2](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2)\\n    POSTGRESQL_PG8000 (Enum): [postgresql+pg8000](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pg8000)\\n    POSTGRESQL_PSYCOPG2CFFI (Enum): [postgresql+psycopg2cffi](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2cffi)\\n    POSTGRESQL_PYPOSTGRESQL (Enum): [postgresql+pypostgresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pypostgresql)\\n    POSTGRESQL_PYGRESQL (Enum): [postgresql+pygresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pygresql)\\n\\n    MYSQL_MYSQLDB (Enum): [mysql+mysqldb](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqldb)\\n    MYSQL_PYMYSQL (Enum): [mysql+pymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pymysql)\\n    MYSQL_MYSQLCONNECTOR (Enum): [mysql+mysqlconnector](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqlconnector)\\n    MYSQL_CYMYSQL (Enum): [mysql+cymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.cymysql)\\n    MYSQL_OURSQL (Enum): [mysql+oursql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.oursql)\\n    MYSQL_PYODBC (Enum): [mysql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pyodbc)\\n\\n    SQLITE_PYSQLITE (Enum): [sqlite+pysqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlite)\\n    SQLITE_PYSQLCIPHER (Enum): [sqlite+pysqlcipher](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlcipher)\\n\\n    ORACLE_CX_ORACLE (Enum): [oracle+cx_oracle](https://docs.sqlalchemy.org/en/14/dialects/oracle.html#module-sqlalchemy.dialects.oracle.cx_oracle)\\n\\n    MSSQL_PYODBC (Enum): [mssql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pyodbc)\\n    MSSQL_MXODBC (Enum): [mssql+mxodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.mxodbc)\\n    MSSQL_PYMSSQL (Enum): [mssql+pymssql](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pymssql)"}, "AsyncDriver": {"enum": ["postgresql+asyncpg", "sqlite+aiosqlite", "mysql+asyncmy", "mysql+aiomysql"], "title": "AsyncDriver", "description": "Known dialects with their corresponding async drivers.\\n\\nAttributes:\\n    POSTGRESQL_ASYNCPG (Enum): [postgresql+asyncpg](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.asyncpg)\\n\\n    SQLITE_AIOSQLITE (Enum): [sqlite+aiosqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.aiosqlite)\\n\\n    MYSQL_ASYNCMY (Enum): [mysql+asyncmy](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.asyncmy)\\n    MYSQL_AIOMYSQL (Enum): [mysql+aiomysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.aiomysql)"}, "ConnectionComponents": {"type": "object", "title": "ConnectionComponents", "required": ["driver", "database"], "properties": {"host": {"type": "string", "title": "Host", "description": "The host address of the database."}, "port": {"type": "string", "title": "Port", "description": "The port to connect to the database."}, "query": {"type": "object", "title": "Query", "description": "A dictionary of string keys to string values to be passed to the dialect and/or the DBAPI upon connect. To specify non-string parameters to a Python DBAPI directly, use connect_args.", "additionalProperties": {"type": "string"}}, "driver": {"anyOf": [{"$ref": "#/definitions/AsyncDriver"}, {"$ref": "#/definitions/SyncDriver"}, {"type": "string"}], "title": "Driver", "description": "The driver name to use."}, "database": {"type": "string", "title": "Database", "description": "The name of the database to use."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password used to authenticate."}, "username": {"type": "string", "title": "Username", "description": "The user name used to authenticate."}}, "description": "Parameters to use to create a SQLAlchemy engine URL.\\n\\nAttributes:\\n    driver: The driver name to use.\\n    database: The name of the database to use.\\n    username: The user name used to authenticate.\\n    password: The password used to authenticate.\\n    host: The host address of the database.\\n    port: The port to connect to the database.\\n    query: A dictionary of string keys to string values to be passed to the dialect\\n        and/or the DBAPI upon connect."}}, "description": "A block representing a dbt operation, containing multiple dbt and shell commands.\\n\\nFor long-lasting operations, use the trigger method and utilize the block as a\\ncontext manager for automatic closure of processes when context is exited.\\nIf not, manually call the close method to close processes.\\n\\nFor short-lasting operations, use the run method. Context is automatically managed\\nwith this method.", "secret_fields": ["dbt_cli_profile.target_configs.connector.credentials.password", "dbt_cli_profile.target_configs.connector.credentials.private_key", "dbt_cli_profile.target_configs.connector.credentials.private_key_passphrase", "dbt_cli_profile.target_configs.connector.credentials.token", "dbt_cli_profile.target_configs.credentials.service_account_info.*", "dbt_cli_profile.target_configs.credentials.connection_info.password", "dbt_cli_profile.target_configs.credentials.password"], "block_type_slug": "dbt-core-operation"}	sha256:0f685bc693353f66d1fc83687c8af67511feba052b5343506033141c9a2441c7	2196312a-8f17-4798-beb1-4f4ed1b62f7d	[]	0.4.1
fff57dc2-c72f-4748-b069-45bc4383bb81	2025-11-10 15:29:45.435484+00	2025-11-10 15:29:45.435498+00	{"type": "object", "title": "DockerHost", "properties": {"timeout": {"type": "integer", "title": "Timeout", "description": "Default timeout for API calls, in seconds."}, "version": {"type": "string", "title": "Version", "default": "auto", "description": "The version of the API to use"}, "base_url": {"type": "string", "title": "Base URL", "example": "unix:///var/run/docker.sock", "description": "URL to the Docker host."}, "client_kwargs": {"type": "object", "title": "Additional Configuration", "description": "Additional keyword arguments to pass to `docker.from_env()` or `DockerClient`."}, "max_pool_size": {"type": "integer", "title": "Max Pool Size", "description": "The maximum number of connections to save in the pool."}}, "description": "Store settings for interacting with a Docker host.", "secret_fields": [], "block_type_slug": "docker-host"}	sha256:bf0961e9f2d88fd81bca2c7b78c025bd289776ad84ae8ef22d8f3db8b9561478	5202ce30-a9c3-45cd-9927-2104e2158315	[]	0.4.5
dad8b5fb-e790-4f0f-b5dd-33eb33e07f51	2025-11-10 15:29:45.445337+00	2025-11-10 15:29:45.445351+00	{"type": "object", "title": "DockerRegistryCredentials", "required": ["username", "password", "registry_url"], "properties": {"reauth": {"type": "boolean", "title": "Reauth", "default": true, "description": "Whether or not to reauthenticate on each interaction."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password to log into the registry with."}, "username": {"type": "string", "title": "Username", "description": "The username to log into the registry with."}, "registry_url": {"type": "string", "title": "Registry Url", "example": "index.docker.io", "description": "The URL to the registry. Generally, \\"http\\" or \\"https\\" can be omitted."}}, "description": "Store credentials for interacting with a Docker Registry.", "secret_fields": ["password"], "block_type_slug": "docker-registry-credentials"}	sha256:d5cbcfdf092e1f904ea26c274fcd0f23d86ecbbd0afae0f254f575ac3e40915d	947f8696-4017-4048-9bff-87389b842a3f	[]	0.4.5
98b3c2bb-c440-4189-a014-ed0af7706b6b	2025-11-10 15:29:45.455295+00	2025-11-10 15:29:45.455309+00	{"type": "object", "title": "EmailServerCredentials", "properties": {"password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password to use for authentication to the server. Unnecessary if SMTP login is not required."}, "username": {"type": "string", "title": "Username", "description": "The username to use for authentication to the server. Unnecessary if SMTP login is not required."}, "smtp_port": {"type": "integer", "title": "SMTP Port", "description": "If provided, overrides the smtp_type's default port number."}, "smtp_type": {"anyOf": [{"$ref": "#/definitions/SMTPType"}, {"type": "string"}], "title": "SMTP Type", "default": 465, "description": "Either 'SSL', 'STARTTLS', or 'INSECURE'."}, "smtp_server": {"anyOf": [{"$ref": "#/definitions/SMTPServer"}, {"type": "string"}], "title": "SMTP Server", "default": "smtp.gmail.com", "description": "Either the hostname of the SMTP server, or one of the keys from the built-in SMTPServer Enum members, like 'gmail'."}}, "definitions": {"SMTPType": {"enum": [465, 587, 25], "title": "SMTPType", "description": "Protocols used to secure email transmissions."}, "SMTPServer": {"enum": ["smtp.aol.com", "smtp.mail.att.net", "smtp.comcast.net", "smtp.mail.me.com", "smtp.gmail.com", "smtp-mail.outlook.com", "smtp.mail.yahoo.com"], "title": "SMTPServer", "description": "Server used to send email."}}, "description": "Block used to manage generic email server authentication.\\nIt is recommended you use a\\n[Google App Password](https://support.google.com/accounts/answer/185833)\\nif you use Gmail.", "secret_fields": ["password"], "block_type_slug": "email-server-credentials"}	sha256:56d6491f4b2d4aaae5ce604652416f44d0c8fa39ca68c5f747aee7cb518a41d0	8b177061-8118-4f38-9589-7bcd9fe56cbe	[]	0.3.2
c5145a70-1c69-471c-b00c-233ab83c90eb	2025-11-10 15:29:45.465313+00	2025-11-10 15:29:45.465327+00	{"type": "object", "title": "BigQueryWarehouse", "required": ["gcp_credentials"], "properties": {"fetch_size": {"type": "integer", "title": "Fetch Size", "default": 1, "description": "The number of rows to fetch at a time."}, "gcp_credentials": {"$ref": "#/definitions/GcpCredentials"}}, "description": "A block for querying a database with BigQuery.\\n\\nUpon instantiating, a connection to BigQuery is established\\nand maintained for the life of the object until the close method is called.\\n\\nIt is recommended to use this block as a context manager, which will automatically\\nclose the connection and its cursors when the context is exited.\\n\\nIt is also recommended that this block is loaded and consumed within a single task\\nor flow because if the block is passed across separate tasks and flows,\\nthe state of the block's connection and cursor could be lost.", "secret_fields": ["gcp_credentials.service_account_info.*"], "block_type_slug": "bigquery-warehouse"}	sha256:e8495199f3b490e3b15ba1bc67a97cf04b23aa8a7cba67161291d7cbc882d025	8489af94-7ba8-4e6a-bbb3-638218e4d952	[]	0.5.8
cbad1d51-e7e5-42f9-a737-3c1a1fffd152	2025-11-10 15:29:45.484033+00	2025-11-10 15:29:45.484047+00	{"type": "object", "title": "CloudRunJob", "required": ["image", "region", "credentials"], "properties": {"cpu": {"type": "integer", "title": "CPU", "description": "The amount of compute allocated to the Cloud Run Job. The int must be valid based on the rules specified at https://cloud.google.com/run/docs/configuring/cpu#setting-jobs ."}, "env": {"type": "object", "title": "Env", "description": "Environment variables to be passed to your Cloud Run Job.", "additionalProperties": {"type": "string"}}, "args": {"type": "array", "items": {"type": "string"}, "title": "Args", "description": "Arguments to be passed to your Cloud Run Job's entrypoint command."}, "name": {"type": "string", "title": "Name", "description": "Name applied to the infrastructure for identification."}, "type": {"enum": ["cloud-run-job"], "type": "string", "title": "Type", "default": "cloud-run-job", "description": "The slug for this task type."}, "image": {"type": "string", "title": "Image Name", "description": "The image to use for a new Cloud Run Job. This value must refer to an image within either Google Container Registry or Google Artifact Registry, like `gcr.io/<project_name>/<repo>/`."}, "labels": {"type": "object", "title": "Labels", "description": "Labels applied to the infrastructure for metadata purposes.", "additionalProperties": {"type": "string"}}, "memory": {"type": "integer", "title": "Memory", "description": "The amount of memory allocated to the Cloud Run Job."}, "region": {"type": "string", "title": "Region", "description": "The region where the Cloud Run Job resides."}, "command": {"type": "array", "items": {"type": "string"}, "title": "Command", "description": "The command to run in the infrastructure."}, "timeout": {"type": "integer", "title": "Job Timeout", "default": 600, "maximum": 3600, "description": "The length of time that Prefect will wait for a Cloud Run Job to complete before raising an exception.", "exclusiveMinimum": 0}, "keep_job": {"type": "boolean", "title": "Keep Job After Completion", "default": false, "description": "Keep the completed Cloud Run Job on Google Cloud Platform."}, "credentials": {"$ref": "#/definitions/GcpCredentials"}, "max_retries": {"type": "integer", "title": "Max Retries", "default": 3, "maximum": 10, "minimum": 0, "description": "The maximum retries setting specifies the number of times a task is allowed to restart in case of failure before being failed permanently."}, "memory_unit": {"enum": ["G", "Gi", "M", "Mi"], "type": "string", "title": "Memory Units", "description": "The unit of memory. See https://cloud.google.com/run/docs/configuring/memory-limits#setting for additional details."}, "vpc_connector_name": {"type": "string", "title": "VPC Connector Name", "description": "The name of the VPC connector to use for the Cloud Run Job."}}, "description": "Infrastructure block used to run GCP Cloud Run Jobs. Note this block is experimental. The interface may change without notice.", "secret_fields": ["credentials.service_account_info.*"], "block_type_slug": "cloud-run-job"}	sha256:acb0001d2257a6f271c4e69e392f94913011d44d12bcd3e89a668dce76eba7ef	84db1b6e-2ea9-44b0-bb6c-5e28c122296c	["run-infrastructure"]	0.5.8
b6771a65-df53-416f-a19f-0adcefc0e4d0	2025-11-10 15:29:45.503072+00	2025-11-10 15:29:45.503086+00	{"type": "object", "title": "GcpCredentials", "properties": {"project": {"type": "string", "title": "Project", "description": "The GCP project to use for the client."}, "service_account_file": {"type": "string", "title": "Service Account File", "format": "path", "description": "Path to the service account JSON keyfile."}, "service_account_info": {"type": "object", "title": "Service Account Info", "description": "The contents of the keyfile as a dict."}}, "description": "Block used to manage authentication with GCP. Google authentication is\\nhandled via the `google.oauth2` module or through the CLI.\\nSpecify either one of service `account_file` or `service_account_info`; if both\\nare not specified, the client will try to detect the credentials following Google's\\n[Application Default Credentials](https://cloud.google.com/docs/authentication/application-default-credentials).\\nSee Google's [Authentication documentation](https://cloud.google.com/docs/authentication#service-accounts)\\nfor details on inference and recommended authentication patterns.", "secret_fields": ["service_account_info.*"], "block_type_slug": "gcp-credentials"}	sha256:f764f9c506a2bed9e5ed7cc9083d06d95f13c01c8c9a9e45bae5d9b4dc522624	4817e94d-e90f-4489-b87b-a5e4595f3e92	[]	0.5.8
4fa8c02b-02a8-474a-adb5-894e8cd582b0	2025-11-10 15:29:45.513905+00	2025-11-10 15:29:45.513919+00	{"type": "object", "title": "GcpSecret", "required": ["gcp_credentials", "secret_name"], "properties": {"secret_name": {"type": "string", "title": "Secret Name", "description": "Name of the secret to manage."}, "secret_version": {"type": "string", "title": "Secret Version", "default": "latest", "description": "Version number of the secret to use."}, "gcp_credentials": {"$ref": "#/definitions/GcpCredentials"}}, "description": "Manages a secret in Google Cloud Platform's Secret Manager.", "secret_fields": ["gcp_credentials.service_account_info.*"], "block_type_slug": "gcpsecret"}	sha256:0311dc4cd2480a4af70d3b30ecd14d296243e73e7245ba064b753e4c0b25acdf	af37262f-ba54-4e34-b45c-4ea570e9368f	[]	0.5.8
d2eee124-1d98-4287-a2ab-2f275111d9e1	2025-11-10 15:29:45.532763+00	2025-11-10 15:29:45.532778+00	{"type": "object", "title": "GcsBucket", "required": ["bucket"], "properties": {"bucket": {"type": "string", "title": "Bucket", "description": "Name of the bucket."}, "bucket_folder": {"type": "string", "title": "Bucket Folder", "default": "", "description": "A default path to a folder within the GCS bucket to use for reading and writing objects."}, "gcp_credentials": {"allOf": [{"$ref": "#/definitions/GcpCredentials"}], "title": "Gcp Credentials", "description": "The credentials to authenticate with GCP."}}, "description": "Block used to store data using GCP Cloud Storage Buckets.\\n\\nNote! `GcsBucket` in `prefect-gcp` is a unique block, separate from `GCS`\\nin core Prefect. `GcsBucket` does not use `gcsfs` under the hood,\\ninstead using the `google-cloud-storage` package, and offers more configuration\\nand functionality.", "secret_fields": ["gcp_credentials.service_account_info.*"], "block_type_slug": "gcs-bucket"}	sha256:6f44cdbd523fb8d4029fbc504a89095d67d27439aec09d2c1871b03a1f4e14e9	0d62d397-8240-4c54-b2b4-623d028d6ab1	["get-directory", "put-directory", "read-path", "write-path"]	0.5.8
33c37b97-3828-4e02-bc38-c89d7987a8fa	2025-11-10 15:29:45.552617+00	2025-11-10 15:29:45.552632+00	{"type": "object", "title": "VertexAICustomTrainingJob", "required": ["region", "image"], "properties": {"env": {"type": "object", "title": "Environment Variables", "description": "Environment variables to be passed to your Cloud Run Job.", "additionalProperties": {"type": "string"}}, "name": {"type": "string", "title": "Name", "description": "Name applied to the infrastructure for identification."}, "type": {"enum": ["vertex-ai-custom-training-job"], "type": "string", "title": "Type", "default": "vertex-ai-custom-training-job", "description": "The slug for this task type."}, "image": {"type": "string", "title": "Image Name", "description": "The image to use for a new Vertex AI custom training job. This value must refer to an image within either Google Container Registry or Google Artifact Registry, like `gcr.io/<project_name>/<repo>/`."}, "labels": {"type": "object", "title": "Labels", "description": "Labels applied to the infrastructure for metadata purposes.", "additionalProperties": {"type": "string"}}, "region": {"type": "string", "title": "Region", "description": "The region where the Vertex AI custom training job resides."}, "command": {"type": "array", "items": {"type": "string"}, "title": "Command", "description": "The command to run in the infrastructure."}, "network": {"type": "string", "title": "Network", "description": "The full name of the Compute Engine networkto which the Job should be peered. Private services access must already be configured for the network. If left unspecified, the job is not peered with any network."}, "machine_type": {"type": "string", "title": "Machine Type", "default": "n1-standard-4", "description": "The machine type to use for the run, which controls the available CPU and memory."}, "boot_disk_type": {"type": "string", "title": "Boot Disk Type", "default": "pd-ssd", "description": "The type of boot disk to attach to the machine."}, "gcp_credentials": {"allOf": [{"$ref": "#/definitions/GcpCredentials"}], "title": "Gcp Credentials", "description": "GCP credentials to use when running the configured Vertex AI custom training job. If not provided, credentials will be inferred from the environment. See `GcpCredentials` for details."}, "service_account": {"type": "string", "title": "Service Account", "description": "Specifies the service account to use as the run-as account in Vertex AI. The agent submitting jobs must have act-as permission on this run-as account. If unspecified, the AI Platform Custom Code Service Agent for the CustomJob's project is used. Takes precedence over the service account found in gcp_credentials, and required if a service account cannot be detected in gcp_credentials."}, "accelerator_type": {"type": "string", "title": "Accelerator Type", "description": "The type of accelerator to attach to the machine."}, "maximum_run_time": {"type": "number", "title": "Maximum Run Time", "format": "time-delta", "default": 604800.0, "description": "The maximum job running time."}, "accelerator_count": {"type": "integer", "title": "Accelerator Count", "description": "The number of accelerators to attach to the machine."}, "boot_disk_size_gb": {"type": "integer", "title": "Boot Disk Size", "default": 100, "description": "The size of the boot disk to attach to the machine, in gigabytes."}, "reserved_ip_ranges": {"type": "array", "items": {"type": "string"}, "title": "Reserved Ip Ranges", "description": "A list of names for the reserved ip ranges under the VPC network that can be used for this job. If set, we will deploy the job within the provided ip ranges. Otherwise, the job will be deployed to any ip ranges under the provided VPC network."}, "job_watch_poll_interval": {"type": "number", "title": "Job Watch Poll Interval", "default": 5.0, "description": "The amount of time to wait between GCP API calls while monitoring the state of a Vertex AI Job."}}, "description": "Infrastructure block used to run Vertex AI custom training jobs.", "secret_fields": ["gcp_credentials.service_account_info.*"], "block_type_slug": "vertex-ai-custom-training-job"}	sha256:3cfb58eddef311b9ed90e4c4a35605882c543b1ae51b32d770880ae4dd9af59f	d2176e39-c02f-470d-96bd-de4a775db763	["run-infrastructure"]	0.5.8
92f6f1cb-54fd-4d77-870a-f5348eb94572	2025-11-10 15:29:45.572044+00	2025-11-10 15:29:45.572057+00	{"type": "object", "title": "GitHubCredentials", "properties": {"token": {"type": "string", "title": "Token", "format": "password", "writeOnly": true, "description": "A GitHub personal access token (PAT)."}}, "description": "Block used to manage GitHub authentication.", "secret_fields": ["token"], "block_type_slug": "github-credentials"}	sha256:74a34b668838ba661d9160ab127053dd44a22dd04e89562839645791e70d046a	f30608cc-deaf-4017-8915-1787e5589f83	[]	0.2.2
87e32d6b-217a-48cf-b021-b13067b012ad	2025-11-10 15:29:45.581837+00	2025-11-10 15:29:45.581851+00	{"type": "object", "title": "GitHubRepository", "required": ["repository_url"], "properties": {"reference": {"type": "string", "title": "Reference", "description": "An optional reference to pin to; can be a branch name or tag."}, "credentials": {"allOf": [{"$ref": "#/definitions/GitHubCredentials"}], "title": "Credentials", "description": "An optional GitHubCredentials block for using private GitHub repos."}, "repository_url": {"type": "string", "title": "Repository URL", "description": "The URL of a GitHub repository to read from, in either HTTPS or SSH format. If you are using a private repo, it must be in the HTTPS format."}}, "description": "Interact with files stored on GitHub repositories.", "secret_fields": ["credentials.token"], "block_type_slug": "github-repository"}	sha256:3d2b2de1cd9336264ccc73f7078264d9053dc956941136516e18050c9953abf0	c2ba79ae-ffb0-45bb-8319-899365c3716c	["get-directory"]	0.2.2
5482c087-0f55-4f99-aaeb-aeed582646ae	2025-11-10 15:29:45.600657+00	2025-11-10 15:29:45.600671+00	{"type": "object", "title": "GitLabCredentials", "properties": {"url": {"type": "string", "title": "URL", "description": "URL to self-hosted GitLab instances."}, "token": {"name": "Personal Access Token", "type": "string", "title": "Token", "format": "password", "writeOnly": true, "description": "A GitLab Personal Access Token with read_repository scope."}}, "description": "Store a GitLab personal access token to interact with private GitLab\\nrepositories.", "secret_fields": ["token"], "block_type_slug": "gitlab-credentials"}	sha256:7d8d6317127bc66afe9e97ae5658ee8e1decdc598350eb292fb62be379f0246c	807b93b0-9c06-41ec-a70c-ea6f09d70d71	[]	0.2.2
e87cb6ed-8d1a-435f-8016-4c0f0f385b69	2025-11-10 15:29:45.610916+00	2025-11-10 15:29:45.610931+00	{"type": "object", "title": "GitLabRepository", "required": ["repository"], "properties": {"reference": {"type": "string", "title": "Reference", "description": "An optional reference to pin to; can be a branch name or tag."}, "repository": {"type": "string", "title": "Repository", "description": "The URL of a GitLab repository to read from, in either HTTP/HTTPS or SSH format."}, "credentials": {"allOf": [{"$ref": "#/definitions/GitLabCredentials"}], "title": "Credentials", "description": "An optional GitLab Credentials block for authenticating with private GitLab repos."}}, "description": "Interact with files stored in GitLab repositories.", "secret_fields": ["credentials.token"], "block_type_slug": "gitlab-repository"}	sha256:ac874a97e2ff2403a4b63181b6ae85dd51b4a0df0337d290d922627f5123af44	879820a4-bd7b-4a17-851e-ec28288e4578	["get-directory"]	0.2.2
0e3014c8-f33a-4f87-9384-8974d2458424	2025-11-10 15:29:45.629511+00	2025-11-10 15:29:45.629525+00	{"type": "object", "title": "KubernetesCredentials", "properties": {"cluster_config": {"$ref": "#/definitions/KubernetesClusterConfig"}}, "description": "Credentials block for generating configured Kubernetes API clients.", "secret_fields": [], "block_type_slug": "kubernetes-credentials"}	sha256:957fa8dca90bd1b5fb9c575ee09e80b454116c0b134287fbc2eff47a72564c3b	280264f0-14f8-45cc-806e-3e319debffe9	[]	0.3.7
401f1f8c-2ebc-4ba6-bf5f-9417809e54be	2025-11-10 15:29:45.648691+00	2025-11-10 15:29:45.648707+00	{"type": "object", "title": "ShellOperation", "required": ["commands"], "properties": {"env": {"type": "object", "title": "Environment Variables", "description": "Environment variables to use for the subprocess.", "additionalProperties": {"type": "string"}}, "shell": {"type": "string", "title": "Shell", "description": "The shell to run the command with; if unset, defaults to `powershell` on Windows and `bash` on other platforms."}, "commands": {"type": "array", "items": {"type": "string"}, "title": "Commands", "description": "A list of commands to execute sequentially."}, "extension": {"type": "string", "title": "Extension", "description": "The extension to use for the temporary file; if unset, defaults to `.ps1` on Windows and `.sh` on other platforms."}, "working_dir": {"type": "string", "title": "Working Directory", "format": "directory-path", "description": "The absolute path to the working directory the command will be executed within."}, "stream_output": {"type": "boolean", "title": "Stream Output", "default": true, "description": "Whether to stream output."}}, "description": "A block representing a shell operation, containing multiple commands.\\n\\nFor long-lasting operations, use the trigger method and utilize the block as a\\ncontext manager for automatic closure of processes when context is exited.\\nIf not, manually call the close method to close processes.\\n\\nFor short-lasting operations, use the run method. Context is automatically managed\\nwith this method.", "secret_fields": [], "block_type_slug": "shell-operation"}	sha256:9525e2fd40af302916ff7a4c33ec9c0e20d8970b09243ca010d729fac144811d	e97da1e9-1787-4113-a639-24570bfdb7a4	[]	0.2.2
14d6270c-2582-4ad1-b182-1845d3fd446f	2025-11-10 15:29:45.660232+00	2025-11-10 15:29:45.66025+00	{"type": "object", "title": "SlackCredentials", "required": ["token"], "properties": {"token": {"type": "string", "title": "Token", "format": "password", "writeOnly": true, "description": "Bot user OAuth token for the Slack app used to perform actions."}}, "description": "Block holding Slack credentials for use in tasks and flows.", "secret_fields": ["token"], "block_type_slug": "slack-credentials"}	sha256:f79058d8fcf22ed575f824b27daa68a52fedaa0e40f7a8a542d4ac9cf3ee8317	beef1dec-090c-4b1d-965f-9d52c4f46695	[]	0.2.2
6ee64ddc-0808-47ba-a2f6-fa052ec7a67d	2025-11-10 15:29:45.67101+00	2025-11-10 15:29:45.671026+00	{"type": "object", "title": "SnowflakeConnector", "required": ["credentials", "database", "warehouse", "schema"], "properties": {"schema": {"type": "string", "title": "Schema", "description": "The name of the default schema to use."}, "database": {"type": "string", "title": "Database", "description": "The name of the default database to use."}, "warehouse": {"type": "string", "title": "Warehouse", "description": "The name of the default warehouse to use."}, "fetch_size": {"type": "integer", "title": "Fetch Size", "default": 1, "description": "The default number of rows to fetch at a time."}, "credentials": {"allOf": [{"$ref": "#/definitions/SnowflakeCredentials"}], "title": "Credentials", "description": "The credentials to authenticate with Snowflake."}, "poll_frequency_s": {"type": "integer", "title": "Poll Frequency [seconds]", "default": 1, "description": "The number of seconds between checking query status for long running queries."}}, "description": "Perform data operations against a Snowflake database.", "secret_fields": ["credentials.password", "credentials.private_key", "credentials.private_key_passphrase", "credentials.token"], "block_type_slug": "snowflake-connector"}	sha256:dd0d36d69bbe0d44870fd754f3c00754e37e3f52209590083eaee4c585ce0bd0	23d7c017-9d6a-4544-aa2e-0290ba45a6d3	[]	0.27.3
1eaefebc-840f-4c89-94b8-5fd9a5722c87	2025-11-10 15:29:45.690355+00	2025-11-10 15:29:45.690371+00	{"type": "object", "title": "SnowflakeCredentials", "required": ["account", "user"], "properties": {"role": {"type": "string", "title": "Role", "description": "The name of the default role to use."}, "user": {"type": "string", "title": "User", "description": "The user name used to authenticate."}, "token": {"type": "string", "title": "Token", "format": "password", "writeOnly": true, "description": "The OAuth or JWT Token to provide when authenticator is set to `oauth`."}, "account": {"type": "string", "title": "Account", "example": "nh12345.us-east-2.aws", "description": "The snowflake account name."}, "endpoint": {"type": "string", "title": "Endpoint", "description": "The Okta endpoint to use when authenticator is set to `okta_endpoint`."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password used to authenticate."}, "autocommit": {"type": "boolean", "title": "Autocommit", "description": "Whether to automatically commit."}, "private_key": {"type": "string", "title": "Private Key", "format": "password", "writeOnly": true, "description": "The PEM used to authenticate."}, "authenticator": {"enum": ["snowflake", "snowflake_jwt", "externalbrowser", "okta_endpoint", "oauth", "username_password_mfa"], "type": "string", "title": "Authenticator", "default": "snowflake", "description": "The type of authenticator to use for initializing connection."}, "private_key_path": {"type": "string", "title": "Private Key Path", "format": "path", "description": "The path to the private key."}, "private_key_passphrase": {"type": "string", "title": "Private Key Passphrase", "format": "password", "writeOnly": true, "description": "The password to use for the private key."}}, "description": "Block used to manage authentication with Snowflake.", "secret_fields": ["password", "private_key", "private_key_passphrase", "token"], "block_type_slug": "snowflake-credentials"}	sha256:b24edfb413527c951cb2a8b4b4c16aec096523f871d941889e29ac2e6e92e036	adff8102-8bb1-4f2e-abd6-5e27e2660f56	[]	0.27.3
8361a56f-c12b-458a-ac7d-552d565e5243	2025-11-10 15:29:45.701483+00	2025-11-10 15:29:45.7015+00	{"type": "object", "title": "DatabaseCredentials", "properties": {"url": {"type": "string", "title": "Url", "format": "uri", "maxLength": 65536, "minLength": 1, "description": "Manually create and provide a URL to create the engine, this is useful for external dialects, e.g. Snowflake, because some of the params, such as 'warehouse', is not directly supported in the vanilla `sqlalchemy.engine.URL.create` method; do not provide this alongside with other URL params as it will raise a `ValueError`."}, "host": {"type": "string", "title": "Host", "description": "The host address of the database."}, "port": {"type": "string", "title": "Port", "description": "The port to connect to the database."}, "query": {"type": "object", "title": "Query", "description": "A dictionary of string keys to string values to be passed to the dialect and/or the DBAPI upon connect. To specify non-string parameters to a Python DBAPI directly, use connect_args.", "additionalProperties": {"type": "string"}}, "driver": {"anyOf": [{"$ref": "#/definitions/AsyncDriver"}, {"$ref": "#/definitions/SyncDriver"}, {"type": "string"}], "title": "Driver", "description": "The driver name to use."}, "database": {"type": "string", "title": "Database", "description": "The name of the database to use."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password used to authenticate."}, "username": {"type": "string", "title": "Username", "description": "The user name used to authenticate."}, "connect_args": {"type": "object", "title": "Connect Args", "description": "The options which will be passed directly to the DBAPI's connect() method as additional keyword arguments."}}, "definitions": {"SyncDriver": {"enum": ["postgresql+psycopg2", "postgresql+pg8000", "postgresql+psycopg2cffi", "postgresql+pypostgresql", "postgresql+pygresql", "mysql+mysqldb", "mysql+pymysql", "mysql+mysqlconnector", "mysql+cymysql", "mysql+oursql", "mysql+pyodbc", "sqlite+pysqlite", "sqlite+pysqlcipher", "oracle+cx_oracle", "mssql+pyodbc", "mssql+mxodbc", "mssql+pymssql"], "title": "SyncDriver", "description": "Known dialects with their corresponding sync drivers.\\n\\nAttributes:\\n    POSTGRESQL_PSYCOPG2 (Enum): [postgresql+psycopg2](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2)\\n    POSTGRESQL_PG8000 (Enum): [postgresql+pg8000](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pg8000)\\n    POSTGRESQL_PSYCOPG2CFFI (Enum): [postgresql+psycopg2cffi](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2cffi)\\n    POSTGRESQL_PYPOSTGRESQL (Enum): [postgresql+pypostgresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pypostgresql)\\n    POSTGRESQL_PYGRESQL (Enum): [postgresql+pygresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pygresql)\\n\\n    MYSQL_MYSQLDB (Enum): [mysql+mysqldb](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqldb)\\n    MYSQL_PYMYSQL (Enum): [mysql+pymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pymysql)\\n    MYSQL_MYSQLCONNECTOR (Enum): [mysql+mysqlconnector](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqlconnector)\\n    MYSQL_CYMYSQL (Enum): [mysql+cymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.cymysql)\\n    MYSQL_OURSQL (Enum): [mysql+oursql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.oursql)\\n    MYSQL_PYODBC (Enum): [mysql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pyodbc)\\n\\n    SQLITE_PYSQLITE (Enum): [sqlite+pysqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlite)\\n    SQLITE_PYSQLCIPHER (Enum): [sqlite+pysqlcipher](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlcipher)\\n\\n    ORACLE_CX_ORACLE (Enum): [oracle+cx_oracle](https://docs.sqlalchemy.org/en/14/dialects/oracle.html#module-sqlalchemy.dialects.oracle.cx_oracle)\\n\\n    MSSQL_PYODBC (Enum): [mssql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pyodbc)\\n    MSSQL_MXODBC (Enum): [mssql+mxodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.mxodbc)\\n    MSSQL_PYMSSQL (Enum): [mssql+pymssql](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pymssql)"}, "AsyncDriver": {"enum": ["postgresql+asyncpg", "sqlite+aiosqlite", "mysql+asyncmy", "mysql+aiomysql"], "title": "AsyncDriver", "description": "Known dialects with their corresponding async drivers.\\n\\nAttributes:\\n    POSTGRESQL_ASYNCPG (Enum): [postgresql+asyncpg](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.asyncpg)\\n\\n    SQLITE_AIOSQLITE (Enum): [sqlite+aiosqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.aiosqlite)\\n\\n    MYSQL_ASYNCMY (Enum): [mysql+asyncmy](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.asyncmy)\\n    MYSQL_AIOMYSQL (Enum): [mysql+aiomysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.aiomysql)"}}, "description": "Block used to manage authentication with a database.", "secret_fields": ["password"], "block_type_slug": "database-credentials"}	sha256:76d1ccbf0ab2038fea77e9689b91a7c8b6398e080e95d9303f65a93a4c03162e	dd83a224-2277-4759-ba9b-490e3641e6a5	[]	0.4.0
e12c2f23-3f55-48f0-a091-dcaaf86aa1fb	2025-11-10 15:29:45.713237+00	2025-11-10 15:29:45.713254+00	{"type": "object", "title": "SqlAlchemyConnector", "required": ["connection_info"], "properties": {"fetch_size": {"type": "integer", "title": "Fetch Size", "default": 1, "description": "The number of rows to fetch at a time."}, "connect_args": {"type": "object", "title": "Additional Connection Arguments", "description": "The options which will be passed directly to the DBAPI's connect() method as additional keyword arguments."}, "connection_info": {"anyOf": [{"$ref": "#/definitions/ConnectionComponents"}, {"type": "string", "format": "uri", "maxLength": 65536, "minLength": 1}], "title": "Connection Info", "description": "SQLAlchemy URL to create the engine; either create from components or create from a string."}}, "definitions": {"SyncDriver": {"enum": ["postgresql+psycopg2", "postgresql+pg8000", "postgresql+psycopg2cffi", "postgresql+pypostgresql", "postgresql+pygresql", "mysql+mysqldb", "mysql+pymysql", "mysql+mysqlconnector", "mysql+cymysql", "mysql+oursql", "mysql+pyodbc", "sqlite+pysqlite", "sqlite+pysqlcipher", "oracle+cx_oracle", "mssql+pyodbc", "mssql+mxodbc", "mssql+pymssql"], "title": "SyncDriver", "description": "Known dialects with their corresponding sync drivers.\\n\\nAttributes:\\n    POSTGRESQL_PSYCOPG2 (Enum): [postgresql+psycopg2](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2)\\n    POSTGRESQL_PG8000 (Enum): [postgresql+pg8000](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pg8000)\\n    POSTGRESQL_PSYCOPG2CFFI (Enum): [postgresql+psycopg2cffi](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.psycopg2cffi)\\n    POSTGRESQL_PYPOSTGRESQL (Enum): [postgresql+pypostgresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pypostgresql)\\n    POSTGRESQL_PYGRESQL (Enum): [postgresql+pygresql](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.pygresql)\\n\\n    MYSQL_MYSQLDB (Enum): [mysql+mysqldb](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqldb)\\n    MYSQL_PYMYSQL (Enum): [mysql+pymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pymysql)\\n    MYSQL_MYSQLCONNECTOR (Enum): [mysql+mysqlconnector](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.mysqlconnector)\\n    MYSQL_CYMYSQL (Enum): [mysql+cymysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.cymysql)\\n    MYSQL_OURSQL (Enum): [mysql+oursql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.oursql)\\n    MYSQL_PYODBC (Enum): [mysql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.pyodbc)\\n\\n    SQLITE_PYSQLITE (Enum): [sqlite+pysqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlite)\\n    SQLITE_PYSQLCIPHER (Enum): [sqlite+pysqlcipher](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.pysqlcipher)\\n\\n    ORACLE_CX_ORACLE (Enum): [oracle+cx_oracle](https://docs.sqlalchemy.org/en/14/dialects/oracle.html#module-sqlalchemy.dialects.oracle.cx_oracle)\\n\\n    MSSQL_PYODBC (Enum): [mssql+pyodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pyodbc)\\n    MSSQL_MXODBC (Enum): [mssql+mxodbc](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.mxodbc)\\n    MSSQL_PYMSSQL (Enum): [mssql+pymssql](https://docs.sqlalchemy.org/en/14/dialects/mssql.html#module-sqlalchemy.dialects.mssql.pymssql)"}, "AsyncDriver": {"enum": ["postgresql+asyncpg", "sqlite+aiosqlite", "mysql+asyncmy", "mysql+aiomysql"], "title": "AsyncDriver", "description": "Known dialects with their corresponding async drivers.\\n\\nAttributes:\\n    POSTGRESQL_ASYNCPG (Enum): [postgresql+asyncpg](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#module-sqlalchemy.dialects.postgresql.asyncpg)\\n\\n    SQLITE_AIOSQLITE (Enum): [sqlite+aiosqlite](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#module-sqlalchemy.dialects.sqlite.aiosqlite)\\n\\n    MYSQL_ASYNCMY (Enum): [mysql+asyncmy](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.asyncmy)\\n    MYSQL_AIOMYSQL (Enum): [mysql+aiomysql](https://docs.sqlalchemy.org/en/14/dialects/mysql.html#module-sqlalchemy.dialects.mysql.aiomysql)"}, "ConnectionComponents": {"type": "object", "title": "ConnectionComponents", "required": ["driver", "database"], "properties": {"host": {"type": "string", "title": "Host", "description": "The host address of the database."}, "port": {"type": "string", "title": "Port", "description": "The port to connect to the database."}, "query": {"type": "object", "title": "Query", "description": "A dictionary of string keys to string values to be passed to the dialect and/or the DBAPI upon connect. To specify non-string parameters to a Python DBAPI directly, use connect_args.", "additionalProperties": {"type": "string"}}, "driver": {"anyOf": [{"$ref": "#/definitions/AsyncDriver"}, {"$ref": "#/definitions/SyncDriver"}, {"type": "string"}], "title": "Driver", "description": "The driver name to use."}, "database": {"type": "string", "title": "Database", "description": "The name of the database to use."}, "password": {"type": "string", "title": "Password", "format": "password", "writeOnly": true, "description": "The password used to authenticate."}, "username": {"type": "string", "title": "Username", "description": "The user name used to authenticate."}}, "description": "Parameters to use to create a SQLAlchemy engine URL.\\n\\nAttributes:\\n    driver: The driver name to use.\\n    database: The name of the database to use.\\n    username: The user name used to authenticate.\\n    password: The password used to authenticate.\\n    host: The host address of the database.\\n    port: The port to connect to the database.\\n    query: A dictionary of string keys to string values to be passed to the dialect\\n        and/or the DBAPI upon connect."}}, "description": "Block used to manage authentication with a database.\\n\\nUpon instantiating, an engine is created and maintained for the life of\\nthe object until the close method is called.\\n\\nIt is recommended to use this block as a context manager, which will automatically\\nclose the engine and its connections when the context is exited.\\n\\nIt is also recommended that this block is loaded and consumed within a single task\\nor flow because if the block is passed across separate tasks and flows,\\nthe state of the block's connection and cursor could be lost.", "secret_fields": ["connection_info.password"], "block_type_slug": "sqlalchemy-connector"}	sha256:01e6c0bdaac125860811b201f5a5e98ffefd5f8a49f1398b6996aec362643acc	26e2a9b6-d402-4582-96b5-2e830228705f	[]	0.4.0
\.


--
-- Data for Name: block_schema_reference; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.block_schema_reference (id, created, updated, name, parent_block_schema_id, reference_block_schema_id) FROM stdin;
1961cd8e-0ddc-4dc7-90b3-43389a0b69da	2025-11-10 15:29:44.620034+00	2025-11-10 15:29:44.620049+00	image_registry	69b4881e-e5d6-432c-9c4d-4e38e2d56076	c2ed2b93-4c0f-4cff-a08e-c91e52f5bf9d
7deda7b9-d758-4900-a4e9-4a66c546ab2c	2025-11-10 15:29:44.67+00	2025-11-10 15:29:44.670014+00	cluster_config	eb638633-fd66-4dca-b87e-ad5eddd89d2e	777093a3-baa6-4c54-a149-23a472b59aa6
a85c592a-c8a4-4115-b4f7-4650d93af092	2025-11-10 15:29:44.925779+00	2025-11-10 15:29:44.925794+00	aws_credentials	f94a7aed-416c-4293-8503-88bd4da6d206	5bbd1795-3796-425c-987a-c4cba38a8561
e06f0b8f-963e-47d8-858c-2d445d5e3f1c	2025-11-10 15:29:44.948209+00	2025-11-10 15:29:44.948223+00	aws_credentials	665db009-862b-41db-bd53-b1cddf44f358	5bbd1795-3796-425c-987a-c4cba38a8561
a09574eb-883b-489a-8676-b74784a49e18	2025-11-10 15:29:44.968808+00	2025-11-10 15:29:44.968822+00	aws_credentials	afadaa63-8a13-40bf-bf9e-28c86c36ff31	5bbd1795-3796-425c-987a-c4cba38a8561
58d65760-c7cc-4b99-9c97-8ba5b55471fa	2025-11-10 15:29:45.000617+00	2025-11-10 15:29:45.000631+00	credentials	0c26191e-e1b7-4b0c-9c0d-c209e5f1a846	4e00ee81-e5e6-4f18-8487-a02e1212fde5
74a454ba-4227-4645-8eec-c59e5624f684	2025-11-10 15:29:45.009744+00	2025-11-10 15:29:45.009759+00	credentials	0c26191e-e1b7-4b0c-9c0d-c209e5f1a846	5bbd1795-3796-425c-987a-c4cba38a8561
8422bb12-15d3-456f-b2a3-059eb131a281	2025-11-10 15:29:45.034498+00	2025-11-10 15:29:45.034512+00	credentials	4a298ce8-bc6b-4657-a725-e8bf8a4d92d8	039b7e5b-35cc-4c78-818b-db95f2162317
2461453f-6ed1-40a0-bdb6-e06b03c56800	2025-11-10 15:29:45.077129+00	2025-11-10 15:29:45.077143+00	aci_credentials	06fb9814-4ade-4689-84a2-2a073e8e322d	ad7a0d94-fd29-4eac-ba04-03472b1c7b56
c673da51-de15-459b-aae7-6b95809b07da	2025-11-10 15:29:45.09105+00	2025-11-10 15:29:45.091064+00	image_registry	06fb9814-4ade-4689-84a2-2a073e8e322d	4a4ffe4a-3f47-4adb-80a2-b8e024e233ac
48f049d3-db5a-41f8-9bef-ec3bbe1a9215	2025-11-10 15:29:45.140747+00	2025-11-10 15:29:45.140761+00	bitbucket_credentials	d1c69885-1704-4987-95d7-07025875f154	b2313c80-ac19-4ad9-a087-778dbe199161
0c8a95d0-3037-4039-a814-a133d3dd67fb	2025-11-10 15:29:45.176066+00	2025-11-10 15:29:45.176079+00	credentials	199d33e2-63f3-44fb-8c56-37daa90c3b9c	27ebbf43-2ea7-49fe-a4f4-aa08b2e54dd0
a8a2e282-ebb3-4764-97c9-328a066b172b	2025-11-10 15:29:45.215525+00	2025-11-10 15:29:45.215539+00	credentials	b0dd96ec-a223-439e-906b-705e61aec3d8	e89af390-ba32-47a2-9407-23d82026ccb1
cbf0d71d-6ebf-44bb-b4be-fe20e8bd5a04	2025-11-10 15:29:45.231174+00	2025-11-10 15:29:45.231188+00	credentials	b0dd96ec-a223-439e-906b-705e61aec3d8	ecc358cf-363c-44db-859e-d38cb196620a
041ac2a5-e701-4e06-8e88-7641343097ad	2025-11-10 15:29:45.287038+00	2025-11-10 15:29:45.287051+00	credentials	1c7bc499-8474-43e4-8aa5-e94cc63dfd8f	f0bdd34a-b283-4435-8201-6e649a9d41ff
038616f0-0e8e-4b0a-9799-90f07ad6f61a	2025-11-10 15:29:45.28996+00	2025-11-10 15:29:45.289973+00	connector	cafbbe36-852a-4f37-8fed-ffb42c211fda	1c7bc499-8474-43e4-8aa5-e94cc63dfd8f
12925a1e-8dac-4e6e-98c0-6cd3c5ea8999	2025-11-10 15:29:45.292888+00	2025-11-10 15:29:45.292901+00	target_configs	9c1527cd-50cc-4767-a87a-0c1d98655776	cafbbe36-852a-4f37-8fed-ffb42c211fda
15218b89-fcbe-4645-bb2f-744aeb2ae994	2025-11-10 15:29:45.302708+00	2025-11-10 15:29:45.302726+00	target_configs	9c1527cd-50cc-4767-a87a-0c1d98655776	199d33e2-63f3-44fb-8c56-37daa90c3b9c
02923495-1261-43a5-827e-dae8f0442c12	2025-11-10 15:29:45.313534+00	2025-11-10 15:29:45.313548+00	target_configs	9c1527cd-50cc-4767-a87a-0c1d98655776	b0dd96ec-a223-439e-906b-705e61aec3d8
2f59de77-2fb9-4014-962c-c29ef4ce2eb2	2025-11-10 15:29:45.330033+00	2025-11-10 15:29:45.330047+00	target_configs	9c1527cd-50cc-4767-a87a-0c1d98655776	a246a55e-09e7-4283-b0b7-8a789653dad3
143937c6-a261-45fb-8da0-d69f526df3d1	2025-11-10 15:29:45.339041+00	2025-11-10 15:29:45.339055+00	global_configs	9c1527cd-50cc-4767-a87a-0c1d98655776	2e359870-7534-4bf8-ae7a-c6c5613b8f97
2ed173aa-4e5d-470e-a109-e91ab6a37e5c	2025-11-10 15:29:45.377428+00	2025-11-10 15:29:45.377441+00	credentials	87857a20-0eff-4f19-b9e8-085a238b699a	78e327a0-aa1e-44da-acba-67cc09177dca
9b31ecbb-61fb-450c-92c7-85e49119a35a	2025-11-10 15:29:45.38026+00	2025-11-10 15:29:45.380274+00	connector	0fc3f9ae-7e57-4409-aa64-a434d6b15cfd	87857a20-0eff-4f19-b9e8-085a238b699a
3d62fe48-4304-4e61-ae0f-217ca5682d4e	2025-11-10 15:29:45.427189+00	2025-11-10 15:29:45.427202+00	dbt_cli_profile	f03eddbb-cf03-473f-99e9-d04d7f1a0345	9c1527cd-50cc-4767-a87a-0c1d98655776
f5207166-8ae7-4a1f-9404-b53d12bc3df3	2025-11-10 15:29:45.475399+00	2025-11-10 15:29:45.475413+00	gcp_credentials	c5145a70-1c69-471c-b00c-233ab83c90eb	27ebbf43-2ea7-49fe-a4f4-aa08b2e54dd0
6a046e18-04c5-467a-8b7c-85a94f732a39	2025-11-10 15:29:45.49475+00	2025-11-10 15:29:45.494763+00	credentials	cbad1d51-e7e5-42f9-a737-3c1a1fffd152	27ebbf43-2ea7-49fe-a4f4-aa08b2e54dd0
deb1e51d-323d-49bb-a4f9-7f702ec412c2	2025-11-10 15:29:45.524037+00	2025-11-10 15:29:45.524051+00	gcp_credentials	4fa8c02b-02a8-474a-adb5-894e8cd582b0	b6771a65-df53-416f-a19f-0adcefc0e4d0
e3c6e842-cb81-4d4e-ad1f-952073f749a7	2025-11-10 15:29:45.543774+00	2025-11-10 15:29:45.543788+00	gcp_credentials	d2eee124-1d98-4287-a2ab-2f275111d9e1	b6771a65-df53-416f-a19f-0adcefc0e4d0
bae60f76-c226-450b-8947-36d53c9697fd	2025-11-10 15:29:45.563628+00	2025-11-10 15:29:45.563641+00	gcp_credentials	33c37b97-3828-4e02-bc38-c89d7987a8fa	b6771a65-df53-416f-a19f-0adcefc0e4d0
c982178f-c485-4503-b865-3222268823b4	2025-11-10 15:29:45.592338+00	2025-11-10 15:29:45.592353+00	credentials	87e32d6b-217a-48cf-b021-b13067b012ad	92f6f1cb-54fd-4d77-870a-f5348eb94572
428db716-717d-482c-90d6-8184e4719848	2025-11-10 15:29:45.621151+00	2025-11-10 15:29:45.621165+00	credentials	e87cb6ed-8d1a-435f-8016-4c0f0f385b69	5482c087-0f55-4f99-aaeb-aeed582646ae
fc782bfc-ad35-44fa-bc5b-06d377ce2617	2025-11-10 15:29:45.640237+00	2025-11-10 15:29:45.640251+00	cluster_config	0e3014c8-f33a-4f87-9384-8974d2458424	777093a3-baa6-4c54-a149-23a472b59aa6
aeb88e7f-2fb4-4783-a48d-3ef81b5705a7	2025-11-10 15:29:45.681723+00	2025-11-10 15:29:45.681737+00	credentials	6ee64ddc-0808-47ba-a2f6-fa052ec7a67d	78e327a0-aa1e-44da-acba-67cc09177dca
\.


--
-- Data for Name: block_type; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.block_type (id, created, updated, name, logo_url, documentation_url, description, code_example, is_protected, slug) FROM stdin;
8b809681-f571-4206-a179-9681d5c5cbfb	2025-11-10 15:29:44.094763+00	2026-01-25 15:15:52.321172+00	Process	https://cdn.sanity.io/images/3ugk85nk/production/356e6766a91baf20e1d08bbe16e8b5aaef4d8643-48x48.png	https://docs.prefect.io/concepts/infrastructure/#process	Run a command in a new process.\n\nCurrent environment variables and Prefect settings will be included in the created\nprocess. Configured environment variables will override any current environment\nvariables.	```python\nfrom prefect.infrastructure.process import Process\n\nprocess_block = Process.load("BLOCK_NAME")\n```	t	process
cf809fdf-fd78-4090-9687-f9f0ee245ecd	2025-11-10 15:29:43.727246+00	2026-01-25 15:15:52.203494+00	Webhook	https://cdn.sanity.io/images/3ugk85nk/production/c7247cb359eb6cf276734d4b1fbf00fb8930e89e-250x250.png	https://docs.prefect.io/api-ref/prefect/blocks/webhook/#prefect.blocks.webhook.Webhook	Block that enables calling webhooks.	```python\nfrom prefect.blocks.webhook import Webhook\n\nwebhook_block = Webhook.load("BLOCK_NAME")\n```	t	webhook
3ce57538-7b29-4aa2-9ff7-cb5e26d01935	2025-11-10 15:29:44.081312+00	2026-01-25 15:15:52.212454+00	Local File System	https://cdn.sanity.io/images/3ugk85nk/production/ad39089fa66d273b943394a68f003f7a19aa850e-48x48.png	https://docs.prefect.io/concepts/filesystems/#local-filesystem	Store data as a file on a local file system.	Load stored local file system config:\n```python\nfrom prefect.filesystems import LocalFileSystem\n\nlocal_file_system_block = LocalFileSystem.load("BLOCK_NAME")\n```	t	local-file-system
01b2484d-187f-4a91-b0de-a0a2fa054bbf	2025-11-10 15:29:44.110458+00	2026-01-25 15:15:52.072529+00	Slack Webhook	https://cdn.sanity.io/images/3ugk85nk/production/c1965ecbf8704ee1ea20d77786de9a41ce1087d1-500x500.png	https://docs.prefect.io/api-ref/prefect/blocks/notifications/#prefect.blocks.notifications.SlackWebhook	Enables sending notifications via a provided Slack webhook.	Load a saved Slack webhook and send a message:\n```python\nfrom prefect.blocks.notifications import SlackWebhook\n\nslack_webhook_block = SlackWebhook.load("BLOCK_NAME")\nslack_webhook_block.notify("Hello from Prefect!")\n```	f	slack-webhook
60f1a1ed-3cf7-44ea-82a4-161972502a8e	2025-11-10 15:29:44.126914+00	2026-01-25 15:15:52.083294+00	Microsoft Teams Webhook	https://cdn.sanity.io/images/3ugk85nk/production/817efe008a57f0a24f3587414714b563e5e23658-250x250.png	https://docs.prefect.io/api-ref/prefect/blocks/notifications/#prefect.blocks.notifications.MicrosoftTeamsWebhook	Enables sending notifications via a provided Microsoft Teams webhook.	Load a saved Teams webhook and send a message:\n```python\nfrom prefect.blocks.notifications import MicrosoftTeamsWebhook\nteams_webhook_block = MicrosoftTeamsWebhook.load("BLOCK_NAME")\nteams_webhook_block.notify("Hello from Prefect!")\n```	f	ms-teams-webhook
902e22cb-0d10-4ff5-a7fe-3d6ee23e5998	2025-11-10 15:29:44.151548+00	2026-01-25 15:15:52.09335+00	Pager Duty Webhook	https://cdn.sanity.io/images/3ugk85nk/production/8dbf37d17089c1ce531708eac2e510801f7b3aee-250x250.png	https://docs.prefect.io/api-ref/prefect/blocks/notifications/#prefect.blocks.notifications.PagerDutyWebHook	Enables sending notifications via a provided PagerDuty webhook.	Load a saved PagerDuty webhook and send a message:\n```python\nfrom prefect.blocks.notifications import PagerDutyWebHook\npagerduty_webhook_block = PagerDutyWebHook.load("BLOCK_NAME")\npagerduty_webhook_block.notify("Hello from Prefect!")\n```	f	pager-duty-webhook
76448f87-b13d-4253-9705-636fc297c7c2	2025-11-10 15:29:44.265582+00	2026-01-25 15:15:52.101914+00	Twilio SMS	https://cdn.sanity.io/images/3ugk85nk/production/8bd8777999f82112c09b9c8d57083ac75a4a0d65-250x250.png	https://docs.prefect.io/api-ref/prefect/blocks/notifications/#prefect.blocks.notifications.TwilioSMS	Enables sending notifications via Twilio SMS.	Load a saved `TwilioSMS` block and send a message:\n```python\nfrom prefect.blocks.notifications import TwilioSMS\ntwilio_webhook_block = TwilioSMS.load("BLOCK_NAME")\ntwilio_webhook_block.notify("Hello from Prefect!")\n```	f	twilio-sms
9a6bfc6d-174c-4464-819a-ad1e4a7b9b11	2025-11-10 15:29:44.284549+00	2026-01-25 15:15:52.112001+00	Opsgenie Webhook	https://cdn.sanity.io/images/3ugk85nk/production/d8b5bc6244ae6cd83b62ec42f10d96e14d6e9113-280x280.png	https://docs.prefect.io/api-ref/prefect/blocks/notifications/#prefect.blocks.notifications.OpsgenieWebhook	Enables sending notifications via a provided Opsgenie webhook.	Load a saved Opsgenie webhook and send a message:\n```python\nfrom prefect.blocks.notifications import OpsgenieWebhook\nopsgenie_webhook_block = OpsgenieWebhook.load("BLOCK_NAME")\nopsgenie_webhook_block.notify("Hello from Prefect!")\n```	f	opsgenie-webhook
7e20de36-9198-4df7-9006-cd76601cd6b8	2025-11-10 15:29:44.303372+00	2026-01-25 15:15:52.1213+00	Mattermost Webhook	https://cdn.sanity.io/images/3ugk85nk/production/1350a147130bf82cbc799a5f868d2c0116207736-250x250.png	https://docs.prefect.io/api-ref/prefect/blocks/notifications/#prefect.blocks.notifications.MattermostWebhook	Enables sending notifications via a provided Mattermost webhook.	Load a saved Mattermost webhook and send a message:\n```python\nfrom prefect.blocks.notifications import MattermostWebhook\n\nmattermost_webhook_block = MattermostWebhook.load("BLOCK_NAME")\n\nmattermost_webhook_block.notify("Hello from Prefect!")\n```	f	mattermost-webhook
b3c9aa4c-9ac5-44e0-a944-d7169133d4c3	2025-11-10 15:29:44.340018+00	2026-01-25 15:15:52.132864+00	Discord Webhook	https://cdn.sanity.io/images/3ugk85nk/production/9e94976c80ef925b66d24e5d14f0d47baa6b8f88-250x250.png	https://docs.prefect.io/api-ref/prefect/blocks/notifications/#prefect.blocks.notifications.DiscordWebhook	Enables sending notifications via a provided Discord webhook.	Load a saved Discord webhook and send a message:\n```python\nfrom prefect.blocks.notifications import DiscordWebhook\n\ndiscord_webhook_block = DiscordWebhook.load("BLOCK_NAME")\n\ndiscord_webhook_block.notify("Hello from Prefect!")\n```	f	discord-webhook
e09eed89-2851-4abe-baa7-5dcb4eca8229	2025-11-10 15:29:44.003779+00	2026-01-25 15:15:52.180811+00	Date Time	https://cdn.sanity.io/images/3ugk85nk/production/8b3da9a6621e92108b8e6a75b82e15374e170ff7-48x48.png	https://docs.prefect.io/api-ref/prefect/blocks/system/#prefect.blocks.system.DateTime	A block that represents a datetime	Load a stored JSON value:\n```python\nfrom prefect.blocks.system import DateTime\n\ndata_time_block = DateTime.load("BLOCK_NAME")\n```	t	date-time
ebd43b6d-5bb8-4582-9001-5b658fbd70f0	2025-11-10 15:29:44.056897+00	2026-01-25 15:15:52.193755+00	Secret	https://cdn.sanity.io/images/3ugk85nk/production/c6f20e556dd16effda9df16551feecfb5822092b-48x48.png	https://docs.prefect.io/api-ref/prefect/blocks/system/#prefect.blocks.system.Secret	A block that represents a secret value. The value stored in this block will be obfuscated when\nthis block is logged or shown in the UI.	```python\nfrom prefect.blocks.system import Secret\n\nsecret_block = Secret.load("BLOCK_NAME")\n\n# Access the stored secret\nsecret_block.get()\n```	t	secret
90a36992-37de-48e5-b490-af103b20b771	2025-11-10 15:29:44.373844+00	2026-01-25 15:15:52.153186+00	Sendgrid Email	https://cdn.sanity.io/images/3ugk85nk/production/82bc6ed16ca42a2252a5512c72233a253b8a58eb-250x250.png	https://docs.prefect.io/api-ref/prefect/blocks/notifications/#prefect.blocks.notifications.SendgridEmail	Enables sending notifications via Sendgrid email service.	Load a saved Sendgrid and send a email message:\n```python\nfrom prefect.blocks.notifications import SendgridEmail\n\nsendgrid_block = SendgridEmail.load("BLOCK_NAME")\n\nsendgrid_block.notify("Hello from Prefect!")	f	sendgrid-email
b124696c-96b4-4977-b256-ad9831ba1f29	2025-11-10 15:29:44.402616+00	2026-01-25 15:15:52.17169+00	String	https://cdn.sanity.io/images/3ugk85nk/production/c262ea2c80a2c043564e8763f3370c3db5a6b3e6-48x48.png	https://docs.prefect.io/api-ref/prefect/blocks/system/#prefect.blocks.system.String	A block that represents a string	Load a stored string value:\n```python\nfrom prefect.blocks.system import String\n\nstring_block = String.load("BLOCK_NAME")\n```	f	string
7c148288-67ac-4e26-b9eb-503ac5a8634c	2025-11-10 15:29:44.466068+00	2026-01-25 15:15:52.2212+00	Remote File System	https://cdn.sanity.io/images/3ugk85nk/production/e86b41bc0f9c99ba9489abeee83433b43d5c9365-48x48.png	https://docs.prefect.io/concepts/filesystems/#remote-file-system	Store data as a file on a remote file system.\n\nSupports any remote file system supported by `fsspec`. The file system is specified\nusing a protocol. For example, "s3://my-bucket/my-folder/" will use S3.	Load stored remote file system config:\n```python\nfrom prefect.filesystems import RemoteFileSystem\n\nremote_file_system_block = RemoteFileSystem.load("BLOCK_NAME")\n```	f	remote-file-system
cb102f3e-d893-4d51-84f0-16e169c45e1e	2025-11-10 15:29:44.484961+00	2026-01-25 15:15:52.230362+00	S3	https://cdn.sanity.io/images/3ugk85nk/production/d74b16fe84ce626345adf235a47008fea2869a60-225x225.png	https://docs.prefect.io/concepts/filesystems/#s3	DEPRECATION WARNING:\n\nThis class is deprecated as of March 2024 and will not be available after September 2024.\nIt has been replaced by `S3Bucket` from the `prefect-aws` package, which offers enhanced functionality\nand better a better user experience.\n\nStore data as a file on AWS S3.	Load stored S3 config:\n```python\nfrom prefect.filesystems import S3\n\ns3_block = S3.load("BLOCK_NAME")\n```	f	s3
3c62bc9a-694b-4d85-b85a-73687aac52ee	2025-11-10 15:29:44.502486+00	2026-01-25 15:15:52.239777+00	GCS	https://cdn.sanity.io/images/3ugk85nk/production/422d13bb838cf247eb2b2cf229ce6a2e717d601b-256x256.png	https://docs.prefect.io/concepts/filesystems/#gcs	DEPRECATION WARNING:\n\nThis class is deprecated as of March 2024 and will not be available after September 2024.\nIt has been replaced by `GcsBucket` from the `prefect-gcp` package, which offers enhanced functionality\nand better a better user experience.\nStore data as a file on Google Cloud Storage.	Load stored GCS config:\n```python\nfrom prefect.filesystems import GCS\n\ngcs_block = GCS.load("BLOCK_NAME")\n```	f	gcs
196c5e59-718b-4dee-8255-e51337113be3	2025-11-10 15:29:44.538303+00	2026-01-25 15:15:52.258649+00	SMB	https://cdn.sanity.io/images/3ugk85nk/production/3f624663f7beb97d011d011bffd51ecf6c499efc-195x195.png	https://docs.prefect.io/concepts/filesystems/#smb	Store data as a file on a SMB share.	Load stored SMB config:\n\n```python\nfrom prefect.filesystems import SMB\nsmb_block = SMB.load("BLOCK_NAME")\n```	f	smb
17f4cff0-c848-4e3e-bcd5-88da5d2ea263	2025-11-10 15:29:44.559915+00	2026-01-25 15:15:52.267944+00	GitHub	https://cdn.sanity.io/images/3ugk85nk/production/41971cfecfea5f79ff334164f06ecb34d1038dd4-250x250.png	https://docs.prefect.io/concepts/filesystems/#github	DEPRECATION WARNING:\n\n    This class is deprecated as of March 2024 and will not be available after September 2024.\n    It has been replaced by `GitHubRepository` from the `prefect-github` package, which offers\n    enhanced functionality and better a better user experience.\nq\n    Interact with files stored on GitHub repositories.	```python\nfrom prefect.filesystems import GitHub\n\ngithub_block = GitHub.load("BLOCK_NAME")\n```	f	github
e6bea070-5b7b-49a4-9c8c-8e799929ee62	2025-11-10 15:29:44.57632+00	2026-01-25 15:15:52.277293+00	Docker Registry	https://cdn.sanity.io/images/3ugk85nk/production/14a315b79990200db7341e42553e23650b34bb96-250x250.png	https://docs.prefect.io/api-ref/prefect/infrastructure/#prefect.infrastructure.docker.DockerRegistry	DEPRECATION WARNING:\n\nThis class is deprecated as of March 2024 and will not be available after September 2024.\nIt has been replaced by `DockerRegistryCredentials` from the `prefect-docker` package, which\noffers enhanced functionality and better a better user experience.\n\nConnects to a Docker registry.\n\nRequires a Docker Engine to be connectable.	```python\nfrom prefect.infrastructure.container import DockerRegistry\n\ndocker_registry_block = DockerRegistry.load("BLOCK_NAME")\n```	f	docker-registry
8aa11860-cae9-4b42-bced-e99fbd46c373	2025-11-10 15:29:44.593397+00	2026-01-25 15:15:52.287363+00	Docker Container	https://cdn.sanity.io/images/3ugk85nk/production/14a315b79990200db7341e42553e23650b34bb96-250x250.png	https://docs.prefect.io/api-ref/prefect/infrastructure/#prefect.infrastructure.DockerContainer	Runs a command in a container.\n\nRequires a Docker Engine to be connectable. Docker settings will be retrieved from\nthe environment.\n\nClick [here](https://docs.prefect.io/guides/deployment/docker) to see a tutorial.	```python\nfrom prefect.infrastructure.container import DockerContainer\n\ndocker_container_block = DockerContainer.load("BLOCK_NAME")\n```	f	docker-container
0626cd1e-a7c2-4686-8885-ced4b5eceac2	2025-11-10 15:29:44.630009+00	2026-01-25 15:15:52.300846+00	Kubernetes Cluster Config	https://cdn.sanity.io/images/3ugk85nk/production/2d0b896006ad463b49c28aaac14f31e00e32cfab-250x250.png	https://docs.prefect.io/api-ref/prefect/blocks/kubernetes/#prefect.blocks.kubernetes.KubernetesClusterConfig	Stores configuration for interaction with Kubernetes clusters.\n\nSee `from_file` for creation.	Load a saved Kubernetes cluster config:\n```python\nfrom prefect.blocks.kubernetes import KubernetesClusterConfig\n\ncluster_config_block = KubernetesClusterConfig.load("BLOCK_NAME")\n```	f	kubernetes-cluster-config
18a5e907-afc2-4805-ab8b-da4c81cc6edb	2025-11-10 15:29:44.647782+00	2026-01-25 15:15:52.311017+00	Kubernetes Job	https://cdn.sanity.io/images/3ugk85nk/production/2d0b896006ad463b49c28aaac14f31e00e32cfab-250x250.png	https://docs.prefect.io/api-ref/prefect/infrastructure/#prefect.infrastructure.KubernetesJob	Runs a command as a Kubernetes Job.\n\nFor a guided tutorial, see [How to use Kubernetes with Prefect](https://medium.com/the-prefect-blog/how-to-use-kubernetes-with-prefect-419b2e8b8cb2/).\nFor more information, including examples for customizing the resulting manifest, see [`KubernetesJob` infrastructure concepts](https://docs.prefect.io/concepts/infrastructure/#kubernetesjob).	```python\nfrom prefect.infrastructure.kubernetes import KubernetesJob\n\nkubernetes_job_block = KubernetesJob.load("BLOCK_NAME")\n```	f	kubernetes-job
4b49a287-9159-4d7c-ba22-88bb09356b01	2025-11-10 15:29:44.781248+00	2026-01-25 15:15:52.332985+00	Azure Container Instance Credentials	https://cdn.sanity.io/images/3ugk85nk/production/54e3fa7e00197a4fbd1d82ed62494cb58d08c96a-250x250.png	https://prefecthq.github.io/prefect-azure/credentials/#prefect_azure.credentials.AzureContainerInstanceCredentials	Block used to manage Azure Container Instances authentication. Stores Azure Service\nPrincipal authentication data. This block is part of the prefect-azure collection. Install prefect-azure with `pip install prefect-azure` to use this block.	```python\nfrom prefect_azure.credentials import AzureContainerInstanceCredentials\n\nazure_container_instance_credentials_block = AzureContainerInstanceCredentials.load("BLOCK_NAME")\n```	f	azure-container-instance-credentials
d01de82c-ebf0-4b23-8d30-1aafc2670610	2025-11-10 15:29:44.803143+00	2026-01-25 15:15:52.332985+00	dbt CLI BigQuery Target Configs	https://cdn.sanity.io/images/3ugk85nk/production/1f4742f3473da5a9fc873430a803bb739e5e48a6-400x400.png	https://prefecthq.github.io/prefect-dbt/cli/configs/bigquery/#prefect_dbt.cli.configs.bigquery.BigQueryTargetConfigs	dbt CLI target configs containing credentials and settings, specific to BigQuery. This block is part of the prefect-dbt collection. Install prefect-dbt with `pip install prefect-dbt` to use this block.	Load stored BigQueryTargetConfigs.\n```python\nfrom prefect_dbt.cli.configs import BigQueryTargetConfigs\n\nbigquery_target_configs = BigQueryTargetConfigs.load("BLOCK_NAME")\n```\n\nInstantiate BigQueryTargetConfigs.\n```python\nfrom prefect_dbt.cli.configs import BigQueryTargetConfigs\nfrom prefect_gcp.credentials import GcpCredentials\n\ncredentials = GcpCredentials.load("BLOCK-NAME-PLACEHOLDER")\ntarget_configs = BigQueryTargetConfigs(\n    schema="schema",  # also known as dataset\n    credentials=credentials,\n)\n```	f	dbt-cli-bigquery-target-configs
518f9ede-528c-407e-b435-7d4a22a7752f	2025-11-10 15:29:44.809401+00	2026-01-25 15:15:52.332985+00	dbt CLI Postgres Target Configs	https://cdn.sanity.io/images/3ugk85nk/production/1f4742f3473da5a9fc873430a803bb739e5e48a6-400x400.png	https://prefecthq.github.io/prefect-dbt/cli/configs/postgres/#prefect_dbt.cli.configs.postgres.PostgresTargetConfigs	dbt CLI target configs containing credentials and settings specific to Postgres. This block is part of the prefect-dbt collection. Install prefect-dbt with `pip install prefect-dbt` to use this block.	Load stored PostgresTargetConfigs:\n```python\nfrom prefect_dbt.cli.configs import PostgresTargetConfigs\n\npostgres_target_configs = PostgresTargetConfigs.load("BLOCK_NAME")\n```\n\nInstantiate PostgresTargetConfigs with DatabaseCredentials.\n```python\nfrom prefect_dbt.cli.configs import PostgresTargetConfigs\nfrom prefect_sqlalchemy import DatabaseCredentials, SyncDriver\n\ncredentials = DatabaseCredentials(\n    driver=SyncDriver.POSTGRESQL_PSYCOPG2,\n    username="prefect",\n    password="prefect_password",\n    database="postgres",\n    host="host",\n    port=8080\n)\ntarget_configs = PostgresTargetConfigs(credentials=credentials, schema="schema")\n```	f	dbt-cli-postgres-target-configs
e82bceb3-a910-4862-a4fc-47f2531c2aad	2025-11-10 15:29:44.755278+00	2026-01-25 15:15:52.332985+00	AWS Credentials	https://cdn.sanity.io/images/3ugk85nk/production/d74b16fe84ce626345adf235a47008fea2869a60-225x225.png	https://prefecthq.github.io/prefect-aws/credentials/#prefect_aws.credentials.AwsCredentials	Block used to manage authentication with AWS. AWS authentication is\nhandled via the `boto3` module. Refer to the\n[boto3 docs](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/credentials.html)\nfor more info about the possible credential configurations. This block is part of the prefect-aws collection. Install prefect-aws with `pip install prefect-aws` to use this block.	Load stored AWS credentials:\n```python\nfrom prefect_aws import AwsCredentials\n\naws_credentials_block = AwsCredentials.load("BLOCK_NAME")\n```	f	aws-credentials
badae73b-45cc-4d37-b133-3aceeeb9b4c4	2025-11-10 15:29:44.768685+00	2026-01-25 15:15:52.332985+00	MinIO Credentials	https://cdn.sanity.io/images/3ugk85nk/production/676cb17bcbdff601f97e0a02ff8bcb480e91ff40-250x250.png	https://prefecthq.github.io/prefect-aws/credentials/#prefect_aws.credentials.MinIOCredentials	Block used to manage authentication with MinIO. Refer to the MinIO docs: https://docs.min.io/docs/minio-server-configuration-guide.html for more info about the possible credential configurations. This block is part of the prefect-aws collection. Install prefect-aws with `pip install prefect-aws` to use this block.	Load stored MinIO credentials:\n```python\nfrom prefect_aws import MinIOCredentials\n\nminio_credentials_block = MinIOCredentials.load("BLOCK_NAME")\n```	f	minio-credentials
d9c19e52-a0e7-49e6-bda5-2ae3ce2cbae2	2025-11-10 15:29:44.774983+00	2026-01-25 15:15:52.332985+00	Azure Blob Storage Container	https://cdn.sanity.io/images/3ugk85nk/production/54e3fa7e00197a4fbd1d82ed62494cb58d08c96a-250x250.png	https://prefecthq.github.io/prefect-azure/blob_storage/#prefect_azure.blob_storabe.AzureBlobStorageContainer	Represents a container in Azure Blob Storage.\n\nThis class provides methods for downloading and uploading files and folders\nto and from the Azure Blob Storage container. This block is part of the prefect-azure collection. Install prefect-azure with `pip install prefect-azure` to use this block.	```python\nfrom prefect_azure.blob_storage import AzureBlobStorageContainer\n\nazure_blob_storage_container_block = AzureBlobStorageContainer.load("BLOCK_NAME")\n```	f	azure-blob-storage-container
2def6597-968c-4f82-9286-ad251512ec7e	2025-11-10 15:29:44.784369+00	2026-01-25 15:15:52.332985+00	Azure Container Instance Job	https://cdn.sanity.io/images/3ugk85nk/production/54e3fa7e00197a4fbd1d82ed62494cb58d08c96a-250x250.png	https://prefecthq.github.io/prefect-azure/container_instance/#prefect_azure.container_instance.AzureContainerInstanceJob	DEPRECATION WARNING: This block is deprecated along with Agents and all other Infrastructure blocks. It will be removed in `prefect>=3.0.0`. Run tasks using Azure Container Instances. Note this block is experimental. The interface may change without notice. This block is part of the prefect-azure collection. Install prefect-azure with `pip install prefect-azure` to use this block.	```python\nfrom prefect_azure.container_instance import AzureContainerInstanceJob\n\nazure_container_instance_job_block = AzureContainerInstanceJob.load("BLOCK_NAME")\n```	f	azure-container-instance-job
20385df2-5a9a-49d0-a44a-e63d3fdd9d30	2025-11-10 15:29:44.815643+00	2026-01-25 15:15:52.332985+00	dbt CLI Snowflake Target Configs	https://cdn.sanity.io/images/3ugk85nk/production/1f4742f3473da5a9fc873430a803bb739e5e48a6-400x400.png	https://prefecthq.github.io/prefect-dbt/cli/configs/snowflake/#prefect_dbt.cli.configs.snowflake.SnowflakeTargetConfigs	Target configs contain credentials and\nsettings, specific to Snowflake.\nTo find valid keys, head to the [Snowflake Profile](\nhttps://docs.getdbt.com/reference/warehouse-profiles/snowflake-profile)\npage. This block is part of the prefect-dbt collection. Install prefect-dbt with `pip install prefect-dbt` to use this block.	Load stored SnowflakeTargetConfigs:\n```python\nfrom prefect_dbt.cli.configs import SnowflakeTargetConfigs\n\nsnowflake_target_configs = SnowflakeTargetConfigs.load("BLOCK_NAME")\n```\n\nInstantiate SnowflakeTargetConfigs.\n```python\nfrom prefect_dbt.cli.configs import SnowflakeTargetConfigs\nfrom prefect_snowflake.credentials import SnowflakeCredentials\nfrom prefect_snowflake.database import SnowflakeConnector\n\ncredentials = SnowflakeCredentials(\n    user="user",\n    password="password",\n    account="account.region.aws",\n    role="role",\n)\nconnector = SnowflakeConnector(\n    schema="public",\n    database="database",\n    warehouse="warehouse",\n    credentials=credentials,\n)\ntarget_configs = SnowflakeTargetConfigs(\n    connector=connector,\n    extras={"retry_on_database_errors": True},\n)\n```	f	dbt-cli-snowflake-target-configs
72929781-17d9-40df-8f19-1f5cf2baa4cf	2025-11-10 15:29:44.758991+00	2026-01-25 15:15:52.332985+00	AWS Secret	https://cdn.sanity.io/images/3ugk85nk/production/d74b16fe84ce626345adf235a47008fea2869a60-225x225.png	https://prefecthq.github.io/prefect-aws/secrets_manager/#prefect_aws.secrets_manager.AwsSecret	Manages a secret in AWS's Secrets Manager. This block is part of the prefect-aws collection. Install prefect-aws with `pip install prefect-aws` to use this block.	```python\nfrom prefect_aws.secrets_manager import AwsSecret\n\naws_secret_block = AwsSecret.load("BLOCK_NAME")\n```	f	aws-secret
b8ee79c1-434d-4786-9872-0bd9154f3445	2025-11-10 15:29:44.762316+00	2026-01-25 15:15:52.332985+00	ECS Task	https://cdn.sanity.io/images/3ugk85nk/production/d74b16fe84ce626345adf235a47008fea2869a60-225x225.png	https://prefecthq.github.io/prefect-aws/ecs/#prefect_aws.ecs.ECSTask	DEPRECATION WARNING: This block is deprecated along with Agents and all other Infrastructure blocks. It will be removed in `prefect>=3.0.0`. Run a command as an ECS task. This block is part of the prefect-aws collection. Install prefect-aws with `pip install prefect-aws` to use this block.	```python\nfrom prefect_aws.ecs import ECSTask\n\necs_task_block = ECSTask.load("BLOCK_NAME")\n```	f	ecs-task
107cc660-78c3-4c3e-b976-05470e6b0883	2025-11-10 15:29:44.806278+00	2026-01-25 15:15:52.332985+00	dbt CLI Global Configs	https://cdn.sanity.io/images/3ugk85nk/production/1f4742f3473da5a9fc873430a803bb739e5e48a6-400x400.png	https://prefecthq.github.io/prefect-dbt/cli/configs/base/#prefect_dbt.cli.configs.base.GlobalConfigs	Global configs control things like the visual output\nof logs, the manner in which dbt parses your project,\nand what to do when dbt finds a version mismatch\nor a failing model. Docs can be found [here](\nhttps://docs.getdbt.com/reference/global-configs). This block is part of the prefect-dbt collection. Install prefect-dbt with `pip install prefect-dbt` to use this block.	Load stored GlobalConfigs:\n```python\nfrom prefect_dbt.cli.configs import GlobalConfigs\n\ndbt_cli_global_configs = GlobalConfigs.load("BLOCK_NAME")\n```	f	dbt-cli-global-configs
f30608cc-deaf-4017-8915-1787e5589f83	2025-11-10 15:29:44.856452+00	2026-01-25 15:15:52.332985+00	GitHub Credentials	https://cdn.sanity.io/images/3ugk85nk/production/41971cfecfea5f79ff334164f06ecb34d1038dd4-250x250.png	https://prefecthq.github.io/prefect-github/credentials/#prefect_github.credentials.GitHubCredentials	Block used to manage GitHub authentication. This block is part of the prefect-github collection. Install prefect-github with `pip install prefect-github` to use this block.	Load stored GitHub credentials:\n```python\nfrom prefect_github import GitHubCredentials\ngithub_credentials_block = GitHubCredentials.load("BLOCK_NAME")\n```	f	github-credentials
2c10e829-8234-4143-80f2-a9ab5f794e76	2025-11-10 15:29:44.778116+00	2026-01-25 15:15:52.332985+00	Azure Blob Storage Credentials	https://cdn.sanity.io/images/3ugk85nk/production/54e3fa7e00197a4fbd1d82ed62494cb58d08c96a-250x250.png	https://prefecthq.github.io/prefect-azure/credentials/#prefect_azure.credentials.AzureBlobStorageCredentials	Stores credentials for authenticating with Azure Blob Storage. This block is part of the prefect-azure collection. Install prefect-azure with `pip install prefect-azure` to use this block.	Load stored Azure Blob Storage credentials and retrieve a blob service client:\n```python\nfrom prefect_azure import AzureBlobStorageCredentials\n\nazure_credentials_block = AzureBlobStorageCredentials.load("BLOCK_NAME")\n\nblob_service_client = azure_credentials_block.get_blob_client()\n```	f	azure-blob-storage-credentials
286e622d-0b9e-4fad-9c99-a4f2ddbddacc	2025-11-10 15:29:44.357093+00	2026-01-25 15:15:52.14337+00	Custom Webhook	https://cdn.sanity.io/images/3ugk85nk/production/c7247cb359eb6cf276734d4b1fbf00fb8930e89e-250x250.png	https://docs.prefect.io/api-ref/prefect/blocks/notifications/#prefect.blocks.notifications.CustomWebhookNotificationBlock	Enables sending notifications via any custom webhook.\n\nAll nested string param contains `{{key}}` will be substituted with value from context/secrets.\n\nContext values include: `subject`, `body` and `name`.	Load a saved custom webhook and send a message:\n```python\nfrom prefect.blocks.notifications import CustomWebhookNotificationBlock\n\ncustom_webhook_block = CustomWebhookNotificationBlock.load("BLOCK_NAME")\n\ncustom_webhook_block.notify("Hello from Prefect!")\n```	f	custom-webhook
ae892096-ad00-46e6-83d8-83db23b85797	2025-11-10 15:29:43.985462+00	2026-01-25 15:15:52.162119+00	JSON	https://cdn.sanity.io/images/3ugk85nk/production/4fcef2294b6eeb423b1332d1ece5156bf296ff96-48x48.png	https://docs.prefect.io/api-ref/prefect/blocks/system/#prefect.blocks.system.JSON	A block that represents JSON	Load a stored JSON value:\n```python\nfrom prefect.blocks.system import JSON\n\njson_block = JSON.load("BLOCK_NAME")\n```	t	json
a1bf8f7c-6b21-49f5-9647-54cc82660747	2025-11-10 15:29:44.520995+00	2026-01-25 15:15:52.249627+00	Azure	https://cdn.sanity.io/images/3ugk85nk/production/54e3fa7e00197a4fbd1d82ed62494cb58d08c96a-250x250.png	https://docs.prefect.io/concepts/filesystems/#azure	DEPRECATION WARNING:\n\nThis class is deprecated as of March 2024 and will not be available after September 2024.\nIt has been replaced by `AzureBlobStorageContainer` from the `prefect-azure` package, which\noffers enhanced functionality and better a better user experience.\n\nStore data as a file on Azure Datalake and Azure Blob Storage.	Load stored Azure config:\n```python\nfrom prefect.filesystems import Azure\n\naz_block = Azure.load("BLOCK_NAME")\n```	f	azure
4ca24a8e-7af9-4bde-90e2-6c53ba9037fc	2025-11-10 15:29:44.765492+00	2026-01-25 15:15:52.332985+00	Lambda Function	https://cdn.sanity.io/images/3ugk85nk/production/d74b16fe84ce626345adf235a47008fea2869a60-225x225.png	https://prefecthq.github.io/prefect-aws/s3/#prefect_aws.lambda_function.LambdaFunction	Invoke a Lambda function. This block is part of the prefect-aws\ncollection. Install prefect-aws with `pip install prefect-aws` to use this\nblock. This block is part of the prefect-aws collection. Install prefect-aws with `pip install prefect-aws` to use this block.	```python\nfrom prefect_aws.lambda_function import LambdaFunction\n\nlambda_function_block = LambdaFunction.load("BLOCK_NAME")\n```	f	lambda-function
724d142c-551c-49c5-95d9-602a79dd08a8	2025-11-10 15:29:44.78746+00	2026-01-25 15:15:52.332985+00	Azure Cosmos DB Credentials	https://cdn.sanity.io/images/3ugk85nk/production/54e3fa7e00197a4fbd1d82ed62494cb58d08c96a-250x250.png	https://prefecthq.github.io/prefect-azure/credentials/#prefect_azure.credentials.AzureCosmosDbCredentials	Block used to manage Cosmos DB authentication with Azure.\nAzure authentication is handled via the `azure` module through\na connection string. This block is part of the prefect-azure collection. Install prefect-azure with `pip install prefect-azure` to use this block.	Load stored Azure Cosmos DB credentials:\n```python\nfrom prefect_azure import AzureCosmosDbCredentials\nazure_credentials_block = AzureCosmosDbCredentials.load("BLOCK_NAME")\n```	f	azure-cosmos-db-credentials
7c0bc1a2-2364-4826-abaa-a9cce10bafa1	2025-11-10 15:29:44.790584+00	2026-01-25 15:15:52.332985+00	AzureML Credentials	https://cdn.sanity.io/images/3ugk85nk/production/54e3fa7e00197a4fbd1d82ed62494cb58d08c96a-250x250.png	https://prefecthq.github.io/prefect-azure/credentials/#prefect_azure.credentials.AzureMlCredentials	Block used to manage authentication with AzureML. Azure authentication is\nhandled via the `azure` module. This block is part of the prefect-azure collection. Install prefect-azure with `pip install prefect-azure` to use this block.	Load stored AzureML credentials:\n```python\nfrom prefect_azure import AzureMlCredentials\nazure_ml_credentials_block = AzureMlCredentials.load("BLOCK_NAME")\n```	f	azureml-credentials
1e2fc80f-bd6f-48ce-821a-f5ea0ef14445	2025-11-10 15:29:44.771837+00	2026-01-25 15:15:52.332985+00	S3 Bucket	https://cdn.sanity.io/images/3ugk85nk/production/d74b16fe84ce626345adf235a47008fea2869a60-225x225.png	https://prefecthq.github.io/prefect-aws/s3/#prefect_aws.s3.S3Bucket	Block used to store data using AWS S3 or S3-compatible object storage like MinIO. This block is part of the prefect-aws collection. Install prefect-aws with `pip install prefect-aws` to use this block.	```python\nfrom prefect_aws.s3 import S3Bucket\n\ns3_bucket_block = S3Bucket.load("BLOCK_NAME")\n```	f	s3-bucket
1d9bea68-b0da-42db-92cc-fe5316e2955b	2025-11-10 15:29:44.793757+00	2026-01-25 15:15:52.332985+00	BitBucket Credentials	https://cdn.sanity.io/images/3ugk85nk/production/5d729f7355fb6828c4b605268ded9cfafab3ae4f-250x250.png	\N	Store BitBucket credentials to interact with private BitBucket repositories. This block is part of the prefect-bitbucket collection. Install prefect-bitbucket with `pip install prefect-bitbucket` to use this block.	Load stored BitBucket credentials:\n```python\nfrom prefect_bitbucket import BitBucketCredentials\nbitbucket_credentials_block = BitBucketCredentials.load("BLOCK_NAME")\n```	f	bitbucket-credentials
51d69e36-e1f5-4696-aba4-da2840e8e144	2025-11-10 15:29:44.800045+00	2026-01-25 15:15:52.332985+00	Databricks Credentials	https://cdn.sanity.io/images/3ugk85nk/production/ff9a2573c23954bedd27b0f420465a55b1a99dfd-250x250.png	https://prefecthq.github.io/prefect-databricks/credentials/#prefect_databricks.credentials.DatabricksCredentials	Block used to manage Databricks authentication. This block is part of the prefect-databricks collection. Install prefect-databricks with `pip install prefect-databricks` to use this block.	Load stored Databricks credentials:\n```python\nfrom prefect_databricks import DatabricksCredentials\ndatabricks_credentials_block = DatabricksCredentials.load("BLOCK_NAME")\n```	f	databricks-credentials
c7abb882-393a-43cc-b867-359a72a2fa5a	2025-11-10 15:29:44.812533+00	2026-01-25 15:15:52.332985+00	dbt CLI Profile	https://cdn.sanity.io/images/3ugk85nk/production/1f4742f3473da5a9fc873430a803bb739e5e48a6-400x400.png	https://prefecthq.github.io/prefect-dbt/cli/credentials/#prefect_dbt.cli.credentials.DbtCliProfile	Profile for use across dbt CLI tasks and flows. This block is part of the prefect-dbt collection. Install prefect-dbt with `pip install prefect-dbt` to use this block.	Load stored dbt CLI profile:\n```python\nfrom prefect_dbt.cli import DbtCliProfile\ndbt_cli_profile = DbtCliProfile.load("BLOCK_NAME").get_profile()\n```\n\nGet a dbt Snowflake profile from DbtCliProfile by using SnowflakeTargetConfigs:\n```python\nfrom prefect_dbt.cli import DbtCliProfile\nfrom prefect_dbt.cli.configs import SnowflakeTargetConfigs\nfrom prefect_snowflake.credentials import SnowflakeCredentials\nfrom prefect_snowflake.database import SnowflakeConnector\n\ncredentials = SnowflakeCredentials(\n    user="user",\n    password="password",\n    account="account.region.aws",\n    role="role",\n)\nconnector = SnowflakeConnector(\n    schema="public",\n    database="database",\n    warehouse="warehouse",\n    credentials=credentials,\n)\ntarget_configs = SnowflakeTargetConfigs(\n    connector=connector\n)\ndbt_cli_profile = DbtCliProfile(\n    name="jaffle_shop",\n    target="dev",\n    target_configs=target_configs,\n)\nprofile = dbt_cli_profile.get_profile()\n```\n\nGet a dbt Redshift profile from DbtCliProfile by using generic TargetConfigs:\n```python\nfrom prefect_dbt.cli import DbtCliProfile\nfrom prefect_dbt.cli.configs import GlobalConfigs, TargetConfigs\n\ntarget_configs_extras = dict(\n    host="hostname.region.redshift.amazonaws.com",\n    user="username",\n    password="password1",\n    port=5439,\n    dbname="analytics",\n)\ntarget_configs = TargetConfigs(\n    type="redshift",\n    schema="schema",\n    threads=4,\n    extras=target_configs_extras\n)\ndbt_cli_profile = DbtCliProfile(\n    name="jaffle_shop",\n    target="dev",\n    target_configs=target_configs,\n)\nprofile = dbt_cli_profile.get_profile()\n```	f	dbt-cli-profile
2196312a-8f17-4798-beb1-4f4ed1b62f7d	2025-11-10 15:29:44.82506+00	2026-01-25 15:15:52.332985+00	dbt Core Operation	https://cdn.sanity.io/images/3ugk85nk/production/1f4742f3473da5a9fc873430a803bb739e5e48a6-400x400.png	https://prefecthq.github.io/prefect-dbt/cli/commands/#prefect_dbt.cli.commands.DbtCoreOperation	A block representing a dbt operation, containing multiple dbt and shell commands.\n\nFor long-lasting operations, use the trigger method and utilize the block as a\ncontext manager for automatic closure of processes when context is exited.\nIf not, manually call the close method to close processes.\n\nFor short-lasting operations, use the run method. Context is automatically managed\nwith this method. This block is part of the prefect-dbt collection. Install prefect-dbt with `pip install prefect-dbt` to use this block.	Load a configured block.\n```python\nfrom prefect_dbt import DbtCoreOperation\n\ndbt_op = DbtCoreOperation.load("BLOCK_NAME")\n```\n\nExecute short-lasting dbt debug and list with a custom DbtCliProfile.\n```python\nfrom prefect_dbt import DbtCoreOperation, DbtCliProfile\nfrom prefect_dbt.cli.configs import SnowflakeTargetConfigs\nfrom prefect_snowflake import SnowflakeConnector\n\nsnowflake_connector = await SnowflakeConnector.load("snowflake-connector")\ntarget_configs = SnowflakeTargetConfigs(connector=snowflake_connector)\ndbt_cli_profile = DbtCliProfile(\n    name="jaffle_shop",\n    target="dev",\n    target_configs=target_configs,\n)\ndbt_init = DbtCoreOperation(\n    commands=["dbt debug", "dbt list"],\n    dbt_cli_profile=dbt_cli_profile,\n    overwrite_profiles=True\n)\ndbt_init.run()\n```\n\nExecute a longer-lasting dbt run as a context manager.\n```python\nwith DbtCoreOperation(commands=["dbt run"]) as dbt_run:\n    dbt_process = dbt_run.trigger()\n    # do other things\n    dbt_process.wait_for_completion()\n    dbt_output = dbt_process.fetch_result()\n```	f	dbt-core-operation
11d0c5c7-c932-4438-b0b7-38e1365e0505	2025-11-10 15:29:44.796851+00	2026-01-25 15:15:52.332985+00	BitBucket Repository	https://cdn.sanity.io/images/3ugk85nk/production/5d729f7355fb6828c4b605268ded9cfafab3ae4f-250x250.png	\N	Interact with files stored in BitBucket repositories. This block is part of the prefect-bitbucket collection. Install prefect-bitbucket with `pip install prefect-bitbucket` to use this block.	```python\nfrom prefect_bitbucket.repository import BitBucketRepository\n\nbitbucket_repository_block = BitBucketRepository.load("BLOCK_NAME")\n```	f	bitbucket-repository
192b1b04-abd2-4ffb-8e7f-80345ab74be3	2025-11-10 15:29:44.81885+00	2026-01-25 15:15:52.332985+00	dbt CLI Target Configs	https://cdn.sanity.io/images/3ugk85nk/production/1f4742f3473da5a9fc873430a803bb739e5e48a6-400x400.png	https://prefecthq.github.io/prefect-dbt/cli/configs/base/#prefect_dbt.cli.configs.base.TargetConfigs	Target configs contain credentials and\nsettings, specific to the warehouse you're connecting to.\nTo find valid keys, head to the [Available adapters](\nhttps://docs.getdbt.com/docs/available-adapters) page and\nclick the desired adapter's "Profile Setup" hyperlink. This block is part of the prefect-dbt collection. Install prefect-dbt with `pip install prefect-dbt` to use this block.	Load stored TargetConfigs:\n```python\nfrom prefect_dbt.cli.configs import TargetConfigs\n\ndbt_cli_target_configs = TargetConfigs.load("BLOCK_NAME")\n```	f	dbt-cli-target-configs
5202ce30-a9c3-45cd-9927-2104e2158315	2025-11-10 15:29:44.828208+00	2026-01-25 15:15:52.332985+00	Docker Host	https://cdn.sanity.io/images/3ugk85nk/production/14a315b79990200db7341e42553e23650b34bb96-250x250.png	\N	Store settings for interacting with a Docker host. This block is part of the prefect-docker collection. Install prefect-docker with `pip install prefect-docker` to use this block.	Get a Docker Host client.\n```python\nfrom prefect_docker import DockerHost\n\ndocker_host = DockerHost(\nbase_url="tcp://127.0.0.1:1234",\n    max_pool_size=4\n)\nwith docker_host.get_client() as client:\n    ... # Use the client for Docker operations\n```	f	docker-host
947f8696-4017-4048-9bff-87389b842a3f	2025-11-10 15:29:44.831323+00	2026-01-25 15:15:52.332985+00	Docker Registry Credentials	https://cdn.sanity.io/images/3ugk85nk/production/14a315b79990200db7341e42553e23650b34bb96-250x250.png	\N	Store credentials for interacting with a Docker Registry. This block is part of the prefect-docker collection. Install prefect-docker with `pip install prefect-docker` to use this block.	Log into Docker Registry.\n```python\nfrom prefect_docker import DockerHost, DockerRegistryCredentials\n\ndocker_host = DockerHost()\ndocker_registry_credentials = DockerRegistryCredentials(\n    username="my_username",\n    password="my_password",\n    registry_url="registry.hub.docker.com",\n)\nwith docker_host.get_client() as client:\n    docker_registry_credentials.login(client)\n```	f	docker-registry-credentials
8b177061-8118-4f38-9589-7bcd9fe56cbe	2025-11-10 15:29:44.834422+00	2026-01-25 15:15:52.332985+00	Email Server Credentials	https://cdn.sanity.io/images/3ugk85nk/production/82bc6ed16ca42a2252a5512c72233a253b8a58eb-250x250.png	https://prefecthq.github.io/prefect-email/credentials/#prefect_email.credentials.EmailServerCredentials	Block used to manage generic email server authentication.\nIt is recommended you use a\n[Google App Password](https://support.google.com/accounts/answer/185833)\nif you use Gmail. This block is part of the prefect-email collection. Install prefect-email with `pip install prefect-email` to use this block.	Load stored email server credentials:\n```python\nfrom prefect_email import EmailServerCredentials\nemail_credentials_block = EmailServerCredentials.load("BLOCK_NAME")\n```	f	email-server-credentials
8489af94-7ba8-4e6a-bbb3-638218e4d952	2025-11-10 15:29:44.837586+00	2026-01-25 15:15:52.332985+00	BigQuery Warehouse	https://cdn.sanity.io/images/3ugk85nk/production/10424e311932e31c477ac2b9ef3d53cefbaad708-250x250.png	https://prefecthq.github.io/prefect-gcp/bigquery/#prefect_gcp.bigquery.BigQueryWarehouse	A block for querying a database with BigQuery.\n\nUpon instantiating, a connection to BigQuery is established\nand maintained for the life of the object until the close method is called.\n\nIt is recommended to use this block as a context manager, which will automatically\nclose the connection and its cursors when the context is exited.\n\nIt is also recommended that this block is loaded and consumed within a single task\nor flow because if the block is passed across separate tasks and flows,\nthe state of the block's connection and cursor could be lost. This block is part of the prefect-gcp collection. Install prefect-gcp with `pip install prefect-gcp` to use this block.	```python\nfrom prefect_gcp.bigquery import BigQueryWarehouse\n\nbigquery_warehouse_block = BigQueryWarehouse.load("BLOCK_NAME")\n```	f	bigquery-warehouse
4817e94d-e90f-4489-b87b-a5e4595f3e92	2025-11-10 15:29:44.843955+00	2026-01-25 15:15:52.332985+00	GCP Credentials	https://cdn.sanity.io/images/3ugk85nk/production/10424e311932e31c477ac2b9ef3d53cefbaad708-250x250.png	https://prefecthq.github.io/prefect-gcp/credentials/#prefect_gcp.credentials.GcpCredentials	Block used to manage authentication with GCP. Google authentication is\nhandled via the `google.oauth2` module or through the CLI.\nSpecify either one of service `account_file` or `service_account_info`; if both\nare not specified, the client will try to detect the credentials following Google's\n[Application Default Credentials](https://cloud.google.com/docs/authentication/application-default-credentials).\nSee Google's [Authentication documentation](https://cloud.google.com/docs/authentication#service-accounts)\nfor details on inference and recommended authentication patterns. This block is part of the prefect-gcp collection. Install prefect-gcp with `pip install prefect-gcp` to use this block.	Load GCP credentials stored in a `GCP Credentials` Block:\n```python\nfrom prefect_gcp import GcpCredentials\ngcp_credentials_block = GcpCredentials.load("BLOCK_NAME")\n```	f	gcp-credentials
af37262f-ba54-4e34-b45c-4ea570e9368f	2025-11-10 15:29:44.847099+00	2026-01-25 15:15:52.332985+00	GcpSecret	https://cdn.sanity.io/images/3ugk85nk/production/10424e311932e31c477ac2b9ef3d53cefbaad708-250x250.png	https://prefecthq.github.io/prefect-gcp/secret_manager/#prefect_gcp.secret_manager.GcpSecret	Manages a secret in Google Cloud Platform's Secret Manager. This block is part of the prefect-gcp collection. Install prefect-gcp with `pip install prefect-gcp` to use this block.	```python\nfrom prefect_gcp.secret_manager import GcpSecret\n\ngcpsecret_block = GcpSecret.load("BLOCK_NAME")\n```	f	gcpsecret
3cd1fddb-bcdc-4238-a302-889f80715ad9	2025-11-10 15:29:44.821922+00	2026-01-25 15:15:52.332985+00	dbt Cloud Credentials	https://cdn.sanity.io/images/3ugk85nk/production/1f4742f3473da5a9fc873430a803bb739e5e48a6-400x400.png	https://prefecthq.github.io/prefect-dbt/cloud/credentials/#prefect_dbt.cloud.credentials.DbtCloudCredentials	Credentials block for credential use across dbt Cloud tasks and flows. This block is part of the prefect-dbt collection. Install prefect-dbt with `pip install prefect-dbt` to use this block.	Load stored dbt Cloud credentials:\n```python\nfrom prefect_dbt.cloud import DbtCloudCredentials\n\ndbt_cloud_credentials = DbtCloudCredentials.load("BLOCK_NAME")\n```\n\nUse DbtCloudCredentials instance to trigger a job run:\n```python\nfrom prefect_dbt.cloud import DbtCloudCredentials\n\ncredentials = DbtCloudCredentials(api_key="my_api_key", account_id=123456789)\n\nasync with dbt_cloud_credentials.get_administrative_client() as client:\n    client.trigger_job_run(job_id=1)\n```\n\nLoad saved dbt Cloud credentials within a flow:\n```python\nfrom prefect import flow\n\nfrom prefect_dbt.cloud import DbtCloudCredentials\nfrom prefect_dbt.cloud.jobs import trigger_dbt_cloud_job_run\n\n\n@flow\ndef trigger_dbt_cloud_job_run_flow():\n    credentials = DbtCloudCredentials.load("my-dbt-credentials")\n    trigger_dbt_cloud_job_run(dbt_cloud_credentials=credentials, job_id=1)\n\ntrigger_dbt_cloud_job_run_flow()\n```	f	dbt-cloud-credentials
0d62d397-8240-4c54-b2b4-623d028d6ab1	2025-11-10 15:29:44.85022+00	2026-01-25 15:15:52.332985+00	GCS Bucket	https://cdn.sanity.io/images/3ugk85nk/production/10424e311932e31c477ac2b9ef3d53cefbaad708-250x250.png	https://prefecthq.github.io/prefect-gcp/cloud_storage/#prefect_gcp.cloud_storage.GcsBucket	Block used to store data using GCP Cloud Storage Buckets.\n\nNote! `GcsBucket` in `prefect-gcp` is a unique block, separate from `GCS`\nin core Prefect. `GcsBucket` does not use `gcsfs` under the hood,\ninstead using the `google-cloud-storage` package, and offers more configuration\nand functionality. This block is part of the prefect-gcp collection. Install prefect-gcp with `pip install prefect-gcp` to use this block.	Load stored GCP Cloud Storage Bucket:\n```python\nfrom prefect_gcp.cloud_storage import GcsBucket\ngcp_cloud_storage_bucket_block = GcsBucket.load("BLOCK_NAME")\n```	f	gcs-bucket
d2176e39-c02f-470d-96bd-de4a775db763	2025-11-10 15:29:44.853352+00	2026-01-25 15:15:52.332985+00	Vertex AI Custom Training Job	https://cdn.sanity.io/images/3ugk85nk/production/10424e311932e31c477ac2b9ef3d53cefbaad708-250x250.png	https://prefecthq.github.io/prefect-gcp/aiplatform/#prefect_gcp.aiplatform.VertexAICustomTrainingJob	DEPRECATION WARNING: This block is deprecated along with Agents and all other Infrastructure blocks. It will be removed in `prefect>=3.0.0`. Infrastructure block used to run Vertex AI custom training jobs. This block is part of the prefect-gcp collection. Install prefect-gcp with `pip install prefect-gcp` to use this block.	```python\nfrom prefect_gcp.aiplatform import VertexAICustomTrainingJob\n\nvertex_ai_custom_training_job_block = VertexAICustomTrainingJob.load("BLOCK_NAME")\n```	f	vertex-ai-custom-training-job
807b93b0-9c06-41ec-a70c-ea6f09d70d71	2025-11-10 15:29:44.862673+00	2026-01-25 15:15:52.332985+00	GitLab Credentials	https://cdn.sanity.io/images/3ugk85nk/production/a5db0f07a1bb4390f0e1cda9f7ef9091d89633b9-250x250.png	\N	Store a GitLab personal access token to interact with private GitLab\nrepositories. This block is part of the prefect-gitlab collection. Install prefect-gitlab with `pip install prefect-gitlab` to use this block.	Load stored GitLab credentials:\n```python\nfrom prefect_gitlab import GitLabCredentials\ngitlab_credentials_block = GitLabCredentials.load("BLOCK_NAME")\n```	f	gitlab-credentials
879820a4-bd7b-4a17-851e-ec28288e4578	2025-11-10 15:29:44.865751+00	2026-01-25 15:15:52.332985+00	GitLab Repository	https://cdn.sanity.io/images/3ugk85nk/production/a5db0f07a1bb4390f0e1cda9f7ef9091d89633b9-250x250.png	\N	Interact with files stored in GitLab repositories. This block is part of the prefect-gitlab collection. Install prefect-gitlab with `pip install prefect-gitlab` to use this block.	```python\nfrom prefect_gitlab.repositories import GitLabRepository\n\ngitlab_repository_block = GitLabRepository.load("BLOCK_NAME")\n```	f	gitlab-repository
dd83a224-2277-4759-ba9b-490e3641e6a5	2025-11-10 15:29:44.884526+00	2026-01-25 15:15:52.332985+00	Database Credentials	https://cdn.sanity.io/images/3ugk85nk/production/fb3f4debabcda1c5a3aeea4f5b3f94c28845e23e-250x250.png	https://prefecthq.github.io/prefect-sqlalchemy/credentials/#prefect_sqlalchemy.credentials.DatabaseCredentials	Block used to manage authentication with a database. This block is part of the prefect-sqlalchemy collection. Install prefect-sqlalchemy with `pip install prefect-sqlalchemy` to use this block.	Load stored database credentials:\n```python\nfrom prefect_sqlalchemy import DatabaseCredentials\ndatabase_block = DatabaseCredentials.load("BLOCK_NAME")\n```	f	database-credentials
26e2a9b6-d402-4582-96b5-2e830228705f	2025-11-10 15:29:44.887626+00	2026-01-25 15:15:52.332985+00	SQLAlchemy Connector	https://cdn.sanity.io/images/3ugk85nk/production/3c7dff04f70aaf4528e184a3b028f9e40b98d68c-250x250.png	https://prefecthq.github.io/prefect-sqlalchemy/database/#prefect_sqlalchemy.database.SqlAlchemyConnector	Block used to manage authentication with a database.\n\nUpon instantiating, an engine is created and maintained for the life of\nthe object until the close method is called.\n\nIt is recommended to use this block as a context manager, which will automatically\nclose the engine and its connections when the context is exited.\n\nIt is also recommended that this block is loaded and consumed within a single task\nor flow because if the block is passed across separate tasks and flows,\nthe state of the block's connection and cursor could be lost. This block is part of the prefect-sqlalchemy collection. Install prefect-sqlalchemy with `pip install prefect-sqlalchemy` to use this block.	Load stored database credentials and use in context manager:\n```python\nfrom prefect_sqlalchemy import SqlAlchemyConnector\n\ndatabase_block = SqlAlchemyConnector.load("BLOCK_NAME")\nwith database_block:\n    ...\n```\n\nCreate table named customers and insert values; then fetch the first 10 rows.\n```python\nfrom prefect_sqlalchemy import (\n    SqlAlchemyConnector, SyncDriver, ConnectionComponents\n)\n\nwith SqlAlchemyConnector(\n    connection_info=ConnectionComponents(\n        driver=SyncDriver.SQLITE_PYSQLITE,\n        database="prefect.db"\n    )\n) as database:\n    database.execute(\n        "CREATE TABLE IF NOT EXISTS customers (name varchar, address varchar);",\n    )\n    for i in range(1, 42):\n        database.execute(\n            "INSERT INTO customers (name, address) VALUES (:name, :address);",\n            parameters={"name": "Marvin", "address": f"Highway {i}"},\n        )\n    results = database.fetch_many(\n        "SELECT * FROM customers WHERE name = :name;",\n        parameters={"name": "Marvin"},\n        size=10\n    )\nprint(results)\n```	f	sqlalchemy-connector
84db1b6e-2ea9-44b0-bb6c-5e28c122296c	2025-11-10 15:29:44.840721+00	2026-01-25 15:15:52.332985+00	GCP Cloud Run Job	https://cdn.sanity.io/images/3ugk85nk/production/10424e311932e31c477ac2b9ef3d53cefbaad708-250x250.png	https://prefecthq.github.io/prefect-gcp/cloud_run/#prefect_gcp.cloud_run.CloudRunJob	DEPRECATION WARNING: This block is deprecated along with Agents and all other Infrastructure blocks. It will be removed in `prefect>=3.0.0`. Infrastructure block used to run GCP Cloud Run Jobs. Note this block is experimental. The interface may change without notice. This block is part of the prefect-gcp collection. Install prefect-gcp with `pip install prefect-gcp` to use this block.	```python\nfrom prefect_gcp.cloud_run import CloudRunJob\n\ncloud_run_job_block = CloudRunJob.load("BLOCK_NAME")\n```	f	cloud-run-job
c2ba79ae-ffb0-45bb-8319-899365c3716c	2025-11-10 15:29:44.859568+00	2026-01-25 15:15:52.332985+00	GitHub Repository	https://cdn.sanity.io/images/3ugk85nk/production/41971cfecfea5f79ff334164f06ecb34d1038dd4-250x250.png	https://prefecthq.github.io/prefect-github/repository/#prefect_github.repository.GitHubRepository	Interact with files stored on GitHub repositories. This block is part of the prefect-github collection. Install prefect-github with `pip install prefect-github` to use this block.	```python\nfrom prefect_github.repository import GitHubRepository\n\ngithub_repository_block = GitHubRepository.load("BLOCK_NAME")\n```	f	github-repository
280264f0-14f8-45cc-806e-3e319debffe9	2025-11-10 15:29:44.868836+00	2026-01-25 15:15:52.332985+00	Kubernetes Credentials	https://cdn.sanity.io/images/3ugk85nk/production/2d0b896006ad463b49c28aaac14f31e00e32cfab-250x250.png	https://prefecthq.github.io/prefect-kubernetes/credentials/#prefect_kubernetes.credentials.KubernetesCredentials	Credentials block for generating configured Kubernetes API clients. This block is part of the prefect-kubernetes collection. Install prefect-kubernetes with `pip install prefect-kubernetes` to use this block.	Load stored Kubernetes credentials:\n```python\nfrom prefect_kubernetes.credentials import KubernetesCredentials\n\nkubernetes_credentials = KubernetesCredentials.load("BLOCK_NAME")\n```	f	kubernetes-credentials
adff8102-8bb1-4f2e-abd6-5e27e2660f56	2025-11-10 15:29:44.881471+00	2026-01-25 15:15:52.332985+00	Snowflake Credentials	https://cdn.sanity.io/images/3ugk85nk/production/bd359de0b4be76c2254bd329fe3a267a1a3879c2-250x250.png	https://prefecthq.github.io/prefect-snowflake/credentials/#prefect_snowflake.credentials.SnowflakeCredentials	Block used to manage authentication with Snowflake. This block is part of the prefect-snowflake collection. Install prefect-snowflake with `pip install prefect-snowflake` to use this block.	Load stored Snowflake credentials:\n```python\nfrom prefect_snowflake import SnowflakeCredentials\n\nsnowflake_credentials_block = SnowflakeCredentials.load("BLOCK_NAME")\n```	f	snowflake-credentials
e97da1e9-1787-4113-a639-24570bfdb7a4	2025-11-10 15:29:44.871943+00	2026-01-25 15:15:52.332985+00	Shell Operation	https://cdn.sanity.io/images/3ugk85nk/production/0b47a017e1b40381de770c17647c49cdf6388d1c-250x250.png	https://prefecthq.github.io/prefect-shell/commands/#prefect_shell.commands.ShellOperation	A block representing a shell operation, containing multiple commands.\n\nFor long-lasting operations, use the trigger method and utilize the block as a\ncontext manager for automatic closure of processes when context is exited.\nIf not, manually call the close method to close processes.\n\nFor short-lasting operations, use the run method. Context is automatically managed\nwith this method. This block is part of the prefect-shell collection. Install prefect-shell with `pip install prefect-shell` to use this block.	Load a configured block:\n```python\nfrom prefect_shell import ShellOperation\n\nshell_operation = ShellOperation.load("BLOCK_NAME")\n```	f	shell-operation
beef1dec-090c-4b1d-965f-9d52c4f46695	2025-11-10 15:29:44.875154+00	2026-01-25 15:15:52.332985+00	Slack Credentials	https://cdn.sanity.io/images/3ugk85nk/production/c1965ecbf8704ee1ea20d77786de9a41ce1087d1-500x500.png	https://prefecthq.github.io/prefect-slack/credentials/#prefect_slack.credentials.SlackCredentials	Block holding Slack credentials for use in tasks and flows. This block is part of the prefect-slack collection. Install prefect-slack with `pip install prefect-slack` to use this block.	Load stored Slack credentials:\n```python\nfrom prefect_slack import SlackCredentials\nslack_credentials_block = SlackCredentials.load("BLOCK_NAME")\n```\n\nGet a Slack client:\n```python\nfrom prefect_slack import SlackCredentials\nslack_credentials_block = SlackCredentials.load("BLOCK_NAME")\nclient = slack_credentials_block.get_client()\n```	f	slack-credentials
23d7c017-9d6a-4544-aa2e-0290ba45a6d3	2025-11-10 15:29:44.8783+00	2026-01-25 15:15:52.332985+00	Snowflake Connector	https://cdn.sanity.io/images/3ugk85nk/production/bd359de0b4be76c2254bd329fe3a267a1a3879c2-250x250.png	https://prefecthq.github.io/prefect-snowflake/database/#prefect_snowflake.database.SnowflakeConnector	Perform data operations against a Snowflake database. This block is part of the prefect-snowflake collection. Install prefect-snowflake with `pip install prefect-snowflake` to use this block.	Load stored Snowflake connector as a context manager:\n```python\nfrom prefect_snowflake.database import SnowflakeConnector\n\nsnowflake_connector = SnowflakeConnector.load("BLOCK_NAME"):\n```\n\nInsert data into database and fetch results.\n```python\nfrom prefect_snowflake.database import SnowflakeConnector\n\nwith SnowflakeConnector.load("BLOCK_NAME") as conn:\n    conn.execute(\n        "CREATE TABLE IF NOT EXISTS customers (name varchar, address varchar);"\n    )\n    conn.execute_many(\n        "INSERT INTO customers (name, address) VALUES (%(name)s, %(address)s);",\n        seq_of_parameters=[\n            {"name": "Ford", "address": "Highway 42"},\n            {"name": "Unknown", "address": "Space"},\n            {"name": "Me", "address": "Myway 88"},\n        ],\n    )\n    results = conn.fetch_all(\n        "SELECT * FROM customers WHERE address = %(address)s",\n        parameters={"address": "Space"}\n    )\n    print(results)\n```	f	snowflake-connector
\.


--
-- Data for Name: composite_trigger_child_firing; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.composite_trigger_child_firing (automation_id, parent_trigger_id, child_trigger_id, child_firing_id, child_fired_at, child_firing, id, created, updated) FROM stdin;
\.


--
-- Data for Name: concurrency_limit; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.concurrency_limit (id, created, updated, tag, concurrency_limit, active_slots) FROM stdin;
\.


--
-- Data for Name: concurrency_limit_v2; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.concurrency_limit_v2 (id, created, updated, active, name, "limit", active_slots, denied_slots, slot_decay_per_second, avg_slot_occupancy_seconds) FROM stdin;
\.


--
-- Data for Name: configuration; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.configuration (id, created, updated, key, value) FROM stdin;
1b5f2ff5-a065-4285-b2e2-ed07f762fcc8	2025-11-12 11:45:04.106227+00	2025-11-12 11:45:04.106254+00	ENCRYPTION_KEY	{"fernet_key": "2mZvokbKJQzVjWndQDz3wsQZXBYvh-iZVawm9TqQQOU="}
\.


--
-- Data for Name: csrf_token; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.csrf_token (token, client, expiration, id, created, updated) FROM stdin;
\.


--
-- Data for Name: deployment; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.deployment (id, created, updated, name, schedule, is_schedule_active, tags, parameters, flow_data, flow_id, infrastructure_document_id, description, manifest_path, parameter_openapi_schema, storage_document_id, version, infra_overrides, path, entrypoint, work_queue_name, created_by, updated_by, work_queue_id, pull_steps, enforce_parameter_schema, last_polled, paused, status) FROM stdin;
d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	2025-11-12 11:45:04.313971+00	2025-11-12 11:47:44.925259+00	daily-collection	\N	t	["dataset-management", "daily", "collection"]	{}	\N	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	23aa794b-4a92-434f-b10f-ec6fa8d17348	Daily collection of new predictions for ML training	\N	{"type": "object", "title": "Parameters", "properties": {"since_date": {"anyOf": [{"type": "string"}, {"type": "null"}], "title": "since_date", "default": null, "position": 1, "description": "Fetch predictions since this date, defaults to yesterday"}, "collection_date": {"anyOf": [{"type": "string"}, {"type": "null"}], "title": "collection_date", "default": null, "position": 0, "description": "Collection date (YYYY-MM-DD), defaults to today"}}}	\N	1.0.0	{}	/app/automl	flows/dataset_management.py:daily_data_collection_flow	default	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	\N	f	\N	f	NOT_READY
0aaf4a21-55de-47cb-952b-b2fcf5482b42	2025-11-12 11:45:04.78268+00	2025-11-12 11:47:45.291859+00	monthly-creation	\N	t	["dataset-management", "monthly", "creation"]	{}	\N	0d6089bc-ec9a-42ec-b0f0-008a42cb945d	06f61094-d1c3-4990-b0af-3aecc56293ad	Monthly creation of verified and full training datasets	\N	{"type": "object", "title": "Parameters", "properties": {"year": {"anyOf": [{"type": "integer"}, {"type": "null"}], "title": "year", "default": null, "position": 0, "description": "Year (YYYY), defaults to previous month"}, "month": {"anyOf": [{"type": "integer"}, {"type": "null"}], "title": "month", "default": null, "position": 1, "description": "Month (1-12), defaults to previous month"}}}	\N	1.0.0	{}	/app/automl	flows/dataset_management.py:monthly_dataset_creation_flow	default	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	\N	f	\N	f	NOT_READY
ec838372-322b-4053-b7da-c080a35d10f6	2025-11-12 11:47:45.769861+00	2025-11-12 11:47:45.763125+00	monthly-model-update	\N	t	["model-training", "monthly", "orchestrator"]	{}	\N	5256a040-1daf-409c-a08f-0a7b90582957	efd456dc-5023-40b4-8a75-a793be43a0b8	Monthly model training, comparison, and deployment orchestration	\N	{"type": "object", "title": "Parameters", "properties": {"year": {"anyOf": [{"type": "integer"}, {"type": "null"}], "title": "year", "default": null, "position": 0, "description": "Dataset year (default: current year)"}, "month": {"anyOf": [{"type": "integer"}, {"type": "null"}], "title": "month", "default": null, "position": 1, "description": "Dataset month (default: current month)"}, "quick_test": {"type": "boolean", "title": "quick_test", "default": false, "position": 6, "description": "If True, skip actual training and use fake data for testing UI"}, "train_full": {"type": "boolean", "title": "train_full", "default": true, "position": 5, "description": "Whether to train on full dataset"}, "training_mode": {"type": "string", "title": "training_mode", "default": "local", "position": 2, "description": "'local' or 'yandex_cloud'"}, "train_verified": {"type": "boolean", "title": "train_verified", "default": true, "position": 4, "description": "Whether to train on verified dataset"}, "validate_datasets": {"type": "boolean", "title": "validate_datasets", "default": true, "position": 3, "description": "Whether to validate datasets before training"}}}	\N	1.0.0	{}	/app/automl	flows/model_update_orchestrator.py:update_model_flow	default	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	\N	f	\N	f	NOT_READY
\.


--
-- Data for Name: deployment_schedule; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.deployment_schedule (id, created, updated, schedule, active, deployment_id, max_active_runs, max_scheduled_runs, catchup) FROM stdin;
6dfb2a28-4e24-49f1-899a-91346cfa9a65	2025-11-12 11:47:44.958824+00	2025-11-12 11:47:44.958846+00	{"cron": "0 0 * * *", "day_or": true, "timezone": "UTC"}	t	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	\N	f
28f38051-c53c-4d17-9af5-328a5c67a1a1	2025-11-12 11:47:45.312988+00	2025-11-12 11:47:45.313008+00	{"cron": "0 1 1 * *", "day_or": true, "timezone": "UTC"}	t	0aaf4a21-55de-47cb-952b-b2fcf5482b42	\N	\N	f
ad94528c-a8c5-4f0a-9a92-e5656ce461ba	2025-11-12 11:47:45.782974+00	2025-11-12 11:47:45.782996+00	{"cron": "0 2 2 * *", "day_or": true, "timezone": "UTC"}	t	ec838372-322b-4053-b7da-c080a35d10f6	\N	\N	f
\.


--
-- Data for Name: event_resources; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.event_resources (occurred, resource_id, resource_role, resource, event_id, id, created, updated) FROM stdin;
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.events (occurred, event, resource_id, resource, related_resource_ids, related, payload, received, recorded, follows, id, created, updated) FROM stdin;
\.


--
-- Data for Name: flow; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.flow (id, created, updated, name, tags) FROM stdin;
eb63db8a-d4d1-47d7-b3c7-467722ee05a8	2025-11-12 11:45:03.85761+00	2025-11-12 11:45:03.857636+00	daily_data_collection	[]
0d6089bc-ec9a-42ec-b0f0-008a42cb945d	2025-11-12 11:45:04.556235+00	2025-11-12 11:45:04.55626+00	monthly_dataset_creation	[]
5256a040-1daf-409c-a08f-0a7b90582957	2025-11-12 11:47:45.519779+00	2025-11-12 11:47:45.519806+00	update_model_orchestrator	[]
\.


--
-- Data for Name: flow_run; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.flow_run (id, created, updated, name, state_type, run_count, expected_start_time, next_scheduled_start_time, start_time, end_time, total_run_time, flow_version, parameters, idempotency_key, context, empirical_policy, tags, auto_scheduled, flow_id, deployment_id, parent_task_run_id, state_id, state_name, infrastructure_document_id, work_queue_name, state_timestamp, created_by, infrastructure_pid, work_queue_id, job_variables, deployment_version) FROM stdin;
f7965b9c-96b2-4635-af3d-7d5056cdae70	2025-11-12 11:47:49.102012+00	2026-01-01 01:00:15.818055+00	busy-spider	SCHEDULED	0	2026-01-01 01:00:00+00	2026-01-01 01:00:00+00	\N	\N	00:00:00	\N	{}	scheduled 0aaf4a21-55de-47cb-952b-b2fcf5482b42 2026-01-01T01:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "monthly", "creation"]	t	0d6089bc-ec9a-42ec-b0f0-008a42cb945d	0aaf4a21-55de-47cb-952b-b2fcf5482b42	\N	289c7995-f533-4a9a-a75e-806bc9d15cb1	Late	06f61094-d1c3-4990-b0af-3aecc56293ad	default	2026-01-01 01:00:15.819328+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
55e8bebd-5b0b-4c6d-8105-b22a9cb3e405	2025-11-12 11:47:49.101935+00	2025-12-01 01:00:18.335986+00	mysterious-hummingbird	SCHEDULED	0	2025-12-01 01:00:00+00	2025-12-01 01:00:00+00	\N	\N	00:00:00	\N	{}	scheduled 0aaf4a21-55de-47cb-952b-b2fcf5482b42 2025-12-01T01:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "monthly", "creation"]	t	0d6089bc-ec9a-42ec-b0f0-008a42cb945d	0aaf4a21-55de-47cb-952b-b2fcf5482b42	\N	f3cfe6f0-c0cd-4c95-980b-6d9c666228be	Late	06f61094-d1c3-4990-b0af-3aecc56293ad	default	2025-12-01 01:00:18.337791+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
843db310-214d-45ff-b7b1-5322e5eba0eb	2025-11-29 00:00:36.097236+00	2025-12-02 00:00:15.591197+00	ochre-armadillo	SCHEDULED	0	2025-12-02 00:00:00+00	2025-12-02 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-02T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	848d593d-e6b9-489f-bfeb-6e8f4b49234a	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-02 00:00:15.592332+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
2b65ad67-5bb3-4ff2-bcb0-1257eaba7dfd	2025-12-02 02:00:42.145482+00	2025-12-02 02:00:42.146773+00	apricot-mustang	SCHEDULED	0	2026-03-02 02:00:00+00	2026-03-02 02:00:00+00	\N	\N	00:00:00	\N	{}	scheduled ec838372-322b-4053-b7da-c080a35d10f6 2026-03-02T02:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "model-training", "monthly", "orchestrator"]	t	5256a040-1daf-409c-a08f-0a7b90582957	ec838372-322b-4053-b7da-c080a35d10f6	\N	9f5fa9f2-831a-4bca-8b34-fa82af4b1b29	Scheduled	efd456dc-5023-40b4-8a75-a793be43a0b8	default	\N	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
d6ce72e1-9ad5-4862-bf1d-dd466cee59d3	2025-12-04 00:00:45.731339+00	2025-12-07 00:00:16.024789+00	just-parrot	SCHEDULED	0	2025-12-07 00:00:00+00	2025-12-07 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-07T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	db82ad12-ffe0-49f4-9f02-37fa241bec7e	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-07 00:00:16.02702+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
77703632-e8d8-4ea0-9f4e-25e9c17f6727	2025-12-10 00:00:56.811153+00	2025-12-13 00:00:16.977101+00	determined-seahorse	SCHEDULED	0	2025-12-13 00:00:00+00	2025-12-13 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-13T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	f5e7f300-dea4-45ae-a679-479537faa3d0	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-13 00:00:16.978197+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
624992be-c52f-43b8-99a5-3651db4cad6d	2025-12-11 00:00:58.674236+00	2025-12-14 00:00:15.391888+00	aloof-scallop	SCHEDULED	0	2025-12-14 00:00:00+00	2025-12-14 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-14T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	234d0c49-436b-476d-bf70-bbc80d8f06b7	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-14 00:00:15.393869+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
36a5863e-1a41-4732-b939-7eb2daca5744	2025-12-13 00:00:02.518005+00	2025-12-16 00:00:17.4412+00	defiant-markhor	SCHEDULED	0	2025-12-16 00:00:00+00	2025-12-16 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-16T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	d1091caf-0dea-45b8-9171-2c3d65d97157	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-16 00:00:17.442948+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
c93a16e1-ffb3-4a11-966f-a61aef7a061b	2025-11-12 11:47:49.102064+00	2025-11-12 11:47:49.105914+00	tremendous-condor	SCHEDULED	0	2026-02-01 01:00:00+00	2026-02-01 01:00:00+00	\N	\N	00:00:00	\N	{}	scheduled 0aaf4a21-55de-47cb-952b-b2fcf5482b42 2026-02-01T01:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "monthly", "creation"]	t	0d6089bc-ec9a-42ec-b0f0-008a42cb945d	0aaf4a21-55de-47cb-952b-b2fcf5482b42	\N	2858f2e5-a80d-45b3-a488-3e5db0b745b9	Scheduled	06f61094-d1c3-4990-b0af-3aecc56293ad	default	\N	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
ba30c6f1-004c-45e1-b5bc-a07461485d96	2025-11-12 11:47:49.102114+00	2025-11-13 00:00:15.915774+00	sophisticated-mayfly	SCHEDULED	0	2025-11-13 00:00:00+00	2025-11-13 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-13T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	768fb0ac-a0c1-4553-b4c8-b5d12efb53eb	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-13 00:00:15.917094+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
6723ff3c-d5db-4dd9-9091-bd57941ac8ca	2025-11-12 11:47:49.102168+00	2025-11-14 00:00:19.406206+00	nickel-teal	SCHEDULED	0	2025-11-14 00:00:00+00	2025-11-14 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-14T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	c2221a74-1bac-47d8-96c7-cb64d2af77ce	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-14 00:00:19.407704+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
b09071db-7494-45c9-aa14-03892847b9dd	2025-12-16 00:00:08.336964+00	2025-12-19 00:00:15.628074+00	eminent-kagu	SCHEDULED	0	2025-12-19 00:00:00+00	2025-12-19 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-19T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	4eeeeee5-b2bf-4d53-8dc2-16edb8a97675	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-19 00:00:15.62939+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
a96f76de-aab7-4969-a3fd-dd76b46784b8	2025-12-18 00:00:11.987042+00	2025-12-21 00:00:18.193628+00	solid-swine	SCHEDULED	0	2025-12-21 00:00:00+00	2025-12-21 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-21T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	31d85649-1586-4966-8d4d-2f491d41f8e1	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-21 00:00:18.195514+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
ca26ca1c-b7ee-46b6-acd5-c91fa3b16c0c	2025-11-12 11:47:49.103404+00	2026-01-02 02:00:17.557096+00	glistening-dugong	SCHEDULED	0	2026-01-02 02:00:00+00	2026-01-02 02:00:00+00	\N	\N	00:00:00	\N	{}	scheduled ec838372-322b-4053-b7da-c080a35d10f6 2026-01-02T02:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "model-training", "monthly", "orchestrator"]	t	5256a040-1daf-409c-a08f-0a7b90582957	ec838372-322b-4053-b7da-c080a35d10f6	\N	249c2ea5-95aa-443f-83fc-ab249c476814	Late	efd456dc-5023-40b4-8a75-a793be43a0b8	default	2026-01-02 02:00:17.55828+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
c2a69edb-e6f5-4630-80ff-b381136b2cab	2025-11-12 11:47:49.103467+00	2025-11-12 11:47:49.105914+00	wine-robin	SCHEDULED	0	2026-02-02 02:00:00+00	2026-02-02 02:00:00+00	\N	\N	00:00:00	\N	{}	scheduled ec838372-322b-4053-b7da-c080a35d10f6 2026-02-02T02:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "model-training", "monthly", "orchestrator"]	t	5256a040-1daf-409c-a08f-0a7b90582957	ec838372-322b-4053-b7da-c080a35d10f6	\N	4b10910c-628d-4d62-a543-58e1d95a5e14	Scheduled	efd456dc-5023-40b4-8a75-a793be43a0b8	default	\N	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
17073ad8-747b-44fd-b4b1-603a144b32f8	2025-11-12 11:47:49.102267+00	2025-12-02 02:00:17.620895+00	steadfast-myna	SCHEDULED	0	2025-12-02 02:00:00+00	2025-12-02 02:00:00+00	\N	\N	00:00:00	\N	{}	scheduled ec838372-322b-4053-b7da-c080a35d10f6 2025-12-02T02:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "model-training", "monthly", "orchestrator"]	t	5256a040-1daf-409c-a08f-0a7b90582957	ec838372-322b-4053-b7da-c080a35d10f6	\N	5520c329-9b70-4608-b63d-4f00d46f5894	Late	efd456dc-5023-40b4-8a75-a793be43a0b8	default	2025-12-02 02:00:17.622051+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
4559b692-832c-4cc9-9cdf-713a153654e0	2025-11-12 11:47:49.102217+00	2025-11-15 00:00:17.883035+00	wealthy-binturong	SCHEDULED	0	2025-11-15 00:00:00+00	2025-11-15 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-15T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	5249d0f8-87c6-40f3-a5dc-987214f0df8f	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-15 00:00:17.884966+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
542f14d8-c322-46df-b01e-0a718133d7b8	2025-11-13 00:00:04.94328+00	2025-11-16 00:00:16.338498+00	illustrious-hyrax	SCHEDULED	0	2025-11-16 00:00:00+00	2025-11-16 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-16T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	3aa5f979-1ed0-48fb-b971-51495138d840	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-16 00:00:16.340714+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
bcddc817-4fa5-4160-be95-d63987198014	2025-11-14 00:00:06.886899+00	2025-11-17 00:00:19.932749+00	unique-owl	SCHEDULED	0	2025-11-17 00:00:00+00	2025-11-17 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-17T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	3edb5f5b-4f16-46b6-b4ac-007821b84c76	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-17 00:00:19.934574+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
fb8f4280-f78d-4de1-a397-29e8a1e058ce	2025-11-15 00:00:08.758664+00	2025-11-18 00:00:18.091113+00	tentacled-bird	SCHEDULED	0	2025-11-18 00:00:00+00	2025-11-18 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-18T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	b0a44d55-add0-49c6-8f95-427aeead858c	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-18 00:00:18.092889+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
d232a8dd-ba29-4fa3-aa5d-ca1eb85aad07	2025-11-16 00:00:10.720262+00	2025-11-19 00:00:16.523762+00	marvellous-coyote	SCHEDULED	0	2025-11-19 00:00:00+00	2025-11-19 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-19T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	00e23a0d-e38e-4325-8d2f-537764238a7a	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-19 00:00:16.525692+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
6ca35442-3de6-4e4c-9a9e-a0d384b9e9fc	2025-11-17 00:00:12.669165+00	2025-11-20 00:00:19.876847+00	fanatic-petrel	SCHEDULED	0	2025-11-20 00:00:00+00	2025-11-20 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-20T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	c4ae4f37-4c1a-4808-a4c3-d72c24f80539	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-20 00:00:19.879013+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
2be2002c-bf66-41a2-a9b9-f754f62632c7	2025-11-18 00:00:14.630972+00	2025-11-21 00:00:18.388455+00	celadon-bittern	SCHEDULED	0	2025-11-21 00:00:00+00	2025-11-21 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-21T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	b90f843f-d984-4921-b0ec-64a008b7c3b5	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-21 00:00:18.389942+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
9b6b5c83-b524-4007-9739-e52537bca4e8	2025-11-19 00:00:16.670502+00	2025-11-22 00:00:16.933753+00	zircon-nautilus	SCHEDULED	0	2025-11-22 00:00:00+00	2025-11-22 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-22T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	8a74c876-d807-4328-866a-cb7a8d389ed3	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-22 00:00:16.936893+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
9b46afd2-6f45-405c-9a76-ec4150519982	2025-11-20 00:00:18.640739+00	2025-11-23 00:00:15.330902+00	loose-woodpecker	SCHEDULED	0	2025-11-23 00:00:00+00	2025-11-23 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-23T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	51c4e06b-0634-4031-b919-b6417c182664	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-23 00:00:15.332634+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
d2a081cf-b457-4138-a895-5c7740a4c49b	2025-11-21 00:00:20.662546+00	2025-11-24 00:00:18.625319+00	amazing-oriole	SCHEDULED	0	2025-11-24 00:00:00+00	2025-11-24 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-24T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	79ad4680-68c7-46ce-b5a1-737d06f183ff	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-24 00:00:18.626621+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
112c2feb-ee9a-4c2a-957f-489701e3d2ed	2025-11-26 00:00:30.356354+00	2025-11-29 00:00:15.435892+00	skinny-chowchow	SCHEDULED	0	2025-11-29 00:00:00+00	2025-11-29 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-29T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	681a104d-0bc9-4323-afe5-baa55dc3c314	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-29 00:00:15.442832+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
9f84018d-3495-41ba-a3b0-3f3453286d20	2025-11-22 00:00:22.638824+00	2025-11-25 00:00:17.311864+00	outstanding-marten	SCHEDULED	0	2025-11-25 00:00:00+00	2025-11-25 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-25T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	738e4137-2a60-47fd-982b-21762c2a8d03	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-25 00:00:17.313828+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
7c1762ef-349c-4f18-94ed-52bf2d65291f	2025-11-30 00:00:37.986957+00	2025-12-03 00:00:18.510028+00	masked-fennec	SCHEDULED	0	2025-12-03 00:00:00+00	2025-12-03 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-03T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	d8535e27-08cf-475b-89ee-e1983afd200c	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-03 00:00:18.511592+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
1a113ce3-6130-4db8-9865-2792ff6b7a48	2025-12-02 00:00:41.979843+00	2025-12-05 00:00:15.067157+00	inescapable-adder	SCHEDULED	0	2025-12-05 00:00:00+00	2025-12-05 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-05T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	c5dc06e3-7fcf-467a-ae6f-d298ee5d95fa	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-05 00:00:15.068611+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
777d4fb3-bff5-42d3-99ef-ae1df2c6229d	2025-12-05 00:00:47.644129+00	2025-12-08 00:00:18.306036+00	cyan-jacamar	SCHEDULED	0	2025-12-08 00:00:00+00	2025-12-08 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-08T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	fbea3dca-7e8a-4582-be35-85f60e86453a	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-08 00:00:18.307796+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
e32da044-73da-4a04-89dc-6905dc048451	2025-12-06 00:00:49.561986+00	2025-12-09 00:00:16.058185+00	industrious-petrel	SCHEDULED	0	2025-12-09 00:00:00+00	2025-12-09 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-09T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	173e2b2e-d675-45c4-a9dc-599bdee461e9	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-09 00:00:16.060041+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
c10aee62-fa00-45c3-b8ac-3c7b901899b9	2025-12-07 00:00:51.393888+00	2025-12-10 00:00:17.933476+00	magnificent-deer	SCHEDULED	0	2025-12-10 00:00:00+00	2025-12-10 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-10T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	e73a0d39-806c-47e8-81bb-07173d5116d6	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-10 00:00:17.93551+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
3cfc62f3-d11a-4d7f-946b-107a730628e7	2025-12-17 00:00:10.255942+00	2025-12-20 00:00:19.992019+00	successful-starling	SCHEDULED	0	2025-12-20 00:00:00+00	2025-12-20 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-20T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	67c8552a-5f5e-4961-8c5f-15ee28a5c8a9	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-20 00:00:19.993167+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
f0aba532-b3f5-4271-a79b-df52d5d6eead	2025-12-19 00:00:13.600758+00	2025-12-22 00:00:16.48359+00	famous-llama	SCHEDULED	0	2025-12-22 00:00:00+00	2025-12-22 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-22T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	c4b9e739-015f-4c02-a8b5-53b7ac8ce102	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-22 00:00:16.485549+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
b24ce800-7315-446b-a68c-879289317622	2025-12-20 00:00:15.229065+00	2025-12-23 00:00:19.717323+00	serious-meerkat	SCHEDULED	0	2025-12-23 00:00:00+00	2025-12-23 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-23T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	d23a3bd1-15a4-47d3-9bd2-ef0e64cae1e5	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-23 00:00:19.719174+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
ceb83735-2900-4e5b-a916-f00a84bf76ed	2025-12-21 00:00:17.075758+00	2025-12-24 00:00:18.278198+00	refreshing-moth	SCHEDULED	0	2025-12-24 00:00:00+00	2025-12-24 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-24T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	4587de7e-9dc1-49ad-8108-e20f155a93be	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-24 00:00:18.279943+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
622f880f-5d4c-4eaf-8676-ef14a75b31e8	2025-12-22 00:00:18.980749+00	2025-12-25 00:00:16.967053+00	roaring-moose	SCHEDULED	0	2025-12-25 00:00:00+00	2025-12-25 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-25T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	eac56d76-642c-4ef3-9e88-c63d7b80ef46	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-25 00:00:16.968212+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
f9164581-4d26-4223-818e-b95d506befb9	2025-12-23 00:00:20.96226+00	2025-12-26 00:00:15.41504+00	pretty-buzzard	SCHEDULED	0	2025-12-26 00:00:00+00	2025-12-26 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-26T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	b29cd8f2-da75-41ec-a64d-f63253b1756e	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-26 00:00:15.416923+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
37afd881-6e7f-4852-812c-0a52a8ac9acb	2025-11-27 00:00:32.347048+00	2025-11-30 00:00:18.972639+00	busy-agouti	SCHEDULED	0	2025-11-30 00:00:00+00	2025-11-30 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-30T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	51087be1-87ae-4ef7-aa79-bae57602d794	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-30 00:00:18.974534+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
241f56a6-bb83-45be-ba2f-78de7f011b44	2025-11-28 00:00:34.187603+00	2025-12-01 00:00:17.373206+00	sweet-polecat	SCHEDULED	0	2025-12-01 00:00:00+00	2025-12-01 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-01T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	241bc622-e468-41de-8b07-b34d101d84be	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-01 00:00:17.374997+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
7c41b2f3-47d8-4a67-8675-d39745e166ae	2026-01-02 02:00:42.216862+00	2026-01-02 02:00:42.217443+00	cerulean-snake	SCHEDULED	0	2026-04-02 02:00:00+00	2026-04-02 02:00:00+00	\N	\N	00:00:00	\N	{}	scheduled ec838372-322b-4053-b7da-c080a35d10f6 2026-04-02T02:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "model-training", "monthly", "orchestrator"]	t	5256a040-1daf-409c-a08f-0a7b90582957	ec838372-322b-4053-b7da-c080a35d10f6	\N	5de72a03-abf2-4a1d-a4ec-da3ec290d15b	Scheduled	efd456dc-5023-40b4-8a75-a793be43a0b8	default	\N	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
0157c87b-a08e-46bc-b61b-dd6cd067858b	2025-11-23 00:00:24.441497+00	2025-11-26 00:00:16.042271+00	inventive-seagull	SCHEDULED	0	2025-11-26 00:00:00+00	2025-11-26 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-26T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	18cdec8b-4edc-4e02-badb-a14ca3dd1942	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-26 00:00:16.043465+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
29560a6b-94e2-4fef-b9bb-b71c9df5928a	2025-11-24 00:00:26.552025+00	2025-11-27 00:00:18.945772+00	unyielding-wrasse	SCHEDULED	0	2025-11-27 00:00:00+00	2025-11-27 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-27T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	c32feb8d-4b54-4e9a-a9a1-ed5ee3ae58e5	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-27 00:00:18.949441+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
c106e617-9ba2-4c1b-a0a9-c493f72856a9	2025-12-01 01:00:40.117643+00	2025-12-01 01:00:40.118607+00	fantastic-slug	SCHEDULED	0	2026-03-01 01:00:00+00	2026-03-01 01:00:00+00	\N	\N	00:00:00	\N	{}	scheduled 0aaf4a21-55de-47cb-952b-b2fcf5482b42 2026-03-01T01:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "monthly", "creation"]	t	0d6089bc-ec9a-42ec-b0f0-008a42cb945d	0aaf4a21-55de-47cb-952b-b2fcf5482b42	\N	8facd923-300d-4606-9e5b-c26469d2b4ca	Scheduled	06f61094-d1c3-4990-b0af-3aecc56293ad	default	\N	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
77819e6f-bf0f-48eb-9804-0c25c4d9a0d2	2025-11-25 00:00:28.441472+00	2025-11-28 00:00:17.296465+00	great-condor	SCHEDULED	0	2025-11-28 00:00:00+00	2025-11-28 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-11-28T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	775676f3-b188-4c72-8925-e4b658956417	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-11-28 00:00:17.298264+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
d62b2d0c-c5f7-4aaf-b3c2-4929893c9f2b	2025-12-01 00:00:40.032064+00	2025-12-04 00:00:16.842069+00	greedy-kudu	SCHEDULED	0	2025-12-04 00:00:00+00	2025-12-04 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-04T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	62746a66-f162-4588-a936-3f72f05cdad8	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-04 00:00:16.843312+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
f22aeee2-42e4-4354-9889-838df3bdfc3c	2025-12-03 00:00:43.936304+00	2025-12-06 00:00:18.380764+00	defiant-griffin	SCHEDULED	0	2025-12-06 00:00:00+00	2025-12-06 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-06T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	99952201-761c-4988-9173-09a8f32a8661	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-06 00:00:18.383322+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
ca408b34-04d2-4b44-83f7-c7ed0b2bdd29	2025-12-08 00:00:53.200899+00	2025-12-11 00:00:15.437655+00	zippy-mongoose	SCHEDULED	0	2025-12-11 00:00:00+00	2025-12-11 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-11T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	c3a9068f-5dea-4bd7-8f7b-3222edf2c378	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-11 00:00:15.439171+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
e027892b-2073-4a73-9fb0-053bc02720d4	2025-12-09 00:00:55.07081+00	2025-12-12 00:00:18.81462+00	tasteful-impala	SCHEDULED	0	2025-12-12 00:00:00+00	2025-12-12 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-12T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	73c6f7b3-d7ba-4ddf-a806-8b7c0ef253c3	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-12 00:00:18.815891+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
e4b16a72-9ce2-435c-85cb-bef4871d7cb5	2025-12-12 00:00:00.594594+00	2025-12-15 00:00:18.860856+00	mustard-squirrel	SCHEDULED	0	2025-12-15 00:00:00+00	2025-12-15 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-15T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	2be88a0d-bb8a-49ef-b0dc-cbaae965eb53	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-15 00:00:18.864936+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
74d0a57b-4aba-4eec-8817-88409b115c8e	2025-12-14 00:00:04.426669+00	2025-12-17 00:00:15.487953+00	cobalt-aardwolf	SCHEDULED	0	2025-12-17 00:00:00+00	2025-12-17 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-17T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	cd0e6e51-59f4-4aeb-98c1-b1702751a6c1	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-17 00:00:15.489817+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
d0ac9ca1-2f79-49b4-9a2e-8361c2abc46d	2025-12-15 00:00:06.422627+00	2025-12-18 00:00:15.852209+00	private-beluga	SCHEDULED	0	2025-12-18 00:00:00+00	2025-12-18 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-18T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	5aa694ca-15a5-405b-854b-9e284dc79554	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-18 00:00:15.853518+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
4eadc0aa-1ceb-4f97-8a31-f5e8e811ba68	2025-12-25 00:00:24.764836+00	2025-12-28 00:00:18.154906+00	benign-ocelot	SCHEDULED	0	2025-12-28 00:00:00+00	2025-12-28 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-28T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	f6f159df-87ae-499c-a27b-91ca303b2b1b	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-28 00:00:18.157825+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
4a4b00d0-957b-4e9f-be10-a5179d48329c	2025-12-24 00:00:22.889537+00	2025-12-27 00:00:19.292643+00	sociable-chupacabra	SCHEDULED	0	2025-12-27 00:00:00+00	2025-12-27 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-27T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	320b9fa3-e837-4d67-9012-fc27ef92b54f	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-27 00:00:19.294549+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
40db4190-7b97-407a-b5c5-68bb5a4835de	2025-12-27 00:00:28.634933+00	2025-12-30 00:00:16.027023+00	ubiquitous-lizard	SCHEDULED	0	2025-12-30 00:00:00+00	2025-12-30 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-30T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	d602d916-9f94-41a7-90f1-0e040506207f	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-30 00:00:16.028138+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
7960a986-6f03-4ae6-b011-6c89c0cbf40e	2025-12-28 00:00:30.565225+00	2025-12-31 00:00:19.179326+00	burrowing-chowchow	SCHEDULED	0	2025-12-31 00:00:00+00	2025-12-31 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-31T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	b5a57141-925d-449c-bff5-604940a72318	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-31 00:00:19.18057+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
406d536e-6610-402e-ba41-e4e5b1bef57b	2025-12-30 00:00:11.312748+00	2026-01-02 00:00:16.20202+00	merciful-bug	SCHEDULED	0	2026-01-02 00:00:00+00	2026-01-02 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-02T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	82c175ac-9176-4338-9df5-abac0144561e	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-02 00:00:16.203076+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
9ab35af2-6fad-4162-891c-b259a43eba17	2025-12-31 00:00:39.475634+00	2026-01-03 00:00:17.20963+00	warm-pheasant	SCHEDULED	0	2026-01-03 00:00:00+00	2026-01-03 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-03T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	889f2833-69a0-48c3-bf74-29ae61657561	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-03 00:00:17.210849+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
22fe108a-bad9-483d-82c8-963ed92ff10c	2026-01-01 00:00:40.779256+00	2026-01-04 00:00:18.243775+00	mustard-jackal	SCHEDULED	0	2026-01-04 00:00:00+00	2026-01-04 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-04T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	b213455e-034b-41df-a183-1449853cc78f	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-04 00:00:18.244916+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
12300b3e-737f-417c-9461-d186964da0c4	2026-01-03 00:00:43.475687+00	2026-01-06 00:00:17.208215+00	radiant-mouflon	SCHEDULED	0	2026-01-06 00:00:00+00	2026-01-06 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-06T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	af42d62c-9f64-403c-b6d5-bbb63d370dcd	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-06 00:00:17.210013+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
cb8afdca-b7e4-49ff-a2b5-5fec3424034e	2026-01-05 00:00:46.189967+00	2026-01-08 00:00:18.298917+00	topaz-hare	SCHEDULED	0	2026-01-08 00:00:00+00	2026-01-08 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-08T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	3516a423-7770-4e6b-b25e-94451864a793	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-08 00:00:18.300667+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
42fe8ddd-5c20-41f4-8ec8-bf6d22f0fd80	2026-01-06 00:00:47.700904+00	2026-01-09 00:00:16.378453+00	warm-meerkat	SCHEDULED	0	2026-01-09 00:00:00+00	2026-01-09 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-09T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	ed8bb0b8-5eae-41f1-a91c-e7cfa9d5f8ae	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-09 00:00:16.380181+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
d841e1c8-3b27-4fde-be03-b23ead6d1c41	2026-01-13 00:00:58.230742+00	2026-01-16 00:00:18.260985+00	certain-labradoodle	SCHEDULED	0	2026-01-16 00:00:00+00	2026-01-16 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-16T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	9851d167-3481-4267-a057-a1b0d28ad779	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-16 00:00:18.262732+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
505abe48-d621-47cd-a829-0fe6c84e62fe	2026-01-14 00:00:59.745082+00	2026-01-17 00:00:16.284939+00	ebony-dachshund	SCHEDULED	0	2026-01-17 00:00:00+00	2026-01-17 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-17T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	a626abd0-6c32-4dba-b6eb-9c2674f0e17e	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-17 00:00:16.286698+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
8565270e-9f12-40dd-a232-9e550d7d2a35	2026-01-16 00:00:02.769048+00	2026-01-19 00:00:17.322411+00	jade-mongoose	SCHEDULED	0	2026-01-19 00:00:00+00	2026-01-19 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-19T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	ae564d75-f5f7-4551-af9b-7cc8ca2245f7	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-19 00:00:17.3242+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
18dcbb2f-db7d-4fab-8608-2673c4892985	2025-12-26 00:00:26.719191+00	2025-12-29 00:00:16.675025+00	warm-frog	SCHEDULED	0	2025-12-29 00:00:00+00	2025-12-29 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2025-12-29T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	823b0e18-a3a5-423b-b72a-624eb48755e4	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2025-12-29 00:00:16.676904+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
11c597e4-d1c4-430e-8857-5ed0abe5128c	2025-12-29 00:00:32.43458+00	2026-01-01 00:00:15.15185+00	accurate-yak	SCHEDULED	0	2026-01-01 00:00:00+00	2026-01-01 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-01T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	00a96b15-e7e3-4c23-be27-bccc5d460b9f	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-01 00:00:15.153112+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
bbf34c77-e6c9-4c62-87d5-80565a889aaa	2026-01-01 01:00:40.839386+00	2026-01-01 01:00:40.839923+00	azure-narwhal	SCHEDULED	0	2026-04-01 01:00:00+00	2026-04-01 01:00:00+00	\N	\N	00:00:00	\N	{}	scheduled 0aaf4a21-55de-47cb-952b-b2fcf5482b42 2026-04-01T01:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "monthly", "creation"]	t	0d6089bc-ec9a-42ec-b0f0-008a42cb945d	0aaf4a21-55de-47cb-952b-b2fcf5482b42	\N	708cdb0a-8e88-4a43-8827-927fb82e3bff	Scheduled	06f61094-d1c3-4990-b0af-3aecc56293ad	default	\N	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
44eba868-9803-4d32-9a8d-c2556fe722ee	2026-01-02 00:00:42.105002+00	2026-01-05 00:00:19.314749+00	hairy-okapi	SCHEDULED	0	2026-01-05 00:00:00+00	2026-01-05 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-05T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	7d00ce3e-5724-4bab-9558-6bc9cfaf0dea	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-05 00:00:19.315796+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
a522c4cb-c440-41fc-ab20-6e214fbc6722	2026-01-04 00:00:44.81034+00	2026-01-07 00:00:15.2685+00	humongous-dragonfly	SCHEDULED	0	2026-01-07 00:00:00+00	2026-01-07 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-07T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	18fa2260-679e-46c0-9353-2527c0534263	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-07 00:00:15.270206+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
c951d9b0-7e9f-4f64-8c09-dc3c9ee45108	2026-01-07 00:00:49.219441+00	2026-01-10 00:00:19.497573+00	towering-armadillo	SCHEDULED	0	2026-01-10 00:00:00+00	2026-01-10 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-10T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	19cc8258-b64c-4384-9135-1bf9fc38387e	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-10 00:00:19.499343+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
a49bbd79-770e-44de-a40e-f3404ec96a4c	2026-01-08 00:00:50.716893+00	2026-01-11 00:00:17.575026+00	tacky-mamba	SCHEDULED	0	2026-01-11 00:00:00+00	2026-01-11 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-11T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	33f508c6-f012-4d5d-be01-718e8e1b64bd	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-11 00:00:17.576767+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
07fc47dc-39c7-4cce-bb02-25c7d0e29992	2026-01-09 00:00:52.203722+00	2026-01-12 00:00:15.624259+00	utopian-mamba	SCHEDULED	0	2026-01-12 00:00:00+00	2026-01-12 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-12T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	654292a8-bb3c-40f8-9c21-59ea5fa8db78	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-12 00:00:15.625957+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
131ac30c-6c09-4348-a944-731ee75d9cc4	2026-01-10 00:00:53.716959+00	2026-01-13 00:00:18.738116+00	wandering-bird	SCHEDULED	0	2026-01-13 00:00:00+00	2026-01-13 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-13T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	22679bfa-10e5-46d9-aef9-c13cb9db047f	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-13 00:00:18.739863+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
579194af-2f5c-4088-8846-a2b35b0abef7	2026-01-11 00:00:55.215444+00	2026-01-14 00:00:16.917841+00	vengeful-tamarin	SCHEDULED	0	2026-01-14 00:00:00+00	2026-01-14 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-14T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	6136be28-efaf-4be1-9917-02f683cf11de	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-14 00:00:16.91967+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
870aab41-3b1b-4af7-a504-ef1c272f49d8	2026-01-12 00:00:56.718652+00	2026-01-15 00:00:15.108201+00	cornflower-peccary	SCHEDULED	0	2026-01-15 00:00:00+00	2026-01-15 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-15T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	15967337-386b-464a-a98d-7712d0be6260	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-15 00:00:15.109988+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
63c85525-2c76-45a0-931c-6395ffa9a309	2026-01-15 00:00:01.257766+00	2026-01-18 00:00:19.286523+00	prophetic-leopard	SCHEDULED	0	2026-01-18 00:00:00+00	2026-01-18 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-18T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	6fda17cc-650e-4230-ae87-4ab73ff4d8f1	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-18 00:00:19.288201+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
444cdff0-54f0-4324-aba9-193def0cc7d6	2026-01-17 00:00:04.266989+00	2026-01-20 00:00:15.388912+00	peculiar-jaybird	SCHEDULED	0	2026-01-20 00:00:00+00	2026-01-20 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-20T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	1869f008-c36a-4c23-966a-193ae51c55e2	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-20 00:00:15.390615+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
08ef0d69-493a-4d82-82ba-968b784260b4	2026-01-18 00:00:05.752915+00	2026-01-21 00:00:18.534118+00	wandering-hornet	SCHEDULED	0	2026-01-21 00:00:00+00	2026-01-21 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-21T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	e3a94ff6-99c9-4197-b5f6-5198de8549bb	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-21 00:00:18.536074+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
c23355d7-02f7-48b1-b655-864906b2439b	2026-01-21 00:00:10.272307+00	2026-01-24 00:00:17.979799+00	roaring-gorilla	SCHEDULED	0	2026-01-24 00:00:00+00	2026-01-24 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-24T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	6eb57b8c-6b44-44f3-8cef-861a25603654	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-24 00:00:17.981449+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
6f97a160-ed1b-4993-a774-9878ebc979da	2026-01-23 00:00:13.315994+00	2026-01-26 00:00:18.454409+00	solid-cow	SCHEDULED	0	2026-01-26 00:00:00+00	2026-01-26 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-26T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	7e3b1894-e9e0-4b07-b681-907d92ba0a21	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-26 00:00:18.45553+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
1c16706f-dae4-40d8-bba4-849cc8c1b5c8	2026-01-19 00:00:07.249371+00	2026-01-22 00:00:16.670121+00	judicious-unicorn	SCHEDULED	0	2026-01-22 00:00:00+00	2026-01-22 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-22T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	510bc244-5938-48a3-b372-c80ebe729871	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-22 00:00:16.671836+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
9496431f-dfbe-4c11-b799-e799f38da912	2026-01-20 00:00:08.754946+00	2026-01-23 00:00:19.853803+00	meticulous-tench	SCHEDULED	0	2026-01-23 00:00:00+00	2026-01-23 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-23T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	e6ba0684-3343-4cae-a058-d7817847b200	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-23 00:00:19.855619+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
a1d03b19-a14f-4789-9079-1df59220e74c	2026-01-22 00:00:11.782492+00	2026-01-25 00:00:18.458167+00	pumpkin-lion	SCHEDULED	0	2026-01-25 00:00:00+00	2026-01-25 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-25T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	f63f7d9a-6ad8-48bd-a92c-0783e1ed6367	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-25 00:00:18.459211+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
d88035d5-b4cc-4ac8-96f5-142c3f8682e6	2026-01-26 00:00:53.145623+00	2026-01-26 00:00:53.146314+00	bulky-hippo	SCHEDULED	0	2026-01-29 00:00:00+00	2026-01-29 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-29T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	9213c799-a5c0-4674-9436-c646763e4d42	Scheduled	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	\N	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
5bf1d57e-c266-4929-bf90-9875c1429cc1	2026-01-24 00:00:14.808633+00	2026-01-27 00:00:19.70773+00	sepia-lyrebird	SCHEDULED	0	2026-01-27 00:00:00+00	2026-01-27 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-27T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	c3557fa7-b280-44e4-a81d-91e4054220e5	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-27 00:00:19.708792+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
1a6c7c5b-4cb1-47b5-a2a8-4e03163e164b	2026-01-27 00:00:54.479944+00	2026-01-27 00:00:54.480555+00	wooden-bandicoot	SCHEDULED	0	2026-01-30 00:00:00+00	2026-01-30 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-30T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	fe863959-83f5-48e1-b366-e5bf71b699d9	Scheduled	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	\N	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
51776141-ef3b-45a7-a20a-6679c5cf208a	2026-01-25 00:00:50.388754+00	2026-01-28 00:00:15.928489+00	able-inchworm	SCHEDULED	0	2026-01-28 00:00:00+00	2026-01-28 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-28T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	f3800b06-a5cc-4eaa-8e0d-d6797d3c0cba	Late	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	2026-01-28 00:00:15.929707+00	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
48c9d84d-ac78-4c93-a538-4e43e617ab38	2026-01-28 00:00:55.807601+00	2026-01-28 00:00:55.808161+00	abiding-raptor	SCHEDULED	0	2026-01-31 00:00:00+00	2026-01-31 00:00:00+00	\N	\N	00:00:00	\N	{}	scheduled d11b8f8c-6770-4a65-bbb9-3c1ac189c94f 2026-01-31T00:00:00+00:00	{}	{"retries": null, "resuming": false, "pause_keys": [], "retry_type": null, "max_retries": 0, "retry_delay": null, "retry_delay_seconds": 0}	["auto-scheduled", "dataset-management", "daily", "collection"]	t	eb63db8a-d4d1-47d7-b3c7-467722ee05a8	d11b8f8c-6770-4a65-bbb9-3c1ac189c94f	\N	8b4b6e48-95ad-4030-940a-6ce9f006c89c	Scheduled	23aa794b-4a92-434f-b10f-ec6fa8d17348	default	\N	\N	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	{}	1.0.0
\.


--
-- Data for Name: flow_run_input; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.flow_run_input (id, created, updated, key, value, flow_run_id, sender) FROM stdin;
\.


--
-- Data for Name: flow_run_notification_policy; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.flow_run_notification_policy (id, created, updated, is_active, state_names, tags, message_template, block_document_id) FROM stdin;
\.


--
-- Data for Name: flow_run_notification_queue; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.flow_run_notification_queue (id, created, updated, flow_run_notification_policy_id, flow_run_state_id) FROM stdin;
\.


--
-- Data for Name: flow_run_state; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.flow_run_state (id, created, updated, type, "timestamp", name, message, state_details, data, flow_run_id, result_artifact_id) FROM stdin;
889bc561-6107-44fb-b3a5-b4f75446b7b6	2025-11-12 11:47:49.120123+00	2025-11-12 11:47:49.120155+00	SCHEDULED	2025-11-12 11:47:49.0619+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-01T01:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	55e8bebd-5b0b-4c6d-8105-b22a9cb3e405	\N
2fdcbd87-9b77-4598-9bee-4231084d5884	2025-11-12 11:47:49.120166+00	2025-11-12 11:47:49.120174+00	SCHEDULED	2025-11-12 11:47:49.062145+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-01T01:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	f7965b9c-96b2-4635-af3d-7d5056cdae70	\N
2858f2e5-a80d-45b3-a488-3e5db0b745b9	2025-11-12 11:47:49.120181+00	2025-11-12 11:47:49.120188+00	SCHEDULED	2025-11-12 11:47:49.062357+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-02-01T01:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	c93a16e1-ffb3-4a11-966f-a61aef7a061b	\N
0111cb7d-9a33-4058-ab47-c4c11a9a38bb	2025-11-12 11:47:49.120196+00	2025-11-12 11:47:49.120203+00	SCHEDULED	2025-11-12 11:47:49.081056+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-13T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	ba30c6f1-004c-45e1-b5bc-a07461485d96	\N
2f1a39fe-8640-4b82-999f-0d1e20b668dc	2025-11-12 11:47:49.12021+00	2025-11-12 11:47:49.120218+00	SCHEDULED	2025-11-12 11:47:49.081365+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-14T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	6723ff3c-d5db-4dd9-9091-bd57941ac8ca	\N
484176d8-6b79-47ea-b399-f00cffc58b1d	2025-11-12 11:47:49.120225+00	2025-11-12 11:47:49.120233+00	SCHEDULED	2025-11-12 11:47:49.08161+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-15T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	4559b692-832c-4cc9-9cdf-713a153654e0	\N
094b7432-6564-4242-be49-3f31a3a65174	2025-11-12 11:47:49.12024+00	2025-11-12 11:47:49.120246+00	SCHEDULED	2025-11-12 11:47:49.095657+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-02T02:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	17073ad8-747b-44fd-b4b1-603a144b32f8	\N
5b63c9f8-4637-43bf-9058-8fcaf3fe47b8	2025-11-12 11:47:49.120253+00	2025-11-12 11:47:49.12026+00	SCHEDULED	2025-11-12 11:47:49.095963+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-02T02:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	ca26ca1c-b7ee-46b6-acd5-c91fa3b16c0c	\N
4b10910c-628d-4d62-a543-58e1d95a5e14	2025-11-12 11:47:49.120266+00	2025-11-12 11:47:49.120273+00	SCHEDULED	2025-11-12 11:47:49.096224+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-02-02T02:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	c2a69edb-e6f5-4630-80ff-b381136b2cab	\N
c1a077c7-892c-4239-9186-39fa21a6daf5	2025-11-13 00:00:04.957714+00	2025-11-13 00:00:04.957744+00	SCHEDULED	2025-11-13 00:00:04.937946+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-16T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	542f14d8-c322-46df-b01e-0a718133d7b8	\N
768fb0ac-a0c1-4553-b4c8-b5d12efb53eb	2025-11-13 00:00:15.937707+00	2025-11-13 00:00:15.93773+00	SCHEDULED	2025-11-13 00:00:15.917094+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "ba30c6f1-004c-45e1-b5bc-a07461485d96", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-13T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	ba30c6f1-004c-45e1-b5bc-a07461485d96	\N
d1cae757-fb7c-40d0-934e-4ef7913b9066	2025-11-14 00:00:06.8965+00	2025-11-14 00:00:06.896525+00	SCHEDULED	2025-11-14 00:00:06.881383+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-17T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	bcddc817-4fa5-4160-be95-d63987198014	\N
c2221a74-1bac-47d8-96c7-cb64d2af77ce	2025-11-14 00:00:19.431433+00	2025-11-14 00:00:19.431454+00	SCHEDULED	2025-11-14 00:00:19.407704+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "6723ff3c-d5db-4dd9-9091-bd57941ac8ca", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-14T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	6723ff3c-d5db-4dd9-9091-bd57941ac8ca	\N
05e04894-6213-430c-9cef-61cce108697e	2025-11-15 00:00:08.768473+00	2025-11-15 00:00:08.768506+00	SCHEDULED	2025-11-15 00:00:08.752629+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-18T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	fb8f4280-f78d-4de1-a397-29e8a1e058ce	\N
5249d0f8-87c6-40f3-a5dc-987214f0df8f	2025-11-15 00:00:17.905122+00	2025-11-15 00:00:17.905147+00	SCHEDULED	2025-11-15 00:00:17.884966+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "4559b692-832c-4cc9-9cdf-713a153654e0", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-15T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	4559b692-832c-4cc9-9cdf-713a153654e0	\N
505a6e04-df4c-4b52-97e8-5d5bbfca34d1	2025-11-16 00:00:10.736028+00	2025-11-16 00:00:10.736066+00	SCHEDULED	2025-11-16 00:00:10.714902+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-19T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	d232a8dd-ba29-4fa3-aa5d-ca1eb85aad07	\N
3aa5f979-1ed0-48fb-b971-51495138d840	2025-11-16 00:00:16.358229+00	2025-11-16 00:00:16.358251+00	SCHEDULED	2025-11-16 00:00:16.340714+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "542f14d8-c322-46df-b01e-0a718133d7b8", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-16T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	542f14d8-c322-46df-b01e-0a718133d7b8	\N
3edb5f5b-4f16-46b6-b4ac-007821b84c76	2025-11-17 00:00:19.949066+00	2025-11-17 00:00:19.949085+00	SCHEDULED	2025-11-17 00:00:19.934574+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "bcddc817-4fa5-4160-be95-d63987198014", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-17T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	bcddc817-4fa5-4160-be95-d63987198014	\N
8a74c876-d807-4328-866a-cb7a8d389ed3	2025-11-22 00:00:16.950753+00	2025-11-22 00:00:16.950772+00	SCHEDULED	2025-11-22 00:00:16.936893+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "9b6b5c83-b524-4007-9739-e52537bca4e8", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-22T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	9b6b5c83-b524-4007-9739-e52537bca4e8	\N
738e4137-2a60-47fd-982b-21762c2a8d03	2025-11-25 00:00:17.328001+00	2025-11-25 00:00:17.32802+00	SCHEDULED	2025-11-25 00:00:17.313828+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "9f84018d-3495-41ba-a3b0-3f3453286d20", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-25T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	9f84018d-3495-41ba-a3b0-3f3453286d20	\N
673e6cc7-30dc-4de3-9a04-b2c73bec67ba	2025-11-25 00:00:28.452247+00	2025-11-25 00:00:28.452274+00	SCHEDULED	2025-11-25 00:00:28.432865+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-28T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	77819e6f-bf0f-48eb-9804-0c25c4d9a0d2	\N
c0870d50-8d98-4a87-87b6-c2740258a6c9	2025-11-17 00:00:12.677224+00	2025-11-17 00:00:12.677248+00	SCHEDULED	2025-11-17 00:00:12.663421+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-20T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	6ca35442-3de6-4e4c-9a9e-a0d384b9e9fc	\N
ad0e3ccd-b6fb-43f8-acb1-a05f2ff38b71	2025-11-18 00:00:14.638395+00	2025-11-18 00:00:14.638417+00	SCHEDULED	2025-11-18 00:00:14.623274+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-21T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	2be2002c-bf66-41a2-a9b9-f754f62632c7	\N
b0a44d55-add0-49c6-8f95-427aeead858c	2025-11-18 00:00:18.109086+00	2025-11-18 00:00:18.109106+00	SCHEDULED	2025-11-18 00:00:18.092889+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "fb8f4280-f78d-4de1-a397-29e8a1e058ce", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-18T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	fb8f4280-f78d-4de1-a397-29e8a1e058ce	\N
00e23a0d-e38e-4325-8d2f-537764238a7a	2025-11-19 00:00:16.542197+00	2025-11-19 00:00:16.542218+00	SCHEDULED	2025-11-19 00:00:16.525692+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "d232a8dd-ba29-4fa3-aa5d-ca1eb85aad07", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-19T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	d232a8dd-ba29-4fa3-aa5d-ca1eb85aad07	\N
b6381003-45df-45da-826a-18620fa854a7	2025-11-19 00:00:16.682596+00	2025-11-19 00:00:16.682623+00	SCHEDULED	2025-11-19 00:00:16.665025+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-22T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	9b6b5c83-b524-4007-9739-e52537bca4e8	\N
509a0876-dd68-4cd8-9b10-9057537ff10c	2025-11-20 00:00:18.648185+00	2025-11-20 00:00:18.648215+00	SCHEDULED	2025-11-20 00:00:18.633791+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-23T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	9b46afd2-6f45-405c-9a76-ec4150519982	\N
c4ae4f37-4c1a-4808-a4c3-d72c24f80539	2025-11-20 00:00:19.898075+00	2025-11-20 00:00:19.898095+00	SCHEDULED	2025-11-20 00:00:19.879013+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "6ca35442-3de6-4e4c-9a9e-a0d384b9e9fc", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-20T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	6ca35442-3de6-4e4c-9a9e-a0d384b9e9fc	\N
b90f843f-d984-4921-b0ec-64a008b7c3b5	2025-11-21 00:00:18.41255+00	2025-11-21 00:00:18.41257+00	SCHEDULED	2025-11-21 00:00:18.389942+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "2be2002c-bf66-41a2-a9b9-f754f62632c7", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-21T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	2be2002c-bf66-41a2-a9b9-f754f62632c7	\N
ae32e3c2-038f-4a69-88ae-9410a3ef837d	2025-11-21 00:00:20.671055+00	2025-11-21 00:00:20.671085+00	SCHEDULED	2025-11-21 00:00:20.652988+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-24T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	d2a081cf-b457-4138-a895-5c7740a4c49b	\N
aa05eec3-3011-4a78-b22c-5da6f2a09a02	2025-11-22 00:00:22.646307+00	2025-11-22 00:00:22.646331+00	SCHEDULED	2025-11-22 00:00:22.63156+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-25T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	9f84018d-3495-41ba-a3b0-3f3453286d20	\N
51c4e06b-0634-4031-b919-b6417c182664	2025-11-23 00:00:15.348725+00	2025-11-23 00:00:15.348745+00	SCHEDULED	2025-11-23 00:00:15.332634+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "9b46afd2-6f45-405c-9a76-ec4150519982", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-23T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	9b46afd2-6f45-405c-9a76-ec4150519982	\N
f08c98cb-ea11-4878-9a1d-9cb19b075d97	2025-11-23 00:00:24.450953+00	2025-11-23 00:00:24.450979+00	SCHEDULED	2025-11-23 00:00:24.436147+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-26T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	0157c87b-a08e-46bc-b61b-dd6cd067858b	\N
79ad4680-68c7-46ce-b5a1-737d06f183ff	2025-11-24 00:00:18.640568+00	2025-11-24 00:00:18.640598+00	SCHEDULED	2025-11-24 00:00:18.626621+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "d2a081cf-b457-4138-a895-5c7740a4c49b", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-24T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	d2a081cf-b457-4138-a895-5c7740a4c49b	\N
0699225a-2def-4ebf-b1ea-027b2ea72850	2025-11-24 00:00:26.559141+00	2025-11-24 00:00:26.559166+00	SCHEDULED	2025-11-24 00:00:26.546242+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-27T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	29560a6b-94e2-4fef-b9bb-b71c9df5928a	\N
18cdec8b-4edc-4e02-badb-a14ca3dd1942	2025-11-26 00:00:16.058076+00	2025-11-26 00:00:16.058094+00	SCHEDULED	2025-11-26 00:00:16.043465+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "0157c87b-a08e-46bc-b61b-dd6cd067858b", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-26T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	0157c87b-a08e-46bc-b61b-dd6cd067858b	\N
9f4b9a37-0872-4ed4-8be1-6e116ca7ce52	2025-11-26 00:00:30.363756+00	2025-11-26 00:00:30.363782+00	SCHEDULED	2025-11-26 00:00:30.350071+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-29T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	112c2feb-ee9a-4c2a-957f-489701e3d2ed	\N
c32feb8d-4b54-4e9a-a9a1-ed5ee3ae58e5	2025-11-27 00:00:18.963972+00	2025-11-27 00:00:18.963992+00	SCHEDULED	2025-11-27 00:00:18.949441+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "29560a6b-94e2-4fef-b9bb-b71c9df5928a", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-27T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	29560a6b-94e2-4fef-b9bb-b71c9df5928a	\N
d15584d6-648b-4bc3-8170-1db660b2184e	2025-11-27 00:00:32.357205+00	2025-11-27 00:00:32.357231+00	SCHEDULED	2025-11-27 00:00:32.342068+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-30T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	37afd881-6e7f-4852-812c-0a52a8ac9acb	\N
775676f3-b188-4c72-8925-e4b658956417	2025-11-28 00:00:17.316832+00	2025-11-28 00:00:17.316853+00	SCHEDULED	2025-11-28 00:00:17.298264+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "77819e6f-bf0f-48eb-9804-0c25c4d9a0d2", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-28T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	77819e6f-bf0f-48eb-9804-0c25c4d9a0d2	\N
56274dc4-8b9d-4516-887e-02da0cc2160a	2025-11-28 00:00:34.200812+00	2025-11-28 00:00:34.200843+00	SCHEDULED	2025-11-28 00:00:34.181963+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-01T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	241f56a6-bb83-45be-ba2f-78de7f011b44	\N
681a104d-0bc9-4323-afe5-baa55dc3c314	2025-11-29 00:00:15.466045+00	2025-11-29 00:00:15.466066+00	SCHEDULED	2025-11-29 00:00:15.442832+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "112c2feb-ee9a-4c2a-957f-489701e3d2ed", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-29T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	112c2feb-ee9a-4c2a-957f-489701e3d2ed	\N
ad59735d-6e68-4d51-9dd4-33823129d2ac	2025-11-29 00:00:36.106137+00	2025-11-29 00:00:36.106165+00	SCHEDULED	2025-11-29 00:00:36.091833+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-02T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	843db310-214d-45ff-b7b1-5322e5eba0eb	\N
51087be1-87ae-4ef7-aa79-bae57602d794	2025-11-30 00:00:18.994463+00	2025-11-30 00:00:18.994481+00	SCHEDULED	2025-11-30 00:00:18.974534+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "37afd881-6e7f-4852-812c-0a52a8ac9acb", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-11-30T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	37afd881-6e7f-4852-812c-0a52a8ac9acb	\N
f658e3b7-95ec-4849-8222-99deaf9dee3f	2025-11-30 00:00:37.99498+00	2025-11-30 00:00:37.995003+00	SCHEDULED	2025-11-30 00:00:37.978542+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-03T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	7c1762ef-349c-4f18-94ed-52bf2d65291f	\N
241bc622-e468-41de-8b07-b34d101d84be	2025-12-01 00:00:17.389168+00	2025-12-01 00:00:17.389188+00	SCHEDULED	2025-12-01 00:00:17.374997+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "241f56a6-bb83-45be-ba2f-78de7f011b44", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-01T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	241f56a6-bb83-45be-ba2f-78de7f011b44	\N
4f34aedb-448b-40a1-8a76-ebbe43ba1c63	2025-12-01 00:00:40.044451+00	2025-12-01 00:00:40.044481+00	SCHEDULED	2025-12-01 00:00:40.026358+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-04T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	d62b2d0c-c5f7-4aaf-b3c2-4929893c9f2b	\N
f3cfe6f0-c0cd-4c95-980b-6d9c666228be	2025-12-01 01:00:18.35295+00	2025-12-01 01:00:18.352967+00	SCHEDULED	2025-12-01 01:00:18.337791+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "55e8bebd-5b0b-4c6d-8105-b22a9cb3e405", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-01T01:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	55e8bebd-5b0b-4c6d-8105-b22a9cb3e405	\N
8facd923-300d-4606-9e5b-c26469d2b4ca	2025-12-01 01:00:40.124965+00	2025-12-01 01:00:40.124987+00	SCHEDULED	2025-12-01 01:00:40.111384+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-03-01T01:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	c106e617-9ba2-4c1b-a0a9-c493f72856a9	\N
848d593d-e6b9-489f-bfeb-6e8f4b49234a	2025-12-02 00:00:15.605678+00	2025-12-02 00:00:15.605697+00	SCHEDULED	2025-12-02 00:00:15.592332+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "843db310-214d-45ff-b7b1-5322e5eba0eb", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-02T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	843db310-214d-45ff-b7b1-5322e5eba0eb	\N
a564f4c3-7c23-4ca7-b232-4c65b0604ddb	2025-12-02 00:00:41.987954+00	2025-12-02 00:00:41.987976+00	SCHEDULED	2025-12-02 00:00:41.97473+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-05T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	1a113ce3-6130-4db8-9865-2792ff6b7a48	\N
5520c329-9b70-4608-b63d-4f00d46f5894	2025-12-02 02:00:17.638347+00	2025-12-02 02:00:17.638366+00	SCHEDULED	2025-12-02 02:00:17.622051+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "17073ad8-747b-44fd-b4b1-603a144b32f8", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-02T02:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	17073ad8-747b-44fd-b4b1-603a144b32f8	\N
9f5fa9f2-831a-4bca-8b34-fa82af4b1b29	2025-12-02 02:00:42.153794+00	2025-12-02 02:00:42.153819+00	SCHEDULED	2025-12-02 02:00:42.136944+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-03-02T02:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	2b65ad67-5bb3-4ff2-bcb0-1257eaba7dfd	\N
d8535e27-08cf-475b-89ee-e1983afd200c	2025-12-03 00:00:18.527012+00	2025-12-03 00:00:18.52703+00	SCHEDULED	2025-12-03 00:00:18.511592+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "7c1762ef-349c-4f18-94ed-52bf2d65291f", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-03T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	7c1762ef-349c-4f18-94ed-52bf2d65291f	\N
fa0044f9-caee-4076-9998-a48521fe834a	2025-12-03 00:00:43.943059+00	2025-12-03 00:00:43.943081+00	SCHEDULED	2025-12-03 00:00:43.931045+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-06T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	f22aeee2-42e4-4354-9889-838df3bdfc3c	\N
99952201-761c-4988-9173-09a8f32a8661	2025-12-06 00:00:18.399462+00	2025-12-06 00:00:18.399494+00	SCHEDULED	2025-12-06 00:00:18.383322+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "f22aeee2-42e4-4354-9889-838df3bdfc3c", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-06T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	f22aeee2-42e4-4354-9889-838df3bdfc3c	\N
fbea3dca-7e8a-4582-be35-85f60e86453a	2025-12-08 00:00:18.319655+00	2025-12-08 00:00:18.319672+00	SCHEDULED	2025-12-08 00:00:18.307796+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "777d4fb3-bff5-42d3-99ef-ae1df2c6229d", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-08T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	777d4fb3-bff5-42d3-99ef-ae1df2c6229d	\N
7ba94ce9-5d42-44b7-a822-20e5878ce6de	2025-12-08 00:00:53.208222+00	2025-12-08 00:00:53.208244+00	SCHEDULED	2025-12-08 00:00:53.19531+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-11T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	ca408b34-04d2-4b44-83f7-c7ed0b2bdd29	\N
9d0749fe-dbfd-4533-b73a-703bf1540a98	2025-12-09 00:00:55.075191+00	2025-12-09 00:00:55.075205+00	SCHEDULED	2025-12-09 00:00:55.067222+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-12T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	e027892b-2073-4a73-9fb0-053bc02720d4	\N
a7baf428-25b8-494d-aa7f-52cb644ce4b9	2025-12-12 00:00:00.602488+00	2025-12-12 00:00:00.602514+00	SCHEDULED	2025-12-12 00:00:00.588607+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-15T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	e4b16a72-9ce2-435c-85cb-bef4871d7cb5	\N
c803834b-a417-4fd5-a17b-1e40b9fbb4fe	2025-12-14 00:00:04.436855+00	2025-12-14 00:00:04.436881+00	SCHEDULED	2025-12-14 00:00:04.420522+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-17T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	74d0a57b-4aba-4eec-8817-88409b115c8e	\N
234d0c49-436b-476d-bf70-bbc80d8f06b7	2025-12-14 00:00:15.407871+00	2025-12-14 00:00:15.407891+00	SCHEDULED	2025-12-14 00:00:15.393869+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "624992be-c52f-43b8-99a5-3651db4cad6d", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-14T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	624992be-c52f-43b8-99a5-3651db4cad6d	\N
0700791b-04c8-4161-890c-546e3a722939	2025-12-15 00:00:06.429448+00	2025-12-15 00:00:06.429474+00	SCHEDULED	2025-12-15 00:00:06.416696+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-18T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	d0ac9ca1-2f79-49b4-9a2e-8361c2abc46d	\N
2be88a0d-bb8a-49ef-b0dc-cbaae965eb53	2025-12-15 00:00:18.890396+00	2025-12-15 00:00:18.890421+00	SCHEDULED	2025-12-15 00:00:18.864936+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "e4b16a72-9ce2-435c-85cb-bef4871d7cb5", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-15T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	e4b16a72-9ce2-435c-85cb-bef4871d7cb5	\N
a67af9c4-cdf8-48b0-b151-ff8d4105d177	2025-12-17 00:00:10.262819+00	2025-12-17 00:00:10.262841+00	SCHEDULED	2025-12-17 00:00:10.250838+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-20T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	3cfc62f3-d11a-4d7f-946b-107a730628e7	\N
4eeeeee5-b2bf-4d53-8dc2-16edb8a97675	2025-12-19 00:00:15.637062+00	2025-12-19 00:00:15.637074+00	SCHEDULED	2025-12-19 00:00:15.62939+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "b09071db-7494-45c9-aa14-03892847b9dd", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-19T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	b09071db-7494-45c9-aa14-03892847b9dd	\N
8956092d-f819-4a34-899a-eb19a6f030db	2025-12-20 00:00:15.235753+00	2025-12-20 00:00:15.235778+00	SCHEDULED	2025-12-20 00:00:15.221669+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-23T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	b24ce800-7315-446b-a68c-879289317622	\N
5a3626d0-4abc-4327-a431-6d537ec012a8	2025-12-21 00:00:17.086088+00	2025-12-21 00:00:17.086113+00	SCHEDULED	2025-12-21 00:00:17.07057+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-24T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	ceb83735-2900-4e5b-a916-f00a84bf76ed	\N
c4b9e739-015f-4c02-a8b5-53b7ac8ce102	2025-12-22 00:00:16.49947+00	2025-12-22 00:00:16.499491+00	SCHEDULED	2025-12-22 00:00:16.485549+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "f0aba532-b3f5-4271-a79b-df52d5d6eead", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-22T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	f0aba532-b3f5-4271-a79b-df52d5d6eead	\N
99665021-5690-4fc6-9c05-ee2c44f3cd51	2025-12-22 00:00:18.98859+00	2025-12-22 00:00:18.988616+00	SCHEDULED	2025-12-22 00:00:18.972325+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-25T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	622f880f-5d4c-4eaf-8676-ef14a75b31e8	\N
62746a66-f162-4588-a936-3f72f05cdad8	2025-12-04 00:00:16.856711+00	2025-12-04 00:00:16.856729+00	SCHEDULED	2025-12-04 00:00:16.843312+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "d62b2d0c-c5f7-4aaf-b3c2-4929893c9f2b", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-04T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	d62b2d0c-c5f7-4aaf-b3c2-4929893c9f2b	\N
58eab099-d239-44d9-a4fb-958574404031	2025-12-04 00:00:45.739962+00	2025-12-04 00:00:45.739988+00	SCHEDULED	2025-12-04 00:00:45.726202+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-07T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	d6ce72e1-9ad5-4862-bf1d-dd466cee59d3	\N
173e2b2e-d675-45c4-a9dc-599bdee461e9	2025-12-09 00:00:16.071587+00	2025-12-09 00:00:16.071607+00	SCHEDULED	2025-12-09 00:00:16.060041+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "e32da044-73da-4a04-89dc-6905dc048451", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-09T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	e32da044-73da-4a04-89dc-6905dc048451	\N
69ae8280-e626-4d07-9ea7-0cda86f67dc3	2025-12-10 00:00:56.817677+00	2025-12-10 00:00:56.817701+00	SCHEDULED	2025-12-10 00:00:56.804081+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-13T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	77703632-e8d8-4ea0-9f4e-25e9c17f6727	\N
c3a9068f-5dea-4bd7-8f7b-3222edf2c378	2025-12-11 00:00:15.453916+00	2025-12-11 00:00:15.453935+00	SCHEDULED	2025-12-11 00:00:15.439171+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "ca408b34-04d2-4b44-83f7-c7ed0b2bdd29", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-11T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	ca408b34-04d2-4b44-83f7-c7ed0b2bdd29	\N
73c6f7b3-d7ba-4ddf-a806-8b7c0ef253c3	2025-12-12 00:00:18.833153+00	2025-12-12 00:00:18.833172+00	SCHEDULED	2025-12-12 00:00:18.815891+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "e027892b-2073-4a73-9fb0-053bc02720d4", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-12T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	e027892b-2073-4a73-9fb0-053bc02720d4	\N
4c13e24d-d728-4923-802c-52537698d6dd	2025-12-18 00:00:11.992398+00	2025-12-18 00:00:11.992411+00	SCHEDULED	2025-12-18 00:00:11.983449+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-21T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	a96f76de-aab7-4969-a3fd-dd76b46784b8	\N
5aa694ca-15a5-405b-854b-9e284dc79554	2025-12-18 00:00:15.862091+00	2025-12-18 00:00:15.862104+00	SCHEDULED	2025-12-18 00:00:15.853518+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "d0ac9ca1-2f79-49b4-9a2e-8361c2abc46d", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-18T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	d0ac9ca1-2f79-49b4-9a2e-8361c2abc46d	\N
67c8552a-5f5e-4961-8c5f-15ee28a5c8a9	2025-12-20 00:00:20.00983+00	2025-12-20 00:00:20.009849+00	SCHEDULED	2025-12-20 00:00:19.993167+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "3cfc62f3-d11a-4d7f-946b-107a730628e7", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-20T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	3cfc62f3-d11a-4d7f-946b-107a730628e7	\N
31d85649-1586-4966-8d4d-2f491d41f8e1	2025-12-21 00:00:18.210264+00	2025-12-21 00:00:18.210301+00	SCHEDULED	2025-12-21 00:00:18.195514+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "a96f76de-aab7-4969-a3fd-dd76b46784b8", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-21T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	a96f76de-aab7-4969-a3fd-dd76b46784b8	\N
c5dc06e3-7fcf-467a-ae6f-d298ee5d95fa	2025-12-05 00:00:15.082538+00	2025-12-05 00:00:15.082556+00	SCHEDULED	2025-12-05 00:00:15.068611+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "1a113ce3-6130-4db8-9865-2792ff6b7a48", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-05T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	1a113ce3-6130-4db8-9865-2792ff6b7a48	\N
da2828eb-5500-4c1a-89e6-acf2f2c583b4	2025-12-05 00:00:47.651067+00	2025-12-05 00:00:47.651089+00	SCHEDULED	2025-12-05 00:00:47.639138+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-08T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	777d4fb3-bff5-42d3-99ef-ae1df2c6229d	\N
904b8965-1fee-4270-b8c8-36652f6f9baa	2025-12-06 00:00:49.568645+00	2025-12-06 00:00:49.568669+00	SCHEDULED	2025-12-06 00:00:49.55311+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-09T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	e32da044-73da-4a04-89dc-6905dc048451	\N
db82ad12-ffe0-49f4-9f02-37fa241bec7e	2025-12-07 00:00:16.041425+00	2025-12-07 00:00:16.041443+00	SCHEDULED	2025-12-07 00:00:16.02702+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "d6ce72e1-9ad5-4862-bf1d-dd466cee59d3", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-07T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	d6ce72e1-9ad5-4862-bf1d-dd466cee59d3	\N
057910b0-1f87-4cc9-91c6-cdb6200b0d0f	2025-12-07 00:00:51.40097+00	2025-12-07 00:00:51.400993+00	SCHEDULED	2025-12-07 00:00:51.388931+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-10T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	c10aee62-fa00-45c3-b8ac-3c7b901899b9	\N
e73a0d39-806c-47e8-81bb-07173d5116d6	2025-12-10 00:00:17.952939+00	2025-12-10 00:00:17.952979+00	SCHEDULED	2025-12-10 00:00:17.93551+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "c10aee62-fa00-45c3-b8ac-3c7b901899b9", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-10T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	c10aee62-fa00-45c3-b8ac-3c7b901899b9	\N
0fa99bb1-9141-48fb-b190-403e738c488d	2025-12-11 00:00:58.681835+00	2025-12-11 00:00:58.68186+00	SCHEDULED	2025-12-11 00:00:58.664743+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-14T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	624992be-c52f-43b8-99a5-3651db4cad6d	\N
2fc54086-a92f-4075-95d6-eb9f80663aa0	2025-12-13 00:00:02.52542+00	2025-12-13 00:00:02.525445+00	SCHEDULED	2025-12-13 00:00:02.512451+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-16T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	36a5863e-1a41-4732-b939-7eb2daca5744	\N
f5e7f300-dea4-45ae-a679-479537faa3d0	2025-12-13 00:00:16.992749+00	2025-12-13 00:00:16.992771+00	SCHEDULED	2025-12-13 00:00:16.978197+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "77703632-e8d8-4ea0-9f4e-25e9c17f6727", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-13T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	77703632-e8d8-4ea0-9f4e-25e9c17f6727	\N
a1d51442-81b8-4f50-8f69-10910dc5370f	2025-12-16 00:00:08.348452+00	2025-12-16 00:00:08.348477+00	SCHEDULED	2025-12-16 00:00:08.331978+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-19T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	b09071db-7494-45c9-aa14-03892847b9dd	\N
d1091caf-0dea-45b8-9171-2c3d65d97157	2025-12-16 00:00:17.456702+00	2025-12-16 00:00:17.45672+00	SCHEDULED	2025-12-16 00:00:17.442948+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "36a5863e-1a41-4732-b939-7eb2daca5744", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-16T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	36a5863e-1a41-4732-b939-7eb2daca5744	\N
cd0e6e51-59f4-4aeb-98c1-b1702751a6c1	2025-12-17 00:00:15.505766+00	2025-12-17 00:00:15.505787+00	SCHEDULED	2025-12-17 00:00:15.489817+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "74d0a57b-4aba-4eec-8817-88409b115c8e", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-17T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	74d0a57b-4aba-4eec-8817-88409b115c8e	\N
6c404d6b-b470-4953-9b61-184fc8c0cd54	2025-12-19 00:00:13.60544+00	2025-12-19 00:00:13.60546+00	SCHEDULED	2025-12-19 00:00:13.597658+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-22T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	f0aba532-b3f5-4271-a79b-df52d5d6eead	\N
d23a3bd1-15a4-47d3-9bd2-ef0e64cae1e5	2025-12-23 00:00:19.733923+00	2025-12-23 00:00:19.733942+00	SCHEDULED	2025-12-23 00:00:19.719174+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "b24ce800-7315-446b-a68c-879289317622", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-23T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	b24ce800-7315-446b-a68c-879289317622	\N
54f6d073-c04d-4fcf-a9a1-046c5233996c	2025-12-23 00:00:20.969978+00	2025-12-23 00:00:20.970004+00	SCHEDULED	2025-12-23 00:00:20.954477+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-26T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	f9164581-4d26-4223-818e-b95d506befb9	\N
4587de7e-9dc1-49ad-8108-e20f155a93be	2025-12-24 00:00:18.292854+00	2025-12-24 00:00:18.292873+00	SCHEDULED	2025-12-24 00:00:18.279943+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "ceb83735-2900-4e5b-a916-f00a84bf76ed", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-24T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	ceb83735-2900-4e5b-a916-f00a84bf76ed	\N
381d7a79-6545-4264-b6f9-43ecdc00bcdc	2025-12-24 00:00:22.898187+00	2025-12-24 00:00:22.898212+00	SCHEDULED	2025-12-24 00:00:22.884169+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-27T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	4a4b00d0-957b-4e9f-be10-a5179d48329c	\N
eac56d76-642c-4ef3-9e88-c63d7b80ef46	2025-12-25 00:00:16.983725+00	2025-12-25 00:00:16.983743+00	SCHEDULED	2025-12-25 00:00:16.968212+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "622f880f-5d4c-4eaf-8676-ef14a75b31e8", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-25T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	622f880f-5d4c-4eaf-8676-ef14a75b31e8	\N
f34f7f8f-711b-485b-ad17-abb6b626f246	2025-12-25 00:00:24.771562+00	2025-12-25 00:00:24.771585+00	SCHEDULED	2025-12-25 00:00:24.758495+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-28T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	4eadc0aa-1ceb-4f97-8a31-f5e8e811ba68	\N
b29cd8f2-da75-41ec-a64d-f63253b1756e	2025-12-26 00:00:15.431201+00	2025-12-26 00:00:15.43122+00	SCHEDULED	2025-12-26 00:00:15.416923+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "f9164581-4d26-4223-818e-b95d506befb9", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-26T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	f9164581-4d26-4223-818e-b95d506befb9	\N
a464274e-9961-4e54-95f9-0e217c342d44	2025-12-26 00:00:26.726328+00	2025-12-26 00:00:26.726352+00	SCHEDULED	2025-12-26 00:00:26.711842+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-29T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	18dcbb2f-db7d-4fab-8608-2673c4892985	\N
320b9fa3-e837-4d67-9012-fc27ef92b54f	2025-12-27 00:00:19.309893+00	2025-12-27 00:00:19.309914+00	SCHEDULED	2025-12-27 00:00:19.294549+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "4a4b00d0-957b-4e9f-be10-a5179d48329c", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-27T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	4a4b00d0-957b-4e9f-be10-a5179d48329c	\N
44db17ea-8363-4ffa-9716-9dd8d6c7b79a	2025-12-27 00:00:28.644646+00	2025-12-27 00:00:28.644671+00	SCHEDULED	2025-12-27 00:00:28.629719+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-30T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	40db4190-7b97-407a-b5c5-68bb5a4835de	\N
f6f159df-87ae-499c-a27b-91ca303b2b1b	2025-12-28 00:00:18.175521+00	2025-12-28 00:00:18.175544+00	SCHEDULED	2025-12-28 00:00:18.157825+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "4eadc0aa-1ceb-4f97-8a31-f5e8e811ba68", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-28T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	4eadc0aa-1ceb-4f97-8a31-f5e8e811ba68	\N
3391789e-4af7-4d7a-a82e-157f24a90fba	2025-12-28 00:00:30.574004+00	2025-12-28 00:00:30.574028+00	SCHEDULED	2025-12-28 00:00:30.559321+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-31T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	7960a986-6f03-4ae6-b011-6c89c0cbf40e	\N
823b0e18-a3a5-423b-b72a-624eb48755e4	2025-12-29 00:00:16.689235+00	2025-12-29 00:00:16.689255+00	SCHEDULED	2025-12-29 00:00:16.676904+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "18dcbb2f-db7d-4fab-8608-2673c4892985", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-29T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	18dcbb2f-db7d-4fab-8608-2673c4892985	\N
2e51c5b5-c925-4b2b-9ec7-d74d8943ce7e	2025-12-29 00:00:32.444591+00	2025-12-29 00:00:32.444615+00	SCHEDULED	2025-12-29 00:00:32.429369+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-01T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	11c597e4-d1c4-430e-8857-5ed0abe5128c	\N
7a100e9e-33d4-41b9-a89e-8a2101e76d88	2025-12-30 00:00:11.393262+00	2025-12-30 00:00:11.393282+00	SCHEDULED	2025-12-30 00:00:11.309016+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-02T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	406d536e-6610-402e-ba41-e4e5b1bef57b	\N
d602d916-9f94-41a7-90f1-0e040506207f	2025-12-30 00:00:16.044894+00	2025-12-30 00:00:16.044907+00	SCHEDULED	2025-12-30 00:00:16.028138+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "40db4190-7b97-407a-b5c5-68bb5a4835de", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-30T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	40db4190-7b97-407a-b5c5-68bb5a4835de	\N
b5a57141-925d-449c-bff5-604940a72318	2025-12-31 00:00:19.220347+00	2025-12-31 00:00:19.22036+00	SCHEDULED	2025-12-31 00:00:19.18057+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "7960a986-6f03-4ae6-b011-6c89c0cbf40e", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2025-12-31T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	7960a986-6f03-4ae6-b011-6c89c0cbf40e	\N
39bf0c40-5a40-4f1a-a9a2-6979aed3ad9c	2025-12-31 00:00:39.517452+00	2025-12-31 00:00:39.517471+00	SCHEDULED	2025-12-31 00:00:39.472228+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-03T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	9ab35af2-6fad-4162-891c-b259a43eba17	\N
00a96b15-e7e3-4c23-be27-bccc5d460b9f	2026-01-01 00:00:15.163523+00	2026-01-01 00:00:15.163535+00	SCHEDULED	2026-01-01 00:00:15.153112+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "11c597e4-d1c4-430e-8857-5ed0abe5128c", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-01T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	11c597e4-d1c4-430e-8857-5ed0abe5128c	\N
33a19824-ae86-40bc-b663-7951390511ab	2026-01-01 00:00:40.783418+00	2026-01-01 00:00:40.783431+00	SCHEDULED	2026-01-01 00:00:40.77622+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-04T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	22fe108a-bad9-483d-82c8-963ed92ff10c	\N
289c7995-f533-4a9a-a75e-806bc9d15cb1	2026-01-01 01:00:15.829875+00	2026-01-01 01:00:15.829892+00	SCHEDULED	2026-01-01 01:00:15.819328+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "f7965b9c-96b2-4635-af3d-7d5056cdae70", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-01T01:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	f7965b9c-96b2-4635-af3d-7d5056cdae70	\N
708cdb0a-8e88-4a43-8827-927fb82e3bff	2026-01-01 01:00:40.845469+00	2026-01-01 01:00:40.845481+00	SCHEDULED	2026-01-01 01:00:40.836528+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-04-01T01:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	bbf34c77-e6c9-4c62-87d5-80565a889aaa	\N
82c175ac-9176-4338-9df5-abac0144561e	2026-01-02 00:00:16.213371+00	2026-01-02 00:00:16.213383+00	SCHEDULED	2026-01-02 00:00:16.203076+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "406d536e-6610-402e-ba41-e4e5b1bef57b", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-02T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	406d536e-6610-402e-ba41-e4e5b1bef57b	\N
921ad159-06d6-49a9-987f-e133375afb38	2026-01-02 00:00:42.109023+00	2026-01-02 00:00:42.109035+00	SCHEDULED	2026-01-02 00:00:42.101969+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-05T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	44eba868-9803-4d32-9a8d-c2556fe722ee	\N
249c2ea5-95aa-443f-83fc-ab249c476814	2026-01-02 02:00:17.565957+00	2026-01-02 02:00:17.56597+00	SCHEDULED	2026-01-02 02:00:17.55828+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "ca26ca1c-b7ee-46b6-acd5-c91fa3b16c0c", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-02T02:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	ca26ca1c-b7ee-46b6-acd5-c91fa3b16c0c	\N
5de72a03-abf2-4a1d-a4ec-da3ec290d15b	2026-01-02 02:00:42.223327+00	2026-01-02 02:00:42.22334+00	SCHEDULED	2026-01-02 02:00:42.213952+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-04-02T02:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	7c41b2f3-47d8-4a67-8675-d39745e166ae	\N
889f2833-69a0-48c3-bf74-29ae61657561	2026-01-03 00:00:17.218404+00	2026-01-03 00:00:17.218418+00	SCHEDULED	2026-01-03 00:00:17.210849+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "9ab35af2-6fad-4162-891c-b259a43eba17", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-03T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	9ab35af2-6fad-4162-891c-b259a43eba17	\N
4b11cbb5-58c5-4f29-bde1-9e039b09fd19	2026-01-03 00:00:43.479468+00	2026-01-03 00:00:43.47948+00	SCHEDULED	2026-01-03 00:00:43.472717+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-06T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	12300b3e-737f-417c-9461-d186964da0c4	\N
b213455e-034b-41df-a183-1449853cc78f	2026-01-04 00:00:18.255148+00	2026-01-04 00:00:18.25516+00	SCHEDULED	2026-01-04 00:00:18.244916+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "22fe108a-bad9-483d-82c8-963ed92ff10c", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-04T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	22fe108a-bad9-483d-82c8-963ed92ff10c	\N
b771e3eb-73eb-4c47-b040-1b8567cf6d4a	2026-01-04 00:00:44.821924+00	2026-01-04 00:00:44.821937+00	SCHEDULED	2026-01-04 00:00:44.807431+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-07T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	a522c4cb-c440-41fc-ab20-6e214fbc6722	\N
7d00ce3e-5724-4bab-9558-6bc9cfaf0dea	2026-01-05 00:00:19.324174+00	2026-01-05 00:00:19.324185+00	SCHEDULED	2026-01-05 00:00:19.315796+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "44eba868-9803-4d32-9a8d-c2556fe722ee", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-05T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	44eba868-9803-4d32-9a8d-c2556fe722ee	\N
1ac055bd-6cdc-49c8-94f1-358482c5dd86	2026-01-05 00:00:46.196414+00	2026-01-05 00:00:46.196428+00	SCHEDULED	2026-01-05 00:00:46.186622+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-08T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	cb8afdca-b7e4-49ff-a2b5-5fec3424034e	\N
af42d62c-9f64-403c-b6d5-bbb63d370dcd	2026-01-06 00:00:17.223947+00	2026-01-06 00:00:17.223966+00	SCHEDULED	2026-01-06 00:00:17.210013+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "12300b3e-737f-417c-9461-d186964da0c4", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-06T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	12300b3e-737f-417c-9461-d186964da0c4	\N
74c4248b-5306-4edc-8b47-346194a0552d	2026-01-06 00:00:47.708219+00	2026-01-06 00:00:47.70826+00	SCHEDULED	2026-01-06 00:00:47.695626+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-09T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	42fe8ddd-5c20-41f4-8ec8-bf6d22f0fd80	\N
18fa2260-679e-46c0-9353-2527c0534263	2026-01-07 00:00:15.282914+00	2026-01-07 00:00:15.282933+00	SCHEDULED	2026-01-07 00:00:15.270206+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "a522c4cb-c440-41fc-ab20-6e214fbc6722", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-07T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	a522c4cb-c440-41fc-ab20-6e214fbc6722	\N
7d63f8e5-6fe2-47c5-81dc-614931d28816	2026-01-07 00:00:49.22758+00	2026-01-07 00:00:49.227605+00	SCHEDULED	2026-01-07 00:00:49.213812+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-10T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	c951d9b0-7e9f-4f64-8c09-dc3c9ee45108	\N
3516a423-7770-4e6b-b25e-94451864a793	2026-01-08 00:00:18.312996+00	2026-01-08 00:00:18.313016+00	SCHEDULED	2026-01-08 00:00:18.300667+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "cb8afdca-b7e4-49ff-a2b5-5fec3424034e", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-08T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	cb8afdca-b7e4-49ff-a2b5-5fec3424034e	\N
3758d74b-b66c-4a7c-8816-fe0749a2ee6d	2026-01-08 00:00:50.724268+00	2026-01-08 00:00:50.72429+00	SCHEDULED	2026-01-08 00:00:50.71131+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-11T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	a49bbd79-770e-44de-a40e-f3404ec96a4c	\N
115fd51c-7845-406e-90ee-37d41c32646a	2026-01-10 00:00:53.724141+00	2026-01-10 00:00:53.724164+00	SCHEDULED	2026-01-10 00:00:53.711638+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-13T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	131ac30c-6c09-4348-a944-731ee75d9cc4	\N
9af83f0b-d1e5-49a4-a4ce-ae6b2f8fb014	2026-01-11 00:00:55.223002+00	2026-01-11 00:00:55.223027+00	SCHEDULED	2026-01-11 00:00:55.210004+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-14T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	579194af-2f5c-4088-8846-a2b35b0abef7	\N
654292a8-bb3c-40f8-9c21-59ea5fa8db78	2026-01-12 00:00:15.639127+00	2026-01-12 00:00:15.639147+00	SCHEDULED	2026-01-12 00:00:15.625957+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "07fc47dc-39c7-4cce-bb02-25c7d0e29992", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-12T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	07fc47dc-39c7-4cce-bb02-25c7d0e29992	\N
36f967e8-edd4-4de0-a8b8-7d77c576ee4b	2026-01-12 00:00:56.726141+00	2026-01-12 00:00:56.726163+00	SCHEDULED	2026-01-12 00:00:56.713337+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-15T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	870aab41-3b1b-4af7-a504-ef1c272f49d8	\N
15967337-386b-464a-a98d-7712d0be6260	2026-01-15 00:00:15.123197+00	2026-01-15 00:00:15.123217+00	SCHEDULED	2026-01-15 00:00:15.109988+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "870aab41-3b1b-4af7-a504-ef1c272f49d8", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-15T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	870aab41-3b1b-4af7-a504-ef1c272f49d8	\N
a626abd0-6c32-4dba-b6eb-9c2674f0e17e	2026-01-17 00:00:16.298706+00	2026-01-17 00:00:16.298723+00	SCHEDULED	2026-01-17 00:00:16.286698+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "505abe48-d621-47cd-a829-0fe6c84e62fe", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-17T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	505abe48-d621-47cd-a829-0fe6c84e62fe	\N
6fda17cc-650e-4230-ae87-4ab73ff4d8f1	2026-01-18 00:00:19.299837+00	2026-01-18 00:00:19.299854+00	SCHEDULED	2026-01-18 00:00:19.288201+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "63c85525-2c76-45a0-931c-6395ffa9a309", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-18T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	63c85525-2c76-45a0-931c-6395ffa9a309	\N
d3ea2fcf-51b5-48cc-b63e-d2d11687601d	2026-01-20 00:00:08.763454+00	2026-01-20 00:00:08.763477+00	SCHEDULED	2026-01-20 00:00:08.748901+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-23T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	9496431f-dfbe-4c11-b799-e799f38da912	\N
10e772b8-0768-47c2-bc35-a9fa00feddfc	2026-01-22 00:00:11.789116+00	2026-01-22 00:00:11.789138+00	SCHEDULED	2026-01-22 00:00:11.777308+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-25T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	a1d03b19-a14f-4789-9079-1df59220e74c	\N
2a079c1d-9110-4c28-ae4b-3a5d2b1c24d5	2026-01-24 00:00:14.815016+00	2026-01-24 00:00:14.815037+00	SCHEDULED	2026-01-24 00:00:14.803469+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-27T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	5bf1d57e-c266-4929-bf90-9875c1429cc1	\N
ed8bb0b8-5eae-41f1-a91c-e7cfa9d5f8ae	2026-01-09 00:00:16.393019+00	2026-01-09 00:00:16.393038+00	SCHEDULED	2026-01-09 00:00:16.380181+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "42fe8ddd-5c20-41f4-8ec8-bf6d22f0fd80", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-09T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	42fe8ddd-5c20-41f4-8ec8-bf6d22f0fd80	\N
632bdb51-dd3b-47eb-9337-d614a9cebe95	2026-01-13 00:00:58.237966+00	2026-01-13 00:00:58.237986+00	SCHEDULED	2026-01-13 00:00:58.225539+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-16T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	d841e1c8-3b27-4fde-be03-b23ead6d1c41	\N
6136be28-efaf-4be1-9917-02f683cf11de	2026-01-14 00:00:16.933111+00	2026-01-14 00:00:16.933132+00	SCHEDULED	2026-01-14 00:00:16.91967+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "579194af-2f5c-4088-8846-a2b35b0abef7", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-14T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	579194af-2f5c-4088-8846-a2b35b0abef7	\N
9cb4653e-2b5e-4c62-b206-84b490669eb8	2026-01-14 00:00:59.751756+00	2026-01-14 00:00:59.751776+00	SCHEDULED	2026-01-14 00:00:59.73993+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-17T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	505abe48-d621-47cd-a829-0fe6c84e62fe	\N
e42c1aa7-d8ed-4e59-8323-3ccb026a3f18	2026-01-18 00:00:05.760796+00	2026-01-18 00:00:05.76082+00	SCHEDULED	2026-01-18 00:00:05.747428+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-21T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	08ef0d69-493a-4d82-82ba-968b784260b4	\N
ae564d75-f5f7-4551-af9b-7cc8ca2245f7	2026-01-19 00:00:17.338169+00	2026-01-19 00:00:17.338191+00	SCHEDULED	2026-01-19 00:00:17.3242+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "8565270e-9f12-40dd-a232-9e550d7d2a35", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-19T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	8565270e-9f12-40dd-a232-9e550d7d2a35	\N
1869f008-c36a-4c23-966a-193ae51c55e2	2026-01-20 00:00:15.403782+00	2026-01-20 00:00:15.403805+00	SCHEDULED	2026-01-20 00:00:15.390615+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "444cdff0-54f0-4324-aba9-193def0cc7d6", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-20T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	444cdff0-54f0-4324-aba9-193def0cc7d6	\N
270ba07b-5fec-47d0-ad82-c7959e6b964f	2026-01-21 00:00:10.278888+00	2026-01-21 00:00:10.27891+00	SCHEDULED	2026-01-21 00:00:10.267144+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-24T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	c23355d7-02f7-48b1-b655-864906b2439b	\N
e3a94ff6-99c9-4197-b5f6-5198de8549bb	2026-01-21 00:00:18.549868+00	2026-01-21 00:00:18.549888+00	SCHEDULED	2026-01-21 00:00:18.536074+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "08ef0d69-493a-4d82-82ba-968b784260b4", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-21T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	08ef0d69-493a-4d82-82ba-968b784260b4	\N
510bc244-5938-48a3-b372-c80ebe729871	2026-01-22 00:00:16.684171+00	2026-01-22 00:00:16.684189+00	SCHEDULED	2026-01-22 00:00:16.671836+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "1c16706f-dae4-40d8-bba4-849cc8c1b5c8", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-22T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	1c16706f-dae4-40d8-bba4-849cc8c1b5c8	\N
2e36aa53-bf39-47c0-83f2-09e9939e6738	2026-01-23 00:00:13.322779+00	2026-01-23 00:00:13.3228+00	SCHEDULED	2026-01-23 00:00:13.310608+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-26T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	6f97a160-ed1b-4993-a774-9878ebc979da	\N
e6ba0684-3343-4cae-a058-d7817847b200	2026-01-23 00:00:19.867432+00	2026-01-23 00:00:19.867451+00	SCHEDULED	2026-01-23 00:00:19.855619+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "9496431f-dfbe-4c11-b799-e799f38da912", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-23T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	9496431f-dfbe-4c11-b799-e799f38da912	\N
6c892ea0-d3a6-41be-b543-18c0c448808c	2026-01-09 00:00:52.214513+00	2026-01-09 00:00:52.21454+00	SCHEDULED	2026-01-09 00:00:52.198005+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-12T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	07fc47dc-39c7-4cce-bb02-25c7d0e29992	\N
19cc8258-b64c-4384-9135-1bf9fc38387e	2026-01-10 00:00:19.511994+00	2026-01-10 00:00:19.512012+00	SCHEDULED	2026-01-10 00:00:19.499343+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "c951d9b0-7e9f-4f64-8c09-dc3c9ee45108", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-10T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	c951d9b0-7e9f-4f64-8c09-dc3c9ee45108	\N
33f508c6-f012-4d5d-be01-718e8e1b64bd	2026-01-11 00:00:17.590129+00	2026-01-11 00:00:17.590148+00	SCHEDULED	2026-01-11 00:00:17.576767+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "a49bbd79-770e-44de-a40e-f3404ec96a4c", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-11T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	a49bbd79-770e-44de-a40e-f3404ec96a4c	\N
22679bfa-10e5-46d9-aef9-c13cb9db047f	2026-01-13 00:00:18.752856+00	2026-01-13 00:00:18.752877+00	SCHEDULED	2026-01-13 00:00:18.739863+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "131ac30c-6c09-4348-a944-731ee75d9cc4", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-13T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	131ac30c-6c09-4348-a944-731ee75d9cc4	\N
dff5e367-0b82-4cfe-8ec7-85ce990f6312	2026-01-15 00:00:01.265395+00	2026-01-15 00:00:01.265415+00	SCHEDULED	2026-01-15 00:00:01.252147+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-18T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	63c85525-2c76-45a0-931c-6395ffa9a309	\N
a78f384b-66df-446d-9270-06db0211af1f	2026-01-16 00:00:02.777485+00	2026-01-16 00:00:02.777514+00	SCHEDULED	2026-01-16 00:00:02.763172+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-19T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	8565270e-9f12-40dd-a232-9e550d7d2a35	\N
9851d167-3481-4267-a057-a1b0d28ad779	2026-01-16 00:00:18.275719+00	2026-01-16 00:00:18.275738+00	SCHEDULED	2026-01-16 00:00:18.262732+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "d841e1c8-3b27-4fde-be03-b23ead6d1c41", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-16T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	d841e1c8-3b27-4fde-be03-b23ead6d1c41	\N
5e1a25fa-81e3-4ac7-be1d-0803ab419a92	2026-01-17 00:00:04.274447+00	2026-01-17 00:00:04.274469+00	SCHEDULED	2026-01-17 00:00:04.261193+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-20T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	444cdff0-54f0-4324-aba9-193def0cc7d6	\N
ff07bbac-1a74-40b5-b47c-58712002441b	2026-01-19 00:00:07.25692+00	2026-01-19 00:00:07.256942+00	SCHEDULED	2026-01-19 00:00:07.243842+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-22T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	1c16706f-dae4-40d8-bba4-849cc8c1b5c8	\N
6eb57b8c-6b44-44f3-8cef-861a25603654	2026-01-24 00:00:17.995216+00	2026-01-24 00:00:17.995252+00	SCHEDULED	2026-01-24 00:00:17.981449+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "c23355d7-02f7-48b1-b655-864906b2439b", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-24T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	c23355d7-02f7-48b1-b655-864906b2439b	\N
f63f7d9a-6ad8-48bd-a92c-0783e1ed6367	2026-01-25 00:00:18.500463+00	2026-01-25 00:00:18.500476+00	SCHEDULED	2026-01-25 00:00:18.459211+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "a1d03b19-a14f-4789-9079-1df59220e74c", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-25T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	a1d03b19-a14f-4789-9079-1df59220e74c	\N
75d625e5-b0bc-4323-a239-03555ae3d99d	2026-01-25 00:00:50.422858+00	2026-01-25 00:00:50.422873+00	SCHEDULED	2026-01-25 00:00:50.384794+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-28T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	51776141-ef3b-45a7-a20a-6679c5cf208a	\N
7e3b1894-e9e0-4b07-b681-907d92ba0a21	2026-01-26 00:00:18.509596+00	2026-01-26 00:00:18.509609+00	SCHEDULED	2026-01-26 00:00:18.45553+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "6f97a160-ed1b-4993-a774-9878ebc979da", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-26T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	6f97a160-ed1b-4993-a774-9878ebc979da	\N
9213c799-a5c0-4674-9436-c646763e4d42	2026-01-26 00:00:53.17692+00	2026-01-26 00:00:53.176933+00	SCHEDULED	2026-01-26 00:00:53.14185+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-29T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	d88035d5-b4cc-4ac8-96f5-142c3f8682e6	\N
c3557fa7-b280-44e4-a81d-91e4054220e5	2026-01-27 00:00:19.719842+00	2026-01-27 00:00:19.719855+00	SCHEDULED	2026-01-27 00:00:19.708792+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "5bf1d57e-c266-4929-bf90-9875c1429cc1", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-27T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	5bf1d57e-c266-4929-bf90-9875c1429cc1	\N
fe863959-83f5-48e1-b366-e5bf71b699d9	2026-01-27 00:00:54.488558+00	2026-01-27 00:00:54.488571+00	SCHEDULED	2026-01-27 00:00:54.476908+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-30T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	1a6c7c5b-4cb1-47b5-a2a8-4e03163e164b	\N
f3800b06-a5cc-4eaa-8e0d-d6797d3c0cba	2026-01-28 00:00:15.938522+00	2026-01-28 00:00:15.938535+00	SCHEDULED	2026-01-28 00:00:15.929707+00	Late	\N	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": "51776141-ef3b-45a7-a20a-6679c5cf208a", "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-28T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	\N	51776141-ef3b-45a7-a20a-6679c5cf208a	\N
8b4b6e48-95ad-4030-940a-6ce9f006c89c	2026-01-28 00:00:55.812232+00	2026-01-28 00:00:55.812262+00	SCHEDULED	2026-01-28 00:00:55.804619+00	Scheduled	Flow run scheduled	{"cache_key": null, "pause_key": null, "retriable": null, "flow_run_id": null, "task_run_id": null, "pause_timeout": null, "refresh_cache": null, "transition_id": null, "scheduled_time": "2026-01-31T00:00:00+00:00", "cache_expiration": null, "pause_reschedule": false, "run_input_keyset": null, "child_flow_run_id": null, "task_parameters_id": null, "untrackable_result": false}	null	48c9d84d-ac78-4c93-a538-4e43e617ab38	\N
\.


--
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.log (id, created, updated, name, level, flow_run_id, task_run_id, message, "timestamp") FROM stdin;
\.


--
-- Data for Name: saved_search; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.saved_search (id, created, updated, name, filters) FROM stdin;
\.


--
-- Data for Name: task_run; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.task_run (id, created, updated, name, state_type, run_count, expected_start_time, next_scheduled_start_time, start_time, end_time, total_run_time, task_key, dynamic_key, cache_key, cache_expiration, task_version, empirical_policy, task_inputs, tags, flow_run_id, state_id, state_name, state_timestamp, flow_run_run_count) FROM stdin;
\.


--
-- Data for Name: task_run_state; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.task_run_state (id, created, updated, type, "timestamp", name, message, state_details, data, task_run_id, result_artifact_id) FROM stdin;
\.


--
-- Data for Name: task_run_state_cache; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.task_run_state_cache (id, created, updated, cache_key, cache_expiration, task_run_state_id) FROM stdin;
\.


--
-- Data for Name: variable; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.variable (id, created, updated, name, value, tags) FROM stdin;
\.


--
-- Data for Name: work_pool; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.work_pool (id, created, updated, name, description, type, base_job_template, is_paused, concurrency_limit, default_queue_id, status, last_transitioned_status_at, last_status_event_id) FROM stdin;
c9f64874-7b23-49a2-8da7-38f132af7ca5	2025-11-12 11:45:02.667082+00	2025-11-12 11:45:02.667812+00	default-pool	\N	process	{"variables": {"type": "object", "properties": {"env": {"type": "object", "title": "Environment Variables", "description": "Environment variables to set when starting a flow run.", "additionalProperties": {"type": "string"}}, "name": {"type": "string", "title": "Name", "description": "Name given to infrastructure created by a worker."}, "labels": {"type": "object", "title": "Labels", "description": "Labels applied to infrastructure created by a worker.", "additionalProperties": {"type": "string"}}, "command": {"type": "string", "title": "Command", "description": "The command to use when starting a flow run. In most cases, this should be left blank and the command will be automatically generated by the worker."}, "working_dir": {"type": "string", "title": "Working Directory", "format": "path", "description": "If provided, workers will open flow run processes within the specified path as the working directory. Otherwise, a temporary directory will be created."}, "stream_output": {"type": "boolean", "title": "Stream Output", "default": true, "description": "If enabled, workers will stream output from flow run processes to local standard output."}}}, "job_configuration": {"env": "{{ env }}", "name": "{{ name }}", "labels": "{{ labels }}", "command": "{{ command }}", "working_dir": "{{ working_dir }}", "stream_output": "{{ stream_output }}"}}	f	\N	8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	NOT_READY	\N	\N
\.


--
-- Data for Name: work_queue; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.work_queue (id, created, updated, name, filter, description, is_paused, concurrency_limit, last_polled, priority, work_pool_id, status) FROM stdin;
8484fa2b-0d2d-4f04-86d9-0a21a7287d3e	2025-11-12 11:45:02.725321+00	2025-11-12 11:45:02.725363+00	default	\N	The work pool's default queue.	f	\N	\N	1	c9f64874-7b23-49a2-8da7-38f132af7ca5	NOT_READY
\.


--
-- Data for Name: worker; Type: TABLE DATA; Schema: public; Owner: prefect
--

COPY public.worker (id, created, updated, name, last_heartbeat_time, work_pool_id, heartbeat_interval_seconds, status) FROM stdin;
\.


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: agent pk_agent; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.agent
    ADD CONSTRAINT pk_agent PRIMARY KEY (id);


--
-- Name: artifact pk_artifact; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.artifact
    ADD CONSTRAINT pk_artifact PRIMARY KEY (id);


--
-- Name: artifact_collection pk_artifact_collection; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.artifact_collection
    ADD CONSTRAINT pk_artifact_collection PRIMARY KEY (id);


--
-- Name: automation pk_automation; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.automation
    ADD CONSTRAINT pk_automation PRIMARY KEY (id);


--
-- Name: automation_bucket pk_automation_bucket; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.automation_bucket
    ADD CONSTRAINT pk_automation_bucket PRIMARY KEY (id);


--
-- Name: automation_event_follower pk_automation_event_follower; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.automation_event_follower
    ADD CONSTRAINT pk_automation_event_follower PRIMARY KEY (id);


--
-- Name: automation_related_resource pk_automation_related_resource; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.automation_related_resource
    ADD CONSTRAINT pk_automation_related_resource PRIMARY KEY (id);


--
-- Name: block_document pk_block_document; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.block_document
    ADD CONSTRAINT pk_block_document PRIMARY KEY (id);


--
-- Name: block_document_reference pk_block_document_reference; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.block_document_reference
    ADD CONSTRAINT pk_block_document_reference PRIMARY KEY (id);


--
-- Name: block_schema pk_block_schema; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.block_schema
    ADD CONSTRAINT pk_block_schema PRIMARY KEY (id);


--
-- Name: block_schema_reference pk_block_schema_reference; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.block_schema_reference
    ADD CONSTRAINT pk_block_schema_reference PRIMARY KEY (id);


--
-- Name: block_type pk_block_type; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.block_type
    ADD CONSTRAINT pk_block_type PRIMARY KEY (id);


--
-- Name: composite_trigger_child_firing pk_composite_trigger_child_firing; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.composite_trigger_child_firing
    ADD CONSTRAINT pk_composite_trigger_child_firing PRIMARY KEY (id);


--
-- Name: concurrency_limit pk_concurrency_limit; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.concurrency_limit
    ADD CONSTRAINT pk_concurrency_limit PRIMARY KEY (id);


--
-- Name: concurrency_limit_v2 pk_concurrency_limit_v2; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.concurrency_limit_v2
    ADD CONSTRAINT pk_concurrency_limit_v2 PRIMARY KEY (id);


--
-- Name: configuration pk_configuration; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT pk_configuration PRIMARY KEY (id);


--
-- Name: csrf_token pk_csrf_token; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.csrf_token
    ADD CONSTRAINT pk_csrf_token PRIMARY KEY (id);


--
-- Name: deployment pk_deployment; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.deployment
    ADD CONSTRAINT pk_deployment PRIMARY KEY (id);


--
-- Name: deployment_schedule pk_deployment_schedule; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.deployment_schedule
    ADD CONSTRAINT pk_deployment_schedule PRIMARY KEY (id);


--
-- Name: event_resources pk_event_resources; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.event_resources
    ADD CONSTRAINT pk_event_resources PRIMARY KEY (id);


--
-- Name: events pk_events; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT pk_events PRIMARY KEY (id);


--
-- Name: flow pk_flow; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow
    ADD CONSTRAINT pk_flow PRIMARY KEY (id);


--
-- Name: flow_run pk_flow_run; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow_run
    ADD CONSTRAINT pk_flow_run PRIMARY KEY (id);


--
-- Name: flow_run_input pk_flow_run_input; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow_run_input
    ADD CONSTRAINT pk_flow_run_input PRIMARY KEY (id);


--
-- Name: flow_run_notification_policy pk_flow_run_notification_policy; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow_run_notification_policy
    ADD CONSTRAINT pk_flow_run_notification_policy PRIMARY KEY (id);


--
-- Name: flow_run_notification_queue pk_flow_run_notification_queue; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow_run_notification_queue
    ADD CONSTRAINT pk_flow_run_notification_queue PRIMARY KEY (id);


--
-- Name: flow_run_state pk_flow_run_state; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow_run_state
    ADD CONSTRAINT pk_flow_run_state PRIMARY KEY (id);


--
-- Name: log pk_log; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT pk_log PRIMARY KEY (id);


--
-- Name: saved_search pk_saved_search; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.saved_search
    ADD CONSTRAINT pk_saved_search PRIMARY KEY (id);


--
-- Name: task_run pk_task_run; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.task_run
    ADD CONSTRAINT pk_task_run PRIMARY KEY (id);


--
-- Name: task_run_state pk_task_run_state; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.task_run_state
    ADD CONSTRAINT pk_task_run_state PRIMARY KEY (id);


--
-- Name: task_run_state_cache pk_task_run_state_cache; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.task_run_state_cache
    ADD CONSTRAINT pk_task_run_state_cache PRIMARY KEY (id);


--
-- Name: variable pk_variable; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.variable
    ADD CONSTRAINT pk_variable PRIMARY KEY (id);


--
-- Name: work_pool pk_work_pool; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.work_pool
    ADD CONSTRAINT pk_work_pool PRIMARY KEY (id);


--
-- Name: work_queue pk_work_queue; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.work_queue
    ADD CONSTRAINT pk_work_queue PRIMARY KEY (id);


--
-- Name: worker pk_worker; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT pk_worker PRIMARY KEY (id);


--
-- Name: agent uq_agent__name; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.agent
    ADD CONSTRAINT uq_agent__name UNIQUE (name);


--
-- Name: artifact_collection uq_artifact_collection__key; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.artifact_collection
    ADD CONSTRAINT uq_artifact_collection__key UNIQUE (key);


--
-- Name: automation_event_follower uq_automation_event_follower__follower_event_id; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.automation_event_follower
    ADD CONSTRAINT uq_automation_event_follower__follower_event_id UNIQUE (follower_event_id);


--
-- Name: concurrency_limit_v2 uq_concurrency_limit_v2__name; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.concurrency_limit_v2
    ADD CONSTRAINT uq_concurrency_limit_v2__name UNIQUE (name);


--
-- Name: configuration uq_configuration__key; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT uq_configuration__key UNIQUE (key);


--
-- Name: csrf_token uq_csrf_token__client; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.csrf_token
    ADD CONSTRAINT uq_csrf_token__client UNIQUE (client);


--
-- Name: flow uq_flow__name; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow
    ADD CONSTRAINT uq_flow__name UNIQUE (name);


--
-- Name: flow_run_input uq_flow_run_input__flow_run_id_key; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow_run_input
    ADD CONSTRAINT uq_flow_run_input__flow_run_id_key UNIQUE (flow_run_id, key);


--
-- Name: saved_search uq_saved_search__name; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.saved_search
    ADD CONSTRAINT uq_saved_search__name UNIQUE (name);


--
-- Name: variable uq_variable__name; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.variable
    ADD CONSTRAINT uq_variable__name UNIQUE (name);


--
-- Name: work_pool uq_work_pool__name; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.work_pool
    ADD CONSTRAINT uq_work_pool__name UNIQUE (name);


--
-- Name: work_queue uq_work_queue__work_pool_id_name; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.work_queue
    ADD CONSTRAINT uq_work_queue__work_pool_id_name UNIQUE (work_pool_id, name);


--
-- Name: worker uq_worker__work_pool_id_name; Type: CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT uq_worker__work_pool_id_name UNIQUE (work_pool_id, name);


--
-- Name: ix_agent__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_agent__updated ON public.agent USING btree (updated);


--
-- Name: ix_agent__work_queue_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_agent__work_queue_id ON public.agent USING btree (work_queue_id);


--
-- Name: ix_artifact__flow_run_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_artifact__flow_run_id ON public.artifact USING btree (flow_run_id);


--
-- Name: ix_artifact__key; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_artifact__key ON public.artifact USING btree (key);


--
-- Name: ix_artifact__key_created_desc; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_artifact__key_created_desc ON public.artifact USING btree (key, created DESC) INCLUDE (id, updated, type, task_run_id, flow_run_id);


--
-- Name: ix_artifact__task_run_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_artifact__task_run_id ON public.artifact USING btree (task_run_id);


--
-- Name: ix_artifact__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_artifact__updated ON public.artifact USING btree (updated);


--
-- Name: ix_artifact_collection__key_latest_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_artifact_collection__key_latest_id ON public.artifact_collection USING btree (key, latest_id);


--
-- Name: ix_automation__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_automation__updated ON public.automation USING btree (updated);


--
-- Name: ix_automation_bucket__automation_id__end; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_automation_bucket__automation_id__end ON public.automation_bucket USING btree (automation_id, "end");


--
-- Name: ix_automation_bucket__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_automation_bucket__updated ON public.automation_bucket USING btree (updated);


--
-- Name: ix_automation_event_follower__leader_event_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_automation_event_follower__leader_event_id ON public.automation_event_follower USING btree (leader_event_id);


--
-- Name: ix_automation_event_follower__received; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_automation_event_follower__received ON public.automation_event_follower USING btree (received);


--
-- Name: ix_automation_event_follower__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_automation_event_follower__updated ON public.automation_event_follower USING btree (updated);


--
-- Name: ix_automation_related_resource__resource_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_automation_related_resource__resource_id ON public.automation_related_resource USING btree (resource_id);


--
-- Name: ix_automation_related_resource__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_automation_related_resource__updated ON public.automation_related_resource USING btree (updated);


--
-- Name: ix_block_document__block_type_name__name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_block_document__block_type_name__name ON public.block_document USING btree (block_type_name, name);


--
-- Name: ix_block_document__is_anonymous; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_block_document__is_anonymous ON public.block_document USING btree (is_anonymous);


--
-- Name: ix_block_document__name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_block_document__name ON public.block_document USING btree (name);


--
-- Name: ix_block_document__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_block_document__updated ON public.block_document USING btree (updated);


--
-- Name: ix_block_document_reference__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_block_document_reference__updated ON public.block_document_reference USING btree (updated);


--
-- Name: ix_block_schema__block_type_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_block_schema__block_type_id ON public.block_schema USING btree (block_type_id);


--
-- Name: ix_block_schema__capabilities; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_block_schema__capabilities ON public.block_schema USING gin (capabilities);


--
-- Name: ix_block_schema__created; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_block_schema__created ON public.block_schema USING btree (created);


--
-- Name: ix_block_schema__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_block_schema__updated ON public.block_schema USING btree (updated);


--
-- Name: ix_block_schema_reference__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_block_schema_reference__updated ON public.block_schema_reference USING btree (updated);


--
-- Name: ix_block_type__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_block_type__updated ON public.block_type USING btree (updated);


--
-- Name: ix_composite_trigger_child_firing__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_composite_trigger_child_firing__updated ON public.composite_trigger_child_firing USING btree (updated);


--
-- Name: ix_concurrency_limit__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_concurrency_limit__updated ON public.concurrency_limit USING btree (updated);


--
-- Name: ix_concurrency_limit_v2__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_concurrency_limit_v2__updated ON public.concurrency_limit_v2 USING btree (updated);


--
-- Name: ix_configuration__key; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_configuration__key ON public.configuration USING btree (key);


--
-- Name: ix_configuration__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_configuration__updated ON public.configuration USING btree (updated);


--
-- Name: ix_csrf_token__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_csrf_token__updated ON public.csrf_token USING btree (updated);


--
-- Name: ix_deployment__created; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_deployment__created ON public.deployment USING btree (created);


--
-- Name: ix_deployment__flow_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_deployment__flow_id ON public.deployment USING btree (flow_id);


--
-- Name: ix_deployment__paused; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_deployment__paused ON public.deployment USING btree (paused);


--
-- Name: ix_deployment__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_deployment__updated ON public.deployment USING btree (updated);


--
-- Name: ix_deployment__work_queue_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_deployment__work_queue_id ON public.deployment USING btree (work_queue_id);


--
-- Name: ix_deployment__work_queue_name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_deployment__work_queue_name ON public.deployment USING btree (work_queue_name);


--
-- Name: ix_deployment_schedule__deployment_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_deployment_schedule__deployment_id ON public.deployment_schedule USING btree (deployment_id);


--
-- Name: ix_deployment_schedule__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_deployment_schedule__updated ON public.deployment_schedule USING btree (updated);


--
-- Name: ix_event_resources__resource_id__occurred; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_event_resources__resource_id__occurred ON public.event_resources USING btree (resource_id, occurred);


--
-- Name: ix_event_resources__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_event_resources__updated ON public.event_resources USING btree (updated);


--
-- Name: ix_events__event__id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_events__event__id ON public.events USING btree (event, id);


--
-- Name: ix_events__event_occurred_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_events__event_occurred_id ON public.events USING btree (event, occurred, id);


--
-- Name: ix_events__event_related_occurred; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_events__event_related_occurred ON public.events USING btree (event, related, occurred);


--
-- Name: ix_events__event_resource_id_occurred; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_events__event_resource_id_occurred ON public.events USING btree (event, resource_id, occurred);


--
-- Name: ix_events__occurred; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_events__occurred ON public.events USING btree (occurred);


--
-- Name: ix_events__occurred_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_events__occurred_id ON public.events USING btree (occurred, id);


--
-- Name: ix_events__related_resource_ids; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_events__related_resource_ids ON public.events USING btree (related_resource_ids);


--
-- Name: ix_events__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_events__updated ON public.events USING btree (updated);


--
-- Name: ix_flow__created; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow__created ON public.flow USING btree (created);


--
-- Name: ix_flow__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow__updated ON public.flow USING btree (updated);


--
-- Name: ix_flow_run__coalesce_start_time_expected_start_time_asc; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__coalesce_start_time_expected_start_time_asc ON public.flow_run USING btree (COALESCE(start_time, expected_start_time));


--
-- Name: ix_flow_run__coalesce_start_time_expected_start_time_desc; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__coalesce_start_time_expected_start_time_desc ON public.flow_run USING btree (COALESCE(start_time, expected_start_time) DESC);


--
-- Name: ix_flow_run__deployment_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__deployment_id ON public.flow_run USING btree (deployment_id);


--
-- Name: ix_flow_run__deployment_version; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__deployment_version ON public.flow_run USING btree (deployment_version);


--
-- Name: ix_flow_run__end_time_desc; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__end_time_desc ON public.flow_run USING btree (end_time DESC);


--
-- Name: ix_flow_run__expected_start_time_desc; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__expected_start_time_desc ON public.flow_run USING btree (expected_start_time DESC);


--
-- Name: ix_flow_run__flow_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__flow_id ON public.flow_run USING btree (flow_id);


--
-- Name: ix_flow_run__flow_version; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__flow_version ON public.flow_run USING btree (flow_version);


--
-- Name: ix_flow_run__infrastructure_document_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__infrastructure_document_id ON public.flow_run USING btree (infrastructure_document_id);


--
-- Name: ix_flow_run__name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__name ON public.flow_run USING btree (name);


--
-- Name: ix_flow_run__next_scheduled_start_time_asc; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__next_scheduled_start_time_asc ON public.flow_run USING btree (next_scheduled_start_time);


--
-- Name: ix_flow_run__parent_task_run_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__parent_task_run_id ON public.flow_run USING btree (parent_task_run_id);


--
-- Name: ix_flow_run__scheduler_deployment_id_auto_scheduled_next_schedu; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__scheduler_deployment_id_auto_scheduled_next_schedu ON public.flow_run USING btree (deployment_id, auto_scheduled, next_scheduled_start_time) WHERE (state_type = 'SCHEDULED'::public.state_type);


--
-- Name: ix_flow_run__start_time; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__start_time ON public.flow_run USING btree (start_time);


--
-- Name: ix_flow_run__state_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__state_id ON public.flow_run USING btree (state_id);


--
-- Name: ix_flow_run__state_name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__state_name ON public.flow_run USING btree (state_name);


--
-- Name: ix_flow_run__state_timestamp; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__state_timestamp ON public.flow_run USING btree (state_timestamp);


--
-- Name: ix_flow_run__state_type; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__state_type ON public.flow_run USING btree (state_type);


--
-- Name: ix_flow_run__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__updated ON public.flow_run USING btree (updated);


--
-- Name: ix_flow_run__work_queue_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__work_queue_id ON public.flow_run USING btree (work_queue_id);


--
-- Name: ix_flow_run__work_queue_name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run__work_queue_name ON public.flow_run USING btree (work_queue_name);


--
-- Name: ix_flow_run_input__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run_input__updated ON public.flow_run_input USING btree (updated);


--
-- Name: ix_flow_run_notification_policy__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run_notification_policy__updated ON public.flow_run_notification_policy USING btree (updated);


--
-- Name: ix_flow_run_notification_queue__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run_notification_queue__updated ON public.flow_run_notification_queue USING btree (updated);


--
-- Name: ix_flow_run_state__name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run_state__name ON public.flow_run_state USING btree (name);


--
-- Name: ix_flow_run_state__result_artifact_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run_state__result_artifact_id ON public.flow_run_state USING btree (result_artifact_id);


--
-- Name: ix_flow_run_state__type; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run_state__type ON public.flow_run_state USING btree (type);


--
-- Name: ix_flow_run_state__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_flow_run_state__updated ON public.flow_run_state USING btree (updated);


--
-- Name: ix_log__flow_run_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_log__flow_run_id ON public.log USING btree (flow_run_id);


--
-- Name: ix_log__flow_run_id_timestamp; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_log__flow_run_id_timestamp ON public.log USING btree (flow_run_id, "timestamp");


--
-- Name: ix_log__level; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_log__level ON public.log USING btree (level);


--
-- Name: ix_log__task_run_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_log__task_run_id ON public.log USING btree (task_run_id);


--
-- Name: ix_log__timestamp; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_log__timestamp ON public.log USING btree ("timestamp");


--
-- Name: ix_log__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_log__updated ON public.log USING btree (updated);


--
-- Name: ix_saved_search__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_saved_search__updated ON public.saved_search USING btree (updated);


--
-- Name: ix_task_run__end_time_desc; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run__end_time_desc ON public.task_run USING btree (end_time DESC);


--
-- Name: ix_task_run__expected_start_time_desc; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run__expected_start_time_desc ON public.task_run USING btree (expected_start_time DESC);


--
-- Name: ix_task_run__flow_run_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run__flow_run_id ON public.task_run USING btree (flow_run_id);


--
-- Name: ix_task_run__name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run__name ON public.task_run USING btree (name);


--
-- Name: ix_task_run__next_scheduled_start_time_asc; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run__next_scheduled_start_time_asc ON public.task_run USING btree (next_scheduled_start_time);


--
-- Name: ix_task_run__start_time; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run__start_time ON public.task_run USING btree (start_time);


--
-- Name: ix_task_run__state_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run__state_id ON public.task_run USING btree (state_id);


--
-- Name: ix_task_run__state_name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run__state_name ON public.task_run USING btree (state_name);


--
-- Name: ix_task_run__state_timestamp; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run__state_timestamp ON public.task_run USING btree (state_timestamp);


--
-- Name: ix_task_run__state_type; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run__state_type ON public.task_run USING btree (state_type);


--
-- Name: ix_task_run__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run__updated ON public.task_run USING btree (updated);


--
-- Name: ix_task_run_state__name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run_state__name ON public.task_run_state USING btree (name);


--
-- Name: ix_task_run_state__result_artifact_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run_state__result_artifact_id ON public.task_run_state USING btree (result_artifact_id);


--
-- Name: ix_task_run_state__type; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run_state__type ON public.task_run_state USING btree (type);


--
-- Name: ix_task_run_state__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run_state__updated ON public.task_run_state USING btree (updated);


--
-- Name: ix_task_run_state_cache__cache_key_created_desc; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run_state_cache__cache_key_created_desc ON public.task_run_state_cache USING btree (cache_key, created DESC);


--
-- Name: ix_task_run_state_cache__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_task_run_state_cache__updated ON public.task_run_state_cache USING btree (updated);


--
-- Name: ix_variable__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_variable__updated ON public.variable USING btree (updated);


--
-- Name: ix_work_pool__type; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_work_pool__type ON public.work_pool USING btree (type);


--
-- Name: ix_work_pool__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_work_pool__updated ON public.work_pool USING btree (updated);


--
-- Name: ix_work_queue__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_work_queue__updated ON public.work_queue USING btree (updated);


--
-- Name: ix_work_queue__work_pool_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_work_queue__work_pool_id ON public.work_queue USING btree (work_pool_id);


--
-- Name: ix_work_queue__work_pool_id_priority; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_work_queue__work_pool_id_priority ON public.work_queue USING btree (work_pool_id, priority);


--
-- Name: ix_worker__updated; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_worker__updated ON public.worker USING btree (updated);


--
-- Name: ix_worker__work_pool_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_worker__work_pool_id ON public.worker USING btree (work_pool_id);


--
-- Name: ix_worker__work_pool_id_last_heartbeat_time; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX ix_worker__work_pool_id_last_heartbeat_time ON public.worker USING btree (work_pool_id, last_heartbeat_time);


--
-- Name: trgm_ix_block_document_name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX trgm_ix_block_document_name ON public.block_document USING gin (name public.gin_trgm_ops);


--
-- Name: trgm_ix_block_type_name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX trgm_ix_block_type_name ON public.block_type USING gin (name public.gin_trgm_ops);


--
-- Name: trgm_ix_deployment_name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX trgm_ix_deployment_name ON public.deployment USING gin (name public.gin_trgm_ops);


--
-- Name: trgm_ix_flow_name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX trgm_ix_flow_name ON public.flow USING gin (name public.gin_trgm_ops);


--
-- Name: trgm_ix_flow_run_name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX trgm_ix_flow_run_name ON public.flow_run USING gin (name public.gin_trgm_ops);


--
-- Name: trgm_ix_task_run_name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX trgm_ix_task_run_name ON public.task_run USING gin (name public.gin_trgm_ops);


--
-- Name: trgm_ix_work_queue_name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE INDEX trgm_ix_work_queue_name ON public.work_queue USING gin (name public.gin_trgm_ops);


--
-- Name: uq_automation_bucket__automation_id__trigger_id__bucketing_key; Type: INDEX; Schema: public; Owner: prefect
--

CREATE UNIQUE INDEX uq_automation_bucket__automation_id__trigger_id__bucketing_key ON public.automation_bucket USING btree (automation_id, trigger_id, bucketing_key);


--
-- Name: uq_automation_related_resource__automation_id__resource_id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE UNIQUE INDEX uq_automation_related_resource__automation_id__resource_id ON public.automation_related_resource USING btree (automation_id, resource_id);


--
-- Name: uq_block__type_id_name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE UNIQUE INDEX uq_block__type_id_name ON public.block_document USING btree (block_type_id, name);


--
-- Name: uq_block_schema__checksum_version; Type: INDEX; Schema: public; Owner: prefect
--

CREATE UNIQUE INDEX uq_block_schema__checksum_version ON public.block_schema USING btree (checksum, version);


--
-- Name: uq_block_type__slug; Type: INDEX; Schema: public; Owner: prefect
--

CREATE UNIQUE INDEX uq_block_type__slug ON public.block_type USING btree (slug);


--
-- Name: uq_composite_trigger_child_firing__a_id__pt_id__ct__id; Type: INDEX; Schema: public; Owner: prefect
--

CREATE UNIQUE INDEX uq_composite_trigger_child_firing__a_id__pt_id__ct__id ON public.composite_trigger_child_firing USING btree (automation_id, parent_trigger_id, child_trigger_id);


--
-- Name: uq_concurrency_limit__tag; Type: INDEX; Schema: public; Owner: prefect
--

CREATE UNIQUE INDEX uq_concurrency_limit__tag ON public.concurrency_limit USING btree (tag);


--
-- Name: uq_deployment__flow_id_name; Type: INDEX; Schema: public; Owner: prefect
--

CREATE UNIQUE INDEX uq_deployment__flow_id_name ON public.deployment USING btree (flow_id, name);


--
-- Name: uq_flow_run__flow_id_idempotency_key; Type: INDEX; Schema: public; Owner: prefect
--

CREATE UNIQUE INDEX uq_flow_run__flow_id_idempotency_key ON public.flow_run USING btree (flow_id, idempotency_key);


--
-- Name: uq_flow_run_state__flow_run_id_timestamp_desc; Type: INDEX; Schema: public; Owner: prefect
--

CREATE UNIQUE INDEX uq_flow_run_state__flow_run_id_timestamp_desc ON public.flow_run_state USING btree (flow_run_id, "timestamp" DESC);


--
-- Name: uq_task_run__flow_run_id_task_key_dynamic_key; Type: INDEX; Schema: public; Owner: prefect
--

CREATE UNIQUE INDEX uq_task_run__flow_run_id_task_key_dynamic_key ON public.task_run USING btree (flow_run_id, task_key, dynamic_key);


--
-- Name: uq_task_run_state__task_run_id_timestamp_desc; Type: INDEX; Schema: public; Owner: prefect
--

CREATE UNIQUE INDEX uq_task_run_state__task_run_id_timestamp_desc ON public.task_run_state USING btree (task_run_id, "timestamp" DESC);


--
-- Name: agent fk_agent__work_queue_id__work_queue; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.agent
    ADD CONSTRAINT fk_agent__work_queue_id__work_queue FOREIGN KEY (work_queue_id) REFERENCES public.work_queue(id);


--
-- Name: automation_bucket fk_automation_bucket__automation_id__automation; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.automation_bucket
    ADD CONSTRAINT fk_automation_bucket__automation_id__automation FOREIGN KEY (automation_id) REFERENCES public.automation(id) ON DELETE CASCADE;


--
-- Name: automation_related_resource fk_automation_related_resource__automation_id__automation; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.automation_related_resource
    ADD CONSTRAINT fk_automation_related_resource__automation_id__automation FOREIGN KEY (automation_id) REFERENCES public.automation(id) ON DELETE CASCADE;


--
-- Name: block_document fk_block__block_schema_id__block_schema; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.block_document
    ADD CONSTRAINT fk_block__block_schema_id__block_schema FOREIGN KEY (block_schema_id) REFERENCES public.block_schema(id) ON DELETE CASCADE;


--
-- Name: block_document fk_block_document__block_type_id__block_type; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.block_document
    ADD CONSTRAINT fk_block_document__block_type_id__block_type FOREIGN KEY (block_type_id) REFERENCES public.block_type(id) ON DELETE CASCADE;


--
-- Name: block_document_reference fk_block_document_reference__parent_block_document_id___328f; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.block_document_reference
    ADD CONSTRAINT fk_block_document_reference__parent_block_document_id___328f FOREIGN KEY (parent_block_document_id) REFERENCES public.block_document(id) ON DELETE CASCADE;


--
-- Name: block_document_reference fk_block_document_reference__reference_block_document_i_5759; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.block_document_reference
    ADD CONSTRAINT fk_block_document_reference__reference_block_document_i_5759 FOREIGN KEY (reference_block_document_id) REFERENCES public.block_document(id) ON DELETE CASCADE;


--
-- Name: block_schema fk_block_schema__block_type_id__block_type; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.block_schema
    ADD CONSTRAINT fk_block_schema__block_type_id__block_type FOREIGN KEY (block_type_id) REFERENCES public.block_type(id) ON DELETE CASCADE;


--
-- Name: block_schema_reference fk_block_schema_reference__parent_block_schema_id__block_schema; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.block_schema_reference
    ADD CONSTRAINT fk_block_schema_reference__parent_block_schema_id__block_schema FOREIGN KEY (parent_block_schema_id) REFERENCES public.block_schema(id) ON DELETE CASCADE;


--
-- Name: block_schema_reference fk_block_schema_reference__reference_block_schema_id__b_6e5d; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.block_schema_reference
    ADD CONSTRAINT fk_block_schema_reference__reference_block_schema_id__b_6e5d FOREIGN KEY (reference_block_schema_id) REFERENCES public.block_schema(id) ON DELETE CASCADE;


--
-- Name: composite_trigger_child_firing fk_composite_trigger_child_firing__automation_id__automation; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.composite_trigger_child_firing
    ADD CONSTRAINT fk_composite_trigger_child_firing__automation_id__automation FOREIGN KEY (automation_id) REFERENCES public.automation(id) ON DELETE CASCADE;


--
-- Name: deployment fk_deployment__flow_id__flow; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.deployment
    ADD CONSTRAINT fk_deployment__flow_id__flow FOREIGN KEY (flow_id) REFERENCES public.flow(id) ON DELETE CASCADE;


--
-- Name: deployment fk_deployment__infrastructure_document_id__block_document; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.deployment
    ADD CONSTRAINT fk_deployment__infrastructure_document_id__block_document FOREIGN KEY (infrastructure_document_id) REFERENCES public.block_document(id) ON DELETE CASCADE;


--
-- Name: deployment fk_deployment__storage_document_id__block_document; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.deployment
    ADD CONSTRAINT fk_deployment__storage_document_id__block_document FOREIGN KEY (storage_document_id) REFERENCES public.block_document(id) ON DELETE CASCADE;


--
-- Name: deployment fk_deployment__work_queue_id__work_queue; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.deployment
    ADD CONSTRAINT fk_deployment__work_queue_id__work_queue FOREIGN KEY (work_queue_id) REFERENCES public.work_queue(id) ON DELETE SET NULL;


--
-- Name: deployment_schedule fk_deployment_schedule__deployment_id__deployment; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.deployment_schedule
    ADD CONSTRAINT fk_deployment_schedule__deployment_id__deployment FOREIGN KEY (deployment_id) REFERENCES public.deployment(id) ON DELETE CASCADE;


--
-- Name: flow_run fk_flow_run__flow_id__flow; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow_run
    ADD CONSTRAINT fk_flow_run__flow_id__flow FOREIGN KEY (flow_id) REFERENCES public.flow(id) ON DELETE CASCADE;


--
-- Name: flow_run fk_flow_run__infrastructure_document_id__block_document; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow_run
    ADD CONSTRAINT fk_flow_run__infrastructure_document_id__block_document FOREIGN KEY (infrastructure_document_id) REFERENCES public.block_document(id) ON DELETE CASCADE;


--
-- Name: flow_run fk_flow_run__parent_task_run_id__task_run; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow_run
    ADD CONSTRAINT fk_flow_run__parent_task_run_id__task_run FOREIGN KEY (parent_task_run_id) REFERENCES public.task_run(id) ON DELETE SET NULL;


--
-- Name: flow_run fk_flow_run__state_id__flow_run_state; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow_run
    ADD CONSTRAINT fk_flow_run__state_id__flow_run_state FOREIGN KEY (state_id) REFERENCES public.flow_run_state(id) ON DELETE SET NULL;


--
-- Name: flow_run fk_flow_run__work_queue_id__work_queue; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow_run
    ADD CONSTRAINT fk_flow_run__work_queue_id__work_queue FOREIGN KEY (work_queue_id) REFERENCES public.work_queue(id) ON DELETE SET NULL;


--
-- Name: flow_run_notification_policy fk_flow_run_alert_policy__block_document_id__block_document; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow_run_notification_policy
    ADD CONSTRAINT fk_flow_run_alert_policy__block_document_id__block_document FOREIGN KEY (block_document_id) REFERENCES public.block_document(id) ON DELETE CASCADE;


--
-- Name: flow_run_input fk_flow_run_input__flow_run_id__flow_run; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow_run_input
    ADD CONSTRAINT fk_flow_run_input__flow_run_id__flow_run FOREIGN KEY (flow_run_id) REFERENCES public.flow_run(id) ON DELETE CASCADE;


--
-- Name: flow_run_state fk_flow_run_state__flow_run_id__flow_run; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow_run_state
    ADD CONSTRAINT fk_flow_run_state__flow_run_id__flow_run FOREIGN KEY (flow_run_id) REFERENCES public.flow_run(id) ON DELETE CASCADE;


--
-- Name: flow_run_state fk_flow_run_state__result_artifact_id__artifact; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.flow_run_state
    ADD CONSTRAINT fk_flow_run_state__result_artifact_id__artifact FOREIGN KEY (result_artifact_id) REFERENCES public.artifact(id) ON DELETE SET NULL;


--
-- Name: task_run fk_task_run__flow_run_id__flow_run; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.task_run
    ADD CONSTRAINT fk_task_run__flow_run_id__flow_run FOREIGN KEY (flow_run_id) REFERENCES public.flow_run(id) ON DELETE CASCADE;


--
-- Name: task_run fk_task_run__state_id__task_run_state; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.task_run
    ADD CONSTRAINT fk_task_run__state_id__task_run_state FOREIGN KEY (state_id) REFERENCES public.task_run_state(id) ON DELETE SET NULL;


--
-- Name: task_run_state fk_task_run_state__result_artifact_id__artifact; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.task_run_state
    ADD CONSTRAINT fk_task_run_state__result_artifact_id__artifact FOREIGN KEY (result_artifact_id) REFERENCES public.artifact(id) ON DELETE SET NULL;


--
-- Name: task_run_state fk_task_run_state__task_run_id__task_run; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.task_run_state
    ADD CONSTRAINT fk_task_run_state__task_run_id__task_run FOREIGN KEY (task_run_id) REFERENCES public.task_run(id) ON DELETE CASCADE;


--
-- Name: work_pool fk_work_pool__default_queue_id__work_queue; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.work_pool
    ADD CONSTRAINT fk_work_pool__default_queue_id__work_queue FOREIGN KEY (default_queue_id) REFERENCES public.work_queue(id) ON DELETE RESTRICT;


--
-- Name: work_queue fk_work_queue__work_pool_id__work_pool; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.work_queue
    ADD CONSTRAINT fk_work_queue__work_pool_id__work_pool FOREIGN KEY (work_pool_id) REFERENCES public.work_pool(id) ON DELETE CASCADE;


--
-- Name: worker fk_worker__work_pool_id__work_pool; Type: FK CONSTRAINT; Schema: public; Owner: prefect
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT fk_worker__work_pool_id__work_pool FOREIGN KEY (work_pool_id) REFERENCES public.work_pool(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict KBm4kACmr2DBlG8lQQGqTxAz4gQGpXyfBOdVYpjBVF0grX2Xls8xarOwvS5WE9p

