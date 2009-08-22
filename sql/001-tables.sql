SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

BEGIN;

--
-- Name: fixes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fixes (
    super     integer NOT NULL,
    major     integer NOT NULL,
    minor     integer NOT NULL,
    fix_md5   text    NOT NULL,
    fix_desc  text    NOT NULL,
    fix_tsv   tsvector
);


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    super           integer NOT NULL,
    major           integer NOT NULL,
    minor           integer NOT NULL,
    upgrade_warning text,
    CONSTRAINT versions_major_check CHECK (major >= 0 AND major < 50),
    CONSTRAINT versions_minor_check CHECK (minor >= 0 AND minor < 100),
    CONSTRAINT versions_super_check CHECK (super >= 7 AND super < 20)
);


--
-- Name: fixes_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fixes
    ADD CONSTRAINT fixes_key PRIMARY KEY (super, major, minor, fix_md5);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (super, major, minor);


--
-- Name: fixes_version_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fixes
    ADD CONSTRAINT fixes_version_fkey FOREIGN KEY (super, major, minor)
    REFERENCES versions(super, major, minor) ON UPDATE CASCADE ON DELETE CASCADE;

COMMIT;
