--
-- PostgreSQL database dump
--

\restrict Q074W8iUeDaCbQe2MInrSF9sEvdvsPaySlH0rSiElKH7dwNVkpT094qQMPzD37X

-- Dumped from database version 15.17
-- Dumped by pg_dump version 15.17

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: notification_preference; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_preference (
    id bigint NOT NULL,
    config_key character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_enabled boolean NOT NULL,
    invoice_alerts_enabled boolean NOT NULL,
    payment_alerts_enabled boolean NOT NULL
);


ALTER TABLE public.notification_preference OWNER TO postgres;

--
-- Name: notification_preference_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notification_preference_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notification_preference_id_seq OWNER TO postgres;

--
-- Name: notification_preference_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notification_preference_id_seq OWNED BY public.notification_preference.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    message character varying(1000),
    is_read boolean NOT NULL,
    title character varying(255) NOT NULL,
    type character varying(20) NOT NULL,
    user_id uuid NOT NULL,
    CONSTRAINT notifications_type_check CHECK (((type)::text = ANY ((ARRAY['INFO'::character varying, 'PAYMENT'::character varying, 'INVOICE'::character varying, 'SYSTEM'::character varying])::text[])))
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notification_preference id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_preference ALTER COLUMN id SET DEFAULT nextval('public.notification_preference_id_seq'::regclass);


--
-- Data for Name: notification_preference; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification_preference (id, config_key, email, email_enabled, invoice_alerts_enabled, payment_alerts_enabled) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, created_at, message, is_read, title, type, user_id) FROM stdin;
\.


--
-- Name: notification_preference_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notification_preference_id_seq', 1, false);


--
-- Name: notification_preference notification_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_preference
    ADD CONSTRAINT notification_preference_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: notification_preference uk_b0ui8tt4idcojo74ibjqrvgph; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_preference
    ADD CONSTRAINT uk_b0ui8tt4idcojo74ibjqrvgph UNIQUE (config_key);


--
-- Name: idx_notification_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_user ON public.notifications USING btree (user_id);


--
-- PostgreSQL database dump complete
--

\unrestrict Q074W8iUeDaCbQe2MInrSF9sEvdvsPaySlH0rSiElKH7dwNVkpT094qQMPzD37X

