--
-- PostgreSQL database dump
--

\restrict 9Ag6iAX6dTz4W9dpNk4CIRp0hylgM5Q1132MEt4k2vZ5SFJpysDHXoNH7UCZV66

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

\unrestrict 9Ag6iAX6dTz4W9dpNk4CIRp0hylgM5Q1132MEt4k2vZ5SFJpysDHXoNH7UCZV66

