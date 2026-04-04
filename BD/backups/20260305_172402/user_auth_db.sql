--
-- PostgreSQL database dump
--

\restrict rSswKjzCsCBEIbxdo16uIMjU0maW5DRdDsUwaEHAKOpO8tQrN7hzJ9NoEaEyAxs

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
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refresh_tokens (
    id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    expires_at timestamp(6) without time zone NOT NULL,
    revoked boolean NOT NULL,
    token character varying(255) NOT NULL,
    user_id uuid NOT NULL
);


ALTER TABLE public.refresh_tokens OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    active boolean NOT NULL,
    company_name character varying(255),
    created_at timestamp(6) without time zone NOT NULL,
    email character varying(255) NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    password_hash character varying(255) NOT NULL,
    phone character varying(50),
    role character varying(30) NOT NULL,
    tax_id character varying(100),
    updated_at timestamp(6) without time zone,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['ADMIN'::character varying, 'USER'::character varying, 'ACCOUNTANT'::character varying, 'MERCHANT'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refresh_tokens (id, created_at, expires_at, revoked, token, user_id) FROM stdin;
dc124552-71c2-4f67-bb0a-82270e9dff3b	2026-03-05 14:07:50.130777	2026-03-12 14:07:50.13076	f	cd8f1ade-3fbb-46d7-982b-e5e51ca25d33	abb15216-dae9-48cc-86f5-4a59d713d985
874b2f99-500a-47f9-971c-e591d5b6ff30	2026-03-05 14:07:50.563275	2026-03-12 14:07:50.563265	f	04c120b9-1a26-41d4-8a8c-74d7d7ec7dbd	c0a80545-f17c-47e4-8f0e-d5de867bac95
da95d4a5-4ff7-4282-9a07-d001424444ab	2026-03-05 14:07:50.758827	2026-03-12 14:07:50.758806	f	b905fa62-b2b7-4c74-b695-b78db71bfbaa	abb15216-dae9-48cc-86f5-4a59d713d985
e737e596-2d85-4b60-9715-09c9df5f6642	2026-03-05 14:11:13.911461	2026-03-12 14:11:13.911449	f	99abb508-8292-461b-a9d8-452f5b8cd691	abb15216-dae9-48cc-86f5-4a59d713d985
8e864c46-19f5-418c-b3a9-dbd2c090b1f4	2026-03-05 14:11:57.386335	2026-03-12 14:11:57.386305	f	ad25adc5-f643-437b-9156-efb3a0266728	abb15216-dae9-48cc-86f5-4a59d713d985
c3ff7a87-e0b0-4b47-9e54-fe9c17b179a0	2026-03-05 14:12:20.648794	2026-03-12 14:12:20.648782	f	08831032-3096-4765-ba73-b34cba7a17a1	abb15216-dae9-48cc-86f5-4a59d713d985
5498797d-f2a3-47d9-86e0-fab08fd9bbc0	2026-03-05 15:19:54.603394	2026-03-12 15:19:54.603351	f	4910112f-1518-4d3a-b223-999107e51f61	abb15216-dae9-48cc-86f5-4a59d713d985
3d4a4809-b8f2-41ef-9285-678134a0e1d8	2026-03-05 16:08:12.476165	2026-03-12 16:08:12.476155	f	7988d731-0759-4c17-a4c6-2daa5a586aec	abb15216-dae9-48cc-86f5-4a59d713d985
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, active, company_name, created_at, email, first_name, last_name, password_hash, phone, role, tax_id, updated_at) FROM stdin;
42c7d68b-0965-4912-8366-f287d610c56b	t	\N	2026-03-05 13:37:43.734481	admin@example.com	Amel	Dabbabi	$2a$10$gFoC5id4aMWrGYtSXQGSEuvyufvm7vzI9nEktj1ST7VJTB8vb4Bp.	\N	ADMIN	\N	\N
722be9e0-7d6e-4bee-a76d-f8c4259061d1	t	\N	2026-03-05 13:37:44.232705	yasminegr432@gmail.com	Yassmine	Grassa	$2a$10$7W...K41kkLkfI4EZeeBs..oBdKPewflrz0qOZPk5pZ51ye9MnAeC	\N	ADMIN	\N	\N
9af363b0-2090-4599-9c11-4d9ecb3f41c7	t	\N	2026-03-05 13:37:44.347646	user@example.com	Jean	Dupont	$2a$10$0PY.U94QX9MREGNiLzwAWuCxaFo656LMmBSzQ0OsTRnlXPrFNObGq	\N	USER	\N	\N
abb15216-dae9-48cc-86f5-4a59d713d985	t	\N	2026-03-05 14:07:50.035988	admin@plateforme.local	Admin	Plateforme	$2a$10$zcw2UOVQpHwhAqQNMlk9vOxqCNx9krs2I3W/y24Ibo2pmQk6BTX8.	\N	USER	\N	\N
c0a80545-f17c-47e4-8f0e-d5de867bac95	t	\N	2026-03-05 14:07:50.556773	merchant1@plateforme.local	Merchant	Test	$2a$10$9w8xu7MvKaZZay9ufs.YV.KRRX7cDoh56/pqs1xPmHQ6QF3xSrWK2	\N	USER	\N	\N
\.


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: users uk_6dotkott2kjsp8vw4d0m25fb7; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uk_6dotkott2kjsp8vw4d0m25fb7 UNIQUE (email);


--
-- Name: refresh_tokens uk_ghpmfn23vmxfu3spu3lfg4r2d; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT uk_ghpmfn23vmxfu3spu3lfg4r2d UNIQUE (token);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens fk1lih5y2npsf8u5o3vhdb9y0os; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT fk1lih5y2npsf8u5o3vhdb9y0os FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict rSswKjzCsCBEIbxdo16uIMjU0maW5DRdDsUwaEHAKOpO8tQrN7hzJ9NoEaEyAxs

