--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5 (Debian 17.5-1.pgdg120+1)
-- Dumped by pg_dump version 17.5 (Debian 17.5-1.pgdg120+1)

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: db_admin_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.db_admin_users (
    id bigint NOT NULL,
    username character varying(128) NOT NULL,
    password text NOT NULL
);


ALTER TABLE public.db_admin_users OWNER TO postgres;

--
-- Name: db_admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.db_admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.db_admin_users_id_seq OWNER TO postgres;

--
-- Name: db_admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.db_admin_users_id_seq OWNED BY public.db_admin_users.id;


--
-- Name: db_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.db_payments (
    user_id uuid NOT NULL,
    status character varying(64) NOT NULL,
    payment_link text NOT NULL,
    payment_sum text NOT NULL,
    prodamus_order_id text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.db_payments OWNER TO postgres;

--
-- Name: db_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.db_settings (
    id bigint NOT NULL,
    key character varying(128) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.db_settings OWNER TO postgres;

--
-- Name: db_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.db_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.db_settings_id_seq OWNER TO postgres;

--
-- Name: db_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.db_settings_id_seq OWNED BY public.db_settings.id;


--
-- Name: db_styles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.db_styles (
    id character varying(64) NOT NULL,
    name character varying(128) NOT NULL,
    comment text NOT NULL,
    pdf_info_url character varying(256) NOT NULL
);


ALTER TABLE public.db_styles OWNER TO postgres;

--
-- Name: db_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.db_tokens (
    user_id uuid NOT NULL,
    refresh_token character varying(256) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    expired_at timestamp with time zone NOT NULL,
    is_removed boolean DEFAULT false NOT NULL
);


ALTER TABLE public.db_tokens OWNER TO postgres;

--
-- Name: db_user_styles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.db_user_styles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    photo_url character varying(128) NOT NULL,
    photo_urls jsonb,
    style_id character varying(64) NOT NULL,
    initial_prediction character varying(64),
    confidence double precision DEFAULT 0,
    is_verified boolean DEFAULT false NOT NULL,
    verified_by integer,
    verified_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.db_user_styles OWNER TO postgres;

--
-- Name: db_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.db_users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    email character varying(128) NOT NULL,
    password_hash character varying(128) NOT NULL,
    first_name character varying(128) NOT NULL,
    last_name character varying(128) NOT NULL,
    birth_date character varying(10) NOT NULL,
    verification_code text,
    is_verified boolean DEFAULT false NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    password_reset_token text,
    password_reset_at timestamp with time zone,
    amocrm_lead_id bigint
);


ALTER TABLE public.db_users OWNER TO postgres;

--
-- Name: db_web_contents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.db_web_contents (
    id bigint NOT NULL,
    key character varying(128) NOT NULL,
    ru_value text NOT NULL,
    en_value text NOT NULL
);


ALTER TABLE public.db_web_contents OWNER TO postgres;

--
-- Name: db_web_contents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.db_web_contents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.db_web_contents_id_seq OWNER TO postgres;

--
-- Name: db_web_contents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.db_web_contents_id_seq OWNED BY public.db_web_contents.id;


--
-- Name: db_admin_users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_admin_users ALTER COLUMN id SET DEFAULT nextval('public.db_admin_users_id_seq'::regclass);


--
-- Name: db_settings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_settings ALTER COLUMN id SET DEFAULT nextval('public.db_settings_id_seq'::regclass);


--
-- Name: db_web_contents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_web_contents ALTER COLUMN id SET DEFAULT nextval('public.db_web_contents_id_seq'::regclass);


--
-- Data for Name: db_admin_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.db_admin_users (id, username, password) FROM stdin;
\.


--
-- Data for Name: db_payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.db_payments (user_id, status, payment_link, payment_sum, prodamus_order_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: db_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.db_settings (id, key, value) FROM stdin;
\.


--
-- Data for Name: db_styles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.db_styles (id, name, comment, pdf_info_url) FROM stdin;
\.


--
-- Data for Name: db_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.db_tokens (user_id, refresh_token, created_at, expired_at, is_removed) FROM stdin;
\.


--
-- Data for Name: db_user_styles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.db_user_styles (id, user_id, photo_url, photo_urls, style_id, initial_prediction, confidence, is_verified, verified_by, verified_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: db_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.db_users (id, created_at, updated_at, deleted_at, email, password_hash, first_name, last_name, birth_date, verification_code, is_verified, is_admin, password_reset_token, password_reset_at, amocrm_lead_id) FROM stdin;
\.


--
-- Data for Name: db_web_contents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.db_web_contents (id, key, ru_value, en_value) FROM stdin;
\.


--
-- Name: db_admin_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.db_admin_users_id_seq', 1, false);


--
-- Name: db_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.db_settings_id_seq', 1, false);


--
-- Name: db_web_contents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.db_web_contents_id_seq', 1, false);


--
-- Name: db_admin_users db_admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_admin_users
    ADD CONSTRAINT db_admin_users_pkey PRIMARY KEY (id);


--
-- Name: db_payments db_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_payments
    ADD CONSTRAINT db_payments_pkey PRIMARY KEY (user_id);


--
-- Name: db_settings db_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_settings
    ADD CONSTRAINT db_settings_pkey PRIMARY KEY (id);


--
-- Name: db_styles db_styles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_styles
    ADD CONSTRAINT db_styles_pkey PRIMARY KEY (id);


--
-- Name: db_tokens db_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_tokens
    ADD CONSTRAINT db_tokens_pkey PRIMARY KEY (user_id, refresh_token);


--
-- Name: db_user_styles db_user_styles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_user_styles
    ADD CONSTRAINT db_user_styles_pkey PRIMARY KEY (id);


--
-- Name: db_users db_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_users
    ADD CONSTRAINT db_users_pkey PRIMARY KEY (id);


--
-- Name: db_web_contents db_web_contents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_web_contents
    ADD CONSTRAINT db_web_contents_pkey PRIMARY KEY (id);


--
-- Name: idx_db_user_styles_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_db_user_styles_user_id ON public.db_user_styles USING btree (user_id);


--
-- Name: idx_db_users_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_db_users_deleted_at ON public.db_users USING btree (deleted_at);


--
-- Name: idx_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_email ON public.db_users USING btree (email);


--
-- Name: idx_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_key ON public.db_web_contents USING btree (key);


--
-- Name: idx_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_name ON public.db_styles USING btree (name);


--
-- Name: idx_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_username ON public.db_admin_users USING btree (username);


--
-- Name: db_payments fk_db_payments_user_auth_info; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_payments
    ADD CONSTRAINT fk_db_payments_user_auth_info FOREIGN KEY (user_id) REFERENCES public.db_users(id) ON DELETE CASCADE;


--
-- Name: db_tokens fk_db_tokens_user_auth_info; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_tokens
    ADD CONSTRAINT fk_db_tokens_user_auth_info FOREIGN KEY (user_id) REFERENCES public.db_users(id) ON DELETE CASCADE;


--
-- Name: db_user_styles fk_db_user_styles_user_auth_info; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_user_styles
    ADD CONSTRAINT fk_db_user_styles_user_auth_info FOREIGN KEY (user_id) REFERENCES public.db_users(id) ON DELETE CASCADE;


--
-- Name: db_user_styles fk_db_user_styles_verified_by_admin; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_user_styles
    ADD CONSTRAINT fk_db_user_styles_verified_by_admin FOREIGN KEY (verified_by) REFERENCES public.db_admin_users(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

