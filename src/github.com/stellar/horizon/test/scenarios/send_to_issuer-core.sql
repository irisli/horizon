--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

DROP INDEX IF EXISTS public.signersaccount;
DROP INDEX IF EXISTS public.sellingissuerindex;
DROP INDEX IF EXISTS public.scpenvsbyseq;
DROP INDEX IF EXISTS public.priceindex;
DROP INDEX IF EXISTS public.ledgersbyseq;
DROP INDEX IF EXISTS public.histfeebyseq;
DROP INDEX IF EXISTS public.histbyseq;
DROP INDEX IF EXISTS public.buyingissuerindex;
DROP INDEX IF EXISTS public.accountbalances;
ALTER TABLE IF EXISTS ONLY public.txhistory DROP CONSTRAINT IF EXISTS txhistory_pkey;
ALTER TABLE IF EXISTS ONLY public.txfeehistory DROP CONSTRAINT IF EXISTS txfeehistory_pkey;
ALTER TABLE IF EXISTS ONLY public.trustlines DROP CONSTRAINT IF EXISTS trustlines_pkey;
ALTER TABLE IF EXISTS ONLY public.storestate DROP CONSTRAINT IF EXISTS storestate_pkey;
ALTER TABLE IF EXISTS ONLY public.signers DROP CONSTRAINT IF EXISTS signers_pkey;
ALTER TABLE IF EXISTS ONLY public.scpquorums DROP CONSTRAINT IF EXISTS scpquorums_pkey;
ALTER TABLE IF EXISTS ONLY public.pubsub DROP CONSTRAINT IF EXISTS pubsub_pkey;
ALTER TABLE IF EXISTS ONLY public.publishqueue DROP CONSTRAINT IF EXISTS publishqueue_pkey;
ALTER TABLE IF EXISTS ONLY public.peers DROP CONSTRAINT IF EXISTS peers_pkey;
ALTER TABLE IF EXISTS ONLY public.offers DROP CONSTRAINT IF EXISTS offers_pkey;
ALTER TABLE IF EXISTS ONLY public.ledgerheaders DROP CONSTRAINT IF EXISTS ledgerheaders_pkey;
ALTER TABLE IF EXISTS ONLY public.ledgerheaders DROP CONSTRAINT IF EXISTS ledgerheaders_ledgerseq_key;
ALTER TABLE IF EXISTS ONLY public.accounts DROP CONSTRAINT IF EXISTS accounts_pkey;
ALTER TABLE IF EXISTS ONLY public.accountdata DROP CONSTRAINT IF EXISTS accountdata_pkey;
DROP TABLE IF EXISTS public.txhistory;
DROP TABLE IF EXISTS public.txfeehistory;
DROP TABLE IF EXISTS public.trustlines;
DROP TABLE IF EXISTS public.storestate;
DROP TABLE IF EXISTS public.signers;
DROP TABLE IF EXISTS public.scpquorums;
DROP TABLE IF EXISTS public.scphistory;
DROP TABLE IF EXISTS public.pubsub;
DROP TABLE IF EXISTS public.publishqueue;
DROP TABLE IF EXISTS public.peers;
DROP TABLE IF EXISTS public.offers;
DROP TABLE IF EXISTS public.ledgerheaders;
DROP TABLE IF EXISTS public.accounts;
DROP TABLE IF EXISTS public.accountdata;
DROP EXTENSION IF EXISTS plpgsql;
DROP SCHEMA IF EXISTS public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accountdata; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accountdata (
    accountid character varying(56) NOT NULL,
    dataname character varying(64) NOT NULL,
    datavalue character varying(112) NOT NULL
);


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    accountid character varying(56) NOT NULL,
    balance bigint NOT NULL,
    seqnum bigint NOT NULL,
    numsubentries integer NOT NULL,
    inflationdest character varying(56),
    homedomain character varying(32) NOT NULL,
    thresholds text NOT NULL,
    flags integer NOT NULL,
    lastmodified integer NOT NULL,
    CONSTRAINT accounts_balance_check CHECK ((balance >= 0)),
    CONSTRAINT accounts_numsubentries_check CHECK ((numsubentries >= 0))
);


