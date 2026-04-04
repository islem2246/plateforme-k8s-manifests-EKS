--
-- PostgreSQL database dump
--

\restrict MPdMluTgYQVEKZYuc3wEqcgnPegjjzYETcB042gsAFpIUk8479cAs4TGAMHjl0m

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

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


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
7666734d-1ba0-42e0-9fef-28c657afe591	2026-03-14 15:01:09.483069	2026-03-21 15:01:09.483052	f	bb105cb1-48b0-4c2b-979a-56fadfb9fe67	8d292fd2-847b-47a5-ae0a-d8bf1b55da7a
023cc265-1225-4842-949a-c94acb723eb4	2026-03-14 15:01:09.986397	2026-03-21 15:01:09.986382	f	f54a61fb-8a6a-4f87-b1e1-977039877b08	82eed65e-d209-4e16-95ed-898930505a6a
46c406aa-f8d0-4cea-aa2a-3ba4cf2e2ed3	2026-03-14 15:01:10.112112	2026-03-21 15:01:10.1121	f	98586c46-2978-4bae-8771-5b1ca94f1292	8d292fd2-847b-47a5-ae0a-d8bf1b55da7a
6e51271a-cc11-4371-8260-fc84a2a29389	2026-03-14 15:01:10.990532	2026-03-21 15:01:10.990518	f	df3f0a9e-1ec0-49e0-b41b-3578c98063e5	8d292fd2-847b-47a5-ae0a-d8bf1b55da7a
c3580193-5af9-43de-b8f8-f189558d8aa9	2026-03-14 15:01:11.108817	2026-03-21 15:01:11.108795	f	17f4c26c-d110-41ff-803b-7166d8ab8292	8d292fd2-847b-47a5-ae0a-d8bf1b55da7a
e17715fb-c4c0-4c5c-bd4a-ba5147657df0	2026-03-14 15:01:29.760816	2026-03-21 15:01:29.760804	f	ba344c2f-9b7c-41e4-91d7-76e3a760d5bb	8d292fd2-847b-47a5-ae0a-d8bf1b55da7a
888aed8e-b097-4039-8034-98eca32f1d79	2026-03-14 15:04:30.370804	2026-03-21 15:04:30.370794	f	d4d7a06c-55c4-4e4c-ac46-ebcf73a35588	8d292fd2-847b-47a5-ae0a-d8bf1b55da7a
ca47735a-18df-4e34-a27f-73b68656c59e	2026-03-14 15:06:54.262631	2026-03-21 15:06:54.262618	f	90772b70-f15c-4b1d-8396-39c88170631c	8d292fd2-847b-47a5-ae0a-d8bf1b55da7a
b91c004f-6820-475c-9c28-5835ca9fd1d0	2026-03-14 15:20:04.455667	2026-03-21 15:20:04.45564	f	f68d675c-40fa-4fd7-b097-2b33301ec743	8d292fd2-847b-47a5-ae0a-d8bf1b55da7a
9c47aa48-2ad5-4cc8-ab46-3c043b418c96	2026-03-14 15:20:19.025895	2026-03-21 15:20:19.025883	f	f3eed7a7-a9db-44d5-95ad-6d3a3f0ea348	1236d240-7a97-4b84-b28b-4ee019cd0b8f
2f2fa920-41a0-4869-b43f-c55a213bc85f	2026-03-14 15:27:25.323306	2026-03-21 15:27:25.323282	f	c8fc44f4-56bb-46a1-8150-ec4bfe228562	f180e622-fd9a-4056-9f9f-b8596926e0d6
b5507c00-b3f5-4944-a4c2-e7bfc816947f	2026-03-14 15:27:46.232421	2026-03-21 15:27:46.23241	f	d7b351ec-acb6-41fe-b72f-6be864b9532a	8d292fd2-847b-47a5-ae0a-d8bf1b55da7a
e1346353-1b54-484b-8fd0-ad05d0f716ee	2026-03-14 15:28:05.786299	2026-03-21 15:28:05.786289	f	0ac4151e-3e8e-4b39-836b-1187ef88a1f7	1236d240-7a97-4b84-b28b-4ee019cd0b8f
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, active, company_name, created_at, email, first_name, last_name, password_hash, phone, role, tax_id, updated_at) FROM stdin;
a371256d-1c08-45cc-97a2-70ac871ad2c6	t	\N	2026-03-14 15:00:52.707071	yasminegr432@gmail.com	Yassmine	Grassa	$2a$10$cKR9pPB2n8ZDoLKhotnxaOakReiPDot4SjLOq.zgDZMw8TfVRSH..	\N	ADMIN	\N	\N
10df755c-3971-4892-a978-c5afe4acaa3f	t	\N	2026-03-14 15:00:52.862239	user@example.com	Jean	Dupont	$2a$10$JU5wX/8K6UIlZ7bZ/HBVTOKmuhb3GSNK765KNT15s4k0EvBFqtkBG	\N	USER	\N	\N
8d292fd2-847b-47a5-ae0a-d8bf1b55da7a	t	\N	2026-03-14 15:01:09.402151	admin@plateforme.local	Admin	Plateforme	$2a$10$OsfmxOGJejfjuddbfF7dQOi4sj28fkKGCJgyrIPw6un9mxeZKFTGm	\N	USER	\N	\N
82eed65e-d209-4e16-95ed-898930505a6a	t	\N	2026-03-14 15:01:09.97537	merchant1@plateforme.local	Merchant	Test	$2a$10$WmwNKvu/sxWcSD36qh40Gu7OZCYCg56EBkx97mb.Iil.DHo9IUgee	\N	USER	\N	\N
1236d240-7a97-4b84-b28b-4ee019cd0b8f	t	\N	2026-03-14 15:00:52.285884	admin@example.com	Amel	Dabbabi	$2a$10$.ww6SpcEt9WIXElTktWqgOF6ug/2XER/Bo2IUsHE.tAKLbDRM5nla	\N	ADMIN	\N	\N
f180e622-fd9a-4056-9f9f-b8596926e0d6	t	\N	2026-03-14 15:24:37.954317	user1@plateforme.local	User	One	$2a$10$PBxp2XzPD4dWEdDoAFXZwuLFfnKg6f845R/ZeXALyrdJXGOVCKzs2	\N	USER	\N	2026-03-14 15:24:37.954317
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

\unrestrict MPdMluTgYQVEKZYuc3wEqcgnPegjjzYETcB042gsAFpIUk8479cAs4TGAMHjl0m

