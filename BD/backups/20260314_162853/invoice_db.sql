--
-- PostgreSQL database dump
--

\restrict IfKuGWdgYKffQw5Z7Nu6Hjte7rwOSK3zrv4BDOVPXGhyCqtdkC1c3euQinATASp

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
-- Name: invoice_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoice_items (
    id uuid NOT NULL,
    description character varying(500) NOT NULL,
    line_total_ht numeric(15,4),
    quantity numeric(10,3) NOT NULL,
    tax_rate numeric(5,2),
    unit_price numeric(15,4) NOT NULL,
    invoice_id uuid NOT NULL
);


ALTER TABLE public.invoice_items OWNER TO postgres;

--
-- Name: invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoices (
    id uuid NOT NULL,
    billing_address character varying(500),
    client_email character varying(255),
    client_name character varying(255),
    created_at timestamp(6) without time zone NOT NULL,
    due_date date,
    invoice_number character varying(30),
    issue_date date,
    owner_user_id uuid NOT NULL,
    signature_hash character varying(255),
    status character varying(20) NOT NULL,
    subtotal_ht numeric(15,4),
    total_ttc numeric(15,4),
    updated_at timestamp(6) without time zone,
    vat_amount numeric(15,4),
    vat_rate numeric(5,2),
    CONSTRAINT invoices_status_check CHECK (((status)::text = ANY ((ARRAY['DRAFT'::character varying, 'VALIDATED'::character varying, 'SENT'::character varying, 'PAID'::character varying, 'CANCELLED'::character varying])::text[])))
);


ALTER TABLE public.invoices OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    active boolean NOT NULL,
    category character varying(50) NOT NULL,
    currency character varying(10),
    description character varying(1000),
    name character varying(200) NOT NULL,
    sku character varying(50) NOT NULL,
    tax_rate numeric(7,2),
    tenant_id bigint NOT NULL,
    unit character varying(10),
    unit_price numeric(15,4) NOT NULL
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_id_seq OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Data for Name: invoice_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoice_items (id, description, line_total_ht, quantity, tax_rate, unit_price, invoice_id) FROM stdin;
11111111-1111-1111-1111-111111111201	Audit et conseil	60.0000	1.000	19.00	60.0000	11111111-1111-1111-1111-111111111101
11111111-1111-1111-1111-111111111202	Integration plateforme	40.0000	1.000	19.00	40.0000	11111111-1111-1111-1111-111111111101
11111111-1111-1111-1111-111111111203	Abonnement annuel	250.0000	1.000	19.00	250.0000	11111111-1111-1111-1111-111111111102
aaaaaaaa-aaaa-aaaa-aaaa-bbbbbbbb0001	Creation site vitrine	2500.0000	1.000	19.00	2500.0000	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa001
aaaaaaaa-aaaa-aaaa-aaaa-bbbbbbbb0002	Maintenance mensuelle	1000.0000	2.000	19.00	500.0000	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa001
aaaaaaaa-aaaa-aaaa-aaaa-bbbbbbbb0003	Design logo et charte graphique	800.0000	1.000	19.00	800.0000	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa002
aaaaaaaa-aaaa-aaaa-aaaa-bbbbbbbb0004	Cartes de visite (500 pcs)	200.0000	1.000	19.00	200.0000	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa002
aaaaaaaa-aaaa-aaaa-aaaa-bbbbbbbb0005	Flyers promotionnels (1000 pcs)	800.0000	1.000	19.00	800.0000	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa002
aaaaaaaa-aaaa-aaaa-aaaa-bbbbbbbb0006	Developpement application de suivi	4000.0000	1.000	19.00	4000.0000	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa003
aaaaaaaa-aaaa-aaaa-aaaa-bbbbbbbb0007	Formation equipe (2 jours)	1200.0000	2.000	19.00	600.0000	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa003
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoices (id, billing_address, client_email, client_name, created_at, due_date, invoice_number, issue_date, owner_user_id, signature_hash, status, subtotal_ht, total_ttc, updated_at, vat_amount, vat_rate) FROM stdin;
11111111-1111-1111-1111-111111111101	Tunis, TN	contact@atlas.tn	Societe Atlas	2026-01-10 09:00:00	2026-01-20	INV-2026-0001	2026-01-10	11111111-1111-1111-1111-111111111111	\N	SENT	100.0000	119.0000	2026-01-10 09:00:00	19.0000	19.00
11111111-1111-1111-1111-111111111102	Sfax, TN	finance@delta.tn	Delta Services	2026-01-05 10:30:00	2026-01-15	INV-2026-0002	2026-01-05	11111111-1111-1111-1111-111111111111	\N	PAID	250.0000	297.5000	2026-01-08 16:20:00	47.5000	19.00
aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa001	25 Rue de la Liberte, Tunis	comptabilite@cafecentral.tn	Cafe Central SARL	2026-01-08 08:30:00	2026-02-08	FAC-2026-00010	2026-01-08	22222222-2222-2222-2222-222222222222	\N	PAID	3500.0000	4165.0000	2026-01-25 14:00:00	665.0000	19.00
aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa002	12 Souk El Attarine, Tunis	info@boutiquemedina.tn	Boutique Medina	2026-02-01 10:15:00	2026-03-01	FAC-2026-00011	2026-02-01	22222222-2222-2222-2222-222222222222	\N	SENT	1800.0000	2142.0000	2026-02-01 10:15:00	342.0000	19.00
aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa003	Zone Industrielle, Sousse	facturation@transexpress.tn	Transport Express	2026-02-15 09:00:00	2026-03-15	\N	2026-02-15	22222222-2222-2222-2222-222222222222	\N	DRAFT	5200.0000	6188.0000	\N	988.0000	19.00
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, active, category, currency, description, name, sku, tax_rate, tenant_id, unit, unit_price) FROM stdin;
\.


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 1, false);


--
-- Name: invoice_items invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: products uk_fhmd06dsmj6k0n90swsh8ie9g; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT uk_fhmd06dsmj6k0n90swsh8ie9g UNIQUE (sku);


--
-- Name: idx_invoice_item_invoice; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_invoice_item_invoice ON public.invoice_items USING btree (invoice_id);


--
-- Name: idx_invoice_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_invoice_number ON public.invoices USING btree (invoice_number);


--
-- Name: idx_invoice_owner; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_invoice_owner ON public.invoices USING btree (owner_user_id);


--
-- Name: idx_invoice_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_invoice_status ON public.invoices USING btree (status);


--
-- Name: idx_product_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_product_category ON public.products USING btree (category);


--
-- Name: idx_product_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_product_name ON public.products USING btree (name);


--
-- Name: idx_product_tenant; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_product_tenant ON public.products USING btree (tenant_id);


--
-- Name: invoice_items fk46ae0lhu1oqs7cv91fn6y9n7w; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT fk46ae0lhu1oqs7cv91fn6y9n7w FOREIGN KEY (invoice_id) REFERENCES public.invoices(id);


--
-- PostgreSQL database dump complete
--

\unrestrict IfKuGWdgYKffQw5Z7Nu6Hjte7rwOSK3zrv4BDOVPXGhyCqtdkC1c3euQinATASp

