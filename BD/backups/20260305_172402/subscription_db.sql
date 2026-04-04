--
-- PostgreSQL database dump
--

\restrict 6djfRQ1VnwsmUQBlqu83rHklP4R4guehVv6Cc9USPhp5fuOUKOagv3hdpmkrqgV

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
-- Name: plans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plans (
    id uuid NOT NULL,
    api_access boolean,
    description character varying(255) NOT NULL,
    max_invoices_per_month integer,
    max_users integer,
    name character varying(30) NOT NULL,
    price_annual numeric(10,2),
    price_monthly numeric(10,2),
    signature_included boolean,
    CONSTRAINT plans_name_check CHECK (((name)::text = ANY ((ARRAY['FREE'::character varying, 'BASIC'::character varying, 'PREMIUM'::character varying, 'ENTERPRISE'::character varying])::text[])))
);


ALTER TABLE public.plans OWNER TO postgres;

--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscriptions (
    id uuid NOT NULL,
    auto_renew boolean,
    end_date date,
    start_date date,
    status character varying(20) NOT NULL,
    user_id uuid NOT NULL,
    plan_id uuid NOT NULL,
    CONSTRAINT subscriptions_status_check CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'CANCELLED'::character varying, 'EXPIRED'::character varying, 'SUSPENDED'::character varying])::text[])))
);


ALTER TABLE public.subscriptions OWNER TO postgres;

--
-- Data for Name: plans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.plans (id, api_access, description, max_invoices_per_month, max_users, name, price_annual, price_monthly, signature_included) FROM stdin;
ab6d28c8-f634-46e6-a7b8-42e7017b6687	f	Plan gratuit	\N	1	FREE	0.00	0.00	f
641163f3-1e82-4d01-8f15-91c568851ee4	t	Plan basique	\N	5	BASIC	299.99	29.99	f
012bee23-7eff-403b-8142-edbaaba89447	t	Plan premium	\N	20	PREMIUM	999.99	99.99	t
a01a9439-c24b-4eb3-9c6c-621d1ef92e26	t	Plan entreprise	\N	100	ENTERPRISE	2999.99	299.99	t
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subscriptions (id, auto_renew, end_date, start_date, status, user_id, plan_id) FROM stdin;
\.


--
-- Name: plans plans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: plans uk_j2syv9y60858xbq169nbeg7ea; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT uk_j2syv9y60858xbq169nbeg7ea UNIQUE (name);


--
-- Name: idx_subscription_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subscription_user ON public.subscriptions USING btree (user_id);


--
-- Name: subscriptions fkb1uf5qnxi6uj95se8ykydntl1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT fkb1uf5qnxi6uj95se8ykydntl1 FOREIGN KEY (plan_id) REFERENCES public.plans(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 6djfRQ1VnwsmUQBlqu83rHklP4R4guehVv6Cc9USPhp5fuOUKOagv3hdpmkrqgV

