--
-- PostgreSQL database dump
--

\restrict KEebZq56yOrUOLbg2d4xwDfqBoR41b7vc49bZ5NRWEqj1hOsPN3hIo20UL4GLbX

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
-- Name: cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cards (
    id uuid NOT NULL,
    card_brand character varying(30),
    card_holder_name character varying(255) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    expiry_month integer,
    expiry_year integer,
    is_default boolean,
    last_four_digits character varying(4) NOT NULL,
    token_reference character varying(255),
    user_id uuid NOT NULL
);


ALTER TABLE public.cards OWNER TO postgres;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id uuid NOT NULL,
    amount numeric(15,4) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    currency character varying(3) NOT NULL,
    external_transaction_id character varying(100),
    invoice_id uuid NOT NULL,
    method character varying(20) NOT NULL,
    payment_date date,
    reference character varying(30) NOT NULL,
    status character varying(20) NOT NULL,
    user_id uuid NOT NULL,
    CONSTRAINT payments_method_check CHECK (((method)::text = ANY ((ARRAY['CARD'::character varying, 'BANK_TRANSFER'::character varying, 'CASH'::character varying, 'CHECK'::character varying])::text[]))),
    CONSTRAINT payments_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'COMPLETED'::character varying, 'FAILED'::character varying, 'REFUNDED'::character varying])::text[])))
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- Data for Name: cards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cards (id, card_brand, card_holder_name, created_at, expiry_month, expiry_year, is_default, last_four_digits, token_reference, user_id) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, amount, created_at, currency, external_transaction_id, invoice_id, method, payment_date, reference, status, user_id) FROM stdin;
11111111-1111-1111-1111-111111112001	297.5000	2026-01-08 16:25:00	TND	TX-2026-0001	11111111-1111-1111-1111-111111111102	CARD	2026-01-08	PAY-2026-0001	COMPLETED	11111111-1111-1111-1111-111111111111
11111111-1111-1111-1111-111111112002	119.0000	2026-01-12 11:10:00	TND	TX-2026-0002	11111111-1111-1111-1111-111111111101	BANK_TRANSFER	\N	PAY-2026-0002	PENDING	11111111-1111-1111-1111-111111111111
a1b2c3d4-e5f6-7890-abcd-ef1234567890	17850.0000	2026-01-10 10:00:00	TND	TX-2026-0003	11111111-1111-1111-1111-111111111111	BANK_TRANSFER	2026-01-10	PAY-2026-0003	COMPLETED	c30182ab-cc6a-4af0-8be4-db2f6e8b5ebb
\.


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- Name: payments idx_payment_reference; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT idx_payment_reference UNIQUE (reference);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: idx_card_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_card_user ON public.cards USING btree (user_id);


--
-- Name: idx_payment_invoice; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payment_invoice ON public.payments USING btree (invoice_id);


--
-- PostgreSQL database dump complete
--

\unrestrict KEebZq56yOrUOLbg2d4xwDfqBoR41b7vc49bZ5NRWEqj1hOsPN3hIo20UL4GLbX

