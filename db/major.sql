--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.10
-- Dumped by pg_dump version 9.6.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: major; Type: TABLE; Schema: pde; Owner: postgres
--

CREATE TABLE pde.major (
    id bigint DEFAULT shard_1.id_generator() NOT NULL,
    name text NOT NULL,
    project_id bigint NOT NULL,
    revision integer,
    CONSTRAINT major_name_check CHECK ((name <> ''::text))
);


ALTER TABLE pde.major OWNER TO postgres;

--
-- Name: major pk_pde_major; Type: CONSTRAINT; Schema: pde; Owner: postgres
--

ALTER TABLE ONLY pde.major
    ADD CONSTRAINT pk_pde_major PRIMARY KEY (id);


--
-- Name: major fk_major_project; Type: FK CONSTRAINT; Schema: pde; Owner: postgres
--

ALTER TABLE ONLY pde.major
    ADD CONSTRAINT fk_major_project FOREIGN KEY (project_id) REFERENCES pde.pde_project(id);


--
-- PostgreSQL database dump complete
--