--
-- Name: ledgerheaders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ledgerheaders (
    ledgerhash character(64) NOT NULL,
    prevhash character(64) NOT NULL,
    bucketlisthash character(64) NOT NULL,
    ledgerseq integer,
    closetime bigint NOT NULL,
    data text NOT NULL,
    CONSTRAINT ledgerheaders_closetime_check CHECK ((closetime >= 0)),
    CONSTRAINT ledgerheaders_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Name: offers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE offers (
    sellerid character varying(56) NOT NULL,
    offerid bigint NOT NULL,
    sellingassettype integer NOT NULL,
    sellingassetcode character varying(12),
    sellingissuer character varying(56),
    buyingassettype integer NOT NULL,
    buyingassetcode character varying(12),
    buyingissuer character varying(56),
    amount bigint NOT NULL,
    pricen integer NOT NULL,
    priced integer NOT NULL,
    price double precision NOT NULL,
    flags integer NOT NULL,
    lastmodified integer NOT NULL,
    CONSTRAINT offers_amount_check CHECK ((amount >= 0)),
    CONSTRAINT offers_offerid_check CHECK ((offerid >= 0))
);


--
-- Name: peers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE peers (
    ip character varying(15) NOT NULL,
    port integer DEFAULT 0 NOT NULL,
    nextattempt timestamp without time zone NOT NULL,
    numfailures integer DEFAULT 0 NOT NULL,
    CONSTRAINT peers_numfailures_check CHECK ((numfailures >= 0)),
    CONSTRAINT peers_port_check CHECK (((port > 0) AND (port <= 65535)))
);


--
-- Name: publishqueue; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE publishqueue (
    ledger integer NOT NULL,
    state text
);


--
-- Name: pubsub; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pubsub (
    resid character(32) NOT NULL,
    lastread integer
);


--
-- Name: scphistory; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scphistory (
    nodeid character(56) NOT NULL,
    ledgerseq integer NOT NULL,
    envelope text NOT NULL,
    CONSTRAINT scphistory_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Name: scpquorums; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scpquorums (
    qsethash character(64) NOT NULL,
    lastledgerseq integer NOT NULL,
    qset text NOT NULL,
    CONSTRAINT scpquorums_lastledgerseq_check CHECK ((lastledgerseq >= 0))
);


--
-- Name: signers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE signers (
    accountid character varying(56) NOT NULL,
    publickey character varying(56) NOT NULL,
    weight integer NOT NULL
);


--
-- Name: storestate; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE storestate (
    statename character(32) NOT NULL,
    state text
);


--
-- Name: trustlines; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trustlines (
    accountid character varying(56) NOT NULL,
    assettype integer NOT NULL,
    issuer character varying(56) NOT NULL,
    assetcode character varying(12) NOT NULL,
    tlimit bigint NOT NULL,
    balance bigint NOT NULL,
    flags integer NOT NULL,
    lastmodified integer NOT NULL,
    CONSTRAINT trustlines_balance_check CHECK ((balance >= 0)),
    CONSTRAINT trustlines_tlimit_check CHECK ((tlimit > 0))
);


--
-- Name: txfeehistory; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE txfeehistory (
    txid character(64) NOT NULL,
    ledgerseq integer NOT NULL,
    txindex integer NOT NULL,
    txchanges text NOT NULL,
    CONSTRAINT txfeehistory_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Name: txhistory; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE txhistory (
    txid character(64) NOT NULL,
    ledgerseq integer NOT NULL,
    txindex integer NOT NULL,
    txbody text NOT NULL,
    txresult text NOT NULL,
    txmeta text NOT NULL,
    CONSTRAINT txhistory_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Data for Name: accountdata; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO accounts VALUES ('GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 999999997999999800, 2, 0, NULL, '', 'AQAAAA==', 0, 2);
INSERT INTO accounts VALUES ('GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4', 999999900, 8589934593, 0, NULL, '', 'AQAAAA==', 0, 4);
INSERT INTO accounts VALUES ('GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 999999800, 8589934594, 1, NULL, '', 'AQAAAA==', 0, 5);


--
-- Data for Name: ledgerheaders; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO ledgerheaders VALUES ('63d98f536ee68d1b27b5b89f23af5311b7569a24faf1403ad0b52b633b07be99', '0000000000000000000000000000000000000000000000000000000000000000', '572a2e32ff248a07b0e70fd1f6d318c1facd20b6cc08c33d5775259868125a16', 1, 0, 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABXKi4y/ySKB7DnD9H20xjB+s0gtswIwz1XdSWYaBJaFgAAAAEN4Lazp2QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAZAX14QAAAABkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
INSERT INTO ledgerheaders VALUES ('f183143d4eb4437a36f93131c81c331870ce89e2467fa9ae60e7fe0882867383', '63d98f536ee68d1b27b5b89f23af5311b7569a24faf1403ad0b52b633b07be99', 'aa8b1ab49f50fced171d1a71ecacb11bde53924c80728ca72b3801e240b93a6d', 2, 1458861022, 'AAAAAmPZj1Nu5o0bJ7W4nyOvUxG3Vpok+vFAOtC1K2M7B76ZUJe9O5kAzNzu/6p0ZJoZ88h0TDub3uYslZJ7cSsRWgAAAAAAVvRz3gAAAAIAAAAIAAAAAQAAAAIAAAAIAAAAAwAAJxAAAAAAAnQIKiwQ7y1yg69ER0rE+8ttWxjdS9dphrI7bdn6YS6qixq0n1D87RcdGnHsrLEb3lOSTIByjKcrOAHiQLk6bQAAAAIN4Lazp2QAAAAAAAAAAADIAAAAAAAAAAAAAAAAAAAAZAX14QAAACcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
INSERT INTO ledgerheaders VALUES ('8cfbd827e9ba00e251ecadceb1e801ea9d5e7b9d7d6b3e37055afae758dd75fb', 'f183143d4eb4437a36f93131c81c331870ce89e2467fa9ae60e7fe0882867383', 'ad49fe6f2ee12922d2bf234812c577955d35db8aaada9f1ce8a1b2646318d683', 3, 1458861023, 'AAAAAvGDFD1OtEN6NvkxMcgcMxhwzoniRn+prmDn/giChnODJGv9NHa/wpF0qyDMXBQHqBqj4WdgG7Czf9vwg/jHXL0AAAAAVvRz3wAAAAAAAAAALLKPbMojH+RR+TSBDKGB/tufH2mL12ccCHr1Jn27yPCtSf5vLuEpItK/I0gSxXeVXTXbiqranxzoobJkYxjWgwAAAAMN4Lazp2QAAAAAAAAAAAEsAAAAAAAAAAAAAAAAAAAAZAX14QAAACcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
INSERT INTO ledgerheaders VALUES ('e84a3c2aaddfa5dcc03bcf8e00db7f8c219410679feb075f75710c52bc4f73a5', '8cfbd827e9ba00e251ecadceb1e801ea9d5e7b9d7d6b3e37055afae758dd75fb', 'a3e5e8770cde6cfc6ba8ceef28ba14d884ac8c7d63f455d60a21fb74efb974d5', 4, 1458861024, 'AAAAAoz72CfpugDiUeytzrHoAeqdXnudfWs+NwVa+udY3XX76sdX4UJQ3btjPb+/0qutIQvkXX8yeI1p3mRpP5YrRXcAAAAAVvRz4AAAAAAAAAAANvoQ5f0h4XOu2zzdNp+2aYFizWM/TiKsCFrgq+HrV6Kj5eh3DN5s/Guozu8ouhTYhKyMfWP0VdYKIft077l01QAAAAQN4Lazp2QAAAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAZAX14QAAACcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
INSERT INTO ledgerheaders VALUES ('c26bdba9f858b54cdf0581f05a2da33dc2f9e3b63cc55b16e9a2239e80876141', 'e84a3c2aaddfa5dcc03bcf8e00db7f8c219410679feb075f75710c52bc4f73a5', '651600da0914d1f2730338b4cfaf1bfb1af08eef5a160918d889ec40a2bcfde3', 5, 1458861025, 'AAAAAuhKPCqt36XcwDvPjgDbf4whlBBnn+sHX3VxDFK8T3Ol6sCaST46c++2tNFUGVTXN5k4pfer+Zh8DC5/g+DcQmoAAAAAVvRz4QAAAAAAAAAAqwSxrFb8etq4gSdxOi9F1KjbMMbBhDJdKXyKRqyFTJtlFgDaCRTR8nMDOLTPrxv7GvCO71oWCRjYiexAorz94wAAAAUN4Lazp2QAAAAAAAAAAAH0AAAAAAAAAAAAAAAAAAAAZAX14QAAACcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');


--
-- Data for Name: offers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: peers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: publishqueue; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: pubsub; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: scphistory; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO scphistory VALUES ('GCQ7OEPPUJPXWLPS2E7SMR7ZL3C6XHUPEDOHPFGBXQPGG4TM73D5RTW7', 2, 'AAAAAKH3Ee+iX3st8tE/Jkf5XsXrno8g3HeUwbweY3Js/sfYAAAAAAAAAAIAAAACAAAAAQAAAEhQl707mQDM3O7/qnRkmhnzyHRMO5ve5iyVkntxKxFaAAAAAABW9HPeAAAAAgAAAAgAAAABAAAAAgAAAAgAAAADAAAnEAAAAAAAAAABIWq8yE5o7tl9kP84Jj2U/sHjqPBaooLpvTpyFLBcwLcAAABAyEUT1yiRPkp3TNb4vn1dbzh8esh84dqZJl4Z9Fr2gemVTCseKVfTZoexSiHr5n5avmAnFshgWXPb3+ONGfWADg==');
INSERT INTO scphistory VALUES ('GCQ7OEPPUJPXWLPS2E7SMR7ZL3C6XHUPEDOHPFGBXQPGG4TM73D5RTW7', 3, 'AAAAAKH3Ee+iX3st8tE/Jkf5XsXrno8g3HeUwbweY3Js/sfYAAAAAAAAAAMAAAACAAAAAQAAADAka/00dr/CkXSrIMxcFAeoGqPhZ2AbsLN/2/CD+MdcvQAAAABW9HPfAAAAAAAAAAAAAAABIWq8yE5o7tl9kP84Jj2U/sHjqPBaooLpvTpyFLBcwLcAAABACnYe0odRL7NI8dUYa6xNcIKP301jHA1d83nxOO3DWBWqFSh0i2pQnYEqgUUzqCHn22DAnvxNu5lsC4DbhwHrBw==');
INSERT INTO scphistory VALUES ('GCQ7OEPPUJPXWLPS2E7SMR7ZL3C6XHUPEDOHPFGBXQPGG4TM73D5RTW7', 4, 'AAAAAKH3Ee+iX3st8tE/Jkf5XsXrno8g3HeUwbweY3Js/sfYAAAAAAAAAAQAAAACAAAAAQAAADDqx1fhQlDdu2M9v7/Sq60hC+RdfzJ4jWneZGk/litFdwAAAABW9HPgAAAAAAAAAAAAAAABIWq8yE5o7tl9kP84Jj2U/sHjqPBaooLpvTpyFLBcwLcAAABAwJh9IG4BPRTtEYj4XsHovh/wdykokhAurZu7OJC+9KdS1bmYBDclfH3iyvtetxylT4FZ0byeO6IsEsaMpFMsBA==');
INSERT INTO scphistory VALUES ('GCQ7OEPPUJPXWLPS2E7SMR7ZL3C6XHUPEDOHPFGBXQPGG4TM73D5RTW7', 5, 'AAAAAKH3Ee+iX3st8tE/Jkf5XsXrno8g3HeUwbweY3Js/sfYAAAAAAAAAAUAAAACAAAAAQAAADDqwJpJPjpz77a00VQZVNc3mTil96v5mHwMLn+D4NxCagAAAABW9HPhAAAAAAAAAAAAAAABIWq8yE5o7tl9kP84Jj2U/sHjqPBaooLpvTpyFLBcwLcAAABA41mxgTBwvZ0mIde6mbSPTVhuA+2w25xY7Z7EEhq6NztQoQNbp4i4qaARPnoa5G32BOy6x+X7vOPDCuVmgQKaAA==');


--
-- Data for Name: scpquorums; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO scpquorums VALUES ('216abcc84e68eed97d90ff38263d94fec1e3a8f05aa282e9bd3a7214b05cc0b7', 5, 'AAAAAQAAAAEAAAAAofcR76Jfey3y0T8mR/lexeuejyDcd5TBvB5jcmz+x9gAAAAA');


--
-- Data for Name: signers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: storestate; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO storestate VALUES ('databaseschema                  ', '3');
INSERT INTO storestate VALUES ('forcescponnextlaunch            ', 'false');
INSERT INTO storestate VALUES ('lastclosedledger                ', 'c26bdba9f858b54cdf0581f05a2da33dc2f9e3b63cc55b16e9a2239e80876141');
INSERT INTO storestate VALUES ('historyarchivestate             ', '{
    "version": 1,
    "server": "v0.4.1-61-gffd1ccd",
    "currentLedger": 5,
    "currentBuckets": [
        {
            "curr": "216adf8a80d1f692bf7016796b687efe0f551079f5c27cee55cde897143d62c5",
            "next": {
                "state": 0
            },
            "snap": "02870372fb6117ddff082a472980c4cc3c9575be56edc7c87991ab815debf0ae"
        },
        {
            "curr": "ef31a20a398ee73ce22275ea8177786bac54656f33dcc4f3fec60d55ddf163d9",
            "next": {
                "state": 1,
                "output": "02870372fb6117ddff082a472980c4cc3c9575be56edc7c87991ab815debf0ae"
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        }
    ]
}');
INSERT INTO storestate VALUES ('lastscpdata                     ', 'AAAAAgAAAACh9xHvol97LfLRPyZH+V7F656PINx3lMG8HmNybP7H2AAAAAAAAAAFAAAAAyFqvMhOaO7ZfZD/OCY9lP7B46jwWqKC6b06chSwXMC3AAAAAQAAADDqwJpJPjpz77a00VQZVNc3mTil96v5mHwMLn+D4NxCagAAAABW9HPhAAAAAAAAAAAAAAABAAAAMOrAmkk+OnPvtrTRVBlU1zeZOKX3q/mYfAwuf4Pg3EJqAAAAAFb0c+EAAAAAAAAAAAAAAEBfyvhSXiyCuIgMYeQt3cErBqQFtqpepDvB4WmcXRnE4aYGYMoIyn96U3yXiz+xZx6mlbRfETLVRWMFctX64zwHAAAAAKH3Ee+iX3st8tE/Jkf5XsXrno8g3HeUwbweY3Js/sfYAAAAAAAAAAUAAAACAAAAAQAAADDqwJpJPjpz77a00VQZVNc3mTil96v5mHwMLn+D4NxCagAAAABW9HPhAAAAAAAAAAAAAAABIWq8yE5o7tl9kP84Jj2U/sHjqPBaooLpvTpyFLBcwLcAAABA41mxgTBwvZ0mIde6mbSPTVhuA+2w25xY7Z7EEhq6NztQoQNbp4i4qaARPnoa5G32BOy6x+X7vOPDCuVmgQKaAAAAAAHoSjwqrd+l3MA7z44A23+MIZQQZ5/rB191cQxSvE9zpQAAAAEAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAABkAAAAAgAAAAIAAAAAAAAAAAAAAAEAAAAAAAAAAQAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAFVU0QAAAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAF0h26AAAAAAAAAAAAa7kvkwAAABAnt8vooy2MPp6VSDo4R3Si++Fuadk3MzaowBTwNbLuqOWSdERMjVz3JpWFKsuW5vKKjkTFZrjZ8EQwxeo4DWJBgAAAAEAAAABAAAAAQAAAACh9xHvol97LfLRPyZH+V7F656PINx3lMG8HmNybP7H2AAAAAA=');


--
-- Data for Name: trustlines; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO trustlines VALUES ('GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 1, 'GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4', 'USD', 9223372036854775807, 99900000000000, 1, 5);


--
-- Data for Name: txfeehistory; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO txfeehistory VALUES ('666656a6eade2082c5780571267d9e4453eee5781ca9a58aa319eb0fe83455fd', 2, 1, 'AAAAAgAAAAMAAAABAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/+cAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO txfeehistory VALUES ('0ee11ddb4817a6165f062c28273bf521d9bfedca4ea304f7bded2cb8ed422b7e', 2, 2, 'AAAAAQAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/84AAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO txfeehistory VALUES ('bd486dbdd02d460817671c4a5a7e9d6e865ca29cb41e62d7aaf70a2fee5b36de', 3, 1, 'AAAAAgAAAAMAAAACAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAA7msoAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAA7msmcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO txfeehistory VALUES ('267d3bd55a6902624d03f3895bc91bf89cb0379b75d39e5b97dc3d448a6ee5cb', 4, 1, 'AAAAAgAAAAMAAAACAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAA7msoAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAEAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAA7msmcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO txfeehistory VALUES ('23071d02983ad8b70733b8ee52a19745a366d71c1f7455199773e7683ddaa035', 5, 1, 'AAAAAgAAAAMAAAADAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAA7msmcAAAAAgAAAAEAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAA7msk4AAAAAgAAAAIAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');


--
-- Data for Name: txhistory; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO txhistory VALUES ('666656a6eade2082c5780571267d9e4453eee5781ca9a58aa319eb0fe83455fd', 2, 1, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAO5rKAAAAAAAAAAABVvwF9wAAAEBdDXe23U4e9C2SxpBLZRx1rJzSFLJ0xDD0uKGpmqbflDT+XXIq6UiDBzmFxt+GO+XqFoQPdrXT7p1oLZIHqTMP', 'ZmZWpureIILFeAVxJn2eRFPu5XgcqaWKoxnrD+g0Vf0AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAADuaygAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2s2vJNTgAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO txhistory VALUES ('0ee11ddb4817a6165f062c28273bf521d9bfedca4ea304f7bded2cb8ed422b7e', 2, 2, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAAO5rKAAAAAAAAAAABVvwF9wAAAEAZCSSFbUKIiIThB3BIHf1u5g0vDSZQ0CD4fBA+pPqUQ/9dwSOSL+NGMZZvl2eJW02eOREjO4QVR4cIcmRmBdYN', 'DuEd20gXphZfBiwoJzv1Idm/7cpOowT3ve0suO1CK34AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAADuaygAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2szAuazgAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO txhistory VALUES ('bd486dbdd02d460817671c4a5a7e9d6e865ca29cb41e62d7aaf70a2fee5b36de', 3, 1, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt73//////////AAAAAAAAAAGu5L5MAAAAQB9kmKW2q3v7Qfy8PMekEb1TTI5ixqkI0BogXrOt7gO162Qbkh2dSTUfeDovc0PAafhDXxthVAlsLujlBmyjBAY=', 'vUhtvdAtRggXZxxKWn6dboZcopy0HmLXqvcKL+5bNt4AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAYAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAABAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAADuayZwAAAACAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO txhistory VALUES ('267d3bd55a6902624d03f3895bc91bf89cb0379b75d39e5b97dc3d448a6ee5cb', 4, 1, 'AAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAABVVNEAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAWvMQekAAAAAAAAAAAAH5kC3vAAAAQMvzjWcUe8CdwX/cl5px2TkYt672RXOFvJOTK5fK6SjBpPHGj5EIFxCRXdLAFy2K1nSkHSnIk9N2qwwQKwK1sww=', 'Jn071VppAmJNA/OJW8kb+JywN5t1055bl9w9RIpu5csAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAABAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAQAAAABAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAFrzEHpAAH//////////AAAAAQAAAAAAAAAA');
INSERT INTO txhistory VALUES ('23071d02983ad8b70733b8ee52a19745a366d71c1f7455199773e7683ddaa035', 5, 1, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAACAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAABVVNEAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAABdIdugAAAAAAAAAAAGu5L5MAAAAQJ7fL6KMtjD6elUg6OEd0ovvhbmnZNzM2qMAU8DWy7qjlknRETI1c9yaVhSrLlubyio5ExWa42fBEMMXqOA1iQY=', 'IwcdApg62LcHM7juUqGXRaNm1xwfdFUZl3PnaD3aoDUAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAAAQAAAABAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAFrzEHpAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAUAAAABAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAFrbyANYAH//////////AAAAAQAAAAAAAAAA');


--
-- Name: accountdata_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accountdata
    ADD CONSTRAINT accountdata_pkey PRIMARY KEY (accountid, dataname);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (accountid);


--
-- Name: ledgerheaders_ledgerseq_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ledgerheaders
    ADD CONSTRAINT ledgerheaders_ledgerseq_key UNIQUE (ledgerseq);


--
-- Name: ledgerheaders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ledgerheaders
    ADD CONSTRAINT ledgerheaders_pkey PRIMARY KEY (ledgerhash);


--
-- Name: offers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY offers
    ADD CONSTRAINT offers_pkey PRIMARY KEY (offerid);


--
-- Name: peers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY peers
    ADD CONSTRAINT peers_pkey PRIMARY KEY (ip, port);


--
-- Name: publishqueue_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY publishqueue
    ADD CONSTRAINT publishqueue_pkey PRIMARY KEY (ledger);


--
-- Name: pubsub_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pubsub
    ADD CONSTRAINT pubsub_pkey PRIMARY KEY (resid);


--
-- Name: scpquorums_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scpquorums
    ADD CONSTRAINT scpquorums_pkey PRIMARY KEY (qsethash);


--
-- Name: signers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY signers
    ADD CONSTRAINT signers_pkey PRIMARY KEY (accountid, publickey);


--
-- Name: storestate_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY storestate
    ADD CONSTRAINT storestate_pkey PRIMARY KEY (statename);


--
-- Name: trustlines_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trustlines
    ADD CONSTRAINT trustlines_pkey PRIMARY KEY (accountid, issuer, assetcode);


--
-- Name: txfeehistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY txfeehistory
    ADD CONSTRAINT txfeehistory_pkey PRIMARY KEY (ledgerseq, txindex);


--
-- Name: txhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY txhistory
    ADD CONSTRAINT txhistory_pkey PRIMARY KEY (ledgerseq, txindex);


--
-- Name: accountbalances; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX accountbalances ON accounts USING btree (balance) WHERE (balance >= 1000000000);


--
-- Name: buyingissuerindex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX buyingissuerindex ON offers USING btree (buyingissuer);


--
-- Name: histbyseq; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX histbyseq ON txhistory USING btree (ledgerseq);


--
-- Name: histfeebyseq; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX histfeebyseq ON txfeehistory USING btree (ledgerseq);


--
-- Name: ledgersbyseq; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ledgersbyseq ON ledgerheaders USING btree (ledgerseq);


--
-- Name: priceindex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX priceindex ON offers USING btree (price);


--
-- Name: scpenvsbyseq; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX scpenvsbyseq ON scphistory USING btree (ledgerseq);


--
-- Name: sellingissuerindex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX sellingissuerindex ON offers USING btree (sellingissuer);


--
-- Name: signersaccount; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX signersaccount ON signers USING btree (accountid);


--
-- PostgreSQL database dump complete
--

