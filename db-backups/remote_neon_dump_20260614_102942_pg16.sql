--
-- PostgreSQL database dump
--

\restrict DeaVx5Jo0Zd29JdxFbBplE5YOqJW9DngMVp1ltftk86GpJNOHr5cMAKMinawsG7

-- Dumped from database version 18.4 (6e15e70)
-- Dumped by pg_dump version 18.4 (Debian 18.4-1.pgdg13+1)

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

ALTER TABLE IF EXISTS ONLY public.stock_price_snapshots DROP CONSTRAINT IF EXISTS fk_stock_price_snapshots_stock;
ALTER TABLE IF EXISTS ONLY public.recommendations DROP CONSTRAINT IF EXISTS fk_recommendations_user;
ALTER TABLE IF EXISTS ONLY public.recommendations DROP CONSTRAINT IF EXISTS fk_recommendations_portfolio_item;
ALTER TABLE IF EXISTS ONLY public.recommendation_factor_details DROP CONSTRAINT IF EXISTS fk_recommendation_factor_details_recommendation;
ALTER TABLE IF EXISTS ONLY public.recommendation_evidence DROP CONSTRAINT IF EXISTS fk_recommendation_evidence_recommendation;
ALTER TABLE IF EXISTS ONLY public.portfolio_items DROP CONSTRAINT IF EXISTS fk_portfolio_items_user;
ALTER TABLE IF EXISTS ONLY public.portfolio_items DROP CONSTRAINT IF EXISTS fk_portfolio_items_stock;
ALTER TABLE IF EXISTS ONLY public.news_analysis_cache DROP CONSTRAINT IF EXISTS fk_news_analysis_cache_stock;
DROP INDEX IF EXISTS public.uk_users_google_subject;
DROP INDEX IF EXISTS public.uk_users_email;
DROP INDEX IF EXISTS public.uk_users_auth_token;
DROP INDEX IF EXISTS public.uk_stocks_ticker_exchange;
DROP INDEX IF EXISTS public.uk_stocks_finnhub_symbol;
DROP INDEX IF EXISTS public.uk_stock_price_snapshots_stock_date;
DROP INDEX IF EXISTS public.uk_recommendations_portfolio_item_date;
DROP INDEX IF EXISTS public.uk_portfolio_items_user_stock;
DROP INDEX IF EXISTS public.uk_news_analysis_cache_stock_content;
DROP INDEX IF EXISTS public.idx_stocks_ticker_normalized;
DROP INDEX IF EXISTS public.idx_stocks_name_ko_normalized;
DROP INDEX IF EXISTS public.idx_stocks_name_ko;
DROP INDEX IF EXISTS public.idx_stocks_name_en_normalized;
DROP INDEX IF EXISTS public.idx_stocks_name_en;
DROP INDEX IF EXISTS public.idx_stock_price_snapshots_stock_date;
DROP INDEX IF EXISTS public.idx_recommendations_user_id_date;
DROP INDEX IF EXISTS public.idx_recommendations_portfolio_item_id;
DROP INDEX IF EXISTS public.idx_recommendation_factor_details_recommendation_id;
DROP INDEX IF EXISTS public.idx_recommendation_factor_details_factor_code;
DROP INDEX IF EXISTS public.idx_recommendation_evidence_recommendation_id;
DROP INDEX IF EXISTS public.idx_portfolio_items_user_id;
DROP INDEX IF EXISTS public.idx_news_analysis_cache_symbol_analyzed_at;
DROP INDEX IF EXISTS public.idx_news_analysis_cache_stock_published_at;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.stocks DROP CONSTRAINT IF EXISTS stocks_pkey;
ALTER TABLE IF EXISTS ONLY public.stock_price_snapshots DROP CONSTRAINT IF EXISTS stock_price_snapshots_pkey;
ALTER TABLE IF EXISTS ONLY public.recommendations DROP CONSTRAINT IF EXISTS recommendations_pkey;
ALTER TABLE IF EXISTS ONLY public.recommendation_factor_details DROP CONSTRAINT IF EXISTS recommendation_factor_details_pkey;
ALTER TABLE IF EXISTS ONLY public.recommendation_evidence DROP CONSTRAINT IF EXISTS recommendation_evidence_pkey;
ALTER TABLE IF EXISTS ONLY public.portfolio_items DROP CONSTRAINT IF EXISTS portfolio_items_pkey;
ALTER TABLE IF EXISTS ONLY public.news_analysis_cache DROP CONSTRAINT IF EXISTS news_analysis_cache_pkey;
ALTER TABLE IF EXISTS public.users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.stocks ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.stock_price_snapshots ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.recommendations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.recommendation_factor_details ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.recommendation_evidence ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.portfolio_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.news_analysis_cache ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.users_id_seq;
DROP TABLE IF EXISTS public.users;
DROP SEQUENCE IF EXISTS public.stocks_id_seq;
DROP TABLE IF EXISTS public.stocks;
DROP SEQUENCE IF EXISTS public.stock_price_snapshots_id_seq;
DROP TABLE IF EXISTS public.stock_price_snapshots;
DROP SEQUENCE IF EXISTS public.recommendations_id_seq;
DROP TABLE IF EXISTS public.recommendations;
DROP SEQUENCE IF EXISTS public.recommendation_factor_details_id_seq;
DROP TABLE IF EXISTS public.recommendation_factor_details;
DROP SEQUENCE IF EXISTS public.recommendation_evidence_id_seq;
DROP TABLE IF EXISTS public.recommendation_evidence;
DROP SEQUENCE IF EXISTS public.portfolio_items_id_seq;
DROP TABLE IF EXISTS public.portfolio_items;
DROP SEQUENCE IF EXISTS public.news_analysis_cache_id_seq;
DROP TABLE IF EXISTS public.news_analysis_cache;
DROP EXTENSION IF EXISTS pg_stat_statements;
--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: news_analysis_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.news_analysis_cache (
    id bigint NOT NULL,
    stock_id bigint NOT NULL,
    news_published_at timestamp with time zone,
    headline character varying(500) NOT NULL,
    summary text,
    source_name character varying(100),
    news_url text,
    sentiment_label character varying(20),
    sentiment_score integer,
    llm_model character varying(100),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    news_id character varying(100),
    symbol character varying(30) NOT NULL,
    keyword_score integer,
    relevance_score integer,
    impact_level character varying(20),
    reason text,
    recency_weight numeric(6,4),
    impact_weight numeric(6,4),
    weighted_score numeric(10,4),
    content_hash character varying(64) NOT NULL,
    analyzed_at timestamp with time zone DEFAULT now() NOT NULL,
    analysis_batch_hash character varying(64) NOT NULL,
    CONSTRAINT ck_news_analysis_impact_level CHECK (((impact_level)::text = ANY (ARRAY[('LOW'::character varying)::text, ('MEDIUM'::character varying)::text, ('HIGH'::character varying)::text]))),
    CONSTRAINT ck_news_analysis_keyword_score CHECK (((keyword_score >= '-100'::integer) AND (keyword_score <= 100))),
    CONSTRAINT ck_news_analysis_relevance_score CHECK (((relevance_score >= 0) AND (relevance_score <= 100))),
    CONSTRAINT ck_news_analysis_sentiment_score CHECK (((sentiment_score >= '-100'::integer) AND (sentiment_score <= 100)))
);


--
-- Name: news_analysis_cache_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.news_analysis_cache_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: news_analysis_cache_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.news_analysis_cache_id_seq OWNED BY public.news_analysis_cache.id;


--
-- Name: portfolio_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.portfolio_items (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    stock_id bigint NOT NULL,
    daily_invest_amount numeric(15,2) NOT NULL,
    holding_quantity numeric(18,6),
    investment_start_date date,
    memo text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: portfolio_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.portfolio_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: portfolio_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.portfolio_items_id_seq OWNED BY public.portfolio_items.id;


--
-- Name: recommendation_evidence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recommendation_evidence (
    id bigint NOT NULL,
    recommendation_id bigint NOT NULL,
    evidence_type character varying(30) NOT NULL,
    title character varying(100) NOT NULL,
    body text NOT NULL,
    score_impact integer,
    display_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: recommendation_evidence_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recommendation_evidence_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommendation_evidence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recommendation_evidence_id_seq OWNED BY public.recommendation_evidence.id;


--
-- Name: recommendation_factor_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recommendation_factor_details (
    id bigint NOT NULL,
    recommendation_id bigint NOT NULL,
    factor_code character varying(40) NOT NULL,
    factor_score integer NOT NULL,
    factor_weight integer NOT NULL,
    factor_summary character varying(255),
    factor_raw_json jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_recommendation_factor_details_score CHECK (((factor_score >= 0) AND (factor_score <= 100))),
    CONSTRAINT ck_recommendation_factor_details_weight CHECK (((factor_weight >= 0) AND (factor_weight <= 100)))
);


--
-- Name: recommendation_factor_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recommendation_factor_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommendation_factor_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recommendation_factor_details_id_seq OWNED BY public.recommendation_factor_details.id;


--
-- Name: recommendations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recommendations (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    portfolio_item_id bigint NOT NULL,
    recommendation_date date NOT NULL,
    recommendation_status character varying(20) NOT NULL,
    engine_score integer NOT NULL,
    confidence_score integer,
    current_amount numeric(15,2) NOT NULL,
    recommended_amount numeric(15,2) NOT NULL,
    final_note text,
    engine_version character varying(50),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    formula_version character varying(50),
    raw_score integer,
    risk_adjustment integer,
    price_score integer,
    news_score integer,
    price_weight integer,
    news_weight integer,
    price_return_30d numeric(10,4),
    news_sentiment_score integer,
    increase_eligible boolean,
    price_momentum_score integer,
    price_stability_score integer,
    fundamental_quality_score integer,
    user_fit_score integer,
    cross_factor_adjustment integer,
    user_adjustment integer,
    risk_profile_applied character varying(30),
    confidence_breakdown_json jsonb,
    CONSTRAINT ck_recommendations_fundamental_quality_score CHECK (((fundamental_quality_score IS NULL) OR ((fundamental_quality_score >= 0) AND (fundamental_quality_score <= 100)))),
    CONSTRAINT ck_recommendations_news_score CHECK (((news_score >= 0) AND (news_score <= 100))),
    CONSTRAINT ck_recommendations_news_sentiment_score CHECK (((news_sentiment_score >= '-100'::integer) AND (news_sentiment_score <= 100))),
    CONSTRAINT ck_recommendations_news_weight CHECK (((news_weight >= 0) AND (news_weight <= 100))),
    CONSTRAINT ck_recommendations_price_momentum_score CHECK (((price_momentum_score IS NULL) OR ((price_momentum_score >= 0) AND (price_momentum_score <= 100)))),
    CONSTRAINT ck_recommendations_price_score CHECK (((price_score >= 0) AND (price_score <= 100))),
    CONSTRAINT ck_recommendations_price_stability_score CHECK (((price_stability_score IS NULL) OR ((price_stability_score >= 0) AND (price_stability_score <= 100)))),
    CONSTRAINT ck_recommendations_price_weight CHECK (((price_weight >= 0) AND (price_weight <= 100))),
    CONSTRAINT ck_recommendations_raw_score CHECK (((raw_score >= 0) AND (raw_score <= 100))),
    CONSTRAINT ck_recommendations_user_fit_score CHECK (((user_fit_score IS NULL) OR ((user_fit_score >= 0) AND (user_fit_score <= 100))))
);


--
-- Name: recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recommendations_id_seq OWNED BY public.recommendations.id;


--
-- Name: stock_price_snapshots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_price_snapshots (
    id bigint NOT NULL,
    stock_id bigint NOT NULL,
    snapshot_date date NOT NULL,
    current_price numeric(15,4),
    change_rate_1d numeric(8,4),
    change_rate_30d numeric(8,4),
    market_cap numeric(20,2),
    per_value numeric(12,4),
    source character varying(30),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    change_rate_7d numeric(8,4)
);


--
-- Name: stock_price_snapshots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stock_price_snapshots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stock_price_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stock_price_snapshots_id_seq OWNED BY public.stock_price_snapshots.id;


--
-- Name: stocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stocks (
    id bigint NOT NULL,
    ticker character varying(30) NOT NULL,
    exchange_code character varying(30) NOT NULL,
    finnhub_symbol character varying(50),
    name_ko text,
    name_en text NOT NULL,
    logo_url text,
    market_type character varying(50),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    ticker_normalized character varying(30) NOT NULL,
    name_ko_normalized text,
    name_en_normalized text NOT NULL,
    search_text text NOT NULL
);


--
-- Name: stocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stocks_id_seq OWNED BY public.stocks.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    nickname character varying(100) NOT NULL,
    status character varying(30) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    google_subject character varying(255),
    profile_image_url text,
    auth_token character varying(255),
    auth_token_expires_at timestamp with time zone,
    last_login_at timestamp with time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: news_analysis_cache id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_analysis_cache ALTER COLUMN id SET DEFAULT nextval('public.news_analysis_cache_id_seq'::regclass);


--
-- Name: portfolio_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.portfolio_items ALTER COLUMN id SET DEFAULT nextval('public.portfolio_items_id_seq'::regclass);


--
-- Name: recommendation_evidence id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendation_evidence ALTER COLUMN id SET DEFAULT nextval('public.recommendation_evidence_id_seq'::regclass);


--
-- Name: recommendation_factor_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendation_factor_details ALTER COLUMN id SET DEFAULT nextval('public.recommendation_factor_details_id_seq'::regclass);


--
-- Name: recommendations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations ALTER COLUMN id SET DEFAULT nextval('public.recommendations_id_seq'::regclass);


--
-- Name: stock_price_snapshots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_price_snapshots ALTER COLUMN id SET DEFAULT nextval('public.stock_price_snapshots_id_seq'::regclass);


--
-- Name: stocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stocks ALTER COLUMN id SET DEFAULT nextval('public.stocks_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: news_analysis_cache; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.news_analysis_cache (id, stock_id, news_published_at, headline, summary, source_name, news_url, sentiment_label, sentiment_score, llm_model, created_at, news_id, symbol, keyword_score, relevance_score, impact_level, reason, recency_weight, impact_weight, weighted_score, content_hash, analyzed_at, analysis_batch_hash) FROM stdin;
213	4077	2026-06-12 03:26:16+00	AI Integration and iPhone Growth Assert Apple Inc. (AAPL) as One of the Best Forever Stocks to Buy	AI 통합과 아이폰 성장에 대한 긍정적인 전망으로 Apple Inc.(AAPL)가 최고의 영구 투자 주식 중 하나로 꼽히고 있습니다. Gene Munster는 WWDC의 영향으로 Apple의 투자 심리가 크게 개선될 것으로 예상합니다.	Yahoo	https://finnhub.io/api/news?id=dd0917b30e0bd4c086123764fd8fcb8aac7440c24047e8d1ded24be5471099fc	POSITIVE	66	gemini-2.5-flash-lite	2026-06-12 08:59:43.367142+00	140614525	AAPL	18	90	HIGH	AI 통합과 아이폰 성장에 대한 긍정적인 전망으로 장기 투자 매력도를 높이고 있습니다.	1.0000	1.3500	80.1900	01d8fd34c35dd4eb4cc68470e986ad4d4cf637d082c6eee971a6c27a969948f9	2026-06-12 08:59:49.594649+00	f873bbe4fdbfb89ff313953f351a9c79e7d6a3c3986e4840fa652b3aca873ea2
211	4078	2026-06-11 22:48:00+00	S&P 500, Nasdaq, Dow End Higher After Trump Signals Iran Deal Coming Soon — ADBE, INTC, AMC, GOOGL, ORCL In Focus	알파벳(GOOGL)은 억만장자 켄 그리핀의 포트폴리오에서 주목받는 AI 주식으로, 연초 대비 및 지난 한 해 동안 주가 상승률이 높습니다.	Yahoo	https://finnhub.io/api/news?id=6a36c740aff5f6ea0867c24a6c5202f8b36bea6f4b23cd4e683c19d82c52cc88	POSITIVE	68	gemini-2.5-flash-lite	2026-06-12 08:55:38.783614+00	140612973	GOOGL	0	90	MEDIUM	**트럼프의 이란 핵 협상 관련 긍정적 발언 속에 AI 투자 유망주로 꼽히는 알파벳(GOOGL) 주가 상승세 기대.**	1.0000	1.0000	61.2000	57a0de85b7e5f9eda19062aa9857fd32ba49c3d7382a8226ea2027a3e78b8975	2026-06-12 08:55:51.086636+00	1a232acbbb58980e6eb068979e7ec73b91d8482d2713190c26b478cf94908ec6
199	4076	2026-06-11 18:54:56+00	Broadcom’s Selloff Shows the New Rule of AI Stocks: Great Isn’t Good	Nvidia, AMD, Intel 및 Arm이 'Agentic AI'의 등장으로 인해 급등하며 칩스톡 랠리를 주도하고 있습니다. 이는 NVIDIA에게 긍정적인 시장 환경을 조성합니다.	Yahoo	https://finnhub.io/api/news?id=3ebbcb322c184a7583136442bf4bdd8c1ea17bb8b89959d561711239a3a96f70	POSITIVE	71	gemini-2.5-flash-lite	2026-06-11 23:38:51.964191+00	140610429	NVDA	18	75	HIGH	'Agentic AI'가 게임 체인저로 불리며 칩스톡 전반의 상승을 이끌고 있으며, 이는 NVIDIA에게 긍정적인 전망을 제시합니다.	1.0000	1.3500	71.8875	51c489700bf8c41f126a732727ff8bced945fa6140818741564661d3ef1fc970	2026-06-11 23:38:55.753412+00	b62592980e327ee2aac5e1a2d2f7d31d78bbcc2264da33752c93f234fa927673
212	4078	2026-06-12 03:25:50+00	Is Alphabet Inc. (GOOGL) One of the Best Forever Stocks to Buy on $85B Capital Raise?	트럼프 대통령이 이란과의 거래 가능성을 시사하면서 S&P 500, 나스닥, 다우 지수가 상승했으며, 이는 시장 전반에 영향을 미칠 수 있는 소식입니다.	Yahoo	https://finnhub.io/api/news?id=ee61b884cc03592e91fb31fe12f8058cdc842adaa02d09a538132ee05a85002f	NEUTRAL	5	gemini-2.5-flash-lite	2026-06-12 08:55:38.783614+00	140614533	GOOGL	36	90	LOW	**알파벳(GOOGL)의 850억 달러 자본 조달이 지정학적 이슈와 얽혀 있어, 현시점에서는 알파벳에 대한 긍정적 혹은 부정적 투자 판단을 내리기 어렵습니다.**	1.0000	0.7500	3.3750	c093d3c698c4e4862d066f6caf92f373c948c38eec3c0225df50a599dfff57aa	2026-06-12 08:55:51.175936+00	1a232acbbb58980e6eb068979e7ec73b91d8482d2713190c26b478cf94908ec6
218	4113	2026-06-12 01:31:11+00	SpaceX May Look Expensive Today — Palantir Co-Founder Says It Could Look 'Really Cheap' In 10 Years	Palantir 공동 창업자는 SpaceX가 10년 안에 '정말 싸게' 보일 수 있다고 말하며, 현재의 가치평가 논쟁에 대한 의견을 제시했습니다.	Yahoo	https://finnhub.io/api/news?id=763b4ce9d54d07d1a5ebd0e273ef0bdf87d7ca678fd4f76e867cb720a5e714d9	NEUTRAL	9	gemini-2.5-flash-lite	2026-06-12 09:03:31.20836+00	140614562	PLTR	0	75	LOW	SpaceX의 가치평가에 대한 논의는 Palantir의 공동 창업자가 참여했지만 Palantir 자체의 주가나 사업에 대한 직접적인 영향은 적습니다.	1.0000	0.7500	5.0625	396b77b89843b5ec4188d9f106d51cbcf6f0bb25c248702534ef48c4a134f911	2026-06-12 09:03:36.112515+00	e4620c95967ff82cf3144fcb8544e810b88577a8aee39454aa59a4c116182bea
217	4113	2026-06-12 06:12:27+00	Palantir Expands Commercial AI Footprint With New Multiyear Enterprise Deals	Palantir Technologies는 고객 수요에 힘입어 새로운 엔터프라이즈 AI 배포를 발표했으며, McCarthy Building Companies, GNP Seguros, Kirkland & Ellis와 다년간 수백만 달러 규모의 협력을 체결했습니다.	Yahoo	https://finnhub.io/api/news?id=348417111d0b8b51c60f14a3740a36a4ba88443f1ed253b298c70d5d7818ecf2	POSITIVE	51	gemini-2.5-flash-lite	2026-06-12 09:03:31.20836+00	140615534	PLTR	0	75	MEDIUM	McCarthy Building Companies, GNP Seguros, Kirkland & Ellis 등과의 새로운 엔터프라이즈 AI 계약은 Palantir의 상업적 AI 솔루션에 대한 수요 증가를 나타냅니다.	1.0000	1.0000	38.2500	e303f0e98a30a4eb0edd00672da06565b7cdfbaf4407daeeb201a3e80eb35dce	2026-06-12 09:03:36.108503+00	e4620c95967ff82cf3144fcb8544e810b88577a8aee39454aa59a4c116182bea
215	4077	2026-06-11 21:45:02+00	Here's Why Apple (AAPL) Gained But Lagged the Market Today	Apple(AAPL)은 최근 거래 세션에서 이전 종가 대비 1.3% 상승한 295.38달러로 마감했습니다.	Yahoo	https://finnhub.io/api/news?id=4413795342297aef9ecd62757af9f7327e0b80c5d60c4d1220bce1ef95564e97	NEUTRAL	9	gemini-2.5-flash-lite	2026-06-12 08:59:43.367142+00	140612945	AAPL	0	90	LOW	장중 소폭 상승했으나 시장 평균 수익률에는 미치지 못해 단기적인 주가 영향은 제한적입니다.	1.0000	0.7500	6.0750	e57cdc5e31e167e5e76610406df30a69f4be919691121ae110e666b5e6df4919	2026-06-12 08:59:49.679856+00	f873bbe4fdbfb89ff313953f351a9c79e7d6a3c3986e4840fa652b3aca873ea2
145	4090	2026-06-10 08:30:40+00	AMD's AI Story Is No Longer Speculative, It's Funded	AMD의 AI 사업이 더 이상 투기적인 수준을 넘어 펀딩이 확보된 단계에 이르렀다는 분석은 AI 및 데이터센터 부문의 수요 증가로 인한 매출 성장과 마진 확대를 예상하게 하여 긍정적인 전망을 제시합니다.	SeekingAlpha	https://finnhub.io/api/news?id=08fd6d2a457449f13de3413d31b31301856793915ce2632ff3343c858fc8c70d	POSITIVE	75	gemini-2.5-flash-lite	2026-06-10 13:04:48.81723+00	140592328	AMD	18	90	HIGH	AI와 데이터센터 부문의 견조한 수요와 성장 전망은 AMD의 향후 실적에 대한 기대감을 높여 주가에 긍정적인 영향을 미칠 것입니다.	1.0000	1.3500	91.1250	c7dbf8f7bd18a32637879d11311287f99b6940eead1639e7fb213f3b7d14ba78	2026-06-10 13:04:53.752544+00	37242f3d12e5a8035bc7caab102c77242663a75c87e8aac7f9217aebdbfa5ed8
200	4076	2026-06-11 17:30:12+00	NVIDIA Corp. (NVDA) Is A Top AI Stock In Ken Griffin’s Portfolio	Broadcom의 실적 발표 후 주가 하락은 AI 주식에 대한 새로운 기준을 보여줍니다. NVIDIA는 Broadcom 다음으로 두 번째로 큰 AI 칩 기업으로, 이러한 시장 분위기에 영향을 받을 수 있습니다.	Yahoo	https://finnhub.io/api/news?id=f5b070746128dec4b2908e918c450b9cf2f967cc15908b247ce9c0abc1a866a7	NEGATIVE	-40	gemini-2.5-flash-lite	2026-06-11 23:38:51.964191+00	140608850	NVDA	18	78	MEDIUM	Broadcom의 실적 발표 후 주가 하락은 AI 칩 시장 전반의 투자 심리를 반영하며, NVIDIA 역시 이러한 시장 상황에서 자유롭지 못할 수 있음을 시사합니다.	1.0000	1.0000	-31.2000	bc0366ae15745409598ab6f1abd421f908636931a501185b95dfe5775edf0d37	2026-06-11 23:38:55.940051+00	b62592980e327ee2aac5e1a2d2f7d31d78bbcc2264da33752c93f234fa927673
214	4077	2026-06-11 17:30:42+00	Apple Inc. (AAPL) Is A Top Stock In Ken Griffin’s Portfolio	Apple Inc.(AAPL)는 억만장자 Ken Griffin의 포트폴리오 상위 13개 추천 주식 중 하나입니다. 최근 WWDC에서 발표된 Siri AI는 주목받고 있습니다.	Yahoo	https://finnhub.io/api/news?id=9774a3117d1880a58ce357de5c4f977042d3dd7f7b3b33238dc41ea5756a05d5	POSITIVE	51	gemini-2.5-flash-lite	2026-06-12 08:59:43.367142+00	140608865	AAPL	0	90	MEDIUM	억만장자 Ken Griffin의 포트폴리오 상위 종목으로 선정되었으며, AI 기능 강화 소식이 긍정적인 영향을 미치고 있습니다.	1.0000	1.0000	45.9000	2712048304c45183381570b137d167fe80b3cd46c8bb6d33fdd8f119d0329778	2026-06-12 08:59:49.598085+00	f873bbe4fdbfb89ff313953f351a9c79e7d6a3c3986e4840fa652b3aca873ea2
206	4080	2026-06-11 17:30:17+00	Should You Buy Amazon.com (AMZN)?	아마존이 '라스트 마일' 배송 서비스를 넘어 트럭 단위 미만(less-than-truckload) 화물 운송 서비스를 추가하며 물류 사업을 확장하고 있습니다. 이는 기업들의 물류 효율성을 높여줄 것으로 기대됩니다.	Yahoo	https://finnhub.io/api/news?id=2d0923d1b8dc53dbc10c94fabb496b2cf8a305a28372fa23cff16f7fb1b32436	POSITIVE	58	gemini-2.5-flash-lite	2026-06-11 23:38:51.964191+00	140608866	AMZN	18	78	MEDIUM	아마존이 공급망 서비스를 확장하며 물류 사업 경쟁력을 강화하는 것은 장기적인 성장 동력으로 작용할 수 있습니다.	1.0000	1.0000	45.2400	f8f2f181215b73b2059d8cb9712eefbff2a15b4cfefc3e6518db514dd3d30c1d	2026-06-11 23:39:06.08833+00	844ebad9da4528e93f3db26784869697a4d929eb3de8842a5cf7d0481c36b585
147	4090	2026-06-10 10:49:00+00	Ark Investment's Cathie Wood Just Sold AMD Shares and Bought Nvidia. Is That the Right Move for Investors?	아크 인베스트먼트의 캐시 우드가 AMD 주식을 매도하고 엔비디아 주식을 매수했다는 소식은 투자자들에게 다른 반도체 기업과의 비교 관점을 제시하며, AMD의 단기적인 투자 매력에 대한 의문을 제기할 수 있습니다.	Yahoo	https://finnhub.io/api/news?id=9e69e8fc4bdd7a8496010e4c4d5d12aa853a1f03eab2938d8a388329b367ad6a	NEUTRAL	3	gemini-2.5-flash-lite	2026-06-10 13:04:48.81723+00	140591939	AMD	18	90	MEDIUM	캐시 우드의 투자 결정은 시장에서 주목받는 지표이며, 이는 AMD의 상대적 매력도에 대한 의문을 제기할 수 있습니다.	1.0000	1.0000	2.7000	3ec927cdf55feabb25d63904d78f9ae4d42abb44f85551da246e3effc358f143	2026-06-10 13:04:53.763198+00	37242f3d12e5a8035bc7caab102c77242663a75c87e8aac7f9217aebdbfa5ed8
146	4090	2026-06-09 21:18:14+00	Penguin Solutions, AMD, and Impinj Stocks Trade Down, What You Need To Know	펭귄 솔루션, AMD, 임핀지 등 여러 주식이 하락했으며, 이는 중동 지역의 지정학적 긴장 고조로 인한 거시 경제 불안정성이 반도체 섹터의 회복을 저해했기 때문이라는 분석입니다.	Yahoo	https://finnhub.io/api/news?id=a7a412c74482c80288856b58a7bd54903faf5f327b6b593bcddb10f6afac5e7d	NEGATIVE	-25	gemini-2.5-flash-lite	2026-06-10 13:04:48.81723+00	140586749	AMD	0	90	LOW	해당 뉴스는 AMD 자체의 문제보다는 외부 거시 경제적 요인으로 인한 주가 하락을 설명하므로 직접적인 영향은 제한적입니다.	1.0000	0.7500	-16.8750	a755e9e716b8d834b8f4b2cec0ed7214ebc61e3e22582bbabe92b1517f94fe49	2026-06-10 13:04:53.756428+00	37242f3d12e5a8035bc7caab102c77242663a75c87e8aac7f9217aebdbfa5ed8
83	4096	2026-06-07 16:55:01+00	Intel was on the brink of downfall. A twist in the AI race could boost its revival	Lip-Bu Tan이 2025년 3월 인텔의 수장이 되었을 때, 회사는 턴어라운드가 절실했습니다.	Yahoo	https://finnhub.io/api/news?id=302e3d59344303ef018e8b9b7e7399cb045214641e639b8b1649176cec548420	POSITIVE	51	gemini-2.5-flash-lite	2026-06-07 19:20:28.438555+00	140560393	INTC	0	75	HIGH	AI 경쟁에서의 반전 가능성이 인텔의 부활을 이끌 수 있다는 긍정적인 전망을 제시합니다.	1.0000	1.3500	51.6375	4d099f9ba11721a7a4039de0bbc05633629a1c212388dfe0302cb4649f22ca05	2026-06-07 19:20:42.945193+00	12212f50498ee09d41bb59ba83f3f56adb5e76892f87ed00ad8731d7a4a2cf1e
117	4142	2026-06-09 16:56:55+00	1 Unstoppable Fast-Food Giant to Buy Hand Over Fist and Hold for 25 Years	McDonald's(MCD)는 프랜차이즈 수수료 경제, 배당 기록, 경기 방어적 특성으로 인해 장기 보유에 적합하며, 수십 년간 꾸준히 가치를 창출할 수 있는 몇 안 되는 소비재 기업 중 하나로 평가됩니다.	Yahoo	https://finnhub.io/api/news?id=8085cb5d8e881229a73b58cc20e5d22a24f6c2bc037a8b70314ab019751c4db0	POSITIVE	75	gemini-2.5-flash-lite	2026-06-09 22:51:10.290768+00	140583295	MCD	18	75	HIGH	해당 기사는 McDonald's의 장기 투자 매력과 내재적 가치를 긍정적으로 분석하여 주가 및 적립 투자 판단에 대한 호재로 작용할 것입니다.	1.0000	1.3500	75.9375	c524430bc5e880eba1fcbf94c68bc25e88ab04acb721f27eaa57a4d302ec5882	2026-06-09 22:51:19.398361+00	76e1c02d0a96c765b8fdbec86a50c0b1cf8d46998ec2e50f5bc3ae853b4036bd
207	4080	2026-06-11 17:01:00+00	Amazon expands supply chain services with less-than-truckload freight offering	제프 베이조스가 설립한 AI 스타트업 프로메테우스가 410억 달러의 가치로 펀딩 라운드를 성공적으로 마쳤습니다. 이는 AI 분야에서의 베이조스의 영향력을 보여주는 사례입니다.	Yahoo	https://finnhub.io/api/news?id=0ac29f32f6d249d12398b4607644f1bba32c15cb30ffb0d301875609a3f06b18	POSITIVE	17	gemini-2.5-flash-lite	2026-06-11 23:38:51.964191+00	140608883	AMZN	0	63	LOW	창업자의 AI 스타트업 투자가치가 크게 상승한 것은 긍정적이지만, 아마존 자체의 직접적인 실적이나 사업 영향과는 거리가 있습니다.	1.0000	0.7500	8.0325	479dc5189e924256876cd681bdb5fd1f92ccfc411ff595a7a8a7bd74c3d066a6	2026-06-11 23:39:06.273345+00	844ebad9da4528e93f3db26784869697a4d929eb3de8842a5cf7d0481c36b585
216	4113	2026-06-11 18:41:16+00	PLTR Stock: What Does Its Valuation Imply?	Palantir Technologies는 하이퍼 성장 단계에 있으며, 회사의 AIP 플랫폼은 해군과 같은 중요 기관의 운영 핵심이 되고 있습니다.	Yahoo	https://finnhub.io/api/news?id=9d094434df572c4962060629ba4ddd552bf0f496e1d2aa388687d89961009c5c	POSITIVE	66	gemini-2.5-flash-lite	2026-06-12 09:03:31.20836+00	140610442	PLTR	18	90	HIGH	Palantir의 AIP 플랫폼이 미국 해군과 같은 주요 기관에서 운영 코어로 채택되면서 하이퍼 성장 국면에 있음을 시사합니다.	1.0000	1.3500	80.1900	aebf819715485cb0a0cc009eae509f24a37e7e1664093199420b7ba585a23044	2026-06-12 09:03:36.103113+00	e4620c95967ff82cf3144fcb8544e810b88577a8aee39454aa59a4c116182bea
\.


--
-- Data for Name: portfolio_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.portfolio_items (id, user_id, stock_id, daily_invest_amount, holding_quantity, investment_start_date, memo, is_active, created_at, updated_at) FROM stdin;
3	1	4239	50.00	2.000000	2026-06-11	2	f	2026-06-06 23:31:51.933337+00	2026-06-07 00:41:03.943058+00
5	1	4078	20.00	2.000000	2026-06-01	\N	t	2026-06-07 00:49:00.427339+00	2026-06-07 00:49:00.427339+00
6	1	4076	23.00	2.000000	2026-06-09	\N	t	2026-06-07 11:20:55.962035+00	2026-06-07 15:41:21.311394+00
7	1	4123	12.00	3.000000	2026-06-02	sdafsaf	f	2026-06-07 15:38:12.68655+00	2026-06-07 15:48:02.030523+00
8	1	4096	12.00	2.000000	2026-06-02	fsda	f	2026-06-07 15:42:52.428095+00	2026-06-08 00:09:32.201553+00
9	1	4142	2.00	3.000000	2026-06-02	\N	f	2026-06-09 00:06:35.397922+00	2026-06-10 03:20:06.028411+00
4	1	4077	12.00	2.000000	2026-06-02	\N	f	2026-06-06 23:57:37.533449+00	2026-06-10 03:20:09.367769+00
10	1	4080	10.00	5.000000	2026-06-01	\N	t	2026-06-10 03:21:00.851076+00	2026-06-10 03:21:00.851076+00
11	2	4077	20.00	3.000000	2026-06-02	\N	t	2026-06-10 12:44:28.949852+00	2026-06-10 12:44:28.949852+00
12	2	4078	20.00	18.000000	2026-06-01	\N	t	2026-06-10 12:45:32.17748+00	2026-06-10 12:45:32.17748+00
13	2	4341	20.00	25.000000	2026-06-02	\N	f	2026-06-10 12:48:08.469909+00	2026-06-10 12:48:58.490227+00
15	2	4090	23.00	2.000000	2026-06-01	\N	f	2026-06-10 13:04:44.633541+00	2026-06-10 13:05:06.944752+00
14	2	4113	20.00	2.000000	2026-06-01	\N	t	2026-06-10 12:49:20.662387+00	2026-06-10 13:05:25.964408+00
\.


--
-- Data for Name: recommendation_evidence; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recommendation_evidence (id, recommendation_id, evidence_type, title, body, score_impact, display_order, created_at) FROM stdin;
365	43	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-09 08:22:32.261805+00
366	43	NEWS	관련 뉴스 분석	McDonald's는 직장 내 안전 및 문화와 관련된 부정적인 뉴스가 기업 이미지에 영향을 미칠 수 있으나, 장기 투자 관점에서는 일반적인 투자 원칙과 배당 성장에 대한 긍정적인 내용이 언급되었습니다. 전반적으로 MCD에 대한 직접적이고 구체적인 분석보다는 일반적인 내용이 포함되어 있어 투자 판단에 미치는 영향은 제한적입니다. Gemini 종합 감성 -20점을 정규화해 뉴스 점수 40점으로 계산했습니다.	40	2	2026-06-09 08:22:32.261805+00
367	43	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 40점, 위험 조정 +0점, 최종 40점입니다.	0	3	2026-06-09 08:22:32.261805+00
397	63	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-09 23:33:33.693625+00
273	19	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-07 23:12:11.790095+00
274	19	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-07 23:12:11.790095+00
275	19	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-07 23:12:11.790095+00
276	19	AI_NOTE	최종 해석	Intel Corp은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-07 23:12:11.790095+00
145	3	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-07 11:21:42.451347+00
146	3	NEWS	관련 뉴스 분석	최근 관련 뉴스는 전반적으로 긍정적이며 최신성과 영향도를 반영한 가중 점수도 양호합니다. Gemini 종합 감성 +73점을 정규화해 뉴스 점수 87점으로 계산했습니다.	87	2	2026-06-07 11:21:42.451347+00
147	3	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 87점, 위험 조정 +0점, 최종 87점입니다.	0	3	2026-06-07 11:21:42.451347+00
148	3	AI_NOTE	최종 해석	NVIDIA Corp은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-07 11:21:42.451347+00
149	1	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-07 11:21:42.451347+00
150	1	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-07 11:21:42.451347+00
151	1	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-07 11:21:42.451347+00
152	1	AI_NOTE	최종 해석	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-07 11:21:42.451347+00
153	2	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-07 11:21:42.451347+00
154	2	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-07 11:21:42.451347+00
155	2	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-07 11:21:42.451347+00
156	2	AI_NOTE	최종 해석	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-07 11:21:42.451347+00
277	15	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-07 23:12:11.790095+00
278	15	NEWS	관련 뉴스 분석	엔비디아는 TSMC와의 AI 기반 제조 공정 파트너십을 통해 장기적인 성장 모멘텀을 확보할 것으로 예상되나, 레버리지 ETF의 급락은 단기적인 시장 변동성에 대한 경계를 요구합니다. 또한, CEO의 타사 투자 언급은 직접적인 주가 영향보다는 업계 전반의 성장 가능성을 시사합니다. Gemini 종합 감성 +1점을 정규화해 뉴스 점수 51점으로 계산했습니다.	51	2	2026-06-07 23:12:11.790095+00
279	15	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 51점, 위험 조정 +0점, 최종 51점입니다.	0	3	2026-06-07 23:12:11.790095+00
280	15	AI_NOTE	최종 해석	NVIDIA Corp은 현재 점수 51점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	\N	4	2026-06-07 23:12:11.790095+00
281	7	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-07 23:12:11.790095+00
282	7	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-07 23:12:11.790095+00
283	7	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-07 23:12:11.790095+00
284	7	AI_NOTE	최종 해석	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-07 23:12:11.790095+00
285	8	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-07 23:12:11.790095+00
286	8	NEWS	관련 뉴스 분석	알파벳의 AI 인프라 확장에 대한 버크셔 해서웨이의 대규모 투자는 장기적인 성장 동력 확보 측면에서 긍정적이며, 단기적인 비용 부담에도 불구하고 긍정적인 전망을 유지하게 합니다. 다만, 지정학적 리스크는 시장 전반의 불확실성을 높이는 요인으로 작용할 수 있습니다. Gemini 종합 감성 +41점을 정규화해 뉴스 점수 71점으로 계산했습니다.	71	2	2026-06-07 23:12:11.790095+00
287	8	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 71점, 위험 조정 +0점, 최종 71점입니다.	0	3	2026-06-07 23:12:11.790095+00
288	8	AI_NOTE	최종 해석	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-07 23:12:11.790095+00
368	43	AI_NOTE	최종 해석	McDonald's Corporation은 현재 점수 40점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	\N	4	2026-06-09 08:22:32.261805+00
369	40	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-09 08:22:32.261805+00
370	40	NEWS	관련 뉴스 분석	NVIDIA는 AI 스타트업 인수와 긍정적인 투자 분석 등 일부 호재가 있으나, 구글과의 경쟁 심화 가능성이라는 큰 악재가 존재하여 주가 변동성이 예상됩니다. 장기적으로는 기술 혁신과 시장 지배력 유지 여부가 중요할 것으로 보입니다. Gemini 종합 감성 +6점을 정규화해 뉴스 점수 53점으로 계산했습니다.	53	2	2026-06-09 08:22:32.261805+00
371	40	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 53점, 위험 조정 +0점, 최종 53점입니다.	0	3	2026-06-09 08:22:32.261805+00
372	40	AI_NOTE	최종 해석	NVIDIA Corp은 현재 점수 53점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	\N	4	2026-06-09 08:22:32.261805+00
373	41	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-09 08:22:32.261805+00
374	41	NEWS	관련 뉴스 분석	Apple의 AI 업데이트 발표는 긍정적인 영향을 미쳤으나, 지정학적 불확실성은 단기적으로 부정적인 영향을 줄 수 있습니다. 전반적으로 Apple은 AI 기술 혁신을 통해 장기적인 성장 동력을 확보하고 있습니다. Gemini 종합 감성 +20점을 정규화해 뉴스 점수 60점으로 계산했습니다.	60	2	2026-06-09 08:22:32.261805+00
375	41	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 60점, 위험 조정 +0점, 최종 60점입니다.	0	3	2026-06-09 08:22:32.261805+00
376	41	AI_NOTE	최종 해석	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-09 08:22:32.261805+00
377	42	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-09 08:22:32.261805+00
378	42	NEWS	관련 뉴스 분석	최근 관련 뉴스의 긍정과 부정 신호가 혼재해 뉴스 심리를 중립으로 평가했습니다. Gemini 종합 감성 +10점을 정규화해 뉴스 점수 55점으로 계산했습니다.	55	2	2026-06-09 08:22:32.261805+00
379	42	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 55점, 위험 조정 +0점, 최종 55점입니다.	0	3	2026-06-09 08:22:32.261805+00
380	42	AI_NOTE	최종 해석	Alphabet Inc은 현재 점수 55점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	\N	4	2026-06-09 08:22:32.261805+00
398	63	NEWS	관련 뉴스 분석	최근 관련 뉴스는 전반적으로 긍정적이며 최신성과 영향도를 반영한 가중 점수도 양호합니다. Gemini 종합 감성 +49점을 정규화해 뉴스 점수 75점으로 계산했습니다.	75	2	2026-06-09 23:33:33.693625+00
399	63	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 75점, 위험 조정 +0점, 최종 75점입니다.	0	3	2026-06-09 23:33:33.693625+00
400	63	AI_NOTE	최종 해석	McDonald's Corporation은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-09 23:33:33.693625+00
405	65	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-09 23:33:33.693625+00
406	65	NEWS	관련 뉴스 분석	최근 관련 뉴스의 긍정과 부정 신호가 혼재해 뉴스 심리를 중립으로 평가했습니다. Gemini 종합 감성 +6점을 정규화해 뉴스 점수 53점으로 계산했습니다.	53	2	2026-06-09 23:33:33.693625+00
407	65	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 53점, 위험 조정 +0점, 최종 53점입니다.	0	3	2026-06-09 23:33:33.693625+00
408	65	AI_NOTE	최종 해석	Apple Inc은 현재 점수 53점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	\N	4	2026-06-09 23:33:33.693625+00
609	98	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-11 13:55:13.414503+00
610	98	NEWS	관련 뉴스 분석	최근 관련 뉴스의 긍정과 부정 신호가 혼재해 뉴스 심리를 중립으로 평가했습니다. Gemini 종합 감성 +0점을 정규화해 뉴스 점수 50점으로 계산했습니다.	50	2	2026-06-11 13:55:13.414503+00
611	98	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-11 13:55:13.414503+00
612	98	AI_NOTE	최종 해석	Palantir Technologies Inc은 현재 점수 50점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	\N	4	2026-06-11 13:55:13.414503+00
213	9	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-07 15:42:58.0095+00
214	9	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-07 15:42:58.0095+00
215	9	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-07 15:42:58.0095+00
216	9	AI_NOTE	최종 해석	International Business Machines Corp은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-07 15:42:58.0095+00
413	71	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 03:21:21.341578+00
414	71	NEWS	관련 뉴스 분석	아마존닷컴(AMZN)은 단기적인 주가 하락에도 불구하고 AWS와 핀터레스트 간의 장기 계약 체결, 그리고 새로운 파트너십을 통한 사업 확장 가능성 등 긍정적인 요인들이 부각되며 장기 투자 관점에서 긍정적인 전망을 제시하고 있습니다. Gemini 종합 감성 +34점을 정규화해 뉴스 점수 67점으로 계산했습니다.	67	2	2026-06-10 03:21:21.341578+00
415	71	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 67점, 위험 조정 +0점, 최종 67점입니다.	0	3	2026-06-10 03:21:21.341578+00
416	71	AI_NOTE	최종 해석	Amazon.com Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-10 03:21:21.341578+00
417	64	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 03:21:21.341578+00
418	64	NEWS	관련 뉴스 분석	NVIDIA는 SK 그룹과의 파트너십 확대, 창고 건설 자동화 분야에서의 AI 칩 활용 가능성, 그리고 PC 시장을 겨냥한 AI 기능 내장 칩 출시 등 연이은 긍정적인 뉴스로 인해 장기적인 성장성과 기술 혁신에 대한 기대감을 높이며 주가에 긍정적인 영향을 미칠 것으로 분석됩니다. Gemini 종합 감성 +46점을 정규화해 뉴스 점수 73점으로 계산했습니다.	73	2	2026-06-10 03:21:21.341578+00
419	64	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 73점, 위험 조정 +0점, 최종 73점입니다.	0	3	2026-06-10 03:21:21.341578+00
420	64	AI_NOTE	최종 해석	NVIDIA Corp은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-10 03:21:21.341578+00
421	66	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 03:21:21.341578+00
422	66	NEWS	관련 뉴스 분석	Alphabet은 AI 투자 및 Waymo 확장으로 인한 지출 증가로 가치 평가에 대한 우려가 있지만, SpaceX와의 대규모 AI 클라우드 계약과 높은 수익률의 전환 우선주 발행은 긍정적인 측면으로 작용할 수 있습니다. Gemini 종합 감성 +20점을 정규화해 뉴스 점수 60점으로 계산했습니다.	60	2	2026-06-10 03:21:21.341578+00
423	66	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 60점, 위험 조정 +0점, 최종 60점입니다.	0	3	2026-06-10 03:21:21.341578+00
424	66	AI_NOTE	최종 해석	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-10 03:21:21.341578+00
437	77	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 12:48:12.022161+00
438	77	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-10 12:48:12.022161+00
439	77	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-10 12:48:12.022161+00
440	77	AI_NOTE	최종 해석	Nike Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-10 12:48:12.022161+00
461	83	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 13:04:48.81723+00
462	83	NEWS	관련 뉴스 분석	The provided news articles offer mixed insights into Advanced Micro Devices Inc. (AMD). While one article highlights AMD's AI-driven growth and funded outlook, suggesting positive momentum, another focuses on Cathie Wood's decision to sell AMD shares and buy Nvidia, which could be interpreted as a neutral to slightly negative signal depending on the investor's perspective. A third article links AMD's stock decline to broader market instability rather than company-specific issues, indicating a low direct impact from that particular news. Gemini 종합 감성 +22점을 정규화해 뉴스 점수 61점으로 계산했습니다.	61	2	2026-06-10 13:04:48.81723+00
463	83	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 61점, 위험 조정 +0점, 최종 61점입니다.	0	3	2026-06-10 13:04:48.81723+00
464	83	AI_NOTE	최종 해석	Advanced Micro Devices Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-10 13:04:48.81723+00
573	111	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 23:43:20.787549+00
574	111	NEWS	관련 뉴스 분석	Amazon의 운송 물류 시장 진출로 인해 운송 관련주들이 하락세를 보였으나, 단기적 위협은 크지 않을 것으로 분석되었습니다. 해당 뉴스는 Amazon 주가에 미미한 영향을 줄 것으로 예상됩니다. Gemini 종합 감성 -10점을 정규화해 뉴스 점수 45점으로 계산했습니다.	45	2	2026-06-10 23:43:20.787549+00
575	111	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 45점, 위험 조정 +0점, 최종 45점입니다.	0	3	2026-06-10 23:43:20.787549+00
576	111	AI_NOTE	최종 해석	Amazon.com Inc은 현재 점수 45점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	\N	4	2026-06-10 23:43:20.787549+00
577	112	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 23:43:20.787549+00
578	112	NEWS	관련 뉴스 분석	NVIDIA와 SK 그룹의 협력 발표 소식은 긍정적이나, 전반적인 기술주 하락세와 인플레이션 우려가 투자 심리에 영향을 미칠 수 있습니다. SpaceX의 GPU 용량 확보 소식은 NVIDIA에게 긍정적인 요인이지만, 단기적인 시장 상황을 지켜볼 필요가 있습니다. Gemini 종합 감성 -6점을 정규화해 뉴스 점수 47점으로 계산했습니다.	47	2	2026-06-10 23:43:20.787549+00
579	112	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 47점, 위험 조정 +0점, 최종 47점입니다.	0	3	2026-06-10 23:43:20.787549+00
580	112	AI_NOTE	최종 해석	NVIDIA Corp은 현재 점수 47점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	\N	4	2026-06-10 23:43:20.787549+00
581	113	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 23:43:20.787549+00
582	113	NEWS	관련 뉴스 분석	최근 관련 뉴스는 전반적으로 긍정적이며 최신성과 영향도를 반영한 가중 점수도 양호합니다. Gemini 종합 감성 +49점을 정규화해 뉴스 점수 75점으로 계산했습니다.	75	2	2026-06-10 23:43:20.787549+00
583	113	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 75점, 위험 조정 +0점, 최종 75점입니다.	0	3	2026-06-10 23:43:20.787549+00
584	113	AI_NOTE	최종 해석	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-10 23:43:20.787549+00
517	75	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 14:55:36.230078+00
518	75	NEWS	관련 뉴스 분석	최근 관련 뉴스는 전반적으로 긍정적이며 최신성과 영향도를 반영한 가중 점수도 양호합니다. Gemini 종합 감성 +30점을 정규화해 뉴스 점수 65점으로 계산했습니다.	65	2	2026-06-10 14:55:36.230078+00
519	75	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 65점, 위험 조정 +0점, 최종 65점입니다.	0	3	2026-06-10 14:55:36.230078+00
520	75	AI_NOTE	최종 해석	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-10 14:55:36.230078+00
509	80	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 14:45:29.730436+00
510	80	NEWS	관련 뉴스 분석	최근 관련 뉴스의 긍정과 부정 신호가 혼재해 뉴스 심리를 중립으로 평가했습니다. Gemini 종합 감성 +10점을 정규화해 뉴스 점수 55점으로 계산했습니다.	55	2	2026-06-10 14:45:29.730436+00
511	80	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 55점, 위험 조정 +0점, 최종 55점입니다.	0	3	2026-06-10 14:45:29.730436+00
512	80	AI_NOTE	최종 해석	Palantir Technologies Inc은 현재 점수 55점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	\N	4	2026-06-10 14:45:29.730436+00
513	74	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 14:45:38.192978+00
514	74	NEWS	관련 뉴스 분석	최근 관련 뉴스의 긍정과 부정 신호가 혼재해 뉴스 심리를 중립으로 평가했습니다. Gemini 종합 감성 -8점을 정규화해 뉴스 점수 46점으로 계산했습니다.	46	2	2026-06-10 14:45:38.192978+00
515	74	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 46점, 위험 조정 +0점, 최종 46점입니다.	0	3	2026-06-10 14:45:38.192978+00
516	74	AI_NOTE	최종 해석	Apple Inc은 현재 점수 46점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	\N	4	2026-06-10 14:45:38.192978+00
761	128	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-12 08:55:38.783614+00
601	100	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-11 07:37:19.390346+00
602	100	NEWS	관련 뉴스 분석	The analysis of Alphabet Inc. (GOOGL) news indicates a generally neutral to slightly positive outlook, with mixed signals regarding its stock performance and long-term investment potential. While some articles highlight Alphabet's ongoing valuation and potential momentum cooling after a strong year, others point to its inclusion in the influential 'MANGOS' group and a bullish 2027 outlook driven by AI cloud growth. The market seems to be digesting these varied factors, leading to a balanced sentiment. Gemini 종합 감성 +53점을 정규화해 뉴스 점수 77점으로 계산했습니다.	77	2	2026-06-11 07:37:19.390346+00
603	100	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 77점, 위험 조정 +0점, 최종 77점입니다.	0	3	2026-06-11 07:37:19.390346+00
604	100	AI_NOTE	최종 해석	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-11 07:37:19.390346+00
605	101	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-11 07:37:30.083616+00
606	101	NEWS	관련 뉴스 분석	Apple Inc. (AAPL) news analysis shows a mixed outlook. While the company introduced next-generation Siri AI, its immediate impact on stock price is uncertain, with analysts citing potential delays in AI-driven revenue and strong existing demand drivers like iPhone and Services. A separate report mentions Apple and Nvidia as 'good money' amidst market shifts, implying resilience. Morgan Stanley has revamped its price target for Apple stock following a key event (WWDC 2026), suggesting a positive or neutral adjustment based on the company's AI advancements. Gemini 종합 감성 +19점을 정규화해 뉴스 점수 60점으로 계산했습니다.	60	2	2026-06-11 07:37:30.083616+00
607	101	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 60점, 위험 조정 +0점, 최종 60점입니다.	0	3	2026-06-11 07:37:30.083616+00
608	101	AI_NOTE	최종 해석	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-11 07:37:30.083616+00
762	128	NEWS	관련 뉴스 분석	Alphabet Inc. (GOOGL) receives positive attention from analysts regarding its capital raise and its position as a top AI stock, indicating strong long-term investment potential. However, a separate news item suggests a broader market influence without direct company-specific impact. Gemini 종합 감성 +35점을 정규화해 뉴스 점수 68점으로 계산했습니다.	68	2	2026-06-12 08:55:38.783614+00
763	128	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 68점, 위험 조정 +0점, 최종 68점입니다.	0	3	2026-06-12 08:55:38.783614+00
764	128	AI_NOTE	최종 해석	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-12 08:55:38.783614+00
765	129	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-12 08:59:43.367142+00
766	129	NEWS	관련 뉴스 분석	Apple's stock shows mixed signals. While AI integration and new product launches like Siri AI are positive developments, their impact on current stock price and long-term investment potential is debated, with some analysts seeing strong upside and others noting that positive news may already be priced in. Despite overall positive sentiment, individual article relevance and impact vary. Gemini 종합 감성 +47점을 정규화해 뉴스 점수 74점으로 계산했습니다.	74	2	2026-06-12 08:59:43.367142+00
767	129	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 74점, 위험 조정 +0점, 최종 74점입니다.	0	3	2026-06-12 08:59:43.367142+00
768	129	AI_NOTE	최종 해석	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-12 08:59:43.367142+00
769	121	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-12 09:03:31.20836+00
770	121	NEWS	관련 뉴스 분석	Palantir Technologies (PLTR) is experiencing a hyper-growth phase, with its AIP platform being adopted by key institutions like the Department of the Navy. Recent multiyear enterprise deals with McCarthy Building Companies, GNP Seguros, and Kirkland & Ellis further highlight growing demand for its AI solutions. While discussions around SpaceX's valuation, involving a Palantir co-founder, are noted, they have a lower direct relevance to PLTR's immediate stock performance. Gemini 종합 감성 +49점을 정규화해 뉴스 점수 75점으로 계산했습니다.	75	2	2026-06-12 09:03:31.20836+00
771	121	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 75점, 위험 조정 +0점, 최종 75점입니다.	0	3	2026-06-12 09:03:31.20836+00
772	121	AI_NOTE	최종 해석	Palantir Technologies Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-12 09:03:31.20836+00
725	149	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-11 23:39:09.957901+00
726	149	NEWS	관련 뉴스 분석	아마존은 긍정적인 투자 의견과 함께 물류 사업 확장을 통해 장기적인 성장세를 이어갈 것으로 보입니다. 창업자의 AI 스타트업 성공은 긍정적인 뉴스지만, 아마존 자체의 직접적인 영향은 제한적입니다. Gemini 종합 감성 +37점을 정규화해 뉴스 점수 69점으로 계산했습니다.	69	2	2026-06-11 23:39:09.957901+00
727	149	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 69점, 위험 조정 +0점, 최종 69점입니다.	0	3	2026-06-11 23:39:09.957901+00
728	149	AI_NOTE	최종 해석	Amazon.com Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-11 23:39:09.957901+00
729	150	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-11 23:39:09.957901+00
730	150	NEWS	관련 뉴스 분석	NVIDIA는 유명 투자자의 포트폴리오에 포함되고 'Agentic AI' 트렌드로 인해 긍정적인 전망을 받고 있지만, AI 칩 시장 전반의 투자 심리 위축 가능성도 존재합니다. 단기적으로는 시장 전반의 분위기에 영향을 받을 수 있으나, 장기적으로는 기술 혁신과 주요 투자자들의 관심을 바탕으로 긍정적인 흐름을 이어갈 것으로 예상됩니다. Gemini 종합 감성 +16점을 정규화해 뉴스 점수 58점으로 계산했습니다.	58	2	2026-06-11 23:39:09.957901+00
731	150	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 58점, 위험 조정 +0점, 최종 58점입니다.	0	3	2026-06-11 23:39:09.957901+00
732	150	AI_NOTE	최종 해석	NVIDIA Corp은 현재 점수 58점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	\N	4	2026-06-11 23:39:09.957901+00
733	151	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-11 23:39:09.957901+00
734	151	NEWS	관련 뉴스 분석	Alphabet Inc.(GOOGL)는 억만장자 투자자의 포트폴리오에 포함된 AI 유망주로 선정되었으며, 주가는 긍정적인 흐름을 보이고 있습니다. 또한, 차세대 AI 칩 생산 능력 강화를 위해 삼성과의 파트너십을 모색하고 있으며, 이는 기술 경쟁력 강화 및 시장 점유율 확대에 기여할 것으로 예상됩니다. SpaceX와 Anthropic에 대한 전략적 투자는 미래 성장 잠재력에 대한 긍정적인 신호로 해석될 수 있습니다. Gemini 종합 감성 +63점을 정규화해 뉴스 점수 82점으로 계산했습니다.	82	2	2026-06-11 23:39:09.957901+00
735	151	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 82점, 위험 조정 +0점, 최종 82점입니다.	0	3	2026-06-11 23:39:09.957901+00
736	151	AI_NOTE	최종 해석	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-11 23:39:09.957901+00
809	163	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-13 08:57:01.19949+00
810	163	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-13 08:57:01.19949+00
811	163	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-13 08:57:01.19949+00
812	163	AI_NOTE	최종 해석	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-13 08:57:01.19949+00
837	161	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-13 10:08:31.80401+00
838	161	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-13 10:08:31.80401+00
839	161	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-13 10:08:31.80401+00
840	161	AI_NOTE	최종 해석	Palantir Technologies Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-13 10:08:31.80401+00
841	162	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-13 10:10:11.708099+00
842	162	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-13 10:10:11.708099+00
843	162	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-13 10:10:11.708099+00
844	162	AI_NOTE	최종 해석	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-13 10:10:11.708099+00
853	181	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-14 01:01:51.494704+00
854	181	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-14 01:01:51.494704+00
855	181	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-14 01:01:51.494704+00
856	181	AI_NOTE	최종 해석	Amazon.com Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-14 01:01:51.494704+00
857	182	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-14 01:01:51.494704+00
858	182	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-14 01:01:51.494704+00
859	182	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-14 01:01:51.494704+00
860	182	AI_NOTE	최종 해석	NVIDIA Corp은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-14 01:01:51.494704+00
861	183	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-14 01:01:51.494704+00
862	183	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-14 01:01:51.494704+00
863	183	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-14 01:01:51.494704+00
864	183	AI_NOTE	최종 해석	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-14 01:01:51.494704+00
865	179	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-14 01:01:52.10624+00
866	179	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-14 01:01:52.10624+00
867	179	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-14 01:01:52.10624+00
868	179	AI_NOTE	최종 해석	Palantir Technologies Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-14 01:01:52.10624+00
869	180	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-14 01:01:52.10624+00
870	180	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-14 01:01:52.10624+00
871	180	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-14 01:01:52.10624+00
872	180	AI_NOTE	최종 해석	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-14 01:01:52.10624+00
873	186	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-14 01:01:52.10624+00
874	186	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-14 01:01:52.10624+00
875	186	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-14 01:01:52.10624+00
876	186	AI_NOTE	최종 해석	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-14 01:01:52.10624+00
\.


--
-- Data for Name: recommendation_factor_details; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recommendation_factor_details (id, recommendation_id, factor_code, factor_score, factor_weight, factor_summary, factor_raw_json, created_at) FROM stdin;
\.


--
-- Data for Name: recommendations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recommendations (id, user_id, portfolio_item_id, recommendation_date, recommendation_status, engine_score, confidence_score, current_amount, recommended_amount, final_note, engine_version, created_at, formula_version, raw_score, risk_adjustment, price_score, news_score, price_weight, news_weight, price_return_30d, news_sentiment_score, increase_eligible, price_momentum_score, price_stability_score, fundamental_quality_score, user_fit_score, cross_factor_adjustment, user_adjustment, risk_profile_applied, confidence_breakdown_json) FROM stdin;
181	1	10	2026-06-14	MAINTAIN	50	65	10.00	10.00	Amazon.com Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-14 01:01:51.494704+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
182	1	6	2026-06-14	MAINTAIN	50	65	23.00	23.00	NVIDIA Corp은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-14 01:01:51.494704+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
183	1	5	2026-06-14	MAINTAIN	50	65	20.00	20.00	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-14 01:01:51.494704+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
186	2	11	2026-06-14	MAINTAIN	50	65	20.00	20.00	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-14 01:01:52.10624+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
121	2	14	2026-06-12	MAINTAIN	75	75	20.00	20.00	Palantir Technologies Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-11 15:00:51.690043+00	SCORE_V3_PRICE_NEWS	75	0	\N	75	0	45	\N	49	f	\N	\N	\N	\N	\N	\N	\N	\N
161	2	14	2026-06-13	MAINTAIN	50	65	20.00	20.00	Palantir Technologies Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-13 07:57:58.960853+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
162	2	12	2026-06-13	MAINTAIN	50	65	20.00	20.00	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-13 07:57:58.960853+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
74	2	11	2026-06-10	REDUCE	46	75	20.00	14.00	Apple Inc은 현재 점수 46점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-10 12:44:35.335864+00	SCORE_V3_PRICE_NEWS	46	0	\N	46	0	45	\N	-8	f	\N	\N	\N	\N	\N	\N	\N	\N
8	1	5	2026-06-08	MAINTAIN	71	74	20.00	20.00	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-07 15:26:01.636756+00	SCORE_V3_PRICE_NEWS	71	0	\N	71	0	45	\N	41	f	\N	\N	\N	\N	\N	\N	\N	\N
113	1	5	2026-06-11	MAINTAIN	75	75	20.00	20.00	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-10 23:43:20.787549+00	SCORE_V3_PRICE_NEWS	75	0	\N	75	0	45	\N	49	f	\N	\N	\N	\N	\N	\N	\N	\N
42	1	5	2026-06-09	REDUCE	55	75	20.00	14.00	Alphabet Inc은 현재 점수 55점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-08 23:32:03.415996+00	SCORE_V3_PRICE_NEWS	55	0	\N	55	0	45	\N	10	f	\N	\N	\N	\N	\N	\N	\N	\N
63	1	9	2026-06-10	MAINTAIN	75	73	2.00	2.00	McDonald's Corporation은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-09 22:51:10.290768+00	SCORE_V3_PRICE_NEWS	75	0	\N	75	0	45	\N	49	f	\N	\N	\N	\N	\N	\N	\N	\N
65	1	4	2026-06-10	REDUCE	53	75	12.00	8.40	Apple Inc은 현재 점수 53점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-09 22:51:10.290768+00	SCORE_V3_PRICE_NEWS	53	0	\N	53	0	45	\N	6	f	\N	\N	\N	\N	\N	\N	\N	\N
180	2	12	2026-06-14	MAINTAIN	50	65	20.00	20.00	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-13 23:51:50.818037+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
66	1	5	2026-06-10	MAINTAIN	60	75	20.00	20.00	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-09 22:51:10.290768+00	SCORE_V3_PRICE_NEWS	60	0	\N	60	0	45	\N	20	f	\N	\N	\N	\N	\N	\N	\N	\N
2	1	5	2026-06-07	MAINTAIN	50	65	20.00	20.00	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE	2026-06-07 01:03:29.435271+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
112	1	6	2026-06-11	REDUCE	47	74	23.00	16.10	NVIDIA Corp은 현재 점수 47점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-10 23:43:20.787549+00	SCORE_V3_PRICE_NEWS	47	0	\N	47	0	45	\N	-6	f	\N	\N	\N	\N	\N	\N	\N	\N
3	1	6	2026-06-07	MAINTAIN	87	75	2.00	2.00	NVIDIA Corp은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE	2026-06-07 11:20:57.867692+00	SCORE_V3_PRICE_NEWS	87	0	\N	87	0	45	\N	73	f	\N	\N	\N	\N	\N	\N	\N	\N
77	2	13	2026-06-10	MAINTAIN	50	65	20.00	20.00	Nike Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-10 12:48:12.022161+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
163	2	11	2026-06-13	MAINTAIN	50	65	20.00	20.00	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-13 07:57:58.960853+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
80	2	14	2026-06-10	REDUCE	55	75	20.00	14.00	Palantir Technologies Inc은 현재 점수 55점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-10 12:49:23.247864+00	SCORE_V3_PRICE_NEWS	55	0	\N	55	0	45	\N	10	f	\N	\N	\N	\N	\N	\N	\N	\N
71	1	10	2026-06-10	MAINTAIN	67	75	10.00	10.00	Amazon.com Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-10 03:21:21.341578+00	SCORE_V3_PRICE_NEWS	67	0	\N	67	0	45	\N	34	f	\N	\N	\N	\N	\N	\N	\N	\N
129	2	11	2026-06-12	MAINTAIN	74	75	20.00	20.00	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-11 15:00:51.690043+00	SCORE_V3_PRICE_NEWS	74	0	\N	74	0	45	\N	47	f	\N	\N	\N	\N	\N	\N	\N	\N
9	1	7	2026-06-08	MAINTAIN	50	70	12.00	12.00	International Business Machines Corp은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-07 15:38:22.426905+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
1	1	4	2026-06-07	MAINTAIN	50	65	12.00	12.00	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE	2026-06-07 01:03:29.435271+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
40	1	6	2026-06-09	REDUCE	53	75	23.00	16.10	NVIDIA Corp은 현재 점수 53점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-08 23:32:03.415996+00	SCORE_V3_PRICE_NEWS	53	0	\N	53	0	45	\N	6	f	\N	\N	\N	\N	\N	\N	\N	\N
75	2	12	2026-06-10	MAINTAIN	65	75	20.00	20.00	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-10 12:45:40.376084+00	SCORE_V3_PRICE_NEWS	65	0	\N	65	0	45	\N	30	f	\N	\N	\N	\N	\N	\N	\N	\N
64	1	6	2026-06-10	MAINTAIN	73	75	23.00	23.00	NVIDIA Corp은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-09 22:51:10.290768+00	SCORE_V3_PRICE_NEWS	73	0	\N	73	0	45	\N	46	f	\N	\N	\N	\N	\N	\N	\N	\N
128	2	12	2026-06-12	MAINTAIN	68	74	20.00	20.00	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-11 15:00:51.690043+00	SCORE_V3_PRICE_NEWS	68	0	\N	68	0	45	\N	35	f	\N	\N	\N	\N	\N	\N	\N	\N
100	2	12	2026-06-11	MAINTAIN	77	74	20.00	20.00	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-10 15:19:31.798541+00	SCORE_V3_PRICE_NEWS	77	0	\N	77	0	45	\N	53	f	\N	\N	\N	\N	\N	\N	\N	\N
101	2	11	2026-06-11	MAINTAIN	60	75	20.00	20.00	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-10 15:19:31.798541+00	SCORE_V3_PRICE_NEWS	60	0	\N	60	0	45	\N	19	f	\N	\N	\N	\N	\N	\N	\N	\N
149	1	10	2026-06-12	MAINTAIN	69	74	10.00	10.00	Amazon.com Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-11 23:39:09.957901+00	SCORE_V3_PRICE_NEWS	69	0	\N	69	0	45	\N	37	f	\N	\N	\N	\N	\N	\N	\N	\N
150	1	6	2026-06-12	REDUCE	58	74	23.00	16.10	NVIDIA Corp은 현재 점수 58점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-11 23:39:09.957901+00	SCORE_V3_PRICE_NEWS	58	0	\N	58	0	45	\N	16	f	\N	\N	\N	\N	\N	\N	\N	\N
151	1	5	2026-06-12	MAINTAIN	82	75	20.00	20.00	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-11 23:39:09.957901+00	SCORE_V3_PRICE_NEWS	82	0	\N	82	0	45	\N	63	f	\N	\N	\N	\N	\N	\N	\N	\N
98	2	14	2026-06-11	REDUCE	50	74	20.00	14.00	Palantir Technologies Inc은 현재 점수 50점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-10 15:19:31.798541+00	SCORE_V3_PRICE_NEWS	50	0	\N	50	0	45	\N	0	f	\N	\N	\N	\N	\N	\N	\N	\N
83	2	15	2026-06-10	MAINTAIN	61	75	23.00	23.00	Advanced Micro Devices Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-10 13:04:48.81723+00	SCORE_V3_PRICE_NEWS	61	0	\N	61	0	45	\N	22	f	\N	\N	\N	\N	\N	\N	\N	\N
19	1	8	2026-06-08	MAINTAIN	50	70	12.00	12.00	Intel Corp은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-07 15:42:58.0095+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
15	1	6	2026-06-08	REDUCE	51	75	23.00	16.10	NVIDIA Corp은 현재 점수 51점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-07 15:41:25.52539+00	SCORE_V3_PRICE_NEWS	51	0	\N	51	0	45	\N	1	f	\N	\N	\N	\N	\N	\N	\N	\N
179	2	14	2026-06-14	MAINTAIN	50	65	20.00	20.00	Palantir Technologies Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-13 15:14:26.138038+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
7	1	4	2026-06-08	MAINTAIN	50	65	12.00	12.00	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-07 15:26:01.636756+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
111	1	10	2026-06-11	REDUCE	45	74	10.00	7.00	Amazon.com Inc은 현재 점수 45점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-10 23:43:20.787549+00	SCORE_V3_PRICE_NEWS	45	0	\N	45	0	45	\N	-10	f	\N	\N	\N	\N	\N	\N	\N	\N
43	1	9	2026-06-09	REDUCE	40	73	2.00	1.40	McDonald's Corporation은 현재 점수 40점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-09 00:06:39.489732+00	SCORE_V3_PRICE_NEWS	40	0	\N	40	0	45	\N	-20	f	\N	\N	\N	\N	\N	\N	\N	\N
41	1	4	2026-06-09	MAINTAIN	60	75	12.00	12.00	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-08 23:32:03.415996+00	SCORE_V3_PRICE_NEWS	60	0	\N	60	0	45	\N	20	f	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: stock_price_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock_price_snapshots (id, stock_id, snapshot_date, current_price, change_rate_1d, change_rate_30d, market_cap, per_value, source, created_at, change_rate_7d) FROM stdin;
1	4076	2026-06-07	205.1000	-6.2014	\N	4963420.00	31.0966	FINNHUB	2026-06-07 06:46:38.373156+00	\N
2	4077	2026-06-07	307.3400	-1.2499	\N	4514012.50	36.8265	FINNHUB	2026-06-07 06:46:39.388905+00	\N
3	4078	2026-06-07	368.5300	-0.9834	\N	4465109.50	27.8707	FINNHUB	2026-06-07 06:46:40.397118+00	\N
4	4079	2026-06-07	416.6700	-2.6586	\N	3095205.80	24.7189	FINNHUB	2026-06-07 06:46:41.486449+00	\N
5	4080	2026-06-07	246.0300	-3.0576	\N	2646571.50	29.1479	FINNHUB	2026-06-07 06:46:42.528661+00	\N
6	4081	2026-06-07	415.1700	-6.6866	\N	61848700.00	32.0659	FINNHUB	2026-06-07 06:46:43.551356+00	\N
7	4082	2026-06-07	385.7300	-7.9206	\N	1826303.50	62.2950	FINNHUB	2026-06-07 06:46:44.589992+00	\N
8	4083	2026-06-07	593.0000	-5.5085	\N	1505284.90	21.3252	FINNHUB	2026-06-07 06:46:45.485525+00	\N
9	4084	2026-06-07	391.0000	-6.5599	\N	1468488.00	380.2403	FINNHUB	2026-06-07 06:46:46.541803+00	\N
10	4085	2026-06-07	488.1300	1.9848	\N	1054321.50	14.5482	FINNHUB	2026-06-07 06:46:47.618841+00	\N
11	4086	2026-06-07	1131.4200	0.5465	\N	1065505.10	42.1536	FINNHUB	2026-06-07 06:46:48.583581+00	\N
12	4087	2026-06-07	864.0100	-13.2520	\N	974373.44	40.4120	FINNHUB	2026-06-07 06:46:49.577954+00	\N
13	4088	2026-06-07	118.8800	0.9682	\N	930219.94	40.9140	FINNHUB	2026-06-07 06:46:50.65794+00	\N
14	4089	2026-06-07	312.3700	0.4761	\N	836999.06	14.2108	FINNHUB	2026-06-07 06:46:51.599359+00	\N
15	4090	2026-06-07	466.3800	-10.8601	\N	760479.50	151.8226	FINNHUB	2026-06-07 06:46:53.164789+00	\N
74	4128	2026-06-08	81.9400	\N	\N	250751.92	11.5570	FINNHUB	2026-06-07 22:47:10.06584+00	\N
75	4129	2026-06-08	180.9900	\N	\N	243736.22	33.5910	FINNHUB	2026-06-07 22:47:13.433857+00	\N
76	4130	2026-06-08	85.4000	\N	\N	179551.80	12.7756	FINNHUB	2026-06-07 22:47:16.766641+00	\N
16	4076	2026-06-08	205.1000	0.0000	\N	4963420.00	31.0966	FINNHUB	2026-06-07 15:51:22.458737+00	\N
17	4077	2026-06-08	307.3400	0.0000	\N	4514012.50	36.8265	FINNHUB	2026-06-07 15:51:25.453924+00	\N
18	4078	2026-06-08	368.5300	0.0000	\N	4465109.50	27.8707	FINNHUB	2026-06-07 15:51:28.418585+00	\N
25	4079	2026-06-08	416.6700	0.0000	\N	3095205.80	24.7189	FINNHUB	2026-06-07 22:44:25.720633+00	\N
26	4080	2026-06-08	246.0300	0.0000	\N	2646571.50	29.1479	FINNHUB	2026-06-07 22:44:29.059382+00	\N
27	4081	2026-06-08	415.1700	0.0000	\N	61848700.00	32.0659	FINNHUB	2026-06-07 22:44:32.42671+00	\N
28	4082	2026-06-08	385.7300	0.0000	\N	1826303.50	62.2950	FINNHUB	2026-06-07 22:44:35.753776+00	\N
29	4083	2026-06-08	593.0000	0.0000	\N	1505284.90	21.3252	FINNHUB	2026-06-07 22:44:39.187048+00	\N
30	4084	2026-06-08	391.0000	0.0000	\N	1468488.00	380.2403	FINNHUB	2026-06-07 22:44:42.511224+00	\N
31	4085	2026-06-08	488.1300	0.0000	\N	1054321.50	14.5482	FINNHUB	2026-06-07 22:44:45.879869+00	\N
32	4086	2026-06-08	1131.4200	0.0000	\N	1065505.10	42.1536	FINNHUB	2026-06-07 22:44:49.232235+00	\N
33	4087	2026-06-08	864.0100	0.0000	\N	974373.44	40.4120	FINNHUB	2026-06-07 22:44:52.579564+00	\N
34	4088	2026-06-08	118.8800	0.0000	\N	946056.50	41.6105	FINNHUB	2026-06-07 22:44:55.917247+00	\N
35	4089	2026-06-08	312.3700	0.0000	\N	836999.06	14.2108	FINNHUB	2026-06-07 22:44:59.241918+00	\N
36	4090	2026-06-08	466.3800	0.0000	\N	760479.50	151.8226	FINNHUB	2026-06-07 22:45:02.593872+00	\N
37	4091	2026-06-08	1641.7400	\N	\N	572213.25	56.0279	FINNHUB	2026-06-07 22:45:05.946252+00	\N
38	4092	2026-06-08	149.9200	\N	\N	621410.50	24.5481	FINNHUB	2026-06-07 22:45:09.300558+00	\N
39	4093	2026-06-08	213.6800	\N	\N	614553.50	37.9120	FINNHUB	2026-06-07 22:45:12.650598+00	\N
40	4094	2026-06-08	323.5700	\N	\N	609646.25	27.4171	FINNHUB	2026-06-07 22:45:15.993285+00	\N
41	4095	2026-06-08	232.7700	\N	\N	560327.90	26.6316	FINNHUB	2026-06-07 22:45:19.337565+00	\N
42	4096	2026-06-08	99.1700	\N	\N	498428.40	\N	FINNHUB	2026-06-07 22:45:22.677836+00	\N
43	4097	2026-06-08	121.6400	\N	\N	479436.12	40.0933	FINNHUB	2026-06-07 22:45:26.075227+00	\N
44	4098	2026-06-08	491.0800	\N	\N	433910.38	27.8684	FINNHUB	2026-06-07 22:45:29.407652+00	\N
45	4099	2026-06-08	971.8700	\N	\N	431003.75	48.7671	FINNHUB	2026-06-07 22:45:32.792917+00	\N
46	4100	2026-06-08	904.2800	\N	\N	416544.84	44.1723	FINNHUB	2026-06-07 22:45:36.150305+00	\N
47	4101	2026-06-08	227.2300	\N	\N	401468.34	110.4452	FINNHUB	2026-06-07 22:45:39.495376+00	\N
48	4102	2026-06-08	53.8300	\N	\N	382009.44	12.0519	FINNHUB	2026-06-07 22:45:42.815405+00	\N
49	4103	2026-06-08	303.2800	\N	\N	379273.20	56.5387	FINNHUB	2026-06-07 22:45:46.192662+00	\N
50	4104	2026-06-08	187.3100	\N	\N	373046.20	33.8856	FINNHUB	2026-06-07 22:45:49.566137+00	\N
51	4105	2026-06-08	342.9300	\N	\N	418620.16	463.0754	FINNHUB	2026-06-07 22:45:52.877066+00	\N
52	4106	2026-06-08	399.4700	\N	\N	360052.00	29.8947	FINNHUB	2026-06-07 22:45:56.225958+00	\N
53	4107	2026-06-08	453.0100	\N	\N	359671.56	42.2745	FINNHUB	2026-06-07 22:45:59.561275+00	\N
54	4108	2026-06-08	82.1800	\N	\N	346043.40	25.8750	FINNHUB	2026-06-07 22:46:02.950066+00	\N
55	4109	2026-06-08	328.0000	\N	\N	342214.62	39.6541	FINNHUB	2026-06-07 22:46:06.301454+00	\N
56	4110	2026-06-08	79.4800	\N	\N	341961.30	24.9589	FINNHUB	2026-06-07 22:46:09.64625+00	\N
57	4111	2026-06-08	146.5400	\N	\N	341232.90	20.5364	FINNHUB	2026-06-07 22:46:12.983989+00	\N
58	4112	2026-06-08	211.9300	\N	\N	334274.00	18.4549	FINNHUB	2026-06-07 22:46:16.318351+00	\N
59	4113	2026-06-08	135.5300	\N	\N	324907.72	142.4079	FINNHUB	2026-06-07 22:46:19.802027+00	\N
60	4114	2026-06-08	1038.6800	\N	\N	306418.30	16.9592	FINNHUB	2026-06-07 22:46:23.161265+00	\N
61	4115	2026-06-08	90.8000	\N	\N	234899.33	14.0485	FINNHUB	2026-06-07 22:46:26.492531+00	\N
62	4116	2026-06-08	310.7800	\N	\N	309883.94	22.1156	FINNHUB	2026-06-07 22:46:29.82859+00	\N
63	4117	2026-06-08	120.7900	\N	\N	298330.10	33.3889	FINNHUB	2026-06-07 22:46:33.254743+00	\N
64	4118	2026-06-08	185.9500	\N	\N	210203.86	26.9921	FINNHUB	2026-06-07 22:46:36.690393+00	\N
65	4119	2026-06-08	178.2900	\N	\N	277875.47	25.0429	FINNHUB	2026-06-07 22:46:40.025972+00	\N
66	4120	2026-06-08	121.0600	\N	\N	302455.94	19.3870	FINNHUB	2026-06-07 22:46:43.356404+00	\N
67	4121	2026-06-08	149.1600	\N	\N	211478.11	19.6229	FINNHUB	2026-06-07 22:46:46.696894+00	\N
68	4122	2026-06-08	194.0400	\N	\N	378397.47	17.0927	FINNHUB	2026-06-07 22:46:50.041446+00	\N
69	4123	2026-06-08	284.8400	\N	\N	267716.90	24.8993	FINNHUB	2026-06-07 22:46:53.370863+00	\N
70	4124	2026-06-08	285.0600	\N	\N	259431.06	48.3382	FINNHUB	2026-06-07 22:46:56.728996+00	\N
71	4125	2026-06-08	394.3900	\N	\N	257309.69	30.5993	FINNHUB	2026-06-07 22:47:00.03931+00	\N
72	4126	2026-06-08	1929.2000	\N	\N	252006.62	53.9564	FINNHUB	2026-06-07 22:47:03.417719+00	\N
73	4127	2026-06-08	933.6100	\N	\N	250879.69	26.7634	FINNHUB	2026-06-07 22:47:06.739602+00	\N
77	4131	2026-06-08	507.9000	\N	\N	234954.30	33.1763	FINNHUB	2026-06-07 22:47:20.113176+00	\N
78	4132	2026-06-08	177.1600	\N	\N	33610830.00	8.7344	FINNHUB	2026-06-07 22:47:23.493566+00	\N
79	4133	2026-06-08	1559.3200	\N	\N	230919.34	51.2357	FINNHUB	2026-06-07 22:47:26.807944+00	\N
80	4134	2026-06-08	263.4700	\N	\N	230483.55	91.2192	FINNHUB	2026-06-07 22:47:30.146327+00	\N
81	4135	2026-06-08	215.9400	\N	\N	227600.77	22.9367	FINNHUB	2026-06-07 22:47:33.583325+00	\N
82	4136	2026-06-08	19.9100	\N	\N	35435760.00	14.5993	FINNHUB	2026-06-07 22:47:36.990396+00	\N
83	4137	2026-06-08	132.4700	\N	\N	227173.78	14.1753	FINNHUB	2026-06-07 22:47:40.311951+00	\N
84	4138	2026-06-08	272.0500	\N	\N	221720.75	263.0764	FINNHUB	2026-06-07 22:47:43.643029+00	\N
85	4139	2026-06-08	82.7200	\N	\N	319067.30	21.9411	FINNHUB	2026-06-07 22:47:46.986265+00	\N
86	4140	2026-06-08	184.7700	\N	\N	192063.45	26.2633	FINNHUB	2026-06-07 22:47:50.353605+00	\N
87	4141	2026-06-08	310.6600	\N	\N	211971.53	18.8923	FINNHUB	2026-06-07 22:47:53.693317+00	\N
88	4142	2026-06-08	279.8400	\N	\N	198827.95	22.9144	FINNHUB	2026-06-07 22:47:57.029568+00	\N
89	4143	2026-06-08	88.7100	\N	\N	172297.33	13.1609	FINNHUB	2026-06-07 22:48:00.374045+00	\N
90	4144	2026-06-08	42.9600	\N	\N	1261429.40	10.3432	FINNHUB	2026-06-07 22:48:03.756648+00	\N
91	4145	2026-06-08	401.3900	\N	\N	195511.88	59.0059	FINNHUB	2026-06-07 22:48:07.089693+00	\N
92	4146	2026-06-08	154.2700	\N	\N	194257.19	52.2127	FINNHUB	2026-06-07 22:48:10.419143+00	\N
93	4147	2026-06-08	141.9200	\N	\N	193971.77	22.2114	FINNHUB	2026-06-07 22:48:13.757788+00	\N
94	4148	2026-06-08	178.1000	\N	\N	192740.66	18.2814	FINNHUB	2026-06-07 22:48:17.096411+00	\N
95	4149	2026-06-08	847.4700	\N	\N	190027.34	79.9106	FINNHUB	2026-06-07 22:48:20.434698+00	\N
96	4150	2026-06-08	45.3700	\N	\N	189445.10	10.9253	FINNHUB	2026-06-07 22:48:23.769237+00	\N
97	4151	2026-06-08	349.5800	\N	\N	188671.22	24.1886	FINNHUB	2026-06-07 22:48:27.107838+00	\N
98	4152	2026-06-08	557.2000	\N	\N	187185.77	47.2340	FINNHUB	2026-06-07 22:48:30.422744+00	\N
99	4153	2026-06-08	113.1600	\N	\N	266991.03	17.9068	FINNHUB	2026-06-07 22:48:34.361641+00	\N
100	4154	2026-06-08	85.8400	\N	\N	179005.72	21.8753	FINNHUB	2026-06-07 22:48:37.767157+00	\N
101	4155	2026-06-08	160.7100	\N	\N	177537.06	30.6627	FINNHUB	2026-06-07 22:48:41.106739+00	\N
102	4156	2026-06-08	12.1500	\N	\N	157420.42	9.7450	FINNHUB	2026-06-07 22:48:44.447026+00	\N
103	4157	2026-06-08	511.7200	\N	\N	176380.75	27.0897	FINNHUB	2026-06-07 22:48:47.78069+00	\N
104	4158	2026-06-08	100.6900	\N	\N	135580.52	18.1488	FINNHUB	2026-06-07 22:48:51.148588+00	\N
105	4159	2026-06-08	472.8000	\N	\N	175702.62	25.6650	FINNHUB	2026-06-07 22:48:54.513526+00	\N
106	4160	2026-06-08	99.7100	\N	\N	173147.55	15.4265	FINNHUB	2026-06-07 22:48:57.846413+00	\N
107	4161	2026-06-08	671.0200	\N	\N	170799.10	\N	FINNHUB	2026-06-07 22:49:01.15759+00	\N
108	4162	2026-06-08	138.8100	\N	\N	170768.86	38.2418	FINNHUB	2026-06-07 22:49:04.59095+00	\N
109	4163	2026-06-08	215.4500	\N	\N	169839.73	74.8852	FINNHUB	2026-06-07 22:49:07.92259+00	\N
110	4164	2026-06-08	995.6000	\N	\N	162124.40	25.9192	FINNHUB	2026-06-07 22:49:11.259936+00	\N
111	4165	2026-06-08	272.3200	\N	\N	156680.90	21.7220	FINNHUB	2026-06-07 22:49:14.595028+00	\N
112	4166	2026-06-08	129.1600	\N	\N	160361.16	17.3984	FINNHUB	2026-06-07 22:49:18.106016+00	\N
113	4167	2026-06-08	91.0700	\N	\N	158626.84	25.2751	FINNHUB	2026-06-07 22:49:21.447249+00	\N
114	4168	2026-06-08	22.7500	\N	\N	158074.72	7.3760	FINNHUB	2026-06-07 22:49:24.792129+00	\N
115	4169	2026-06-08	583.4400	\N	\N	157492.30	32.9275	FINNHUB	2026-06-07 22:49:28.132836+00	\N
116	4170	2026-06-08	88.8400	\N	\N	154504.80	16.3983	FINNHUB	2026-06-07 22:49:31.462932+00	\N
117	4171	2026-06-08	395.9400	\N	\N	153743.48	38.5225	FINNHUB	2026-06-07 22:49:34.848293+00	\N
118	4172	2026-06-08	177.5800	\N	\N	152832.06	84.4376	FINNHUB	2026-06-07 22:49:38.193554+00	\N
119	4173	2026-06-08	78.5000	\N	\N	134027.83	21.2940	FINNHUB	2026-06-07 22:49:41.595642+00	\N
120	4174	2026-06-08	185.6600	\N	\N	152055.55	18.9525	FINNHUB	2026-06-07 22:49:44.922578+00	\N
121	4175	2026-06-08	422.0600	\N	\N	149477.97	50.1755	FINNHUB	2026-06-07 22:49:48.259728+00	\N
122	4176	2026-06-08	26.0400	\N	\N	148413.52	19.8122	FINNHUB	2026-06-07 22:49:51.588014+00	\N
123	4177	2026-06-08	23.1600	\N	\N	23393220.00	14.7780	FINNHUB	2026-06-07 22:49:54.980215+00	\N
124	4178	2026-06-08	206.9300	\N	\N	146074.86	103.7788	FINNHUB	2026-06-07 22:49:58.307543+00	\N
125	4179	2026-06-08	172.9700	\N	\N	144313.31	29.0620	FINNHUB	2026-06-07 22:50:01.645908+00	\N
126	4180	2026-06-08	47.0100	\N	\N	113789.34	15.6755	FINNHUB	2026-06-07 22:50:04.975742+00	\N
127	4181	2026-06-08	70.7100	\N	\N	146624.19	17.1691	FINNHUB	2026-06-07 22:50:08.284758+00	\N
128	4182	2026-06-08	117.1400	\N	\N	142710.95	19.4907	FINNHUB	2026-06-07 22:50:11.640348+00	\N
129	4183	2026-06-08	109.5400	\N	\N	142145.08	106.7155	FINNHUB	2026-06-07 22:50:14.957056+00	\N
130	4184	2026-06-08	115.3500	\N	\N	140901.66	46.1354	FINNHUB	2026-06-07 22:50:18.316906+00	\N
131	4185	2026-06-08	144.5400	\N	\N	137606.56	37.0183	FINNHUB	2026-06-07 22:50:21.659076+00	\N
132	4186	2026-06-08	213.9700	\N	\N	135582.77	30.0560	FINNHUB	2026-06-07 22:50:25.005437+00	\N
133	4187	2026-06-08	21.8900	\N	\N	20976390.00	\N	FINNHUB	2026-06-07 22:50:28.355712+00	\N
134	4188	2026-06-08	184.3000	\N	\N	130442.13	35.3598	FINNHUB	2026-06-07 22:50:31.711446+00	\N
135	4189	2026-06-08	165.8400	\N	\N	128505.84	20.8817	FINNHUB	2026-06-07 22:50:35.045581+00	\N
136	4190	2026-06-08	59.7200	\N	\N	99118.05	12.7664	FINNHUB	2026-06-07 22:50:38.492965+00	\N
137	4191	2026-06-08	326.2700	\N	\N	126547.12	11.1999	FINNHUB	2026-06-07 22:50:41.848405+00	\N
138	4192	2026-06-08	424.4400	\N	\N	125634.24	26.2998	FINNHUB	2026-06-07 22:50:45.188811+00	\N
139	4193	2026-06-08	22.2200	\N	\N	110426.16	10.2218	FINNHUB	2026-06-07 22:50:48.595942+00	\N
140	4194	2026-06-08	56.3100	\N	\N	172140.80	24.9299	FINNHUB	2026-06-07 22:50:51.93837+00	\N
141	4195	2026-06-08	95.9300	\N	\N	122399.70	41.7461	FINNHUB	2026-06-07 22:50:55.267106+00	\N
142	4196	2026-06-08	56.7200	\N	\N	88227.22	10.7878	FINNHUB	2026-06-07 22:50:58.696318+00	\N
143	4197	2026-06-08	85.0700	\N	\N	122241.28	8.6757	FINNHUB	2026-06-07 22:51:02.011597+00	\N
144	4198	2026-06-08	523.7600	\N	\N	120759.99	25.1951	FINNHUB	2026-06-07 22:51:05.347666+00	\N
145	4199	2026-06-08	23.4100	\N	\N	11604413.00	15.2637	FINNHUB	2026-06-07 22:51:08.675026+00	\N
146	4200	2026-06-08	72.1900	\N	\N	120549.45	14.9695	FINNHUB	2026-06-07 22:51:12.00482+00	\N
147	4201	2026-06-08	204.0200	\N	\N	119216.32	10.3137	FINNHUB	2026-06-07 22:51:15.339987+00	\N
148	4202	2026-06-08	210.7400	\N	\N	118163.41	17.7903	FINNHUB	2026-06-07 22:51:18.675706+00	\N
149	4203	2026-06-08	9.5200	\N	\N	18642272.00	14.9301	FINNHUB	2026-06-07 22:51:22.007178+00	\N
150	4204	2026-06-08	305.6600	\N	\N	117178.05	35.1148	FINNHUB	2026-06-07 22:51:25.336335+00	\N
151	4205	2026-06-08	57.2700	\N	\N	116949.42	19.5675	FINNHUB	2026-06-07 22:51:28.674857+00	\N
152	4206	2026-06-08	112.4500	\N	\N	115970.59	66.0049	FINNHUB	2026-06-07 22:51:31.995167+00	\N
153	4207	2026-06-08	300.5100	\N	\N	115428.53	74.0686	FINNHUB	2026-06-07 22:51:35.302525+00	\N
154	4208	2026-06-08	164.3700	\N	\N	162156.66	16.6639	FINNHUB	2026-06-07 22:51:38.723124+00	\N
155	4209	2026-06-08	446.8300	\N	\N	113407.88	26.1411	FINNHUB	2026-06-07 22:51:42.054988+00	\N
156	4210	2026-06-08	42.9700	\N	\N	84158.03	34.9753	FINNHUB	2026-06-07 22:51:45.399243+00	\N
157	4211	2026-06-08	180.6700	\N	\N	112429.63	34.8835	FINNHUB	2026-06-07 22:51:48.731438+00	\N
158	4212	2026-06-08	882.3400	\N	\N	111251.06	31.9671	FINNHUB	2026-06-07 22:51:52.059703+00	\N
159	4213	2026-06-08	17.7500	\N	\N	561060.30	5.2151	FINNHUB	2026-06-07 22:51:55.426606+00	\N
160	4214	2026-06-08	15.8500	\N	\N	561060.30	5.2151	FINNHUB	2026-06-07 22:51:58.76786+00	\N
161	4215	2026-06-08	178.2500	\N	\N	109434.67	14.3084	FINNHUB	2026-06-07 22:52:02.11616+00	\N
162	4216	2026-06-08	95.2900	\N	\N	108602.01	72.6095	FINNHUB	2026-06-07 22:52:05.45308+00	\N
163	4217	2026-06-08	45.0200	\N	\N	92175.07	7.5374	FINNHUB	2026-06-07 22:52:08.913919+00	\N
164	4218	2026-06-08	1080.9500	\N	\N	106607.89	74.9704	FINNHUB	2026-06-07 22:52:12.249422+00	\N
165	4219	2026-06-08	99.7100	\N	\N	106445.69	12.5882	FINNHUB	2026-06-07 22:52:15.592407+00	\N
166	4220	2026-06-08	144.6800	\N	\N	105999.56	54.2336	FINNHUB	2026-06-07 22:52:18.918821+00	\N
167	4221	2026-06-08	81.6700	\N	\N	104854.89	21.8357	FINNHUB	2026-06-07 22:52:22.267958+00	\N
168	4222	2026-06-08	92.6000	\N	\N	104388.09	23.9258	FINNHUB	2026-06-07 22:52:25.596967+00	\N
169	4223	2026-06-08	50.4800	\N	\N	104388.09	23.9258	FINNHUB	2026-06-07 22:52:29.016717+00	\N
170	4224	2026-06-08	695.1100	\N	\N	104308.31	94.4184	FINNHUB	2026-06-07 22:52:32.340911+00	\N
171	4225	2026-06-08	376.1900	\N	\N	103759.23	88.6097	FINNHUB	2026-06-07 22:52:35.698028+00	\N
172	4226	2026-06-08	392.5100	\N	\N	103500.42	40.0543	FINNHUB	2026-06-07 22:52:39.182861+00	\N
173	4227	2026-06-08	51.5200	\N	\N	76278.88	13.0861	FINNHUB	2026-06-07 22:52:42.520381+00	\N
174	4228	2026-06-08	496.9500	\N	\N	102288.48	32.7792	FINNHUB	2026-06-07 22:52:45.913968+00	\N
175	4229	2026-06-08	251.4400	\N	\N	101632.06	14.0999	FINNHUB	2026-06-07 22:52:49.254421+00	\N
176	4230	2026-06-08	456.8400	\N	\N	100986.98	34.8459	FINNHUB	2026-06-07 22:52:52.587893+00	\N
177	4231	2026-06-08	251.9000	\N	\N	100787.08	57.7908	FINNHUB	2026-06-07 22:52:55.92379+00	\N
178	4232	2026-06-08	108.8400	\N	\N	140464.89	14.3069	FINNHUB	2026-06-07 22:52:59.24586+00	\N
179	4233	2026-06-08	44.6000	\N	\N	99779.73	74.6854	FINNHUB	2026-06-07 22:53:02.565625+00	\N
180	4234	2026-06-08	80.5600	\N	\N	139411.92	14.6012	FINNHUB	2026-06-07 22:53:05.904299+00	\N
181	4235	2026-06-08	142.3900	\N	\N	97733.52	\N	FINNHUB	2026-06-07 22:53:09.226971+00	\N
182	4236	2026-06-08	124.2200	\N	\N	96841.44	18.8444	FINNHUB	2026-06-07 22:53:12.595879+00	\N
183	4237	2026-06-08	45.7000	\N	\N	138133.06	14.2259	FINNHUB	2026-06-07 22:53:15.941185+00	\N
184	4238	2026-06-08	25.9500	\N	\N	8908024.00	16.4331	FINNHUB	2026-06-07 22:53:19.259847+00	\N
185	4239	2026-06-08	346.4400	\N	\N	93687.83	21.5821	FINNHUB	2026-06-07 22:53:22.585274+00	\N
186	4240	2026-06-08	36.9400	\N	\N	892034.70	17.0633	FINNHUB	2026-06-07 22:53:25.920591+00	\N
187	4241	2026-06-08	257.4000	\N	\N	93271.31	21.8419	FINNHUB	2026-06-07 22:53:29.24497+00	\N
188	4242	2026-06-08	775.6600	\N	\N	93237.48	19.5795	FINNHUB	2026-06-07 22:53:32.593682+00	\N
189	4243	2026-06-08	231.9500	\N	\N	92718.37	21.3366	FINNHUB	2026-06-07 22:53:36.092228+00	\N
190	4244	2026-06-08	108.5400	\N	\N	92259.69	17.5766	FINNHUB	2026-06-07 22:53:39.417241+00	\N
191	4245	2026-06-08	228.3700	\N	\N	91705.32	12.7104	FINNHUB	2026-06-07 22:53:42.731782+00	\N
192	4246	2026-06-08	63.3700	\N	\N	91098.17	33.3327	FINNHUB	2026-06-07 22:53:46.069661+00	\N
193	4247	2026-06-08	254.8300	\N	\N	92042.06	24.2791	FINNHUB	2026-06-07 22:53:49.374175+00	\N
194	4248	2026-06-08	194.1200	\N	\N	90439.16	31.1827	FINNHUB	2026-06-07 22:53:52.706385+00	\N
195	4249	2026-06-08	415.5300	\N	\N	90237.48	17.2110	FINNHUB	2026-06-07 22:53:56.023253+00	\N
196	4250	2026-06-08	651.2200	\N	\N	89861.23	33.6181	FINNHUB	2026-06-07 22:53:59.373137+00	\N
197	4251	2026-06-08	464.8500	\N	\N	89009.16	115.1078	FINNHUB	2026-06-07 22:54:02.716499+00	\N
198	4252	2026-06-08	220.4000	\N	\N	88507.30	31.6776	FINNHUB	2026-06-07 22:54:06.052153+00	\N
199	4253	2026-06-08	250.1100	\N	\N	88405.45	\N	FINNHUB	2026-06-07 22:54:09.389437+00	\N
200	4254	2026-06-08	71.9600	\N	\N	88006.95	31.5211	FINNHUB	2026-06-07 22:54:12.716165+00	\N
201	4255	2026-06-08	143.6500	\N	\N	87643.10	24.8210	FINNHUB	2026-06-07 22:54:16.057282+00	\N
202	4256	2026-06-08	89.5500	\N	\N	87580.63	43.1023	FINNHUB	2026-06-07 22:54:19.398275+00	\N
203	4257	2026-06-08	46.9900	\N	\N	87313.95	28.6275	FINNHUB	2026-06-07 22:54:22.73416+00	\N
204	4258	2026-06-08	55.6900	\N	\N	86447.56	11.0745	FINNHUB	2026-06-07 22:54:26.046846+00	\N
205	4259	2026-06-08	29.6700	\N	\N	74653.13	7.7193	FINNHUB	2026-06-07 22:54:29.364816+00	\N
206	4260	2026-06-08	23.8200	\N	\N	85090.48	4.5268	FINNHUB	2026-06-07 22:54:32.70166+00	\N
207	4261	2026-06-08	7.5400	\N	\N	432650.44	12.4150	FINNHUB	2026-06-07 22:54:36.031254+00	\N
208	4262	2026-06-08	14.3800	\N	\N	77555.14	99.3024	FINNHUB	2026-06-07 22:54:39.415379+00	\N
209	4263	2026-06-08	93.4000	\N	\N	83861.33	28.3161	FINNHUB	2026-06-07 22:54:42.729435+00	\N
210	4264	2026-06-08	234.1100	\N	\N	83333.84	614.2257	FINNHUB	2026-06-07 22:54:46.047624+00	\N
211	4265	2026-06-08	24.2700	\N	\N	62817.62	5.6797	FINNHUB	2026-06-07 22:54:49.372606+00	\N
212	4266	2026-06-08	238.2600	\N	\N	82580.91	\N	FINNHUB	2026-06-07 22:54:52.662723+00	\N
213	4267	2026-06-08	372.1300	\N	\N	82553.24	12.1509	FINNHUB	2026-06-07 22:54:55.994958+00	\N
214	4268	2026-06-08	54.8700	\N	\N	82033.81	24.6422	FINNHUB	2026-06-07 22:54:59.299136+00	\N
215	4269	2026-06-08	163.6600	\N	\N	123113.16	16.5390	FINNHUB	2026-06-07 22:55:02.701356+00	\N
216	4270	2026-06-08	37.8100	\N	\N	81802.63	13.8578	FINNHUB	2026-06-07 22:55:05.999601+00	\N
217	4271	2026-06-08	1607.8000	\N	\N	81510.93	42.4536	FINNHUB	2026-06-07 22:55:09.305857+00	\N
218	4272	2026-06-08	296.7600	\N	\N	81174.84	17.7083	FINNHUB	2026-06-07 22:55:12.644107+00	\N
219	4273	2026-06-08	81.8600	\N	\N	59658.77	18.4075	FINNHUB	2026-06-07 22:55:15.958142+00	\N
220	4274	2026-06-08	34.0300	\N	\N	2602020.00	55.0657	FINNHUB	2026-06-07 22:55:19.314274+00	\N
221	4275	2026-06-08	153.7600	\N	\N	80196.19	28.7751	FINNHUB	2026-06-07 22:55:22.632193+00	\N
222	4276	2026-06-08	141.5000	\N	\N	80020.02	20.3561	FINNHUB	2026-06-07 22:55:25.952658+00	\N
223	4277	2026-06-08	210.3100	\N	\N	68199.73	14.5307	FINNHUB	2026-06-07 22:55:29.267566+00	\N
224	4278	2026-06-08	53.8000	\N	\N	68484.14	15.2798	FINNHUB	2026-06-07 22:55:32.593543+00	\N
225	4279	2026-06-08	89.9300	\N	\N	110407.77	27.0806	FINNHUB	2026-06-07 22:55:35.954575+00	\N
226	4280	2026-06-08	165.4400	\N	\N	79708.08	20.3078	FINNHUB	2026-06-07 22:55:39.254817+00	\N
227	4281	2026-06-08	62.0400	\N	\N	79637.63	30.4542	FINNHUB	2026-06-07 22:55:42.560711+00	\N
228	4282	2026-06-08	133.5400	\N	\N	80485.21	31.9766	FINNHUB	2026-06-07 22:55:45.860877+00	\N
229	4283	2026-06-08	331.0000	\N	\N	78978.84	17.6135	FINNHUB	2026-06-07 22:55:49.173905+00	\N
230	4284	2026-06-08	451.3500	\N	\N	78850.84	31.6035	FINNHUB	2026-06-07 22:55:52.482046+00	\N
231	4285	2026-06-08	343.1000	\N	\N	78106.16	50.6525	FINNHUB	2026-06-07 22:55:55.777401+00	\N
232	4286	2026-06-08	138.1200	\N	\N	77361.01	31.6534	FINNHUB	2026-06-07 22:55:59.118539+00	\N
233	4287	2026-06-08	544.4000	\N	\N	77323.02	16.8975	FINNHUB	2026-06-07 22:56:02.449583+00	\N
234	4288	2026-06-08	5.3100	\N	\N	58554.57	9.3077	FINNHUB	2026-06-07 22:56:05.758884+00	\N
235	4289	2026-06-08	119.4800	\N	\N	76842.88	15.2825	FINNHUB	2026-06-07 22:56:09.092716+00	\N
236	4290	2026-06-08	289.4800	\N	\N	76576.84	12.1783	FINNHUB	2026-06-07 22:56:12.413901+00	\N
237	4291	2026-06-08	262.0100	\N	\N	76490.31	16.5135	FINNHUB	2026-06-07 22:56:15.700916+00	\N
238	4292	2026-06-08	255.8200	\N	\N	75961.35	18.0602	FINNHUB	2026-06-07 22:56:19.023993+00	\N
239	4293	2026-06-08	280.0000	\N	\N	75094.59	16.7659	FINNHUB	2026-06-07 22:56:22.329981+00	\N
240	4294	2026-06-08	263.6100	\N	\N	74982.25	12428.6839	FINNHUB	2026-06-07 22:56:25.639211+00	\N
241	4295	2026-06-08	305.3000	\N	\N	75297.85	28.9685	FINNHUB	2026-06-07 22:56:28.953235+00	\N
242	4296	2026-06-08	90.3300	\N	\N	74857.84	28.7483	FINNHUB	2026-06-07 22:56:32.327586+00	\N
243	4297	2026-06-08	295.9600	\N	\N	74721.34	28.1648	FINNHUB	2026-06-07 22:56:35.632776+00	\N
244	4298	2026-06-08	24.8400	\N	\N	1321162.90	15.0960	FINNHUB	2026-06-07 22:56:39.068545+00	\N
245	4299	2026-06-08	82.4700	\N	\N	74330.65	39.1833	FINNHUB	2026-06-07 22:56:42.360828+00	\N
246	4300	2026-06-08	82.1100	\N	\N	74035.73	29.1709	FINNHUB	2026-06-07 22:56:45.65444+00	\N
247	4301	2026-06-08	230.3700	\N	\N	73898.34	31.9111	FINNHUB	2026-06-07 22:56:48.980347+00	\N
248	4302	2026-06-08	46.1800	\N	\N	73739.60	29.2501	FINNHUB	2026-06-07 22:56:52.266436+00	\N
249	4303	2026-06-08	128.0300	\N	\N	73811.54	64.5206	FINNHUB	2026-06-07 22:56:55.576541+00	\N
250	4304	2026-06-08	376.9900	\N	\N	73754.07	157.3088	FINNHUB	2026-06-07 22:56:58.885705+00	\N
251	4305	2026-06-08	62.2200	\N	\N	108020.77	17.0676	FINNHUB	2026-06-07 22:57:02.20168+00	\N
252	4306	2026-06-08	66.5100	\N	\N	72950.55	50.6249	FINNHUB	2026-06-07 22:57:05.507868+00	\N
253	4307	2026-06-08	183.0800	\N	\N	73403.19	17.8033	FINNHUB	2026-06-07 22:57:08.80654+00	\N
254	4308	2026-06-08	137.7800	\N	\N	73385.56	13.3501	FINNHUB	2026-06-07 22:57:12.12293+00	\N
255	4309	2026-06-08	120.3800	\N	\N	100816.91	21.4276	FINNHUB	2026-06-07 22:57:15.453075+00	\N
256	4310	2026-06-08	1481.0500	\N	\N	72763.98	106.8616	FINNHUB	2026-06-07 22:57:18.753404+00	\N
257	4311	2026-06-08	252.7200	\N	\N	72707.55	23.1996	FINNHUB	2026-06-07 22:57:22.116522+00	\N
258	4312	2026-06-08	257.9700	\N	\N	72602.43	34.4790	FINNHUB	2026-06-07 22:57:25.431296+00	\N
259	4313	2026-06-08	48.5500	\N	\N	72162.54	20.2419	FINNHUB	2026-06-07 22:57:28.767885+00	\N
260	4314	2026-06-08	179.8500	\N	\N	71955.67	37.1435	FINNHUB	2026-06-07 22:57:32.075529+00	\N
261	4315	2026-06-08	68.6800	\N	\N	95750.00	27.8343	FINNHUB	2026-06-07 22:57:35.445497+00	\N
262	4316	2026-06-08	88.5800	\N	\N	70880.77	33.9630	FINNHUB	2026-06-07 22:57:38.844869+00	\N
263	4317	2026-06-08	31.6800	\N	\N	70482.48	21.2617	FINNHUB	2026-06-07 22:57:42.153406+00	\N
264	4318	2026-06-08	313.4500	\N	\N	70398.98	26.3667	FINNHUB	2026-06-07 22:57:45.466766+00	\N
265	4319	2026-06-08	129.1400	\N	\N	70265.73	19.2309	FINNHUB	2026-06-07 22:57:48.810063+00	\N
266	4320	2026-06-08	105.0600	\N	\N	70201.11	19.1232	FINNHUB	2026-06-07 22:57:52.177767+00	\N
267	4321	2026-06-08	328.5300	\N	\N	70166.43	17.7997	FINNHUB	2026-06-07 22:57:55.499995+00	\N
268	4322	2026-06-08	1238.7400	\N	\N	69287.16	33.2791	FINNHUB	2026-06-07 22:57:59.079297+00	\N
269	4323	2026-06-08	488.2100	\N	\N	69032.13	157.4997	FINNHUB	2026-06-07 22:58:02.460627+00	\N
270	4324	2026-06-08	156.8000	\N	\N	68320.70	73.7805	FINNHUB	2026-06-07 22:58:05.744541+00	\N
271	4325	2026-06-08	410.3400	\N	\N	68114.63	32.5907	FINNHUB	2026-06-07 22:58:09.077684+00	\N
272	4326	2026-06-08	863.6600	\N	\N	67192.75	152.7455	FINNHUB	2026-06-07 22:58:12.378211+00	\N
273	4327	2026-06-08	1067.7700	\N	\N	66892.12	26.6821	FINNHUB	2026-06-07 22:58:15.686629+00	\N
274	4328	2026-06-08	186.7900	\N	\N	65639.14	47.6375	FINNHUB	2026-06-07 22:58:19.008046+00	\N
275	4329	2026-06-08	19.3900	\N	\N	66724.08	15.2897	FINNHUB	2026-06-07 22:58:22.315075+00	\N
276	4330	2026-06-08	39.4600	\N	\N	99600.17	11.6778	FINNHUB	2026-06-07 22:58:25.692967+00	\N
277	4331	2026-06-08	26.2400	\N	\N	65787.27	\N	FINNHUB	2026-06-07 22:58:29.000046+00	\N
278	4332	2026-06-08	15.2300	\N	\N	367651.22	23.5629	FINNHUB	2026-06-07 22:58:32.306724+00	\N
279	4333	2026-06-08	49.2000	\N	\N	65150.81	41.8707	FINNHUB	2026-06-07 22:58:35.595555+00	\N
280	4334	2026-06-08	1843.9400	\N	\N	64911.16	53.0473	FINNHUB	2026-06-07 22:58:39.146325+00	\N
281	4335	2026-06-08	38.7100	\N	\N	89705.75	13.9772	FINNHUB	2026-06-07 22:58:42.507744+00	\N
282	4336	2026-06-08	635.4500	\N	\N	66619.96	15.0608	FINNHUB	2026-06-07 22:58:45.812008+00	\N
283	4337	2026-06-08	210.0400	\N	\N	64621.77	29.7933	FINNHUB	2026-06-07 22:58:49.115458+00	\N
284	4338	2026-06-08	303.2500	\N	\N	64484.50	8.4803	FINNHUB	2026-06-07 22:58:52.428203+00	\N
285	4339	2026-06-08	70.7200	\N	\N	59545.07	229.4854	FINNHUB	2026-06-07 22:58:55.749157+00	\N
286	4340	2026-06-08	110.0800	\N	\N	63721.73	\N	FINNHUB	2026-06-07 22:58:59.050318+00	\N
287	4341	2026-06-08	42.9800	\N	\N	63648.53	28.2882	FINNHUB	2026-06-07 22:59:02.359923+00	\N
288	4342	2026-06-08	15.7900	\N	\N	47890.68	7.9898	FINNHUB	2026-06-07 22:59:05.685884+00	\N
289	4343	2026-06-08	282.3500	\N	\N	62873.90	29.8362	FINNHUB	2026-06-07 22:59:09.005402+00	\N
290	4344	2026-06-08	62.5900	\N	\N	62093.58	19.9273	FINNHUB	2026-06-07 22:59:12.320804+00	\N
291	4345	2026-06-08	212.6500	\N	\N	62071.65	21.3598	FINNHUB	2026-06-07 22:59:15.625911+00	\N
292	4346	2026-06-08	35.1500	\N	\N	45543.99	22.0552	FINNHUB	2026-06-07 22:59:18.968179+00	\N
293	4347	2026-06-08	116.6800	\N	\N	61407.08	24.8009	FINNHUB	2026-06-07 22:59:22.382951+00	\N
294	4348	2026-06-08	1300.0100	\N	\N	61377.52	34.4431	FINNHUB	2026-06-07 22:59:25.68966+00	\N
295	4349	2026-06-08	49.2000	\N	\N	61297.26	11.0905	FINNHUB	2026-06-07 22:59:28.990632+00	\N
296	4350	2026-06-08	346.9900	\N	\N	58253.57	36.4509	FINNHUB	2026-06-07 22:59:32.292375+00	\N
297	4351	2026-06-08	118.2400	\N	\N	60182.38	12.9815	FINNHUB	2026-06-07 22:59:35.603531+00	\N
298	4352	2026-06-08	91.4200	\N	\N	59760.34	30.5367	FINNHUB	2026-06-07 22:59:38.994541+00	\N
299	4353	2026-06-08	31.5100	\N	\N	51955.40	7.3373	FINNHUB	2026-06-07 22:59:42.314142+00	\N
300	4354	2026-06-08	14.9000	\N	\N	59371.92	\N	FINNHUB	2026-06-07 22:59:45.79341+00	\N
301	4355	2026-06-08	121.7200	\N	\N	85223.54	29.1861	FINNHUB	2026-06-07 22:59:49.151716+00	\N
302	4356	2026-06-08	66.9000	\N	\N	58839.39	19.9185	FINNHUB	2026-06-07 22:59:52.456338+00	\N
303	4357	2026-06-08	227.8100	\N	\N	57328.49	70.1523	FINNHUB	2026-06-07 22:59:55.759617+00	\N
304	4358	2026-06-08	11.9700	\N	\N	58181.37	18.2745	FINNHUB	2026-06-07 22:59:59.041415+00	\N
305	4359	2026-06-08	254.3900	\N	\N	57935.02	24.8541	FINNHUB	2026-06-07 23:00:02.358567+00	\N
306	4360	2026-06-08	307.8300	\N	\N	57347.18	33.1104	FINNHUB	2026-06-07 23:00:05.992305+00	\N
307	4361	2026-06-08	56.4800	\N	\N	57312.16	12.1993	FINNHUB	2026-06-07 23:00:09.543526+00	\N
308	4362	2026-06-08	60.8400	\N	\N	56732.84	50.6299	FINNHUB	2026-06-07 23:00:13.493556+00	\N
309	4363	2026-06-08	221.0100	\N	\N	56892.60	4.6848	FINNHUB	2026-06-07 23:00:16.889862+00	\N
310	4364	2026-06-08	264.0900	\N	\N	56685.31	26.5866	FINNHUB	2026-06-07 23:00:20.216696+00	\N
311	4365	2026-06-08	56.9300	\N	\N	56624.55	11.9587	FINNHUB	2026-06-07 23:00:23.529837+00	\N
312	4366	2026-06-08	329.8300	\N	\N	56566.67	53.6686	FINNHUB	2026-06-07 23:00:26.872081+00	\N
313	4367	2026-06-08	357.9300	\N	\N	56031.13	65.6058	FINNHUB	2026-06-07 23:00:30.175045+00	\N
314	4368	2026-06-08	67.1600	\N	\N	55781.79	42.5815	FINNHUB	2026-06-07 23:00:33.59399+00	\N
315	4369	2026-06-08	122.5700	\N	\N	55670.21	16.1363	FINNHUB	2026-06-07 23:00:36.939558+00	\N
316	4370	2026-06-08	151.9200	\N	\N	55660.13	63.2502	FINNHUB	2026-06-07 23:00:40.238639+00	\N
317	4371	2026-06-08	88.2500	\N	\N	55600.40	15.7464	FINNHUB	2026-06-07 23:00:43.593572+00	\N
318	4372	2026-06-08	216.1400	\N	\N	55526.36	34.4542	FINNHUB	2026-06-07 23:00:46.919998+00	\N
319	4373	2026-06-08	891.3200	\N	\N	45100.63	23.1225	FINNHUB	2026-06-07 23:00:50.229707+00	\N
320	4374	2026-06-08	100.3900	\N	\N	54769.81	\N	FINNHUB	2026-06-07 23:00:53.527122+00	\N
321	4375	2026-06-08	309.6800	\N	\N	54363.01	28.5696	FINNHUB	2026-06-07 23:00:56.849988+00	\N
322	4376	2026-06-08	84.4900	\N	\N	54363.97	15.0218	FINNHUB	2026-06-07 23:01:00.173534+00	\N
323	4377	2026-06-08	317.0600	\N	\N	54346.60	203.0700	FINNHUB	2026-06-07 23:01:03.586775+00	\N
324	4378	2026-06-08	192.6200	\N	\N	54186.57	190.7978	FINNHUB	2026-06-07 23:01:06.885891+00	\N
325	4379	2026-06-08	46.7900	\N	\N	53716.56	41.3331	FINNHUB	2026-06-07 23:01:10.22132+00	\N
326	4380	2026-06-08	275.0400	\N	\N	53512.08	20.9960	FINNHUB	2026-06-07 23:01:13.572973+00	\N
327	4381	2026-06-08	86.5600	\N	\N	56403.70	35.1855	FINNHUB	2026-06-07 23:01:16.895216+00	\N
328	4382	2026-06-08	28.2200	\N	\N	77254.95	16.6462	FINNHUB	2026-06-07 23:01:20.554263+00	\N
329	4383	2026-06-08	116.2300	\N	\N	73518.31	29.3157	FINNHUB	2026-06-07 23:01:23.910758+00	\N
330	4384	2026-06-08	19.7000	\N	\N	1572123.10	31.3728	FINNHUB	2026-06-07 23:01:27.234234+00	\N
331	4385	2026-06-08	67.2100	\N	\N	46220.52	18.2278	FINNHUB	2026-06-07 23:01:30.744261+00	\N
332	4386	2026-06-08	226.5500	\N	\N	51925.94	33.9887	FINNHUB	2026-06-07 23:01:34.054275+00	\N
333	4387	2026-06-08	79.4200	\N	\N	52178.49	11.6548	FINNHUB	2026-06-07 23:01:37.362343+00	\N
334	4388	2026-06-08	77.0300	\N	\N	51519.20	44.3367	FINNHUB	2026-06-07 23:01:40.797229+00	\N
335	4389	2026-06-08	44.2800	\N	\N	51072.69	22.5188	FINNHUB	2026-06-07 23:01:44.168191+00	\N
336	4390	2026-06-08	3116.4300	\N	\N	51348.86	20.7209	FINNHUB	2026-06-07 23:01:47.483828+00	\N
337	4391	2026-06-08	203.0000	\N	\N	50902.55	57.3873	FINNHUB	2026-06-07 23:01:51.038765+00	\N
338	4392	2026-06-08	12.4000	\N	\N	4957683.00	16.8400	FINNHUB	2026-06-07 23:01:56.394318+00	\N
339	4393	2026-06-08	110.7400	\N	\N	50706.39	28.1435	FINNHUB	2026-06-07 23:01:59.819832+00	\N
340	4394	2026-06-08	242.5700	\N	\N	50446.87	50.0812	FINNHUB	2026-06-07 23:02:03.139156+00	\N
341	4395	2026-06-08	148.7600	\N	\N	50159.27	22.3825	FINNHUB	2026-06-07 23:02:06.481674+00	\N
342	4396	2026-06-08	238.8200	\N	\N	50045.18	33.9289	FINNHUB	2026-06-07 23:02:10.088722+00	\N
343	4397	2026-06-08	446.7100	\N	\N	49707.19	45.6868	FINNHUB	2026-06-07 23:02:13.693704+00	\N
344	4398	2026-06-08	85.9600	\N	\N	49495.77	45.1521	FINNHUB	2026-06-07 23:02:17.005203+00	\N
345	4399	2026-06-08	87.2800	\N	\N	49360.40	25.8161	FINNHUB	2026-06-07 23:02:20.324537+00	\N
346	4400	2026-06-08	79.0400	\N	\N	49342.27	23.5974	FINNHUB	2026-06-07 23:02:23.639024+00	\N
347	4401	2026-06-08	3.1200	\N	\N	253253.00	16.2574	FINNHUB	2026-06-07 23:02:27.238484+00	\N
348	4402	2026-06-08	66.8100	\N	\N	40896.18	46.0543	FINNHUB	2026-06-07 23:02:30.567576+00	\N
349	4403	2026-06-08	15.6000	\N	\N	7688481.00	40.0939	FINNHUB	2026-06-07 23:02:33.907436+00	\N
350	4404	2026-06-08	229.9600	\N	\N	48521.56	33.1658	FINNHUB	2026-06-07 23:02:37.232347+00	\N
351	4405	2026-06-08	109.3500	\N	\N	48551.40	23.7997	FINNHUB	2026-06-07 23:02:40.53765+00	\N
352	4406	2026-06-08	205.7100	\N	\N	48178.49	30.9830	FINNHUB	2026-06-07 23:02:43.859513+00	\N
353	4407	2026-06-08	88.3400	\N	\N	47887.28	208.2056	FINNHUB	2026-06-07 23:02:47.350353+00	\N
354	4408	2026-06-08	52.0100	\N	\N	47137.27	21.6923	FINNHUB	2026-06-07 23:02:50.699596+00	\N
355	4409	2026-06-08	45.7500	\N	\N	46811.77	16.8448	FINNHUB	2026-06-07 23:02:54.012707+00	\N
356	4410	2026-06-08	331.4300	\N	\N	38998.54	49.3886	FINNHUB	2026-06-07 23:02:57.539577+00	\N
357	4411	2026-06-08	117.2600	\N	\N	45954.57	80.1021	FINNHUB	2026-06-07 23:03:00.850682+00	\N
358	4412	2026-06-08	236.5700	\N	\N	45623.99	26.2781	FINNHUB	2026-06-07 23:03:04.168653+00	\N
359	4413	2026-06-08	103.4400	\N	\N	45051.53	96.4929	FINNHUB	2026-06-07 23:03:07.468772+00	\N
360	4414	2026-06-08	615.4600	\N	\N	44805.49	33.9511	FINNHUB	2026-06-07 23:03:10.771223+00	\N
361	4415	2026-06-08	161.7500	\N	\N	44767.07	14.6059	FINNHUB	2026-06-07 23:03:14.068064+00	\N
362	4416	2026-06-08	229.5800	\N	\N	44524.25	18.0260	FINNHUB	2026-06-07 23:03:17.368064+00	\N
363	4417	2026-06-08	80.4300	\N	\N	32753.63	18.1006	FINNHUB	2026-06-07 23:03:20.756672+00	\N
364	4418	2026-06-08	562.1600	\N	\N	44344.87	40.4890	FINNHUB	2026-06-07 23:03:24.080998+00	\N
365	4419	2026-06-08	260.4000	\N	\N	44183.98	36.5157	FINNHUB	2026-06-07 23:03:27.397398+00	\N
366	4420	2026-06-08	33.6100	\N	\N	44153.06	45.7071	FINNHUB	2026-06-07 23:03:30.677198+00	\N
367	4421	2026-06-08	201.0100	\N	\N	44143.88	\N	FINNHUB	2026-06-07 23:03:34.043988+00	\N
368	4422	2026-06-08	371.7100	\N	\N	67950.26	50.8719	FINNHUB	2026-06-07 23:03:37.408312+00	\N
369	4423	2026-06-08	12.5600	\N	\N	414308.30	16.4624	FINNHUB	2026-06-07 23:03:40.73436+00	\N
370	4424	2026-06-08	84.1200	\N	\N	42481.23	12.2283	FINNHUB	2026-06-07 23:03:44.04989+00	\N
371	4425	2026-06-08	120.4400	\N	\N	42207.91	\N	FINNHUB	2026-06-07 23:03:47.378407+00	\N
372	4426	2026-06-08	218.7400	\N	\N	63288.10	33.1315	FINNHUB	2026-06-07 23:03:50.684997+00	\N
373	4427	2026-06-08	350.0800	\N	\N	42031.13	37.1957	FINNHUB	2026-06-07 23:03:54.043944+00	\N
374	4428	2026-06-08	37.8800	\N	\N	6515090.00	14.5665	FINNHUB	2026-06-07 23:03:57.356341+00	\N
375	4429	2026-06-08	151.1600	\N	\N	41650.69	36.5999	FINNHUB	2026-06-07 23:04:00.669901+00	\N
376	4430	2026-06-08	150.8700	\N	\N	41582.97	23.9258	FINNHUB	2026-06-07 23:04:04.044617+00	\N
377	4431	2026-06-08	21.3300	\N	\N	58287.73	15.1054	FINNHUB	2026-06-07 23:04:07.352972+00	\N
378	4432	2026-06-08	30.5300	\N	\N	41537.88	22.6735	FINNHUB	2026-06-07 23:04:10.655827+00	\N
379	4433	2026-06-08	94.7400	\N	\N	41990.44	18.7638	FINNHUB	2026-06-07 23:04:13.937713+00	\N
380	4434	2026-06-08	125.6500	\N	\N	27897.87	44.7956	FINNHUB	2026-06-07 23:04:17.224811+00	\N
381	4435	2026-06-08	75.5300	\N	\N	41421.89	53.1732	FINNHUB	2026-06-07 23:04:20.512626+00	\N
382	4436	2026-06-08	121.6600	\N	\N	45886.58	796.6544	FINNHUB	2026-06-07 23:04:23.825038+00	\N
383	4437	2026-06-08	145.6000	\N	\N	41289.20	13.0143	FINNHUB	2026-06-07 23:04:27.135667+00	\N
384	4438	2026-06-08	94.4900	\N	\N	41240.35	38.9427	FINNHUB	2026-06-07 23:04:30.444252+00	\N
385	4439	2026-06-08	68.1500	\N	\N	40561.59	50.2570	FINNHUB	2026-06-07 23:04:33.820283+00	\N
386	4440	2026-06-08	73.7200	\N	\N	56195.20	17.1327	FINNHUB	2026-06-07 23:04:37.171709+00	\N
387	4441	2026-06-08	454.6600	\N	\N	40872.61	10.4936	FINNHUB	2026-06-07 23:04:40.490957+00	\N
388	4442	2026-06-08	303.0500	\N	\N	40460.99	70.0967	FINNHUB	2026-06-07 23:04:43.790554+00	\N
389	4443	2026-06-08	82.0200	\N	\N	39875.64	153.1176	FINNHUB	2026-06-07 23:04:47.089441+00	\N
390	4444	2026-06-08	152.4000	\N	\N	40151.46	50.1516	FINNHUB	2026-06-07 23:04:50.378561+00	\N
391	4445	2026-06-08	89.9400	\N	\N	39547.36	32.9929	FINNHUB	2026-06-07 23:04:53.659872+00	\N
392	4446	2026-06-08	75.4900	\N	\N	40025.27	12.6622	FINNHUB	2026-06-07 23:04:57.03814+00	\N
393	4447	2026-06-08	9.1200	\N	\N	29173.98	17.5009	FINNHUB	2026-06-07 23:05:00.374527+00	\N
394	4448	2026-06-08	34.1900	\N	\N	114938.20	24.8448	FINNHUB	2026-06-07 23:05:03.752901+00	\N
395	4449	2026-06-08	214.3900	\N	\N	39805.07	\N	FINNHUB	2026-06-07 23:05:07.049444+00	\N
396	4450	2026-06-08	79.4800	\N	\N	39606.59	17.5018	FINNHUB	2026-06-07 23:05:10.368788+00	\N
397	4451	2026-06-08	155.2200	\N	\N	54983.11	37.4241	FINNHUB	2026-06-07 23:05:13.690107+00	\N
398	4452	2026-06-08	486.1200	\N	\N	39182.29	190.2163	FINNHUB	2026-06-07 23:05:16.990583+00	\N
399	4453	2026-06-08	106.2600	\N	\N	39159.97	18.1717	FINNHUB	2026-06-07 23:05:20.337521+00	\N
400	4454	2026-06-08	107.9100	\N	\N	58379720.00	9.6843	FINNHUB	2026-06-07 23:05:23.693368+00	\N
401	4455	2026-06-08	28.8800	\N	\N	279029.97	17.4657	FINNHUB	2026-06-07 23:05:26.997451+00	\N
402	4456	2026-06-08	80.9200	\N	\N	38999.93	36.0776	FINNHUB	2026-06-07 23:05:30.321187+00	\N
403	4457	2026-06-08	63.5700	\N	\N	39194.76	38.5775	FINNHUB	2026-06-07 23:05:33.631455+00	\N
404	4458	2026-06-08	203.4900	\N	\N	38892.29	170.0425	FINNHUB	2026-06-07 23:05:36.929494+00	\N
405	4459	2026-06-08	243.5000	\N	\N	38998.54	49.3886	FINNHUB	2026-06-07 23:05:40.271311+00	\N
406	4460	2026-06-08	268.5000	\N	\N	38721.13	28.2249	FINNHUB	2026-06-07 23:05:43.59368+00	\N
407	4461	2026-06-08	823.3600	\N	\N	111690.95	64.3019	FINNHUB	2026-06-07 23:05:47.142702+00	\N
408	4462	2026-06-08	130.9300	\N	\N	38338.48	29.2214	FINNHUB	2026-06-07 23:05:50.444364+00	\N
409	4463	2026-06-08	135.4400	\N	\N	38252.58	27.0527	FINNHUB	2026-06-07 23:05:53.746404+00	\N
410	4464	2026-06-08	206.8900	\N	\N	38160.85	80.8015	FINNHUB	2026-06-07 23:05:57.071093+00	\N
411	4465	2026-06-08	27.4100	\N	\N	37915.65	12.2427	FINNHUB	2026-06-07 23:06:00.386895+00	\N
412	4466	2026-06-08	122.8800	\N	\N	646375.44	22.7096	FINNHUB	2026-06-07 23:06:07.102323+00	\N
413	4467	2026-06-08	17.1100	\N	\N	37680.07	12.7556	FINNHUB	2026-06-07 23:06:10.407529+00	\N
414	4468	2026-06-08	86.0400	\N	\N	52100.91	24.4867	FINNHUB	2026-06-07 23:06:13.752106+00	\N
415	4469	2026-06-08	29.3400	\N	\N	37635.42	25.9200	FINNHUB	2026-06-07 23:06:17.048236+00	\N
416	4470	2026-06-08	84.4000	\N	\N	143160.97	137.9200	FINNHUB	2026-06-07 23:06:20.375536+00	\N
417	4471	2026-06-08	184.5800	\N	\N	37440.88	34.2188	FINNHUB	2026-06-07 23:06:23.718563+00	\N
418	4472	2026-06-08	353.2400	\N	\N	37267.75	46.0664	FINNHUB	2026-06-07 23:06:27.021096+00	\N
419	4473	2026-06-08	160.0700	\N	\N	37250.34	445.2320	FINNHUB	2026-06-07 23:06:30.328019+00	\N
420	4474	2026-06-08	124.6600	\N	\N	37089.43	136.2060	FINNHUB	2026-06-07 23:06:33.718539+00	\N
421	4475	2026-06-08	112.9500	\N	\N	36790.72	22.4484	FINNHUB	2026-06-07 23:06:37.022974+00	\N
422	4476	2026-06-08	281.3800	\N	\N	36510.43	32.7948	FINNHUB	2026-06-07 23:06:40.35933+00	\N
423	4477	2026-06-08	76.2900	\N	\N	36480.55	21.0141	FINNHUB	2026-06-07 23:06:43.677047+00	\N
424	4478	2026-06-08	41.2900	\N	\N	36422.14	7.1995	FINNHUB	2026-06-07 23:06:46.977769+00	\N
425	4479	2026-06-08	104.6200	\N	\N	36303.14	10.4741	FINNHUB	2026-06-07 23:06:50.304953+00	\N
426	4480	2026-06-08	93.6000	\N	\N	36328.46	\N	FINNHUB	2026-06-07 23:06:53.592702+00	\N
427	4481	2026-06-08	817.4400	\N	\N	36327.26	27.1581	FINNHUB	2026-06-07 23:06:56.897269+00	\N
428	4482	2026-06-08	132.1400	\N	\N	36223.65	8.9177	FINNHUB	2026-06-07 23:07:00.194506+00	\N
429	4483	2026-06-08	100.5300	\N	\N	36018.98	22.0071	FINNHUB	2026-06-07 23:07:03.527523+00	\N
430	4484	2026-06-08	365.3600	\N	\N	35873.18	79.8516	FINNHUB	2026-06-07 23:07:06.834698+00	\N
431	4485	2026-06-08	12.6500	\N	\N	35792.29	149.5189	FINNHUB	2026-06-07 23:07:10.138635+00	\N
432	4486	2026-06-08	144.2800	\N	\N	35637.16	42.0746	FINNHUB	2026-06-07 23:07:13.427141+00	\N
433	4487	2026-06-08	26.7000	\N	\N	5856344.00	\N	FINNHUB	2026-06-07 23:07:16.748829+00	\N
434	4488	2026-06-08	56.9800	\N	\N	26154.75	12.0324	FINNHUB	2026-06-07 23:07:20.106441+00	\N
435	4489	2026-06-08	44.5600	\N	\N	1097678.60	28.1290	FINNHUB	2026-06-07 23:07:23.450962+00	\N
436	4490	2026-06-08	575.8300	\N	\N	34576.23	13.6449	FINNHUB	2026-06-07 23:07:26.757755+00	\N
437	4491	2026-06-08	567.3300	\N	\N	35181.49	37.3435	FINNHUB	2026-06-07 23:07:30.069425+00	\N
438	4492	2026-06-08	105.7300	\N	\N	34060.38	9.2960	FINNHUB	2026-06-07 23:07:33.401614+00	\N
439	4493	2026-06-08	225.9900	\N	\N	34299.38	329.9413	FINNHUB	2026-06-07 23:07:36.694914+00	\N
440	4494	2026-06-08	17.7100	\N	\N	34003.35	20.9638	FINNHUB	2026-06-07 23:07:39.977104+00	\N
441	4495	2026-06-08	14.7000	\N	\N	25697.26	\N	FINNHUB	2026-06-07 23:07:43.27788+00	\N
442	4496	2026-06-08	116.2800	\N	\N	33699.51	\N	FINNHUB	2026-06-07 23:07:46.613232+00	\N
443	4497	2026-06-08	53.7500	\N	\N	33619.45	10.2363	FINNHUB	2026-06-07 23:07:49.915509+00	\N
444	4498	2026-06-08	332.1800	\N	\N	33522.73	19.5570	FINNHUB	2026-06-07 23:07:53.240344+00	\N
445	4499	2026-06-08	3.3600	\N	\N	171522.84	7.2138	FINNHUB	2026-06-07 23:07:56.554755+00	\N
446	4500	2026-06-08	16.5200	\N	\N	33488.20	15.1736	FINNHUB	2026-06-07 23:07:59.881711+00	\N
447	4501	2026-06-08	173.4500	\N	\N	33390.69	47.1924	FINNHUB	2026-06-07 23:08:03.173397+00	\N
448	4502	2026-06-08	79.4400	\N	\N	33303.48	12.6006	FINNHUB	2026-06-07 23:08:06.466416+00	\N
449	4503	2026-06-08	50.2500	\N	\N	33297.53	18.0768	FINNHUB	2026-06-07 23:08:09.797717+00	\N
450	4504	2026-06-08	72.6600	\N	\N	33157.70	34.7201	FINNHUB	2026-06-07 23:08:13.090021+00	\N
451	4505	2026-06-08	36.6200	\N	\N	556910.94	9.4337	FINNHUB	2026-06-07 23:08:16.523205+00	\N
452	4506	2026-06-08	99.0400	\N	\N	32875.37	15.5146	FINNHUB	2026-06-07 23:08:19.832123+00	\N
453	4507	2026-06-08	67.1700	\N	\N	46357348.00	9.0793	FINNHUB	2026-06-07 23:08:23.147426+00	\N
454	4508	2026-06-08	39.1800	\N	\N	32730.89	21.2538	FINNHUB	2026-06-07 23:08:26.498195+00	\N
455	4509	2026-06-08	167.0400	\N	\N	32962.07	25.8323	FINNHUB	2026-06-07 23:08:29.801153+00	\N
456	4510	2026-06-08	66.8100	\N	\N	26024.38	39.9043	FINNHUB	2026-06-07 23:08:33.118394+00	\N
457	4511	2026-06-08	222.4400	\N	\N	32575.24	11.1140	FINNHUB	2026-06-07 23:08:36.445912+00	\N
458	4512	2026-06-08	79.3600	\N	\N	32799.47	\N	FINNHUB	2026-06-07 23:08:39.733871+00	\N
459	4513	2026-06-08	67.2000	\N	\N	46136.64	13.8713	FINNHUB	2026-06-07 23:08:43.051782+00	\N
460	4514	2026-06-08	55.8700	\N	\N	32174.54	38.8916	FINNHUB	2026-06-07 23:08:46.337184+00	\N
461	4515	2026-06-08	145.3100	\N	\N	30698.33	32.5159	FINNHUB	2026-06-07 23:08:49.640638+00	\N
462	4516	2026-06-08	25.4900	\N	\N	24393.76	8.1806	FINNHUB	2026-06-07 23:08:52.958551+00	\N
463	4517	2026-06-08	12.8000	\N	\N	31104.16	11.1365	FINNHUB	2026-06-07 23:08:56.241795+00	\N
464	4518	2026-06-08	91.1900	\N	\N	31860.84	6.5396	FINNHUB	2026-06-07 23:08:59.554232+00	\N
465	4519	2026-06-08	149.2300	\N	\N	31725.77	\N	FINNHUB	2026-06-07 23:09:02.836606+00	\N
466	4520	2026-06-08	61.4400	\N	\N	29351.22	17.1986	FINNHUB	2026-06-07 23:09:06.198344+00	\N
467	4521	2026-06-08	170.4700	\N	\N	31545.01	16.8654	FINNHUB	2026-06-07 23:09:09.509182+00	\N
468	4522	2026-06-08	26.2200	\N	\N	47465.47	11.8895	FINNHUB	2026-06-07 23:09:12.820286+00	\N
469	4523	2026-06-08	64.4700	\N	\N	31206.97	12.3250	FINNHUB	2026-06-07 23:09:16.444272+00	\N
470	4524	2026-06-08	15.1500	\N	\N	115126744.00	12.7517	FINNHUB	2026-06-07 23:09:19.769448+00	\N
471	4525	2026-06-08	215.3100	\N	\N	30835.70	\N	FINNHUB	2026-06-07 23:09:23.066545+00	\N
472	4526	2026-06-08	62.3300	\N	\N	30778.37	\N	FINNHUB	2026-06-07 23:09:26.366417+00	\N
473	4527	2026-06-08	183.4500	\N	\N	30617.81	22.1067	FINNHUB	2026-06-07 23:09:29.662742+00	\N
474	4528	2026-06-08	27.8600	\N	\N	30446.58	9.8079	FINNHUB	2026-06-07 23:09:32.993555+00	\N
475	4529	2026-06-08	145.7700	\N	\N	30324.29	23.9907	FINNHUB	2026-06-07 23:09:36.293802+00	\N
476	4530	2026-06-08	109.2700	\N	\N	30240.65	19.8429	FINNHUB	2026-06-07 23:09:39.602139+00	\N
477	4531	2026-06-08	83.4900	\N	\N	30206.26	\N	FINNHUB	2026-06-07 23:09:42.911691+00	\N
478	4532	2026-06-08	61.6700	\N	\N	30197.84	33.5013	FINNHUB	2026-06-07 23:09:46.215416+00	\N
479	4533	2026-06-08	47.6900	\N	\N	246955.66	6.4272	FINNHUB	2026-06-07 23:09:49.521264+00	\N
480	4534	2026-06-08	270.1000	\N	\N	216439.66	68.4287	FINNHUB	2026-06-07 23:09:52.851452+00	\N
481	4535	2026-06-08	279.0100	\N	\N	29980.56	18.0030	FINNHUB	2026-06-07 23:09:56.324981+00	\N
482	4536	2026-06-08	41.8200	\N	\N	29942.23	\N	FINNHUB	2026-06-07 23:09:59.607023+00	\N
483	4537	2026-06-08	101.6200	\N	\N	29798.26	14.3868	FINNHUB	2026-06-07 23:10:02.943879+00	\N
484	4538	2026-06-08	53.5800	\N	\N	29615.59	25.6190	FINNHUB	2026-06-07 23:10:06.223729+00	\N
485	4539	2026-06-08	142.0500	\N	\N	29736.64	64.3650	FINNHUB	2026-06-07 23:10:09.51181+00	\N
486	4540	2026-06-08	151.4500	\N	\N	29515.03	13.7471	FINNHUB	2026-06-07 23:10:12.826493+00	\N
487	4541	2026-06-08	281.9100	\N	\N	29502.95	23.8871	FINNHUB	2026-06-07 23:10:16.295577+00	\N
488	4542	2026-06-08	64.6700	\N	\N	29417.85	15.4020	FINNHUB	2026-06-07 23:10:19.596889+00	\N
489	4543	2026-06-08	54.4300	\N	\N	29025.02	9.0703	FINNHUB	2026-06-07 23:10:22.896642+00	\N
490	4544	2026-06-08	214.7600	\N	\N	28919.89	26.2534	FINNHUB	2026-06-07 23:10:26.222522+00	\N
491	4545	2026-06-08	195.3400	\N	\N	28839.43	21.0215	FINNHUB	2026-06-07 23:10:29.535293+00	\N
492	4546	2026-06-08	30.9600	\N	\N	28663.13	18.4542	FINNHUB	2026-06-07 23:10:32.843529+00	\N
493	4547	2026-06-08	55.9000	\N	\N	38937.88	21.6081	FINNHUB	2026-06-07 23:10:36.306821+00	\N
494	4548	2026-06-08	48.8200	\N	\N	39773.64	23.5347	FINNHUB	2026-06-07 23:10:39.765785+00	\N
495	4549	2026-06-08	170.2400	\N	\N	28416.43	21.1089	FINNHUB	2026-06-07 23:10:43.069335+00	\N
496	4550	2026-06-08	363.8900	\N	\N	28754.06	63.9009	FINNHUB	2026-06-07 23:10:46.398534+00	\N
497	4551	2026-06-08	196.0400	\N	\N	28436.86	18.7138	FINNHUB	2026-06-07 23:10:49.69959+00	\N
498	4552	2026-06-08	140.1000	\N	\N	28306.47	42.7074	FINNHUB	2026-06-07 23:10:52.999817+00	\N
499	4553	2026-06-08	72.2500	\N	\N	28274.09	48.1671	FINNHUB	2026-06-07 23:10:56.291633+00	\N
500	4554	2026-06-08	73.3300	\N	\N	28216.94	7.4668	FINNHUB	2026-06-07 23:10:59.591611+00	\N
501	4555	2026-06-08	350.7400	\N	\N	28210.70	\N	FINNHUB	2026-06-07 23:11:02.888661+00	\N
502	4556	2026-06-08	761.9100	\N	\N	28159.46	43.3175	FINNHUB	2026-06-07 23:11:06.193751+00	\N
503	4557	2026-06-08	72.8600	\N	\N	28114.70	30.2179	FINNHUB	2026-06-07 23:11:09.488205+00	\N
504	4558	2026-06-08	9.8000	\N	\N	118499.12	12.4187	FINNHUB	2026-06-07 23:11:12.799031+00	\N
505	4559	2026-06-08	66.8900	\N	\N	26572.30	15.5303	FINNHUB	2026-06-07 23:11:16.095889+00	\N
506	4560	2026-06-08	172.6100	\N	\N	28169.73	29.9152	FINNHUB	2026-06-07 23:11:19.426057+00	\N
507	4561	2026-06-08	42.6900	\N	\N	27926.49	26.0752	FINNHUB	2026-06-07 23:11:22.727016+00	\N
508	4562	2026-06-08	602.2700	\N	\N	27902.65	29.9064	FINNHUB	2026-06-07 23:11:26.032539+00	\N
509	4563	2026-06-08	228.8800	\N	\N	27470.55	18.4614	FINNHUB	2026-06-07 23:11:29.325134+00	\N
510	4564	2026-06-08	129.2000	\N	\N	27259.45	114.0563	FINNHUB	2026-06-07 23:11:32.694139+00	\N
511	4565	2026-06-08	15.1500	\N	\N	27195.23	\N	FINNHUB	2026-06-07 23:11:35.98053+00	\N
512	4566	2026-06-08	733.1400	\N	\N	27083.05	52.9921	FINNHUB	2026-06-07 23:11:39.289522+00	\N
513	4567	2026-06-08	189.7200	\N	\N	26915.97	23.6015	FINNHUB	2026-06-07 23:11:42.589778+00	\N
514	4568	2026-06-08	882.4300	\N	\N	27078.21	78.1151	FINNHUB	2026-06-07 23:11:45.895783+00	\N
515	4569	2026-06-08	63.9800	\N	\N	27055.99	13.6992	FINNHUB	2026-06-07 23:11:49.201944+00	\N
516	4570	2026-06-08	70.3400	\N	\N	26990.59	18.2246	FINNHUB	2026-06-07 23:11:52.486563+00	\N
517	4571	2026-06-08	35.7400	\N	\N	26889.00	22.0582	FINNHUB	2026-06-07 23:11:55.807547+00	\N
518	4572	2026-06-08	389.7900	\N	\N	26885.54	53.3839	FINNHUB	2026-06-07 23:11:59.274374+00	\N
519	4573	2026-06-08	294.9200	\N	\N	26837.72	31.9155	FINNHUB	2026-06-07 23:12:02.597359+00	\N
520	4574	2026-06-08	284.9500	\N	\N	26870.56	43.1937	FINNHUB	2026-06-07 23:12:05.904108+00	\N
521	4575	2026-06-08	46.4200	\N	\N	26850.78	25.2120	FINNHUB	2026-06-07 23:12:09.231693+00	\N
522	4076	2026-06-09	208.6400	1.7260	\N	5057195.00	31.6841	FINNHUB	2026-06-08 23:04:13.607526+00	\N
523	4077	2026-06-09	301.5400	-1.8872	\N	4542065.00	37.0554	FINNHUB	2026-06-08 23:04:17.031871+00	\N
524	4078	2026-06-09	363.3100	-1.4164	\N	4402106.50	27.4774	FINNHUB	2026-06-08 23:04:20.365799+00	\N
525	4079	2026-06-09	411.7400	-1.1832	\N	3064600.80	24.4745	FINNHUB	2026-06-08 23:04:23.909117+00	\N
526	4080	2026-06-09	245.2200	-0.3292	\N	2665181.50	29.3529	FINNHUB	2026-06-08 23:04:27.182539+00	\N
527	4081	2026-06-09	426.8000	2.8013	\N	61330052.00	31.7970	FINNHUB	2026-06-08 23:04:30.76555+00	\N
528	4082	2026-06-09	396.6000	2.8180	\N	1872561.20	63.8729	FINNHUB	2026-06-08 23:04:34.178248+00	\N
529	4083	2026-06-09	585.3900	-1.2833	\N	1505284.90	21.3252	FINNHUB	2026-06-08 23:04:37.474186+00	\N
530	4084	2026-06-09	408.9500	4.5908	\N	1468488.00	380.2403	FINNHUB	2026-06-08 23:04:40.774934+00	\N
531	4085	2026-06-09	487.0000	-0.2315	\N	1049438.20	14.4808	FINNHUB	2026-06-08 23:04:44.225009+00	\N
532	4086	2026-06-09	1149.1500	1.5671	\N	1092203.50	43.2099	FINNHUB	2026-06-08 23:04:47.967523+00	\N
533	4087	2026-06-09	949.2800	9.8691	\N	1068809.90	44.3287	FINNHUB	2026-06-08 23:04:51.287355+00	\N
534	4088	2026-06-09	119.8300	0.7991	\N	946056.50	41.6105	FINNHUB	2026-06-08 23:04:54.574624+00	\N
535	4089	2026-06-09	311.1100	-0.4034	\N	835538.60	14.1860	FINNHUB	2026-06-08 23:04:57.859394+00	\N
536	4090	2026-06-09	490.3300	5.1353	\N	799532.40	159.6192	FINNHUB	2026-06-08 23:05:01.135109+00	\N
537	4091	2026-06-09	1749.0400	6.5357	\N	558538.20	54.6889	FINNHUB	2026-06-08 23:05:04.625488+00	\N
538	4092	2026-06-09	151.7500	1.2207	\N	621410.50	24.5481	FINNHUB	2026-06-08 23:05:07.909572+00	\N
539	4093	2026-06-09	211.8200	-0.8705	\N	608628.80	37.5465	FINNHUB	2026-06-08 23:05:11.582622+00	\N
540	4094	2026-06-09	319.6700	-1.2053	\N	609646.25	27.4171	FINNHUB	2026-06-08 23:05:14.845284+00	\N
541	4095	2026-06-09	232.1600	-0.2621	\N	556307.90	26.4405	FINNHUB	2026-06-08 23:05:18.113779+00	\N
542	4096	2026-06-09	110.2700	11.1929	\N	558036.75	\N	FINNHUB	2026-06-08 23:05:21.386708+00	\N
543	4097	2026-06-09	124.1500	2.0635	\N	479436.12	40.0933	FINNHUB	2026-06-08 23:05:24.674763+00	\N
544	4098	2026-06-09	485.6700	-1.1017	\N	430331.84	27.6385	FINNHUB	2026-06-08 23:05:27.987447+00	\N
545	4099	2026-06-09	974.7500	0.2963	\N	433538.25	49.0539	FINNHUB	2026-06-08 23:05:31.299209+00	\N
546	4100	2026-06-09	915.6400	1.2562	\N	417277.28	44.2500	FINNHUB	2026-06-08 23:05:34.623567+00	\N
547	4101	2026-06-09	223.0700	-1.8307	\N	400355.25	110.1390	FINNHUB	2026-06-08 23:05:37.901661+00	\N
548	4102	2026-06-09	53.6300	-0.3715	\N	381299.80	12.0295	FINNHUB	2026-06-08 23:05:41.160319+00	\N
549	4103	2026-06-09	324.4500	6.9803	\N	402346.22	59.9783	FINNHUB	2026-06-08 23:05:44.456489+00	\N
550	4104	2026-06-09	189.2400	1.0304	\N	377467.53	34.2872	FINNHUB	2026-06-08 23:05:47.753862+00	\N
551	4105	2026-06-09	346.3900	1.0090	\N	418620.16	463.0754	FINNHUB	2026-06-08 23:05:51.012539+00	\N
552	4106	2026-06-09	406.5700	1.7774	\N	360052.00	29.8947	FINNHUB	2026-06-08 23:05:54.276507+00	\N
553	4107	2026-06-09	492.1700	8.6444	\N	384117.56	45.1478	FINNHUB	2026-06-08 23:05:57.604261+00	\N
554	4108	2026-06-09	82.6400	0.5597	\N	346611.88	25.9175	FINNHUB	2026-06-08 23:06:00.858751+00	\N
555	4109	2026-06-09	322.0400	-1.8171	\N	337373.53	39.0931	FINNHUB	2026-06-08 23:06:04.223294+00	\N
556	4110	2026-06-09	79.5400	0.0755	\N	341057.78	24.8929	FINNHUB	2026-06-08 23:06:07.570309+00	\N
557	4111	2026-06-09	145.1000	-0.9827	\N	338368.72	20.3640	FINNHUB	2026-06-08 23:06:11.389137+00	\N
558	4112	2026-06-09	212.2400	0.1463	\N	337349.70	18.6247	FINNHUB	2026-06-08 23:06:14.68228+00	\N
559	4113	2026-06-09	136.4700	0.6936	\N	324907.72	142.4079	FINNHUB	2026-06-08 23:06:17.930804+00	\N
560	4114	2026-06-09	1045.0000	0.6085	\N	311831.72	17.2588	FINNHUB	2026-06-08 23:06:21.226363+00	\N
561	4115	2026-06-09	91.5300	0.8040	\N	233833.94	13.9867	FINNHUB	2026-06-08 23:06:24.523167+00	\N
562	4116	2026-06-09	309.7100	-0.3443	\N	310586.90	22.1658	FINNHUB	2026-06-08 23:06:27.791829+00	\N
563	4117	2026-06-09	119.5200	-1.0514	\N	296971.70	33.2369	FINNHUB	2026-06-08 23:06:31.061337+00	\N
564	4118	2026-06-09	181.5500	-2.3662	\N	214918.50	27.6012	FINNHUB	2026-06-08 23:06:34.448558+00	\N
565	4119	2026-06-09	176.0600	-1.2508	\N	277875.47	25.0429	FINNHUB	2026-06-08 23:06:37.746026+00	\N
566	4120	2026-06-09	120.0700	-0.8178	\N	299809.00	19.2069	FINNHUB	2026-06-08 23:06:40.998233+00	\N
567	4121	2026-06-09	146.4200	-1.8370	\N	211478.11	19.6229	FINNHUB	2026-06-08 23:06:44.385383+00	\N
568	4122	2026-06-09	195.3200	0.6597	\N	377922.62	17.0712	FINNHUB	2026-06-08 23:06:47.656001+00	\N
569	4123	2026-06-09	280.8200	-1.4113	\N	263816.38	24.5365	FINNHUB	2026-06-08 23:06:50.990013+00	\N
570	4124	2026-06-09	290.9000	2.0487	\N	265064.53	49.3878	FINNHUB	2026-06-08 23:06:54.267518+00	\N
571	4125	2026-06-09	400.7700	1.6177	\N	261472.17	31.0943	FINNHUB	2026-06-08 23:06:57.517353+00	\N
572	4126	2026-06-09	2108.0600	9.2712	\N	275370.62	58.9588	FINNHUB	2026-06-08 23:07:00.865887+00	\N
573	4127	2026-06-09	933.8500	0.0257	\N	250879.69	26.7634	FINNHUB	2026-06-08 23:07:04.292921+00	\N
574	4128	2026-06-09	80.9600	-1.1960	\N	250751.92	11.5570	FINNHUB	2026-06-08 23:07:07.541425+00	\N
575	4129	2026-06-09	178.6600	-1.2874	\N	243736.22	33.5910	FINNHUB	2026-06-08 23:07:10.82016+00	\N
576	4130	2026-06-09	86.6500	1.4637	\N	179401.23	12.7666	FINNHUB	2026-06-08 23:07:14.090837+00	\N
577	4131	2026-06-09	501.9200	-1.1774	\N	232187.95	32.7856	FINNHUB	2026-06-08 23:07:17.458342+00	\N
578	4132	2026-06-09	178.4500	0.7282	\N	33747004.00	8.7698	FINNHUB	2026-06-08 23:07:20.724214+00	\N
579	4133	2026-06-09	1642.0000	5.3023	\N	230919.34	51.2357	FINNHUB	2026-06-08 23:07:23.981603+00	\N
580	4134	2026-06-09	288.8500	9.6330	\N	253536.72	100.3430	FINNHUB	2026-06-08 23:07:27.268669+00	\N
581	4135	2026-06-09	217.7700	0.8475	\N	229882.67	23.1667	FINNHUB	2026-06-08 23:07:30.532511+00	\N
582	4136	2026-06-09	19.9200	0.0502	\N	35994856.00	14.8296	FINNHUB	2026-06-08 23:07:33.813315+00	\N
583	4137	2026-06-09	133.2800	0.6115	\N	227173.78	14.1753	FINNHUB	2026-06-08 23:07:37.067074+00	\N
584	4138	2026-06-09	266.3300	-2.1026	\N	221720.73	263.0763	FINNHUB	2026-06-08 23:07:40.333714+00	\N
585	4139	2026-06-09	83.7000	1.1847	\N	311141.47	21.4414	FINNHUB	2026-06-08 23:07:43.741526+00	\N
586	4140	2026-06-09	181.9200	-1.5425	\N	188537.42	25.7811	FINNHUB	2026-06-08 23:07:47.635529+00	\N
587	4141	2026-06-09	312.3000	0.5279	\N	213465.83	19.0255	FINNHUB	2026-06-08 23:07:50.937985+00	\N
588	4142	2026-06-09	277.7800	-0.7361	\N	197428.27	22.7531	FINNHUB	2026-06-08 23:07:54.233667+00	\N
589	4143	2026-06-09	88.6300	-0.0902	\N	172297.33	13.1609	FINNHUB	2026-06-08 23:07:57.732879+00	\N
590	4144	2026-06-09	41.0200	-4.5158	\N	1261429.40	10.3432	FINNHUB	2026-06-08 23:08:01.078376+00	\N
591	4145	2026-06-09	403.8900	0.6228	\N	198592.70	59.9356	FINNHUB	2026-06-08 23:08:04.519958+00	\N
592	4146	2026-06-09	156.4000	1.3807	\N	194773.47	52.3514	FINNHUB	2026-06-08 23:08:07.858452+00	\N
593	4147	2026-06-09	140.6800	-0.8737	\N	192242.81	22.0134	FINNHUB	2026-06-08 23:08:11.122547+00	\N
594	4148	2026-06-09	178.4300	0.1853	\N	193660.55	18.3686	FINNHUB	2026-06-08 23:08:14.381552+00	\N
595	4149	2026-06-09	876.7700	3.4574	\N	190027.34	79.9106	FINNHUB	2026-06-08 23:08:17.665985+00	\N
596	4150	2026-06-09	45.4400	0.1543	\N	189445.10	10.9253	FINNHUB	2026-06-08 23:08:20.937244+00	\N
597	4151	2026-06-09	345.7300	-1.1013	\N	188344.69	24.1468	FINNHUB	2026-06-08 23:08:24.234099+00	\N
598	4152	2026-06-09	563.6900	1.1648	\N	187185.77	47.2340	FINNHUB	2026-06-08 23:08:27.490504+00	\N
599	4153	2026-06-09	114.1700	0.8925	\N	266501.10	17.8740	FINNHUB	2026-06-08 23:08:30.818869+00	\N
600	4154	2026-06-09	84.0100	-2.1319	\N	178004.75	21.7530	FINNHUB	2026-06-08 23:08:34.178897+00	\N
601	4155	2026-06-09	159.7500	-0.5973	\N	177537.06	30.6627	FINNHUB	2026-06-08 23:08:37.458564+00	\N
602	4156	2026-06-09	12.1600	0.0823	\N	156628.03	9.6959	FINNHUB	2026-06-08 23:08:40.726903+00	\N
603	4157	2026-06-09	526.9300	2.9723	\N	176380.75	27.0897	FINNHUB	2026-06-08 23:08:44.034111+00	\N
604	4158	2026-06-09	100.9300	0.2384	\N	131691.10	17.6305	FINNHUB	2026-06-08 23:08:47.319543+00	\N
605	4159	2026-06-09	469.6300	-0.6705	\N	175546.55	25.6422	FINNHUB	2026-06-08 23:08:50.733726+00	\N
606	4160	2026-06-09	98.8700	-0.8424	\N	171619.42	15.2904	FINNHUB	2026-06-08 23:08:54.024433+00	\N
607	4161	2026-06-09	658.7900	-1.8226	\N	167704.77	\N	FINNHUB	2026-06-08 23:08:57.2902+00	\N
608	4162	2026-06-09	143.6000	3.4508	\N	176760.10	39.5835	FINNHUB	2026-06-08 23:09:00.569284+00	\N
609	4163	2026-06-09	215.9200	0.2181	\N	169847.61	74.8887	FINNHUB	2026-06-08 23:09:03.893538+00	\N
610	4164	2026-06-09	994.7700	-0.0834	\N	162124.40	25.9192	FINNHUB	2026-06-08 23:09:07.173193+00	\N
611	4165	2026-06-09	268.6700	-1.3403	\N	156680.90	21.7220	FINNHUB	2026-06-08 23:09:10.447412+00	\N
612	4166	2026-06-09	128.1000	-0.8207	\N	158300.16	17.1748	FINNHUB	2026-06-08 23:09:13.809572+00	\N
613	4167	2026-06-09	90.5000	-0.6259	\N	157912.89	25.1614	FINNHUB	2026-06-08 23:09:17.0981+00	\N
614	4168	2026-06-09	22.5000	-1.0989	\N	157345.14	7.3419	FINNHUB	2026-06-08 23:09:20.377252+00	\N
615	4169	2026-06-09	573.6600	-1.6763	\N	158271.06	33.0903	FINNHUB	2026-06-08 23:09:23.652891+00	\N
616	4170	2026-06-09	88.0800	-0.8555	\N	153965.66	16.3411	FINNHUB	2026-06-08 23:09:26.932263+00	\N
617	4171	2026-06-09	403.1400	1.8185	\N	157280.90	39.4089	FINNHUB	2026-06-08 23:09:30.401169+00	\N
618	4172	2026-06-09	187.5400	5.6087	\N	162974.69	90.0413	FINNHUB	2026-06-08 23:09:33.695348+00	\N
619	4173	2026-06-09	78.6600	0.2038	\N	134027.83	21.2940	FINNHUB	2026-06-08 23:09:37.014906+00	\N
620	4174	2026-06-09	182.5500	-1.6751	\N	149455.22	18.6283	FINNHUB	2026-06-08 23:09:40.273593+00	\N
621	4175	2026-06-09	418.6100	-0.8174	\N	148909.53	49.9847	FINNHUB	2026-06-08 23:09:43.558969+00	\N
622	4176	2026-06-09	25.6200	-1.6129	\N	146447.22	19.5498	FINNHUB	2026-06-08 23:09:46.818344+00	\N
623	4177	2026-06-09	23.2400	0.3454	\N	23778718.00	15.0215	FINNHUB	2026-06-08 23:09:50.152306+00	\N
624	4178	2026-06-09	200.0000	-3.3490	\N	146074.86	103.7788	FINNHUB	2026-06-08 23:09:53.418945+00	\N
625	4179	2026-06-09	170.4800	-1.4396	\N	144405.10	29.0805	FINNHUB	2026-06-08 23:09:56.695307+00	\N
626	4180	2026-06-09	47.2900	0.5956	\N	113789.34	15.6755	FINNHUB	2026-06-08 23:10:00.48635+00	\N
627	4181	2026-06-09	70.0600	-0.9192	\N	146624.19	17.1691	FINNHUB	2026-06-08 23:10:03.793175+00	\N
628	4182	2026-06-09	118.8900	1.4939	\N	145004.39	19.8039	FINNHUB	2026-06-08 23:10:07.117684+00	\N
629	4183	2026-06-09	110.7800	1.1320	\N	143611.44	107.8164	FINNHUB	2026-06-08 23:10:10.375946+00	\N
630	4184	2026-06-09	114.1900	-1.0056	\N	139484.70	45.6714	FINNHUB	2026-06-08 23:10:13.631498+00	\N
631	4185	2026-06-09	142.7800	-1.2177	\N	137159.11	36.8980	FINNHUB	2026-06-08 23:10:16.969984+00	\N
632	4186	2026-06-09	211.8000	-1.0142	\N	135582.77	30.0560	FINNHUB	2026-06-08 23:10:20.233552+00	\N
633	4187	2026-06-09	22.1500	1.1878	\N	20976390.00	\N	FINNHUB	2026-06-08 23:10:23.553104+00	\N
634	4188	2026-06-09	183.5300	-0.4178	\N	130658.00	35.4183	FINNHUB	2026-06-08 23:10:26.850701+00	\N
635	4189	2026-06-09	162.3000	-2.1346	\N	126560.89	20.5656	FINNHUB	2026-06-08 23:10:30.108011+00	\N
636	4190	2026-06-09	59.6900	-0.0502	\N	101045.34	13.0146	FINNHUB	2026-06-08 23:10:33.368138+00	\N
637	4191	2026-06-09	321.8800	-1.3455	\N	125426.20	11.1006	FINNHUB	2026-06-08 23:10:36.808307+00	\N
638	4192	2026-06-09	417.0900	-1.7317	\N	123580.00	25.8698	FINNHUB	2026-06-08 23:10:41.479262+00	\N
639	4193	2026-06-09	22.3700	0.6751	\N	109077.45	10.0970	FINNHUB	2026-06-08 23:10:44.751334+00	\N
640	4194	2026-06-09	55.3300	-1.7404	\N	171507.53	24.8382	FINNHUB	2026-06-08 23:10:48.327451+00	\N
641	4195	2026-06-09	97.0800	1.1988	\N	121697.94	41.5068	FINNHUB	2026-06-08 23:10:51.597267+00	\N
642	4196	2026-06-09	56.0900	-1.1107	\N	88142.96	10.7777	FINNHUB	2026-06-08 23:10:54.954683+00	\N
643	4197	2026-06-09	82.6200	-2.8800	\N	121088.34	8.5892	FINNHUB	2026-06-08 23:10:58.285407+00	\N
644	4198	2026-06-09	520.0700	-0.7045	\N	119506.89	24.9336	FINNHUB	2026-06-08 23:11:01.613023+00	\N
645	4199	2026-06-09	23.0100	-1.7087	\N	11507407.00	15.1362	FINNHUB	2026-06-08 23:11:04.942347+00	\N
646	4200	2026-06-09	71.2900	-1.2467	\N	119405.58	14.8275	FINNHUB	2026-06-08 23:11:08.278528+00	\N
647	4201	2026-06-09	200.2600	-1.8430	\N	119216.32	10.3137	FINNHUB	2026-06-08 23:11:11.625596+00	\N
648	4202	2026-06-09	207.9700	-1.3144	\N	117571.87	17.7013	FINNHUB	2026-06-08 23:11:14.911855+00	\N
649	4203	2026-06-09	9.5900	0.7353	\N	18815406.00	15.0688	FINNHUB	2026-06-08 23:11:18.206448+00	\N
650	4204	2026-06-09	301.5300	-1.3512	\N	115851.62	34.7173	FINNHUB	2026-06-08 23:11:21.469753+00	\N
651	4205	2026-06-09	55.5700	-2.9684	\N	114213.05	19.1097	FINNHUB	2026-06-08 23:11:24.739629+00	\N
652	4206	2026-06-09	114.1900	1.5474	\N	115970.58	66.0049	FINNHUB	2026-06-08 23:11:27.98878+00	\N
653	4207	2026-06-09	300.5700	0.0200	\N	115428.53	74.0686	FINNHUB	2026-06-08 23:11:31.246557+00	\N
654	4208	2026-06-09	164.5900	0.1338	\N	161881.25	16.6356	FINNHUB	2026-06-08 23:11:34.529646+00	\N
655	4209	2026-06-09	442.9600	-0.8661	\N	113407.88	26.1411	FINNHUB	2026-06-08 23:11:37.794691+00	\N
656	4210	2026-06-09	43.7200	1.7454	\N	84358.88	35.0634	FINNHUB	2026-06-08 23:11:41.15427+00	\N
657	4211	2026-06-09	180.3900	-0.1550	\N	112466.98	34.8951	FINNHUB	2026-06-08 23:11:47.978281+00	\N
658	4212	2026-06-09	883.1400	0.0907	\N	111107.33	31.9258	FINNHUB	2026-06-08 23:11:51.25118+00	\N
659	4213	2026-06-09	17.7500	0.0000	\N	557362.06	5.1808	FINNHUB	2026-06-08 23:11:54.536803+00	\N
660	4214	2026-06-09	15.9000	0.3155	\N	557362.06	5.1808	FINNHUB	2026-06-08 23:11:57.878227+00	\N
661	4215	2026-06-09	174.4300	-2.1431	\N	108697.95	14.2121	FINNHUB	2026-06-08 23:12:01.184174+00	\N
662	4216	2026-06-09	94.8200	-0.4932	\N	108488.04	72.5333	FINNHUB	2026-06-08 23:12:04.733842+00	\N
663	4217	2026-06-09	43.8800	-2.5322	\N	92175.07	7.5374	FINNHUB	2026-06-08 23:12:08.053256+00	\N
664	4218	2026-06-09	1062.7400	-1.6846	\N	104811.93	73.7074	FINNHUB	2026-06-08 23:12:11.352623+00	\N
665	4219	2026-06-09	98.9900	-0.7221	\N	106445.69	12.5882	FINNHUB	2026-06-08 23:12:14.65637+00	\N
666	4220	2026-06-09	143.0400	-1.1335	\N	105904.32	54.1849	FINNHUB	2026-06-08 23:12:17.939811+00	\N
667	4221	2026-06-09	80.6900	-1.2000	\N	103147.32	21.4801	FINNHUB	2026-06-08 23:12:21.30332+00	\N
668	4222	2026-06-09	91.2800	-1.4255	\N	102753.50	23.5511	FINNHUB	2026-06-08 23:12:24.59795+00	\N
669	4223	2026-06-09	49.8800	-1.1886	\N	102753.50	23.5511	FINNHUB	2026-06-08 23:12:27.876736+00	\N
670	4224	2026-06-09	693.8100	-0.1870	\N	104645.95	94.7241	FINNHUB	2026-06-08 23:12:31.199801+00	\N
671	4225	2026-06-09	394.2400	4.7981	\N	106854.57	91.2531	FINNHUB	2026-06-08 23:12:34.459742+00	\N
672	4226	2026-06-09	391.4200	-0.2777	\N	103550.52	40.0737	FINNHUB	2026-06-08 23:12:37.786502+00	\N
673	4227	2026-06-09	50.6400	-1.7081	\N	77722.63	13.3338	FINNHUB	2026-06-08 23:12:41.07972+00	\N
674	4228	2026-06-09	503.1300	1.2436	\N	103832.23	33.2700	FINNHUB	2026-06-08 23:12:44.446526+00	\N
675	4229	2026-06-09	244.9900	-2.5652	\N	101632.06	14.0999	FINNHUB	2026-06-08 23:12:47.750832+00	\N
676	4230	2026-06-09	458.9200	0.4553	\N	100986.98	34.8459	FINNHUB	2026-06-08 23:12:51.062995+00	\N
677	4231	2026-06-09	246.5500	-2.1239	\N	100787.08	57.7908	FINNHUB	2026-06-08 23:12:54.367668+00	\N
678	4232	2026-06-09	109.5200	0.6248	\N	140724.34	14.3333	FINNHUB	2026-06-08 23:12:57.776268+00	\N
679	4233	2026-06-09	44.2300	-0.8296	\N	98683.50	73.8649	FINNHUB	2026-06-08 23:13:01.043777+00	\N
680	4234	2026-06-09	80.9300	0.4593	\N	138487.53	14.5043	FINNHUB	2026-06-08 23:13:04.526554+00	\N
681	4235	2026-06-09	141.7800	-0.4284	\N	98165.94	\N	FINNHUB	2026-06-08 23:13:07.78082+00	\N
682	4236	2026-06-09	122.0500	-1.7469	\N	96693.32	18.8156	FINNHUB	2026-06-08 23:13:11.07063+00	\N
683	4237	2026-06-09	46.2900	1.2910	\N	133001.56	13.6974	FINNHUB	2026-06-08 23:13:14.449497+00	\N
684	4238	2026-06-09	25.7000	-0.9634	\N	9050747.00	16.6964	FINNHUB	2026-06-08 23:13:17.77524+00	\N
685	4239	2026-06-09	340.8600	-1.6107	\N	92390.31	21.2832	FINNHUB	2026-06-08 23:13:21.204971+00	\N
686	4240	2026-06-09	37.6000	1.7867	\N	897358.00	17.1762	FINNHUB	2026-06-08 23:13:24.491312+00	\N
687	4241	2026-06-09	252.0300	-2.0862	\N	91010.18	21.3124	FINNHUB	2026-06-08 23:13:27.75905+00	\N
688	4242	2026-06-09	766.6400	-1.1629	\N	92507.84	19.4263	FINNHUB	2026-06-08 23:13:31.050824+00	\N
689	4243	2026-06-09	229.0750	-1.2395	\N	91695.05	21.1012	FINNHUB	2026-06-08 23:13:34.340176+00	\N
690	4244	2026-06-09	107.7000	-0.7739	\N	92259.69	17.5766	FINNHUB	2026-06-08 23:13:37.655967+00	\N
691	4245	2026-06-09	227.1400	-0.5386	\N	91884.01	12.7351	FINNHUB	2026-06-08 23:13:40.935978+00	\N
692	4246	2026-06-09	63.9100	0.8521	\N	92471.03	33.8350	FINNHUB	2026-06-08 23:13:44.278297+00	\N
693	4247	2026-06-09	250.6700	-1.6325	\N	92042.06	24.2791	FINNHUB	2026-06-08 23:13:47.532638+00	\N
694	4248	2026-06-09	189.1000	-2.5860	\N	88342.64	30.4598	FINNHUB	2026-06-08 23:13:50.995658+00	\N
695	4249	2026-06-09	418.1500	0.6305	\N	90850.96	17.3280	FINNHUB	2026-06-08 23:13:54.308077+00	\N
696	4250	2026-06-09	672.6800	3.2954	\N	92959.09	34.7771	FINNHUB	2026-06-08 23:13:57.597817+00	\N
697	4251	2026-06-09	473.4800	1.8565	\N	89350.00	115.5486	FINNHUB	2026-06-08 23:14:00.941228+00	\N
698	4252	2026-06-09	216.1400	-1.9328	\N	88507.30	31.6776	FINNHUB	2026-06-08 23:14:04.319507+00	\N
699	4253	2026-06-09	247.7900	-0.9276	\N	87585.41	\N	FINNHUB	2026-06-08 23:14:07.585537+00	\N
700	4254	2026-06-09	71.5900	-0.5142	\N	88006.95	31.5211	FINNHUB	2026-06-08 23:14:10.85932+00	\N
701	4255	2026-06-09	144.0500	0.2785	\N	88033.58	24.9316	FINNHUB	2026-06-08 23:14:14.235159+00	\N
702	4256	2026-06-09	88.4700	-1.2060	\N	87564.98	43.0946	FINNHUB	2026-06-08 23:14:17.537115+00	\N
703	4257	2026-06-09	47.1100	0.2554	\N	87564.80	28.7098	FINNHUB	2026-06-08 23:14:21.222691+00	\N
704	4258	2026-06-09	55.3500	-0.6105	\N	86447.56	11.0745	FINNHUB	2026-06-08 23:14:24.492875+00	\N
705	4259	2026-06-09	29.1100	-1.8874	\N	73618.45	7.6123	FINNHUB	2026-06-08 23:14:27.79377+00	\N
706	4260	2026-06-09	23.7600	-0.2519	\N	84501.06	4.4955	FINNHUB	2026-06-08 23:14:31.083964+00	\N
707	4261	2026-06-09	7.4300	-1.4589	\N	436388.72	12.5223	FINNHUB	2026-06-08 23:14:34.547124+00	\N
708	4262	2026-06-09	14.5900	1.4604	\N	73006.20	93.4778	FINNHUB	2026-06-08 23:14:38.191908+00	\N
709	4263	2026-06-09	93.2100	-0.2034	\N	83861.33	28.3161	FINNHUB	2026-06-08 23:14:41.464767+00	\N
710	4264	2026-06-09	231.6800	-1.0380	\N	82468.86	607.8502	FINNHUB	2026-06-08 23:14:44.765875+00	\N
711	4265	2026-06-09	24.2300	-0.1648	\N	61971.29	5.6032	FINNHUB	2026-06-08 23:14:48.058106+00	\N
712	4266	2026-06-09	240.4500	0.9192	\N	82580.91	\N	FINNHUB	2026-06-08 23:14:51.331739+00	\N
713	4267	2026-06-09	361.3200	-2.9049	\N	79794.66	11.7449	FINNHUB	2026-06-08 23:14:54.593396+00	\N
714	4268	2026-06-09	56.5500	3.0618	\N	85293.04	25.6212	FINNHUB	2026-06-08 23:14:57.865162+00	\N
715	4269	2026-06-09	162.1100	-0.9471	\N	114235.63	15.3365	FINNHUB	2026-06-08 23:15:01.509506+00	\N
716	4270	2026-06-09	37.5200	-0.7670	\N	81802.63	13.8578	FINNHUB	2026-06-08 23:15:04.847637+00	\N
717	4271	2026-06-09	1611.9900	0.2606	\N	80392.05	41.8709	FINNHUB	2026-06-08 23:15:08.114225+00	\N
718	4272	2026-06-09	305.5100	2.9485	\N	80467.74	17.5540	FINNHUB	2026-06-08 23:15:11.414032+00	\N
719	4273	2026-06-09	80.1700	-2.0645	\N	60579.28	18.6915	FINNHUB	2026-06-08 23:15:14.672762+00	\N
720	4274	2026-06-09	35.5200	4.3785	\N	2531813.80	53.5800	FINNHUB	2026-06-08 23:15:18.299801+00	\N
721	4275	2026-06-09	153.8500	0.0585	\N	81095.88	29.0979	FINNHUB	2026-06-08 23:15:21.559712+00	\N
722	4276	2026-06-09	139.0500	-1.7314	\N	79160.45	20.1375	FINNHUB	2026-06-08 23:15:24.823258+00	\N
723	4277	2026-06-09	207.3400	-1.4122	\N	67173.38	14.3121	FINNHUB	2026-06-08 23:15:28.095195+00	\N
724	4278	2026-06-09	54.3200	0.9665	\N	68878.98	15.3679	FINNHUB	2026-06-08 23:15:31.393329+00	\N
725	4279	2026-06-09	90.0500	0.1334	\N	111313.27	27.3027	FINNHUB	2026-06-08 23:15:34.68867+00	\N
726	4280	2026-06-09	162.5200	-1.7650	\N	77995.31	19.8714	FINNHUB	2026-06-08 23:15:37.975133+00	\N
727	4281	2026-06-09	61.6000	-0.7092	\N	79663.31	30.4640	FINNHUB	2026-06-08 23:15:41.281549+00	\N
728	4282	2026-06-09	134.4300	0.6665	\N	80485.21	31.9766	FINNHUB	2026-06-08 23:15:44.523926+00	\N
729	4283	2026-06-09	330.2200	-0.2357	\N	78710.40	17.5536	FINNHUB	2026-06-08 23:15:47.802041+00	\N
730	4284	2026-06-09	443.7600	-1.6816	\N	77986.08	31.2569	FINNHUB	2026-06-08 23:15:51.156057+00	\N
731	4285	2026-06-09	340.6300	-0.7199	\N	77641.76	50.3513	FINNHUB	2026-06-08 23:15:54.444778+00	\N
732	4286	2026-06-09	139.0700	0.6878	\N	78257.16	32.0201	FINNHUB	2026-06-08 23:15:57.731962+00	\N
733	4287	2026-06-09	540.8100	-0.6594	\N	75894.16	16.5853	FINNHUB	2026-06-08 23:16:01.029308+00	\N
734	4288	2026-06-09	5.3000	-0.1883	\N	57768.88	9.1828	FINNHUB	2026-06-08 23:16:04.508443+00	\N
735	4289	2026-06-09	118.7000	-0.6528	\N	75062.04	14.9202	FINNHUB	2026-06-08 23:16:07.8975+00	\N
736	4290	2026-06-09	289.6100	0.0449	\N	76259.41	12.1278	FINNHUB	2026-06-08 23:16:11.191304+00	\N
737	4291	2026-06-09	266.1700	1.5877	\N	76490.31	16.5135	FINNHUB	2026-06-08 23:16:14.549592+00	\N
738	4292	2026-06-09	258.3900	1.0046	\N	75961.35	18.0602	FINNHUB	2026-06-08 23:16:18.233286+00	\N
739	4293	2026-06-09	272.0000	-2.8571	\N	75094.59	16.7659	FINNHUB	2026-06-08 23:16:21.503285+00	\N
740	4294	2026-06-09	253.5700	-3.8087	\N	71395.41	11834.1472	FINNHUB	2026-06-08 23:16:24.754614+00	\N
741	4295	2026-06-09	299.5500	-1.8834	\N	73815.57	28.3982	FINNHUB	2026-06-08 23:16:28.021297+00	\N
742	4296	2026-06-09	89.0200	-1.4502	\N	74410.33	28.5764	FINNHUB	2026-06-08 23:16:31.29107+00	\N
743	4297	2026-06-09	301.1400	1.7502	\N	74721.34	28.1648	FINNHUB	2026-06-08 23:16:34.637973+00	\N
744	4298	2026-06-09	24.8600	0.0805	\N	1321162.90	15.0960	FINNHUB	2026-06-08 23:16:37.925282+00	\N
745	4299	2026-06-09	85.0400	3.1163	\N	74330.65	39.1833	FINNHUB	2026-06-08 23:16:41.263729+00	\N
746	4300	2026-06-09	83.7700	2.0217	\N	74035.73	29.1709	FINNHUB	2026-06-08 23:16:44.514433+00	\N
747	4301	2026-06-09	227.4200	-1.2805	\N	73670.58	31.8127	FINNHUB	2026-06-08 23:16:47.842256+00	\N
748	4302	2026-06-09	45.9700	-0.4547	\N	73739.60	29.2501	FINNHUB	2026-06-08 23:16:51.109935+00	\N
749	4303	2026-06-09	127.5700	-0.3593	\N	73811.54	64.5206	FINNHUB	2026-06-08 23:16:54.380325+00	\N
750	4304	2026-06-09	401.9300	6.6156	\N	76494.98	163.1548	FINNHUB	2026-06-08 23:16:57.752346+00	\N
751	4305	2026-06-09	63.2500	1.6554	\N	103083.22	16.2874	FINNHUB	2026-06-08 23:17:01.077253+00	\N
752	4306	2026-06-09	69.4500	4.4204	\N	76120.41	52.8247	FINNHUB	2026-06-08 23:17:04.419391+00	\N
753	4307	2026-06-09	183.4200	0.1857	\N	73403.19	17.8033	FINNHUB	2026-06-08 23:17:07.661426+00	\N
754	4308	2026-06-09	140.1500	1.7201	\N	74757.07	13.5996	FINNHUB	2026-06-08 23:17:10.941536+00	\N
755	4309	2026-06-09	120.8100	0.3572	\N	101872.40	21.6519	FINNHUB	2026-06-08 23:17:14.234005+00	\N
756	4310	2026-06-09	1559.1800	5.2753	\N	75392.45	110.7218	FINNHUB	2026-06-08 23:17:17.495242+00	\N
757	4311	2026-06-09	252.3900	-0.1306	\N	73084.44	23.3199	FINNHUB	2026-06-08 23:17:22.847195+00	\N
758	4312	2026-06-09	257.4100	-0.2171	\N	72274.56	34.3233	FINNHUB	2026-06-08 23:17:26.226348+00	\N
759	4313	2026-06-09	48.7000	0.3090	\N	72340.90	20.2920	FINNHUB	2026-06-08 23:17:29.528205+00	\N
760	4314	2026-06-09	173.6450	-3.4501	\N	70495.35	36.3897	FINNHUB	2026-06-08 23:17:32.931902+00	\N
761	4315	2026-06-09	68.2500	-0.6261	\N	95830.00	27.8576	FINNHUB	2026-06-08 23:17:36.254402+00	\N
762	4316	2026-06-09	86.0700	-2.8336	\N	69264.39	33.1885	FINNHUB	2026-06-08 23:17:39.539814+00	\N
763	4317	2026-06-09	31.2900	-1.2311	\N	69703.79	21.0268	FINNHUB	2026-06-08 23:17:42.84491+00	\N
764	4318	2026-06-09	309.9300	-1.1230	\N	69844.24	26.1589	FINNHUB	2026-06-08 23:17:46.139375+00	\N
765	4319	2026-06-09	126.7700	-1.8352	\N	70265.73	19.2309	FINNHUB	2026-06-08 23:17:49.502988+00	\N
766	4320	2026-06-09	101.5300	-3.3600	\N	69158.72	18.8392	FINNHUB	2026-06-08 23:17:52.821535+00	\N
767	4321	2026-06-09	325.8500	-0.8158	\N	69592.98	17.6542	FINNHUB	2026-06-08 23:17:56.167293+00	\N
768	4322	2026-06-09	1206.2800	-2.6204	\N	67781.71	32.5561	FINNHUB	2026-06-08 23:17:59.466861+00	\N
769	4323	2026-06-09	466.6700	-4.4120	\N	66245.35	151.1416	FINNHUB	2026-06-08 23:18:02.768194+00	\N
770	4324	2026-06-09	152.4900	-2.7487	\N	68320.70	73.7805	FINNHUB	2026-06-08 23:18:06.095195+00	\N
771	4325	2026-06-09	406.8000	-0.8627	\N	66932.73	32.0252	FINNHUB	2026-06-08 23:18:09.408659+00	\N
772	4326	2026-06-09	895.4000	3.6751	\N	69119.08	157.1245	FINNHUB	2026-06-08 23:18:12.703947+00	\N
773	4327	2026-06-09	1084.0500	1.5247	\N	66892.12	26.6821	FINNHUB	2026-06-08 23:18:15.994539+00	\N
774	4328	2026-06-09	182.1500	-2.4841	\N	65472.22	47.5163	FINNHUB	2026-06-08 23:18:19.622602+00	\N
775	4329	2026-06-09	19.3400	-0.2579	\N	66724.08	15.2897	FINNHUB	2026-06-08 23:18:22.883789+00	\N
776	4330	2026-06-09	39.4600	0.0000	\N	91994.04	10.7791	FINNHUB	2026-06-08 23:18:26.186076+00	\N
777	4331	2026-06-09	26.4700	0.8765	\N	65787.27	\N	FINNHUB	2026-06-08 23:18:29.472661+00	\N
778	4332	2026-06-09	14.9900	-1.5758	\N	367651.22	23.5629	FINNHUB	2026-06-08 23:18:32.746206+00	\N
779	4333	2026-06-09	49.8700	1.3618	\N	65781.93	42.2763	FINNHUB	2026-06-08 23:18:36.117486+00	\N
780	4334	2026-06-09	1852.0300	0.4387	\N	64429.41	52.6536	FINNHUB	2026-06-08 23:18:39.413591+00	\N
781	4335	2026-06-09	38.8900	0.4650	\N	90544.13	14.1078	FINNHUB	2026-06-08 23:18:42.714559+00	\N
782	4336	2026-06-09	611.3400	-3.7942	\N	66258.27	14.9790	FINNHUB	2026-06-08 23:18:45.981455+00	\N
783	4337	2026-06-09	204.9300	-2.4329	\N	63606.47	29.3253	FINNHUB	2026-06-08 23:18:49.25509+00	\N
784	4338	2026-06-09	296.7300	-2.1500	\N	63306.45	8.3254	FINNHUB	2026-06-08 23:18:52.582502+00	\N
785	4339	2026-06-09	75.0100	6.0662	\N	56047.14	216.0293	FINNHUB	2026-06-08 23:18:55.851618+00	\N
786	4340	2026-06-09	113.6500	3.2431	\N	63721.73	\N	FINNHUB	2026-06-08 23:18:59.105606+00	\N
787	4341	2026-06-09	43.2300	0.5817	\N	63826.24	28.3672	FINNHUB	2026-06-08 23:19:02.373113+00	\N
788	4342	2026-06-09	15.9100	0.7600	\N	47890.68	7.9898	FINNHUB	2026-06-08 23:19:05.730777+00	\N
789	4343	2026-06-09	276.7700	-1.9763	\N	62958.52	29.8764	FINNHUB	2026-06-08 23:19:09.014662+00	\N
790	4344	2026-06-09	64.8400	3.5948	\N	64325.73	20.6437	FINNHUB	2026-06-08 23:19:12.289943+00	\N
791	4345	2026-06-09	205.6100	-3.3106	\N	59832.80	20.5894	FINNHUB	2026-06-08 23:19:15.552678+00	\N
792	4346	2026-06-09	34.5200	-1.7923	\N	46125.85	22.3370	FINNHUB	2026-06-08 23:19:18.822271+00	\N
793	4347	2026-06-09	118.4400	1.5084	\N	62417.55	25.2090	FINNHUB	2026-06-08 23:19:22.209669+00	\N
794	4348	2026-06-09	1304.5700	0.3508	\N	61174.04	34.3289	FINNHUB	2026-06-08 23:19:25.498247+00	\N
795	4349	2026-06-09	48.8300	-0.7520	\N	60836.29	11.0071	FINNHUB	2026-06-08 23:19:28.800436+00	\N
796	4350	2026-06-09	351.5700	1.3199	\N	59281.34	37.0940	FINNHUB	2026-06-08 23:19:32.238454+00	\N
797	4351	2026-06-09	115.2400	-2.5372	\N	58828.47	12.6895	FINNHUB	2026-06-08 23:19:35.552808+00	\N
798	4352	2026-06-09	89.0000	-2.6471	\N	58868.06	30.0808	FINNHUB	2026-06-08 23:19:38.913755+00	\N
799	4353	2026-06-09	31.3500	-0.5078	\N	51571.38	7.2831	FINNHUB	2026-06-08 23:19:42.497004+00	\N
800	4354	2026-06-09	15.0000	0.6711	\N	60049.32	\N	FINNHUB	2026-06-08 23:19:45.904438+00	\N
801	4355	2026-06-09	122.5500	0.6819	\N	82026.99	28.0914	FINNHUB	2026-06-08 23:19:49.338303+00	\N
802	4356	2026-06-09	65.5200	-2.0628	\N	57929.09	19.6104	FINNHUB	2026-06-08 23:19:52.632415+00	\N
803	4357	2026-06-09	218.0000	-4.3062	\N	57328.48	70.1523	FINNHUB	2026-06-08 23:19:55.911428+00	\N
804	4358	2026-06-09	11.6000	-3.0911	\N	58181.37	18.2745	FINNHUB	2026-06-08 23:19:59.152813+00	\N
805	4359	2026-06-09	253.4000	-0.3892	\N	57912.25	24.8444	FINNHUB	2026-06-08 23:20:02.469553+00	\N
806	4360	2026-06-09	302.1000	-1.8614	\N	56279.70	32.4941	FINNHUB	2026-06-08 23:20:05.993766+00	\N
807	4361	2026-06-09	56.4100	-0.1239	\N	57312.16	12.1993	FINNHUB	2026-06-08 23:20:09.317448+00	\N
808	4362	2026-06-09	60.0100	-1.3642	\N	56000.84	49.9766	FINNHUB	2026-06-08 23:20:12.60162+00	\N
809	4363	2026-06-09	215.0200	-2.7103	\N	55345.50	4.5574	FINNHUB	2026-06-08 23:20:15.893756+00	\N
810	4364	2026-06-09	264.1300	0.0151	\N	56685.31	26.5866	FINNHUB	2026-06-08 23:20:19.14882+00	\N
811	4365	2026-06-09	57.4800	0.9661	\N	57111.93	12.0617	FINNHUB	2026-06-08 23:20:22.447741+00	\N
812	4366	2026-06-09	331.6000	0.5366	\N	56439.46	53.5479	FINNHUB	2026-06-08 23:20:25.804243+00	\N
813	4367	2026-06-09	374.6900	4.6825	\N	58654.78	68.6777	FINNHUB	2026-06-08 23:20:29.080261+00	\N
814	4368	2026-06-09	67.3500	0.2829	\N	55781.79	42.5815	FINNHUB	2026-06-08 23:20:32.349931+00	\N
815	4369	2026-06-09	123.9700	1.1422	\N	55711.09	16.1481	FINNHUB	2026-06-08 23:20:35.697104+00	\N
816	4370	2026-06-09	150.8300	-0.7175	\N	54986.00	62.4841	FINNHUB	2026-06-08 23:20:39.142504+00	\N
817	4371	2026-06-09	88.1500	-0.1133	\N	55723.26	15.7812	FINNHUB	2026-06-08 23:20:42.429537+00	\N
818	4372	2026-06-09	212.5200	-1.6748	\N	54907.23	34.0700	FINNHUB	2026-06-08 23:20:45.70211+00	\N
819	4373	2026-06-09	882.4100	-0.9996	\N	47402.69	24.3055	FINNHUB	2026-06-08 23:20:48.951406+00	\N
820	4374	2026-06-09	102.3700	1.9723	\N	54769.81	\N	FINNHUB	2026-06-08 23:20:52.18537+00	\N
821	4375	2026-06-09	311.0800	0.4521	\N	54543.82	28.6646	FINNHUB	2026-06-08 23:20:55.469817+00	\N
822	4376	2026-06-09	84.3800	-0.1302	\N	54228.85	14.9845	FINNHUB	2026-06-08 23:20:58.800577+00	\N
823	4377	2026-06-09	346.3300	9.2317	\N	54346.60	203.0700	FINNHUB	2026-06-08 23:21:02.049409+00	\N
824	4378	2026-06-09	198.1950	2.8943	\N	54186.57	190.7978	FINNHUB	2026-06-08 23:21:05.298446+00	\N
825	4379	2026-06-09	46.0000	-1.6884	\N	53027.74	40.8031	FINNHUB	2026-06-08 23:21:08.677519+00	\N
826	4380	2026-06-09	274.0800	-0.3490	\N	53512.08	20.9960	FINNHUB	2026-06-08 23:21:11.935528+00	\N
827	4381	2026-06-09	84.4900	-2.3914	\N	53016.66	33.0727	FINNHUB	2026-06-08 23:21:15.192884+00	\N
828	4382	2026-06-09	28.7200	1.7718	\N	77254.95	16.6462	FINNHUB	2026-06-08 23:21:18.490952+00	\N
829	4383	2026-06-09	114.8700	-1.1701	\N	73518.31	29.2968	FINNHUB	2026-06-08 23:21:22.074923+00	\N
830	4384	2026-06-09	20.0000	1.5228	\N	1653873.60	33.0042	FINNHUB	2026-06-08 23:21:25.330776+00	\N
831	4385	2026-06-09	67.1800	-0.0446	\N	44048.59	17.3733	FINNHUB	2026-06-08 23:21:28.629801+00	\N
832	4386	2026-06-09	225.9500	-0.2648	\N	51788.42	33.8987	FINNHUB	2026-06-08 23:21:31.891155+00	\N
833	4387	2026-06-09	78.2100	-1.5235	\N	51633.18	11.5330	FINNHUB	2026-06-08 23:21:35.525523+00	\N
834	4388	2026-06-09	75.8600	-1.5189	\N	50736.68	43.6632	FINNHUB	2026-06-08 23:21:38.919429+00	\N
835	4389	2026-06-09	45.0800	1.8067	\N	52053.08	22.9511	FINNHUB	2026-06-08 23:21:42.185194+00	\N
836	4390	2026-06-09	3074.0400	-1.3602	\N	50684.84	20.4529	FINNHUB	2026-06-08 23:21:45.46406+00	\N
837	4391	2026-06-09	203.2000	0.0985	\N	50867.45	57.3477	FINNHUB	2026-06-08 23:21:48.717546+00	\N
838	4392	2026-06-09	12.2800	-0.9677	\N	4855463.00	16.4927	FINNHUB	2026-06-08 23:21:52.582772+00	\N
839	4393	2026-06-09	108.1100	-2.3749	\N	49914.24	27.7038	FINNHUB	2026-06-08 23:21:55.913698+00	\N
840	4394	2026-06-09	247.0100	1.8304	\N	51524.14	51.1507	FINNHUB	2026-06-08 23:21:59.178492+00	\N
841	4395	2026-06-09	146.9000	-1.2503	\N	50159.27	22.3825	FINNHUB	2026-06-08 23:22:02.461587+00	\N
842	4396	2026-06-09	236.6100	-0.9254	\N	49707.81	33.7002	FINNHUB	2026-06-08 23:22:05.767838+00	\N
843	4397	2026-06-09	451.6600	1.1081	\N	50275.80	46.2094	FINNHUB	2026-06-08 23:22:09.312616+00	\N
844	4398	2026-06-09	85.8500	-0.1280	\N	49418.04	45.0812	FINNHUB	2026-06-08 23:22:15.034925+00	\N
845	4399	2026-06-09	86.7800	-0.5729	\N	49004.11	25.6298	FINNHUB	2026-06-08 23:22:18.364774+00	\N
846	4400	2026-06-09	77.6200	-1.7966	\N	49342.27	23.5974	FINNHUB	2026-06-08 23:22:21.63022+00	\N
847	4401	2026-06-09	3.0700	-1.6026	\N	254828.94	16.3586	FINNHUB	2026-06-08 23:22:25.0116+00	\N
848	4402	2026-06-09	66.0200	-1.1825	\N	41930.44	47.2190	FINNHUB	2026-06-08 23:22:28.287667+00	\N
849	4403	2026-06-09	15.7400	0.8974	\N	7808960.00	40.7221	FINNHUB	2026-06-08 23:22:31.60211+00	\N
850	4404	2026-06-09	225.0400	-2.1395	\N	47911.77	32.7490	FINNHUB	2026-06-08 23:22:34.860045+00	\N
851	4405	2026-06-09	108.4400	-0.8322	\N	48438.18	23.7442	FINNHUB	2026-06-08 23:22:38.196548+00	\N
852	4406	2026-06-09	204.4800	-0.5979	\N	48133.99	30.9543	FINNHUB	2026-06-08 23:22:41.460883+00	\N
853	4407	2026-06-09	91.3700	3.4299	\N	50294.11	218.6700	FINNHUB	2026-06-08 23:22:44.718245+00	\N
854	4408	2026-06-09	51.9600	-0.0961	\N	47019.45	21.6380	FINNHUB	2026-06-08 23:22:47.971151+00	\N
855	4409	2026-06-09	44.8000	-2.0765	\N	45839.72	16.4950	FINNHUB	2026-06-08 23:22:51.236317+00	\N
856	4410	2026-06-09	323.5000	-2.3927	\N	38111.96	48.2658	FINNHUB	2026-06-08 23:22:54.501964+00	\N
857	4411	2026-06-09	120.9000	3.1042	\N	47678.95	83.1078	FINNHUB	2026-06-08 23:22:57.760913+00	\N
858	4412	2026-06-09	235.2300	-0.5664	\N	45488.99	26.2004	FINNHUB	2026-06-08 23:23:01.020535+00	\N
859	4413	2026-06-09	105.4400	1.9335	\N	46153.43	98.9168	FINNHUB	2026-06-08 23:23:04.321223+00	\N
860	4414	2026-06-09	602.9400	-2.0343	\N	44269.87	33.5453	FINNHUB	2026-06-08 23:23:07.574021+00	\N
861	4415	2026-06-09	161.8100	0.0371	\N	44966.34	14.6709	FINNHUB	2026-06-08 23:23:10.828451+00	\N
862	4416	2026-06-09	224.2900	-2.3042	\N	43669.95	17.6801	FINNHUB	2026-06-08 23:23:14.091507+00	\N
863	4417	2026-06-09	80.2400	-0.2362	\N	33242.82	18.3734	FINNHUB	2026-06-08 23:23:17.351722+00	\N
864	4418	2026-06-09	561.1700	-0.1761	\N	44405.61	40.5444	FINNHUB	2026-06-08 23:23:20.634524+00	\N
865	4419	2026-06-09	259.6300	-0.2957	\N	44183.98	36.5157	FINNHUB	2026-06-08 23:23:23.906769+00	\N
866	4420	2026-06-09	33.8000	0.5653	\N	44153.06	45.7071	FINNHUB	2026-06-08 23:23:27.14154+00	\N
867	4421	2026-06-09	237.8300	18.3175	\N	44143.88	\N	FINNHUB	2026-06-08 23:23:30.389676+00	\N
868	4422	2026-06-09	386.5000	3.9789	\N	59621.61	44.6077	FINNHUB	2026-06-08 23:23:33.703674+00	\N
869	4423	2026-06-09	12.5200	-0.3185	\N	403746.50	16.0427	FINNHUB	2026-06-08 23:23:37.025609+00	\N
870	4424	2026-06-09	84.4700	0.4161	\N	42481.23	12.2283	FINNHUB	2026-06-08 23:23:40.510494+00	\N
871	4425	2026-06-09	127.2000	5.6128	\N	43339.86	\N	FINNHUB	2026-06-08 23:23:43.907818+00	\N
872	4426	2026-06-09	214.7500	-1.8241	\N	58751.51	30.7367	FINNHUB	2026-06-08 23:23:48.332227+00	\N
873	4427	2026-06-09	355.9800	1.6853	\N	41834.23	37.0214	FINNHUB	2026-06-08 23:23:51.615396+00	\N
874	4428	2026-06-09	38.5300	1.7159	\N	6372279.50	14.2472	FINNHUB	2026-06-08 23:23:54.918248+00	\N
875	4429	2026-06-09	149.9900	-0.7740	\N	41153.34	36.1629	FINNHUB	2026-06-08 23:23:58.255493+00	\N
876	4430	2026-06-09	147.3700	-2.3199	\N	41582.97	23.9258	FINNHUB	2026-06-08 23:24:01.532602+00	\N
877	4431	2026-06-09	21.6800	1.6409	\N	58287.73	15.1373	FINNHUB	2026-06-08 23:24:04.933897+00	\N
878	4432	2026-06-09	30.7500	0.7206	\N	41537.88	22.6735	FINNHUB	2026-06-08 23:24:08.234266+00	\N
879	4433	2026-06-09	95.2500	0.5383	\N	42216.48	18.8626	FINNHUB	2026-06-08 23:24:11.491384+00	\N
880	4434	2026-06-09	126.8700	0.9710	\N	28168.75	45.2306	FINNHUB	2026-06-08 23:24:14.743985+00	\N
881	4435	2026-06-09	77.3100	2.3567	\N	41421.89	53.1732	FINNHUB	2026-06-08 23:24:18.022049+00	\N
882	4436	2026-06-09	119.1000	-2.1042	\N	44306.36	768.8003	FINNHUB	2026-06-08 23:24:21.281536+00	\N
883	4437	2026-06-09	144.2800	-0.9066	\N	40914.87	12.8963	FINNHUB	2026-06-08 23:24:24.539294+00	\N
884	4438	2026-06-09	91.7900	-2.8574	\N	40096.84	37.8629	FINNHUB	2026-06-08 23:24:27.800054+00	\N
885	4439	2026-06-09	69.9200	2.5972	\N	40561.59	50.2570	FINNHUB	2026-06-08 23:24:31.041696+00	\N
886	4440	2026-06-09	73.5200	-0.2713	\N	56959.84	17.3658	FINNHUB	2026-06-08 23:24:34.346852+00	\N
887	4441	2026-06-09	449.3800	-1.1613	\N	40872.61	10.4936	FINNHUB	2026-06-08 23:24:37.595852+00	\N
888	4442	2026-06-09	292.1600	-3.5935	\N	38802.09	67.2227	FINNHUB	2026-06-08 23:24:40.890603+00	\N
889	4443	2026-06-09	79.6200	-2.9261	\N	39875.64	153.1176	FINNHUB	2026-06-08 23:24:44.137071+00	\N
890	4444	2026-06-09	162.1100	6.3714	\N	40151.46	50.1516	FINNHUB	2026-06-08 23:24:47.386986+00	\N
891	4445	2026-06-09	89.0400	-1.0007	\N	40127.36	33.4768	FINNHUB	2026-06-08 23:24:50.67281+00	\N
892	4446	2026-06-09	74.1000	-1.8413	\N	39744.26	12.5733	FINNHUB	2026-06-08 23:24:53.979088+00	\N
893	4447	2026-06-09	8.8900	-2.5219	\N	29173.98	17.5009	FINNHUB	2026-06-08 23:24:57.237566+00	\N
894	4448	2026-06-09	33.2600	-2.7201	\N	116056.26	25.2464	FINNHUB	2026-06-08 23:25:00.52405+00	\N
895	4449	2026-06-09	212.5500	-0.8582	\N	39008.56	\N	FINNHUB	2026-06-08 23:25:03.893956+00	\N
896	4450	2026-06-09	77.7400	-2.1892	\N	39053.45	17.2574	FINNHUB	2026-06-08 23:25:07.231569+00	\N
897	4451	2026-06-09	153.7100	-0.9728	\N	54983.11	37.4000	FINNHUB	2026-06-08 23:25:12.443637+00	\N
898	4452	2026-06-09	471.0600	-3.0980	\N	39182.29	190.2163	FINNHUB	2026-06-08 23:25:15.701985+00	\N
899	4453	2026-06-09	104.3100	-1.8351	\N	38588.75	17.9066	FINNHUB	2026-06-08 23:25:18.962902+00	\N
900	4454	2026-06-09	100.3900	-6.9688	\N	61010716.00	10.1207	FINNHUB	2026-06-08 23:25:22.24625+00	\N
901	4455	2026-06-09	28.5900	-1.0042	\N	279029.97	17.4657	FINNHUB	2026-06-08 23:25:25.57681+00	\N
902	4456	2026-06-09	80.2200	-0.8651	\N	38913.17	35.9974	FINNHUB	2026-06-08 23:25:28.840562+00	\N
903	4457	2026-06-09	62.9600	-0.9596	\N	38861.82	38.2498	FINNHUB	2026-06-08 23:25:32.329449+00	\N
904	4458	2026-06-09	202.6100	-0.4325	\N	38892.29	170.0425	FINNHUB	2026-06-08 23:25:35.608359+00	\N
905	4459	2026-06-09	239.5000	-1.6427	\N	38111.96	48.2658	FINNHUB	2026-06-08 23:25:38.99823+00	\N
906	4460	2026-06-09	267.2000	-0.4842	\N	38726.90	28.2291	FINNHUB	2026-06-08 23:25:42.316816+00	\N
907	4461	2026-06-09	830.1600	0.8259	\N	113671.96	65.8596	FINNHUB	2026-06-08 23:25:45.694248+00	\N
908	4462	2026-06-09	131.7100	0.5957	\N	38338.48	29.2214	FINNHUB	2026-06-08 23:25:49.091961+00	\N
909	4463	2026-06-09	132.6900	-2.0304	\N	37836.00	26.7581	FINNHUB	2026-06-08 23:25:52.379311+00	\N
910	4464	2026-06-09	222.2700	7.4339	\N	38160.85	80.8015	FINNHUB	2026-06-08 23:25:55.668831+00	\N
911	4465	2026-06-09	27.0100	-1.4593	\N	37544.93	12.1230	FINNHUB	2026-06-08 23:25:58.932264+00	\N
912	4466	2026-06-09	122.5100	-0.3011	\N	646375.44	22.7096	FINNHUB	2026-06-08 23:26:02.471819+00	\N
913	4467	2026-06-09	16.4800	-3.6821	\N	36325.70	12.2971	FINNHUB	2026-06-08 23:26:05.742192+00	\N
914	4468	2026-06-09	83.1800	-3.3240	\N	52437.05	24.6288	FINNHUB	2026-06-08 23:26:09.043599+00	\N
915	4469	2026-06-09	29.2700	-0.2386	\N	37263.42	25.6638	FINNHUB	2026-06-08 23:26:12.300297+00	\N
916	4470	2026-06-09	87.3500	3.4953	\N	143160.97	137.9200	FINNHUB	2026-06-08 23:26:15.565295+00	\N
917	4471	2026-06-09	175.9000	-4.7026	\N	36035.17	32.9341	FINNHUB	2026-06-08 23:26:18.853552+00	\N
918	4472	2026-06-09	363.9500	3.0319	\N	38302.73	47.3458	FINNHUB	2026-06-08 23:26:22.229575+00	\N
919	4473	2026-06-09	159.5100	-0.3498	\N	37450.47	447.6241	FINNHUB	2026-06-08 23:26:25.58685+00	\N
920	4474	2026-06-09	123.5000	-0.9305	\N	36785.95	135.0915	FINNHUB	2026-06-08 23:26:28.862594+00	\N
921	4475	2026-06-09	111.2500	-1.5051	\N	36790.72	22.4484	FINNHUB	2026-06-08 23:26:32.167454+00	\N
922	4476	2026-06-09	269.9800	-4.0515	\N	36510.43	32.7948	FINNHUB	2026-06-08 23:26:35.452009+00	\N
923	4477	2026-06-09	76.4800	0.2491	\N	36518.81	21.0362	FINNHUB	2026-06-08 23:26:38.924564+00	\N
924	4478	2026-06-09	41.2600	-0.0727	\N	36369.21	7.1890	FINNHUB	2026-06-08 23:26:42.188155+00	\N
925	4479	2026-06-09	103.7200	-0.8603	\N	36136.58	10.4260	FINNHUB	2026-06-08 23:26:45.472617+00	\N
926	4480	2026-06-09	92.0600	-1.6453	\N	36328.46	\N	FINNHUB	2026-06-08 23:26:48.721349+00	\N
927	4481	2026-06-09	823.7900	0.7768	\N	36084.84	26.9768	FINNHUB	2026-06-08 23:26:52.002099+00	\N
928	4482	2026-06-09	127.5900	-3.4433	\N	35410.85	8.7176	FINNHUB	2026-06-08 23:26:55.273727+00	\N
929	4483	2026-06-09	98.9200	-1.6015	\N	35574.70	21.7356	FINNHUB	2026-06-08 23:26:58.576182+00	\N
930	4484	2026-06-09	363.3400	-0.5529	\N	35873.18	79.8516	FINNHUB	2026-06-08 23:27:01.942037+00	\N
931	4485	2026-06-09	12.3500	-2.3715	\N	35792.29	149.5189	FINNHUB	2026-06-08 23:27:05.185295+00	\N
932	4486	2026-06-09	143.7600	-0.3604	\N	35637.16	42.0746	FINNHUB	2026-06-08 23:27:08.442869+00	\N
933	4487	2026-06-09	26.9700	1.0112	\N	5622790.50	\N	FINNHUB	2026-06-08 23:27:11.724647+00	\N
934	4488	2026-06-09	56.3300	-1.1408	\N	26154.75	12.0324	FINNHUB	2026-06-08 23:27:15.004351+00	\N
935	4489	2026-06-09	44.0200	-1.2118	\N	1093799.90	28.0296	FINNHUB	2026-06-08 23:27:18.339026+00	\N
936	4490	2026-06-09	553.9800	-3.7945	\N	33524.83	13.2300	FINNHUB	2026-06-08 23:27:21.670295+00	\N
937	4491	2026-06-09	572.7700	0.9589	\N	35181.49	37.3435	FINNHUB	2026-06-08 23:27:24.92085+00	\N
938	4492	2026-06-09	105.3200	-0.3878	\N	34060.38	9.2960	FINNHUB	2026-06-08 23:27:28.190543+00	\N
939	4493	2026-06-09	212.5400	-5.9516	\N	33106.43	318.4658	FINNHUB	2026-06-08 23:27:31.443659+00	\N
940	4494	2026-06-09	17.5500	-0.9034	\N	34003.35	20.9638	FINNHUB	2026-06-08 23:27:34.688401+00	\N
941	4495	2026-06-09	14.8100	0.7483	\N	25790.37	\N	FINNHUB	2026-06-08 23:27:37.957251+00	\N
942	4496	2026-06-09	116.6200	0.2924	\N	32838.77	\N	FINNHUB	2026-06-08 23:27:41.225761+00	\N
943	4497	2026-06-09	52.9800	-1.4326	\N	33253.54	10.1249	FINNHUB	2026-06-08 23:27:44.490047+00	\N
944	4498	2026-06-09	333.7500	0.4726	\N	33690.25	19.6548	FINNHUB	2026-06-08 23:27:47.748514+00	\N
945	4499	2026-06-09	3.2900	-2.0833	\N	172156.17	7.2404	FINNHUB	2026-06-08 23:27:51.103755+00	\N
946	4500	2026-06-09	16.4900	-0.1816	\N	33427.39	15.1461	FINNHUB	2026-06-08 23:27:54.384827+00	\N
947	4501	2026-06-09	171.1300	-1.3376	\N	33390.69	47.1924	FINNHUB	2026-06-08 23:27:57.627556+00	\N
948	4502	2026-06-09	78.8200	-0.7805	\N	33303.48	12.6006	FINNHUB	2026-06-08 23:28:00.891535+00	\N
949	4503	2026-06-09	50.7900	1.0746	\N	33390.30	18.1272	FINNHUB	2026-06-08 23:28:04.309513+00	\N
950	4504	2026-06-09	71.5000	-1.5965	\N	32920.41	34.4716	FINNHUB	2026-06-08 23:28:07.570765+00	\N
951	4505	2026-06-09	35.8800	-2.0208	\N	542116.20	9.1980	FINNHUB	2026-06-08 23:28:10.865988+00	\N
952	4506	2026-06-09	97.7500	-1.3025	\N	32740.94	15.4511	FINNHUB	2026-06-08 23:28:14.169883+00	\N
953	4507	2026-06-09	63.9100	-4.8534	\N	49784364.00	9.7505	FINNHUB	2026-06-08 23:28:17.454694+00	\N
954	4508	2026-06-09	40.5000	3.3691	\N	33574.64	21.8017	FINNHUB	2026-06-08 23:28:20.73787+00	\N
955	4509	2026-06-09	170.3100	1.9576	\N	33210.71	26.0272	FINNHUB	2026-06-08 23:28:24.031717+00	\N
956	4510	2026-06-09	66.1100	-1.0477	\N	26024.38	39.9043	FINNHUB	2026-06-08 23:28:27.292528+00	\N
957	4511	2026-06-09	222.6300	0.0854	\N	32645.54	11.1380	FINNHUB	2026-06-08 23:28:30.579521+00	\N
958	4512	2026-06-09	81.2900	2.4320	\N	32799.47	\N	FINNHUB	2026-06-08 23:28:33.82007+00	\N
959	4513	2026-06-09	67.2800	0.1190	\N	45049.26	13.5356	FINNHUB	2026-06-08 23:28:37.088307+00	\N
960	4514	2026-06-09	54.8600	-1.8078	\N	32174.54	38.8916	FINNHUB	2026-06-08 23:28:40.330575+00	\N
961	4515	2026-06-09	145.0000	-0.2133	\N	30571.57	32.3817	FINNHUB	2026-06-08 23:28:43.627531+00	\N
962	4516	2026-06-09	25.5800	0.3531	\N	23788.17	7.9786	FINNHUB	2026-06-08 23:28:46.888697+00	\N
963	4517	2026-06-09	12.8400	0.3125	\N	31799.78	11.3855	FINNHUB	2026-06-08 23:28:50.13308+00	\N
964	4518	2026-06-09	89.6100	-1.7326	\N	31860.84	6.5396	FINNHUB	2026-06-08 23:28:53.388697+00	\N
965	4519	2026-06-09	148.4900	-0.4959	\N	31725.77	\N	FINNHUB	2026-06-08 23:28:56.648731+00	\N
966	4520	2026-06-09	62.8100	2.2298	\N	29051.06	17.0247	FINNHUB	2026-06-08 23:28:59.910044+00	\N
967	4521	2026-06-09	169.1100	-0.7978	\N	31306.30	16.7378	FINNHUB	2026-06-08 23:29:03.174501+00	\N
968	4522	2026-06-09	25.8600	-1.3730	\N	43584.65	10.9103	FINNHUB	2026-06-08 23:29:06.453015+00	\N
969	4523	2026-06-09	64.5600	0.1396	\N	31206.97	12.3250	FINNHUB	2026-06-08 23:29:09.754456+00	\N
970	4524	2026-06-09	15.3500	1.3201	\N	112042990.00	12.4101	FINNHUB	2026-06-08 23:29:13.024416+00	\N
971	4525	2026-06-09	213.4700	-0.8546	\N	30375.27	\N	FINNHUB	2026-06-08 23:29:16.643257+00	\N
972	4526	2026-06-09	65.0300	4.3318	\N	31807.93	\N	FINNHUB	2026-06-08 23:29:19.890966+00	\N
973	4527	2026-06-09	183.6900	0.1308	\N	30495.97	22.0187	FINNHUB	2026-06-08 23:29:23.135345+00	\N
974	4528	2026-06-09	27.4000	-1.6511	\N	30446.58	9.8079	FINNHUB	2026-06-08 23:29:26.369561+00	\N
975	4529	2026-06-09	143.1100	-1.8248	\N	30233.80	23.9191	FINNHUB	2026-06-08 23:29:29.623281+00	\N
976	4530	2026-06-09	107.1500	-1.9401	\N	29720.36	19.5015	FINNHUB	2026-06-08 23:29:32.986875+00	\N
977	4531	2026-06-09	84.6400	1.3774	\N	30531.87	\N	FINNHUB	2026-06-08 23:29:36.262262+00	\N
978	4532	2026-06-09	62.0900	0.6810	\N	30197.84	33.5013	FINNHUB	2026-06-08 23:29:39.5405+00	\N
979	4533	2026-06-09	47.2100	-1.0065	\N	243527.53	6.3329	FINNHUB	2026-06-08 23:29:42.815403+00	\N
980	4534	2026-06-09	270.8000	0.2592	\N	210235.03	66.4671	FINNHUB	2026-06-08 23:29:46.072538+00	\N
981	4535	2026-06-09	275.3900	-1.2974	\N	30781.09	18.4837	FINNHUB	2026-06-08 23:29:49.33055+00	\N
982	4536	2026-06-09	42.3000	1.1478	\N	29942.23	\N	FINNHUB	2026-06-08 23:29:52.570968+00	\N
983	4537	2026-06-09	101.1500	-0.4625	\N	29798.26	14.3868	FINNHUB	2026-06-08 23:29:55.818533+00	\N
984	4538	2026-06-09	50.8000	-5.1885	\N	29615.59	25.6190	FINNHUB	2026-06-08 23:29:59.076105+00	\N
985	4539	2026-06-09	144.4500	1.6895	\N	29736.64	64.3650	FINNHUB	2026-06-08 23:30:02.470325+00	\N
986	4540	2026-06-09	150.1900	-0.8320	\N	29605.65	13.7893	FINNHUB	2026-06-08 23:30:05.737784+00	\N
987	4541	2026-06-09	280.3200	-0.5640	\N	29336.55	23.7524	FINNHUB	2026-06-08 23:30:09.178441+00	\N
988	4542	2026-06-09	64.6700	0.0000	\N	29417.85	15.4020	FINNHUB	2026-06-08 23:30:12.448209+00	\N
989	4543	2026-06-09	52.7200	-3.1417	\N	28513.09	8.9103	FINNHUB	2026-06-08 23:30:15.725251+00	\N
990	4544	2026-06-09	216.1900	0.6659	\N	29226.91	26.5321	FINNHUB	2026-06-08 23:30:18.987535+00	\N
991	4545	2026-06-09	192.6200	-1.3924	\N	28544.16	20.8063	FINNHUB	2026-06-08 23:30:22.285252+00	\N
992	4546	2026-06-09	30.8600	-0.3230	\N	28348.35	18.2516	FINNHUB	2026-06-08 23:30:25.55001+00	\N
993	4547	2026-06-09	55.0800	-1.4669	\N	39490.94	21.9151	FINNHUB	2026-06-08 23:30:28.83575+00	\N
994	4548	2026-06-09	48.3600	-0.9422	\N	39564.40	23.4109	FINNHUB	2026-06-08 23:30:32.184385+00	\N
995	4549	2026-06-09	167.8900	-1.3804	\N	27971.59	20.7784	FINNHUB	2026-06-08 23:30:35.474627+00	\N
996	4550	2026-06-09	361.7000	-0.6018	\N	28807.80	64.0203	FINNHUB	2026-06-08 23:30:38.834302+00	\N
997	4551	2026-06-09	193.1400	-1.4793	\N	28100.32	18.4923	FINNHUB	2026-06-08 23:30:42.115286+00	\N
998	4552	2026-06-09	140.9000	0.5710	\N	28418.60	42.8766	FINNHUB	2026-06-08 23:30:45.399415+00	\N
999	4553	2026-06-09	72.4600	0.2907	\N	28274.09	48.1671	FINNHUB	2026-06-08 23:30:48.647965+00	\N
1000	4554	2026-06-09	70.8400	-3.3956	\N	27635.90	7.3130	FINNHUB	2026-06-08 23:30:51.911101+00	\N
1001	4555	2026-06-09	352.5600	0.5189	\N	28297.96	\N	FINNHUB	2026-06-08 23:30:55.176163+00	\N
1002	4556	2026-06-09	751.6300	-1.3492	\N	27864.15	42.8632	FINNHUB	2026-06-08 23:30:58.433319+00	\N
1003	4557	2026-06-09	76.6200	5.1606	\N	28944.33	31.1096	FINNHUB	2026-06-08 23:31:01.710114+00	\N
1004	4558	2026-06-09	9.7300	-0.7143	\N	118592.19	12.4284	FINNHUB	2026-06-08 23:31:05.0445+00	\N
1005	4559	2026-06-09	67.4400	0.8222	\N	26777.50	15.6502	FINNHUB	2026-06-08 23:31:08.313185+00	\N
1006	4560	2026-06-09	167.2400	-3.1111	\N	28169.73	29.9152	FINNHUB	2026-06-08 23:31:11.575118+00	\N
1007	4561	2026-06-09	41.8500	-1.9677	\N	27429.33	25.6109	FINNHUB	2026-06-08 23:31:14.841157+00	\N
1008	4562	2026-06-09	612.3800	1.6786	\N	28220.00	30.2465	FINNHUB	2026-06-08 23:31:18.121241+00	\N
1009	4563	2026-06-09	225.9000	-1.3020	\N	27123.69	18.2283	FINNHUB	2026-06-08 23:31:21.367974+00	\N
1010	4564	2026-06-09	127.7100	-1.1533	\N	27191.94	113.7738	FINNHUB	2026-06-08 23:31:24.673265+00	\N
1011	4565	2026-06-09	15.1800	0.1980	\N	27195.23	\N	FINNHUB	2026-06-08 23:31:27.910412+00	\N
1012	4566	2026-06-09	721.3300	-1.6109	\N	26735.25	52.3116	FINNHUB	2026-06-08 23:31:31.188929+00	\N
1013	4567	2026-06-09	187.6100	-1.1122	\N	26915.97	23.6015	FINNHUB	2026-06-08 23:31:34.545068+00	\N
1014	4568	2026-06-09	891.8600	1.0686	\N	27052.12	78.0398	FINNHUB	2026-06-08 23:31:37.864542+00	\N
1015	4569	2026-06-09	64.3500	0.5783	\N	27250.51	13.7977	FINNHUB	2026-06-08 23:31:41.144415+00	\N
1016	4570	2026-06-09	69.6300	-1.0094	\N	26990.59	18.2246	FINNHUB	2026-06-08 23:31:44.447381+00	\N
1017	4571	2026-06-09	35.3500	-1.0912	\N	26569.26	21.7959	FINNHUB	2026-06-08 23:31:47.785245+00	\N
1018	4572	2026-06-09	396.1400	1.6291	\N	27812.21	55.2239	FINNHUB	2026-06-08 23:31:51.059524+00	\N
1019	4573	2026-06-09	283.4100	-3.9028	\N	26837.72	31.9155	FINNHUB	2026-06-08 23:31:54.347574+00	\N
1020	4574	2026-06-09	288.1700	1.1300	\N	27003.99	43.4081	FINNHUB	2026-06-08 23:31:57.615793+00	\N
1021	4575	2026-06-09	45.7100	-1.5295	\N	26534.37	24.9149	FINNHUB	2026-06-08 23:32:00.883144+00	\N
1022	4076	2026-06-10	208.1900	-0.2157	\N	5090470.00	31.8926	FINNHUB	2026-06-09 23:05:08.572009+00	\N
1023	4077	2026-06-10	290.5500	-3.6446	\N	4260068.00	34.7548	FINNHUB	2026-06-09 23:05:11.937661+00	\N
1024	4078	2026-06-10	364.2600	0.2615	\N	4400410.00	27.4669	FINNHUB	2026-06-09 23:05:15.290569+00	\N
1025	4079	2026-06-10	403.4100	-2.0231	\N	3047660.00	24.3392	FINNHUB	2026-06-09 23:05:18.726298+00	\N
1026	4080	2026-06-10	244.1900	-0.4200	\N	2677003.50	29.4831	FINNHUB	2026-06-09 23:05:22.075705+00	\N
1027	4081	2026-06-10	427.9200	0.2624	\N	59514788.00	30.8559	FINNHUB	2026-06-09 23:05:25.569665+00	\N
1028	4082	2026-06-10	392.1600	-1.1195	\N	1842756.50	62.8562	FINNHUB	2026-06-09 23:05:28.90891+00	\N
1029	4083	2026-06-10	584.5900	-0.1367	\N	1485967.50	21.0516	FINNHUB	2026-06-09 23:05:32.292003+00	\N
1030	4084	2026-06-10	396.6800	-3.0004	\N	1535903.10	397.6963	FINNHUB	2026-06-09 23:05:35.654232+00	\N
1031	4085	2026-06-10	487.7700	0.1581	\N	1053042.50	14.5305	FINNHUB	2026-06-09 23:05:39.18539+00	\N
1032	4086	2026-06-10	1144.6800	-0.3890	\N	1095014.50	43.3211	FINNHUB	2026-06-09 23:05:42.562161+00	\N
1033	4087	2026-06-10	935.8900	-1.4105	\N	1023779.50	42.4611	FINNHUB	2026-06-09 23:05:45.918018+00	\N
1034	4088	2026-06-10	118.8800	-0.7928	\N	953616.70	41.9430	FINNHUB	2026-06-09 23:05:49.383927+00	\N
1035	4089	2026-06-10	312.7000	0.5111	\N	836893.94	14.2090	FINNHUB	2026-06-09 23:05:52.708758+00	\N
1036	4090	2026-06-10	475.5050	-3.0235	\N	775358.70	154.7931	FINNHUB	2026-06-09 23:05:56.087231+00	\N
1037	4091	2026-06-10	1777.7700	1.6426	\N	578554.20	56.6488	FINNHUB	2026-06-09 23:05:59.494001+00	\N
1038	4092	2026-06-10	148.9100	-1.8715	\N	628995.75	24.8477	FINNHUB	2026-06-09 23:06:02.859842+00	\N
1039	4093	2026-06-10	205.8100	-2.8373	\N	622433.90	38.3981	FINNHUB	2026-06-09 23:06:06.233685+00	\N
1040	4094	2026-06-10	325.0500	1.6830	\N	602298.20	27.0866	FINNHUB	2026-06-09 23:06:09.590522+00	\N
1041	4095	2026-06-10	237.0000	2.0848	\N	570594.70	27.1195	FINNHUB	2026-06-09 23:06:13.027103+00	\N
1042	4096	2026-06-10	107.9200	-2.1311	\N	528986.50	\N	FINNHUB	2026-06-09 23:06:16.516645+00	\N
1043	4097	2026-06-10	120.3600	-3.0528	\N	489329.12	40.9206	FINNHUB	2026-06-09 23:06:19.922433+00	\N
1044	4098	2026-06-10	495.2400	1.9705	\N	433559.06	27.8458	FINNHUB	2026-06-09 23:06:23.439257+00	\N
1045	4099	2026-06-10	968.5900	-0.6320	\N	431134.60	48.7819	FINNHUB	2026-06-09 23:06:26.79741+00	\N
1046	4100	2026-06-10	914.7000	-0.1027	\N	417553.66	44.2793	FINNHUB	2026-06-09 23:06:30.164156+00	\N
1047	4101	2026-06-10	225.4200	1.0535	\N	394118.50	108.4232	FINNHUB	2026-06-09 23:06:33.5266+00	\N
1048	4102	2026-06-10	54.4200	1.4731	\N	385664.22	12.1672	FINNHUB	2026-06-09 23:06:36.85064+00	\N
1049	4103	2026-06-10	327.1600	0.8353	\N	430984.30	64.2474	FINNHUB	2026-06-09 23:06:40.254532+00	\N
1050	4104	2026-06-10	186.7600	-1.3105	\N	371353.34	33.7318	FINNHUB	2026-06-09 23:06:43.601627+00	\N
1051	4105	2026-06-10	324.8600	-6.2155	\N	364877.50	403.6256	FINNHUB	2026-06-09 23:06:46.915802+00	\N
1052	4106	2026-06-10	413.0000	1.5815	\N	366451.40	30.4261	FINNHUB	2026-06-09 23:06:50.261645+00	\N
1053	4107	2026-06-10	499.2100	1.4304	\N	414033.56	48.6640	FINNHUB	2026-06-09 23:06:53.611544+00	\N
1054	4108	2026-06-10	81.4100	-1.4884	\N	344527.53	25.7617	FINNHUB	2026-06-09 23:06:56.954551+00	\N
1055	4109	2026-06-10	330.4400	2.6084	\N	342141.60	39.6456	FINNHUB	2026-06-09 23:07:00.368432+00	\N
1056	4110	2026-06-10	81.3400	2.2630	\N	342305.50	24.9840	FINNHUB	2026-06-09 23:07:03.723507+00	\N
1057	4111	2026-06-10	148.6700	2.4604	\N	345540.84	20.7957	FINNHUB	2026-06-09 23:07:07.25755+00	\N
1058	4112	2026-06-10	210.2500	-0.9376	\N	331379.70	18.2951	FINNHUB	2026-06-09 23:07:10.62404+00	\N
1059	4113	2026-06-10	132.0700	-3.2242	\N	327161.22	143.3956	FINNHUB	2026-06-09 23:07:14.040318+00	\N
1060	4114	2026-06-10	1032.0100	-1.2431	\N	311564.72	17.2440	FINNHUB	2026-06-09 23:07:17.660149+00	\N
1061	4115	2026-06-10	89.3400	-2.3927	\N	235621.03	14.1502	FINNHUB	2026-06-09 23:07:21.082449+00	\N
1062	4116	2026-06-10	321.3300	3.7519	\N	318419.25	22.7248	FINNHUB	2026-06-09 23:07:24.513515+00	\N
1063	4117	2026-06-10	119.6000	0.0669	\N	294427.78	32.9522	FINNHUB	2026-06-09 23:07:27.909798+00	\N
1064	4118	2026-06-10	183.4300	1.0355	\N	213956.97	27.5882	FINNHUB	2026-06-09 23:07:31.505993+00	\N
1065	4119	2026-06-10	178.4900	1.3802	\N	274399.84	24.7296	FINNHUB	2026-06-09 23:07:34.841172+00	\N
1066	4120	2026-06-10	119.7000	-0.3082	\N	290854.28	18.5978	FINNHUB	2026-06-09 23:07:38.194554+00	\N
1067	4121	2026-06-10	149.1200	1.8440	\N	215384.90	19.9603	FINNHUB	2026-06-09 23:07:41.622557+00	\N
1068	4122	2026-06-10	197.8900	1.3158	\N	380757.75	17.1993	FINNHUB	2026-06-09 23:07:45.471918+00	\N
1069	4123	2026-06-10	277.4900	-1.1858	\N	260583.19	24.2358	FINNHUB	2026-06-09 23:07:48.811539+00	\N
1070	4124	2026-06-10	288.6300	-0.7803	\N	266957.53	49.7405	FINNHUB	2026-06-09 23:07:52.165619+00	\N
1071	4125	2026-06-10	381.7800	-4.7384	\N	261472.17	31.0943	FINNHUB	2026-06-09 23:07:55.507301+00	\N
1072	4126	2026-06-10	2139.3700	1.4853	\N	275370.62	58.9588	FINNHUB	2026-06-09 23:07:58.88566+00	\N
1073	4127	2026-06-10	920.1500	-1.4670	\N	250944.17	26.7702	FINNHUB	2026-06-09 23:08:02.271005+00	\N
1074	4128	2026-06-10	82.0000	1.2846	\N	247752.94	11.4188	FINNHUB	2026-06-09 23:08:05.637352+00	\N
1075	4129	2026-06-10	181.5600	1.6232	\N	240598.45	33.1586	FINNHUB	2026-06-09 23:08:09.054254+00	\N
1076	4130	2026-06-10	85.4300	-1.4080	\N	180222.27	12.8766	FINNHUB	2026-06-09 23:08:12.563111+00	\N
1077	4131	2026-06-10	515.5900	2.7235	\N	232187.95	32.7856	FINNHUB	2026-06-09 23:08:15.921242+00	\N
1078	4132	2026-06-10	175.7800	-1.4962	\N	33421374.00	8.6852	FINNHUB	2026-06-09 23:08:19.543658+00	\N
1079	4133	2026-06-10	1646.5400	0.2765	\N	243163.39	53.9524	FINNHUB	2026-06-09 23:08:22.902447+00	\N
1080	4134	2026-06-10	266.8800	-7.6060	\N	254212.52	100.6105	FINNHUB	2026-06-09 23:08:26.376601+00	\N
1081	4135	2026-06-10	205.4200	-5.6711	\N	211485.11	21.3126	FINNHUB	2026-06-09 23:08:29.786092+00	\N
1082	4136	2026-06-10	19.8300	-0.4518	\N	35424576.00	14.5947	FINNHUB	2026-06-09 23:08:33.148404+00	\N
1083	4137	2026-06-10	134.7300	1.0879	\N	228562.88	14.2620	FINNHUB	2026-06-09 23:08:36.536527+00	\N
1084	4138	2026-06-10	260.5200	-2.1815	\N	217058.94	257.5450	FINNHUB	2026-06-09 23:08:39.877651+00	\N
1085	4139	2026-06-10	84.7300	1.2306	\N	311141.47	21.4353	FINNHUB	2026-06-09 23:08:43.258503+00	\N
1086	4140	2026-06-10	178.9200	-1.6491	\N	184591.08	25.2415	FINNHUB	2026-06-09 23:08:46.866283+00	\N
1087	4141	2026-06-10	318.3800	1.9468	\N	216945.67	19.3356	FINNHUB	2026-06-09 23:08:50.255224+00	\N
1088	4142	2026-06-10	282.2500	1.6092	\N	197296.81	22.7379	FINNHUB	2026-06-09 23:08:53.759533+00	\N
1089	4143	2026-06-10	88.4800	-0.1692	\N	172275.08	13.1607	FINNHUB	2026-06-09 23:08:57.14485+00	\N
1090	4144	2026-06-10	42.1900	2.8523	\N	1208768.00	9.9114	FINNHUB	2026-06-09 23:09:00.488141+00	\N
1091	4145	2026-06-10	404.6200	0.1807	\N	193997.03	58.5487	FINNHUB	2026-06-09 23:09:03.834307+00	\N
1092	4146	2026-06-10	152.1600	-2.7110	\N	196939.28	52.9336	FINNHUB	2026-06-09 23:09:07.159794+00	\N
1093	4147	2026-06-10	142.7800	1.4928	\N	194532.14	22.2755	FINNHUB	2026-06-09 23:09:10.60287+00	\N
1094	4148	2026-06-10	179.4600	0.5773	\N	193931.08	18.3943	FINNHUB	2026-06-09 23:09:13.969727+00	\N
1095	4149	2026-06-10	846.0100	-3.5083	\N	196597.25	82.6734	FINNHUB	2026-06-09 23:09:17.399211+00	\N
1096	4150	2026-06-10	45.7800	0.7482	\N	189737.39	10.9422	FINNHUB	2026-06-09 23:09:20.776137+00	\N
1097	4151	2026-06-10	344.5650	-0.3370	\N	187057.48	23.9817	FINNHUB	2026-06-09 23:09:24.159552+00	\N
1098	4152	2026-06-10	520.8400	-7.6017	\N	189366.02	47.7842	FINNHUB	2026-06-09 23:09:27.508974+00	\N
1099	4153	2026-06-10	114.6400	0.4117	\N	269423.94	18.0700	FINNHUB	2026-06-09 23:09:30.85342+00	\N
1100	4154	2026-06-10	84.8300	0.9761	\N	175585.77	21.4574	FINNHUB	2026-06-09 23:09:34.215655+00	\N
1101	4155	2026-06-10	164.8700	3.2050	\N	180795.94	31.2256	FINNHUB	2026-06-09 23:09:37.553712+00	\N
1102	4156	2026-06-10	12.2700	0.9046	\N	155542.19	9.6287	FINNHUB	2026-06-09 23:09:40.915048+00	\N
1103	4157	2026-06-10	517.7200	-1.7479	\N	181623.36	27.8948	FINNHUB	2026-06-09 23:09:44.304792+00	\N
1104	4158	2026-06-10	101.4200	0.4855	\N	131717.45	17.7049	FINNHUB	2026-06-09 23:09:47.786207+00	\N
1105	4159	2026-06-10	494.0700	5.2041	\N	181451.61	26.5048	FINNHUB	2026-06-09 23:09:51.123532+00	\N
1106	4160	2026-06-10	99.3300	0.4653	\N	172869.70	15.4018	FINNHUB	2026-06-09 23:09:54.512723+00	\N
1107	4161	2026-06-10	644.9300	-2.1039	\N	167704.77	\N	FINNHUB	2026-06-09 23:09:57.829613+00	\N
1108	4162	2026-06-10	154.0700	7.2911	\N	189246.98	42.3798	FINNHUB	2026-06-09 23:10:01.181268+00	\N
1109	4163	2026-06-10	214.5100	-0.6530	\N	172228.28	75.9384	FINNHUB	2026-06-09 23:10:07.3262+00	\N
1110	4164	2026-06-10	1011.9600	1.7280	\N	161989.25	25.8976	FINNHUB	2026-06-09 23:10:10.662825+00	\N
1111	4165	2026-06-10	271.2800	0.9715	\N	154580.84	21.4309	FINNHUB	2026-06-09 23:10:14.153415+00	\N
1112	4166	2026-06-10	125.5000	-2.0297	\N	156524.72	16.9822	FINNHUB	2026-06-09 23:10:17.690291+00	\N
1113	4167	2026-06-10	91.2500	0.8287	\N	159449.86	25.4063	FINNHUB	2026-06-09 23:10:21.0825+00	\N
1114	4168	2026-06-10	22.7100	0.9333	\N	156268.84	7.2917	FINNHUB	2026-06-09 23:10:24.521754+00	\N
1115	4169	2026-06-10	577.3300	0.6398	\N	156385.55	32.6961	FINNHUB	2026-06-09 23:10:27.859277+00	\N
1116	4170	2026-06-10	88.7700	0.7834	\N	152730.88	16.2100	FINNHUB	2026-06-09 23:10:31.198605+00	\N
1117	4171	2026-06-10	401.7200	-0.3522	\N	153525.08	38.4678	FINNHUB	2026-06-09 23:10:34.57586+00	\N
1118	4172	2026-06-10	173.9400	-7.2518	\N	161326.55	89.1307	FINNHUB	2026-06-09 23:10:37.92126+00	\N
1119	4173	2026-06-10	81.0200	3.0003	\N	134305.56	21.3406	FINNHUB	2026-06-09 23:10:41.583819+00	\N
1120	4174	2026-06-10	175.3500	-3.9441	\N	148230.81	18.4757	FINNHUB	2026-06-09 23:10:44.962601+00	\N
1121	4175	2026-06-10	426.6100	1.9111	\N	150861.86	50.6401	FINNHUB	2026-06-09 23:10:48.308289+00	\N
1122	4176	2026-06-10	25.7000	0.3123	\N	147045.66	19.6296	FINNHUB	2026-06-09 23:10:51.703788+00	\N
1123	4177	2026-06-10	23.0700	-0.7315	\N	23301616.00	14.7202	FINNHUB	2026-06-09 23:10:55.113008+00	\N
1124	4178	2026-06-10	206.7700	3.3850	\N	141182.88	100.3033	FINNHUB	2026-06-09 23:10:58.525216+00	\N
1125	4179	2026-06-10	175.1700	2.7511	\N	146144.66	29.4308	FINNHUB	2026-06-09 23:11:01.990004+00	\N
1126	4180	2026-06-10	47.8600	1.2053	\N	114318.52	15.7286	FINNHUB	2026-06-09 23:11:05.408662+00	\N
1127	4181	2026-06-10	70.3800	0.4568	\N	146624.19	17.1691	FINNHUB	2026-06-09 23:11:08.745903+00	\N
1128	4182	2026-06-10	116.7900	-1.7663	\N	143100.81	19.5440	FINNHUB	2026-06-09 23:11:12.153109+00	\N
1129	4183	2026-06-10	110.4200	-0.3250	\N	143312.97	107.5923	FINNHUB	2026-06-09 23:11:15.502537+00	\N
1130	4184	2026-06-10	120.2900	5.3420	\N	139484.70	45.6714	FINNHUB	2026-06-09 23:11:18.836816+00	\N
1131	4185	2026-06-10	147.5200	3.3198	\N	138349.14	37.2181	FINNHUB	2026-06-09 23:11:22.529147+00	\N
1132	4186	2026-06-10	215.7000	1.8414	\N	134207.73	29.7512	FINNHUB	2026-06-09 23:11:25.88761+00	\N
1133	4187	2026-06-10	21.3100	-3.7923	\N	21088974.00	\N	FINNHUB	2026-06-09 23:11:29.264188+00	\N
1134	4188	2026-06-10	188.4100	2.6590	\N	133428.92	36.1694	FINNHUB	2026-06-09 23:11:32.601001+00	\N
1135	4189	2026-06-10	163.9900	1.0413	\N	127072.31	20.6487	FINNHUB	2026-06-09 23:11:35.934736+00	\N
1136	4190	2026-06-10	59.9500	0.4356	\N	96569.97	12.4382	FINNHUB	2026-06-09 23:11:39.350703+00	\N
1137	4191	2026-06-10	325.1300	1.0097	\N	125695.77	11.1245	FINNHUB	2026-06-09 23:11:42.687957+00	\N
1138	4192	2026-06-10	424.8200	1.8533	\N	125187.28	26.2063	FINNHUB	2026-06-09 23:11:46.025596+00	\N
1139	4193	2026-06-10	22.5300	0.7152	\N	109021.25	10.0918	FINNHUB	2026-06-09 23:11:49.372776+00	\N
1140	4194	2026-06-10	55.5400	0.3795	\N	168646.89	24.4239	FINNHUB	2026-06-09 23:11:52.738567+00	\N
1141	4195	2026-06-10	97.0600	-0.0206	\N	122591.09	41.8114	FINNHUB	2026-06-09 23:11:56.314037+00	\N
1142	4196	2026-06-10	57.5800	2.6564	\N	88731.84	10.8544	FINNHUB	2026-06-09 23:11:59.716187+00	\N
1143	4197	2026-06-10	81.9300	-0.8351	\N	117601.02	8.3260	FINNHUB	2026-06-09 23:12:03.081319+00	\N
1144	4198	2026-06-10	530.1300	1.9344	\N	121248.80	25.2971	FINNHUB	2026-06-09 23:12:06.653444+00	\N
1145	4199	2026-06-10	23.2900	1.2169	\N	11371909.00	14.9579	FINNHUB	2026-06-09 23:12:10.0384+00	\N
1146	4200	2026-06-10	71.5600	0.3787	\N	119096.64	14.7891	FINNHUB	2026-06-09 23:12:13.425694+00	\N
1147	4201	2026-06-10	200.1300	-0.0649	\N	117019.22	10.1236	FINNHUB	2026-06-09 23:12:17.007248+00	\N
1148	4202	2026-06-10	217.3700	4.5199	\N	120044.59	18.0736	FINNHUB	2026-06-09 23:12:20.354837+00	\N
1149	4203	2026-06-10	9.5700	-0.2086	\N	18439878.00	14.7681	FINNHUB	2026-06-09 23:12:24.056523+00	\N
1150	4204	2026-06-10	314.0100	4.1389	\N	119724.91	35.8780	FINNHUB	2026-06-09 23:12:27.517395+00	\N
1151	4205	2026-06-10	56.4800	1.6376	\N	115203.45	19.2754	FINNHUB	2026-06-09 23:12:30.95885+00	\N
1152	4206	2026-06-10	106.9700	-6.3228	\N	117765.06	67.0262	FINNHUB	2026-06-09 23:12:34.392613+00	\N
1153	4207	2026-06-10	289.5200	-3.6763	\N	115428.53	74.0686	FINNHUB	2026-06-09 23:12:37.706162+00	\N
1154	4208	2026-06-10	165.2200	0.3828	\N	162177.84	16.6661	FINNHUB	2026-06-09 23:12:41.08933+00	\N
1155	4209	2026-06-10	445.7700	0.6344	\N	112425.65	25.9147	FINNHUB	2026-06-09 23:12:44.425295+00	\N
1156	4210	2026-06-10	42.6700	-2.4016	\N	84297.08	35.1785	FINNHUB	2026-06-09 23:12:47.867919+00	\N
1157	4211	2026-06-10	183.3500	1.6409	\N	113394.19	35.1828	FINNHUB	2026-06-09 23:12:51.22331+00	\N
1158	4212	2026-06-10	905.5300	2.5353	\N	113167.58	32.5178	FINNHUB	2026-06-09 23:12:54.56322+00	\N
1159	4213	2026-06-10	17.8200	0.3944	\N	561570.75	5.2199	FINNHUB	2026-06-09 23:12:58.027666+00	\N
1160	4214	2026-06-10	15.9000	0.0000	\N	561570.75	5.2199	FINNHUB	2026-06-09 23:13:01.399936+00	\N
1161	4215	2026-06-10	173.4700	-0.5504	\N	107758.62	14.0893	FINNHUB	2026-06-09 23:13:04.730418+00	\N
1162	4216	2026-06-10	97.4100	2.7315	\N	111513.94	74.5564	FINNHUB	2026-06-09 23:13:08.079555+00	\N
1163	4217	2026-06-10	44.7300	1.9371	\N	93995.90	7.6863	FINNHUB	2026-06-09 23:13:11.456274+00	\N
1164	4218	2026-06-10	1059.8400	-0.2729	\N	104525.93	73.5063	FINNHUB	2026-06-09 23:13:14.814219+00	\N
1165	4219	2026-06-10	98.5400	-0.4546	\N	105677.05	12.4973	FINNHUB	2026-06-09 23:13:18.187545+00	\N
1166	4220	2026-06-10	138.3900	-3.2508	\N	99728.09	51.0249	FINNHUB	2026-06-09 23:13:21.564007+00	\N
1167	4221	2026-06-10	81.9800	1.5987	\N	104610.95	21.7849	FINNHUB	2026-06-09 23:13:24.921104+00	\N
1168	4222	2026-06-10	92.9500	1.8295	\N	104134.45	23.8676	FINNHUB	2026-06-09 23:13:28.322303+00	\N
1169	4223	2026-06-10	50.6800	1.6038	\N	104134.45	23.8676	FINNHUB	2026-06-09 23:13:31.700727+00	\N
1170	4224	2026-06-10	691.9500	-0.2681	\N	106331.88	96.2502	FINNHUB	2026-06-09 23:13:35.075513+00	\N
1171	4225	2026-06-10	390.9000	-0.8472	\N	111421.39	95.1532	FINNHUB	2026-06-09 23:13:38.926654+00	\N
1172	4226	2026-06-10	393.6100	0.5595	\N	104706.81	40.5212	FINNHUB	2026-06-09 23:13:42.284529+00	\N
1173	4227	2026-06-10	51.2500	1.2046	\N	76688.90	13.1564	FINNHUB	2026-06-09 23:13:45.635981+00	\N
1174	4228	2026-06-10	496.2200	-1.3734	\N	102138.22	32.6103	FINNHUB	2026-06-09 23:13:48.977389+00	\N
1175	4229	2026-06-10	237.8800	-2.9022	\N	99024.96	13.7382	FINNHUB	2026-06-09 23:13:52.352522+00	\N
1176	4230	2026-06-10	470.7600	2.5800	\N	101446.78	35.0046	FINNHUB	2026-06-09 23:13:55.685971+00	\N
1177	4231	2026-06-10	257.1600	4.3034	\N	98646.50	56.5634	FINNHUB	2026-06-09 23:13:59.182258+00	\N
1178	4232	2026-06-10	110.7500	1.1231	\N	141725.10	14.4352	FINNHUB	2026-06-09 23:14:02.623005+00	\N
1179	4233	2026-06-10	45.5100	2.8940	\N	100943.09	75.5562	FINNHUB	2026-06-09 23:14:05.995908+00	\N
1180	4234	2026-06-10	81.7000	0.9514	\N	139288.67	14.5883	FINNHUB	2026-06-09 23:14:09.405369+00	\N
1181	4235	2026-06-10	143.2500	1.0368	\N	98255.09	\N	FINNHUB	2026-06-09 23:14:12.744067+00	\N
1182	4236	2026-06-10	123.8200	1.4502	\N	94975.63	18.4813	FINNHUB	2026-06-09 23:14:16.078756+00	\N
1183	4237	2026-06-10	44.8100	-3.1972	\N	134878.95	13.8907	FINNHUB	2026-06-09 23:14:20.658295+00	\N
1184	4238	2026-06-10	26.2900	2.2957	\N	8963266.00	16.5350	FINNHUB	2026-06-09 23:14:23.983826+00	\N
1185	4239	2026-06-10	345.6800	1.4141	\N	92545.26	21.3189	FINNHUB	2026-06-09 23:14:27.503984+00	\N
1186	4240	2026-06-10	36.5900	-2.6862	\N	901920.80	17.2703	FINNHUB	2026-06-09 23:14:30.88564+00	\N
1187	4241	2026-06-10	255.9400	1.5514	\N	93055.70	21.7914	FINNHUB	2026-06-09 23:14:34.385299+00	\N
1188	4242	2026-06-10	784.2300	2.2944	\N	93009.09	19.5315	FINNHUB	2026-06-09 23:14:37.783199+00	\N
1189	4243	2026-06-10	231.1700	0.9145	\N	91613.10	21.0823	FINNHUB	2026-06-09 23:14:41.30758+00	\N
1190	4244	2026-06-10	107.8700	0.1578	\N	91545.69	17.4406	FINNHUB	2026-06-09 23:14:44.735526+00	\N
1191	4245	2026-06-10	232.1800	2.2189	\N	92881.90	12.8734	FINNHUB	2026-06-09 23:14:48.093893+00	\N
1192	4246	2026-06-10	64.2500	0.5320	\N	91356.93	33.4273	FINNHUB	2026-06-09 23:14:51.468547+00	\N
1193	4247	2026-06-10	251.6500	0.3910	\N	90539.52	23.8828	FINNHUB	2026-06-09 23:14:54.994662+00	\N
1194	4248	2026-06-10	190.8300	0.9149	\N	89488.74	30.8550	FINNHUB	2026-06-09 23:14:58.34553+00	\N
1195	4249	2026-06-10	424.4300	1.5019	\N	91366.72	17.4264	FINNHUB	2026-06-09 23:15:01.801965+00	\N
1196	4250	2026-06-10	669.2300	-0.5129	\N	93822.45	35.1001	FINNHUB	2026-06-09 23:15:05.228332+00	\N
1197	4251	2026-06-10	465.2700	-1.7340	\N	92095.81	119.0995	FINNHUB	2026-06-09 23:15:08.580843+00	\N
1198	4252	2026-06-10	221.3000	2.3873	\N	86796.59	31.0653	FINNHUB	2026-06-09 23:15:11.957069+00	\N
1199	4253	2026-06-10	236.1300	-4.7056	\N	87585.41	\N	FINNHUB	2026-06-09 23:15:15.283715+00	\N
1200	4254	2026-06-10	71.5900	0.0000	\N	87554.44	31.3590	FINNHUB	2026-06-09 23:15:18.640004+00	\N
1201	4255	2026-06-10	147.7500	2.5686	\N	89528.37	25.3550	FINNHUB	2026-06-09 23:15:22.030316+00	\N
1202	4256	2026-06-10	90.1500	1.8989	\N	86739.54	42.6884	FINNHUB	2026-06-09 23:15:25.546941+00	\N
1203	4257	2026-06-10	47.2800	0.3609	\N	87824.94	28.7951	FINNHUB	2026-06-09 23:15:28.929084+00	\N
1204	4258	2026-06-10	56.0200	1.2105	\N	85919.78	11.0069	FINNHUB	2026-06-09 23:15:32.266081+00	\N
1205	4259	2026-06-10	29.2700	0.5496	\N	71988.47	7.4437	FINNHUB	2026-06-09 23:15:35.609938+00	\N
1206	4260	2026-06-10	23.8500	0.3788	\N	85165.50	4.5308	FINNHUB	2026-06-09 23:15:39.082078+00	\N
1207	4261	2026-06-10	7.5300	1.3459	\N	433146.44	12.4292	FINNHUB	2026-06-09 23:15:42.428762+00	\N
1208	4262	2026-06-10	13.8500	-5.0720	\N	73006.20	93.4778	FINNHUB	2026-06-09 23:15:45.822111+00	\N
1209	4263	2026-06-10	95.8400	2.8216	\N	83690.73	28.2585	FINNHUB	2026-06-09 23:15:49.138336+00	\N
1210	4264	2026-06-10	227.3400	-1.8733	\N	82468.86	607.8502	FINNHUB	2026-06-09 23:15:52.457585+00	\N
1211	4265	2026-06-10	24.3200	0.3714	\N	61681.87	5.5770	FINNHUB	2026-06-09 23:15:55.793963+00	\N
1212	4266	2026-06-10	239.6600	-0.3286	\N	83339.97	\N	FINNHUB	2026-06-09 23:15:59.215249+00	\N
1213	4267	2026-06-10	374.9000	3.7584	\N	82442.33	12.1346	FINNHUB	2026-06-09 23:16:02.754233+00	\N
1214	4268	2026-06-10	55.8500	-1.2378	\N	82467.38	24.7724	FINNHUB	2026-06-09 23:16:06.093245+00	\N
1215	4269	2026-06-10	159.9300	-1.3448	\N	113223.62	15.2104	FINNHUB	2026-06-09 23:16:09.465645+00	\N
1216	4270	2026-06-10	37.3500	-0.4531	\N	81175.21	13.7515	FINNHUB	2026-06-09 23:16:12.841361+00	\N
1217	4271	2026-06-10	1641.1600	1.8096	\N	83190.27	43.3283	FINNHUB	2026-06-09 23:16:16.205128+00	\N
1218	4272	2026-06-10	293.7800	-3.8395	\N	83844.56	18.2907	FINNHUB	2026-06-09 23:16:19.58946+00	\N
1219	4273	2026-06-10	81.0800	1.1351	\N	59832.92	18.4613	FINNHUB	2026-06-09 23:16:22.935881+00	\N
1220	4274	2026-06-10	35.0800	-1.2387	\N	2369461.80	50.1442	FINNHUB	2026-06-09 23:16:26.35311+00	\N
1221	4275	2026-06-10	156.3900	1.6510	\N	81917.36	29.3927	FINNHUB	2026-06-09 23:16:29.724446+00	\N
1222	4276	2026-06-10	141.5600	1.8051	\N	78413.97	19.9476	FINNHUB	2026-06-09 23:16:33.08916+00	\N
1223	4277	2026-06-10	211.8900	2.1945	\N	68718.58	14.6413	FINNHUB	2026-06-09 23:16:36.542455+00	\N
1224	4278	2026-06-10	53.5600	-1.3991	\N	68732.74	15.3353	FINNHUB	2026-06-09 23:16:39.887356+00	\N
1225	4279	2026-06-10	90.2000	0.1666	\N	111615.10	27.3768	FINNHUB	2026-06-09 23:16:43.284102+00	\N
1226	4280	2026-06-10	165.5200	1.8459	\N	79529.82	20.2624	FINNHUB	2026-06-09 23:16:46.66546+00	\N
1227	4281	2026-06-10	62.9300	2.1591	\N	79714.65	30.4836	FINNHUB	2026-06-09 23:16:50.03789+00	\N
1228	4282	2026-06-10	131.3500	-2.2912	\N	81021.62	32.1898	FINNHUB	2026-06-09 23:16:53.378217+00	\N
1229	4283	2026-06-10	331.7600	0.4664	\N	79318.85	17.6893	FINNHUB	2026-06-09 23:16:56.715759+00	\N
1230	4284	2026-06-10	449.9400	1.3926	\N	78321.51	31.3914	FINNHUB	2026-06-09 23:17:00.052696+00	\N
1231	4285	2026-06-10	342.5700	0.5695	\N	77355.49	50.1657	FINNHUB	2026-06-09 23:17:03.493571+00	\N
1232	4286	2026-06-10	142.4200	2.4089	\N	79551.00	32.5495	FINNHUB	2026-06-09 23:17:06.857437+00	\N
1233	4287	2026-06-10	548.6700	1.4534	\N	76877.03	16.8001	FINNHUB	2026-06-09 23:17:10.251519+00	\N
1234	4288	2026-06-10	5.3400	0.7547	\N	57700.72	9.1719	FINNHUB	2026-06-09 23:17:13.759237+00	\N
1235	4289	2026-06-10	120.7300	1.7102	\N	74747.99	14.8295	FINNHUB	2026-06-09 23:17:17.176348+00	\N
1236	4290	2026-06-10	295.0000	1.8611	\N	76835.77	12.2194	FINNHUB	2026-06-09 23:17:20.57818+00	\N
1237	4291	2026-06-10	258.1500	-3.0131	\N	77704.77	16.7756	FINNHUB	2026-06-09 23:17:24.088095+00	\N
1238	4292	2026-06-10	253.7800	-1.7841	\N	76724.47	18.2417	FINNHUB	2026-06-09 23:17:27.472839+00	\N
1239	4293	2026-06-10	282.2600	3.7721	\N	72949.03	16.2869	FINNHUB	2026-06-09 23:17:30.818133+00	\N
1240	4294	2026-06-10	259.6100	2.3820	\N	73844.48	12240.0928	FINNHUB	2026-06-09 23:17:34.149878+00	\N
1241	4295	2026-06-10	310.5500	3.6722	\N	76084.62	29.2712	FINNHUB	2026-06-09 23:17:37.503316+00	\N
1242	4296	2026-06-10	89.4900	0.5280	\N	73747.35	28.3218	FINNHUB	2026-06-09 23:17:40.831107+00	\N
1243	4297	2026-06-10	297.4100	-1.2386	\N	76029.15	28.6578	FINNHUB	2026-06-09 23:17:44.151313+00	\N
1244	4298	2026-06-10	25.2700	1.6492	\N	1321162.90	15.0960	FINNHUB	2026-06-09 23:17:47.484498+00	\N
1245	4299	2026-06-10	83.7700	-1.4934	\N	76647.01	40.4043	FINNHUB	2026-06-09 23:17:50.81477+00	\N
1246	4300	2026-06-10	83.7600	-0.0119	\N	75532.48	29.7606	FINNHUB	2026-06-09 23:17:54.135966+00	\N
1247	4301	2026-06-10	229.4500	0.8926	\N	72862.21	31.4636	FINNHUB	2026-06-09 23:17:57.55001+00	\N
1248	4302	2026-06-10	47.1500	2.5669	\N	73404.27	29.1171	FINNHUB	2026-06-09 23:18:00.885149+00	\N
1249	4303	2026-06-10	132.7000	4.0213	\N	73546.34	64.2888	FINNHUB	2026-06-09 23:18:04.239003+00	\N
1250	4304	2026-06-10	355.9400	-11.4423	\N	77922.16	166.1988	FINNHUB	2026-06-09 23:18:07.614813+00	\N
1251	4305	2026-06-10	61.2000	-3.2411	\N	104602.46	16.5275	FINNHUB	2026-06-09 23:18:11.011699+00	\N
1252	4306	2026-06-10	69.6100	0.2304	\N	75988.77	52.7334	FINNHUB	2026-06-09 23:18:14.347781+00	\N
1253	4307	2026-06-10	179.0000	-2.4098	\N	73539.50	17.8364	FINNHUB	2026-06-09 23:18:17.680964+00	\N
1254	4308	2026-06-10	137.3300	-2.0121	\N	72890.20	13.2600	FINNHUB	2026-06-09 23:18:21.073871+00	\N
1255	4309	2026-06-10	120.3100	-0.4139	\N	102333.41	21.7499	FINNHUB	2026-06-09 23:18:24.444847+00	\N
1256	4310	2026-06-10	1531.9800	-1.7445	\N	79347.66	116.5304	FINNHUB	2026-06-09 23:18:27.774006+00	\N
1257	4311	2026-06-10	256.5500	1.6482	\N	73678.53	23.5094	FINNHUB	2026-06-09 23:18:31.139018+00	\N
1258	4312	2026-06-10	264.4400	2.7311	\N	73573.39	34.9401	FINNHUB	2026-06-09 23:18:34.484914+00	\N
1259	4313	2026-06-10	48.9600	0.5339	\N	72734.79	20.4025	FINNHUB	2026-06-09 23:18:37.87082+00	\N
1260	4314	2026-06-10	179.8700	3.5849	\N	71519.58	36.9184	FINNHUB	2026-06-09 23:18:41.237173+00	\N
1261	4315	2026-06-10	68.1700	-0.1172	\N	95830.00	27.8576	FINNHUB	2026-06-09 23:18:44.710673+00	\N
1262	4316	2026-06-10	87.8000	2.0100	\N	70664.72	33.8595	FINNHUB	2026-06-09 23:18:48.098778+00	\N
1263	4317	2026-06-10	31.3400	0.1598	\N	69726.04	21.0335	FINNHUB	2026-06-09 23:18:51.435915+00	\N
1264	4318	2026-06-10	312.3200	0.7711	\N	69766.75	26.1299	FINNHUB	2026-06-09 23:18:54.783878+00	\N
1265	4319	2026-06-10	127.7600	0.7809	\N	68976.20	18.8779	FINNHUB	2026-06-09 23:18:58.193536+00	\N
1266	4320	2026-06-10	103.7000	2.1373	\N	69492.82	18.9302	FINNHUB	2026-06-09 23:19:01.578259+00	\N
1267	4321	2026-06-10	331.5900	1.7615	\N	70471.85	17.8772	FINNHUB	2026-06-09 23:19:04.938537+00	\N
1268	4322	2026-06-10	1257.2400	4.2246	\N	68903.74	33.0950	FINNHUB	2026-06-09 23:19:08.358027+00	\N
1269	4323	2026-06-10	439.3400	-5.8564	\N	65610.48	149.6931	FINNHUB	2026-06-09 23:19:11.728053+00	\N
1270	4324	2026-06-10	155.6700	2.0854	\N	66442.75	71.7524	FINNHUB	2026-06-09 23:19:15.049827+00	\N
1271	4325	2026-06-10	414.0700	1.7871	\N	67568.50	32.3294	FINNHUB	2026-06-09 23:19:18.43125+00	\N
1272	4326	2026-06-10	821.7600	-8.2243	\N	63149.48	143.5542	FINNHUB	2026-06-09 23:19:21.79244+00	\N
1273	4327	2026-06-10	1094.1700	0.9335	\N	67912.01	27.0890	FINNHUB	2026-06-09 23:19:25.216449+00	\N
1274	4328	2026-06-10	184.9300	1.5262	\N	63920.76	46.3904	FINNHUB	2026-06-09 23:19:28.553185+00	\N
1275	4329	2026-06-10	19.0600	-1.4478	\N	66552.02	15.2502	FINNHUB	2026-06-09 23:19:32.008954+00	\N
1276	4330	2026-06-10	39.1500	-0.7856	\N	92245.34	10.8155	FINNHUB	2026-06-09 23:19:35.360558+00	\N
1277	4331	2026-06-10	26.5600	0.3400	\N	66363.91	\N	FINNHUB	2026-06-09 23:19:38.856039+00	\N
1278	4332	2026-06-10	15.1400	1.0007	\N	367651.22	23.5629	FINNHUB	2026-06-09 23:19:42.264256+00	\N
1279	4333	2026-06-10	48.2700	-3.2083	\N	63012.22	40.4963	FINNHUB	2026-06-09 23:19:45.592349+00	\N
1280	4334	2026-06-10	1831.5600	-1.1053	\N	63198.22	51.6474	FINNHUB	2026-06-09 23:19:48.924229+00	\N
1281	4335	2026-06-10	38.8600	-0.0771	\N	90963.31	14.1732	FINNHUB	2026-06-09 23:19:52.423165+00	\N
1282	4336	2026-06-10	616.1800	0.7917	\N	65301.61	14.7628	FINNHUB	2026-06-09 23:19:55.828179+00	\N
1283	4337	2026-06-10	210.1800	2.5619	\N	63428.03	29.2430	FINNHUB	2026-06-09 23:19:59.252988+00	\N
1284	4338	2026-06-10	300.2500	1.1863	\N	63234.15	8.3159	FINNHUB	2026-06-09 23:20:02.862496+00	\N
1285	4339	2026-06-10	73.3200	-2.2530	\N	58313.65	225.5713	FINNHUB	2026-06-09 23:20:06.264328+00	\N
1286	4340	2026-06-10	108.2300	-4.7690	\N	65788.29	\N	FINNHUB	2026-06-09 23:20:09.601939+00	\N
1287	4341	2026-06-10	44.6500	3.2848	\N	65669.95	29.1866	FINNHUB	2026-06-09 23:20:12.978118+00	\N
1288	4342	2026-06-10	16.0500	0.8800	\N	47267.99	7.8859	FINNHUB	2026-06-09 23:20:16.445386+00	\N
1289	4343	2026-06-10	282.9800	2.2437	\N	62290.47	29.5594	FINNHUB	2026-06-09 23:20:19.977689+00	\N
1290	4344	2026-06-10	63.5500	-1.9895	\N	64325.73	20.6437	FINNHUB	2026-06-09 23:20:23.443035+00	\N
1291	4345	2026-06-10	210.9100	2.5777	\N	62054.13	21.3538	FINNHUB	2026-06-09 23:20:26.870053+00	\N
1292	4346	2026-06-10	34.9400	1.2167	\N	45770.40	22.1648	FINNHUB	2026-06-09 23:20:30.457804+00	\N
1293	4347	2026-06-10	119.6900	1.0554	\N	62025.47	25.0507	FINNHUB	2026-06-09 23:20:33.954592+00	\N
1294	4348	2026-06-10	1329.8000	1.9340	\N	62304.55	34.9633	FINNHUB	2026-06-09 23:20:37.396298+00	\N
1295	4349	2026-06-10	49.4300	1.2288	\N	60836.29	11.0071	FINNHUB	2026-06-09 23:20:40.779513+00	\N
1296	4350	2026-06-10	357.5200	1.6924	\N	59281.34	37.0940	FINNHUB	2026-06-09 23:20:44.133011+00	\N
1297	4351	2026-06-10	115.6100	0.3211	\N	58752.13	12.6730	FINNHUB	2026-06-09 23:20:47.502351+00	\N
1298	4352	2026-06-10	90.8700	2.1011	\N	58328.77	29.8052	FINNHUB	2026-06-09 23:20:50.871023+00	\N
1299	4353	2026-06-10	31.9000	1.7544	\N	51159.25	7.2249	FINNHUB	2026-06-09 23:20:54.290035+00	\N
1300	4354	2026-06-10	14.9500	-0.3333	\N	60866.18	\N	FINNHUB	2026-06-09 23:20:57.691083+00	\N
1301	4355	2026-06-10	118.9800	-2.9131	\N	82762.06	28.3432	FINNHUB	2026-06-09 23:21:01.096578+00	\N
1302	4356	2026-06-10	66.2500	1.1142	\N	58184.15	19.6967	FINNHUB	2026-06-09 23:21:04.617549+00	\N
1303	4357	2026-06-10	220.1200	0.9725	\N	57328.48	70.1523	FINNHUB	2026-06-09 23:21:07.975021+00	\N
1304	4358	2026-06-10	11.8800	2.4138	\N	56382.95	17.7096	FINNHUB	2026-06-09 23:21:11.394134+00	\N
1305	4359	2026-06-10	254.3200	0.3631	\N	56885.13	24.4037	FINNHUB	2026-06-09 23:21:14.755307+00	\N
1306	4360	2026-06-10	308.1700	2.0093	\N	56279.70	32.4941	FINNHUB	2026-06-09 23:21:18.105848+00	\N
1307	4361	2026-06-10	56.5000	0.1595	\N	57241.13	12.1841	FINNHUB	2026-06-09 23:21:21.457248+00	\N
1308	4362	2026-06-10	61.2500	2.0663	\N	56798.12	50.6881	FINNHUB	2026-06-09 23:21:24.795516+00	\N
1309	4363	2026-06-10	217.1800	1.0046	\N	55788.27	4.5939	FINNHUB	2026-06-09 23:21:28.147557+00	\N
1310	4364	2026-06-10	264.1700	0.0151	\N	56693.90	26.5906	FINNHUB	2026-06-09 23:21:31.482974+00	\N
1311	4365	2026-06-10	56.5500	-1.6180	\N	55848.74	11.7949	FINNHUB	2026-06-09 23:21:34.817743+00	\N
1312	4366	2026-06-10	331.4300	-0.0513	\N	57840.40	54.8770	FINNHUB	2026-06-09 23:21:38.59356+00	\N
1313	4367	2026-06-10	369.2100	-1.4625	\N	58654.78	68.6777	FINNHUB	2026-06-09 23:21:42.001004+00	\N
1314	4368	2026-06-10	71.2400	5.7758	\N	55939.60	42.7020	FINNHUB	2026-06-09 23:21:45.331306+00	\N
1315	4369	2026-06-10	126.6100	2.1295	\N	57141.79	16.5628	FINNHUB	2026-06-09 23:21:48.721001+00	\N
1316	4370	2026-06-10	147.2100	-2.4001	\N	54084.71	61.4599	FINNHUB	2026-06-09 23:21:52.105984+00	\N
1317	4371	2026-06-10	87.7900	-0.4084	\N	54995.57	15.5751	FINNHUB	2026-06-09 23:21:55.499894+00	\N
1318	4372	2026-06-10	217.0500	2.1316	\N	55803.82	34.6263	FINNHUB	2026-06-09 23:21:58.985251+00	\N
1319	4373	2026-06-10	884.0000	0.1802	\N	47229.42	24.3035	FINNHUB	2026-06-09 23:22:02.393865+00	\N
1320	4374	2026-06-10	98.4500	-3.8292	\N	55850.04	\N	FINNHUB	2026-06-09 23:22:05.872806+00	\N
1321	4375	2026-06-10	322.8600	3.7868	\N	56455.51	29.6692	FINNHUB	2026-06-09 23:22:09.254556+00	\N
1322	4376	2026-06-10	85.5700	1.4103	\N	54518.40	15.0645	FINNHUB	2026-06-09 23:22:12.642435+00	\N
1323	4377	2026-06-10	341.7000	-1.3369	\N	59363.71	221.8168	FINNHUB	2026-06-09 23:22:15.971973+00	\N
1324	4378	2026-06-10	194.2400	-1.9955	\N	55754.90	196.3201	FINNHUB	2026-06-09 23:22:19.414247+00	\N
1325	4379	2026-06-10	46.5800	1.2609	\N	53354.55	41.0546	FINNHUB	2026-06-09 23:22:22.763529+00	\N
1326	4380	2026-06-10	279.5700	2.0031	\N	53325.30	20.9227	FINNHUB	2026-06-09 23:22:26.128387+00	\N
1327	4381	2026-06-10	84.8700	0.4498	\N	51748.82	32.2818	FINNHUB	2026-06-09 23:22:29.459967+00	\N
1328	4382	2026-06-10	27.6500	-3.7256	\N	73630.41	15.8652	FINNHUB	2026-06-09 23:22:32.800802+00	\N
1329	4383	2026-06-10	112.5800	-1.9936	\N	72728.13	29.0006	FINNHUB	2026-06-09 23:22:36.320225+00	\N
1330	4384	2026-06-10	19.8800	-0.6000	\N	1521815.20	30.3689	FINNHUB	2026-06-09 23:22:39.650073+00	\N
1331	4385	2026-06-10	66.3100	-1.2950	\N	43691.56	17.2943	FINNHUB	2026-06-09 23:22:43.016733+00	\N
1332	4386	2026-06-10	229.8000	1.7039	\N	51788.42	33.8987	FINNHUB	2026-06-09 23:22:46.365191+00	\N
1333	4387	2026-06-10	81.1700	3.7847	\N	53269.10	11.8984	FINNHUB	2026-06-09 23:22:49.717394+00	\N
1334	4388	2026-06-10	75.0100	-1.1205	\N	50736.68	43.6632	FINNHUB	2026-06-09 23:22:53.040945+00	\N
1335	4389	2026-06-10	44.0700	-2.2405	\N	51274.54	22.6078	FINNHUB	2026-06-09 23:22:56.420291+00	\N
1336	4390	2026-06-10	3137.7500	2.0725	\N	51623.11	20.8315	FINNHUB	2026-06-09 23:22:59.791437+00	\N
1337	4391	2026-06-10	202.4800	-0.3543	\N	50767.15	57.2347	FINNHUB	2026-06-09 23:23:04.003644+00	\N
1338	4392	2026-06-10	12.2400	-0.3257	\N	4816977.50	16.3620	FINNHUB	2026-06-09 23:23:07.463278+00	\N
1339	4393	2026-06-10	109.6600	1.4337	\N	49431.18	27.4357	FINNHUB	2026-06-09 23:23:10.829129+00	\N
1340	4394	2026-06-10	248.7300	0.6963	\N	50968.86	50.5994	FINNHUB	2026-06-09 23:23:14.224125+00	\N
1341	4395	2026-06-10	146.2200	-0.4629	\N	50159.27	22.3825	FINNHUB	2026-06-09 23:23:17.588804+00	\N
1342	4396	2026-06-10	239.4000	1.1792	\N	49604.07	33.6299	FINNHUB	2026-06-09 23:23:20.967169+00	\N
1343	4397	2026-06-10	460.4700	1.9506	\N	50532.29	46.4451	FINNHUB	2026-06-09 23:23:24.416856+00	\N
1344	4398	2026-06-10	87.5400	1.9686	\N	50457.35	46.0293	FINNHUB	2026-06-09 23:23:27.772973+00	\N
1345	4399	2026-06-10	87.5200	0.8527	\N	49507.45	25.8930	FINNHUB	2026-06-09 23:23:31.1137+00	\N
1346	4400	2026-06-10	77.8700	0.3221	\N	48455.81	23.1735	FINNHUB	2026-06-09 23:23:34.517154+00	\N
1347	4401	2026-06-10	3.1200	1.6287	\N	253410.60	16.2675	FINNHUB	2026-06-09 23:23:37.890942+00	\N
1348	4402	2026-06-10	65.8100	-0.3181	\N	41154.75	46.3454	FINNHUB	2026-06-09 23:23:41.258514+00	\N
1349	4403	2026-06-10	15.7200	-0.1271	\N	8005531.50	41.7472	FINNHUB	2026-06-09 23:23:44.609537+00	\N
1350	4404	2026-06-10	224.0800	-0.4266	\N	47897.00	32.7389	FINNHUB	2026-06-09 23:23:47.982018+00	\N
1351	4405	2026-06-10	108.6600	0.2029	\N	47767.74	23.4156	FINNHUB	2026-06-09 23:23:51.327916+00	\N
1352	4406	2026-06-10	212.6700	4.0053	\N	48297.93	31.0598	FINNHUB	2026-06-09 23:23:54.733627+00	\N
1353	4407	2026-06-10	91.4700	0.1094	\N	48933.49	212.7543	FINNHUB	2026-06-09 23:23:58.093794+00	\N
1354	4408	2026-06-10	52.7100	1.4434	\N	47391.03	21.8090	FINNHUB	2026-06-09 23:24:01.552144+00	\N
1355	4409	2026-06-10	45.3300	1.1830	\N	45839.72	16.4950	FINNHUB	2026-06-09 23:24:04.968101+00	\N
1356	4410	2026-06-10	326.4200	0.9026	\N	38071.57	48.2147	FINNHUB	2026-06-09 23:24:08.347034+00	\N
1357	4411	2026-06-10	117.0000	-3.2258	\N	44602.50	77.7453	FINNHUB	2026-06-09 23:24:11.691028+00	\N
1358	4412	2026-06-10	237.8500	1.1138	\N	45606.63	26.2681	FINNHUB	2026-06-09 23:24:15.021928+00	\N
1359	4413	2026-06-10	102.2700	-3.0064	\N	44173.93	94.6132	FINNHUB	2026-06-09 23:24:18.394187+00	\N
1360	4414	2026-06-10	607.5400	0.7629	\N	44043.54	33.3738	FINNHUB	2026-06-09 23:24:21.741195+00	\N
1361	4415	2026-06-10	163.2500	0.8899	\N	44374.06	14.4777	FINNHUB	2026-06-09 23:24:25.103589+00	\N
1362	4416	2026-06-10	235.4400	4.9712	\N	44985.82	18.2129	FINNHUB	2026-06-09 23:24:28.462924+00	\N
1363	4417	2026-06-10	80.4100	0.2119	\N	33431.83	18.5521	FINNHUB	2026-06-09 23:24:31.825252+00	\N
1364	4418	2026-06-10	578.8900	3.1577	\N	45364.04	41.4195	FINNHUB	2026-06-09 23:24:35.371868+00	\N
1365	4419	2026-06-10	265.7700	2.3649	\N	44053.33	36.4077	FINNHUB	2026-06-09 23:24:38.886909+00	\N
1366	4420	2026-06-10	36.0100	6.5385	\N	44402.66	45.9655	FINNHUB	2026-06-09 23:24:42.212301+00	\N
1367	4421	2026-06-10	226.8150	-4.6315	\N	52229.93	\N	FINNHUB	2026-06-09 23:24:45.572014+00	\N
1368	4422	2026-06-10	371.8600	-3.7878	\N	61886.58	46.3322	FINNHUB	2026-06-09 23:24:49.06172+00	\N
1369	4423	2026-06-10	11.8600	-5.2716	\N	396929.84	15.7718	FINNHUB	2026-06-09 23:24:52.453103+00	\N
1370	4424	2026-06-10	84.4300	-0.0474	\N	42657.98	12.2792	FINNHUB	2026-06-09 23:24:55.816747+00	\N
1371	4425	2026-06-10	117.0200	-8.0031	\N	43690.31	\N	FINNHUB	2026-06-09 23:24:59.180943+00	\N
1372	4426	2026-06-10	212.1600	-1.2061	\N	57742.88	30.2285	FINNHUB	2026-06-09 23:25:02.547063+00	\N
1373	4427	2026-06-10	363.1800	2.0226	\N	42804.33	37.8799	FINNHUB	2026-06-09 23:25:05.936796+00	\N
1374	4428	2026-06-10	38.9000	0.9603	\N	6359770.50	14.2192	FINNHUB	2026-06-09 23:25:09.812695+00	\N
1375	4429	2026-06-10	152.0400	1.3668	\N	41102.37	36.1181	FINNHUB	2026-06-09 23:25:13.191975+00	\N
1376	4430	2026-06-10	151.6300	2.8907	\N	40618.30	23.3707	FINNHUB	2026-06-09 23:25:16.539267+00	\N
1377	4431	2026-06-10	21.7200	0.1845	\N	58287.73	15.1331	FINNHUB	2026-06-09 23:25:19.981649+00	\N
1378	4432	2026-06-10	31.4800	2.3740	\N	41837.20	22.8369	FINNHUB	2026-06-09 23:25:23.337217+00	\N
1379	4433	2026-06-10	96.8700	1.7008	\N	42934.49	19.1149	FINNHUB	2026-06-09 23:25:26.700526+00	\N
1380	4434	2026-06-10	130.6100	2.9479	\N	28168.75	45.2306	FINNHUB	2026-06-09 23:25:30.191322+00	\N
1381	4435	2026-06-10	75.2600	-2.6517	\N	42398.07	54.4263	FINNHUB	2026-06-09 23:25:33.680857+00	\N
1382	4436	2026-06-10	121.1100	1.6877	\N	40900.65	708.3553	FINNHUB	2026-06-09 23:25:37.1239+00	\N
1383	4437	2026-06-10	151.0700	4.7061	\N	40914.87	12.8963	FINNHUB	2026-06-09 23:25:40.490904+00	\N
1384	4438	2026-06-10	92.5700	0.8498	\N	40452.55	38.1988	FINNHUB	2026-06-09 23:25:43.878611+00	\N
1385	4439	2026-06-10	68.2900	-2.3312	\N	41615.06	51.5623	FINNHUB	2026-06-09 23:25:47.209635+00	\N
1386	4440	2026-06-10	73.9700	0.6121	\N	56893.34	17.3455	FINNHUB	2026-06-09 23:25:50.628895+00	\N
1387	4441	2026-06-10	449.1900	-0.0423	\N	40397.95	10.3717	FINNHUB	2026-06-09 23:25:53.989751+00	\N
1388	4442	2026-06-10	297.6900	1.8928	\N	40336.15	69.8804	FINNHUB	2026-06-09 23:25:57.381832+00	\N
1389	4443	2026-06-10	82.4700	3.5795	\N	38708.83	148.6372	FINNHUB	2026-06-09 23:26:00.730308+00	\N
1390	4444	2026-06-10	155.5000	-4.0775	\N	42709.66	53.3469	FINNHUB	2026-06-09 23:26:04.157365+00	\N
1391	4445	2026-06-10	90.3100	1.4263	\N	40127.36	33.4768	FINNHUB	2026-06-09 23:26:07.497858+00	\N
1392	4446	2026-06-10	73.9200	-0.2429	\N	39219.36	12.4073	FINNHUB	2026-06-09 23:26:10.847096+00	\N
1393	4447	2026-06-10	9.1200	2.5872	\N	29810.89	17.8830	FINNHUB	2026-06-09 23:26:14.21923+00	\N
1394	4448	2026-06-10	34.4500	3.5779	\N	118676.70	25.7760	FINNHUB	2026-06-09 23:26:17.646287+00	\N
1395	4449	2026-06-10	212.0500	-0.2352	\N	39437.45	\N	FINNHUB	2026-06-09 23:26:21.024314+00	\N
1396	4450	2026-06-10	78.5900	1.0934	\N	38896.48	17.1880	FINNHUB	2026-06-09 23:26:24.419536+00	\N
1397	4451	2026-06-10	157.5800	2.5177	\N	54543.55	37.1250	FINNHUB	2026-06-09 23:26:27.79219+00	\N
1398	4452	2026-06-10	452.5100	-3.9379	\N	37968.42	184.3234	FINNHUB	2026-06-09 23:26:31.136536+00	\N
1399	4453	2026-06-10	106.4000	2.0036	\N	39268.68	18.2221	FINNHUB	2026-06-09 23:26:34.517166+00	\N
1400	4454	2026-06-10	102.2500	1.8528	\N	53864356.00	8.9353	FINNHUB	2026-06-09 23:26:37.938574+00	\N
1401	4455	2026-06-10	28.7300	0.4897	\N	280971.06	17.5732	FINNHUB	2026-06-09 23:26:41.281403+00	\N
1402	4456	2026-06-10	80.1200	-0.1247	\N	38383.02	35.5070	FINNHUB	2026-06-09 23:26:44.703542+00	\N
1403	4457	2026-06-10	62.9900	0.0476	\N	38972.80	38.3591	FINNHUB	2026-06-09 23:26:48.059161+00	\N
1404	4458	2026-06-10	204.4400	0.9032	\N	38724.10	169.3071	FINNHUB	2026-06-09 23:26:51.474542+00	\N
1405	4459	2026-06-10	241.8300	0.9729	\N	38071.57	48.2147	FINNHUB	2026-06-09 23:26:54.967663+00	\N
1406	4460	2026-06-10	269.8000	0.9731	\N	38145.00	27.8049	FINNHUB	2026-06-09 23:26:58.498849+00	\N
1407	4461	2026-06-10	837.5900	0.8950	\N	115816.90	66.9973	FINNHUB	2026-06-09 23:27:01.86033+00	\N
1408	4462	2026-06-10	136.1000	3.3331	\N	38566.87	29.3955	FINNHUB	2026-06-09 23:27:05.188263+00	\N
1409	4463	2026-06-10	135.4800	2.1026	\N	38282.24	27.0737	FINNHUB	2026-06-09 23:27:08.621351+00	\N
1410	4464	2026-06-10	234.3200	5.4213	\N	40997.69	86.8082	FINNHUB	2026-06-09 23:27:11.968123+00	\N
1411	4465	2026-06-10	27.7300	2.6657	\N	38662.62	12.4839	FINNHUB	2026-06-09 23:27:15.324615+00	\N
1412	4466	2026-06-10	122.2000	-0.2530	\N	646375.44	22.7096	FINNHUB	2026-06-09 23:27:18.697257+00	\N
1413	4467	2026-06-10	16.5800	0.6068	\N	36656.03	12.4089	FINNHUB	2026-06-09 23:27:22.060719+00	\N
1414	4468	2026-06-10	82.3200	-1.0339	\N	50690.89	23.8240	FINNHUB	2026-06-09 23:27:25.538659+00	\N
1415	4469	2026-06-10	29.8800	2.0840	\N	38296.02	26.3749	FINNHUB	2026-06-09 23:27:28.98352+00	\N
1416	4470	2026-06-10	86.3300	-1.1677	\N	148164.81	142.7407	FINNHUB	2026-06-09 23:27:32.358652+00	\N
1417	4471	2026-06-10	175.8400	-0.0341	\N	35617.31	32.5522	FINNHUB	2026-06-09 23:27:35.755646+00	\N
1418	4472	2026-06-10	362.3800	-0.4314	\N	37870.70	46.8117	FINNHUB	2026-06-09 23:27:39.215772+00	\N
1419	4473	2026-06-10	162.6600	1.9748	\N	36989.70	442.1168	FINNHUB	2026-06-09 23:27:42.578162+00	\N
1420	4474	2026-06-10	126.1400	2.1377	\N	37044.80	136.0421	FINNHUB	2026-06-09 23:27:45.950922+00	\N
1421	4475	2026-06-10	113.1000	1.6629	\N	36236.98	22.1106	FINNHUB	2026-06-09 23:27:49.441913+00	\N
1422	4476	2026-06-10	279.0000	3.3410	\N	35031.22	31.4661	FINNHUB	2026-06-09 23:27:52.781538+00	\N
1423	4477	2026-06-10	77.5500	1.3991	\N	37202.61	21.4301	FINNHUB	2026-06-09 23:27:56.138541+00	\N
1424	4478	2026-06-10	41.4600	0.4847	\N	36395.67	7.1942	FINNHUB	2026-06-09 23:27:59.460547+00	\N
1425	4479	2026-06-10	103.7000	-0.0193	\N	35713.24	10.3039	FINNHUB	2026-06-09 23:28:02.802441+00	\N
1426	4480	2026-06-10	88.7100	-3.6389	\N	35730.75	\N	FINNHUB	2026-06-09 23:28:06.145921+00	\N
1427	4481	2026-06-10	827.7800	0.4843	\N	36451.47	27.2509	FINNHUB	2026-06-09 23:28:09.52316+00	\N
1428	4482	2026-06-10	128.9700	1.0816	\N	35014.73	8.6201	FINNHUB	2026-06-09 23:28:12.893176+00	\N
1429	4483	2026-06-10	100.2800	1.3748	\N	35417.05	21.6393	FINNHUB	2026-06-09 23:28:16.293576+00	\N
1430	4484	2026-06-10	371.1500	2.1495	\N	35674.85	79.4101	FINNHUB	2026-06-09 23:28:19.675524+00	\N
1431	4485	2026-06-10	13.1800	6.7206	\N	34943.46	145.9730	FINNHUB	2026-06-09 23:28:23.043385+00	\N
1432	4486	2026-06-10	140.2300	-2.4555	\N	35508.72	41.9229	FINNHUB	2026-06-09 23:28:26.454321+00	\N
1433	4487	2026-06-10	26.7100	-0.9640	\N	5599435.50	\N	FINNHUB	2026-06-09 23:28:30.095065+00	\N
1434	4488	2026-06-10	58.0000	2.9647	\N	26154.75	12.0324	FINNHUB	2026-06-09 23:28:33.724271+00	\N
1435	4489	2026-06-10	45.1200	2.4989	\N	1074406.20	27.5326	FINNHUB	2026-06-09 23:28:37.077732+00	\N
1436	4490	2026-06-10	572.2500	3.2980	\N	33901.61	13.3787	FINNHUB	2026-06-09 23:28:40.424586+00	\N
1437	4491	2026-06-10	563.7800	-1.5696	\N	35181.49	37.3435	FINNHUB	2026-06-09 23:28:43.824229+00	\N
1438	4492	2026-06-10	109.6300	4.0923	\N	34060.38	9.2960	FINNHUB	2026-06-09 23:28:47.176928+00	\N
1439	4493	2026-06-10	204.6900	-3.6934	\N	31895.35	306.8159	FINNHUB	2026-06-09 23:28:50.850973+00	\N
1440	4494	2026-06-10	17.9200	2.1083	\N	33696.15	20.7744	FINNHUB	2026-06-09 23:28:54.219415+00	\N
1441	4495	2026-06-10	14.6700	-0.9453	\N	25882.60	\N	FINNHUB	2026-06-09 23:28:57.593299+00	\N
1442	4496	2026-06-10	116.7700	0.1286	\N	35068.88	\N	FINNHUB	2026-06-09 23:29:00.930566+00	\N
1443	4497	2026-06-10	52.6900	-0.5474	\N	32893.89	10.0154	FINNHUB	2026-06-09 23:29:04.356938+00	\N
1444	4498	2026-06-10	335.3700	0.4854	\N	33759.88	19.6954	FINNHUB	2026-06-09 23:29:07.755963+00	\N
1445	4499	2026-06-10	3.3300	1.2158	\N	169885.81	7.1449	FINNHUB	2026-06-09 23:29:11.122872+00	\N
1446	4500	2026-06-10	16.8200	2.0012	\N	33427.39	15.1461	FINNHUB	2026-06-09 23:29:14.51633+00	\N
1447	4501	2026-06-10	178.1100	4.0788	\N	32944.07	46.5612	FINNHUB	2026-06-09 23:29:17.857195+00	\N
1448	4502	2026-06-10	82.2000	4.2883	\N	33043.56	12.5023	FINNHUB	2026-06-09 23:29:21.224265+00	\N
1449	4503	2026-06-10	51.6500	1.6932	\N	34655.93	18.8143	FINNHUB	2026-06-09 23:29:24.659659+00	\N
1450	4504	2026-06-10	72.6700	1.6364	\N	32678.55	34.2184	FINNHUB	2026-06-09 23:29:28.141823+00	\N
1451	4505	2026-06-10	35.4900	-1.0870	\N	531116.30	9.0590	FINNHUB	2026-06-09 23:29:31.684158+00	\N
1452	4506	2026-06-10	100.5200	2.8338	\N	33257.10	15.6947	FINNHUB	2026-06-09 23:29:35.040361+00	\N
1453	4507	2026-06-10	65.9900	3.2546	\N	44968016.00	8.8072	FINNHUB	2026-06-09 23:29:38.424238+00	\N
1454	4508	2026-06-10	39.6200	-2.1728	\N	32927.20	21.3813	FINNHUB	2026-06-09 23:29:41.792234+00	\N
1455	4509	2026-06-10	165.0000	-3.1178	\N	33127.12	25.9617	FINNHUB	2026-06-09 23:29:45.146589+00	\N
1456	4510	2026-06-10	67.9000	2.7076	\N	26544.06	40.6501	FINNHUB	2026-06-09 23:29:48.538537+00	\N
1457	4511	2026-06-10	225.4300	1.2577	\N	33029.22	11.2689	FINNHUB	2026-06-09 23:29:51.993566+00	\N
1458	4512	2026-06-10	83.6300	2.8786	\N	33597.14	\N	FINNHUB	2026-06-09 23:29:55.350441+00	\N
1459	4513	2026-06-10	66.3500	-1.3823	\N	45236.91	13.6008	FINNHUB	2026-06-09 23:29:58.757766+00	\N
1460	4514	2026-06-10	55.6300	1.4036	\N	31592.90	38.1885	FINNHUB	2026-06-09 23:30:02.102848+00	\N
1461	4515	2026-06-10	148.2300	2.2276	\N	31344.79	33.2007	FINNHUB	2026-06-09 23:30:05.584243+00	\N
1462	4516	2026-06-10	24.9800	-2.3456	\N	23914.26	8.0531	FINNHUB	2026-06-09 23:30:09.16222+00	\N
1463	4517	2026-06-10	12.4700	-2.8816	\N	31799.78	11.3855	FINNHUB	2026-06-09 23:30:12.565917+00	\N
1464	4518	2026-06-10	90.4100	0.8928	\N	31308.80	6.4263	FINNHUB	2026-06-09 23:30:15.929494+00	\N
1465	4519	2026-06-10	149.5500	0.7139	\N	31568.45	\N	FINNHUB	2026-06-09 23:30:19.35362+00	\N
1466	4520	2026-06-10	61.3100	-2.3882	\N	29136.82	17.1362	FINNHUB	2026-06-09 23:30:22.799542+00	\N
1467	4521	2026-06-10	170.6000	0.8811	\N	31578.32	16.8832	FINNHUB	2026-06-09 23:30:26.250538+00	\N
1468	4522	2026-06-10	25.2700	-2.2815	\N	43047.31	10.7828	FINNHUB	2026-06-09 23:30:29.691777+00	\N
1469	4523	2026-06-10	65.2900	1.1307	\N	31250.53	12.3422	FINNHUB	2026-06-09 23:30:33.107257+00	\N
1470	4524	2026-06-10	15.8800	3.4528	\N	112042990.00	12.4101	FINNHUB	2026-06-09 23:30:36.451644+00	\N
1471	4525	2026-06-10	222.8200	4.3800	\N	31455.83	\N	FINNHUB	2026-06-09 23:30:40.124734+00	\N
1472	4526	2026-06-10	66.2100	1.8145	\N	32217.79	\N	FINNHUB	2026-06-09 23:30:43.593057+00	\N
1473	4527	2026-06-10	186.2500	1.3937	\N	31085.13	22.4441	FINNHUB	2026-06-09 23:30:47.02563+00	\N
1474	4528	2026-06-10	28.0200	2.2628	\N	29943.87	9.6460	FINNHUB	2026-06-09 23:30:50.380311+00	\N
1475	4529	2026-06-10	145.9500	1.9845	\N	29785.49	23.5645	FINNHUB	2026-06-09 23:30:53.724422+00	\N
1476	4530	2026-06-10	107.9900	0.7839	\N	29814.45	19.5633	FINNHUB	2026-06-09 23:30:57.098057+00	\N
1477	4531	2026-06-10	86.5600	2.2684	\N	31721.56	\N	FINNHUB	2026-06-09 23:31:00.475002+00	\N
1478	4532	2026-06-10	61.9000	-0.3060	\N	30323.43	33.6624	FINNHUB	2026-06-09 23:31:03.824555+00	\N
1479	4533	2026-06-10	47.0400	-0.3601	\N	245241.60	6.3649	FINNHUB	2026-06-09 23:31:07.230582+00	\N
1480	4534	2026-06-10	268.1700	-0.9712	\N	210235.03	66.4671	FINNHUB	2026-06-09 23:31:10.61358+00	\N
1481	4535	2026-06-10	262.1900	-4.7932	\N	28785.47	17.2853	FINNHUB	2026-06-09 23:31:14.09593+00	\N
1482	4536	2026-06-10	43.0000	1.6548	\N	30285.90	\N	FINNHUB	2026-06-09 23:31:17.455112+00	\N
1483	4537	2026-06-10	96.8300	-4.2709	\N	29798.26	14.3868	FINNHUB	2026-06-09 23:31:20.852273+00	\N
1484	4538	2026-06-10	52.6900	3.7205	\N	28078.99	24.2898	FINNHUB	2026-06-09 23:31:24.386333+00	\N
1485	4539	2026-06-10	144.7000	0.1731	\N	30239.05	65.4525	FINNHUB	2026-06-09 23:31:27.988537+00	\N
1486	4540	2026-06-10	151.3700	0.7857	\N	29715.76	13.8406	FINNHUB	2026-06-09 23:31:31.40498+00	\N
1487	4541	2026-06-10	290.6000	3.6672	\N	30412.39	24.6234	FINNHUB	2026-06-09 23:31:34.784667+00	\N
1488	4542	2026-06-10	66.0100	2.0721	\N	29417.85	15.4020	FINNHUB	2026-06-09 23:31:38.18334+00	\N
1489	4543	2026-06-10	54.0300	2.4848	\N	28331.79	8.8537	FINNHUB	2026-06-09 23:31:41.552085+00	\N
1490	4544	2026-06-10	220.9700	2.2110	\N	29665.91	26.9306	FINNHUB	2026-06-09 23:31:45.377159+00	\N
1491	4545	2026-06-10	199.1000	3.3641	\N	29155.38	21.2518	FINNHUB	2026-06-09 23:31:48.800721+00	\N
1492	4546	2026-06-10	31.3100	1.4582	\N	29010.31	18.6778	FINNHUB	2026-06-09 23:31:52.204176+00	\N
1493	4547	2026-06-10	55.7800	1.2709	\N	39029.21	21.6588	FINNHUB	2026-06-09 23:31:55.648951+00	\N
1494	4548	2026-06-10	48.1100	-0.5170	\N	39209.84	23.2011	FINNHUB	2026-06-09 23:31:59.192281+00	\N
1495	4549	2026-06-10	167.6200	-0.1608	\N	27974.09	20.7803	FINNHUB	2026-06-09 23:32:02.588649+00	\N
1496	4550	2026-06-10	353.0800	-2.3832	\N	28822.02	64.0519	FINNHUB	2026-06-09 23:32:05.970965+00	\N
1497	4551	2026-06-10	196.9400	1.9675	\N	28412.20	18.6976	FINNHUB	2026-06-09 23:32:09.359675+00	\N
1498	4552	2026-06-10	145.6200	3.3499	\N	29458.12	44.4450	FINNHUB	2026-06-09 23:32:12.773768+00	\N
1499	4553	2026-06-10	73.9100	2.0011	\N	28356.27	48.3071	FINNHUB	2026-06-09 23:32:16.107987+00	\N
1500	4554	2026-06-10	71.2600	0.5929	\N	27443.50	7.2621	FINNHUB	2026-06-09 23:32:19.47773+00	\N
1501	4555	2026-06-10	340.2800	-3.4831	\N	27213.74	\N	FINNHUB	2026-06-09 23:32:22.808902+00	\N
1502	4556	2026-06-10	761.1800	1.2706	\N	27834.22	42.8172	FINNHUB	2026-06-09 23:32:26.137129+00	\N
1503	4557	2026-06-10	78.1900	2.0491	\N	29978.47	32.2211	FINNHUB	2026-06-09 23:32:29.49736+00	\N
1504	4558	2026-06-10	9.8300	1.0277	\N	118592.19	12.4284	FINNHUB	2026-06-09 23:32:32.836376+00	\N
1505	4559	2026-06-10	68.3200	1.3049	\N	27119.68	15.8502	FINNHUB	2026-06-09 23:32:36.277522+00	\N
1506	4560	2026-06-10	167.6800	0.2631	\N	28169.73	29.9152	FINNHUB	2026-06-09 23:32:39.607676+00	\N
1507	4561	2026-06-10	42.3900	1.2903	\N	27641.93	25.8095	FINNHUB	2026-06-09 23:32:43.041043+00	\N
1508	4562	2026-06-10	619.2600	1.1235	\N	28418.06	30.4588	FINNHUB	2026-06-09 23:32:46.419965+00	\N
1509	4563	2026-06-10	231.0600	2.2842	\N	27732.20	18.6372	FINNHUB	2026-06-09 23:32:49.841168+00	\N
1510	4564	2026-06-10	129.9600	1.7618	\N	27431.40	114.7757	FINNHUB	2026-06-09 23:32:53.228324+00	\N
1511	4565	2026-06-10	15.9100	4.8090	\N	27249.07	\N	FINNHUB	2026-06-09 23:32:56.629819+00	\N
1512	4566	2026-06-10	733.5700	1.6969	\N	26528.56	51.9072	FINNHUB	2026-06-09 23:33:00.071167+00	\N
1513	4567	2026-06-10	186.8500	-0.4051	\N	26616.62	23.3390	FINNHUB	2026-06-09 23:33:03.436149+00	\N
1514	4568	2026-06-10	842.0100	-5.5894	\N	25724.49	74.2099	FINNHUB	2026-06-09 23:33:06.822141+00	\N
1515	4569	2026-06-10	65.6700	2.0513	\N	27872.15	14.1125	FINNHUB	2026-06-09 23:33:10.154772+00	\N
1516	4570	2026-06-10	71.2700	2.3553	\N	26718.15	18.0406	FINNHUB	2026-06-09 23:33:13.593226+00	\N
1517	4571	2026-06-10	35.7500	1.1315	\N	26794.96	21.9811	FINNHUB	2026-06-09 23:33:17.242226+00	\N
1518	4572	2026-06-10	382.1100	-3.5417	\N	26676.21	52.9683	FINNHUB	2026-06-09 23:33:20.667897+00	\N
1519	4573	2026-06-10	283.8900	0.1694	\N	25790.31	30.6699	FINNHUB	2026-06-09 23:33:24.076629+00	\N
1520	4574	2026-06-10	287.1900	-0.3401	\N	27160.06	43.6590	FINNHUB	2026-06-09 23:33:27.688311+00	\N
1521	4575	2026-06-10	45.9100	0.4375	\N	26509.50	24.8916	FINNHUB	2026-06-09 23:33:31.083128+00	\N
1522	4076	2026-06-11	200.4200	-3.7322	\N	4995606.00	31.2982	FINNHUB	2026-06-10 23:15:38.492924+00	\N
1523	4077	2026-06-11	291.5800	0.3545	\N	4298108.00	35.0651	FINNHUB	2026-06-10 23:15:41.821534+00	\N
1524	4078	2026-06-11	356.3800	-2.1633	\N	4327229.50	27.0101	FINNHUB	2026-06-10 23:15:45.141094+00	\N
1525	4079	2026-06-11	397.3600	-1.4997	\N	2990762.00	23.8848	FINNHUB	2026-06-10 23:15:48.489345+00	\N
1526	4080	2026-06-11	238.0000	-2.5349	\N	2607362.00	28.7161	FINNHUB	2026-06-10 23:15:51.782891+00	\N
1527	4081	2026-06-11	408.7500	-4.4798	\N	59774110.00	30.9903	FINNHUB	2026-06-10 23:15:55.093058+00	\N
1528	4082	2026-06-11	372.1000	-5.1153	\N	1768540.50	60.3247	FINNHUB	2026-06-10 23:15:58.391531+00	\N
1529	4083	2026-06-11	570.9800	-2.3281	\N	1483936.90	21.0228	FINNHUB	2026-06-10 23:16:01.678996+00	\N
1530	4084	2026-06-11	381.5900	-3.8041	\N	1489820.50	385.7640	FINNHUB	2026-06-10 23:16:04.975614+00	\N
1531	4085	2026-06-11	483.6800	-0.8385	\N	1048748.40	14.4713	FINNHUB	2026-06-10 23:16:08.302888+00	\N
1532	4086	2026-06-11	1136.3700	-0.7260	\N	1085526.50	42.9457	FINNHUB	2026-06-10 23:16:11.597697+00	\N
1533	4087	2026-06-11	891.8800	-4.7025	\N	1005961.30	41.7221	FINNHUB	2026-06-10 23:16:14.8854+00	\N
1534	4088	2026-06-11	120.5900	1.4384	\N	946056.50	41.6105	FINNHUB	2026-06-10 23:16:18.173612+00	\N
1535	4089	2026-06-11	309.1400	-1.1385	\N	832390.25	14.1325	FINNHUB	2026-06-10 23:16:21.461328+00	\N
1536	4090	2026-06-11	452.4000	-4.8590	\N	737683.70	147.2717	FINNHUB	2026-06-10 23:16:24.893553+00	\N
1537	4091	2026-06-11	1734.1900	-2.4514	\N	576185.90	56.4169	FINNHUB	2026-06-10 23:16:28.293632+00	\N
1538	4092	2026-06-11	150.6200	1.1483	\N	617224.10	24.3827	FINNHUB	2026-06-10 23:16:31.585929+00	\N
1539	4093	2026-06-11	201.2600	-2.2108	\N	595903.75	36.7615	FINNHUB	2026-06-10 23:16:34.882335+00	\N
1540	4094	2026-06-11	322.9600	-0.6430	\N	612434.80	27.5425	FINNHUB	2026-06-10 23:16:38.16515+00	\N
1541	4095	2026-06-11	238.4900	0.6287	\N	574386.06	27.2997	FINNHUB	2026-06-10 23:16:41.479339+00	\N
1542	4096	2026-06-11	107.0400	-0.8154	\N	530519.44	\N	FINNHUB	2026-06-10 23:16:44.776165+00	\N
1543	4097	2026-06-11	118.8000	-1.2961	\N	474391.10	39.6714	FINNHUB	2026-06-10 23:16:48.078505+00	\N
1544	4098	2026-06-11	489.0800	-1.2438	\N	433291.84	27.8286	FINNHUB	2026-06-10 23:16:51.385004+00	\N
1545	4099	2026-06-11	983.3700	1.5259	\N	431185.60	48.7877	FINNHUB	2026-06-10 23:16:54.680703+00	\N
1546	4100	2026-06-11	856.1600	-6.3999	\N	396801.94	42.0787	FINNHUB	2026-06-10 23:16:57.979595+00	\N
1547	4101	2026-06-11	224.9500	-0.2085	\N	399339.34	109.8595	FINNHUB	2026-06-10 23:17:01.281376+00	\N
1548	4102	2026-06-11	54.5400	0.2205	\N	388112.50	12.2445	FINNHUB	2026-06-10 23:17:04.592734+00	\N
1549	4103	2026-06-11	321.8000	-1.6383	\N	418903.78	62.4465	FINNHUB	2026-06-10 23:17:07.889347+00	\N
1550	4104	2026-06-11	189.8000	1.6278	\N	382386.75	34.7340	FINNHUB	2026-06-10 23:17:11.172389+00	\N
1551	4105	2026-06-11	307.4300	-5.3654	\N	368558.97	407.6980	FINNHUB	2026-06-10 23:17:14.491397+00	\N
1552	4106	2026-06-11	407.4600	-1.3414	\N	372246.90	30.9072	FINNHUB	2026-06-10 23:17:17.794086+00	\N
1553	4107	2026-06-11	497.0100	-0.4407	\N	408531.80	48.0174	FINNHUB	2026-06-10 23:17:21.144946+00	\N
1554	4108	2026-06-11	82.0000	0.7247	\N	347601.40	25.9915	FINNHUB	2026-06-10 23:17:24.52662+00	\N
1555	4109	2026-06-11	318.7100	-3.5498	\N	335266.00	38.8489	FINNHUB	2026-06-10 23:17:27.813456+00	\N
1556	4110	2026-06-11	83.5900	2.7662	\N	359859.62	26.2652	FINNHUB	2026-06-10 23:17:31.124863+00	\N
1557	4111	2026-06-11	149.0500	0.2556	\N	346567.72	20.8575	FINNHUB	2026-06-10 23:17:34.43216+00	\N
1558	4112	2026-06-11	206.6600	-1.7075	\N	326521.62	18.0269	FINNHUB	2026-06-10 23:17:37.71683+00	\N
1559	4113	2026-06-11	130.2100	-1.4083	\N	316613.03	138.7723	FINNHUB	2026-06-10 23:17:40.999562+00	\N
1560	4114	2026-06-11	1001.2900	-2.9767	\N	297992.90	16.4929	FINNHUB	2026-06-10 23:17:44.287523+00	\N
1561	4115	2026-06-11	86.1600	-3.5594	\N	225345.27	13.5277	FINNHUB	2026-06-10 23:17:47.594156+00	\N
1562	4116	2026-06-11	318.9200	-0.7500	\N	321036.66	22.9116	FINNHUB	2026-06-10 23:17:50.889963+00	\N
1563	4117	2026-06-11	119.0900	-0.4264	\N	290636.60	32.5279	FINNHUB	2026-06-10 23:17:54.178506+00	\N
1564	4118	2026-06-11	178.9600	-2.4369	\N	211413.56	27.2493	FINNHUB	2026-06-10 23:17:57.485872+00	\N
1565	4119	2026-06-11	182.9500	2.4987	\N	278187.16	25.0709	FINNHUB	2026-06-10 23:18:00.782695+00	\N
1566	4120	2026-06-11	115.3800	-3.6090	\N	286692.22	18.3514	FINNHUB	2026-06-10 23:18:04.064928+00	\N
1567	4121	2026-06-11	148.1200	-0.6706	\N	214216.52	19.8770	FINNHUB	2026-06-10 23:18:07.363619+00	\N
1568	4122	2026-06-11	197.6100	-0.1415	\N	385478.30	17.4125	FINNHUB	2026-06-10 23:18:10.721656+00	\N
1569	4123	2026-06-11	272.3600	-1.8487	\N	257589.64	23.9574	FINNHUB	2026-06-10 23:18:14.044446+00	\N
1570	4124	2026-06-11	282.0100	-2.2936	\N	266957.53	49.7405	FINNHUB	2026-06-10 23:18:17.35357+00	\N
1571	4125	2026-06-11	369.8300	-3.1301	\N	241286.16	28.6938	FINNHUB	2026-06-10 23:18:20.621886+00	\N
1572	4126	2026-06-11	2135.6400	-0.1744	\N	278973.38	59.7302	FINNHUB	2026-06-10 23:18:23.915003+00	\N
1573	4127	2026-06-11	867.0900	-5.7665	\N	247262.70	26.3775	FINNHUB	2026-06-10 23:18:27.179235+00	\N
1574	4128	2026-06-11	81.9700	-0.0366	\N	250935.53	11.5654	FINNHUB	2026-06-10 23:18:30.670938+00	\N
1575	4129	2026-06-11	177.4100	-2.2857	\N	244503.83	33.6968	FINNHUB	2026-06-10 23:18:34.048015+00	\N
1576	4130	2026-06-11	86.0500	0.7257	\N	176821.92	12.6286	FINNHUB	2026-06-10 23:18:37.349112+00	\N
1577	4131	2026-06-11	509.1600	-1.2471	\N	235537.19	33.2586	FINNHUB	2026-06-10 23:18:40.665751+00	\N
1578	4132	2026-06-11	172.0300	-2.1333	\N	33510182.00	8.7082	FINNHUB	2026-06-10 23:18:44.0921+00	\N
1579	4133	2026-06-11	1643.2300	-0.2010	\N	243835.72	54.1016	FINNHUB	2026-06-10 23:18:47.428079+00	\N
1580	4134	2026-06-11	252.5900	-5.3545	\N	232145.67	91.8770	FINNHUB	2026-06-10 23:18:50.720627+00	\N
1581	4135	2026-06-11	191.2000	-6.9224	\N	201208.60	20.2770	FINNHUB	2026-06-10 23:18:54.003613+00	\N
1582	4136	2026-06-11	19.6700	-0.8069	\N	35558760.00	14.6499	FINNHUB	2026-06-10 23:18:57.296019+00	\N
1583	4137	2026-06-11	133.3800	-1.0020	\N	231049.48	14.4172	FINNHUB	2026-06-10 23:19:00.575336+00	\N
2202	4256	2026-06-12	92.0300	0.8990	\N	89350.82	43.9735	FINNHUB	2026-06-11 23:21:20.613529+00	\N
1584	4138	2026-06-11	263.2200	1.0364	\N	212323.80	251.9267	FINNHUB	2026-06-10 23:19:03.854541+00	\N
1585	4139	2026-06-11	82.9500	-2.1008	\N	305247.88	20.8951	FINNHUB	2026-06-10 23:19:07.203333+00	\N
1586	4140	2026-06-11	170.3000	-4.8178	\N	180621.38	24.6987	FINNHUB	2026-06-10 23:19:10.543698+00	\N
1587	4141	2026-06-11	313.3400	-1.5830	\N	215028.34	19.1647	FINNHUB	2026-06-10 23:19:13.852506+00	\N
1588	4142	2026-06-11	282.5200	0.0957	\N	203201.12	23.4184	FINNHUB	2026-06-10 23:19:17.174958+00	\N
1589	4143	2026-06-11	88.4100	-0.0791	\N	172208.27	13.2028	FINNHUB	2026-06-10 23:19:20.480254+00	\N
1590	4144	2026-06-11	42.8100	1.4695	\N	1197658.00	9.8203	FINNHUB	2026-06-10 23:19:23.817996+00	\N
1591	4145	2026-06-11	392.6700	-2.9534	\N	192034.06	57.9562	FINNHUB	2026-06-10 23:19:27.099371+00	\N
1592	4146	2026-06-11	151.7600	-0.2629	\N	189837.39	51.0247	FINNHUB	2026-06-10 23:19:30.390177+00	\N
1593	4147	2026-06-11	144.3200	1.0786	\N	196746.31	22.5291	FINNHUB	2026-06-10 23:19:33.719891+00	\N
1594	4148	2026-06-11	185.5500	3.3935	\N	200045.55	18.9743	FINNHUB	2026-06-10 23:19:37.000916+00	\N
1595	4149	2026-06-11	815.9900	-3.5484	\N	189699.97	79.7729	FINNHUB	2026-06-10 23:19:40.285981+00	\N
1596	4150	2026-06-11	46.9500	2.5557	\N	191157.08	11.0241	FINNHUB	2026-06-10 23:19:43.595519+00	\N
1597	4151	2026-06-11	337.7300	-1.9837	\N	186026.64	23.8496	FINNHUB	2026-06-10 23:19:46.890564+00	\N
1598	4152	2026-06-11	492.9800	-5.3491	\N	174970.98	44.1518	FINNHUB	2026-06-10 23:19:50.178187+00	\N
1599	4153	2026-06-11	114.5000	-0.1221	\N	270201.10	18.1221	FINNHUB	2026-06-10 23:19:53.493589+00	\N
1600	4154	2026-06-11	85.1200	0.3419	\N	176784.83	21.6039	FINNHUB	2026-06-10 23:19:56.801185+00	\N
1601	4155	2026-06-11	167.6600	1.6922	\N	183253.89	31.6501	FINNHUB	2026-06-10 23:20:00.10582+00	\N
1602	4156	2026-06-11	11.9200	-2.8525	\N	153810.67	9.5215	FINNHUB	2026-06-10 23:20:03.41927+00	\N
1603	4157	2026-06-11	490.0900	-5.3369	\N	178448.84	27.4073	FINNHUB	2026-06-10 23:20:06.717331+00	\N
1604	4158	2026-06-11	99.0600	-2.3270	\N	129108.45	17.3472	FINNHUB	2026-06-10 23:20:10.021702+00	\N
1605	4159	2026-06-11	482.0400	-2.4349	\N	179329.66	26.1948	FINNHUB	2026-06-10 23:20:13.322505+00	\N
1606	4160	2026-06-11	98.6100	-0.7249	\N	172305.34	15.3515	FINNHUB	2026-06-10 23:20:16.618802+00	\N
1607	4161	2026-06-11	647.7400	0.4357	\N	164891.81	\N	FINNHUB	2026-06-10 23:20:19.899824+00	\N
1608	4162	2026-06-11	149.2200	-3.1479	\N	193681.98	43.3730	FINNHUB	2026-06-10 23:20:23.217762+00	\N
1609	4163	2026-06-11	209.0000	-2.5686	\N	168034.52	74.0893	FINNHUB	2026-06-10 23:20:26.55769+00	\N
1610	4164	2026-06-11	1010.6800	-0.1265	\N	164788.48	26.3451	FINNHUB	2026-06-10 23:20:29.871683+00	\N
1611	4165	2026-06-11	267.0300	-1.5666	\N	156082.52	21.6391	FINNHUB	2026-06-10 23:20:33.20613+00	\N
1612	4166	2026-06-11	121.4800	-3.2032	\N	151297.70	16.4151	FINNHUB	2026-06-10 23:20:36.594757+00	\N
1613	4167	2026-06-11	89.1700	-2.2795	\N	155143.23	24.7201	FINNHUB	2026-06-10 23:20:39.898654+00	\N
1614	4168	2026-06-11	23.2100	2.2017	\N	160923.52	7.5089	FINNHUB	2026-06-10 23:20:43.196794+00	\N
1615	4169	2026-06-11	560.0500	-2.9931	\N	153231.34	32.0367	FINNHUB	2026-06-10 23:20:46.492939+00	\N
1616	4170	2026-06-11	89.2700	0.5633	\N	156078.70	16.5653	FINNHUB	2026-06-10 23:20:49.78383+00	\N
1617	4171	2026-06-11	375.4600	-6.5369	\N	147406.44	36.9347	FINNHUB	2026-06-10 23:20:53.079578+00	\N
1618	4172	2026-06-11	168.1700	-3.3172	\N	147281.03	81.3707	FINNHUB	2026-06-10 23:20:56.382609+00	\N
1619	4173	2026-06-11	81.2600	0.2962	\N	134662.66	21.4741	FINNHUB	2026-06-10 23:20:59.698682+00	\N
1620	4174	2026-06-11	170.9200	-2.5264	\N	142993.31	17.8229	FINNHUB	2026-06-10 23:21:03.069645+00	\N
1621	4175	2026-06-11	412.0200	-3.4200	\N	150703.38	50.5869	FINNHUB	2026-06-10 23:21:06.442884+00	\N
1622	4176	2026-06-11	25.6000	-0.3891	\N	145991.27	19.4889	FINNHUB	2026-06-10 23:21:09.908015+00	\N
1623	4177	2026-06-11	22.9900	-0.3468	\N	23595510.00	14.9058	FINNHUB	2026-06-10 23:21:13.831917+00	\N
1624	4178	2026-06-11	211.3600	2.2199	\N	145961.92	103.6985	FINNHUB	2026-06-10 23:21:17.124273+00	\N
1625	4179	2026-06-11	167.7600	-4.2302	\N	139858.02	28.1648	FINNHUB	2026-06-10 23:21:20.418908+00	\N
1626	4180	2026-06-11	46.7700	-2.2775	\N	116478.61	16.0459	FINNHUB	2026-06-10 23:21:23.747345+00	\N
1627	4181	2026-06-11	68.6100	-2.5149	\N	145939.89	17.0890	FINNHUB	2026-06-10 23:21:27.041385+00	\N
1628	4182	2026-06-11	119.9200	2.6800	\N	144879.52	19.7869	FINNHUB	2026-06-10 23:21:30.383401+00	\N
1629	4183	2026-06-11	108.2000	-2.0105	\N	141496.27	106.2284	FINNHUB	2026-06-10 23:21:33.667835+00	\N
1630	4184	2026-06-11	118.4800	-1.5047	\N	146935.94	48.1112	FINNHUB	2026-06-10 23:21:36.961425+00	\N
1631	4185	2026-06-11	145.7700	-1.1863	\N	139567.75	37.5459	FINNHUB	2026-06-10 23:21:40.250687+00	\N
1632	4186	2026-06-11	205.8800	-4.5526	\N	136678.98	30.2990	FINNHUB	2026-06-10 23:21:43.544977+00	\N
1633	4187	2026-06-11	20.7600	-2.5809	\N	20786772.00	\N	FINNHUB	2026-06-10 23:21:46.858601+00	\N
1634	4188	2026-06-11	183.6300	-2.5370	\N	131142.83	35.5497	FINNHUB	2026-06-10 23:21:50.151887+00	\N
1635	4189	2026-06-11	160.6400	-2.0428	\N	124809.67	20.2811	FINNHUB	2026-06-10 23:21:53.439719+00	\N
1636	4190	2026-06-11	61.1200	1.9516	\N	96699.63	12.4549	FINNHUB	2026-06-10 23:21:56.771804+00	\N
1637	4191	2026-06-11	330.5800	1.6763	\N	127939.54	11.3231	FINNHUB	2026-06-10 23:22:00.089626+00	\N
1638	4192	2026-06-11	426.3800	0.3672	\N	126634.72	26.5093	FINNHUB	2026-06-10 23:22:03.405887+00	\N
1639	4193	2026-06-11	22.0200	-2.2636	\N	108768.37	10.0683	FINNHUB	2026-06-10 23:22:06.730179+00	\N
1640	4194	2026-06-11	56.4400	1.6205	\N	169280.14	24.5156	FINNHUB	2026-06-10 23:22:10.070172+00	\N
1641	4195	2026-06-11	98.0200	0.9891	\N	122750.58	41.8658	FINNHUB	2026-06-10 23:22:13.36556+00	\N
1642	4196	2026-06-11	58.6400	1.8409	\N	88731.84	10.8639	FINNHUB	2026-06-10 23:22:16.683662+00	\N
1643	4197	2026-06-11	81.8200	-0.1343	\N	116618.88	8.2653	FINNHUB	2026-06-10 23:22:19.965323+00	\N
1644	4198	2026-06-11	525.0200	-0.9639	\N	122196.41	25.4948	FINNHUB	2026-06-10 23:22:23.34615+00	\N
1645	4199	2026-06-11	23.2000	-0.3864	\N	11369599.00	14.9549	FINNHUB	2026-06-10 23:22:26.691863+00	\N
1646	4200	2026-06-11	73.1300	2.1940	\N	121768.46	15.1209	FINNHUB	2026-06-10 23:22:29.987609+00	\N
1647	4201	2026-06-11	204.2000	2.0337	\N	116943.24	10.1171	FINNHUB	2026-06-10 23:22:33.277205+00	\N
1648	4202	2026-06-11	216.1900	-0.5429	\N	121387.48	18.2757	FINNHUB	2026-06-10 23:22:36.574645+00	\N
1649	4203	2026-06-11	9.3500	-2.2989	\N	18752004.00	15.0180	FINNHUB	2026-06-10 23:22:39.875665+00	\N
1650	4204	2026-06-11	308.8400	-1.6464	\N	118828.42	35.6094	FINNHUB	2026-06-10 23:22:43.207546+00	\N
1651	4205	2026-06-11	55.6000	-1.5581	\N	113978.21	19.0704	FINNHUB	2026-06-10 23:22:46.651162+00	\N
1652	4206	2026-06-11	106.0600	-0.8507	\N	110319.02	62.7883	FINNHUB	2026-06-10 23:22:49.995016+00	\N
1653	4207	2026-06-11	280.9800	-2.9497	\N	115451.58	74.0834	FINNHUB	2026-06-10 23:22:53.278906+00	\N
1654	4208	2026-06-11	164.3900	-0.5024	\N	162898.17	16.7401	FINNHUB	2026-06-10 23:22:56.672963+00	\N
1655	4209	2026-06-11	435.7100	-2.2568	\N	113138.84	26.0791	FINNHUB	2026-06-10 23:22:59.987894+00	\N
1656	4210	2026-06-11	42.9500	0.6562	\N	81778.68	34.1139	FINNHUB	2026-06-10 23:23:03.332963+00	\N
1657	4211	2026-06-11	177.6300	-3.1197	\N	111020.15	34.4462	FINNHUB	2026-06-10 23:23:06.62806+00	\N
1658	4212	2026-06-11	875.6000	-3.3052	\N	111624.60	32.0744	FINNHUB	2026-06-10 23:23:09.928054+00	\N
1659	4213	2026-06-11	18.1100	1.6274	\N	561900.50	5.2229	FINNHUB	2026-06-10 23:23:13.25669+00	\N
1660	4214	2026-06-11	16.0900	1.1950	\N	561900.50	5.2229	FINNHUB	2026-06-10 23:23:16.612579+00	\N
1661	4215	2026-06-11	170.5000	-1.7121	\N	105603.70	13.8075	FINNHUB	2026-06-10 23:23:19.899647+00	\N
1662	4216	2026-06-11	98.7600	1.3859	\N	112220.56	75.0288	FINNHUB	2026-06-10 23:23:23.188523+00	\N
1663	4217	2026-06-11	43.5700	-2.5933	\N	92452.41	7.5601	FINNHUB	2026-06-10 23:23:26.482236+00	\N
1664	4218	2026-06-11	1038.3300	-2.0296	\N	102404.52	72.0144	FINNHUB	2026-06-10 23:23:29.771924+00	\N
1665	4219	2026-06-11	92.7700	-5.8555	\N	105196.64	12.4405	FINNHUB	2026-06-10 23:23:33.054924+00	\N
1666	4220	2026-06-11	138.8800	0.3541	\N	102314.34	52.3481	FINNHUB	2026-06-10 23:23:36.340835+00	\N
1667	4221	2026-06-11	80.2500	-2.1103	\N	104097.40	21.6779	FINNHUB	2026-06-10 23:23:39.64098+00	\N
1668	4222	2026-06-11	94.0200	1.1512	\N	106169.22	24.3340	FINNHUB	2026-06-10 23:23:42.93772+00	\N
1669	4223	2026-06-11	50.9600	0.5525	\N	106169.22	24.3340	FINNHUB	2026-06-10 23:23:46.286565+00	\N
1670	4224	2026-06-11	650.9200	-5.9296	\N	97130.94	87.9216	FINNHUB	2026-06-10 23:23:49.604103+00	\N
1671	4225	2026-06-11	385.1300	-1.4761	\N	108979.04	93.0674	FINNHUB	2026-06-10 23:23:52.902432+00	\N
1672	4226	2026-06-11	386.2300	-1.8750	\N	103211.10	39.9424	FINNHUB	2026-06-10 23:23:56.188767+00	\N
1673	4227	2026-06-11	51.1700	-0.1561	\N	76308.06	13.0911	FINNHUB	2026-06-10 23:23:59.555913+00	\N
1674	4228	2026-06-11	503.1000	1.3865	\N	103844.57	33.1973	FINNHUB	2026-06-10 23:24:02.836868+00	\N
1675	4229	2026-06-11	233.3800	-1.8917	\N	96151.10	13.3395	FINNHUB	2026-06-10 23:24:06.233969+00	\N
1676	4230	2026-06-11	449.1200	-4.5968	\N	103356.70	35.6636	FINNHUB	2026-06-10 23:24:09.528622+00	\N
1677	4231	2026-06-11	249.4900	-2.9826	\N	102891.64	58.9975	FINNHUB	2026-06-10 23:24:12.821641+00	\N
1678	4232	2026-06-11	110.1400	-0.5508	\N	143189.14	14.5843	FINNHUB	2026-06-10 23:24:16.130576+00	\N
1679	4233	2026-06-11	44.6100	-1.9776	\N	100629.88	75.3218	FINNHUB	2026-06-10 23:24:19.444316+00	\N
1680	4234	2026-06-11	81.5600	-0.1714	\N	140348.66	14.6993	FINNHUB	2026-06-10 23:24:22.796655+00	\N
1681	4235	2026-06-11	139.7500	-2.4433	\N	96600.99	\N	FINNHUB	2026-06-10 23:24:26.091737+00	\N
1682	4236	2026-06-11	125.0400	0.9853	\N	96630.95	18.8035	FINNHUB	2026-06-10 23:24:29.398206+00	\N
1683	4237	2026-06-11	45.5200	1.5845	\N	130122.93	13.4009	FINNHUB	2026-06-10 23:24:32.738233+00	\N
1684	4238	2026-06-11	26.7700	1.8258	\N	9145400.00	16.8710	FINNHUB	2026-06-10 23:24:36.070905+00	\N
1685	4239	2026-06-11	341.0700	-1.3336	\N	92821.10	21.3824	FINNHUB	2026-06-10 23:24:39.43644+00	\N
1686	4240	2026-06-11	37.4900	2.4597	\N	877585.75	16.7339	FINNHUB	2026-06-10 23:24:42.779033+00	\N
1687	4241	2026-06-11	263.8000	3.0710	\N	94883.81	22.2195	FINNHUB	2026-06-10 23:24:46.066267+00	\N
1688	4242	2026-06-11	790.4400	0.7919	\N	94919.13	19.9326	FINNHUB	2026-06-10 23:24:49.359233+00	\N
1689	4243	2026-06-11	231.1000	-0.0303	\N	92426.56	21.2695	FINNHUB	2026-06-10 23:24:52.659226+00	\N
1690	4244	2026-06-11	103.2600	-4.2737	\N	91690.19	17.4681	FINNHUB	2026-06-10 23:24:55.943543+00	\N
1691	4245	2026-06-11	232.6400	0.1981	\N	93909.91	13.0159	FINNHUB	2026-06-10 23:24:59.254836+00	\N
1692	4246	2026-06-11	62.0800	-3.3774	\N	89157.46	32.6226	FINNHUB	2026-06-10 23:25:02.640982+00	\N
1693	4247	2026-06-11	242.3000	-3.7155	\N	90893.48	23.9761	FINNHUB	2026-06-10 23:25:05.917339+00	\N
1694	4248	2026-06-11	192.5000	0.8751	\N	89577.26	30.8855	FINNHUB	2026-06-10 23:25:09.207057+00	\N
1695	4249	2026-06-11	404.5600	-4.6816	\N	88845.47	16.9455	FINNHUB	2026-06-10 23:25:12.494107+00	\N
1696	4250	2026-06-11	630.5200	-5.7843	\N	88361.29	33.0570	FINNHUB	2026-06-10 23:25:15.801519+00	\N
1697	4251	2026-06-11	460.5400	-1.0166	\N	89462.97	115.6946	FINNHUB	2026-06-10 23:25:19.089427+00	\N
1698	4252	2026-06-11	224.2800	1.3466	\N	88868.72	31.8070	FINNHUB	2026-06-10 23:25:22.389691+00	\N
1699	4253	2026-06-11	219.6700	-6.9707	\N	83463.99	\N	FINNHUB	2026-06-10 23:25:25.775343+00	\N
1700	4254	2026-06-11	72.2600	0.9359	\N	87554.44	31.3590	FINNHUB	2026-06-10 23:25:29.087558+00	\N
1701	4255	2026-06-11	139.3600	-5.6785	\N	85288.06	24.1541	FINNHUB	2026-06-10 23:25:32.39892+00	\N
1702	4256	2026-06-11	91.2100	1.1758	\N	88788.47	43.6967	FINNHUB	2026-06-10 23:25:35.743324+00	\N
1703	4257	2026-06-11	46.4100	-1.8401	\N	86635.73	28.4052	FINNHUB	2026-06-10 23:25:39.071649+00	\N
1704	4258	2026-06-11	56.8100	1.4102	\N	86959.82	11.1401	FINNHUB	2026-06-10 23:25:42.358257+00	\N
1705	4259	2026-06-11	28.7100	-1.9132	\N	71265.60	7.3690	FINNHUB	2026-06-10 23:25:45.710983+00	\N
1706	4260	2026-06-11	23.9700	0.5031	\N	85858.52	4.5677	FINNHUB	2026-06-10 23:25:49.00398+00	\N
1707	4261	2026-06-11	7.6200	1.1952	\N	443039.20	12.7131	FINNHUB	2026-06-10 23:25:52.302723+00	\N
1708	4262	2026-06-11	13.4000	-3.2491	\N	66810.73	85.5451	FINNHUB	2026-06-10 23:25:55.635235+00	\N
1709	4263	2026-06-11	95.0200	-0.8556	\N	86052.14	29.0558	FINNHUB	2026-06-10 23:25:58.918751+00	\N
1710	4264	2026-06-11	227.6300	0.1276	\N	80923.99	596.4635	FINNHUB	2026-06-10 23:26:02.19822+00	\N
1711	4265	2026-06-11	23.6400	-2.7961	\N	60592.97	5.4786	FINNHUB	2026-06-10 23:26:05.494381+00	\N
1712	4266	2026-06-11	239.9000	0.1001	\N	83066.16	\N	FINNHUB	2026-06-10 23:26:08.77075+00	\N
1713	4267	2026-06-11	373.3400	-0.4161	\N	82455.63	12.1365	FINNHUB	2026-06-10 23:26:12.069585+00	\N
1714	4268	2026-06-11	55.5100	-0.6088	\N	83992.34	25.2305	FINNHUB	2026-06-10 23:26:15.501713+00	\N
1715	4269	2026-06-11	152.4800	-4.6583	\N	111625.46	15.0001	FINNHUB	2026-06-10 23:26:18.824403+00	\N
1716	4270	2026-06-11	37.8700	1.3922	\N	80807.41	13.6892	FINNHUB	2026-06-10 23:26:22.132554+00	\N
1717	4271	2026-06-11	1588.2900	-3.2215	\N	81834.63	42.6222	FINNHUB	2026-06-10 23:26:25.571161+00	\N
1718	4272	2026-06-11	284.2200	-3.2541	\N	79626.62	17.3706	FINNHUB	2026-06-10 23:26:28.868418+00	\N
1719	4273	2026-06-11	80.3800	-0.8633	\N	59683.65	18.4152	FINNHUB	2026-06-10 23:26:32.204384+00	\N
1720	4274	2026-06-11	34.3000	-2.2235	\N	2496710.50	52.8371	FINNHUB	2026-06-10 23:26:35.500201+00	\N
1721	4275	2026-06-11	156.8500	0.2941	\N	81935.61	29.3992	FINNHUB	2026-06-10 23:26:38.947053+00	\N
1722	4276	2026-06-11	140.3400	-0.8618	\N	80093.54	20.3749	FINNHUB	2026-06-10 23:26:42.245568+00	\N
1723	4277	2026-06-11	212.8200	0.4389	\N	69444.98	14.7961	FINNHUB	2026-06-10 23:26:45.552256+00	\N
1724	4278	2026-06-11	54.2400	1.2696	\N	67635.95	15.0906	FINNHUB	2026-06-10 23:26:48.896269+00	\N
1725	4279	2026-06-11	89.6000	-0.6652	\N	111748.26	27.4094	FINNHUB	2026-06-10 23:26:52.275527+00	\N
1726	4280	2026-06-11	167.1500	0.9848	\N	80869.21	20.6036	FINNHUB	2026-06-10 23:26:55.590714+00	\N
1727	4281	2026-06-11	64.1800	1.9863	\N	82063.73	31.3819	FINNHUB	2026-06-10 23:26:58.944651+00	\N
1728	4282	2026-06-11	129.1000	-1.7130	\N	79165.28	31.4522	FINNHUB	2026-06-10 23:27:02.273261+00	\N
1729	4283	2026-06-11	319.2500	-3.7708	\N	76845.70	17.1378	FINNHUB	2026-06-10 23:27:05.62165+00	\N
1730	4284	2026-06-11	450.6900	0.1667	\N	79046.51	31.6820	FINNHUB	2026-06-10 23:27:08.913868+00	\N
1731	4285	2026-06-11	338.2200	-1.2698	\N	76769.87	49.7859	FINNHUB	2026-06-10 23:27:12.22475+00	\N
1732	4286	2026-06-11	137.1100	-3.7284	\N	78128.34	31.9674	FINNHUB	2026-06-10 23:27:15.541968+00	\N
1733	4287	2026-06-11	542.1400	-1.1902	\N	77448.01	16.9248	FINNHUB	2026-06-10 23:27:18.83901+00	\N
1734	4288	2026-06-11	5.1600	-3.3708	\N	57183.23	9.0897	FINNHUB	2026-06-10 23:27:22.130696+00	\N
1735	4289	2026-06-11	125.5200	3.9675	\N	74588.70	14.8138	FINNHUB	2026-06-10 23:27:25.546184+00	\N
1736	4290	2026-06-11	295.8100	0.2746	\N	78140.23	12.4269	FINNHUB	2026-06-10 23:27:28.83686+00	\N
1737	4291	2026-06-11	263.2800	1.9872	\N	75363.44	16.2702	FINNHUB	2026-06-10 23:27:32.118876+00	\N
1738	4292	2026-06-11	257.9900	1.6589	\N	75355.61	17.9162	FINNHUB	2026-06-10 23:27:35.409867+00	\N
1739	4293	2026-06-11	268.7300	-4.7935	\N	75700.71	16.9013	FINNHUB	2026-06-10 23:27:38.923133+00	\N
1740	4294	2026-06-11	234.2300	-9.7762	\N	66625.29	11043.4759	FINNHUB	2026-06-10 23:27:42.249949+00	\N
1741	4295	2026-06-11	303.9100	-2.1381	\N	75613.55	29.0900	FINNHUB	2026-06-10 23:27:45.588378+00	\N
1742	4296	2026-06-11	90.4600	1.0839	\N	75222.47	28.8883	FINNHUB	2026-06-10 23:27:48.881912+00	\N
1743	4297	2026-06-11	285.5600	-3.9844	\N	75087.43	28.3028	FINNHUB	2026-06-10 23:27:52.237686+00	\N
1744	4298	2026-06-11	25.4300	0.6332	\N	1321162.90	15.0960	FINNHUB	2026-06-10 23:27:55.56066+00	\N
1745	4299	2026-06-11	86.3600	3.0918	\N	75502.34	39.8009	FINNHUB	2026-06-10 23:27:58.841009+00	\N
1746	4300	2026-06-11	79.4000	-5.2053	\N	75523.48	29.7571	FINNHUB	2026-06-10 23:28:02.12255+00	\N
1747	4301	2026-06-11	231.9200	1.0765	\N	74469.32	32.1576	FINNHUB	2026-06-10 23:28:05.417655+00	\N
1748	4302	2026-06-11	45.7000	-3.0753	\N	75288.48	29.8645	FINNHUB	2026-06-10 23:28:08.696054+00	\N
1749	4303	2026-06-11	131.1400	-1.1756	\N	76503.88	66.8740	FINNHUB	2026-06-10 23:28:11.979033+00	\N
1750	4304	2026-06-11	354.7700	-0.3287	\N	71197.06	151.8550	FINNHUB	2026-06-10 23:28:15.272656+00	\N
1751	4305	2026-06-11	62.0900	1.4542	\N	100741.18	15.9174	FINNHUB	2026-06-10 23:28:18.643505+00	\N
1752	4306	2026-06-11	67.2500	-3.3903	\N	74080.29	51.4089	FINNHUB	2026-06-10 23:28:21.922728+00	\N
1753	4307	2026-06-11	181.7200	1.5196	\N	71767.37	17.4066	FINNHUB	2026-06-10 23:28:25.245602+00	\N
1754	4308	2026-06-11	140.2800	2.1481	\N	75686.51	13.7687	FINNHUB	2026-06-10 23:28:28.537169+00	\N
1755	4309	2026-06-11	119.1800	-0.9392	\N	101829.94	21.6429	FINNHUB	2026-06-10 23:28:31.865044+00	\N
1756	4310	2026-06-11	1473.0400	-3.8473	\N	74858.65	109.9378	FINNHUB	2026-06-10 23:28:35.156688+00	\N
1757	4311	2026-06-11	250.1700	-2.4868	\N	72614.04	23.1698	FINNHUB	2026-06-10 23:28:38.52033+00	\N
1758	4312	2026-06-11	256.9900	-2.8173	\N	72914.83	34.6274	FINNHUB	2026-06-10 23:28:41.884008+00	\N
1759	4313	2026-06-11	48.3400	-1.2663	\N	71969.31	20.1877	FINNHUB	2026-06-10 23:28:45.175024+00	\N
1760	4314	2026-06-11	180.4000	0.2947	\N	72379.76	37.3624	FINNHUB	2026-06-10 23:28:48.488877+00	\N
1761	4315	2026-06-11	68.7800	0.8948	\N	95130.00	27.6541	FINNHUB	2026-06-10 23:28:51.837404+00	\N
1762	4316	2026-06-11	89.9500	2.4487	\N	71584.94	34.3004	FINNHUB	2026-06-10 23:28:55.148955+00	\N
1763	4317	2026-06-11	31.8400	1.5954	\N	70838.45	21.3691	FINNHUB	2026-06-10 23:28:58.527882+00	\N
1764	4318	2026-06-11	308.9300	-1.0854	\N	70012.69	26.2220	FINNHUB	2026-06-10 23:29:01.845593+00	\N
1765	4319	2026-06-11	128.5300	0.6027	\N	69514.86	19.0254	FINNHUB	2026-06-10 23:29:05.141595+00	\N
1766	4320	2026-06-11	99.9800	-3.5873	\N	69506.18	18.9339	FINNHUB	2026-06-10 23:29:08.46166+00	\N
1767	4321	2026-06-11	336.3300	1.4295	\N	72616.16	18.4211	FINNHUB	2026-06-10 23:29:11.756533+00	\N
1768	4322	2026-06-11	1212.3600	-3.5697	\N	68566.74	32.9331	FINNHUB	2026-06-10 23:29:15.046867+00	\N
1769	4323	2026-06-11	434.6500	-1.0675	\N	62557.90	142.7285	FINNHUB	2026-06-10 23:29:18.350415+00	\N
1770	4324	2026-06-11	151.0000	-2.9999	\N	67828.34	73.2487	FINNHUB	2026-06-10 23:29:21.64618+00	\N
1771	4325	2026-06-11	411.6400	-0.5869	\N	69060.80	33.0434	FINNHUB	2026-06-10 23:29:25.019423+00	\N
1772	4326	2026-06-11	853.2600	3.8332	\N	67375.97	153.1620	FINNHUB	2026-06-10 23:29:28.31361+00	\N
1773	4327	2026-06-11	1056.3500	-3.4565	\N	68545.99	27.3418	FINNHUB	2026-06-10 23:29:31.607529+00	\N
1774	4328	2026-06-11	180.7800	-2.2441	\N	64924.02	47.1185	FINNHUB	2026-06-10 23:29:34.895313+00	\N
1775	4329	2026-06-11	19.0400	-0.1049	\N	65588.49	15.0294	FINNHUB	2026-06-10 23:29:38.193522+00	\N
1776	4330	2026-06-11	37.1900	-5.0064	\N	91357.40	10.7145	FINNHUB	2026-06-10 23:29:41.520709+00	\N
1777	4331	2026-06-11	26.2300	-1.2425	\N	66589.56	\N	FINNHUB	2026-06-10 23:29:44.817914+00	\N
1778	4332	2026-06-11	14.9300	-1.3871	\N	367651.22	23.5629	FINNHUB	2026-06-10 23:29:48.134693+00	\N
1779	4333	2026-06-11	45.4900	-5.7593	\N	59767.93	38.4113	FINNHUB	2026-06-10 23:29:51.434165+00	\N
1780	4334	2026-06-11	1719.4800	-6.1194	\N	60672.44	49.5833	FINNHUB	2026-06-10 23:29:54.762546+00	\N
1781	4335	2026-06-11	39.2500	1.0036	\N	90353.73	14.0782	FINNHUB	2026-06-10 23:29:58.28415+00	\N
1782	4336	2026-06-11	601.6500	-2.3581	\N	64344.95	14.5465	FINNHUB	2026-06-10 23:30:01.601553+00	\N
1783	4337	2026-06-11	212.5900	1.1466	\N	65513.99	30.2047	FINNHUB	2026-06-10 23:30:04.939436+00	\N
1784	4338	2026-06-11	303.3600	1.0358	\N	64960.82	8.5430	FINNHUB	2026-06-10 23:30:08.257258+00	\N
1785	4339	2026-06-11	70.7400	-3.5188	\N	54851.42	211.9089	FINNHUB	2026-06-10 23:30:11.589307+00	\N
1786	4340	2026-06-11	105.0500	-2.9382	\N	62650.83	\N	FINNHUB	2026-06-10 23:30:14.869991+00	\N
1787	4341	2026-06-11	43.9600	-1.5454	\N	65163.19	28.9614	FINNHUB	2026-06-10 23:30:18.17593+00	\N
1788	4342	2026-06-11	15.5600	-3.0530	\N	47697.84	7.9576	FINNHUB	2026-06-10 23:30:21.517581+00	\N
1789	4343	2026-06-11	276.5100	-2.2864	\N	63305.90	30.0412	FINNHUB	2026-06-10 23:30:24.893577+00	\N
1790	4344	2026-06-11	63.0200	-0.8340	\N	62520.17	20.0642	FINNHUB	2026-06-10 23:30:28.189102+00	\N
1791	4345	2026-06-11	202.0000	-4.2246	\N	60028.38	20.6567	FINNHUB	2026-06-10 23:30:31.484933+00	\N
1792	4346	2026-06-11	33.9800	-2.7476	\N	45770.40	22.1648	FINNHUB	2026-06-10 23:30:34.822708+00	\N
1793	4347	2026-06-11	113.9900	-4.7623	\N	61096.57	24.6755	FINNHUB	2026-06-10 23:30:38.19317+00	\N
1794	4348	2026-06-11	1317.6300	-0.9152	\N	62808.32	35.2460	FINNHUB	2026-06-10 23:30:41.489427+00	\N
1795	4349	2026-06-11	49.7600	0.6676	\N	61994.95	11.2167	FINNHUB	2026-06-10 23:30:44.773667+00	\N
1796	4350	2026-06-11	346.5600	-3.0656	\N	58932.29	36.8756	FINNHUB	2026-06-10 23:30:48.087363+00	\N
1797	4351	2026-06-11	117.1100	1.2975	\N	59821.00	12.9036	FINNHUB	2026-06-10 23:30:51.375445+00	\N
1798	4352	2026-06-11	91.0300	0.1761	\N	59525.02	30.4165	FINNHUB	2026-06-10 23:30:54.751536+00	\N
1799	4353	2026-06-11	30.9900	-2.8527	\N	51234.18	7.2354	FINNHUB	2026-06-10 23:30:58.174599+00	\N
1800	4354	2026-06-11	14.3000	-4.3478	\N	57718.27	\N	FINNHUB	2026-06-10 23:31:01.486985+00	\N
1801	4355	2026-06-11	120.2600	1.0758	\N	80218.36	27.4720	FINNHUB	2026-06-10 23:31:04.812892+00	\N
1802	4356	2026-06-11	66.7700	0.7849	\N	58641.50	19.8516	FINNHUB	2026-06-10 23:31:08.122539+00	\N
1803	4357	2026-06-11	211.6900	-3.8297	\N	55393.29	67.7843	FINNHUB	2026-06-10 23:31:11.443373+00	\N
1804	4358	2026-06-11	11.6200	-2.1886	\N	57743.92	18.1371	FINNHUB	2026-06-10 23:31:14.729849+00	\N
1805	4359	2026-06-11	250.4900	-1.5060	\N	57415.77	24.6314	FINNHUB	2026-06-10 23:31:18.034333+00	\N
1806	4360	2026-06-11	303.0000	-1.6776	\N	56447.37	32.5909	FINNHUB	2026-06-10 23:31:21.413369+00	\N
1807	4361	2026-06-11	56.3900	-0.1947	\N	57332.46	12.2036	FINNHUB	2026-06-10 23:31:24.792933+00	\N
1808	4362	2026-06-11	62.1100	1.4041	\N	58070.97	51.8240	FINNHUB	2026-06-10 23:31:28.081974+00	\N
1809	4363	2026-06-11	223.3400	2.8364	\N	57637.83	4.7462	FINNHUB	2026-06-10 23:31:31.398845+00	\N
1810	4364	2026-06-11	272.5400	3.1684	\N	56702.48	26.5947	FINNHUB	2026-06-10 23:31:34.681219+00	\N
1811	4365	2026-06-11	57.1000	0.9726	\N	57852.93	12.2181	FINNHUB	2026-06-10 23:31:37.979897+00	\N
1812	4366	2026-06-11	324.0000	-2.2418	\N	56631.31	53.7299	FINNHUB	2026-06-10 23:31:41.265187+00	\N
1813	4367	2026-06-11	347.5900	-5.8557	\N	54412.49	63.7105	FINNHUB	2026-06-10 23:31:44.562674+00	\N
1814	4368	2026-06-11	67.9700	-4.5901	\N	59170.55	45.1684	FINNHUB	2026-06-10 23:31:47.84067+00	\N
1815	4369	2026-06-11	127.9800	1.0821	\N	57768.57	16.7445	FINNHUB	2026-06-10 23:31:51.246783+00	\N
1816	4370	2026-06-11	139.4900	-5.2442	\N	51096.90	58.0647	FINNHUB	2026-06-10 23:31:54.599961+00	\N
1817	4371	2026-06-11	90.5700	3.1666	\N	56992.78	16.1407	FINNHUB	2026-06-10 23:31:57.885094+00	\N
1818	4372	2026-06-11	220.1400	1.4236	\N	57474.95	35.6633	FINNHUB	2026-06-10 23:32:01.184895+00	\N
1819	4373	2026-06-11	862.1800	-2.4683	\N	46907.62	24.1072	FINNHUB	2026-06-10 23:32:04.499561+00	\N
1820	4374	2026-06-11	95.6100	-2.8847	\N	53711.40	\N	FINNHUB	2026-06-10 23:32:07.791442+00	\N
1821	4375	2026-06-11	323.8700	0.3128	\N	57058.51	29.9861	FINNHUB	2026-06-10 23:32:11.089217+00	\N
1822	4376	2026-06-11	86.1300	0.6544	\N	56307.15	15.5588	FINNHUB	2026-06-10 23:32:14.381297+00	\N
1823	4377	2026-06-11	330.8600	-3.1724	\N	58570.09	218.8514	FINNHUB	2026-06-10 23:32:17.672155+00	\N
1824	4378	2026-06-11	196.5500	1.1893	\N	54642.30	192.4025	FINNHUB	2026-06-10 23:32:20.953308+00	\N
1825	4379	2026-06-11	46.0300	-1.1808	\N	53584.54	41.2316	FINNHUB	2026-06-10 23:32:24.276917+00	\N
1826	4380	2026-06-11	281.2400	0.5973	\N	54393.43	21.3418	FINNHUB	2026-06-10 23:32:27.57053+00	\N
1827	4381	2026-06-11	82.4400	-2.8632	\N	51981.56	32.4269	FINNHUB	2026-06-10 23:32:30.861026+00	\N
1828	4382	2026-06-11	28.3700	2.6040	\N	74882.19	16.1349	FINNHUB	2026-06-10 23:32:34.210325+00	\N
1829	4383	2026-06-11	107.5200	-4.4946	\N	71247.68	28.4185	FINNHUB	2026-06-10 23:32:37.543895+00	\N
1830	4384	2026-06-11	18.9000	-4.9296	\N	1603565.60	32.0003	FINNHUB	2026-06-10 23:32:40.862987+00	\N
1831	4385	2026-06-11	63.8100	-3.7702	\N	41951.04	16.5842	FINNHUB	2026-06-10 23:32:44.182328+00	\N
1832	4386	2026-06-11	221.7800	-3.4900	\N	50832.65	33.2731	FINNHUB	2026-06-10 23:32:47.511761+00	\N
1833	4387	2026-06-11	76.4700	-5.7903	\N	52132.50	11.6445	FINNHUB	2026-06-10 23:32:50.809349+00	\N
1834	4388	2026-06-11	74.4600	-0.7332	\N	49800.34	42.8574	FINNHUB	2026-06-10 23:32:54.146854+00	\N
1835	4389	2026-06-11	46.6000	5.7409	\N	53892.76	23.7622	FINNHUB	2026-06-10 23:32:57.451087+00	\N
1836	4390	2026-06-11	3110.0500	-0.8828	\N	52030.75	20.9960	FINNHUB	2026-06-10 23:33:00.741664+00	\N
1837	4391	2026-06-11	203.2000	0.3556	\N	51020.40	57.5202	FINNHUB	2026-06-10 23:33:04.043375+00	\N
1838	4392	2026-06-11	11.7600	-3.9216	\N	4789388.00	16.2683	FINNHUB	2026-06-10 23:33:07.361257+00	\N
1839	4393	2026-06-11	110.4800	0.7478	\N	51132.23	28.3798	FINNHUB	2026-06-10 23:33:10.652812+00	\N
1840	4394	2026-06-11	235.9500	-5.1381	\N	49103.39	48.7475	FINNHUB	2026-06-10 23:33:13.950853+00	\N
1841	4395	2026-06-11	138.5400	-5.2524	\N	49532.11	22.1027	FINNHUB	2026-06-10 23:33:17.229404+00	\N
1842	4396	2026-06-11	241.8100	1.0067	\N	51395.74	34.8446	FINNHUB	2026-06-10 23:33:20.5822+00	\N
1843	4397	2026-06-11	440.0700	-4.4303	\N	49619.28	45.6060	FINNHUB	2026-06-10 23:33:23.921208+00	\N
1844	4398	2026-06-11	85.9800	-1.7820	\N	49507.29	45.1626	FINNHUB	2026-06-10 23:33:27.216074+00	\N
1845	4399	2026-06-11	86.7200	-0.9141	\N	49204.88	25.7348	FINNHUB	2026-06-10 23:33:30.509851+00	\N
1846	4400	2026-06-11	78.1000	0.2954	\N	48611.87	23.2481	FINNHUB	2026-06-10 23:33:33.821535+00	\N
1847	4401	2026-06-11	3.1100	-0.3205	\N	255459.30	16.3990	FINNHUB	2026-06-10 23:33:37.189602+00	\N
1848	4402	2026-06-11	64.3000	-2.2945	\N	40666.35	45.7954	FINNHUB	2026-06-10 23:33:40.555761+00	\N
1849	4403	2026-06-11	15.6800	-0.2545	\N	7886637.50	41.1272	FINNHUB	2026-06-10 23:33:43.946678+00	\N
1850	4404	2026-06-11	221.2800	-1.2496	\N	47188.04	32.2543	FINNHUB	2026-06-10 23:33:47.306233+00	\N
1851	4405	2026-06-11	106.4100	-2.0707	\N	48096.30	23.5766	FINNHUB	2026-06-10 23:33:50.603241+00	\N
1852	4406	2026-06-11	216.3000	1.7069	\N	50812.72	32.6770	FINNHUB	2026-06-10 23:33:53.893984+00	\N
1853	4407	2026-06-11	87.9100	-3.8920	\N	48283.05	209.9263	FINNHUB	2026-06-10 23:33:57.184252+00	\N
1854	4408	2026-06-11	52.6500	-0.1138	\N	47844.19	22.0176	FINNHUB	2026-06-10 23:34:00.465778+00	\N
1855	4409	2026-06-11	45.6100	0.6177	\N	46668.52	16.7933	FINNHUB	2026-06-10 23:34:03.823656+00	\N
1856	4410	2026-06-11	320.8800	-1.6972	\N	38040.32	48.1751	FINNHUB	2026-06-10 23:34:07.120568+00	\N
1857	4411	2026-06-11	110.1700	-5.8376	\N	42956.51	74.8763	FINNHUB	2026-06-10 23:34:10.40917+00	\N
1858	4412	2026-06-11	231.7200	-2.5773	\N	45116.78	25.9860	FINNHUB	2026-06-10 23:34:13.703634+00	\N
1859	4413	2026-06-11	95.0300	-7.0793	\N	41384.34	88.6129	FINNHUB	2026-06-10 23:34:16.99814+00	\N
1860	4414	2026-06-11	608.5200	0.1613	\N	43868.92	33.2415	FINNHUB	2026-06-10 23:34:20.287924+00	\N
1861	4415	2026-06-11	161.8000	-0.8882	\N	44202.46	14.4217	FINNHUB	2026-06-10 23:34:23.594195+00	\N
1862	4416	2026-06-11	224.5600	-4.6211	\N	43701.95	17.6931	FINNHUB	2026-06-10 23:34:26.875686+00	\N
1863	4417	2026-06-11	79.7800	-0.7835	\N	33543.01	18.6063	FINNHUB	2026-06-10 23:34:30.170669+00	\N
1864	4418	2026-06-11	556.9400	-3.7917	\N	44457.67	40.5920	FINNHUB	2026-06-10 23:34:33.470411+00	\N
1865	4419	2026-06-11	256.5200	-3.4805	\N	45095.15	37.2687	FINNHUB	2026-06-10 23:34:36.820287+00	\N
1866	4420	2026-06-11	36.5400	1.4718	\N	47305.91	48.9709	FINNHUB	2026-06-10 23:34:40.159223+00	\N
1867	4421	2026-06-11	237.3300	4.6359	\N	49810.92	\N	FINNHUB	2026-06-10 23:34:43.594624+00	\N
1868	4422	2026-06-11	362.9200	-2.4041	\N	59319.23	44.4229	FINNHUB	2026-06-10 23:34:46.997771+00	\N
1869	4423	2026-06-11	11.6000	-2.1922	\N	372109.94	14.7856	FINNHUB	2026-06-10 23:34:50.29578+00	\N
1870	4424	2026-06-11	78.4700	-7.0591	\N	42637.78	12.2734	FINNHUB	2026-06-10 23:34:53.593404+00	\N
1871	4425	2026-06-11	115.3500	-1.4271	\N	42183.38	\N	FINNHUB	2026-06-10 23:34:56.913742+00	\N
1872	4426	2026-06-11	208.4600	-1.7440	\N	57010.02	29.8534	FINNHUB	2026-06-10 23:35:00.229426+00	\N
1873	4427	2026-06-11	364.4600	0.3524	\N	44056.57	38.9881	FINNHUB	2026-06-10 23:35:03.535965+00	\N
1874	4428	2026-06-11	38.1500	-1.9280	\N	6507793.50	14.5502	FINNHUB	2026-06-10 23:35:06.871553+00	\N
1875	4429	2026-06-11	147.7900	-2.7953	\N	41427.50	36.4038	FINNHUB	2026-06-10 23:35:10.167625+00	\N
1876	4430	2026-06-11	151.0800	-0.3627	\N	41792.44	24.0463	FINNHUB	2026-06-10 23:35:13.493589+00	\N
1877	4431	2026-06-11	22.0300	1.4273	\N	58287.73	15.0365	FINNHUB	2026-06-10 23:35:16.803734+00	\N
1878	4432	2026-06-11	31.7000	0.6989	\N	42830.41	23.3790	FINNHUB	2026-06-10 23:35:20.137423+00	\N
1879	4433	2026-06-11	97.5100	0.6607	\N	43218.15	19.2657	FINNHUB	2026-06-10 23:35:23.427126+00	\N
1880	4434	2026-06-11	128.3100	-1.7610	\N	28488.47	45.7440	FINNHUB	2026-06-10 23:35:26.747226+00	\N
1881	4435	2026-06-11	74.8200	-0.5846	\N	41273.82	52.9831	FINNHUB	2026-06-10 23:35:30.05852+00	\N
1882	4436	2026-06-11	117.4800	-2.9973	\N	41112.20	712.7868	FINNHUB	2026-06-10 23:35:33.361587+00	\N
1883	4437	2026-06-11	146.7100	-2.8861	\N	41603.97	13.1135	FINNHUB	2026-06-10 23:35:36.686652+00	\N
1884	4438	2026-06-11	93.3800	0.8750	\N	40729.70	38.4605	FINNHUB	2026-06-10 23:35:39.982047+00	\N
1885	4439	2026-06-11	66.6300	-2.4308	\N	40644.91	50.3603	FINNHUB	2026-06-10 23:35:43.263374+00	\N
1886	4440	2026-06-11	74.9200	1.2843	\N	57114.98	17.4131	FINNHUB	2026-06-10 23:35:46.569387+00	\N
1887	4441	2026-06-11	450.6200	0.3184	\N	40380.87	10.3674	FINNHUB	2026-06-10 23:35:49.854063+00	\N
1888	4442	2026-06-11	291.2200	-2.1734	\N	39902.90	69.1298	FINNHUB	2026-06-10 23:35:53.196603+00	\N
1889	4443	2026-06-11	84.3500	2.2796	\N	40094.41	153.9576	FINNHUB	2026-06-10 23:35:56.484758+00	\N
1890	4444	2026-06-11	153.9700	-0.9839	\N	40968.18	51.1717	FINNHUB	2026-06-10 23:36:00.554344+00	\N
1891	4445	2026-06-11	88.4800	-2.0264	\N	39725.82	33.1418	FINNHUB	2026-06-10 23:36:03.919998+00	\N
1892	4446	2026-06-11	74.9400	1.3799	\N	39049.69	12.3536	FINNHUB	2026-06-10 23:36:07.211915+00	\N
1893	4447	2026-06-11	9.0800	-0.4386	\N	29225.28	17.5317	FINNHUB	2026-06-10 23:36:10.513961+00	\N
1894	4448	2026-06-11	33.5800	-2.5254	\N	113109.73	24.2671	FINNHUB	2026-06-10 23:36:13.82842+00	\N
1895	4449	2026-06-11	210.4600	-0.7498	\N	39619.41	\N	FINNHUB	2026-06-10 23:36:17.13236+00	\N
1896	4450	2026-06-11	78.5900	0.0000	\N	39322.54	17.3763	FINNHUB	2026-06-10 23:36:20.425616+00	\N
1897	4451	2026-06-11	159.0300	0.9202	\N	55829.20	38.0109	FINNHUB	2026-06-10 23:36:25.899035+00	\N
1898	4452	2026-06-11	447.5900	-1.0873	\N	36473.25	177.0649	FINNHUB	2026-06-10 23:36:29.19244+00	\N
1899	4453	2026-06-11	107.6000	1.1278	\N	39659.33	18.4034	FINNHUB	2026-06-10 23:36:32.488893+00	\N
1900	4454	2026-06-11	100.7600	-1.4572	\N	52226052.00	8.6635	FINNHUB	2026-06-10 23:36:35.791117+00	\N
1901	4455	2026-06-11	28.4500	-0.9746	\N	275390.47	17.1903	FINNHUB	2026-06-10 23:36:39.273567+00	\N
1902	4456	2026-06-11	81.2800	1.4478	\N	39592.73	36.6260	FINNHUB	2026-06-10 23:36:42.566562+00	\N
1903	4457	2026-06-11	64.4600	2.3337	\N	39481.47	38.8597	FINNHUB	2026-06-10 23:36:45.857921+00	\N
1904	4458	2026-06-11	206.4300	0.9734	\N	39073.86	170.8363	FINNHUB	2026-06-10 23:36:49.158946+00	\N
1905	4459	2026-06-11	237.4500	-1.8112	\N	38040.32	48.1751	FINNHUB	2026-06-10 23:36:52.534504+00	\N
1906	4460	2026-06-11	268.3400	-0.5411	\N	38951.87	28.3931	FINNHUB	2026-06-10 23:36:55.860094+00	\N
1907	4461	2026-06-11	818.9700	-2.2230	\N	115119.39	65.7811	FINNHUB	2026-06-10 23:36:59.222009+00	\N
1908	4462	2026-06-11	134.0600	-1.4989	\N	39852.34	30.3753	FINNHUB	2026-06-10 23:37:02.616666+00	\N
1909	4463	2026-06-11	131.6200	-2.8491	\N	37745.62	26.6942	FINNHUB	2026-06-10 23:37:05.962411+00	\N
1910	4464	2026-06-11	237.6800	1.4339	\N	43220.31	91.5144	FINNHUB	2026-06-10 23:37:09.259094+00	\N
1911	4465	2026-06-11	25.9900	-6.2748	\N	36912.77	11.9189	FINNHUB	2026-06-10 23:37:12.730023+00	\N
1912	4466	2026-06-11	123.6500	1.1866	\N	646375.44	22.7096	FINNHUB	2026-06-10 23:37:16.06483+00	\N
1913	4467	2026-06-11	16.7200	0.8444	\N	36810.19	12.4611	FINNHUB	2026-06-10 23:37:19.360901+00	\N
1914	4468	2026-06-11	81.9600	-0.4373	\N	50145.22	23.5743	FINNHUB	2026-06-10 23:37:22.697903+00	\N
1915	4469	2026-06-11	30.4200	1.8072	\N	39482.55	27.1921	FINNHUB	2026-06-10 23:37:25.980194+00	\N
1916	4470	2026-06-11	85.4200	-1.0541	\N	144891.11	139.5868	FINNHUB	2026-06-10 23:37:29.271542+00	\N
1917	4471	2026-06-11	176.6100	0.4379	\N	35807.98	32.7264	FINNHUB	2026-06-10 23:37:32.579522+00	\N
1918	4472	2026-06-11	352.3600	-2.7651	\N	37316.81	46.1271	FINNHUB	2026-06-10 23:37:35.903238+00	\N
1919	4473	2026-06-11	167.5000	2.9755	\N	39404.09	470.9746	FINNHUB	2026-06-10 23:37:39.272522+00	\N
1920	4474	2026-06-11	123.3600	-2.2039	\N	36910.91	135.5504	FINNHUB	2026-06-10 23:37:42.604525+00	\N
1921	4475	2026-06-11	114.0100	0.8046	\N	36839.58	22.4782	FINNHUB	2026-06-10 23:37:45.898055+00	\N
1922	4476	2026-06-11	272.6700	-2.2688	\N	36201.61	32.5174	FINNHUB	2026-06-10 23:37:49.201314+00	\N
1923	4477	2026-06-11	78.5400	1.2766	\N	37683.18	21.7069	FINNHUB	2026-06-10 23:37:52.529847+00	\N
1924	4478	2026-06-11	40.7000	-1.8331	\N	36104.58	7.1367	FINNHUB	2026-06-10 23:37:55.804865+00	\N
1925	4479	2026-06-11	105.1700	1.4176	\N	36750.77	10.6032	FINNHUB	2026-06-10 23:37:59.085852+00	\N
1926	4480	2026-06-11	87.3200	-1.5669	\N	33891.04	\N	FINNHUB	2026-06-10 23:38:02.403958+00	\N
1927	4481	2026-06-11	776.7200	-6.1683	\N	34929.61	26.1132	FINNHUB	2026-06-10 23:38:05.697345+00	\N
1928	4482	2026-06-11	129.2600	0.2249	\N	35979.67	8.8576	FINNHUB	2026-06-10 23:38:08.982263+00	\N
1929	4483	2026-06-11	101.1000	0.8177	\N	36078.10	22.0432	FINNHUB	2026-06-10 23:38:12.275311+00	\N
1930	4484	2026-06-11	363.1800	-2.1474	\N	36441.68	81.1171	FINNHUB	2026-06-10 23:38:15.58832+00	\N
1931	4485	2026-06-11	12.5400	-4.8558	\N	37291.88	155.7833	FINNHUB	2026-06-10 23:38:18.905012+00	\N
1932	4486	2026-06-11	137.4700	-1.9682	\N	34636.81	40.8935	FINNHUB	2026-06-10 23:38:22.239423+00	\N
1933	4487	2026-06-11	26.1100	-2.2464	\N	5622790.50	\N	FINNHUB	2026-06-10 23:38:25.698578+00	\N
1934	4488	2026-06-11	55.7500	-3.8793	\N	26154.75	12.0324	FINNHUB	2026-06-10 23:38:29.020364+00	\N
1935	4489	2026-06-11	45.5900	1.0417	\N	1101557.40	28.2284	FINNHUB	2026-06-10 23:38:32.418905+00	\N
1936	4490	2026-06-11	552.8700	-3.3866	\N	33611.29	13.2641	FINNHUB	2026-06-10 23:38:35.752583+00	\N
1937	4491	2026-06-11	557.5500	-1.1050	\N	34961.34	37.1098	FINNHUB	2026-06-10 23:38:39.171637+00	\N
1938	4492	2026-06-11	102.7800	-6.2483	\N	35316.75	9.6389	FINNHUB	2026-06-10 23:38:42.481262+00	\N
1939	4493	2026-06-11	207.0900	1.1725	\N	31895.35	306.8159	FINNHUB	2026-06-10 23:38:45.763443+00	\N
1940	4494	2026-06-11	18.0500	0.7254	\N	34406.56	21.2124	FINNHUB	2026-06-10 23:38:49.055937+00	\N
1941	4495	2026-06-11	15.0500	2.5903	\N	25882.60	\N	FINNHUB	2026-06-10 23:38:52.454342+00	\N
1942	4496	2026-06-11	115.2400	-1.3103	\N	33450.27	\N	FINNHUB	2026-06-10 23:38:55.743551+00	\N
1943	4497	2026-06-11	52.6100	-0.1518	\N	33287.94	10.1354	FINNHUB	2026-06-10 23:38:59.042109+00	\N
1944	4498	2026-06-11	334.1000	-0.3787	\N	33738.69	19.6830	FINNHUB	2026-06-10 23:39:02.353541+00	\N
1945	4499	2026-06-11	3.3000	-0.9009	\N	171998.00	7.2337	FINNHUB	2026-06-10 23:39:05.659746+00	\N
1946	4500	2026-06-11	16.8400	0.1189	\N	34136.88	15.4675	FINNHUB	2026-06-10 23:39:08.990956+00	\N
1947	4501	2026-06-11	172.2100	-3.3126	\N	34287.79	48.4603	FINNHUB	2026-06-10 23:39:12.275385+00	\N
1948	4502	2026-06-11	81.2900	-1.1071	\N	34460.55	13.0384	FINNHUB	2026-06-10 23:39:15.563981+00	\N
1949	4503	2026-06-11	50.8100	-1.6263	\N	33714.99	18.3035	FINNHUB	2026-06-10 23:39:18.846782+00	\N
1950	4504	2026-06-11	73.2000	0.7293	\N	33422.38	34.9973	FINNHUB	2026-06-10 23:39:22.133929+00	\N
1951	4505	2026-06-11	33.5300	-5.5227	\N	521351.62	8.8386	FINNHUB	2026-06-10 23:39:25.696971+00	\N
1952	4506	2026-06-11	101.5800	1.0545	\N	33668.71	15.8890	FINNHUB	2026-06-10 23:39:28.991633+00	\N
1953	4507	2026-06-11	64.2700	-2.6065	\N	46866770.00	9.1791	FINNHUB	2026-06-10 23:39:32.350276+00	\N
1954	4508	2026-06-11	39.7300	0.2776	\N	33516.16	21.7637	FINNHUB	2026-06-10 23:39:35.674752+00	\N
1955	4509	2026-06-11	160.6600	-2.6303	\N	32230.79	25.2592	FINNHUB	2026-06-10 23:39:39.048621+00	\N
1956	4510	2026-06-11	66.1100	-2.6362	\N	26614.02	40.8084	FINNHUB	2026-06-10 23:39:42.368112+00	\N
1957	4511	2026-06-11	223.9300	-0.6654	\N	32749.51	11.1735	FINNHUB	2026-06-10 23:39:45.664099+00	\N
1958	4512	2026-06-11	80.0000	-4.3405	\N	34564.26	\N	FINNHUB	2026-06-10 23:39:48.943888+00	\N
1959	4513	2026-06-11	65.0300	-1.9895	\N	44520.01	13.3891	FINNHUB	2026-06-10 23:39:52.368931+00	\N
1960	4514	2026-06-11	54.5200	-1.9953	\N	32036.33	38.7245	FINNHUB	2026-06-10 23:39:55.666848+00	\N
1961	4515	2026-06-11	149.6000	0.9242	\N	31756.74	33.6370	FINNHUB	2026-06-10 23:39:58.958504+00	\N
1962	4516	2026-06-11	25.0100	0.1201	\N	22904.08	7.7098	FINNHUB	2026-06-10 23:40:02.344128+00	\N
1963	4517	2026-06-11	13.2900	6.5758	\N	31899.16	11.4211	FINNHUB	2026-06-10 23:40:05.622248+00	\N
1964	4518	2026-06-11	91.3100	0.9955	\N	31588.31	6.4836	FINNHUB	2026-06-10 23:40:08.911116+00	\N
1965	4519	2026-06-11	144.1900	-3.5841	\N	30654.29	\N	FINNHUB	2026-06-10 23:40:12.250013+00	\N
1966	4520	2026-06-11	61.4700	0.2610	\N	28225.63	16.5792	FINNHUB	2026-06-10 23:40:15.785177+00	\N
1967	4521	2026-06-11	166.1300	-2.6202	\N	30895.49	16.5181	FINNHUB	2026-06-10 23:40:19.081278+00	\N
1968	4522	2026-06-11	23.6600	-6.3712	\N	42032.32	10.5316	FINNHUB	2026-06-10 23:40:22.404561+00	\N
1969	4523	2026-06-11	66.1400	1.3019	\N	31603.90	12.4818	FINNHUB	2026-06-10 23:40:25.70167+00	\N
1970	4524	2026-06-11	16.2100	2.0781	\N	116565830.00	12.9111	FINNHUB	2026-06-10 23:40:29.020023+00	\N
1971	4525	2026-06-11	216.5000	-2.8364	\N	31242.44	\N	FINNHUB	2026-06-10 23:40:32.327981+00	\N
1972	4526	2026-06-11	65.3400	-1.3140	\N	31894.35	\N	FINNHUB	2026-06-10 23:40:35.612217+00	\N
1973	4527	2026-06-11	182.1700	-2.1906	\N	30277.33	21.8609	FINNHUB	2026-06-10 23:40:39.072188+00	\N
1974	4528	2026-06-11	28.4100	1.3919	\N	30621.43	9.8643	FINNHUB	2026-06-10 23:40:42.349885+00	\N
1975	4529	2026-06-11	146.0700	0.0822	\N	30486.55	24.1191	FINNHUB	2026-06-10 23:40:45.634642+00	\N
1976	4530	2026-06-11	108.7700	0.7223	\N	30185.30	19.8066	FINNHUB	2026-06-10 23:40:48.938745+00	\N
1977	4531	2026-06-11	85.3900	-1.3517	\N	31841.57	\N	FINNHUB	2026-06-10 23:40:52.273671+00	\N
1978	4532	2026-06-11	59.9100	-3.2149	\N	30154.36	33.4531	FINNHUB	2026-06-10 23:40:55.585373+00	\N
1979	4533	2026-06-11	47.9700	1.9770	\N	242868.28	6.3100	FINNHUB	2026-06-10 23:40:58.906304+00	\N
1980	4534	2026-06-11	263.6100	-1.7004	\N	205974.38	65.1200	FINNHUB	2026-06-10 23:41:02.253938+00	\N
1981	4535	2026-06-11	249.2700	-4.9277	\N	27706.85	16.6376	FINNHUB	2026-06-10 23:41:05.576331+00	\N
1982	4536	2026-06-11	41.5000	-3.4884	\N	30787.09	\N	FINNHUB	2026-06-10 23:41:08.91642+00	\N
1983	4537	2026-06-11	93.9600	-2.9640	\N	28393.68	13.7087	FINNHUB	2026-06-10 23:41:12.196656+00	\N
1984	4538	2026-06-11	50.5100	-4.1374	\N	29123.66	25.1935	FINNHUB	2026-06-10 23:41:15.474636+00	\N
1985	4539	2026-06-11	139.7400	-3.4278	\N	30291.38	65.5658	FINNHUB	2026-06-10 23:41:18.749435+00	\N
1986	4540	2026-06-11	150.5900	-0.5153	\N	29478.01	13.7299	FINNHUB	2026-06-10 23:41:22.04302+00	\N
1987	4541	2026-06-11	301.0800	3.6063	\N	31509.16	25.5114	FINNHUB	2026-06-10 23:41:25.372113+00	\N
1988	4542	2026-06-11	63.7600	-3.4086	\N	30027.41	15.7212	FINNHUB	2026-06-10 23:41:28.800375+00	\N
1989	4543	2026-06-11	53.2800	-1.3881	\N	28715.73	8.9737	FINNHUB	2026-06-10 23:41:32.087118+00	\N
1990	4544	2026-06-11	213.7600	-3.2629	\N	29202.67	26.5101	FINNHUB	2026-06-10 23:41:35.376716+00	\N
1991	4545	2026-06-11	194.2400	-2.4410	\N	28983.38	21.1265	FINNHUB	2026-06-10 23:41:38.819667+00	\N
1992	4546	2026-06-11	31.3600	0.1597	\N	28774.22	18.5258	FINNHUB	2026-06-10 23:41:42.105328+00	\N
1993	4547	2026-06-11	56.4800	1.2549	\N	39480.79	21.9094	FINNHUB	2026-06-10 23:41:45.423151+00	\N
1994	4548	2026-06-11	48.8400	1.5174	\N	39018.04	23.0876	FINNHUB	2026-06-10 23:41:48.766879+00	\N
1995	4549	2026-06-11	169.2700	0.9844	\N	28191.09	20.9415	FINNHUB	2026-06-10 23:41:52.100022+00	\N
1996	4550	2026-06-11	335.5800	-4.9564	\N	26578.68	59.0665	FINNHUB	2026-06-10 23:41:55.4542+00	\N
1997	4551	2026-06-11	193.5700	-1.7112	\N	28278.02	18.6093	FINNHUB	2026-06-10 23:41:58.78189+00	\N
1998	4552	2026-06-11	140.9200	-3.2276	\N	28464.06	42.9452	FINNHUB	2026-06-10 23:42:02.086549+00	\N
1999	4553	2026-06-11	70.4800	-4.6408	\N	27581.42	46.9871	FINNHUB	2026-06-10 23:42:05.451437+00	\N
2000	4554	2026-06-11	71.5000	0.3368	\N	27635.90	7.3130	FINNHUB	2026-06-10 23:42:08.757751+00	\N
2001	4555	2026-06-11	348.2800	2.3510	\N	28113.37	\N	FINNHUB	2026-06-10 23:42:12.052526+00	\N
2002	4556	2026-06-11	915.6000	20.2869	\N	32789.31	45.8946	FINNHUB	2026-06-10 23:42:15.335381+00	\N
2003	4557	2026-06-11	74.7700	-4.3740	\N	30387.50	32.6607	FINNHUB	2026-06-10 23:42:18.63359+00	\N
2004	4558	2026-06-11	9.7400	-0.9156	\N	118592.19	12.4284	FINNHUB	2026-06-10 23:42:21.976443+00	\N
2005	4559	2026-06-11	68.0000	-0.4684	\N	26942.71	15.7468	FINNHUB	2026-06-10 23:42:25.2489+00	\N
2006	4560	2026-06-11	163.7600	-2.3378	\N	27365.16	29.0608	FINNHUB	2026-06-10 23:42:28.519683+00	\N
2007	4561	2026-06-11	42.7400	0.8257	\N	27906.87	26.0568	FINNHUB	2026-06-10 23:42:31.865634+00	\N
2008	4562	2026-06-11	601.3500	-2.8922	\N	28285.79	30.3170	FINNHUB	2026-06-10 23:42:35.141948+00	\N
2009	4563	2026-06-11	218.9400	-5.2454	\N	26607.59	17.8814	FINNHUB	2026-06-10 23:42:38.493611+00	\N
2010	4564	2026-06-11	120.6500	-7.1637	\N	25955.56	108.6007	FINNHUB	2026-06-10 23:42:41.778364+00	\N
2011	4565	2026-06-11	15.1200	-4.9654	\N	28559.47	\N	FINNHUB	2026-06-10 23:42:45.053598+00	\N
2012	4566	2026-06-11	719.0200	-1.9835	\N	26579.17	52.0062	FINNHUB	2026-06-10 23:42:48.361212+00	\N
2013	4567	2026-06-11	186.5900	-0.1391	\N	26508.79	23.2445	FINNHUB	2026-06-10 23:42:51.673818+00	\N
2014	4568	2026-06-11	770.2500	-8.5225	\N	24349.15	70.2423	FINNHUB	2026-06-10 23:42:54.954938+00	\N
2015	4569	2026-06-11	64.9600	-1.0812	\N	27872.15	14.1125	FINNHUB	2026-06-10 23:42:58.228049+00	\N
2016	4570	2026-06-11	69.6600	-2.2590	\N	26729.66	18.0484	FINNHUB	2026-06-10 23:43:01.512525+00	\N
2017	4571	2026-06-11	35.5800	-0.4755	\N	26791.20	21.9780	FINNHUB	2026-06-10 23:43:04.79487+00	\N
2018	4572	2026-06-11	375.1800	-1.8136	\N	26076.47	51.7774	FINNHUB	2026-06-10 23:43:08.087532+00	\N
2019	4573	2026-06-11	288.0900	1.4794	\N	25833.99	30.7218	FINNHUB	2026-06-10 23:43:11.373904+00	\N
2020	4574	2026-06-11	280.7500	-2.2424	\N	26282.84	42.2489	FINNHUB	2026-06-10 23:43:14.659289+00	\N
2021	4575	2026-06-11	46.4300	1.1327	\N	26844.99	25.2066	FINNHUB	2026-06-10 23:43:18.004587+00	\N
2022	4076	2026-06-12	204.8700	2.2203	\N	4893966.00	30.6614	FINNHUB	2026-06-11 23:11:31.818029+00	\N
2023	4077	2026-06-12	295.6300	1.3890	\N	4357885.50	35.5528	FINNHUB	2026-06-11 23:11:35.087176+00	\N
2024	4078	2026-06-12	357.7700	0.3900	\N	4283430.00	26.7367	FINNHUB	2026-06-11 23:11:38.394543+00	\N
2025	4079	2026-06-12	390.3400	-1.7667	\N	2895083.00	23.1207	FINNHUB	2026-06-11 23:11:41.593953+00	\N
2026	4080	2026-06-12	241.5100	1.4748	\N	2544917.00	28.0283	FINNHUB	2026-06-11 23:11:44.93774+00	\N
2027	4081	2026-06-12	421.0700	3.0141	\N	58477492.00	30.3181	FINNHUB	2026-06-11 23:11:48.152977+00	\N
2028	4082	2026-06-12	385.5700	3.6200	\N	1824436.90	62.2314	FINNHUB	2026-06-11 23:11:51.390276+00	\N
2029	4083	2026-06-12	568.4300	-0.4466	\N	1449388.80	20.5334	FINNHUB	2026-06-11 23:11:54.602561+00	\N
2030	4084	2026-06-12	399.1500	4.6018	\N	1433146.50	371.0892	FINNHUB	2026-06-11 23:11:57.800382+00	\N
2031	4085	2026-06-12	485.7900	0.4362	\N	1045391.50	14.4250	FINNHUB	2026-06-11 23:12:01.079165+00	\N
2032	4086	2026-06-12	1160.9500	2.1630	\N	1075690.00	42.5566	FINNHUB	2026-06-11 23:12:04.336044+00	\N
2033	4087	2026-06-12	995.8700	11.6596	\N	1032906.00	42.8396	FINNHUB	2026-06-11 23:12:07.553162+00	\N
2034	4088	2026-06-12	120.5000	-0.0746	\N	959664.80	42.2090	FINNHUB	2026-06-11 23:12:10.818173+00	\N
2035	4089	2026-06-12	313.4900	1.4071	\N	842090.10	14.2972	FINNHUB	2026-06-11 23:12:14.044814+00	\N
2036	4090	2026-06-12	488.4500	7.9686	\N	796530.44	159.0199	FINNHUB	2026-06-11 23:12:17.266713+00	\N
2037	4091	2026-06-12	1899.4800	9.5313	\N	575727.50	56.3720	FINNHUB	2026-06-11 23:12:20.565455+00	\N
2038	4092	2026-06-12	146.6000	-2.6690	\N	624311.94	24.6627	FINNHUB	2026-06-11 23:12:23.792219+00	\N
2039	4093	2026-06-12	184.1000	-8.5263	\N	507708.38	31.3207	FINNHUB	2026-06-11 23:12:26.998149+00	\N
2040	4094	2026-06-12	319.0500	-1.2107	\N	608497.00	27.3654	FINNHUB	2026-06-11 23:12:30.322032+00	\N
2041	4095	2026-06-12	238.3300	-0.0671	\N	577611.75	27.4530	FINNHUB	2026-06-11 23:12:33.59465+00	\N
2042	4096	2026-06-12	116.9600	9.2676	\N	578743.90	\N	FINNHUB	2026-06-11 23:12:36.802497+00	\N
2043	4097	2026-06-12	121.8300	2.5505	\N	468242.47	39.1573	FINNHUB	2026-06-11 23:12:40.048247+00	\N
2044	4098	2026-06-12	486.5100	-0.5255	\N	431630.72	27.7219	FINNHUB	2026-06-11 23:12:43.275225+00	\N
2045	4099	2026-06-12	975.6900	-0.7810	\N	437436.40	49.4950	FINNHUB	2026-06-11 23:12:46.588155+00	\N
2046	4100	2026-06-12	897.6300	4.8437	\N	411696.62	43.6582	FINNHUB	2026-06-11 23:12:49.803518+00	\N
2047	4101	2026-06-12	224.7700	-0.0800	\N	397440.03	109.3370	FINNHUB	2026-06-11 23:12:53.008836+00	\N
2048	4102	2026-06-12	55.1600	1.1368	\N	388715.75	12.2635	FINNHUB	2026-06-11 23:12:56.329662+00	\N
2049	4103	2026-06-12	362.5200	12.6538	\N	424362.50	63.2602	FINNHUB	2026-06-11 23:12:59.57479+00	\N
2050	4104	2026-06-12	185.8200	-2.0969	\N	371970.72	33.7879	FINNHUB	2026-06-11 23:13:02.84027+00	\N
2051	4105	2026-06-12	342.2300	11.3197	\N	345651.03	382.3573	FINNHUB	2026-06-11 23:13:06.034101+00	\N
2052	4106	2026-06-12	405.5500	-0.4688	\N	367253.56	30.4927	FINNHUB	2026-06-11 23:13:09.37475+00	\N
2053	4107	2026-06-12	552.6400	11.1929	\N	416796.94	48.9888	FINNHUB	2026-06-11 23:13:12.657789+00	\N
2054	4108	2026-06-12	81.2700	-0.8902	\N	339937.75	25.4185	FINNHUB	2026-06-11 23:13:15.880485+00	\N
2055	4109	2026-06-12	332.7600	4.4084	\N	339011.56	39.2829	FINNHUB	2026-06-11 23:13:19.214837+00	\N
2056	4110	2026-06-12	82.5300	-1.2681	\N	358654.90	26.1773	FINNHUB	2026-06-11 23:13:22.427789+00	\N
2057	4111	2026-06-12	148.3400	-0.4764	\N	347753.00	20.9288	FINNHUB	2026-06-11 23:13:25.64556+00	\N
2058	4112	2026-06-12	212.6600	2.9033	\N	329053.20	18.1667	FINNHUB	2026-06-11 23:13:28.834962+00	\N
2059	4113	2026-06-12	131.0800	0.6682	\N	312154.06	136.8179	FINNHUB	2026-06-11 23:13:32.031271+00	\N
2060	4114	2026-06-12	1035.6400	3.4306	\N	297037.06	16.4400	FINNHUB	2026-06-11 23:13:35.358978+00	\N
2061	4115	2026-06-12	90.7200	5.2925	\N	222252.22	13.3117	FINNHUB	2026-06-11 23:13:38.593563+00	\N
2062	4116	2026-06-12	326.0100	2.2231	\N	320313.78	22.8600	FINNHUB	2026-06-11 23:13:41.822778+00	\N
2063	4117	2026-06-12	120.7600	1.4023	\N	297996.66	33.3516	FINNHUB	2026-06-11 23:13:45.146515+00	\N
2064	4118	2026-06-12	182.2800	1.8552	\N	208808.10	26.8523	FINNHUB	2026-06-11 23:13:48.378779+00	\N
2065	4119	2026-06-12	180.7700	-1.1916	\N	281740.70	25.3912	FINNHUB	2026-06-11 23:13:51.590591+00	\N
2066	4120	2026-06-12	112.6900	-2.3314	\N	277900.25	17.7863	FINNHUB	2026-06-11 23:13:54.794559+00	\N
2067	4121	2026-06-12	153.9200	3.9157	\N	216115.14	19.9929	FINNHUB	2026-06-11 23:13:58.009927+00	\N
2068	4122	2026-06-12	199.2700	0.8400	\N	385129.16	17.3967	FINNHUB	2026-06-11 23:14:01.222023+00	\N
2069	4123	2026-06-12	274.8500	0.9142	\N	255902.55	23.8005	FINNHUB	2026-06-11 23:14:04.550749+00	\N
2070	4124	2026-06-12	297.1000	5.3509	\N	260834.61	48.5997	FINNHUB	2026-06-11 23:14:07.754785+00	\N
2071	4125	2026-06-12	391.4500	5.8459	\N	254507.88	30.2661	FINNHUB	2026-06-11 23:14:10.992179+00	\N
2072	4126	2026-06-12	2411.6400	12.9235	\N	315026.53	67.4494	FINNHUB	2026-06-11 23:14:14.255222+00	\N
2073	4127	2026-06-12	906.7900	4.5785	\N	233004.44	24.8565	FINNHUB	2026-06-11 23:14:17.546243+00	\N
2074	4128	2026-06-12	82.4000	0.5246	\N	250843.72	11.5612	FINNHUB	2026-06-11 23:14:20.768695+00	\N
2075	4129	2026-06-12	184.2100	3.8329	\N	248072.55	34.1886	FINNHUB	2026-06-11 23:14:23.97953+00	\N
2076	4130	2026-06-12	85.8500	-0.2324	\N	179920.61	12.8207	FINNHUB	2026-06-11 23:14:27.195109+00	\N
2077	4131	2026-06-12	515.4400	1.2334	\N	239212.53	33.7775	FINNHUB	2026-06-11 23:14:30.446009+00	\N
2078	4132	2026-06-12	174.9500	1.6974	\N	33320726.00	8.6590	FINNHUB	2026-06-11 23:14:33.71359+00	\N
2079	4133	2026-06-12	1881.5100	14.5007	\N	243345.55	53.9928	FINNHUB	2026-06-11 23:14:37.012722+00	\N
2080	4134	2026-06-12	280.7100	11.1327	\N	227465.48	90.0247	FINNHUB	2026-06-11 23:14:40.350057+00	\N
2081	4135	2026-06-12	202.9600	6.1506	\N	212078.08	21.3724	FINNHUB	2026-06-11 23:14:43.571093+00	\N
2082	4136	2026-06-12	20.0800	2.0844	\N	35592304.00	14.6638	FINNHUB	2026-06-11 23:14:46.809085+00	\N
2083	4137	2026-06-12	138.0700	3.5163	\N	236777.28	14.7746	FINNHUB	2026-06-11 23:14:50.005156+00	\N
2084	4138	2026-06-12	279.5300	6.1963	\N	214524.30	254.5376	FINNHUB	2026-06-11 23:14:53.214566+00	\N
2085	4139	2026-06-12	88.0000	6.0880	\N	305857.53	20.8885	FINNHUB	2026-06-11 23:14:56.461523+00	\N
2086	4140	2026-06-12	163.6400	-3.9107	\N	174783.58	23.9004	FINNHUB	2026-06-11 23:14:59.675511+00	\N
2087	4141	2026-06-12	318.4900	1.6436	\N	216850.16	19.3271	FINNHUB	2026-06-11 23:15:02.891568+00	\N
2088	4142	2026-06-12	284.7700	0.7964	\N	200582.90	23.1166	FINNHUB	2026-06-11 23:15:06.164403+00	\N
2089	4143	2026-06-12	87.7200	-0.7805	\N	171985.61	13.1462	FINNHUB	2026-06-11 23:15:09.395746+00	\N
2090	4144	2026-06-12	43.9600	2.6863	\N	1258096.40	10.3159	FINNHUB	2026-06-11 23:15:12.609759+00	\N
2091	4145	2026-06-12	412.1300	4.9558	\N	195404.72	58.9735	FINNHUB	2026-06-11 23:15:15.892904+00	\N
2092	4146	2026-06-12	156.4000	3.0575	\N	191096.58	51.3631	FINNHUB	2026-06-11 23:15:19.248851+00	\N
2093	4147	2026-06-12	143.7300	-0.4088	\N	197224.69	22.5838	FINNHUB	2026-06-11 23:15:22.491169+00	\N
2094	4148	2026-06-12	185.8200	0.1455	\N	203757.50	19.3263	FINNHUB	2026-06-11 23:15:25.716507+00	\N
2095	4149	2026-06-12	868.0900	6.3849	\N	182968.61	76.9422	FINNHUB	2026-06-11 23:15:28.968495+00	\N
2096	4150	2026-06-12	46.9400	-0.0213	\N	196042.48	11.3058	FINNHUB	2026-06-11 23:15:32.166261+00	\N
2097	4151	2026-06-12	354.0600	4.8352	\N	185918.70	23.8357	FINNHUB	2026-06-11 23:15:35.399174+00	\N
2098	4152	2026-06-12	478.5700	-2.9230	\N	165611.70	41.7901	FINNHUB	2026-06-11 23:15:38.662436+00	\N
2099	4153	2026-06-12	116.2500	1.5284	\N	269728.03	18.0904	FINNHUB	2026-06-11 23:15:42.22802+00	\N
2100	4154	2026-06-12	84.8400	-0.3289	\N	177233.19	21.6587	FINNHUB	2026-06-11 23:15:45.42235+00	\N
2101	4155	2026-06-12	168.3400	0.4056	\N	186457.55	32.2034	FINNHUB	2026-06-11 23:15:48.623998+00	\N
2102	4156	2026-06-12	12.5600	5.3691	\N	153253.06	9.4870	FINNHUB	2026-06-11 23:15:51.849149+00	\N
2103	4157	2026-06-12	529.2900	7.9985	\N	168925.27	25.9446	FINNHUB	2026-06-11 23:15:55.130313+00	\N
2104	4158	2026-06-12	103.6400	4.6235	\N	128775.34	17.2631	FINNHUB	2026-06-11 23:15:58.353615+00	\N
2105	4159	2026-06-12	475.6600	-1.3235	\N	175617.16	25.6525	FINNHUB	2026-06-11 23:16:01.850218+00	\N
2106	4160	2026-06-12	100.3400	1.7544	\N	173885.56	15.4923	FINNHUB	2026-06-11 23:16:05.056511+00	\N
2107	4161	2026-06-12	691.5300	6.7604	\N	176039.20	\N	FINNHUB	2026-06-11 23:16:08.342399+00	\N
2108	4162	2026-06-12	152.4600	2.1713	\N	184043.08	41.2144	FINNHUB	2026-06-11 23:16:11.565866+00	\N
2109	4163	2026-06-12	221.6300	6.0431	\N	166607.77	73.4602	FINNHUB	2026-06-11 23:16:14.834836+00	\N
2110	4164	2026-06-12	1016.5800	0.5838	\N	164580.05	26.3118	FINNHUB	2026-06-11 23:16:18.024942+00	\N
2111	4165	2026-06-12	268.2800	0.4681	\N	153637.27	21.3001	FINNHUB	2026-06-11 23:16:21.315284+00	\N
2112	4166	2026-06-12	125.8700	3.6138	\N	158126.47	17.1560	FINNHUB	2026-06-11 23:16:24.552781+00	\N
2113	4167	2026-06-12	89.6500	0.5383	\N	155988.00	24.8547	FINNHUB	2026-06-11 23:16:27.801959+00	\N
2114	4168	2026-06-12	23.0000	-0.9048	\N	161824.72	7.5510	FINNHUB	2026-06-11 23:16:31.262368+00	\N
2115	4169	2026-06-12	568.6400	1.5338	\N	152008.52	31.7810	FINNHUB	2026-06-11 23:16:34.500618+00	\N
2116	4170	2026-06-12	88.7000	-0.6385	\N	156000.45	16.5570	FINNHUB	2026-06-11 23:16:37.703542+00	\N
2117	4171	2026-06-12	393.6400	4.8421	\N	148889.75	37.3064	FINNHUB	2026-06-11 23:16:40.966162+00	\N
2118	4172	2026-06-12	176.5500	4.9831	\N	146588.14	80.9879	FINNHUB	2026-06-11 23:16:44.163671+00	\N
2119	4173	2026-06-12	82.2700	1.2429	\N	138630.33	22.0787	FINNHUB	2026-06-11 23:16:47.498944+00	\N
2120	4174	2026-06-12	166.4500	-2.6153	\N	136830.33	17.0548	FINNHUB	2026-06-11 23:16:50.711193+00	\N
2121	4175	2026-06-12	412.9000	0.2136	\N	144774.69	48.5968	FINNHUB	2026-06-11 23:16:55.676113+00	\N
2122	4176	2026-06-12	26.1700	2.2266	\N	150123.36	20.0405	FINNHUB	2026-06-11 23:16:58.884986+00	\N
2123	4177	2026-06-12	23.8200	3.6103	\N	23767268.00	15.0143	FINNHUB	2026-06-11 23:17:02.238645+00	\N
2124	4178	2026-06-12	210.6700	-0.3265	\N	149202.06	106.0005	FINNHUB	2026-06-11 23:17:05.536078+00	\N
2125	4179	2026-06-12	182.1600	8.5837	\N	141872.90	28.5706	FINNHUB	2026-06-11 23:17:09.038869+00	\N
2126	4180	2026-06-12	48.1900	3.0361	\N	115894.99	15.9176	FINNHUB	2026-06-11 23:17:12.36563+00	\N
2127	4181	2026-06-12	69.5500	1.3701	\N	142269.62	16.6592	FINNHUB	2026-06-11 23:17:15.552518+00	\N
2128	4182	2026-06-12	115.3600	-3.8025	\N	146183.10	19.9649	FINNHUB	2026-06-11 23:17:18.825315+00	\N
2129	4183	2026-06-12	110.4700	2.0980	\N	141950.44	106.5694	FINNHUB	2026-06-11 23:17:22.147703+00	\N
2130	4184	2026-06-12	120.8800	2.0257	\N	147656.64	48.3472	FINNHUB	2026-06-11 23:17:25.344862+00	\N
2131	4185	2026-06-12	147.1900	0.9741	\N	140391.25	37.7675	FINNHUB	2026-06-11 23:17:28.571646+00	\N
2132	4186	2026-06-12	219.1200	6.4309	\N	130456.51	28.9196	FINNHUB	2026-06-11 23:17:32.017675+00	\N
2133	4187	2026-06-12	21.1500	1.8786	\N	20401612.00	\N	FINNHUB	2026-06-11 23:17:35.25168+00	\N
2134	4188	2026-06-12	180.7900	-1.5466	\N	128591.31	34.8580	FINNHUB	2026-06-11 23:17:38.577714+00	\N
2135	4189	2026-06-12	163.5900	1.8364	\N	126638.38	20.5782	FINNHUB	2026-06-11 23:17:41.795162+00	\N
2136	4190	2026-06-12	61.3900	0.4418	\N	98666.03	12.7081	FINNHUB	2026-06-11 23:17:45.00742+00	\N
2137	4191	2026-06-12	327.9300	-0.8016	\N	127668.03	11.2991	FINNHUB	2026-06-11 23:17:48.224266+00	\N
2138	4192	2026-06-12	413.3400	-3.0583	\N	123178.92	25.7858	FINNHUB	2026-06-11 23:17:51.447318+00	\N
2139	4193	2026-06-12	23.1500	5.1317	\N	108122.11	10.0085	FINNHUB	2026-06-11 23:17:54.672488+00	\N
2140	4194	2026-06-12	56.4600	0.0354	\N	172184.47	24.9362	FINNHUB	2026-06-11 23:17:57.963175+00	\N
2141	4195	2026-06-12	100.4800	2.5097	\N	124696.37	42.5295	FINNHUB	2026-06-11 23:18:01.184401+00	\N
2142	4196	2026-06-12	58.3200	-0.5457	\N	90254.02	11.0442	FINNHUB	2026-06-11 23:18:04.409454+00	\N
2143	4197	2026-06-12	81.3000	-0.6355	\N	116462.30	8.2531	FINNHUB	2026-06-11 23:18:07.639073+00	\N
2144	4198	2026-06-12	548.6800	4.5065	\N	125635.27	26.2122	FINNHUB	2026-06-11 23:18:10.83123+00	\N
2145	4199	2026-06-12	23.8100	2.6293	\N	11502019.00	15.1291	FINNHUB	2026-06-11 23:18:14.147678+00	\N
2146	4200	2026-06-12	71.4100	-2.3520	\N	120390.81	14.9498	FINNHUB	2026-06-11 23:18:17.382356+00	\N
2147	4201	2026-06-12	202.2600	-0.9500	\N	119321.50	10.3228	FINNHUB	2026-06-11 23:18:20.611188+00	\N
2148	4202	2026-06-12	221.0500	2.2480	\N	121482.80	18.2901	FINNHUB	2026-06-11 23:18:23.830312+00	\N
2149	4203	2026-06-12	9.5200	1.8182	\N	18566680.00	14.8696	FINNHUB	2026-06-11 23:18:27.043967+00	\N
2150	4204	2026-06-12	305.6400	-1.0361	\N	116376.82	34.8747	FINNHUB	2026-06-11 23:18:30.272171+00	\N
2151	4205	2026-06-12	56.9000	2.3381	\N	116081.54	19.4223	FINNHUB	2026-06-11 23:18:33.594626+00	\N
2152	4206	2026-06-12	103.0800	-2.8097	\N	109380.52	62.2541	FINNHUB	2026-06-11 23:18:37.028982+00	\N
2153	4207	2026-06-12	297.8800	6.0147	\N	107926.89	69.2549	FINNHUB	2026-06-11 23:18:40.258768+00	\N
2154	4208	2026-06-12	166.6000	1.3444	\N	161994.23	16.6472	FINNHUB	2026-06-11 23:18:43.49356+00	\N
2155	4209	2026-06-12	445.0400	2.1413	\N	110585.56	25.4905	FINNHUB	2026-06-11 23:18:46.763643+00	\N
2156	4210	2026-06-12	42.6800	-0.6286	\N	83509.12	34.7566	FINNHUB	2026-06-11 23:18:49.989785+00	\N
2157	4211	2026-06-12	182.0400	2.4827	\N	110270.57	34.2136	FINNHUB	2026-06-11 23:18:53.193545+00	\N
2158	4212	2026-06-12	902.3700	3.0573	\N	113508.01	32.6156	FINNHUB	2026-06-11 23:18:56.474242+00	\N
2159	4213	2026-06-12	18.2400	0.7178	\N	569585.06	5.2944	FINNHUB	2026-06-11 23:18:59.846939+00	\N
2160	4214	2026-06-12	16.3400	1.5538	\N	569585.06	5.2944	FINNHUB	2026-06-11 23:19:03.261301+00	\N
2161	4215	2026-06-12	167.5200	-1.7478	\N	104117.96	13.6133	FINNHUB	2026-06-11 23:19:06.46343+00	\N
2162	4216	2026-06-12	102.2800	3.5642	\N	116631.20	77.9777	FINNHUB	2026-06-11 23:19:09.683503+00	\N
2163	4217	2026-06-12	44.1100	1.2394	\N	91656.56	7.4950	FINNHUB	2026-06-11 23:19:13.059402+00	\N
2164	4218	2026-06-12	1043.1800	0.4671	\N	103235.42	72.5987	FINNHUB	2026-06-11 23:19:16.363644+00	\N
2165	4219	2026-06-12	97.5900	5.1956	\N	104182.47	12.3205	FINNHUB	2026-06-11 23:19:19.677912+00	\N
2166	4220	2026-06-12	145.0600	4.4499	\N	105596.62	54.0274	FINNHUB	2026-06-11 23:19:22.950035+00	\N
2167	4221	2026-06-12	80.3300	0.0997	\N	102858.45	21.4199	FINNHUB	2026-06-11 23:19:26.165418+00	\N
2168	4222	2026-06-12	93.2700	-0.7977	\N	106011.40	24.2978	FINNHUB	2026-06-11 23:19:29.391574+00	\N
2169	4223	2026-06-12	50.6100	-0.6868	\N	106011.40	24.2978	FINNHUB	2026-06-11 23:19:32.693449+00	\N
2170	4224	2026-06-12	683.2900	4.9730	\N	98996.18	89.6100	FINNHUB	2026-06-11 23:19:35.891446+00	\N
2171	4225	2026-06-12	383.7400	-0.3609	\N	105083.14	89.7403	FINNHUB	2026-06-11 23:19:39.149547+00	\N
2172	4226	2026-06-12	396.8900	2.7600	\N	103405.50	40.0176	FINNHUB	2026-06-11 23:19:42.356704+00	\N
2173	4227	2026-06-12	52.8600	3.3027	\N	77029.65	13.2149	FINNHUB	2026-06-11 23:19:45.595557+00	\N
2174	4228	2026-06-12	486.0000	-3.3989	\N	100931.02	32.3218	FINNHUB	2026-06-11 23:19:48.841785+00	\N
2175	4229	2026-06-12	218.8000	-6.2473	\N	94332.20	13.0872	FINNHUB	2026-06-11 23:19:52.201739+00	\N
2176	4230	2026-06-12	460.1400	2.4537	\N	101716.47	35.0976	FINNHUB	2026-06-11 23:19:55.423293+00	\N
2177	4231	2026-06-12	264.6000	6.0564	\N	105868.45	60.7044	FINNHUB	2026-06-11 23:19:58.653523+00	\N
2178	4232	2026-06-12	111.8400	1.5435	\N	142457.12	14.5098	FINNHUB	2026-06-11 23:20:01.865546+00	\N
2179	4233	2026-06-12	45.0300	0.9415	\N	98501.57	73.7287	FINNHUB	2026-06-11 23:20:05.067683+00	\N
2180	4234	2026-06-12	82.6900	1.3855	\N	140336.33	14.6980	FINNHUB	2026-06-11 23:20:08.471828+00	\N
2181	4235	2026-06-12	142.0900	1.6744	\N	96662.77	\N	FINNHUB	2026-06-11 23:20:11.690159+00	\N
2182	4236	2026-06-12	124.1900	-0.6798	\N	98299.28	19.1281	FINNHUB	2026-06-11 23:20:14.958849+00	\N
2183	4237	2026-06-12	45.4400	-0.1757	\N	132646.95	13.6609	FINNHUB	2026-06-11 23:20:18.523248+00	\N
2184	4238	2026-06-12	27.4600	2.5775	\N	9274961.00	17.1100	FINNHUB	2026-06-11 23:20:22.264228+00	\N
2185	4239	2026-06-12	358.8600	5.2159	\N	95797.19	22.0680	FINNHUB	2026-06-11 23:20:25.451206+00	\N
2186	4240	2026-06-12	36.7500	-1.9739	\N	894062.70	16.9946	FINNHUB	2026-06-11 23:20:28.679671+00	\N
2187	4241	2026-06-12	262.1800	-0.6141	\N	96315.12	22.5546	FINNHUB	2026-06-11 23:20:31.902799+00	\N
2188	4242	2026-06-12	787.1900	-0.4112	\N	95855.52	20.1293	FINNHUB	2026-06-11 23:20:35.141427+00	\N
2189	4243	2026-06-12	225.7700	-2.3064	\N	91373.27	21.0271	FINNHUB	2026-06-11 23:20:38.493087+00	\N
2190	4244	2026-06-12	108.6500	5.2198	\N	87771.66	16.7216	FINNHUB	2026-06-11 23:20:41.838421+00	\N
2191	4245	2026-06-12	233.9400	0.5588	\N	94018.33	13.0310	FINNHUB	2026-06-11 23:20:45.048406+00	\N
2192	4246	2026-06-12	66.3400	6.8621	\N	92521.35	33.8534	FINNHUB	2026-06-11 23:20:48.276357+00	\N
2193	4247	2026-06-12	246.7100	1.8201	\N	87516.35	23.0853	FINNHUB	2026-06-11 23:20:51.4594+00	\N
2194	4248	2026-06-12	189.3100	-1.6571	\N	88025.84	30.3506	FINNHUB	2026-06-11 23:20:54.78109+00	\N
2195	4249	2026-06-12	399.1800	-1.3298	\N	86228.66	16.4464	FINNHUB	2026-06-11 23:20:58.027213+00	\N
2196	4250	2026-06-12	655.6900	3.9919	\N	87613.40	32.7772	FINNHUB	2026-06-11 23:21:01.23955+00	\N
2197	4251	2026-06-12	456.2900	-0.9228	\N	86720.98	112.1487	FINNHUB	2026-06-11 23:21:04.521169+00	\N
2198	4252	2026-06-12	218.7900	-2.4478	\N	90065.41	32.2353	FINNHUB	2026-06-11 23:21:07.720089+00	\N
2199	4253	2026-06-12	227.4400	3.5371	\N	80769.12	\N	FINNHUB	2026-06-11 23:21:10.946013+00	\N
2200	4254	2026-06-12	71.6200	-0.8857	\N	88373.85	31.6525	FINNHUB	2026-06-11 23:21:14.150238+00	\N
2201	4255	2026-06-12	144.0100	3.3367	\N	88186.11	24.9748	FINNHUB	2026-06-11 23:21:17.382874+00	\N
2203	4257	2026-06-12	47.3650	2.0577	\N	87899.26	28.8194	FINNHUB	2026-06-11 23:21:23.806362+00	\N
2204	4258	2026-06-12	57.6300	1.4434	\N	88186.13	11.2972	FINNHUB	2026-06-11 23:21:27.159687+00	\N
2205	4259	2026-06-12	29.6800	3.3786	\N	71010.48	7.3426	FINNHUB	2026-06-11 23:21:30.418544+00	\N
2206	4260	2026-06-12	23.9700	0.0000	\N	86358.63	4.5943	FINNHUB	2026-06-11 23:21:33.664389+00	\N
2207	4261	2026-06-12	7.9100	3.8058	\N	447669.28	12.8460	FINNHUB	2026-06-11 23:21:36.878566+00	\N
2208	4262	2026-06-12	14.0900	5.1493	\N	65526.98	83.9014	FINNHUB	2026-06-11 23:21:40.20886+00	\N
2209	4263	2026-06-12	95.3000	0.2947	\N	85315.88	28.8072	FINNHUB	2026-06-11 23:21:43.431384+00	\N
2210	4264	2026-06-12	234.2400	2.9038	\N	83380.12	614.5668	FINNHUB	2026-06-11 23:21:46.681235+00	\N
2211	4265	2026-06-12	24.7500	4.6954	\N	60302.15	5.4523	FINNHUB	2026-06-11 23:21:49.962136+00	\N
2212	4266	2026-06-12	240.3900	0.2043	\N	83149.34	\N	FINNHUB	2026-06-11 23:21:53.250435+00	\N
2213	4267	2026-06-12	378.5100	1.3848	\N	83780.02	12.3315	FINNHUB	2026-06-11 23:21:56.455311+00	\N
2214	4268	2026-06-12	56.0000	0.8827	\N	82377.67	24.7455	FINNHUB	2026-06-11 23:21:59.640867+00	\N
2215	4269	2026-06-12	157.7600	3.4627	\N	106415.17	14.2488	FINNHUB	2026-06-11 23:22:02.942183+00	\N
2216	4270	2026-06-12	37.2800	-1.5580	\N	81932.44	13.8798	FINNHUB	2026-06-11 23:22:06.220874+00	\N
2217	4271	2026-06-12	1610.0000	1.3669	\N	79087.60	41.1915	FINNHUB	2026-06-11 23:22:09.412077+00	\N
2218	4272	2026-06-12	276.9100	-2.5720	\N	76366.06	16.6593	FINNHUB	2026-06-11 23:22:12.608067+00	\N
2219	4273	2026-06-12	81.5200	1.4183	\N	59683.65	18.4152	FINNHUB	2026-06-11 23:22:15.926598+00	\N
2220	4274	2026-06-12	36.8000	7.2886	\N	2365073.80	50.0513	FINNHUB	2026-06-11 23:22:19.147531+00	\N
2221	4275	2026-06-12	157.9100	0.6758	\N	82801.41	29.7099	FINNHUB	2026-06-11 23:22:22.368291+00	\N
2222	4276	2026-06-12	138.9800	-0.9691	\N	79007.75	20.0986	FINNHUB	2026-06-11 23:22:25.655926+00	\N
2223	4277	2026-06-12	214.8600	0.9586	\N	69970.31	14.9080	FINNHUB	2026-06-11 23:22:28.903129+00	\N
2224	4278	2026-06-12	54.0600	-0.3319	\N	68747.37	15.3385	FINNHUB	2026-06-11 23:22:32.128178+00	\N
2225	4279	2026-06-12	89.3100	-0.3237	\N	110913.79	27.2048	FINNHUB	2026-06-11 23:22:35.365947+00	\N
2226	4280	2026-06-12	168.1500	0.5983	\N	81102.88	20.6632	FINNHUB	2026-06-11 23:22:38.677603+00	\N
2227	4281	2026-06-12	63.3600	-1.2777	\N	82307.63	31.4752	FINNHUB	2026-06-11 23:22:41.943228+00	\N
2228	4282	2026-06-12	130.8700	1.3710	\N	77809.20	30.9135	FINNHUB	2026-06-11 23:22:45.220902+00	\N
2229	4283	2026-06-12	338.0000	5.8731	\N	77285.92	17.2359	FINNHUB	2026-06-11 23:22:48.441961+00	\N
2230	4284	2026-06-12	441.8200	-1.9681	\N	77505.66	31.0644	FINNHUB	2026-06-11 23:22:51.636629+00	\N
2231	4285	2026-06-12	341.8600	1.0762	\N	77933.15	50.5403	FINNHUB	2026-06-11 23:22:54.879341+00	\N
2232	4286	2026-06-12	142.0900	3.6321	\N	77831.49	31.8459	FINNHUB	2026-06-11 23:22:58.14723+00	\N
2233	4287	2026-06-12	552.5200	1.9146	\N	77968.56	17.0386	FINNHUB	2026-06-11 23:23:01.37997+00	\N
2234	4288	2026-06-12	5.4200	5.0388	\N	56619.23	9.0000	FINNHUB	2026-06-11 23:23:04.589409+00	\N
2235	4289	2026-06-12	125.6100	0.0717	\N	77422.20	15.3745	FINNHUB	2026-06-11 23:23:07.799387+00	\N
2236	4290	2026-06-12	294.8400	-0.3279	\N	78358.47	12.4616	FINNHUB	2026-06-11 23:23:11.099752+00	\N
2237	4291	2026-06-12	260.8100	-0.9382	\N	76861.07	16.5935	FINNHUB	2026-06-11 23:23:14.344088+00	\N
2238	4292	2026-06-12	255.6000	-0.9264	\N	76605.70	18.2134	FINNHUB	2026-06-11 23:23:17.557095+00	\N
2239	4293	2026-06-12	287.9600	7.1559	\N	72072.04	16.0911	FINNHUB	2026-06-11 23:23:20.766148+00	\N
2240	4294	2026-06-12	248.8800	6.2545	\N	71269.55	11813.2853	FINNHUB	2026-06-11 23:23:24.067903+00	\N
2241	4295	2026-06-12	316.8900	4.2710	\N	77400.42	29.7774	FINNHUB	2026-06-11 23:23:27.25956+00	\N
2242	4296	2026-06-12	90.1000	-0.3980	\N	75860.58	29.1334	FINNHUB	2026-06-11 23:23:30.456634+00	\N
2243	4297	2026-06-12	302.5500	5.9497	\N	72095.64	27.1751	FINNHUB	2026-06-11 23:23:33.895734+00	\N
2244	4298	2026-06-12	27.6600	8.7692	\N	1321162.90	15.0960	FINNHUB	2026-06-11 23:23:37.108043+00	\N
2245	4299	2026-06-12	92.2300	6.7971	\N	77836.73	41.0315	FINNHUB	2026-06-11 23:23:40.294169+00	\N
2246	4300	2026-06-12	80.8500	1.8262	\N	71592.22	28.2081	FINNHUB	2026-06-11 23:23:43.495428+00	\N
2247	4301	2026-06-12	239.1100	3.1002	\N	76506.28	33.0372	FINNHUB	2026-06-11 23:23:46.956364+00	\N
2248	4302	2026-06-12	46.6200	2.0131	\N	72973.13	28.9461	FINNHUB	2026-06-11 23:23:50.148137+00	\N
2249	4303	2026-06-12	133.9100	2.1122	\N	75604.51	66.0879	FINNHUB	2026-06-11 23:23:53.351747+00	\N
2250	4304	2026-06-12	363.5800	2.4833	\N	69953.77	149.2032	FINNHUB	2026-06-11 23:23:56.602516+00	\N
2251	4305	2026-06-12	61.8000	-0.4671	\N	102323.39	16.1674	FINNHUB	2026-06-11 23:23:59.827243+00	\N
2252	4306	2026-06-12	67.8200	0.8476	\N	74409.34	51.6373	FINNHUB	2026-06-11 23:24:03.150406+00	\N
2253	4307	2026-06-12	178.1000	-1.9921	\N	72857.91	17.6711	FINNHUB	2026-06-11 23:24:06.361635+00	\N
2254	4308	2026-06-12	136.5300	-2.6732	\N	72874.23	13.2571	FINNHUB	2026-06-11 23:24:09.613809+00	\N
2255	4309	2026-06-12	118.2700	-0.7636	\N	100998.90	21.4663	FINNHUB	2026-06-11 23:24:12.82246+00	\N
2256	4310	2026-06-12	1589.5500	7.9095	\N	74885.42	109.9771	FINNHUB	2026-06-11 23:24:16.078106+00	\N
2257	4311	2026-06-12	254.4500	1.7108	\N	73363.50	23.4089	FINNHUB	2026-06-11 23:24:19.305887+00	\N
2258	4312	2026-06-12	263.6300	2.5838	\N	73177.97	34.7523	FINNHUB	2026-06-11 23:24:22.517373+00	\N
2259	4313	2026-06-12	47.1700	-2.4204	\N	69977.60	19.6291	FINNHUB	2026-06-11 23:24:25.728842+00	\N
2260	4314	2026-06-12	181.8800	0.8204	\N	73700.05	38.0439	FINNHUB	2026-06-11 23:24:28.957896+00	\N
2261	4315	2026-06-12	69.3100	0.7706	\N	96150.00	27.9506	FINNHUB	2026-06-11 23:24:32.222541+00	\N
2262	4316	2026-06-12	89.3900	-0.6226	\N	71700.96	34.3560	FINNHUB	2026-06-11 23:24:35.447922+00	\N
2263	4317	2026-06-12	31.3600	-1.5075	\N	70182.13	21.1711	FINNHUB	2026-06-11 23:24:38.77833+00	\N
2264	4318	2026-06-12	310.5300	0.5179	\N	69716.22	26.1109	FINNHUB	2026-06-11 23:24:41.993655+00	\N
2265	4319	2026-06-12	128.4800	-0.0389	\N	69933.82	19.1400	FINNHUB	2026-06-11 23:24:45.182653+00	\N
2266	4320	2026-06-12	104.8300	4.8510	\N	66920.25	18.2294	FINNHUB	2026-06-11 23:24:48.409884+00	\N
2267	4321	2026-06-12	335.1700	-0.3449	\N	72259.48	18.3307	FINNHUB	2026-06-11 23:24:51.693496+00	\N
2268	4322	2026-06-12	1257.5900	3.7307	\N	69998.08	33.6206	FINNHUB	2026-06-11 23:24:54.884001+00	\N
2269	4323	2026-06-12	445.2200	2.4318	\N	62031.32	141.5271	FINNHUB	2026-06-11 23:24:58.091124+00	\N
2270	4324	2026-06-12	154.5900	2.3775	\N	65793.53	71.0513	FINNHUB	2026-06-11 23:25:01.661831+00	\N
2271	4325	2026-06-12	410.3500	-0.3134	\N	67384.24	32.2413	FINNHUB	2026-06-11 23:25:04.871664+00	\N
2272	4326	2026-06-12	889.5900	4.2578	\N	68268.73	155.1915	FINNHUB	2026-06-11 23:25:08.147504+00	\N
2273	4327	2026-06-12	1068.4900	1.1492	\N	66176.70	26.3968	FINNHUB	2026-06-11 23:25:11.366929+00	\N
2274	4328	2026-06-12	182.8400	1.1395	\N	63175.78	45.8497	FINNHUB	2026-06-11 23:25:14.586746+00	\N
2275	4329	2026-06-12	18.7600	-1.4706	\N	65519.68	15.0137	FINNHUB	2026-06-11 23:25:19.085412+00	\N
2276	4330	2026-06-12	39.1000	5.1358	\N	86817.17	10.1456	FINNHUB	2026-06-11 23:25:22.361403+00	\N
2277	4331	2026-06-12	26.8600	2.4018	\N	65762.20	\N	FINNHUB	2026-06-11 23:25:25.670501+00	\N
2278	4332	2026-06-12	15.3600	2.8801	\N	367651.22	23.5629	FINNHUB	2026-06-11 23:25:28.945226+00	\N
2279	4333	2026-06-12	46.8000	2.8798	\N	61568.84	39.5687	FINNHUB	2026-06-11 23:25:32.2415+00	\N
2280	4334	2026-06-12	1843.4200	7.2080	\N	63437.24	51.8428	FINNHUB	2026-06-11 23:25:35.489076+00	\N
2281	4335	2026-06-12	39.7900	1.3758	\N	91405.13	14.2420	FINNHUB	2026-06-11 23:25:38.777953+00	\N
2282	4336	2026-06-12	611.4800	1.6338	\N	63499.95	14.3555	FINNHUB	2026-06-11 23:25:42.03459+00	\N
2283	4337	2026-06-12	208.0500	-2.1356	\N	65581.68	30.2359	FINNHUB	2026-06-11 23:25:45.307699+00	\N
2284	4338	2026-06-12	303.9000	0.1780	\N	64933.18	8.5393	FINNHUB	2026-06-11 23:25:48.500512+00	\N
2285	4339	2026-06-12	78.1200	10.4326	\N	54726.50	211.0606	FINNHUB	2026-06-11 23:25:51.706159+00	\N
2286	4340	2026-06-12	114.7800	9.2623	\N	60810.03	\N	FINNHUB	2026-06-11 23:25:55.023695+00	\N
2287	4341	2026-06-12	45.9600	4.5496	\N	65973.52	29.3216	FINNHUB	2026-06-11 23:25:58.242202+00	\N
2288	4342	2026-06-12	16.2300	4.3059	\N	46663.01	7.7850	FINNHUB	2026-06-11 23:26:01.494545+00	\N
2289	4343	2026-06-12	278.1200	0.5823	\N	62620.04	29.7158	FINNHUB	2026-06-11 23:26:04.73269+00	\N
2290	4344	2026-06-12	63.4800	0.7299	\N	62976.52	20.2107	FINNHUB	2026-06-11 23:26:07.968649+00	\N
2291	4345	2026-06-12	207.7400	2.8416	\N	59465.02	20.4628	FINNHUB	2026-06-11 23:26:11.178942+00	\N
2292	4346	2026-06-12	33.1100	-2.5603	\N	44820.51	21.7048	FINNHUB	2026-06-11 23:26:14.411635+00	\N
2293	4347	2026-06-12	117.5800	3.1494	\N	60543.97	24.4523	FINNHUB	2026-06-11 23:26:17.606269+00	\N
2294	4348	2026-06-12	1313.9600	-0.2785	\N	62606.48	35.1327	FINNHUB	2026-06-11 23:26:20.796438+00	\N
2295	4349	2026-06-12	50.6800	1.8489	\N	63141.16	11.4241	FINNHUB	2026-06-11 23:26:24.096869+00	\N
2296	4350	2026-06-12	365.6200	5.4998	\N	60173.38	37.6522	FINNHUB	2026-06-11 23:26:27.314179+00	\N
2297	4351	2026-06-12	116.4500	-0.5636	\N	59866.81	12.9135	FINNHUB	2026-06-11 23:26:30.536823+00	\N
2298	4352	2026-06-12	91.5400	0.5603	\N	60087.19	30.7037	FINNHUB	2026-06-11 23:26:33.777387+00	\N
2299	4353	2026-06-12	32.2100	3.9368	\N	50756.50	7.1680	FINNHUB	2026-06-11 23:26:37.09502+00	\N
2300	4354	2026-06-12	14.7100	2.8671	\N	56522.87	\N	FINNHUB	2026-06-11 23:26:40.304916+00	\N
2301	4355	2026-06-12	120.9700	0.5904	\N	80977.60	27.7321	FINNHUB	2026-06-11 23:26:43.594383+00	\N
2302	4356	2026-06-12	66.6900	-0.1198	\N	59116.43	20.0123	FINNHUB	2026-06-11 23:26:50.791523+00	\N
2303	4357	2026-06-12	222.2400	4.9837	\N	53271.88	65.1883	FINNHUB	2026-06-11 23:26:54.085381+00	\N
2304	4358	2026-06-12	12.0900	4.0448	\N	56480.16	17.7402	FINNHUB	2026-06-11 23:26:57.266673+00	\N
2305	4359	2026-06-12	260.9000	4.1559	\N	58695.68	25.1805	FINNHUB	2026-06-11 23:27:00.456848+00	\N
2306	4360	2026-06-12	312.1700	3.0264	\N	58155.70	33.5772	FINNHUB	2026-06-11 23:27:03.679828+00	\N
2307	4361	2026-06-12	56.4900	0.1773	\N	57220.84	12.1798	FINNHUB	2026-06-11 23:27:06.871812+00	\N
2308	4362	2026-06-12	61.9100	-0.3220	\N	58220.17	51.9572	FINNHUB	2026-06-11 23:27:10.085915+00	\N
2309	4363	2026-06-12	219.5700	-1.6880	\N	57080.52	4.7003	FINNHUB	2026-06-11 23:27:13.431749+00	\N
2310	4364	2026-06-12	269.3700	-1.1631	\N	58499.05	27.4373	FINNHUB	2026-06-11 23:27:16.648301+00	\N
2311	4365	2026-06-12	55.4700	-2.8546	\N	55878.58	11.8012	FINNHUB	2026-06-11 23:27:19.844846+00	\N
2312	4366	2026-06-12	340.0300	4.9475	\N	55370.10	52.5333	FINNHUB	2026-06-11 23:27:23.195557+00	\N
2313	4367	2026-06-12	381.4000	9.7270	\N	59119.71	69.2221	FINNHUB	2026-06-11 23:27:26.402343+00	\N
2314	4368	2026-06-12	69.7400	2.6041	\N	57924.68	44.2173	FINNHUB	2026-06-11 23:27:29.574524+00	\N
2315	4369	2026-06-12	132.6400	3.6412	\N	60094.03	17.4186	FINNHUB	2026-06-11 23:27:32.821149+00	\N
2316	4370	2026-06-12	151.9900	8.9612	\N	55238.80	62.7714	FINNHUB	2026-06-11 23:27:36.027336+00	\N
2317	4371	2026-06-12	89.2000	-1.5126	\N	57805.52	16.3709	FINNHUB	2026-06-11 23:27:39.272872+00	\N
2318	4372	2026-06-12	220.9000	0.3452	\N	56975.28	35.3532	FINNHUB	2026-06-11 23:27:42.649854+00	\N
2319	4373	2026-06-12	898.9400	4.2636	\N	47217.04	24.2243	FINNHUB	2026-06-11 23:27:45.847337+00	\N
2320	4374	2026-06-12	95.7400	0.1360	\N	52161.98	\N	FINNHUB	2026-06-11 23:27:49.024907+00	\N
2321	4375	2026-06-12	324.7100	0.2594	\N	57447.34	30.1905	FINNHUB	2026-06-11 23:27:52.346913+00	\N
2322	4376	2026-06-12	87.5800	1.6835	\N	55956.48	15.4619	FINNHUB	2026-06-11 23:27:55.561615+00	\N
2323	4377	2026-06-12	367.4700	11.0651	\N	56712.04	211.9086	FINNHUB	2026-06-11 23:27:58.762048+00	\N
2324	4378	2026-06-12	191.5900	-2.5235	\N	55292.13	194.6906	FINNHUB	2026-06-11 23:28:02.065603+00	\N
2325	4379	2026-06-12	46.3900	0.7821	\N	53079.40	40.8429	FINNHUB	2026-06-11 23:28:05.255888+00	\N
2326	4380	2026-06-12	281.4800	0.0853	\N	54765.05	21.4876	FINNHUB	2026-06-11 23:28:08.467953+00	\N
2327	4381	2026-06-12	85.6900	3.9423	\N	50493.23	31.4985	FINNHUB	2026-06-11 23:28:11.667504+00	\N
2328	4382	2026-06-12	28.4800	0.3877	\N	72042.34	15.5230	FINNHUB	2026-06-11 23:28:14.886607+00	\N
2329	4383	2026-06-12	112.6600	4.7805	\N	68114.22	27.0714	FINNHUB	2026-06-11 23:28:18.111441+00	\N
2330	4384	2026-06-12	20.6800	9.4180	\N	1490372.80	29.7414	FINNHUB	2026-06-11 23:28:21.668257+00	\N
2331	4385	2026-06-12	69.0900	8.2746	\N	41430.37	16.3501	FINNHUB	2026-06-11 23:28:24.914571+00	\N
2332	4386	2026-06-12	226.2100	1.9975	\N	51848.01	33.9377	FINNHUB	2026-06-11 23:28:28.170379+00	\N
2333	4387	2026-06-12	81.8300	7.0093	\N	50792.23	11.3451	FINNHUB	2026-06-11 23:28:31.420574+00	\N
2334	4388	2026-06-12	74.8600	0.5372	\N	50067.86	43.0877	FINNHUB	2026-06-11 23:28:34.611684+00	\N
2335	4389	2026-06-12	44.6100	-4.2704	\N	53558.27	23.6148	FINNHUB	2026-06-11 23:28:38.000998+00	\N
2336	4390	2026-06-12	3081.6200	-0.9141	\N	51008.04	20.5833	FINNHUB	2026-06-11 23:28:41.45219+00	\N
2337	4391	2026-06-12	203.0500	-0.0738	\N	50912.58	57.3986	FINNHUB	2026-06-11 23:28:45.088843+00	\N
2338	4392	2026-06-12	11.6000	-1.3605	\N	4645761.50	15.7804	FINNHUB	2026-06-11 23:28:48.328497+00	\N
2339	4393	2026-06-12	109.8900	-0.5340	\N	51184.88	28.4090	FINNHUB	2026-06-11 23:28:51.546104+00	\N
2340	4394	2026-06-12	247.7600	5.0053	\N	50692.27	50.3248	FINNHUB	2026-06-11 23:28:54.83799+00	\N
2341	4395	2026-06-12	146.3800	5.6590	\N	46713.26	20.8448	FINNHUB	2026-06-11 23:28:58.023545+00	\N
2342	4396	2026-06-12	240.1400	-0.6906	\N	50493.62	34.2330	FINNHUB	2026-06-11 23:29:01.23957+00	\N
2343	4397	2026-06-12	457.5900	3.9812	\N	49911.38	45.8744	FINNHUB	2026-06-11 23:29:04.468963+00	\N
2344	4398	2026-06-12	85.7600	-0.2559	\N	49982.32	45.5960	FINNHUB	2026-06-11 23:29:07.758811+00	\N
2345	4399	2026-06-12	86.7400	0.0231	\N	49315.16	25.7924	FINNHUB	2026-06-11 23:29:10.979745+00	\N
2346	4400	2026-06-12	78.2700	0.2177	\N	48755.45	23.3168	FINNHUB	2026-06-11 23:29:14.233706+00	\N
2347	4401	2026-06-12	3.2200	3.5370	\N	256562.48	16.4698	FINNHUB	2026-06-11 23:29:17.444271+00	\N
2348	4402	2026-06-12	67.3500	4.7434	\N	40264.14	45.3425	FINNHUB	2026-06-11 23:29:20.81901+00	\N
2349	4403	2026-06-12	15.8700	1.2117	\N	8037236.50	41.9126	FINNHUB	2026-06-11 23:29:24.147877+00	\N
2350	4404	2026-06-12	205.5700	-7.0996	\N	45958.97	31.4142	FINNHUB	2026-06-11 23:29:27.554961+00	\N
2351	4405	2026-06-12	109.6100	3.0072	\N	48311.64	23.6822	FINNHUB	2026-06-11 23:29:30.750502+00	\N
2352	4406	2026-06-12	221.1600	2.2469	\N	51986.68	33.4319	FINNHUB	2026-06-11 23:29:33.998896+00	\N
2353	4407	2026-06-12	92.9400	5.7218	\N	48597.41	211.2931	FINNHUB	2026-06-11 23:29:37.347103+00	\N
2354	4408	2026-06-12	53.4200	1.4625	\N	48079.83	22.1260	FINNHUB	2026-06-11 23:29:40.558716+00	\N
2355	4409	2026-06-12	45.5100	-0.2193	\N	46566.20	16.7565	FINNHUB	2026-06-11 23:29:43.781521+00	\N
2356	4410	2026-06-12	339.2200	5.7155	\N	38660.65	48.9607	FINNHUB	2026-06-11 23:29:47.034535+00	\N
2357	4411	2026-06-12	115.9600	5.2555	\N	45206.03	78.7973	FINNHUB	2026-06-11 23:29:50.25936+00	\N
2358	4412	2026-06-12	238.5800	2.9605	\N	45569.99	26.2470	FINNHUB	2026-06-11 23:29:53.456651+00	\N
2359	4413	2026-06-12	98.9700	4.1461	\N	42190.86	90.6641	FINNHUB	2026-06-11 23:29:56.783123+00	\N
2360	4414	2026-06-12	594.3100	-2.3352	\N	43989.77	33.3330	FINNHUB	2026-06-11 23:30:00.001242+00	\N
2361	4415	2026-06-12	164.8500	1.8850	\N	45274.93	14.7716	FINNHUB	2026-06-11 23:30:03.20166+00	\N
2362	4416	2026-06-12	228.0300	1.5452	\N	44194.56	17.8925	FINNHUB	2026-06-11 23:30:06.454142+00	\N
2363	4417	2026-06-12	81.1200	1.6796	\N	33509.65	18.5456	FINNHUB	2026-06-11 23:30:11.779415+00	\N
2364	4418	2026-06-12	557.9100	0.1742	\N	43670.42	39.8732	FINNHUB	2026-06-11 23:30:15.049492+00	\N
2365	4419	2026-06-12	262.0900	2.1714	\N	43525.63	35.9716	FINNHUB	2026-06-11 23:30:18.273993+00	\N
2366	4420	2026-06-12	37.1300	1.6147	\N	48002.16	49.6917	FINNHUB	2026-06-11 23:30:21.532227+00	\N
2367	4421	2026-06-12	226.5500	-4.5422	\N	49810.92	\N	FINNHUB	2026-06-11 23:30:24.847929+00	\N
2368	4422	2026-06-12	385.8600	6.3210	\N	58301.71	43.5048	FINNHUB	2026-06-11 23:30:28.223952+00	\N
2369	4423	2026-06-12	12.1400	4.6552	\N	372413.60	14.7977	FINNHUB	2026-06-11 23:30:31.627261+00	\N
2370	4424	2026-06-12	83.1800	6.0023	\N	39627.94	11.4070	FINNHUB	2026-06-11 23:30:34.83456+00	\N
2371	4425	2026-06-12	120.1500	4.1612	\N	40830.65	\N	FINNHUB	2026-06-11 23:30:38.156519+00	\N
2372	4426	2026-06-12	207.9100	-0.2638	\N	56111.32	29.2777	FINNHUB	2026-06-11 23:30:41.43659+00	\N
2373	4427	2026-06-12	368.6900	1.1606	\N	44574.03	39.4460	FINNHUB	2026-06-11 23:30:44.734083+00	\N
2374	4428	2026-06-12	38.7100	1.4679	\N	6428570.00	14.3731	FINNHUB	2026-06-11 23:30:47.982203+00	\N
2375	4429	2026-06-12	147.3500	-0.2977	\N	40325.34	35.4353	FINNHUB	2026-06-11 23:30:51.203072+00	\N
2376	4430	2026-06-12	153.2700	1.4496	\N	41640.85	23.9591	FINNHUB	2026-06-11 23:30:54.447307+00	\N
2377	4431	2026-06-12	21.7300	-1.3618	\N	58287.73	15.0018	FINNHUB	2026-06-11 23:30:57.683565+00	\N
2378	4432	2026-06-12	31.2300	-1.4827	\N	42490.27	23.1934	FINNHUB	2026-06-11 23:31:00.912255+00	\N
2379	4433	2026-06-12	97.6900	0.1846	\N	43519.54	19.4336	FINNHUB	2026-06-11 23:31:04.247675+00	\N
2380	4434	2026-06-12	132.8200	3.5149	\N	29405.44	47.2163	FINNHUB	2026-06-11 23:31:07.458268+00	\N
2381	4435	2026-06-12	80.7400	7.9123	\N	41032.52	52.6733	FINNHUB	2026-06-11 23:31:10.652638+00	\N
2382	4436	2026-06-12	116.1100	-1.1662	\N	41150.69	713.3593	FINNHUB	2026-06-11 23:31:13.884274+00	\N
2383	4437	2026-06-12	154.4300	5.2621	\N	43793.20	13.8036	FINNHUB	2026-06-11 23:31:17.215689+00	\N
2384	4438	2026-06-12	92.0400	-1.4350	\N	40240.87	37.9989	FINNHUB	2026-06-11 23:31:20.415076+00	\N
2385	4439	2026-06-12	69.0900	3.6920	\N	39656.91	49.1361	FINNHUB	2026-06-11 23:31:23.630427+00	\N
2386	4440	2026-06-12	75.8400	1.2280	\N	57885.16	17.6479	FINNHUB	2026-06-11 23:31:26.850406+00	\N
2387	4441	2026-06-12	450.3800	-0.0533	\N	40487.85	10.3948	FINNHUB	2026-06-11 23:31:30.100808+00	\N
2388	4442	2026-06-12	289.3900	-0.6284	\N	38538.41	66.7659	FINNHUB	2026-06-11 23:31:33.30404+00	\N
2389	4443	2026-06-12	83.8900	-0.5453	\N	41008.41	157.4673	FINNHUB	2026-06-11 23:31:36.829011+00	\N
2390	4444	2026-06-12	160.4300	4.1956	\N	40565.09	50.6682	FINNHUB	2026-06-11 23:31:40.076587+00	\N
2391	4445	2026-06-12	93.1800	5.3119	\N	40292.44	33.6145	FINNHUB	2026-06-11 23:31:43.30978+00	\N
2392	4446	2026-06-12	75.3200	0.5071	\N	39988.16	12.6505	FINNHUB	2026-06-11 23:31:46.500936+00	\N
2393	4447	2026-06-12	9.0300	-0.5507	\N	29622.60	17.7700	FINNHUB	2026-06-11 23:31:49.719307+00	\N
2394	4448	2026-06-12	34.5600	2.9184	\N	117861.45	25.3675	FINNHUB	2026-06-11 23:31:52.95292+00	\N
2395	4449	2026-06-12	212.0800	0.7697	\N	38377.48	\N	FINNHUB	2026-06-11 23:31:56.162546+00	\N
2396	4450	2026-06-12	78.7800	0.2418	\N	39521.87	17.4644	FINNHUB	2026-06-11 23:31:59.663981+00	\N
2397	4451	2026-06-12	155.4700	-2.2386	\N	56324.65	38.2111	FINNHUB	2026-06-11 23:32:02.91429+00	\N
2398	4452	2026-06-12	446.2000	-0.3106	\N	36076.69	175.1398	FINNHUB	2026-06-11 23:32:06.10953+00	\N
2399	4453	2026-06-12	106.8400	-0.7063	\N	39777.25	18.4581	FINNHUB	2026-06-11 23:32:09.360171+00	\N
2400	4454	2026-06-12	103.3300	2.5506	\N	51956148.00	8.6187	FINNHUB	2026-06-11 23:32:12.618058+00	\N
2401	4455	2026-06-12	28.0600	-1.3708	\N	272236.20	17.0095	FINNHUB	2026-06-11 23:32:15.992919+00	\N
2402	4456	2026-06-12	78.9000	-2.9282	\N	38358.92	35.4847	FINNHUB	2026-06-11 23:32:19.208627+00	\N
2403	4457	2026-06-12	64.1200	-0.5275	\N	39509.21	38.8870	FINNHUB	2026-06-11 23:32:22.574632+00	\N
2404	4458	2026-06-12	213.7000	3.5218	\N	39454.20	172.4992	FINNHUB	2026-06-11 23:32:25.818791+00	\N
2405	4459	2026-06-12	251.0500	5.7275	\N	38660.65	48.9607	FINNHUB	2026-06-11 23:32:29.125105+00	\N
2406	4460	2026-06-12	279.5500	4.1775	\N	39708.27	28.9444	FINNHUB	2026-06-11 23:32:32.434638+00	\N
2407	4461	2026-06-12	913.2000	11.5059	\N	114866.48	65.8469	FINNHUB	2026-06-11 23:32:35.664914+00	\N
2408	4462	2026-06-12	131.9100	-1.6038	\N	38625.44	29.4401	FINNHUB	2026-06-11 23:32:38.961753+00	\N
2409	4463	2026-06-12	129.5500	-1.5727	\N	36439.37	25.7704	FINNHUB	2026-06-11 23:32:42.197877+00	\N
2410	4464	2026-06-12	264.7600	11.3935	\N	43840.06	92.8266	FINNHUB	2026-06-11 23:32:45.398052+00	\N
2411	4465	2026-06-12	28.1200	8.1955	\N	36138.14	11.6688	FINNHUB	2026-06-11 23:32:48.601566+00	\N
2412	4466	2026-06-12	128.3600	3.8091	\N	646375.44	22.7096	FINNHUB	2026-06-11 23:32:51.811278+00	\N
2413	4467	2026-06-12	16.7900	0.4187	\N	37074.45	12.5506	FINNHUB	2026-06-11 23:32:55.079533+00	\N
2414	4468	2026-06-12	80.2500	-2.0864	\N	49988.07	23.4164	FINNHUB	2026-06-11 23:32:58.29789+00	\N
2415	4469	2026-06-12	31.2500	2.7285	\N	39097.86	26.9272	FINNHUB	2026-06-11 23:33:01.546115+00	\N
2416	4470	2026-06-12	88.8300	3.9920	\N	150675.22	145.1592	FINNHUB	2026-06-11 23:33:04.880034+00	\N
2417	4471	2026-06-12	180.8400	2.3951	\N	35917.52	32.8265	FINNHUB	2026-06-11 23:33:08.115225+00	\N
2418	4472	2026-06-12	376.8900	6.9616	\N	39516.01	48.8455	FINNHUB	2026-06-11 23:33:11.327573+00	\N
2419	4473	2026-06-12	172.3300	2.8836	\N	39598.41	473.2972	FINNHUB	2026-06-11 23:33:14.540128+00	\N
2420	4474	2026-06-12	125.1700	1.4673	\N	37046.29	136.0475	FINNHUB	2026-06-11 23:33:17.743093+00	\N
2421	4475	2026-06-12	113.0700	-0.8245	\N	37135.99	22.6591	FINNHUB	2026-06-11 23:33:20.959292+00	\N
2422	4476	2026-06-12	280.1900	2.7579	\N	35380.27	31.7796	FINNHUB	2026-06-11 23:33:24.25855+00	\N
2423	4477	2026-06-12	79.6400	1.4006	\N	37840.98	21.7978	FINNHUB	2026-06-11 23:33:27.476275+00	\N
2424	4478	2026-06-12	41.2400	1.3268	\N	36144.27	7.1445	FINNHUB	2026-06-11 23:33:30.709439+00	\N
2425	4479	2026-06-12	106.5100	1.2741	\N	36618.91	10.5652	FINNHUB	2026-06-11 23:33:33.963314+00	\N
2426	4480	2026-06-12	97.5600	11.7270	\N	33891.04	\N	FINNHUB	2026-06-11 23:33:37.181558+00	\N
2427	4481	2026-06-12	811.5300	4.4817	\N	35863.75	26.8115	FINNHUB	2026-06-11 23:33:40.407394+00	\N
2428	4482	2026-06-12	128.4000	-0.6653	\N	35543.80	8.7503	FINNHUB	2026-06-11 23:33:43.779697+00	\N
2429	4483	2026-06-12	99.2700	-1.8101	\N	35893.58	21.9305	FINNHUB	2026-06-11 23:33:47.024285+00	\N
2430	4484	2026-06-12	359.7400	-0.9472	\N	35659.14	79.3752	FINNHUB	2026-06-11 23:33:50.282248+00	\N
2431	4485	2026-06-12	13.4300	7.0973	\N	35481.05	148.2188	FINNHUB	2026-06-11 23:33:53.593106+00	\N
2432	4486	2026-06-12	130.5300	-5.0484	\N	33955.09	40.0887	FINNHUB	2026-06-11 23:33:56.793723+00	\N
2433	4487	2026-06-12	27.0700	3.6768	\N	5595543.00	\N	FINNHUB	2026-06-11 23:34:00.013572+00	\N
2434	4488	2026-06-12	59.3900	6.5291	\N	26154.75	12.0324	FINNHUB	2026-06-11 23:34:03.285011+00	\N
2435	4489	2026-06-12	46.0000	0.8993	\N	1117072.20	28.6260	FINNHUB	2026-06-11 23:34:06.596993+00	\N
2436	4490	2026-06-12	565.5400	2.2917	\N	33098.20	13.0616	FINNHUB	2026-06-11 23:34:09.829529+00	\N
2437	4491	2026-06-12	581.7700	4.3440	\N	34575.01	36.6997	FINNHUB	2026-06-11 23:34:13.036287+00	\N
2438	4492	2026-06-12	112.6100	9.5641	\N	33110.06	9.0366	FINNHUB	2026-06-11 23:34:16.264329+00	\N
2439	4493	2026-06-12	206.6200	-0.2270	\N	30385.89	292.2957	FINNHUB	2026-06-11 23:34:19.456052+00	\N
2440	4494	2026-06-12	18.0700	0.1108	\N	34656.16	21.3663	FINNHUB	2026-06-11 23:34:23.043132+00	\N
2441	4495	2026-06-12	15.2600	1.3953	\N	26695.48	\N	FINNHUB	2026-06-11 23:34:26.26982+00	\N
2442	4496	2026-06-12	128.1300	11.1854	\N	34032.80	\N	FINNHUB	2026-06-11 23:34:29.463567+00	\N
2443	4497	2026-06-12	51.2000	-2.6801	\N	31980.69	9.7373	FINNHUB	2026-06-11 23:34:32.678586+00	\N
2444	4498	2026-06-12	332.7100	-0.4160	\N	33787.13	19.7113	FINNHUB	2026-06-11 23:34:35.944426+00	\N
2445	4499	2026-06-12	3.4400	4.2424	\N	170678.16	7.1782	FINNHUB	2026-06-11 23:34:39.233155+00	\N
2446	4500	2026-06-12	17.2100	2.1972	\N	34886.92	15.8074	FINNHUB	2026-06-11 23:34:42.431643+00	\N
2447	4501	2026-06-12	173.2600	0.6097	\N	33151.98	46.8550	FINNHUB	2026-06-11 23:34:45.659232+00	\N
2448	4502	2026-06-12	81.4000	0.1353	\N	34079.05	12.8941	FINNHUB	2026-06-11 23:34:48.916533+00	\N
2449	4503	2026-06-12	50.6100	-0.3936	\N	33549.33	18.2135	FINNHUB	2026-06-11 23:34:52.125413+00	\N
2450	4504	2026-06-12	73.9000	0.9563	\N	33404.13	34.9781	FINNHUB	2026-06-11 23:34:55.462206+00	\N
2451	4505	2026-06-12	35.9000	7.0683	\N	499298.22	8.4844	FINNHUB	2026-06-11 23:34:58.750386+00	\N
2452	4506	2026-06-12	101.5400	-0.0394	\N	33916.00	16.0057	FINNHUB	2026-06-11 23:35:01.956934+00	\N
2453	4507	2026-06-12	65.5800	2.0383	\N	45477436.00	8.9070	FINNHUB	2026-06-11 23:35:05.251188+00	\N
2454	4508	2026-06-12	39.7600	0.0755	\N	33470.21	21.7339	FINNHUB	2026-06-11 23:35:08.502863+00	\N
2455	4509	2026-06-12	160.4700	-0.1183	\N	31027.84	24.3165	FINNHUB	2026-06-11 23:35:11.731639+00	\N
2456	4510	2026-06-12	66.5100	0.6051	\N	26833.89	41.0219	FINNHUB	2026-06-11 23:35:14.960827+00	\N
2457	4511	2026-06-12	227.8200	1.7372	\N	33374.10	11.3866	FINNHUB	2026-06-11 23:35:18.158822+00	\N
2458	4512	2026-06-12	81.4400	1.8000	\N	33063.98	\N	FINNHUB	2026-06-11 23:35:21.426935+00	\N
2459	4513	2026-06-12	65.5600	0.8150	\N	43678.01	13.0889	FINNHUB	2026-06-11 23:35:24.723542+00	\N
2460	4514	2026-06-12	55.2900	1.4123	\N	31840.53	38.4878	FINNHUB	2026-06-11 23:35:27.923286+00	\N
2461	4515	2026-06-12	150.2600	0.4412	\N	31995.47	33.8899	FINNHUB	2026-06-11 23:35:31.158003+00	\N
2462	4516	2026-06-12	26.0400	4.1184	\N	23159.12	7.7780	FINNHUB	2026-06-11 23:35:37.497542+00	\N
2463	4517	2026-06-12	12.7500	-4.0632	\N	30979.94	11.0920	FINNHUB	2026-06-11 23:35:40.675412+00	\N
2464	4518	2026-06-12	91.1300	-0.1971	\N	31839.87	6.5353	FINNHUB	2026-06-11 23:35:43.883438+00	\N
2465	4519	2026-06-12	149.2300	3.4954	\N	31725.77	\N	FINNHUB	2026-06-11 23:35:47.075923+00	\N
2466	4520	2026-06-12	61.9800	0.8297	\N	28600.82	16.7705	FINNHUB	2026-06-11 23:35:50.432206+00	\N
2467	4521	2026-06-12	170.7500	2.7810	\N	31174.91	16.6675	FINNHUB	2026-06-11 23:35:53.63395+00	\N
2468	4522	2026-06-12	24.8600	5.0719	\N	39393.36	9.8350	FINNHUB	2026-06-11 23:35:57.554881+00	\N
2469	4523	2026-06-12	65.6900	-0.6804	\N	31603.90	12.4818	FINNHUB	2026-06-11 23:36:00.762164+00	\N
2470	4524	2026-06-12	16.2600	0.3085	\N	118621660.00	13.1388	FINNHUB	2026-06-11 23:36:04.147781+00	\N
2471	4525	2026-06-12	219.2300	1.2610	\N	31611.22	\N	FINNHUB	2026-06-11 23:36:07.346551+00	\N
2472	4526	2026-06-12	63.5400	-2.7548	\N	31356.11	\N	FINNHUB	2026-06-11 23:36:10.526844+00	\N
2473	4527	2026-06-12	181.0600	-0.6093	\N	30058.69	21.7030	FINNHUB	2026-06-11 23:36:13.779611+00	\N
2474	4528	2026-06-12	28.0900	-1.1264	\N	31047.64	10.0016	FINNHUB	2026-06-11 23:36:17.034766+00	\N
2475	4529	2026-06-12	145.7900	-0.1917	\N	30765.31	24.3396	FINNHUB	2026-06-11 23:36:20.374897+00	\N
2476	4530	2026-06-12	108.2500	-0.4781	\N	30188.07	19.8084	FINNHUB	2026-06-11 23:36:23.593645+00	\N
2477	4531	2026-06-12	88.0200	3.0800	\N	31063.71	\N	FINNHUB	2026-06-11 23:36:26.851789+00	\N
2478	4532	2026-06-12	63.6000	6.1592	\N	29551.99	32.7754	FINNHUB	2026-06-11 23:36:30.065769+00	\N
2479	4533	2026-06-12	47.3900	-1.2091	\N	248801.55	6.4634	FINNHUB	2026-06-11 23:36:33.31668+00	\N
2480	4534	2026-06-12	260.2700	-1.2670	\N	209632.48	66.2766	FINNHUB	2026-06-11 23:36:36.649903+00	\N
2481	4535	2026-06-12	271.1700	8.7857	\N	27200.21	16.3334	FINNHUB	2026-06-11 23:36:39.884104+00	\N
2482	4536	2026-06-12	43.4900	4.7952	\N	29713.12	\N	FINNHUB	2026-06-11 23:36:43.078736+00	\N
2483	4537	2026-06-12	92.3200	-1.7454	\N	27552.10	13.3023	FINNHUB	2026-06-11 23:36:46.306344+00	\N
2484	4538	2026-06-12	52.3300	3.6032	\N	27918.69	24.1511	FINNHUB	2026-06-11 23:36:49.496199+00	\N
2485	4539	2026-06-12	149.1200	6.7125	\N	29253.06	63.3183	FINNHUB	2026-06-11 23:36:52.700536+00	\N
2486	4540	2026-06-12	150.4200	-0.1129	\N	29164.24	13.5837	FINNHUB	2026-06-11 23:36:55.917538+00	\N
2487	4541	2026-06-12	295.9000	-1.7205	\N	31062.29	25.1496	FINNHUB	2026-06-11 23:36:59.160201+00	\N
2488	4542	2026-06-12	64.5100	1.1763	\N	29003.90	15.1853	FINNHUB	2026-06-11 23:37:02.339726+00	\N
2489	4543	2026-06-12	53.0600	-0.4129	\N	27857.19	8.7054	FINNHUB	2026-06-11 23:37:05.561913+00	\N
2490	4544	2026-06-12	218.5300	2.2315	\N	29544.71	26.8206	FINNHUB	2026-06-11 23:37:08.750443+00	\N
2491	4545	2026-06-12	199.9600	2.9448	\N	29569.50	21.5537	FINNHUB	2026-06-11 23:37:11.972209+00	\N
2492	4546	2026-06-12	31.0600	-0.9566	\N	28913.09	18.6152	FINNHUB	2026-06-11 23:37:15.207642+00	\N
2493	4547	2026-06-12	56.4200	-0.1062	\N	39967.90	22.1797	FINNHUB	2026-06-11 23:37:18.449943+00	\N
2494	4548	2026-06-12	48.6600	-0.3686	\N	39671.31	23.4741	FINNHUB	2026-06-11 23:37:21.724857+00	\N
2495	4549	2026-06-12	168.2300	-0.6144	\N	28179.41	20.9328	FINNHUB	2026-06-11 23:37:24.993454+00	\N
2496	4550	2026-06-12	358.5000	6.8300	\N	26920.83	59.8269	FINNHUB	2026-06-11 23:37:28.188529+00	\N
2497	4551	2026-06-12	192.3900	-0.6096	\N	28186.64	18.5491	FINNHUB	2026-06-11 23:37:31.401877+00	\N
2498	4552	2026-06-12	145.3900	3.1720	\N	29294.47	44.1980	FINNHUB	2026-06-11 23:37:34.599544+00	\N
2499	4553	2026-06-12	73.2000	3.8593	\N	28645.86	48.8004	FINNHUB	2026-06-11 23:37:37.798713+00	\N
2500	4554	2026-06-12	72.3400	1.1748	\N	27859.08	7.3721	FINNHUB	2026-06-11 23:37:41.02345+00	\N
2501	4555	2026-06-12	354.4100	1.7601	\N	28516.34	\N	FINNHUB	2026-06-11 23:37:44.20904+00	\N
2502	4556	2026-06-12	916.2800	0.0743	\N	33519.44	46.9166	FINNHUB	2026-06-11 23:37:47.423125+00	\N
2503	4557	2026-06-12	75.2500	0.6420	\N	28786.12	30.9395	FINNHUB	2026-06-11 23:37:50.642811+00	\N
2504	4558	2026-06-12	10.2900	5.6468	\N	118592.19	12.4284	FINNHUB	2026-06-11 23:37:53.949825+00	\N
2505	4559	2026-06-12	68.3000	0.4412	\N	27153.62	15.8700	FINNHUB	2026-06-11 23:37:57.158824+00	\N
2506	4560	2026-06-12	161.5500	-1.3495	\N	26725.42	28.3814	FINNHUB	2026-06-11 23:38:00.387939+00	\N
2507	4561	2026-06-12	42.5500	-0.4445	\N	28005.00	26.1485	FINNHUB	2026-06-11 23:38:03.589568+00	\N
2508	4562	2026-06-12	623.7300	3.7216	\N	29067.36	31.1547	FINNHUB	2026-06-11 23:38:06.79107+00	\N
2509	4563	2026-06-12	224.6600	2.6126	\N	26770.82	17.9911	FINNHUB	2026-06-11 23:38:10.139864+00	\N
2510	4564	2026-06-12	123.7000	2.5280	\N	25763.56	107.7973	FINNHUB	2026-06-11 23:38:13.352952+00	\N
2511	4565	2026-06-12	17.2500	14.0873	\N	27141.37	\N	FINNHUB	2026-06-11 23:38:16.54841+00	\N
2512	4566	2026-06-12	757.2300	5.3142	\N	27239.68	53.2986	FINNHUB	2026-06-11 23:38:19.878301+00	\N
2513	4567	2026-06-12	184.3600	-1.1951	\N	26155.53	22.9347	FINNHUB	2026-06-11 23:38:23.217929+00	\N
2514	4568	2026-06-12	838.5500	8.8673	\N	25475.94	73.4929	FINNHUB	2026-06-11 23:38:26.479083+00	\N
2515	4569	2026-06-12	66.5100	2.3861	\N	27470.41	13.9091	FINNHUB	2026-06-11 23:38:29.681828+00	\N
2516	4570	2026-06-12	70.1300	0.6747	\N	26910.01	18.1702	FINNHUB	2026-06-11 23:38:32.888252+00	\N
2517	4571	2026-06-12	35.4600	-0.3373	\N	26892.77	22.0613	FINNHUB	2026-06-11 23:38:36.086147+00	\N
2518	4572	2026-06-12	369.5500	-1.5006	\N	25822.99	51.2741	FINNHUB	2026-06-11 23:38:39.33127+00	\N
2519	4573	2026-06-12	279.5700	-2.9574	\N	26216.19	31.1763	FINNHUB	2026-06-11 23:38:42.735309+00	\N
2520	4574	2026-06-12	289.1400	2.9884	\N	26759.29	43.0148	FINNHUB	2026-06-11 23:38:46.077725+00	\N
2521	4575	2026-06-12	46.6700	0.5169	\N	27070.58	25.4184	FINNHUB	2026-06-11 23:38:49.300949+00	\N
2523	4077	2026-06-13	291.1300	-1.5222	\N	4267558.50	34.8159	FINNHUB	2026-06-12 23:04:01.823533+00	\N
2524	4078	2026-06-13	359.6800	0.5339	\N	4357883.00	27.2014	FINNHUB	2026-06-12 23:04:04.96365+00	\N
2525	4079	2026-06-13	390.7400	0.1025	\N	2875287.00	22.9626	FINNHUB	2026-06-12 23:04:08.117513+00	\N
2526	4080	2026-06-13	238.5500	-1.2256	\N	2539753.50	27.9715	FINNHUB	2026-06-12 23:04:11.264869+00	\N
2527	4081	2026-06-13	423.9300	0.6792	\N	58347830.00	30.2509	FINNHUB	2026-06-12 23:04:14.442003+00	\N
2528	4082	2026-06-13	382.0700	-0.9077	\N	1817728.60	62.0025	FINNHUB	2026-06-12 23:04:17.579788+00	\N
2529	4083	2026-06-13	566.9800	-0.2551	\N	1440961.20	20.4140	FINNHUB	2026-06-12 23:04:20.705284+00	\N
2530	4084	2026-06-13	406.4300	1.8239	\N	1526438.80	395.2457	FINNHUB	2026-06-12 23:04:23.840923+00	\N
2531	4085	2026-06-13	489.2500	0.7122	\N	1054664.90	14.5529	FINNHUB	2026-06-12 23:04:27.109624+00	\N
2532	4086	2026-06-13	1133.0000	-2.4075	\N	1082333.90	42.8194	FINNHUB	2026-06-12 23:04:30.253747+00	\N
2534	4088	2026-06-13	121.0400	0.4481	\N	963245.94	42.3666	FINNHUB	2026-06-12 23:04:36.664328+00	\N
2535	4089	2026-06-13	320.7200	2.3063	\N	858327.90	14.5729	FINNHUB	2026-06-12 23:04:39.848521+00	\N
2536	4090	2026-06-13	511.5700	4.7333	\N	834166.40	166.5335	FINNHUB	2026-06-12 23:04:42.981257+00	\N
2537	4091	2026-06-13	1863.5500	-1.8916	\N	602008.06	58.9453	FINNHUB	2026-06-12 23:04:46.194109+00	\N
2538	4092	2026-06-13	147.0100	0.2797	\N	607649.25	24.0045	FINNHUB	2026-06-12 23:04:49.325201+00	\N
2539	4093	2026-06-13	184.1300	0.0163	\N	525798.75	32.4367	FINNHUB	2026-06-12 23:04:52.470316+00	\N
2540	4094	2026-06-13	322.3900	1.0469	\N	601130.06	27.0341	FINNHUB	2026-06-12 23:04:55.609753+00	\N
2541	4095	2026-06-13	240.8700	1.0657	\N	577635.80	27.4542	FINNHUB	2026-06-12 23:04:58.840267+00	\N
2542	4096	2026-06-13	124.5700	6.5065	\N	627950.94	\N	FINNHUB	2026-06-12 23:05:02.026429+00	\N
2543	4097	2026-06-13	121.1000	-0.5992	\N	477307.75	39.9153	FINNHUB	2026-06-12 23:05:05.286541+00	\N
2544	4098	2026-06-13	489.9800	0.7132	\N	433380.22	27.8343	FINNHUB	2026-06-12 23:05:08.626071+00	\N
2545	4099	2026-06-13	982.3500	0.6826	\N	434014.97	49.1078	FINNHUB	2026-06-12 23:05:11.808633+00	\N
2546	4100	2026-06-13	910.5700	1.4416	\N	419071.44	44.4402	FINNHUB	2026-06-12 23:05:15.06276+00	\N
2547	4101	2026-06-13	227.7300	1.3169	\N	401671.53	110.5011	FINNHUB	2026-06-12 23:05:18.317554+00	\N
2548	4102	2026-06-13	56.0200	1.5591	\N	395173.62	12.4672	FINNHUB	2026-06-12 23:05:21.759311+00	\N
2549	4103	2026-06-13	366.8100	1.1834	\N	461298.12	68.7663	FINNHUB	2026-06-12 23:05:24.953767+00	\N
2550	4104	2026-06-13	187.2200	0.7534	\N	373185.60	33.8982	FINNHUB	2026-06-12 23:05:28.667314+00	\N
2551	4105	2026-06-13	380.8100	11.2731	\N	364132.72	402.8017	FINNHUB	2026-06-12 23:05:31.845626+00	\N
2552	4106	2026-06-13	408.5200	0.7323	\N	365532.03	30.3497	FINNHUB	2026-06-12 23:05:34.991245+00	\N
2553	4107	2026-06-13	567.2500	2.6437	\N	445439.03	52.3553	FINNHUB	2026-06-12 23:05:38.265276+00	\N
2554	4108	2026-06-13	80.3400	-1.1443	\N	340064.06	25.4279	FINNHUB	2026-06-12 23:05:41.390898+00	\N
2555	4109	2026-06-13	335.3000	0.7633	\N	346596.66	40.1618	FINNHUB	2026-06-12 23:05:44.525387+00	\N
2556	4110	2026-06-13	82.6200	0.1091	\N	354696.66	25.8884	FINNHUB	2026-06-12 23:05:47.716092+00	\N
2557	4111	2026-06-13	149.6100	0.8561	\N	347240.70	20.8980	FINNHUB	2026-06-12 23:05:50.889087+00	\N
2558	4112	2026-06-13	214.0400	0.6489	\N	338303.97	18.6774	FINNHUB	2026-06-12 23:05:54.476277+00	\N
2559	4113	2026-06-13	127.9900	-2.3573	\N	306832.00	134.4853	FINNHUB	2026-06-12 23:05:57.621334+00	\N
2560	4114	2026-06-13	1062.7500	2.6177	\N	314147.50	17.3870	FINNHUB	2026-06-12 23:06:00.788446+00	\N
2561	4115	2026-06-13	92.6700	2.1495	\N	227132.36	13.6550	FINNHUB	2026-06-12 23:06:04.037856+00	\N
2562	4116	2026-06-13	328.3900	0.7300	\N	327881.90	23.4001	FINNHUB	2026-06-12 23:06:07.541686+00	\N
2564	4118	2026-06-13	178.7500	-1.9366	\N	210576.08	27.1814	FINNHUB	2026-06-12 23:06:14.641288+00	\N
2565	4119	2026-06-13	184.3000	1.9528	\N	287242.40	25.8870	FINNHUB	2026-06-12 23:06:17.768089+00	\N
2566	4120	2026-06-13	112.8200	0.1154	\N	262964.62	16.7924	FINNHUB	2026-06-12 23:06:20.932161+00	\N
2567	4121	2026-06-13	153.0700	-0.5522	\N	221884.06	20.5936	FINNHUB	2026-06-12 23:06:24.219377+00	\N
2568	4122	2026-06-13	199.5400	0.1355	\N	388159.78	17.5336	FINNHUB	2026-06-12 23:06:27.737119+00	\N
2569	4123	2026-06-13	272.2400	-0.9496	\N	255973.16	23.8070	FINNHUB	2026-06-12 23:06:30.899888+00	\N
2570	4124	2026-06-13	301.1200	1.3531	\N	270889.12	50.4731	FINNHUB	2026-06-12 23:06:34.11054+00	\N
2571	4125	2026-06-13	395.5700	1.0525	\N	256372.08	30.4878	FINNHUB	2026-06-12 23:06:37.285505+00	\N
2572	4126	2026-06-13	254.5400	-89.4454	\N	31502.65	6.7449	FINNHUB	2026-06-12 23:06:40.464545+00	\N
2573	4127	2026-06-13	940.6600	3.7352	\N	252774.16	26.9655	FINNHUB	2026-06-12 23:06:43.58144+00	\N
2574	4128	2026-06-13	83.7300	1.6141	\N	252159.60	11.6219	FINNHUB	2026-06-12 23:06:46.715205+00	\N
2575	4129	2026-06-13	183.5300	-0.3691	\N	247156.80	34.0624	FINNHUB	2026-06-12 23:06:49.883381+00	\N
2576	4130	2026-06-13	85.6600	-0.2213	\N	181913.58	13.0114	FINNHUB	2026-06-12 23:06:53.074508+00	\N
2577	4131	2026-06-13	523.5700	1.5773	\N	242203.23	34.1998	FINNHUB	2026-06-12 23:06:56.305874+00	\N
2578	4132	2026-06-13	174.9500	0.0000	\N	32533296.00	8.4544	FINNHUB	2026-06-12 23:06:59.583158+00	\N
2579	4133	2026-06-13	1980.1000	5.2399	\N	293232.56	65.0616	FINNHUB	2026-06-12 23:07:02.723272+00	\N
2580	4134	2026-06-13	279.7000	-0.3598	\N	244681.55	96.8384	FINNHUB	2026-06-12 23:07:05.867909+00	\N
2581	4135	2026-06-13	211.7200	4.3161	\N	223279.38	22.5012	FINNHUB	2026-06-12 23:07:09.018552+00	\N
2582	4136	2026-06-13	20.1600	0.3984	\N	35122664.00	14.4703	FINNHUB	2026-06-12 23:07:12.28654+00	\N
2583	4137	2026-06-13	139.8300	1.2747	\N	239795.53	14.9629	FINNHUB	2026-06-12 23:07:15.515323+00	\N
2584	4138	2026-06-13	279.6200	0.0322	\N	223236.66	264.8750	FINNHUB	2026-06-12 23:07:18.766526+00	\N
2585	4139	2026-06-13	90.8200	3.2045	\N	308905.94	21.2394	FINNHUB	2026-06-12 23:07:21.992073+00	\N
2586	4140	2026-06-13	164.1800	0.3300	\N	163341.48	22.3358	FINNHUB	2026-06-12 23:07:25.437904+00	\N
2587	4141	2026-06-13	325.4400	2.1822	\N	221244.33	19.7187	FINNHUB	2026-06-12 23:07:28.569577+00	\N
2588	4142	2026-06-13	284.8100	0.0140	\N	203961.36	23.5060	FINNHUB	2026-06-12 23:07:31.722119+00	\N
2589	4143	2026-06-13	88.0200	0.3420	\N	173677.86	13.3247	FINNHUB	2026-06-12 23:07:34.883548+00	\N
2591	4145	2026-06-13	417.7900	1.3734	\N	204225.86	61.6357	FINNHUB	2026-06-12 23:07:41.419988+00	\N
2592	4146	2026-06-13	163.2400	4.3734	\N	201066.33	54.0428	FINNHUB	2026-06-12 23:07:44.767699+00	\N
2593	4147	2026-06-13	144.2700	0.3757	\N	197183.67	22.5791	FINNHUB	2026-06-12 23:07:47.930174+00	\N
2594	4148	2026-06-13	189.1000	1.7651	\N	204644.92	19.4105	FINNHUB	2026-06-12 23:07:51.070189+00	\N
2595	4149	2026-06-13	931.0400	7.2516	\N	208766.16	87.7906	FINNHUB	2026-06-12 23:07:54.215192+00	\N
2596	4150	2026-06-13	48.1100	2.4925	\N	196000.72	11.3034	FINNHUB	2026-06-12 23:07:57.383927+00	\N
2597	4151	2026-06-13	355.2000	0.3220	\N	191429.12	24.5422	FINNHUB	2026-06-12 23:08:00.538096+00	\N
2598	4152	2026-06-13	496.7700	3.8030	\N	166884.90	42.1113	FINNHUB	2026-06-12 23:08:03.869069+00	\N
2599	4153	2026-06-13	117.3300	0.9290	\N	274070.03	18.3816	FINNHUB	2026-06-12 23:08:07.42166+00	\N
2600	4154	2026-06-13	85.9900	1.3555	\N	178692.90	21.8371	FINNHUB	2026-06-12 23:08:10.763821+00	\N
2601	4155	2026-06-13	168.4100	0.0416	\N	185498.22	32.0377	FINNHUB	2026-06-12 23:08:14.019627+00	\N
2602	4156	2026-06-13	12.8700	2.4682	\N	153663.94	9.5124	FINNHUB	2026-06-12 23:08:17.202084+00	\N
2603	4157	2026-06-13	562.9250	6.3547	\N	182436.81	28.0198	FINNHUB	2026-06-12 23:08:20.343103+00	\N
2604	4158	2026-06-13	105.3500	1.6499	\N	130344.86	17.5392	FINNHUB	2026-06-12 23:08:23.50271+00	\N
2605	4159	2026-06-13	469.3400	-1.3287	\N	174781.00	25.5304	FINNHUB	2026-06-12 23:08:26.716911+00	\N
2606	4160	2026-06-13	100.0400	-0.2990	\N	173234.36	15.4343	FINNHUB	2026-06-12 23:08:29.917741+00	\N
2607	4161	2026-06-13	682.8000	-1.2624	\N	173816.86	\N	FINNHUB	2026-06-12 23:08:33.043598+00	\N
2608	4162	2026-06-13	153.8000	0.8789	\N	188539.60	42.2214	FINNHUB	2026-06-12 23:08:36.184556+00	\N
2610	4164	2026-06-13	1032.0000	1.5169	\N	168051.81	26.8668	FINNHUB	2026-06-12 23:08:42.535832+00	\N
2611	4165	2026-06-13	272.7000	1.6475	\N	154356.47	21.3998	FINNHUB	2026-06-12 23:08:45.800876+00	\N
2612	4166	2026-06-13	125.5900	-0.2225	\N	155605.95	16.8825	FINNHUB	2026-06-12 23:08:48.997547+00	\N
2613	4167	2026-06-13	88.1800	-1.6397	\N	153157.56	24.4037	FINNHUB	2026-06-12 23:08:52.141324+00	\N
2614	4168	2026-06-13	23.5800	2.5217	\N	162903.81	7.6013	FINNHUB	2026-06-12 23:08:55.290271+00	\N
2615	4169	2026-06-13	577.4800	1.5546	\N	155317.95	32.4729	FINNHUB	2026-06-12 23:08:58.47577+00	\N
2616	4170	2026-06-13	91.1000	2.7058	\N	158904.81	16.8653	FINNHUB	2026-06-12 23:09:01.617012+00	\N
2617	4171	2026-06-13	391.3900	-0.5716	\N	152062.16	38.1013	FINNHUB	2026-06-12 23:09:04.750351+00	\N
2618	4172	2026-06-13	179.2000	1.5010	\N	153038.62	84.5517	FINNHUB	2026-06-12 23:09:08.05934+00	\N
2619	4173	2026-06-13	82.9100	0.7779	\N	141010.94	22.5020	FINNHUB	2026-06-12 23:09:11.261807+00	\N
2620	4174	2026-06-13	165.8900	-0.3364	\N	134946.62	16.8200	FINNHUB	2026-06-12 23:09:14.658637+00	\N
2621	4175	2026-06-13	411.0600	-0.4456	\N	144463.02	48.4922	FINNHUB	2026-06-12 23:09:17.850575+00	\N
2622	4176	2026-06-13	26.2100	0.1528	\N	149154.45	19.9112	FINNHUB	2026-06-12 23:09:20.99429+00	\N
2623	4177	2026-06-13	24.4000	2.4349	\N	23675664.00	14.9564	FINNHUB	2026-06-12 23:09:24.132888+00	\N
2624	4178	2026-06-13	214.2300	1.6898	\N	151228.03	107.4398	FINNHUB	2026-06-12 23:09:27.267677+00	\N
2625	4179	2026-06-13	189.7900	4.1886	\N	157462.30	31.7100	FINNHUB	2026-06-12 23:09:30.611667+00	\N
2626	4180	2026-06-13	48.9700	1.6186	\N	119376.20	16.4492	FINNHUB	2026-06-12 23:09:36.836534+00	\N
2627	4181	2026-06-13	68.8500	-1.0065	\N	142767.28	16.7175	FINNHUB	2026-06-12 23:09:40.094291+00	\N
2628	4182	2026-06-13	116.9800	1.4043	\N	143697.77	19.6255	FINNHUB	2026-06-12 23:09:43.274533+00	\N
2629	4183	2026-06-13	108.2400	-2.0186	\N	140458.14	105.4491	FINNHUB	2026-06-12 23:09:46.423723+00	\N
2630	4184	2026-06-13	122.7900	1.5801	\N	149989.72	49.1111	FINNHUB	2026-06-12 23:09:49.586062+00	\N
2631	4185	2026-06-13	148.7400	1.0531	\N	142019.23	38.2054	FINNHUB	2026-06-12 23:09:52.855356+00	\N
2632	4186	2026-06-13	220.3100	0.5431	\N	139600.12	30.9466	FINNHUB	2026-06-12 23:09:56.829031+00	\N
2633	4187	2026-06-13	20.5300	-2.9314	\N	19963124.00	\N	FINNHUB	2026-06-12 23:10:00.442026+00	\N
2634	4188	2026-06-13	180.1000	-0.3817	\N	127533.19	34.5712	FINNHUB	2026-06-12 23:10:03.665645+00	\N
2635	4189	2026-06-13	164.9400	0.8252	\N	127808.45	20.7684	FINNHUB	2026-06-12 23:10:06.834122+00	\N
2637	4191	2026-06-13	328.1400	0.0640	\N	127272.41	11.2640	FINNHUB	2026-06-12 23:10:13.936594+00	\N
2638	4192	2026-06-13	418.9100	1.3476	\N	123997.36	25.9572	FINNHUB	2026-06-12 23:10:17.200635+00	\N
2639	4193	2026-06-13	23.3400	0.8207	\N	108543.59	10.0475	FINNHUB	2026-06-12 23:10:20.43508+00	\N
2640	4194	2026-06-13	56.5000	0.0708	\N	172249.97	24.9457	FINNHUB	2026-06-12 23:10:23.764894+00	\N
2641	4195	2026-06-13	101.9600	1.4729	\N	130642.20	44.5574	FINNHUB	2026-06-12 23:10:27.164345+00	\N
2642	4196	2026-06-13	58.9200	1.0288	\N	90959.13	11.1311	FINNHUB	2026-06-12 23:10:30.681034+00	\N
2643	4197	2026-06-13	81.5600	0.3198	\N	115722.13	8.1822	FINNHUB	2026-06-12 23:10:34.108524+00	\N
2644	4198	2026-06-13	540.3300	-1.5218	\N	124497.43	25.9748	FINNHUB	2026-06-12 23:10:37.389671+00	\N
2645	4199	2026-06-13	24.1700	1.5120	\N	11465064.00	15.0805	FINNHUB	2026-06-12 23:10:40.707833+00	\N
2646	4200	2026-06-13	71.9400	0.7422	\N	119580.91	14.8492	FINNHUB	2026-06-12 23:10:43.997356+00	\N
2647	4201	2026-06-13	203.1100	0.4203	\N	118684.57	10.2677	FINNHUB	2026-06-12 23:10:47.174978+00	\N
2648	4202	2026-06-13	220.7800	-0.1221	\N	123865.81	18.6489	FINNHUB	2026-06-12 23:10:50.371513+00	\N
2649	4203	2026-06-13	9.6800	1.6807	\N	18030212.00	14.4400	FINNHUB	2026-06-12 23:10:53.59326+00	\N
2650	4204	2026-06-13	312.2000	2.1463	\N	120289.02	36.0471	FINNHUB	2026-06-12 23:10:56.932255+00	\N
2651	4205	2026-06-13	57.1300	0.4042	\N	116602.27	19.5094	FINNHUB	2026-06-12 23:11:00.445243+00	\N
2652	4206	2026-06-13	102.1500	-0.9022	\N	101975.73	58.0397	FINNHUB	2026-06-12 23:11:05.573935+00	\N
2653	4207	2026-06-13	302.8700	1.6752	\N	116335.03	74.6503	FINNHUB	2026-06-12 23:11:08.943761+00	\N
2654	4208	2026-06-13	168.3000	1.0204	\N	164141.08	16.8679	FINNHUB	2026-06-12 23:11:12.620257+00	\N
2655	4209	2026-06-13	444.9250	-0.0258	\N	112953.56	26.0364	FINNHUB	2026-06-12 23:11:15.834789+00	\N
2656	4210	2026-06-13	42.7800	0.2343	\N	84250.73	35.1969	FINNHUB	2026-06-12 23:11:19.0238+00	\N
2657	4211	2026-06-13	184.7300	1.4777	\N	113501.59	35.2161	FINNHUB	2026-06-12 23:11:22.337816+00	\N
2658	4212	2026-06-13	903.4800	0.1230	\N	113605.73	32.6437	FINNHUB	2026-06-12 23:11:25.512946+00	\N
2659	4213	2026-06-13	18.3800	0.7675	\N	570094.90	5.2991	FINNHUB	2026-06-12 23:11:28.80804+00	\N
2660	4214	2026-06-13	16.3200	-0.1224	\N	570094.90	5.2991	FINNHUB	2026-06-12 23:11:32.083123+00	\N
2662	4216	2026-06-13	103.0400	0.7431	\N	117104.17	78.2939	FINNHUB	2026-06-12 23:11:38.492922+00	\N
2663	4217	2026-06-13	44.2500	0.3174	\N	92006.26	7.5236	FINNHUB	2026-06-12 23:11:41.719926+00	\N
2664	4218	2026-06-13	1055.8500	1.2146	\N	104132.42	73.2295	FINNHUB	2026-06-12 23:11:45.053805+00	\N
2665	4219	2026-06-13	100.2300	2.7052	\N	107000.81	12.6538	FINNHUB	2026-06-12 23:11:48.248702+00	\N
2666	4220	2026-06-13	146.3000	0.8548	\N	106483.11	54.4810	FINNHUB	2026-06-12 23:11:51.454193+00	\N
2667	4221	2026-06-13	80.2000	-0.1618	\N	102967.58	21.4426	FINNHUB	2026-06-12 23:11:54.617373+00	\N
2669	4223	2026-06-13	49.2000	-2.7860	\N	105611.20	24.2061	FINNHUB	2026-06-12 23:12:00.957711+00	\N
2670	4224	2026-06-13	707.7400	3.5783	\N	105322.71	95.3367	FINNHUB	2026-06-12 23:12:04.279391+00	\N
2671	4225	2026-06-13	384.9600	0.3179	\N	106371.20	90.8403	FINNHUB	2026-06-12 23:12:07.529048+00	\N
2672	4226	2026-06-13	402.5400	1.4236	\N	105213.09	40.7171	FINNHUB	2026-06-12 23:12:10.750021+00	\N
2673	4227	2026-06-13	53.0400	0.3405	\N	78673.27	13.4969	FINNHUB	2026-06-12 23:12:14.133289+00	\N
2674	4228	2026-06-13	482.0000	-0.8230	\N	99211.28	31.6538	FINNHUB	2026-06-12 23:12:18.682992+00	\N
2675	4229	2026-06-13	204.0200	-6.7550	\N	88438.96	12.2696	FINNHUB	2026-06-12 23:12:22.282646+00	\N
2676	4230	2026-06-13	458.2500	-0.4107	\N	101298.68	34.9535	FINNHUB	2026-06-12 23:12:25.751977+00	\N
2677	4231	2026-06-13	264.6700	0.0265	\N	105896.45	60.7204	FINNHUB	2026-06-12 23:12:29.218865+00	\N
2678	4232	2026-06-13	113.4600	1.4485	\N	144606.84	14.7287	FINNHUB	2026-06-12 23:12:32.378799+00	\N
2679	4233	2026-06-13	45.2100	0.3997	\N	101114.88	75.6848	FINNHUB	2026-06-12 23:12:35.67453+00	\N
2680	4234	2026-06-13	83.9900	1.5721	\N	142074.20	14.8800	FINNHUB	2026-06-12 23:12:38.935084+00	\N
2681	4235	2026-06-13	143.9800	1.3301	\N	99065.09	\N	FINNHUB	2026-06-12 23:12:42.100586+00	\N
2682	4236	2026-06-13	124.9700	0.6281	\N	97215.65	18.9172	FINNHUB	2026-06-12 23:12:45.808928+00	\N
2683	4237	2026-06-13	45.3000	-0.3081	\N	132500.94	13.6458	FINNHUB	2026-06-12 23:12:49.1497+00	\N
2684	4238	2026-06-13	27.7900	1.2017	\N	9448161.00	17.4296	FINNHUB	2026-06-12 23:12:52.395557+00	\N
2685	4239	2026-06-13	360.2200	0.3790	\N	97660.45	22.4972	FINNHUB	2026-06-12 23:12:55.686945+00	\N
2686	4240	2026-06-13	36.1800	-1.5510	\N	925749.06	17.5701	FINNHUB	2026-06-12 23:12:58.872022+00	\N
2687	4241	2026-06-13	269.5300	2.8034	\N	96865.91	22.6836	FINNHUB	2026-06-12 23:13:02.130595+00	\N
2688	4242	2026-06-13	784.0500	-0.3989	\N	94889.08	19.9263	FINNHUB	2026-06-12 23:13:05.488563+00	\N
2689	4243	2026-06-13	226.2100	0.1949	\N	90639.75	20.8583	FINNHUB	2026-06-12 23:13:08.691368+00	\N
2690	4244	2026-06-13	108.1000	-0.5062	\N	92353.20	17.5944	FINNHUB	2026-06-12 23:13:11.84033+00	\N
2692	4246	2026-06-13	68.4100	3.1203	\N	98868.17	36.1757	FINNHUB	2026-06-12 23:13:18.263283+00	\N
2693	4247	2026-06-13	253.7600	2.8576	\N	91655.59	24.1772	FINNHUB	2026-06-12 23:13:21.510089+00	\N
2694	4248	2026-06-13	187.1800	-1.1251	\N	87550.63	30.1867	FINNHUB	2026-06-12 23:13:24.712286+00	\N
2695	4249	2026-06-13	404.0700	1.2250	\N	86524.00	16.5028	FINNHUB	2026-06-12 23:13:27.832305+00	\N
2696	4250	2026-06-13	659.5800	0.5933	\N	91252.16	34.1385	FINNHUB	2026-06-12 23:13:31.118789+00	\N
2697	4251	2026-06-13	453.8900	-0.5260	\N	87103.95	112.6439	FINNHUB	2026-06-12 23:13:34.377382+00	\N
2698	4252	2026-06-13	219.4500	0.3017	\N	87860.77	31.4462	FINNHUB	2026-06-12 23:13:37.774384+00	\N
2699	4253	2026-06-13	228.4800	0.4573	\N	81138.45	\N	FINNHUB	2026-06-12 23:13:41.598199+00	\N
2700	4254	2026-06-13	72.0800	0.6423	\N	87591.13	31.3722	FINNHUB	2026-06-12 23:13:44.736451+00	\N
2701	4255	2026-06-13	144.9600	0.6597	\N	88442.35	25.0474	FINNHUB	2026-06-12 23:13:47.887042+00	\N
2702	4256	2026-06-13	92.8300	0.8693	\N	90006.09	44.2960	FINNHUB	2026-06-12 23:13:51.050011+00	\N
2703	4257	2026-06-13	47.5700	0.4328	\N	88391.67	28.9809	FINNHUB	2026-06-12 23:13:54.512035+00	\N
2704	4258	2026-06-13	58.9400	2.2731	\N	89459.02	11.4603	FINNHUB	2026-06-12 23:13:57.944614+00	\N
2705	4259	2026-06-13	30.2100	1.7857	\N	71067.17	7.3485	FINNHUB	2026-06-12 23:14:01.103403+00	\N
2706	4260	2026-06-13	24.5000	2.2111	\N	86644.40	4.6095	FINNHUB	2026-06-12 23:14:04.23724+00	\N
2707	4261	2026-06-13	7.9900	1.0114	\N	457234.88	13.1205	FINNHUB	2026-06-12 23:14:07.419321+00	\N
2708	4262	2026-06-13	14.8000	5.0390	\N	65750.23	84.1872	FINNHUB	2026-06-12 23:14:10.77754+00	\N
2709	4263	2026-06-13	96.2400	0.9864	\N	86411.30	29.1771	FINNHUB	2026-06-12 23:14:13.96234+00	\N
2710	4264	2026-06-13	229.9000	-1.8528	\N	81835.25	603.1801	FINNHUB	2026-06-12 23:14:17.212132+00	\N
2711	4265	2026-06-13	25.4700	2.9091	\N	60728.23	5.4908	FINNHUB	2026-06-12 23:14:20.416966+00	\N
2712	4266	2026-06-13	232.7800	-3.1657	\N	80681.55	\N	FINNHUB	2026-06-12 23:14:23.532859+00	\N
2713	4267	2026-06-13	387.1800	2.2906	\N	85891.94	12.6423	FINNHUB	2026-06-12 23:14:26.950782+00	\N
2714	4268	2026-06-13	56.1800	0.3214	\N	84373.58	25.3450	FINNHUB	2026-06-12 23:14:30.149536+00	\N
2715	4269	2026-06-13	162.6400	3.0933	\N	109977.98	14.7184	FINNHUB	2026-06-12 23:14:33.369198+00	\N
2716	4270	2026-06-13	37.2500	-0.0805	\N	80655.96	13.6636	FINNHUB	2026-06-12 23:14:36.553134+00	\N
2718	4272	2026-06-13	276.7300	-0.0650	\N	73967.14	16.1359	FINNHUB	2026-06-12 23:14:43.106879+00	\N
2719	4273	2026-06-13	81.8400	0.3925	\N	60106.58	18.5457	FINNHUB	2026-06-12 23:14:46.289512+00	\N
2720	4274	2026-06-13	38.1200	3.5870	\N	2387013.20	50.5156	FINNHUB	2026-06-12 23:14:49.505668+00	\N
2721	4275	2026-06-13	158.3200	0.2596	\N	82759.69	29.6949	FINNHUB	2026-06-12 23:14:52.65158+00	\N
2722	4276	2026-06-13	140.5300	1.1153	\N	79457.34	20.2130	FINNHUB	2026-06-12 23:14:57.31212+00	\N
2723	4277	2026-06-13	219.0400	1.9455	\N	71030.71	15.1339	FINNHUB	2026-06-12 23:15:00.497362+00	\N
2724	4278	2026-06-13	53.5000	-1.0359	\N	69478.56	15.5017	FINNHUB	2026-06-12 23:15:03.766224+00	\N
2725	4279	2026-06-13	90.0800	0.8622	\N	110700.73	27.1525	FINNHUB	2026-06-12 23:15:06.999797+00	\N
2726	4280	2026-06-13	168.6800	0.3152	\N	81360.63	20.7288	FINNHUB	2026-06-12 23:15:21.484537+00	\N
2727	4281	2026-06-13	62.9900	-0.5840	\N	80459.17	30.7683	FINNHUB	2026-06-12 23:15:24.946356+00	\N
2728	4282	2026-06-13	132.2800	1.0774	\N	79725.80	31.6749	FINNHUB	2026-06-12 23:15:28.107571+00	\N
2729	4283	2026-06-13	338.3100	0.0917	\N	80465.35	17.9450	FINNHUB	2026-06-12 23:15:31.240263+00	\N
2730	4284	2026-06-13	447.8500	1.3648	\N	77727.52	31.1533	FINNHUB	2026-06-12 23:15:34.394045+00	\N
2731	4285	2026-06-13	345.9500	1.1964	\N	78754.95	51.0732	FINNHUB	2026-06-12 23:15:37.563973+00	\N
2732	4286	2026-06-13	143.0700	0.6897	\N	79747.03	32.6297	FINNHUB	2026-06-12 23:15:40.977035+00	\N
2733	4287	2026-06-13	550.3300	-0.3964	\N	78028.22	17.0516	FINNHUB	2026-06-12 23:15:44.214745+00	\N
2734	4288	2026-06-13	5.5000	1.4760	\N	57161.76	9.0863	FINNHUB	2026-06-12 23:15:47.351972+00	\N
2735	4289	2026-06-13	125.8200	0.1672	\N	78776.31	15.6081	FINNHUB	2026-06-12 23:15:50.963275+00	\N
2736	4290	2026-06-13	298.0000	1.0718	\N	78859.76	12.5413	FINNHUB	2026-06-12 23:16:02.057317+00	\N
2737	4291	2026-06-13	263.5800	1.0621	\N	77145.71	16.6549	FINNHUB	2026-06-12 23:16:05.193153+00	\N
2738	4292	2026-06-13	258.6700	1.2011	\N	75896.02	18.0447	FINNHUB	2026-06-12 23:16:08.345638+00	\N
2739	4293	2026-06-13	294.3800	2.2295	\N	78951.23	17.6270	FINNHUB	2026-06-12 23:16:11.50408+00	\N
2740	4294	2026-06-13	260.2200	4.5564	\N	74017.98	12268.8520	FINNHUB	2026-06-12 23:16:14.706152+00	\N
2741	4295	2026-06-13	317.3000	0.1294	\N	78468.36	30.1883	FINNHUB	2026-06-12 23:16:18.228933+00	\N
2743	4297	2026-06-13	304.8600	0.7635	\N	76385.13	28.7920	FINNHUB	2026-06-12 23:16:24.800566+00	\N
2744	4298	2026-06-13	27.7500	0.3254	\N	1321162.90	15.0960	FINNHUB	2026-06-12 23:16:27.975714+00	\N
2745	4299	2026-06-13	93.1900	1.0409	\N	83992.65	44.2766	FINNHUB	2026-06-12 23:16:31.217746+00	\N
2773	4327	2026-06-13	1074.2400	0.5381	\N	67297.45	26.8438	FINNHUB	2026-06-12 23:18:04.399413+00	\N
2774	4328	2026-06-13	184.2000	0.7438	\N	64785.22	47.0177	FINNHUB	2026-06-12 23:18:07.676788+00	\N
2775	4329	2026-06-13	19.0700	1.6525	\N	64556.15	14.7929	FINNHUB	2026-06-12 23:18:11.415692+00	\N
2776	4330	2026-06-13	40.2000	2.8133	\N	91398.98	10.6757	FINNHUB	2026-06-12 23:18:14.605738+00	\N
2777	4331	2026-06-13	26.9800	0.4468	\N	65762.20	\N	FINNHUB	2026-06-12 23:18:17.752607+00	\N
2778	4332	2026-06-13	15.7100	2.2786	\N	367651.22	23.5629	FINNHUB	2026-06-12 23:18:20.901079+00	\N
2779	4333	2026-06-13	48.1700	2.9274	\N	61568.84	39.5687	FINNHUB	2026-06-12 23:18:24.041011+00	\N
2780	4334	2026-06-13	1877.6100	1.8547	\N	67181.37	54.9026	FINNHUB	2026-06-12 23:18:27.179299+00	\N
2781	4335	2026-06-13	40.3100	1.3069	\N	92573.36	14.4240	FINNHUB	2026-06-12 23:18:30.738397+00	\N
2782	4336	2026-06-13	612.1400	0.1079	\N	64273.66	14.5304	FINNHUB	2026-06-12 23:18:33.967892+00	\N
2783	4337	2026-06-13	209.9100	0.8940	\N	64437.17	29.7082	FINNHUB	2026-06-12 23:18:37.872706+00	\N
2784	4338	2026-06-13	304.4600	0.1843	\N	64629.10	8.4994	FINNHUB	2026-06-12 23:18:41.014952+00	\N
2785	4339	2026-06-13	77.3000	-1.0497	\N	54726.50	211.0606	FINNHUB	2026-06-12 23:18:44.632541+00	\N
2786	4340	2026-06-13	102.3900	-10.7946	\N	66442.41	\N	FINNHUB	2026-06-12 23:18:47.764334+00	\N
2787	4341	2026-06-13	44.9300	-2.2411	\N	66862.06	29.7165	FINNHUB	2026-06-12 23:18:50.927908+00	\N
2788	4342	2026-06-13	16.5800	2.1565	\N	46663.01	7.7850	FINNHUB	2026-06-12 23:18:54.15466+00	\N
2789	4343	2026-06-13	281.6200	1.2585	\N	63647.71	30.2034	FINNHUB	2026-06-12 23:18:57.30479+00	\N
2790	4344	2026-06-13	63.1400	-0.5356	\N	62976.52	20.2107	FINNHUB	2026-06-12 23:19:00.500737+00	\N
2791	4345	2026-06-13	210.3800	1.2708	\N	61563.75	21.1850	FINNHUB	2026-06-12 23:19:03.620554+00	\N
2792	4346	2026-06-13	33.7400	1.9027	\N	43307.73	20.9723	FINNHUB	2026-06-12 23:19:06.757095+00	\N
2793	4347	2026-06-13	118.5200	0.7995	\N	62412.29	25.2069	FINNHUB	2026-06-12 23:19:09.902329+00	\N
2794	4348	2026-06-13	1315.8700	0.1454	\N	62312.11	34.9675	FINNHUB	2026-06-12 23:19:16.671367+00	\N
2795	4349	2026-06-13	51.6600	1.9337	\N	63141.16	11.4241	FINNHUB	2026-06-12 23:19:19.800747+00	\N
2796	4350	2026-06-13	354.9100	-2.9293	\N	60173.38	37.6522	FINNHUB	2026-06-12 23:19:23.28404+00	\N
2797	4351	2026-06-13	117.8000	1.1593	\N	59910.07	12.9228	FINNHUB	2026-06-12 23:19:26.500865+00	\N
2798	4352	2026-06-13	92.2900	0.8193	\N	60597.07	30.9643	FINNHUB	2026-06-12 23:19:29.772702+00	\N
2799	4353	2026-06-13	33.3100	3.4151	\N	50503.60	7.1323	FINNHUB	2026-06-12 23:19:32.926983+00	\N
2800	4354	2026-06-13	14.8400	0.8838	\N	58774.22	\N	FINNHUB	2026-06-12 23:19:36.060042+00	\N
2801	4355	2026-06-13	121.2900	0.2645	\N	81751.35	27.9970	FINNHUB	2026-06-12 23:19:39.377006+00	\N
2802	4356	2026-06-13	67.9100	1.8294	\N	59727.70	20.2193	FINNHUB	2026-06-12 23:19:42.701567+00	\N
2803	4357	2026-06-13	232.3600	4.5536	\N	56918.30	69.6504	FINNHUB	2026-06-12 23:19:45.842639+00	\N
2804	4358	2026-06-13	12.1900	0.8271	\N	58764.65	18.4577	FINNHUB	2026-06-12 23:19:49.075128+00	\N
2805	4359	2026-06-13	266.3500	2.0889	\N	60658.80	26.0227	FINNHUB	2026-06-12 23:19:52.246138+00	\N
2806	4360	2026-06-13	307.7900	-1.4031	\N	58155.70	33.5772	FINNHUB	2026-06-12 23:19:55.64209+00	\N
2807	4361	2026-06-13	56.8700	0.6727	\N	57322.31	12.2014	FINNHUB	2026-06-12 23:19:58.847428+00	\N
2808	4362	2026-06-13	62.7200	1.3084	\N	58485.93	52.1944	FINNHUB	2026-06-12 23:20:02.023078+00	\N
2809	4363	2026-06-13	221.6300	0.9382	\N	56714.98	4.6702	FINNHUB	2026-06-12 23:20:05.281715+00	\N
2810	4364	2026-06-13	272.6000	1.1991	\N	57818.63	27.1182	FINNHUB	2026-06-12 23:20:08.422456+00	\N
2811	4365	2026-06-13	56.5400	1.9290	\N	56351.03	11.9010	FINNHUB	2026-06-12 23:20:11.626155+00	\N
2812	4366	2026-06-13	350.6700	3.1291	\N	58230.89	55.2475	FINNHUB	2026-06-12 23:20:16.423999+00	\N
2813	4367	2026-06-13	403.2000	5.7158	\N	59119.71	69.2221	FINNHUB	2026-06-12 23:20:19.638334+00	\N
2814	4368	2026-06-13	69.9100	0.2438	\N	57924.68	44.2173	FINNHUB	2026-06-12 23:20:27.572506+00	\N
2815	4369	2026-06-13	135.2300	1.9527	\N	61461.15	17.8148	FINNHUB	2026-06-12 23:20:30.708378+00	\N
2816	4370	2026-06-13	149.7100	-1.5001	\N	54850.44	62.3300	FINNHUB	2026-06-12 23:20:34.109213+00	\N
2817	4371	2026-06-13	90.5900	1.5583	\N	57099.88	16.1710	FINNHUB	2026-06-12 23:20:37.314681+00	\N
2818	4372	2026-06-13	218.6900	-1.0005	\N	56354.87	34.9683	FINNHUB	2026-06-12 23:20:40.634958+00	\N
2819	4373	2026-06-13	893.5200	-0.6029	\N	47996.77	24.7155	FINNHUB	2026-06-12 23:20:43.899125+00	\N
2820	4374	2026-06-13	100.5500	5.0240	\N	52232.91	\N	FINNHUB	2026-06-12 23:20:47.085284+00	\N
2821	4375	2026-06-13	325.9400	0.3788	\N	57217.38	30.0696	FINNHUB	2026-06-12 23:20:50.416183+00	\N
2822	4376	2026-06-13	88.8400	1.4387	\N	57191.30	15.8031	FINNHUB	2026-06-12 23:20:53.766258+00	\N
2823	4377	2026-06-13	367.1500	-0.0871	\N	62987.27	235.3565	FINNHUB	2026-06-12 23:20:57.026706+00	\N
2747	4301	2026-06-13	240.1300	0.4266	\N	77603.36	33.5110	FINNHUB	2026-06-12 23:16:37.892347+00	\N
2748	4302	2026-06-13	47.1300	1.0940	\N	75256.55	29.8519	FINNHUB	2026-06-12 23:16:41.041359+00	\N
2749	4303	2026-06-13	133.8800	-0.0224	\N	77184.16	67.4687	FINNHUB	2026-06-12 23:16:44.213116+00	\N
2750	4304	2026-06-13	385.0300	5.8997	\N	75256.58	160.5135	FINNHUB	2026-06-12 23:16:47.459067+00	\N
2751	4305	2026-06-13	61.6000	-0.3236	\N	101945.54	16.1077	FINNHUB	2026-06-12 23:16:50.804525+00	\N
2752	4306	2026-06-13	64.1000	-5.4851	\N	70307.17	48.7905	FINNHUB	2026-06-12 23:16:54.352186+00	\N
2753	4307	2026-06-13	179.4500	0.7580	\N	71899.68	17.4387	FINNHUB	2026-06-12 23:16:57.56732+00	\N
2754	4308	2026-06-13	136.6500	0.0879	\N	73289.68	13.3327	FINNHUB	2026-06-12 23:17:00.732067+00	\N
2755	4309	2026-06-13	118.9800	0.6003	\N	100076.86	21.2703	FINNHUB	2026-06-12 23:17:04.035996+00	\N
2756	4310	2026-06-13	1577.3200	-0.7694	\N	77416.60	113.6945	FINNHUB	2026-06-12 23:17:07.167986+00	\N
2758	4312	2026-06-13	265.4100	0.6752	\N	74102.49	35.1914	FINNHUB	2026-06-12 23:17:13.527564+00	\N
2759	4313	2026-06-13	46.9100	-0.5512	\N	69821.53	19.5853	FINNHUB	2026-06-12 23:17:17.007082+00	\N
2760	4314	2026-06-13	176.2800	-3.0790	\N	70329.32	36.3040	FINNHUB	2026-06-12 23:17:20.229041+00	\N
2761	4315	2026-06-13	69.3900	0.1154	\N	96850.00	28.1541	FINNHUB	2026-06-12 23:17:23.522416+00	\N
2762	4316	2026-06-13	89.4500	0.0671	\N	71496.91	34.2582	FINNHUB	2026-06-12 23:17:27.16508+00	\N
2763	4317	2026-06-13	31.9400	1.8495	\N	71060.94	21.4362	FINNHUB	2026-06-12 23:17:30.318003+00	\N
2764	4318	2026-06-13	313.9100	1.0885	\N	70657.27	26.4634	FINNHUB	2026-06-12 23:17:34.295261+00	\N
2765	4319	2026-06-13	129.2300	0.5837	\N	70314.70	19.2443	FINNHUB	2026-06-12 23:17:38.0932+00	\N
2766	4320	2026-06-13	106.4800	1.5740	\N	70475.08	19.1978	FINNHUB	2026-06-12 23:17:41.216549+00	\N
2767	4321	2026-06-13	335.3100	0.0418	\N	71569.64	18.1557	FINNHUB	2026-06-12 23:17:44.354825+00	\N
2768	4322	2026-06-13	1256.0500	-0.1225	\N	70148.40	33.6928	FINNHUB	2026-06-12 23:17:47.489453+00	\N
2769	4323	2026-06-13	445.9800	0.1707	\N	63410.05	144.6727	FINNHUB	2026-06-12 23:17:50.629957+00	\N
2770	4324	2026-06-13	150.5800	-2.5940	\N	65610.53	70.8537	FINNHUB	2026-06-12 23:17:54.124009+00	\N
2771	4325	2026-06-13	412.2500	0.4630	\N	68491.44	32.7710	FINNHUB	2026-06-12 23:17:57.36125+00	\N
2772	4326	2026-06-13	921.5600	3.5938	\N	71697.38	162.9856	FINNHUB	2026-06-12 23:18:00.659775+00	\N
2824	4378	2026-06-13	192.1300	0.2819	\N	53681.61	189.0198	FINNHUB	2026-06-12 23:21:00.156135+00	\N
2825	4379	2026-06-13	46.5700	0.3880	\N	53825.62	41.4171	FINNHUB	2026-06-12 23:21:03.704298+00	\N
2826	4380	2026-06-13	281.6700	0.0675	\N	54765.05	21.4876	FINNHUB	2026-06-12 23:21:06.863907+00	\N
2827	4381	2026-06-13	82.9400	-3.2092	\N	52483.80	32.7403	FINNHUB	2026-06-12 23:21:10.140136+00	\N
2828	4382	2026-06-13	28.2700	-0.7374	\N	74022.76	15.9497	FINNHUB	2026-06-12 23:21:13.37199+00	\N
2829	4383	2026-06-13	116.1000	3.0534	\N	71361.21	28.3477	FINNHUB	2026-06-12 23:21:16.562218+00	\N
2830	4384	2026-06-13	21.6300	4.5938	\N	1572123.10	31.3728	FINNHUB	2026-06-12 23:21:19.823434+00	\N
2831	4385	2026-06-13	70.8100	2.4895	\N	42575.84	16.8643	FINNHUB	2026-06-12 23:21:23.151561+00	\N
2832	4386	2026-06-13	227.1200	0.4023	\N	51848.01	33.9377	FINNHUB	2026-06-12 23:21:26.362983+00	\N
2833	4387	2026-06-13	83.0600	1.5031	\N	54156.04	12.0965	FINNHUB	2026-06-12 23:21:29.572392+00	\N
2834	4388	2026-06-13	76.1400	1.7099	\N	50067.86	43.0877	FINNHUB	2026-06-12 23:21:32.760735+00	\N
2835	4389	2026-06-13	45.3100	1.5692	\N	52427.94	23.1164	FINNHUB	2026-06-12 23:21:35.919583+00	\N
2836	4390	2026-06-13	3116.3000	1.1254	\N	50958.11	20.5632	FINNHUB	2026-06-12 23:21:39.107371+00	\N
2837	4391	2026-06-13	203.2700	0.1083	\N	50903.81	57.3887	FINNHUB	2026-06-12 23:21:42.282838+00	\N
2838	4392	2026-06-13	11.7400	1.2069	\N	4519783.50	15.3525	FINNHUB	2026-06-12 23:21:45.436689+00	\N
2839	4393	2026-06-13	111.1100	1.1102	\N	50610.23	28.0901	FINNHUB	2026-06-12 23:21:48.568319+00	\N
2840	4394	2026-06-13	245.7500	-0.8113	\N	51590.69	51.2168	FINNHUB	2026-06-12 23:21:51.975637+00	\N
2841	4395	2026-06-13	148.0200	1.1204	\N	46713.26	20.8448	FINNHUB	2026-06-12 23:21:55.100455+00	\N
2842	4396	2026-06-13	241.2800	0.4747	\N	50569.06	34.2841	FINNHUB	2026-06-12 23:21:58.665401+00	\N
2843	4397	2026-06-13	459.3400	0.3824	\N	51124.26	46.9892	FINNHUB	2026-06-12 23:22:01.803246+00	\N
2844	4398	2026-06-13	85.1100	-0.7579	\N	48885.42	44.5953	FINNHUB	2026-06-12 23:22:04.996218+00	\N
2845	4399	2026-06-13	88.9800	2.5824	\N	50321.82	26.3189	FINNHUB	2026-06-12 23:22:08.246579+00	\N
2846	4400	2026-06-13	79.2200	1.2137	\N	48755.45	23.3168	FINNHUB	2026-06-12 23:22:11.435375+00	\N
2847	4401	2026-06-13	3.2500	0.9317	\N	262235.80	16.8340	FINNHUB	2026-06-12 23:22:15.216033+00	\N
2848	4402	2026-06-13	67.9400	0.8760	\N	40264.14	45.3425	FINNHUB	2026-06-12 23:22:18.39769+00	\N
2849	4403	2026-06-13	15.9100	0.2520	\N	7978582.50	41.6067	FINNHUB	2026-06-12 23:22:21.877429+00	\N
2850	4404	2026-06-13	198.4300	-3.4733	\N	42006.94	28.7129	FINNHUB	2026-06-12 23:22:25.012874+00	\N
2851	4405	2026-06-13	108.6100	-0.9123	\N	48138.48	23.5973	FINNHUB	2026-06-12 23:22:28.4169+00	\N
2852	4406	2026-06-13	223.8500	1.2163	\N	52473.82	33.7452	FINNHUB	2026-06-12 23:22:31.717005+00	\N
2853	4407	2026-06-13	95.2400	2.4747	\N	51500.24	223.9141	FINNHUB	2026-06-12 23:22:34.894769+00	\N
2854	4408	2026-06-13	54.7300	2.4523	\N	49516.33	22.7871	FINNHUB	2026-06-12 23:22:38.194359+00	\N
2855	4409	2026-06-13	46.2100	1.5381	\N	46566.20	16.7565	FINNHUB	2026-06-12 23:22:41.42756+00	\N
2856	4410	2026-06-13	331.6100	-2.2434	\N	39090.81	49.5055	FINNHUB	2026-06-12 23:22:44.653081+00	\N
2857	4411	2026-06-13	116.7900	0.7158	\N	45758.62	79.7605	FINNHUB	2026-06-12 23:22:47.815301+00	\N
2858	4412	2026-06-13	238.1000	-0.2012	\N	45863.13	26.4159	FINNHUB	2026-06-12 23:22:50.949966+00	\N
2859	4413	2026-06-13	100.9600	2.0107	\N	44147.80	94.9169	FINNHUB	2026-06-12 23:22:54.09455+00	\N
2860	4414	2026-06-13	599.1200	0.8093	\N	43544.59	32.9957	FINNHUB	2026-06-12 23:22:57.227669+00	\N
2861	4415	2026-06-13	167.6300	1.6864	\N	46185.50	15.0687	FINNHUB	2026-06-12 23:23:00.356847+00	\N
2862	4416	2026-06-13	230.0800	0.8990	\N	44194.56	17.8925	FINNHUB	2026-06-12 23:23:03.526615+00	\N
2863	4417	2026-06-13	81.7900	0.8259	\N	33509.65	18.5456	FINNHUB	2026-06-12 23:23:07.50773+00	\N
2864	4418	2026-06-13	560.8800	0.5323	\N	44010.01	40.1832	FINNHUB	2026-06-12 23:23:10.777696+00	\N
2865	4419	2026-06-13	265.2000	1.1866	\N	44470.73	36.7527	FINNHUB	2026-06-12 23:23:13.962224+00	\N
2866	4420	2026-06-13	36.6100	-1.4005	\N	48777.24	50.4940	FINNHUB	2026-06-12 23:23:17.084985+00	\N
2867	4421	2026-06-13	214.0000	-5.5396	\N	49752.72	\N	FINNHUB	2026-06-12 23:23:20.211567+00	\N
2868	4422	2026-06-13	393.1200	1.8815	\N	61884.27	46.1550	FINNHUB	2026-06-12 23:23:23.405682+00	\N
2869	4423	2026-06-13	12.2800	1.1532	\N	372413.60	14.7977	FINNHUB	2026-06-12 23:23:26.690141+00	\N
2870	4424	2026-06-13	86.3000	3.7509	\N	42006.52	12.0917	FINNHUB	2026-06-12 23:23:29.867451+00	\N
2871	4425	2026-06-13	123.9700	3.1794	\N	43968.91	\N	FINNHUB	2026-06-12 23:23:33.062657+00	\N
2872	4426	2026-06-13	209.4600	0.7455	\N	55960.89	29.1846	FINNHUB	2026-06-12 23:23:36.260074+00	\N
2873	4427	2026-06-13	379.2200	2.8561	\N	45363.45	40.1446	FINNHUB	2026-06-12 23:23:39.438442+00	\N
2874	4428	2026-06-13	38.6700	-0.1033	\N	6306607.50	14.1004	FINNHUB	2026-06-12 23:23:42.595349+00	\N
2875	4429	2026-06-13	146.2400	-0.7533	\N	40274.37	35.3905	FINNHUB	2026-06-12 23:23:45.915937+00	\N
2876	4430	2026-06-13	154.3100	0.6785	\N	42244.46	24.3064	FINNHUB	2026-06-12 23:23:49.056032+00	\N
2877	4431	2026-06-13	23.0700	6.1666	\N	58287.73	15.1032	FINNHUB	2026-06-12 23:23:52.20412+00	\N
2878	4432	2026-06-13	31.7100	1.5370	\N	42490.27	23.1934	FINNHUB	2026-06-12 23:23:55.334026+00	\N
2879	4433	2026-06-13	99.3400	1.6890	\N	43519.54	19.4336	FINNHUB	2026-06-12 23:23:58.461036+00	\N
2880	4434	2026-06-13	134.9000	1.5660	\N	29405.44	47.2163	FINNHUB	2026-06-12 23:24:01.608575+00	\N
2881	4435	2026-06-13	81.3800	0.7927	\N	44279.15	56.8410	FINNHUB	2026-06-12 23:24:04.796589+00	\N
2882	4436	2026-06-13	115.7700	-0.2928	\N	39881.26	689.7928	FINNHUB	2026-06-12 23:24:07.956314+00	\N
2883	4437	2026-06-13	154.0900	-0.2202	\N	43793.20	13.8036	FINNHUB	2026-06-12 23:24:11.19334+00	\N
2884	4438	2026-06-13	92.1600	0.1304	\N	40223.41	37.9824	FINNHUB	2026-06-12 23:24:14.509867+00	\N
2885	4439	2026-06-13	69.5200	0.6224	\N	41376.98	51.2673	FINNHUB	2026-06-12 23:24:17.783832+00	\N
2886	4440	2026-06-13	76.6400	1.0549	\N	58644.25	17.8793	FINNHUB	2026-06-12 23:24:21.018007+00	\N
2887	4441	2026-06-13	459.1300	1.9428	\N	40487.85	10.3948	FINNHUB	2026-06-12 23:24:24.144761+00	\N
2888	4442	2026-06-13	282.8500	-2.2599	\N	38468.31	66.6445	FINNHUB	2026-06-12 23:24:27.291535+00	\N
2889	4443	2026-06-13	84.6000	0.8463	\N	41129.96	157.9340	FINNHUB	2026-06-12 23:24:30.429517+00	\N
2890	4444	2026-06-13	159.7800	-0.4052	\N	42267.05	52.7941	FINNHUB	2026-06-12 23:24:33.59389+00	\N
2891	4445	2026-06-13	92.2500	-0.9981	\N	39475.97	32.9333	FINNHUB	2026-06-12 23:24:36.793993+00	\N
2892	4446	2026-06-13	75.7400	0.5576	\N	40186.98	12.7134	FINNHUB	2026-06-12 23:24:40.09396+00	\N
2893	4447	2026-06-13	9.1300	1.1074	\N	29852.16	17.9077	FINNHUB	2026-06-12 23:24:43.381035+00	\N
2894	4448	2026-06-13	34.6300	0.2025	\N	117861.45	25.3675	FINNHUB	2026-06-12 23:24:46.685158+00	\N
2895	4449	2026-06-13	211.7500	-0.1556	\N	39142.25	\N	FINNHUB	2026-06-12 23:24:49.919167+00	\N
2896	4450	2026-06-13	79.7000	1.1678	\N	39671.37	17.5304	FINNHUB	2026-06-12 23:24:53.25658+00	\N
2897	4451	2026-06-13	156.1100	0.4117	\N	55171.13	37.4098	FINNHUB	2026-06-12 23:24:56.461119+00	\N
2898	4452	2026-06-13	441.7300	-1.0018	\N	35964.65	174.5959	FINNHUB	2026-06-12 23:24:59.732699+00	\N
2899	4453	2026-06-13	107.7400	0.8424	\N	39555.22	18.3551	FINNHUB	2026-06-12 23:25:03.228082+00	\N
2900	4454	2026-06-13	107.8000	4.3259	\N	51112704.00	8.4788	FINNHUB	2026-06-12 23:25:06.493068+00	\N
2901	4455	2026-06-13	28.5600	1.7819	\N	272236.20	17.0095	FINNHUB	2026-06-12 23:25:10.00507+00	\N
2902	4456	2026-06-13	80.2400	1.6984	\N	38387.84	35.5114	FINNHUB	2026-06-12 23:25:13.187791+00	\N
2903	4457	2026-06-13	64.7100	0.9202	\N	39798.99	39.1722	FINNHUB	2026-06-12 23:25:16.448125+00	\N
2904	4458	2026-06-13	203.3600	-4.8386	\N	40843.69	178.5743	FINNHUB	2026-06-12 23:25:19.686497+00	\N
2905	4459	2026-06-13	247.0900	-1.5774	\N	39090.81	49.5055	FINNHUB	2026-06-12 23:25:22.984693+00	\N
2906	4460	2026-06-13	282.7600	1.1483	\N	41024.21	29.9036	FINNHUB	2026-06-12 23:25:26.386566+00	\N
2907	4461	2026-06-13	854.0600	-6.4761	\N	114866.48	65.8469	FINNHUB	2026-06-12 23:25:29.707335+00	\N
2908	4462	2026-06-13	133.4100	1.1371	\N	38625.44	29.4401	FINNHUB	2026-06-12 23:25:33.028152+00	\N
2909	4463	2026-06-13	129.8400	0.2239	\N	36487.38	25.8044	FINNHUB	2026-06-12 23:25:36.246042+00	\N
2910	4464	2026-06-13	250.8100	-5.2689	\N	48834.97	103.4028	FINNHUB	2026-06-12 23:25:39.453652+00	\N
2911	4465	2026-06-13	29.1800	3.7696	\N	39720.83	12.8256	FINNHUB	2026-06-12 23:25:42.691066+00	\N
2912	4466	2026-06-13	129.3700	0.7868	\N	646375.44	22.7096	FINNHUB	2026-06-12 23:25:45.982013+00	\N
2913	4467	2026-06-13	16.9500	0.9529	\N	37305.69	12.6289	FINNHUB	2026-06-12 23:25:49.196055+00	\N
2914	4468	2026-06-13	81.4100	1.4455	\N	48922.91	22.9060	FINNHUB	2026-06-12 23:25:52.440429+00	\N
2915	4469	2026-06-13	32.2300	3.1360	\N	41271.97	28.4245	FINNHUB	2026-06-12 23:25:55.653826+00	\N
2916	4470	2026-06-13	90.8100	2.2290	\N	150675.22	145.1592	FINNHUB	2026-06-12 23:25:58.989656+00	\N
2917	4471	2026-06-13	181.6600	0.4534	\N	37128.50	33.9333	FINNHUB	2026-06-12 23:26:03.132292+00	\N
2918	4472	2026-06-13	384.8200	2.1041	\N	39516.01	48.8455	FINNHUB	2026-06-12 23:26:06.648576+00	\N
2919	4473	2026-06-13	172.5100	0.1045	\N	40007.98	478.1926	FINNHUB	2026-06-12 23:26:09.892397+00	\N
2920	4474	2026-06-13	127.2400	1.6538	\N	37624.97	138.1727	FINNHUB	2026-06-12 23:26:13.381107+00	\N
2921	4475	2026-06-13	113.4400	0.3272	\N	36950.33	22.5458	FINNHUB	2026-06-12 23:26:16.843668+00	\N
2922	4476	2026-06-13	286.4700	2.2413	\N	36356.02	32.6561	FINNHUB	2026-06-12 23:26:20.193423+00	\N
2923	4477	2026-06-13	79.1900	-0.5650	\N	37982.04	21.8791	FINNHUB	2026-06-12 23:26:23.589546+00	\N
2924	4478	2026-06-13	41.5300	0.7032	\N	36633.84	7.2413	FINNHUB	2026-06-12 23:26:26.818981+00	\N
2925	4479	2026-06-13	108.5000	1.8684	\N	37590.51	10.8455	FINNHUB	2026-06-12 23:26:29.946954+00	\N
2926	4480	2026-06-13	82.4100	-15.5289	\N	37865.43	\N	FINNHUB	2026-06-12 23:26:33.06101+00	\N
2927	4481	2026-06-13	823.0500	1.4195	\N	36507.69	27.2929	FINNHUB	2026-06-12 23:26:36.523566+00	\N
2928	4482	2026-06-13	129.6200	0.9502	\N	35419.07	8.7196	FINNHUB	2026-06-12 23:26:39.669512+00	\N
2929	4483	2026-06-13	100.6300	1.3700	\N	36011.81	22.0027	FINNHUB	2026-06-12 23:26:42.857553+00	\N
2930	4484	2026-06-13	355.5300	-1.1703	\N	35321.38	78.6233	FINNHUB	2026-06-12 23:26:46.199926+00	\N
2931	4485	2026-06-13	13.0700	-2.6806	\N	37999.24	158.7383	FINNHUB	2026-06-12 23:26:49.442535+00	\N
2932	4486	2026-06-13	130.8000	0.2068	\N	33955.09	40.0887	FINNHUB	2026-06-12 23:26:53.067514+00	\N
2933	4487	2026-06-13	26.4400	-2.3273	\N	5556617.50	\N	FINNHUB	2026-06-12 23:26:56.317337+00	\N
2934	4488	2026-06-13	60.3300	1.5828	\N	26154.75	12.0324	FINNHUB	2026-06-12 23:26:59.719769+00	\N
2935	4489	2026-06-13	46.0900	0.1957	\N	1124829.80	28.8248	FINNHUB	2026-06-12 23:27:03.159744+00	\N
2936	4490	2026-06-13	577.3300	2.0847	\N	34474.75	13.6049	FINNHUB	2026-06-12 23:27:09.401962+00	\N
2937	4491	2026-06-13	588.7300	1.1963	\N	34575.01	36.6997	FINNHUB	2026-06-12 23:27:12.539793+00	\N
2938	4492	2026-06-13	115.5200	2.5841	\N	33110.06	9.0366	FINNHUB	2026-06-12 23:27:15.714385+00	\N
2939	4493	2026-06-13	204.0800	-1.2293	\N	30382.09	292.2591	FINNHUB	2026-06-12 23:27:19.038551+00	\N
2940	4494	2026-06-13	18.1400	0.3874	\N	34694.56	21.3900	FINNHUB	2026-06-12 23:27:22.340982+00	\N
2941	4495	2026-06-13	15.5300	1.7693	\N	26695.48	\N	FINNHUB	2026-06-12 23:27:25.594832+00	\N
2942	4496	2026-06-13	114.0800	-10.9654	\N	32615.61	\N	FINNHUB	2026-06-12 23:27:29.283479+00	\N
2943	4497	2026-06-13	51.9400	1.4453	\N	32431.04	9.8745	FINNHUB	2026-06-12 23:27:32.429093+00	\N
2944	4498	2026-06-13	334.9700	0.6793	\N	33804.29	19.7213	FINNHUB	2026-06-12 23:27:35.570351+00	\N
2945	4499	2026-06-13	3.5000	1.7442	\N	174797.20	7.3515	FINNHUB	2026-06-12 23:27:39.008824+00	\N
2946	4500	2026-06-13	17.5200	1.8013	\N	34886.92	15.8074	FINNHUB	2026-06-12 23:27:42.131864+00	\N
2947	4501	2026-06-13	162.1000	-6.4412	\N	33354.12	47.1407	FINNHUB	2026-06-12 23:27:45.301909+00	\N
2948	4502	2026-06-13	79.5700	-2.2482	\N	34125.16	12.9115	FINNHUB	2026-06-12 23:27:48.498639+00	\N
2949	4503	2026-06-13	50.6700	0.1186	\N	33409.58	18.1377	FINNHUB	2026-06-12 23:27:51.83157+00	\N
2950	4504	2026-06-13	74.8500	1.2855	\N	33837.65	35.4321	FINNHUB	2026-06-12 23:27:55.058904+00	\N
2951	4505	2026-06-13	36.5000	1.6713	\N	506538.97	8.7235	FINNHUB	2026-06-12 23:27:58.212827+00	\N
2952	4506	2026-06-13	102.2900	0.7386	\N	34083.57	16.0847	FINNHUB	2026-06-12 23:28:01.377082+00	\N
2953	4507	2026-06-13	67.3000	2.6228	\N	44875390.00	8.7891	FINNHUB	2026-06-12 23:28:04.544727+00	\N
2954	4508	2026-06-13	39.6000	-0.4024	\N	33019.09	21.4410	FINNHUB	2026-06-12 23:28:07.709547+00	\N
2955	4509	2026-06-13	161.6100	0.7104	\N	31795.18	24.9179	FINNHUB	2026-06-12 23:28:11.585365+00	\N
2956	4510	2026-06-13	66.8500	0.5112	\N	26813.90	40.9401	FINNHUB	2026-06-12 23:28:14.964377+00	\N
2957	4511	2026-06-13	231.8800	1.7821	\N	33847.85	11.5482	FINNHUB	2026-06-12 23:28:18.116161+00	\N
2958	4512	2026-06-13	82.3700	1.1419	\N	33659.14	\N	FINNHUB	2026-06-12 23:28:21.238067+00	\N
2959	4513	2026-06-13	67.6200	3.1422	\N	43678.01	13.0889	FINNHUB	2026-06-12 23:28:24.426426+00	\N
2960	4514	2026-06-13	54.8700	-0.7596	\N	31840.53	38.4878	FINNHUB	2026-06-12 23:28:27.576189+00	\N
2961	4515	2026-06-13	150.6000	0.2263	\N	31815.90	33.6997	FINNHUB	2026-06-12 23:28:30.720883+00	\N
2962	4516	2026-06-13	26.5800	2.0737	\N	23159.12	7.7780	FINNHUB	2026-06-12 23:28:33.857831+00	\N
2963	4517	2026-06-13	13.0800	2.5882	\N	33017.12	11.8214	FINNHUB	2026-06-12 23:28:37.09198+00	\N
2964	4518	2026-06-13	91.6600	0.5816	\N	31839.87	6.5353	FINNHUB	2026-06-12 23:28:40.464073+00	\N
2965	4519	2026-06-13	153.8700	3.1093	\N	31725.77	\N	FINNHUB	2026-06-12 23:28:43.698619+00	\N
2966	4520	2026-06-13	62.9200	1.5166	\N	29115.38	17.1355	FINNHUB	2026-06-12 23:28:47.311862+00	\N
2967	4521	2026-06-13	174.3400	2.1025	\N	32195.45	17.2131	FINNHUB	2026-06-12 23:28:50.497443+00	\N
2968	4522	2026-06-13	25.5800	2.8962	\N	41399.45	10.3307	FINNHUB	2026-06-12 23:28:53.701558+00	\N
2969	4523	2026-06-13	63.1900	-3.8058	\N	31797.52	12.5583	FINNHUB	2026-06-12 23:28:56.838295+00	\N
2970	4524	2026-06-13	16.5800	1.9680	\N	116565830.00	12.9111	FINNHUB	2026-06-12 23:29:00.041439+00	\N
2971	4525	2026-06-13	212.0700	-3.2660	\N	30371.69	\N	FINNHUB	2026-06-12 23:29:03.313022+00	\N
2972	4526	2026-06-13	65.1900	2.5968	\N	32274.57	\N	FINNHUB	2026-06-12 23:29:06.585084+00	\N
2973	4527	2026-06-13	181.4600	0.2209	\N	30058.69	21.7030	FINNHUB	2026-06-12 23:29:09.725535+00	\N
2974	4528	2026-06-13	28.5200	1.5308	\N	31047.64	10.0016	FINNHUB	2026-06-12 23:29:12.86284+00	\N
2975	4529	2026-06-13	147.4200	1.1180	\N	30603.04	24.2113	FINNHUB	2026-06-12 23:29:16.441166+00	\N
2976	4530	2026-06-13	109.0000	0.6928	\N	30174.23	19.7994	FINNHUB	2026-06-12 23:29:19.573828+00	\N
2977	4531	2026-06-13	89.6800	1.8859	\N	32268.49	\N	FINNHUB	2026-06-12 23:29:22.712587+00	\N
2978	4532	2026-06-13	64.8400	1.9497	\N	31133.49	34.6534	FINNHUB	2026-06-12 23:29:25.841965+00	\N
2979	4533	2026-06-13	46.4700	-1.9413	\N	242604.58	6.2890	FINNHUB	2026-06-12 23:29:28.99231+00	\N
2980	4534	2026-06-13	264.4800	1.6176	\N	209632.48	66.2766	FINNHUB	2026-06-12 23:29:32.149705+00	\N
2981	4535	2026-06-13	267.3100	-1.4235	\N	28980.17	17.4022	FINNHUB	2026-06-12 23:29:35.511424+00	\N
2982	4536	2026-06-13	43.3100	-0.4139	\N	31137.92	\N	FINNHUB	2026-06-12 23:29:38.734844+00	\N
2983	4537	2026-06-13	93.6800	1.4731	\N	27552.10	13.3023	FINNHUB	2026-06-12 23:29:41.850207+00	\N
2984	4538	2026-06-13	53.1700	1.6052	\N	28924.67	25.0213	FINNHUB	2026-06-12 23:29:44.990542+00	\N
2985	4539	2026-06-13	150.6500	1.0260	\N	31216.66	67.5685	FINNHUB	2026-06-12 23:29:48.107129+00	\N
2986	4540	2026-06-13	154.4000	2.6459	\N	30267.28	14.0975	FINNHUB	2026-06-12 23:29:51.248549+00	\N
2987	4541	2026-06-13	294.9100	-0.3346	\N	31062.29	25.1496	FINNHUB	2026-06-12 23:29:54.563239+00	\N
2988	4542	2026-06-13	65.1800	1.0386	\N	29345.07	15.3639	FINNHUB	2026-06-12 23:29:57.677134+00	\N
2989	4543	2026-06-13	53.7800	1.3570	\N	28529.09	8.9153	FINNHUB	2026-06-12 23:30:00.802151+00	\N
2990	4544	2026-06-13	217.4300	-0.5034	\N	29157.56	26.4691	FINNHUB	2026-06-12 23:30:04.006854+00	\N
2991	4545	2026-06-13	200.0500	0.0450	\N	29411.53	21.4385	FINNHUB	2026-06-12 23:30:07.202725+00	\N
2992	4546	2026-06-13	30.7500	-0.9981	\N	28468.70	18.3291	FINNHUB	2026-06-12 23:30:10.352621+00	\N
2993	4547	2026-06-13	56.9100	0.8685	\N	39998.34	22.1966	FINNHUB	2026-06-12 23:30:13.568965+00	\N
2994	4548	2026-06-13	48.3500	-0.6371	\N	39479.44	23.3606	FINNHUB	2026-06-12 23:30:16.808566+00	\N
2995	4549	2026-06-13	169.9600	1.0284	\N	28262.87	20.9948	FINNHUB	2026-06-12 23:30:20.020929+00	\N
2996	4550	2026-06-13	362.9700	1.2469	\N	28554.94	63.4584	FINNHUB	2026-06-12 23:30:23.219327+00	\N
2997	4551	2026-06-13	194.7800	1.2423	\N	28115.56	18.5024	FINNHUB	2026-06-12 23:30:26.403082+00	\N
2998	4552	2026-06-13	147.4200	1.3962	\N	29294.47	44.1980	FINNHUB	2026-06-12 23:30:29.555894+00	\N
2999	4553	2026-06-13	74.0000	1.0929	\N	28645.86	48.8004	FINNHUB	2026-06-12 23:30:32.723455+00	\N
3000	4554	2026-06-13	72.9500	0.8432	\N	27855.23	7.3711	FINNHUB	2026-06-12 23:30:35.858245+00	\N
3001	4555	2026-06-13	342.8000	-3.2759	\N	28516.34	\N	FINNHUB	2026-06-12 23:30:39.076305+00	\N
3002	4556	2026-06-13	895.1400	-2.3072	\N	32993.88	46.1809	FINNHUB	2026-06-12 23:30:42.234095+00	\N
3003	4557	2026-06-13	75.3700	0.1595	\N	28751.40	30.9022	FINNHUB	2026-06-12 23:30:45.456905+00	\N
3004	4558	2026-06-13	10.2800	-0.0972	\N	118592.19	12.4284	FINNHUB	2026-06-12 23:30:48.608544+00	\N
3005	4559	2026-06-13	65.8500	-3.5871	\N	27153.62	15.8700	FINNHUB	2026-06-12 23:30:51.73732+00	\N
3006	4560	2026-06-13	159.5400	-1.2442	\N	26725.42	28.3814	FINNHUB	2026-06-12 23:30:55.244051+00	\N
3007	4561	2026-06-13	42.9000	0.8226	\N	28001.73	26.1454	FINNHUB	2026-06-12 23:30:58.391643+00	\N
3008	4562	2026-06-13	626.0200	0.3671	\N	28892.47	30.9673	FINNHUB	2026-06-12 23:31:02.491719+00	\N
3009	4563	2026-06-13	224.8900	0.1024	\N	26770.82	17.9911	FINNHUB	2026-06-12 23:31:05.805648+00	\N
3010	4564	2026-06-13	125.4700	1.4309	\N	26197.28	109.6121	FINNHUB	2026-06-12 23:31:09.059198+00	\N
3011	4565	2026-06-13	16.8200	-2.4928	\N	30964.86	\N	FINNHUB	2026-06-12 23:31:12.207618+00	\N
3012	4566	2026-06-13	758.0000	0.1017	\N	27926.60	54.6426	FINNHUB	2026-06-12 23:31:15.426503+00	\N
3013	4567	2026-06-13	187.0300	1.4483	\N	26155.53	22.9347	FINNHUB	2026-06-12 23:31:18.555712+00	\N
3014	4568	2026-06-13	858.9900	2.4375	\N	26447.15	76.2946	FINNHUB	2026-06-12 23:31:21.974459+00	\N
3015	4569	2026-06-13	67.6500	1.7140	\N	28464.18	14.4122	FINNHUB	2026-06-12 23:31:25.090791+00	\N
3016	4570	2026-06-13	70.7500	0.8841	\N	26910.01	18.1702	FINNHUB	2026-06-12 23:31:28.222365+00	\N
3017	4571	2026-06-13	35.8500	1.0998	\N	26896.53	22.0644	FINNHUB	2026-06-12 23:31:31.352074+00	\N
3018	4572	2026-06-13	378.9100	2.5328	\N	26604.60	52.8261	FINNHUB	2026-06-12 23:31:34.48159+00	\N
3019	4573	2026-06-13	279.8900	0.1145	\N	25469.99	30.2890	FINNHUB	2026-06-12 23:31:39.105542+00	\N
3020	4574	2026-06-13	289.3600	0.0761	\N	27115.74	43.5878	FINNHUB	2026-06-12 23:31:42.241086+00	\N
3021	4575	2026-06-13	47.0300	0.7714	\N	27024.31	25.3749	FINNHUB	2026-06-12 23:31:45.377152+00	\N
2522	4076	2026-06-13	205.1900	0.1562	\N	4967050.00	31.1193	FINNHUB	2026-06-12 23:03:58.66352+00	\N
2533	4087	2026-06-13	981.6100	-1.4319	\N	1126977.20	46.7412	FINNHUB	2026-06-12 23:04:33.459298+00	\N
2563	4117	2026-06-13	119.0500	-1.4160	\N	297663.25	33.3143	FINNHUB	2026-06-12 23:06:11.196971+00	\N
2590	4144	2026-06-13	43.8800	-0.1820	\N	1255652.10	10.2959	FINNHUB	2026-06-12 23:07:38.093578+00	\N
2609	4163	2026-06-13	219.0500	-1.1641	\N	172748.58	76.1678	FINNHUB	2026-06-12 23:08:39.377644+00	\N
2636	4190	2026-06-13	62.3200	1.5149	\N	99054.99	12.7582	FINNHUB	2026-06-12 23:10:10.539938+00	\N
2661	4215	2026-06-13	170.2800	1.6476	\N	105081.85	13.7393	FINNHUB	2026-06-12 23:11:35.207942+00	\N
2668	4222	2026-06-13	94.0000	0.7827	\N	105611.20	24.2061	FINNHUB	2026-06-12 23:11:57.766376+00	\N
2691	4245	2026-06-13	237.6600	1.5902	\N	95303.34	13.2091	FINNHUB	2026-06-12 23:13:15.023947+00	\N
2717	4271	2026-06-13	1589.6000	-1.2671	\N	80105.60	41.7217	FINNHUB	2026-06-12 23:14:39.721662+00	\N
2742	4296	2026-06-13	91.0200	1.0211	\N	74062.27	28.4428	FINNHUB	2026-06-12 23:16:21.599162+00	\N
2746	4300	2026-06-13	81.5000	0.8040	\N	72899.63	28.7233	FINNHUB	2026-06-12 23:16:34.658311+00	\N
2757	4311	2026-06-13	257.4300	1.1712	\N	73744.70	23.5305	FINNHUB	2026-06-12 23:17:10.351627+00	\N
3274	4076	2026-06-14	205.1900	0.0000	\N	4965598.00	31.1102	FINNHUB	2026-06-14 00:42:10.945893+00	0.0439
3275	4077	2026-06-14	291.1300	0.0000	\N	4275930.00	34.8842	FINNHUB	2026-06-14 00:42:13.336971+00	-5.2743
3276	4078	2026-06-14	359.6800	0.0000	\N	4357883.00	27.2014	FINNHUB	2026-06-14 00:42:15.687962+00	-2.4014
3277	4079	2026-06-14	390.7400	0.0000	\N	2902586.50	23.1806	FINNHUB	2026-06-14 00:42:18.062433+00	-6.2232
3278	4080	2026-06-14	238.5500	0.0000	\N	2566108.50	28.2617	FINNHUB	2026-06-14 00:42:20.423168+00	-3.0403
3279	4081	2026-06-14	423.9300	0.0000	\N	58347830.00	30.2509	FINNHUB	2026-06-14 00:42:22.841475+00	2.1100
3280	4082	2026-06-14	382.0700	0.0000	\N	1817728.60	62.0025	FINNHUB	2026-06-14 00:42:25.203287+00	-0.9489
3281	4083	2026-06-14	566.9800	0.0000	\N	1439235.10	20.3895	FINNHUB	2026-06-14 00:42:27.577718+00	-4.3879
3282	4084	2026-06-14	406.4300	0.0000	\N	1526438.80	395.2457	FINNHUB	2026-06-14 00:42:29.927933+00	3.9463
3283	4085	2026-06-14	489.2500	0.0000	\N	1054664.90	14.5529	FINNHUB	2026-06-14 00:42:32.354302+00	0.2294
3284	4086	2026-06-14	1133.0000	0.0000	\N	1066993.00	42.2125	FINNHUB	2026-06-14 00:42:34.708879+00	0.1396
3285	4087	2026-06-14	981.6100	0.0000	\N	1106995.00	45.9124	FINNHUB	2026-06-14 00:42:37.089749+00	13.6110
3286	4088	2026-06-14	121.0400	0.0000	\N	963245.94	42.3666	FINNHUB	2026-06-14 00:42:39.447091+00	1.8170
3287	4089	2026-06-14	320.7200	0.0000	\N	859372.90	14.5906	FINNHUB	2026-06-14 00:42:41.80863+00	2.6731
3288	4090	2026-06-14	511.5700	0.0000	\N	834166.40	166.5335	FINNHUB	2026-06-14 00:42:44.155294+00	9.6895
3289	4091	2026-06-14	1863.5500	0.0000	\N	602008.06	58.9453	FINNHUB	2026-06-14 00:42:46.538247+00	\N
3290	4092	2026-06-14	147.0100	0.0000	\N	609348.70	24.0716	FINNHUB	2026-06-14 00:42:48.903818+00	\N
3291	4093	2026-06-14	184.1300	0.0000	\N	529566.40	32.6691	FINNHUB	2026-06-14 00:42:51.258921+00	\N
3292	4094	2026-06-14	322.3900	0.0000	\N	607423.06	27.3171	FINNHUB	2026-06-14 00:42:53.61178+00	\N
3293	4095	2026-06-14	240.8700	0.0000	\N	579826.40	27.5583	FINNHUB	2026-06-14 00:42:55.965761+00	\N
3294	4096	2026-06-14	124.5700	0.0000	\N	626088.80	\N	FINNHUB	2026-06-14 00:42:58.343217+00	\N
3295	4097	2026-06-14	121.1000	0.0000	\N	477307.75	39.9153	FINNHUB	2026-06-14 00:43:00.71574+00	\N
3296	4098	2026-06-14	489.9800	0.0000	\N	432938.44	27.8059	FINNHUB	2026-06-14 00:43:03.065449+00	\N
3297	4099	2026-06-14	982.3500	0.0000	\N	435651.40	49.2930	FINNHUB	2026-06-14 00:43:05.418173+00	\N
3298	4100	2026-06-14	910.5700	0.0000	\N	419442.25	44.4796	FINNHUB	2026-06-14 00:43:07.769991+00	\N
3299	4101	2026-06-14	227.7300	0.0000	\N	402351.75	110.6882	FINNHUB	2026-06-14 00:43:10.112689+00	\N
3300	4102	2026-06-14	56.0200	0.0000	\N	397551.00	12.5422	FINNHUB	2026-06-14 00:43:12.473094+00	\N
3301	4103	2026-06-14	366.8100	0.0000	\N	458721.94	68.3822	FINNHUB	2026-06-14 00:43:14.893019+00	\N
3302	4104	2026-06-14	187.2200	0.0000	\N	372866.94	33.8693	FINNHUB	2026-06-14 00:43:17.245426+00	\N
3303	4105	2026-06-14	380.8100	0.0000	\N	364132.72	402.8017	FINNHUB	2026-06-14 00:43:19.585293+00	\N
3304	4106	2026-06-14	408.5200	0.0000	\N	368208.97	30.5720	FINNHUB	2026-06-14 00:43:21.94998+00	\N
3305	4107	2026-06-14	567.2500	0.0000	\N	450373.50	52.9353	FINNHUB	2026-06-14 00:43:24.297422+00	\N
3306	4108	2026-06-14	80.3400	0.0000	\N	338295.53	25.2957	FINNHUB	2026-06-14 00:43:26.645902+00	\N
3307	4109	2026-06-14	335.3000	0.0000	\N	349831.00	40.5366	FINNHUB	2026-06-14 00:43:28.995428+00	\N
3308	4110	2026-06-14	82.6200	0.0000	\N	355471.10	25.9449	FINNHUB	2026-06-14 00:43:31.350852+00	\N
3309	4111	2026-06-14	149.6100	0.0000	\N	348381.72	20.9666	FINNHUB	2026-06-14 00:43:33.701057+00	\N
3310	4112	2026-06-14	214.0400	0.0000	\N	337602.06	18.6387	FINNHUB	2026-06-14 00:43:36.07614+00	\N
3311	4113	2026-06-14	127.9900	0.0000	\N	306832.00	134.4853	FINNHUB	2026-06-14 00:43:38.432476+00	\N
3312	4114	2026-06-14	1062.7500	0.0000	\N	313519.12	17.3522	FINNHUB	2026-06-14 00:43:40.791412+00	\N
3313	4115	2026-06-14	92.6700	0.0000	\N	227132.36	13.6514	FINNHUB	2026-06-14 00:43:43.159475+00	\N
3314	4116	2026-06-14	328.3900	0.0000	\N	327443.16	23.3688	FINNHUB	2026-06-14 00:43:45.51487+00	\N
3315	4117	2026-06-14	119.0500	0.0000	\N	294032.60	32.9080	FINNHUB	2026-06-14 00:43:47.864718+00	\N
3316	4118	2026-06-14	178.7500	0.0000	\N	210576.08	27.1741	FINNHUB	2026-06-14 00:43:50.233252+00	\N
3317	4119	2026-06-14	184.3000	0.0000	\N	287242.40	25.8870	FINNHUB	2026-06-14 00:43:52.573315+00	\N
3318	4120	2026-06-14	112.8200	0.0000	\N	262964.62	16.7916	FINNHUB	2026-06-14 00:43:54.912363+00	\N
3319	4121	2026-06-14	153.0700	0.0000	\N	221884.06	20.5652	FINNHUB	2026-06-14 00:43:57.290886+00	\N
3320	4122	2026-06-14	199.5400	0.0000	\N	388159.78	17.5336	FINNHUB	2026-06-14 00:43:59.658266+00	\N
3321	4123	2026-06-14	272.2400	0.0000	\N	255874.38	23.7978	FINNHUB	2026-06-14 00:44:02.006209+00	\N
3322	4124	2026-06-14	301.1200	0.0000	\N	270889.12	50.4731	FINNHUB	2026-06-14 00:44:04.349874+00	\N
3323	4125	2026-06-14	395.5700	0.0000	\N	256372.08	30.4878	FINNHUB	2026-06-14 00:44:06.682848+00	\N
3324	4126	2026-06-14	254.5400	0.0000	\N	31502.65	6.7449	FINNHUB	2026-06-14 00:44:09.032082+00	\N
3325	4127	2026-06-14	940.6600	0.0000	\N	252774.16	26.9655	FINNHUB	2026-06-14 00:44:11.370431+00	\N
3326	4128	2026-06-14	83.7300	0.0000	\N	256229.66	11.8095	FINNHUB	2026-06-14 00:44:13.727464+00	\N
3327	4129	2026-06-14	183.5300	0.0000	\N	247156.80	34.0624	FINNHUB	2026-06-14 00:44:16.083008+00	\N
3328	4130	2026-06-14	85.6600	0.0000	\N	181913.58	13.0079	FINNHUB	2026-06-14 00:44:18.449805+00	\N
3329	4131	2026-06-14	523.5700	0.0000	\N	242203.23	34.1998	FINNHUB	2026-06-14 00:44:20.840075+00	\N
3330	4132	2026-06-14	174.9500	0.0000	\N	32533296.00	8.4544	FINNHUB	2026-06-14 00:44:23.209068+00	\N
3331	4133	2026-06-14	1980.1000	0.0000	\N	293232.56	65.0616	FINNHUB	2026-06-14 00:44:25.541414+00	\N
3332	4134	2026-06-14	279.7000	0.0000	\N	244681.55	96.8384	FINNHUB	2026-06-14 00:44:27.900244+00	\N
3333	4135	2026-06-14	211.7200	0.0000	\N	223152.89	22.4885	FINNHUB	2026-06-14 00:44:30.260631+00	\N
3334	4136	2026-06-14	20.1600	0.0000	\N	35122664.00	14.4703	FINNHUB	2026-06-14 00:44:32.688844+00	\N
3335	4137	2026-06-14	139.8300	0.0000	\N	239795.53	14.9629	FINNHUB	2026-06-14 00:44:35.037641+00	\N
3336	4138	2026-06-14	279.6200	0.0000	\N	227890.30	270.3967	FINNHUB	2026-06-14 00:44:37.390307+00	\N
3337	4139	2026-06-14	90.8200	0.0000	\N	308905.94	21.2498	FINNHUB	2026-06-14 00:44:39.761666+00	\N
3338	4140	2026-06-14	164.1800	0.0000	\N	163341.48	22.3358	FINNHUB	2026-06-14 00:44:42.131857+00	\N
3339	4141	2026-06-14	325.4400	0.0000	\N	222056.30	19.7911	FINNHUB	2026-06-14 00:44:44.490123+00	\N
3340	4142	2026-06-14	284.8100	0.0000	\N	202359.17	23.3213	FINNHUB	2026-06-14 00:44:46.836694+00	\N
3341	4143	2026-06-14	88.0200	0.0000	\N	173677.86	13.3170	FINNHUB	2026-06-14 00:44:49.199209+00	\N
3342	4144	2026-06-14	43.8800	0.0000	\N	1255652.10	10.2959	FINNHUB	2026-06-14 00:44:51.979889+00	\N
3343	4145	2026-06-14	417.7900	0.0000	\N	203500.10	61.4167	FINNHUB	2026-06-14 00:44:54.328832+00	\N
3344	4146	2026-06-14	163.2400	0.0000	\N	205552.23	55.2485	FINNHUB	2026-06-14 00:44:56.672114+00	\N
3345	4147	2026-06-14	144.2700	0.0000	\N	197183.67	22.5791	FINNHUB	2026-06-14 00:44:59.032519+00	\N
3346	4148	2026-06-14	189.1000	0.0000	\N	204644.92	19.4105	FINNHUB	2026-06-14 00:45:01.383801+00	\N
3347	4149	2026-06-14	931.0400	0.0000	\N	208766.16	87.7906	FINNHUB	2026-06-14 00:45:03.73067+00	\N
3348	4150	2026-06-14	48.1100	0.0000	\N	200886.12	11.5851	FINNHUB	2026-06-14 00:45:06.07903+00	\N
3349	4151	2026-06-14	355.2000	0.0000	\N	191704.38	24.5775	FINNHUB	2026-06-14 00:45:08.424086+00	\N
3350	4152	2026-06-14	496.7700	0.0000	\N	166884.90	42.1113	FINNHUB	2026-06-14 00:45:10.764033+00	\N
3351	4153	2026-06-14	117.3300	0.0000	\N	274070.03	18.3816	FINNHUB	2026-06-14 00:45:13.154981+00	\N
3352	4154	2026-06-14	85.9900	0.0000	\N	179318.52	21.9135	FINNHUB	2026-06-14 00:45:15.503513+00	\N
3353	4155	2026-06-14	168.4100	0.0000	\N	186043.28	32.1318	FINNHUB	2026-06-14 00:45:17.864058+00	\N
3354	4156	2026-06-14	12.8700	0.0000	\N	153663.94	9.5124	FINNHUB	2026-06-14 00:45:20.22478+00	\N
3355	4157	2026-06-14	562.9250	0.0000	\N	194030.19	29.8004	FINNHUB	2026-06-14 00:45:22.58907+00	\N
3356	4158	2026-06-14	105.3500	0.0000	\N	130344.86	17.5345	FINNHUB	2026-06-14 00:45:24.955909+00	\N
3357	4159	2026-06-14	469.3400	0.0000	\N	174416.81	25.4772	FINNHUB	2026-06-14 00:45:27.336607+00	\N
3358	4160	2026-06-14	100.0400	0.0000	\N	173720.60	15.4776	FINNHUB	2026-06-14 00:45:29.679798+00	\N
3359	4161	2026-06-14	682.8000	0.0000	\N	173816.86	\N	FINNHUB	2026-06-14 00:45:32.011834+00	\N
3360	4162	2026-06-14	153.8000	0.0000	\N	189210.08	42.3715	FINNHUB	2026-06-14 00:45:34.36005+00	\N
3361	4163	2026-06-14	219.0500	0.0000	\N	172677.62	76.1365	FINNHUB	2026-06-14 00:45:36.70653+00	\N
3362	4164	2026-06-14	1032.0000	0.0000	\N	168051.81	26.8668	FINNHUB	2026-06-14 00:45:39.048201+00	\N
3363	4165	2026-06-14	272.7000	0.0000	\N	156899.55	21.7523	FINNHUB	2026-06-14 00:45:41.40024+00	\N
3364	4166	2026-06-14	125.5900	0.0000	\N	155928.75	16.9175	FINNHUB	2026-06-14 00:45:43.780217+00	\N
3365	4167	2026-06-14	88.1800	0.0000	\N	153593.02	24.4731	FINNHUB	2026-06-14 00:45:46.141129+00	\N
3366	4168	2026-06-14	23.5800	0.0000	\N	163841.83	7.6451	FINNHUB	2026-06-14 00:45:48.49455+00	\N
3367	4169	2026-06-14	577.4800	0.0000	\N	155883.47	32.5911	FINNHUB	2026-06-14 00:45:50.845632+00	\N
3368	4170	2026-06-14	91.1000	0.0000	\N	158435.23	16.8155	FINNHUB	2026-06-14 00:45:53.1802+00	\N
3369	4171	2026-06-14	391.3900	0.0000	\N	151976.73	38.0799	FINNHUB	2026-06-14 00:45:55.515322+00	\N
3370	4172	2026-06-14	179.2000	0.0000	\N	154226.30	85.2079	FINNHUB	2026-06-14 00:45:57.851351+00	\N
3371	4173	2026-06-14	82.9100	0.0000	\N	141010.94	22.4890	FINNHUB	2026-06-14 00:46:00.199778+00	\N
3372	4174	2026-06-14	165.8900	0.0000	\N	135863.90	16.9343	FINNHUB	2026-06-14 00:46:02.530447+00	\N
3373	4175	2026-06-14	411.0600	0.0000	\N	145582.17	48.8678	FINNHUB	2026-06-14 00:46:04.865204+00	\N
3374	4176	2026-06-14	26.2100	0.0000	\N	149382.42	19.9416	FINNHUB	2026-06-14 00:46:07.202652+00	\N
3375	4177	2026-06-14	24.4000	0.0000	\N	23675664.00	14.9564	FINNHUB	2026-06-14 00:46:09.66268+00	\N
3376	4178	2026-06-14	214.2300	0.0000	\N	151228.03	107.4398	FINNHUB	2026-06-14 00:46:12.017644+00	\N
3377	4179	2026-06-14	189.7900	0.0000	\N	158346.67	31.8881	FINNHUB	2026-06-14 00:46:14.353484+00	\N
3378	4180	2026-06-14	48.9700	0.0000	\N	119376.20	16.4265	FINNHUB	2026-06-14 00:46:16.766228+00	\N
3379	4181	2026-06-14	68.8500	0.0000	\N	142767.28	16.7175	FINNHUB	2026-06-14 00:46:19.319832+00	\N
3380	4182	2026-06-14	116.9800	0.0000	\N	142516.03	19.4641	FINNHUB	2026-06-14 00:46:21.651191+00	\N
3381	4183	2026-06-14	108.2400	0.0000	\N	140458.14	105.4491	FINNHUB	2026-06-14 00:46:23.972507+00	\N
3382	4184	2026-06-14	122.7900	0.0000	\N	149989.72	49.1111	FINNHUB	2026-06-14 00:46:26.309652+00	\N
3383	4185	2026-06-14	148.7400	0.0000	\N	141605.10	38.0940	FINNHUB	2026-06-14 00:46:28.633643+00	\N
3384	4186	2026-06-14	220.3100	0.0000	\N	139600.12	30.9466	FINNHUB	2026-06-14 00:46:30.972371+00	\N
3385	4187	2026-06-14	20.5300	0.0000	\N	19963124.00	\N	FINNHUB	2026-06-14 00:46:33.423865+00	\N
3386	4188	2026-06-14	180.1000	0.0000	\N	127469.48	34.5539	FINNHUB	2026-06-14 00:46:35.773881+00	\N
3387	4189	2026-06-14	164.9400	0.0000	\N	127808.45	20.7684	FINNHUB	2026-06-14 00:46:38.102501+00	\N
3388	4190	2026-06-14	62.3200	0.0000	\N	99054.99	12.7582	FINNHUB	2026-06-14 00:46:40.465627+00	\N
3389	4191	2026-06-14	328.1400	0.0000	\N	127272.41	11.2640	FINNHUB	2026-06-14 00:46:42.797092+00	\N
3390	4192	2026-06-14	418.9100	0.0000	\N	123997.36	25.9572	FINNHUB	2026-06-14 00:46:45.131484+00	\N
3391	4193	2026-06-14	23.3400	0.0000	\N	108543.59	10.0475	FINNHUB	2026-06-14 00:46:47.470129+00	\N
3392	4194	2026-06-14	56.5000	0.0000	\N	172249.97	24.9457	FINNHUB	2026-06-14 00:46:49.831545+00	\N
3393	4195	2026-06-14	101.9600	0.0000	\N	130093.55	44.3702	FINNHUB	2026-06-14 00:46:52.184436+00	\N
3394	4196	2026-06-14	58.9200	0.0000	\N	90959.13	11.1345	FINNHUB	2026-06-14 00:46:54.519921+00	\N
3395	4197	2026-06-14	81.5600	0.0000	\N	115722.13	8.1818	FINNHUB	2026-06-14 00:46:57.001098+00	\N
3396	4198	2026-06-14	540.3300	0.0000	\N	124580.44	25.9922	FINNHUB	2026-06-14 00:46:59.331377+00	\N
3397	4199	2026-06-14	24.1700	0.0000	\N	11465064.00	15.0805	FINNHUB	2026-06-14 00:47:01.663092+00	\N
3398	4200	2026-06-14	71.9400	0.0000	\N	120131.98	14.9177	FINNHUB	2026-06-14 00:47:04.038081+00	\N
3399	4201	2026-06-14	203.1100	0.0000	\N	118684.57	10.2677	FINNHUB	2026-06-14 00:47:06.36791+00	\N
3400	4202	2026-06-14	220.7800	0.0000	\N	123792.91	18.6379	FINNHUB	2026-06-14 00:47:08.698237+00	\N
3401	4203	2026-06-14	9.6800	0.0000	\N	18030212.00	14.4400	FINNHUB	2026-06-14 00:47:11.060276+00	\N
3402	4204	2026-06-14	312.2000	0.0000	\N	119685.23	35.8661	FINNHUB	2026-06-14 00:47:13.40372+00	\N
3403	4205	2026-06-14	57.1300	0.0000	\N	116663.54	19.5197	FINNHUB	2026-06-14 00:47:15.737638+00	\N
3404	4206	2026-06-14	102.1500	0.0000	\N	105348.11	59.9591	FINNHUB	2026-06-14 00:47:18.099984+00	\N
3405	4207	2026-06-14	302.8700	0.0000	\N	116335.03	74.6503	FINNHUB	2026-06-14 00:47:20.420272+00	\N
3406	4208	2026-06-14	168.3000	0.0000	\N	164141.08	16.8679	FINNHUB	2026-06-14 00:47:22.76146+00	\N
3407	4209	2026-06-14	444.9250	0.0000	\N	112924.38	26.0296	FINNHUB	2026-06-14 00:47:25.091818+00	\N
3408	4210	2026-06-14	42.7800	0.0000	\N	84250.73	35.1875	FINNHUB	2026-06-14 00:47:27.468823+00	\N
3409	4211	2026-06-14	184.7300	0.0000	\N	113797.27	35.3079	FINNHUB	2026-06-14 00:47:29.803832+00	\N
3410	4212	2026-06-14	903.4800	0.0000	\N	113916.53	32.7330	FINNHUB	2026-06-14 00:47:32.154619+00	\N
3411	4213	2026-06-14	18.3800	0.0000	\N	570094.90	5.2991	FINNHUB	2026-06-14 00:47:34.527608+00	\N
3412	4214	2026-06-14	16.3200	0.0000	\N	570094.90	5.2991	FINNHUB	2026-06-14 00:47:37.064666+00	\N
3413	4215	2026-06-14	170.2800	0.0000	\N	104541.58	13.6687	FINNHUB	2026-06-14 00:47:39.41377+00	\N
3414	4216	2026-06-14	103.0400	0.0000	\N	117434.68	78.5149	FINNHUB	2026-06-14 00:47:41.745698+00	\N
3415	4217	2026-06-14	44.2500	0.0000	\N	92006.26	7.5236	FINNHUB	2026-06-14 00:47:44.097199+00	\N
3416	4218	2026-06-14	1055.8500	0.0000	\N	104132.42	73.2295	FINNHUB	2026-06-14 00:47:46.424866+00	\N
3417	4219	2026-06-14	100.2300	0.0000	\N	107000.81	12.6538	FINNHUB	2026-06-14 00:47:48.758657+00	\N
3418	4220	2026-06-14	146.3000	0.0000	\N	107186.45	54.8409	FINNHUB	2026-06-14 00:47:51.084073+00	\N
3419	4221	2026-06-14	80.2000	0.0000	\N	102967.58	21.4426	FINNHUB	2026-06-14 00:47:53.420947+00	\N
3420	4222	2026-06-14	94.0000	0.0000	\N	105966.31	24.2875	FINNHUB	2026-06-14 00:47:55.762649+00	\N
3421	4223	2026-06-14	49.2000	0.0000	\N	105966.31	24.2875	FINNHUB	2026-06-14 00:47:58.139421+00	\N
3422	4224	2026-06-14	707.7400	0.0000	\N	106203.57	96.1340	FINNHUB	2026-06-14 00:48:00.477676+00	\N
3423	4225	2026-06-14	384.9600	0.0000	\N	106178.13	90.6754	FINNHUB	2026-06-14 00:48:02.819026+00	\N
3424	4226	2026-06-14	402.5400	0.0000	\N	106145.23	41.0779	FINNHUB	2026-06-14 00:48:05.152321+00	\N
3425	4227	2026-06-14	53.0400	0.0000	\N	78673.27	13.4969	FINNHUB	2026-06-14 00:48:07.513141+00	\N
3426	4228	2026-06-14	482.0000	0.0000	\N	99211.28	31.6721	FINNHUB	2026-06-14 00:48:09.843155+00	\N
3427	4229	2026-06-14	204.0200	0.0000	\N	82464.89	11.4407	FINNHUB	2026-06-14 00:48:12.177321+00	\N
3428	4230	2026-06-14	458.2500	0.0000	\N	101298.68	34.9535	FINNHUB	2026-06-14 00:48:14.531585+00	\N
3429	4231	2026-06-14	264.6700	0.0000	\N	105896.45	60.7204	FINNHUB	2026-06-14 00:48:16.893821+00	\N
3430	4232	2026-06-14	113.4600	0.0000	\N	144606.84	14.7287	FINNHUB	2026-06-14 00:48:19.245553+00	\N
3431	4233	2026-06-14	45.2100	0.0000	\N	100980.86	75.5845	FINNHUB	2026-06-14 00:48:21.588373+00	\N
3432	4234	2026-06-14	83.9900	0.0000	\N	142074.20	14.8800	FINNHUB	2026-06-14 00:48:23.944811+00	\N
3433	4235	2026-06-14	143.9800	0.0000	\N	98824.86	\N	FINNHUB	2026-06-14 00:48:26.263682+00	\N
3434	4236	2026-06-14	124.9700	0.0000	\N	97426.14	18.9582	FINNHUB	2026-06-14 00:48:28.599302+00	\N
3435	4237	2026-06-14	45.3000	0.0000	\N	132500.94	13.6458	FINNHUB	2026-06-14 00:48:30.951381+00	\N
3436	4238	2026-06-14	27.7900	0.0000	\N	9448381.00	17.4300	FINNHUB	2026-06-14 00:48:33.289338+00	\N
3437	4239	2026-06-14	360.2200	0.0000	\N	97414.35	22.4405	FINNHUB	2026-06-14 00:48:35.628094+00	\N
3438	4240	2026-06-14	36.1800	0.0000	\N	925749.06	17.6194	FINNHUB	2026-06-14 00:48:38.102401+00	\N
3439	4241	2026-06-14	269.5300	0.0000	\N	97666.72	22.8712	FINNHUB	2026-06-14 00:48:40.576126+00	\N
3440	4242	2026-06-14	784.0500	0.0000	\N	94245.99	19.7913	FINNHUB	2026-06-14 00:48:42.908946+00	\N
3441	4243	2026-06-14	226.2100	0.0000	\N	90423.89	20.8086	FINNHUB	2026-06-14 00:48:45.249611+00	\N
3442	4244	2026-06-14	108.1000	0.0000	\N	91885.70	17.5054	FINNHUB	2026-06-14 00:48:47.674849+00	\N
3443	4245	2026-06-14	237.6600	0.0000	\N	95435.85	13.2274	FINNHUB	2026-06-14 00:48:50.22209+00	\N
3444	4246	2026-06-14	68.4100	0.0000	\N	98343.46	35.9837	FINNHUB	2026-06-14 00:48:52.569018+00	\N
3445	4247	2026-06-14	253.7600	0.0000	\N	91655.59	24.1772	FINNHUB	2026-06-14 00:48:54.897505+00	\N
3446	4248	2026-06-14	187.1800	0.0000	\N	87205.86	30.0679	FINNHUB	2026-06-14 00:48:57.23328+00	\N
3447	4249	2026-06-14	404.0700	0.0000	\N	87748.80	16.7364	FINNHUB	2026-06-14 00:48:59.578862+00	\N
3448	4250	2026-06-14	659.5800	0.0000	\N	91014.82	34.0497	FINNHUB	2026-06-14 00:49:02.043091+00	\N
3449	4251	2026-06-14	453.8900	0.0000	\N	86910.56	112.3938	FINNHUB	2026-06-14 00:49:04.37649+00	\N
3450	4252	2026-06-14	219.4500	0.0000	\N	88125.81	31.5411	FINNHUB	2026-06-14 00:49:06.718097+00	\N
3451	4253	2026-06-14	228.4800	0.0000	\N	81138.45	\N	FINNHUB	2026-06-14 00:49:09.04028+00	\N
3452	4254	2026-06-14	72.0800	0.0000	\N	88153.71	31.5737	FINNHUB	2026-06-14 00:49:11.373534+00	\N
3453	4255	2026-06-14	144.9600	0.0000	\N	88442.35	25.0474	FINNHUB	2026-06-14 00:49:13.727826+00	\N
3454	4256	2026-06-14	92.8300	0.0000	\N	90788.49	44.6810	FINNHUB	2026-06-14 00:49:16.077557+00	\N
3455	4257	2026-06-14	47.5700	0.0000	\N	88391.67	28.9809	FINNHUB	2026-06-14 00:49:18.427993+00	\N
3456	4258	2026-06-14	58.9400	0.0000	\N	91492.53	11.7208	FINNHUB	2026-06-14 00:49:20.761027+00	\N
3457	4259	2026-06-14	30.2100	0.0000	\N	71067.17	7.3485	FINNHUB	2026-06-14 00:49:23.116275+00	\N
3458	4260	2026-06-14	24.5000	0.0000	\N	87519.59	4.6560	FINNHUB	2026-06-14 00:49:25.446731+00	\N
3459	4261	2026-06-14	7.9900	0.0000	\N	457234.88	13.1205	FINNHUB	2026-06-14 00:49:27.793041+00	\N
3460	4262	2026-06-14	14.8000	0.0000	\N	65750.23	84.1872	FINNHUB	2026-06-14 00:49:30.158439+00	\N
3461	4263	2026-06-14	96.2400	0.0000	\N	86411.30	29.1771	FINNHUB	2026-06-14 00:49:32.489638+00	\N
3462	4264	2026-06-14	229.9000	0.0000	\N	81835.25	603.1801	FINNHUB	2026-06-14 00:49:34.848685+00	\N
3463	4265	2026-06-14	25.4700	0.0000	\N	60728.23	5.4908	FINNHUB	2026-06-14 00:49:37.243851+00	\N
3464	4266	2026-06-14	232.7800	0.0000	\N	80681.55	\N	FINNHUB	2026-06-14 00:49:39.582088+00	\N
3465	4267	2026-06-14	387.1800	0.0000	\N	85891.94	12.6423	FINNHUB	2026-06-14 00:49:41.92981+00	\N
3466	4268	2026-06-14	56.1800	0.0000	\N	83992.34	25.2305	FINNHUB	2026-06-14 00:49:44.267691+00	\N
3467	4269	2026-06-14	162.6400	0.0000	\N	109977.98	14.7153	FINNHUB	2026-06-14 00:49:46.635018+00	\N
3468	4270	2026-06-14	37.2500	0.0000	\N	80591.06	13.6526	FINNHUB	2026-06-14 00:49:48.973045+00	\N
3469	4271	2026-06-14	1589.6000	0.0000	\N	80588.24	41.9730	FINNHUB	2026-06-14 00:49:51.302759+00	\N
3470	4272	2026-06-14	276.7300	0.0000	\N	75695.89	16.5131	FINNHUB	2026-06-14 00:49:53.636882+00	\N
3471	4273	2026-06-14	81.8400	0.0000	\N	60106.58	18.5457	FINNHUB	2026-06-14 00:49:56.132599+00	\N
3472	4274	2026-06-14	38.1200	0.0000	\N	2387013.20	50.5156	FINNHUB	2026-06-14 00:49:58.468213+00	\N
3473	4275	2026-06-14	158.3200	0.0000	\N	82574.53	29.6285	FINNHUB	2026-06-14 00:50:00.819714+00	\N
3474	4276	2026-06-14	140.5300	0.0000	\N	79471.47	20.2166	FINNHUB	2026-06-14 00:50:03.195481+00	\N
3475	4277	2026-06-14	219.0400	0.0000	\N	71030.71	15.1339	FINNHUB	2026-06-14 00:50:05.570331+00	\N
3476	4278	2026-06-14	53.5000	0.0000	\N	69478.56	15.5017	FINNHUB	2026-06-14 00:50:07.946104+00	\N
3477	4279	2026-06-14	90.0800	0.0000	\N	110700.73	27.1525	FINNHUB	2026-06-14 00:50:10.311433+00	\N
3478	4280	2026-06-14	168.6800	0.0000	\N	81269.09	20.7055	FINNHUB	2026-06-14 00:50:12.647272+00	\N
3479	4281	2026-06-14	62.9900	0.0000	\N	80857.10	30.9205	FINNHUB	2026-06-14 00:50:15.576541+00	\N
3480	4282	2026-06-14	132.2800	0.0000	\N	79725.80	31.6749	FINNHUB	2026-06-14 00:50:17.895784+00	\N
3481	4283	2026-06-14	338.3100	0.0000	\N	80723.05	18.0025	FINNHUB	2026-06-14 00:50:20.23047+00	\N
3482	4284	2026-06-14	447.8500	0.0000	\N	78239.40	31.3585	FINNHUB	2026-06-14 00:50:22.562671+00	\N
3483	4285	2026-06-14	345.9500	0.0000	\N	78754.95	51.0732	FINNHUB	2026-06-14 00:50:24.884417+00	\N
3484	4286	2026-06-14	143.0700	0.0000	\N	80133.50	32.7878	FINNHUB	2026-06-14 00:50:27.228277+00	\N
3485	4287	2026-06-14	550.3300	0.0000	\N	78165.28	17.0816	FINNHUB	2026-06-14 00:50:29.567688+00	\N
3486	4288	2026-06-14	5.5000	0.0000	\N	57161.76	9.0863	FINNHUB	2026-06-14 00:50:31.903212+00	\N
3487	4289	2026-06-14	125.8200	0.0000	\N	78776.31	15.6074	FINNHUB	2026-06-14 00:50:34.228877+00	\N
3488	4290	2026-06-14	298.0000	0.0000	\N	78830.66	12.5367	FINNHUB	2026-06-14 00:50:36.562627+00	\N
3489	4291	2026-06-14	263.5800	0.0000	\N	76948.65	16.6124	FINNHUB	2026-06-14 00:50:38.9154+00	\N
3490	4292	2026-06-14	258.6700	0.0000	\N	76807.60	18.2614	FINNHUB	2026-06-14 00:50:41.246316+00	\N
3491	4293	2026-06-14	294.3800	0.0000	\N	78951.23	17.6270	FINNHUB	2026-06-14 00:50:43.953411+00	\N
3492	4294	2026-06-14	260.2200	0.0000	\N	74017.98	12268.8520	FINNHUB	2026-06-14 00:50:46.288922+00	\N
3493	4295	2026-06-14	317.3000	0.0000	\N	78257.48	30.1071	FINNHUB	2026-06-14 00:50:48.622884+00	\N
3494	4296	2026-06-14	91.0200	0.0000	\N	75429.65	28.9679	FINNHUB	2026-06-14 00:50:50.961568+00	\N
3495	4297	2026-06-14	304.8600	0.0000	\N	76968.33	29.0118	FINNHUB	2026-06-14 00:50:53.293347+00	\N
3496	4298	2026-06-14	27.7500	0.0000	\N	1321162.90	15.0960	FINNHUB	2026-06-14 00:50:55.738809+00	\N
3497	4299	2026-06-14	93.1900	0.0000	\N	83992.65	44.2766	FINNHUB	2026-06-14 00:50:58.053572+00	\N
3498	4300	2026-06-14	81.5000	0.0000	\N	73485.71	28.9542	FINNHUB	2026-06-14 00:51:00.395404+00	\N
3499	4301	2026-06-14	240.1300	0.0000	\N	77029.16	33.2630	FINNHUB	2026-06-14 00:51:02.725799+00	\N
3500	4302	2026-06-14	47.1300	0.0000	\N	75256.55	29.8519	FINNHUB	2026-06-14 00:51:05.043781+00	\N
3501	4303	2026-06-14	133.8800	0.0000	\N	77184.16	67.4687	FINNHUB	2026-06-14 00:51:07.393297+00	\N
3502	4304	2026-06-14	385.0300	0.0000	\N	75327.01	160.6637	FINNHUB	2026-06-14 00:51:09.726256+00	\N
3503	4305	2026-06-14	61.6000	0.0000	\N	101945.54	16.1077	FINNHUB	2026-06-14 00:51:12.07843+00	\N
3504	4306	2026-06-14	64.1000	0.0000	\N	70307.17	48.7905	FINNHUB	2026-06-14 00:51:14.396042+00	\N
3505	4307	2026-06-14	179.4500	0.0000	\N	71947.80	17.4504	FINNHUB	2026-06-14 00:51:16.738884+00	\N
3506	4308	2026-06-14	136.6500	0.0000	\N	72783.68	13.2406	FINNHUB	2026-06-14 00:51:19.121255+00	\N
3507	4309	2026-06-14	118.9800	0.0000	\N	100076.86	21.2703	FINNHUB	2026-06-14 00:51:21.489416+00	\N
3508	4310	2026-06-14	1577.3200	0.0000	\N	77493.73	113.8077	FINNHUB	2026-06-14 00:51:23.838283+00	\N
3509	4311	2026-06-14	257.4300	0.0000	\N	74062.61	23.6320	FINNHUB	2026-06-14 00:51:26.168697+00	\N
3510	4312	2026-06-14	265.4100	0.0000	\N	74696.33	35.4734	FINNHUB	2026-06-14 00:51:28.496287+00	\N
3511	4313	2026-06-14	46.9100	0.0000	\N	69724.91	19.5582	FINNHUB	2026-06-14 00:51:30.823863+00	\N
3512	4314	2026-06-14	176.2800	0.0000	\N	70527.36	36.4062	FINNHUB	2026-06-14 00:51:33.159305+00	\N
3513	4315	2026-06-14	69.3900	0.0000	\N	96850.00	28.1541	FINNHUB	2026-06-14 00:51:35.558954+00	\N
3514	4316	2026-06-14	89.4500	0.0000	\N	71576.94	34.2966	FINNHUB	2026-06-14 00:51:37.892131+00	\N
3515	4317	2026-06-14	31.9400	0.0000	\N	71060.94	21.4362	FINNHUB	2026-06-14 00:51:40.219329+00	\N
3516	4318	2026-06-14	313.9100	0.0000	\N	70502.30	26.4054	FINNHUB	2026-06-14 00:51:42.577579+00	\N
3517	4319	2026-06-14	129.2300	0.0000	\N	70314.70	19.2443	FINNHUB	2026-06-14 00:51:45.160661+00	\N
3518	4320	2026-06-14	106.4800	0.0000	\N	71149.96	19.3816	FINNHUB	2026-06-14 00:51:47.493452+00	\N
3519	4321	2026-06-14	335.3100	0.0000	\N	71614.49	18.1670	FINNHUB	2026-06-14 00:51:49.838869+00	\N
3520	4322	2026-06-14	1256.0500	0.0000	\N	70255.38	33.7442	FINNHUB	2026-06-14 00:51:52.172035+00	\N
3521	4323	2026-06-14	445.9800	0.0000	\N	63129.77	144.0332	FINNHUB	2026-06-14 00:51:54.683726+00	\N
3522	4324	2026-06-14	150.5800	0.0000	\N	65610.53	70.8537	FINNHUB	2026-06-14 00:51:57.008184+00	\N
3523	4325	2026-06-14	412.2500	0.0000	\N	68431.68	32.7424	FINNHUB	2026-06-14 00:51:59.701298+00	\N
3524	4326	2026-06-14	921.5600	0.0000	\N	71697.38	162.9856	FINNHUB	2026-06-14 00:52:02.037893+00	\N
3525	4327	2026-06-14	1074.2400	0.0000	\N	67297.45	26.8438	FINNHUB	2026-06-14 00:52:04.367951+00	\N
3526	4328	2026-06-14	184.2000	0.0000	\N	64729.00	46.9769	FINNHUB	2026-06-14 00:52:06.693044+00	\N
3527	4329	2026-06-14	19.0700	0.0000	\N	65622.91	15.0373	FINNHUB	2026-06-14 00:52:09.024411+00	\N
3528	4330	2026-06-14	40.2000	0.0000	\N	91398.98	10.6734	FINNHUB	2026-06-14 00:52:11.425401+00	\N
3529	4331	2026-06-14	26.9800	0.0000	\N	67642.56	\N	FINNHUB	2026-06-14 00:52:13.760912+00	\N
3530	4332	2026-06-14	15.7100	0.0000	\N	367651.22	23.5629	FINNHUB	2026-06-14 00:52:16.116293+00	\N
3531	4333	2026-06-14	48.1700	0.0000	\N	63786.88	40.9941	FINNHUB	2026-06-14 00:52:18.487531+00	\N
3532	4334	2026-06-14	1877.6100	0.0000	\N	66096.43	54.0159	FINNHUB	2026-06-14 00:52:20.928501+00	\N
3533	4335	2026-06-14	40.3100	0.0000	\N	92573.36	14.4240	FINNHUB	2026-06-14 00:52:23.317385+00	\N
3534	4336	2026-06-14	612.1400	0.0000	\N	64176.16	14.5083	FINNHUB	2026-06-14 00:52:25.696033+00	\N
3535	4337	2026-06-14	209.9100	0.0000	\N	64581.77	29.7749	FINNHUB	2026-06-14 00:52:28.034942+00	\N
3536	4338	2026-06-14	304.4600	0.0000	\N	64741.80	8.5142	FINNHUB	2026-06-14 00:52:30.371044+00	\N
3537	4339	2026-06-14	77.3000	0.0000	\N	57849.65	223.8023	FINNHUB	2026-06-14 00:52:32.718106+00	\N
3538	4340	2026-06-14	102.3900	0.0000	\N	59270.24	\N	FINNHUB	2026-06-14 00:52:35.043187+00	\N
3539	4341	2026-06-14	44.9300	0.0000	\N	66536.27	29.5717	FINNHUB	2026-06-14 00:52:37.542984+00	\N
3540	4342	2026-06-14	16.5800	0.0000	\N	46774.45	7.8035	FINNHUB	2026-06-14 00:52:39.884647+00	\N
3541	4343	2026-06-14	281.6200	0.0000	\N	62711.34	29.7591	FINNHUB	2026-06-14 00:52:42.217885+00	\N
3542	4344	2026-06-14	63.1400	0.0000	\N	62639.22	20.1024	FINNHUB	2026-06-14 00:52:44.585715+00	\N
3543	4345	2026-06-14	210.3800	0.0000	\N	61409.04	21.1318	FINNHUB	2026-06-14 00:52:46.934594+00	\N
3544	4346	2026-06-14	33.7400	0.0000	\N	43307.73	20.9723	FINNHUB	2026-06-14 00:52:49.290556+00	\N
3545	4347	2026-06-14	118.5200	0.0000	\N	62375.45	25.1920	FINNHUB	2026-06-14 00:52:51.621612+00	\N
3546	4348	2026-06-14	1315.8700	0.0000	\N	62126.32	34.8633	FINNHUB	2026-06-14 00:52:53.9558+00	\N
3547	4349	2026-06-14	51.6600	0.0000	\N	64362.13	11.6450	FINNHUB	2026-06-14 00:52:56.282154+00	\N
3548	4350	2026-06-14	354.9100	0.0000	\N	59504.35	37.2335	FINNHUB	2026-06-14 00:52:58.620465+00	\N
3549	4351	2026-06-14	117.8000	0.0000	\N	59958.42	12.9332	FINNHUB	2026-06-14 00:53:00.965235+00	\N
3550	4352	2026-06-14	92.2900	0.0000	\N	60329.06	30.8273	FINNHUB	2026-06-14 00:53:03.297439+00	\N
3551	4353	2026-06-14	33.3100	0.0000	\N	50503.60	7.1323	FINNHUB	2026-06-14 00:53:05.655827+00	\N
3552	4354	2026-06-14	14.8400	0.0000	\N	59132.84	\N	FINNHUB	2026-06-14 00:53:07.989721+00	\N
3553	4355	2026-06-14	121.2900	0.0000	\N	81751.35	27.9970	FINNHUB	2026-06-14 00:53:10.368912+00	\N
3554	4356	2026-06-14	67.9100	0.0000	\N	59727.70	20.2193	FINNHUB	2026-06-14 00:53:12.701732+00	\N
3555	4357	2026-06-14	232.3600	0.0000	\N	58473.50	71.5535	FINNHUB	2026-06-14 00:53:15.06207+00	\N
3556	4358	2026-06-14	12.1900	0.0000	\N	59250.71	18.6104	FINNHUB	2026-06-14 00:53:17.406268+00	\N
3557	4359	2026-06-14	266.3500	0.0000	\N	60658.80	26.0227	FINNHUB	2026-06-14 00:53:19.748961+00	\N
3558	4360	2026-06-14	307.7900	0.0000	\N	57339.73	33.1061	FINNHUB	2026-06-14 00:53:22.099421+00	\N
3559	4361	2026-06-14	56.8700	0.0000	\N	57707.91	12.2835	FINNHUB	2026-06-14 00:53:24.423952+00	\N
3560	4362	2026-06-14	62.7200	0.0000	\N	58485.93	52.1944	FINNHUB	2026-06-14 00:53:26.755255+00	\N
3561	4363	2026-06-14	221.6300	0.0000	\N	57052.20	4.6980	FINNHUB	2026-06-14 00:53:29.082339+00	\N
3562	4364	2026-06-14	272.6000	0.0000	\N	58511.93	27.4433	FINNHUB	2026-06-14 00:53:31.407282+00	\N
3563	4365	2026-06-14	56.5400	0.0000	\N	56236.65	11.8768	FINNHUB	2026-06-14 00:53:33.740802+00	\N
3564	4366	2026-06-14	350.6700	0.0000	\N	59927.88	56.8576	FINNHUB	2026-06-14 00:53:36.095924+00	\N
3565	4367	2026-06-14	403.2000	0.0000	\N	63117.80	73.9034	FINNHUB	2026-06-14 00:53:38.436412+00	\N
3566	4368	2026-06-14	69.9100	0.0000	\N	58065.88	44.3251	FINNHUB	2026-06-14 00:53:40.757409+00	\N
3567	4369	2026-06-14	135.2300	0.0000	\N	61420.27	17.8030	FINNHUB	2026-06-14 00:53:43.091003+00	\N
3568	4370	2026-06-14	149.7100	0.0000	\N	54850.44	62.3300	FINNHUB	2026-06-14 00:53:45.423226+00	\N
3569	4371	2026-06-14	90.5900	0.0000	\N	57074.68	16.1639	FINNHUB	2026-06-14 00:53:47.757483+00	\N
3570	4372	2026-06-14	218.6900	0.0000	\N	56181.46	34.8607	FINNHUB	2026-06-14 00:53:50.091177+00	\N
3571	4373	2026-06-14	893.5200	0.0000	\N	47996.77	24.7012	FINNHUB	2026-06-14 00:53:52.452843+00	\N
3572	4374	2026-06-14	100.5500	0.0000	\N	54857.10	\N	FINNHUB	2026-06-14 00:53:54.771635+00	\N
3573	4375	2026-06-14	325.9400	0.0000	\N	57217.38	30.0696	FINNHUB	2026-06-14 00:53:57.271127+00	\N
3574	4376	2026-06-14	88.8400	0.0000	\N	57162.92	15.7952	FINNHUB	2026-06-14 00:53:59.598366+00	\N
3575	4377	2026-06-14	367.1500	0.0000	\N	62932.43	235.1515	FINNHUB	2026-06-14 00:54:01.952152+00	\N
3576	4378	2026-06-14	192.1300	0.0000	\N	54048.73	190.3124	FINNHUB	2026-06-14 00:54:04.296442+00	\N
3577	4379	2026-06-14	46.5700	0.0000	\N	53463.99	41.1388	FINNHUB	2026-06-14 00:54:06.630119+00	\N
3578	4380	2026-06-14	281.6700	0.0000	\N	54802.02	21.5021	FINNHUB	2026-06-14 00:54:08.960343+00	\N
3579	4381	2026-06-14	82.9400	0.0000	\N	52483.80	32.7403	FINNHUB	2026-06-14 00:54:11.282609+00	\N
3580	4382	2026-06-14	28.2700	0.0000	\N	74340.38	16.0182	FINNHUB	2026-06-14 00:54:13.637964+00	\N
3581	4383	2026-06-14	116.1000	0.0000	\N	71361.21	28.3417	FINNHUB	2026-06-14 00:54:16.026305+00	\N
3582	4384	2026-06-14	21.6300	0.0000	\N	1572123.10	31.3728	FINNHUB	2026-06-14 00:54:18.392851+00	\N
3583	4385	2026-06-14	70.8100	0.0000	\N	42575.84	16.8546	FINNHUB	2026-06-14 00:54:20.760784+00	\N
3584	4386	2026-06-14	227.1200	0.0000	\N	52056.59	34.0742	FINNHUB	2026-06-14 00:54:23.114088+00	\N
3585	4387	2026-06-14	83.0600	0.0000	\N	54569.95	12.1890	FINNHUB	2026-06-14 00:54:25.502447+00	\N
3586	4388	2026-06-14	76.1400	0.0000	\N	50923.96	43.8244	FINNHUB	2026-06-14 00:54:27.84234+00	\N
3587	4389	2026-06-14	45.3100	0.0000	\N	52260.70	23.0426	FINNHUB	2026-06-14 00:54:30.191523+00	\N
3588	4390	2026-06-14	3116.3000	0.0000	\N	51346.72	20.7200	FINNHUB	2026-06-14 00:54:32.568444+00	\N
3589	4391	2026-06-14	203.2700	0.0000	\N	50970.25	57.4636	FINNHUB	2026-06-14 00:54:34.917844+00	\N
3590	4392	2026-06-14	11.7400	0.0000	\N	4519783.50	15.3525	FINNHUB	2026-06-14 00:54:37.281364+00	\N
3591	4393	2026-06-14	111.1100	0.0000	\N	50875.81	28.2375	FINNHUB	2026-06-14 00:54:39.608841+00	\N
3592	4394	2026-06-14	245.7500	0.0000	\N	51108.20	50.7378	FINNHUB	2026-06-14 00:54:41.939296+00	\N
3593	4395	2026-06-14	148.0200	0.0000	\N	49909.75	22.2712	FINNHUB	2026-06-14 00:54:44.270316+00	\N
3594	4396	2026-06-14	241.2800	0.0000	\N	50560.68	34.2784	FINNHUB	2026-06-14 00:54:46.597218+00	\N
3595	4397	2026-06-14	459.3400	0.0000	\N	51112.58	46.9785	FINNHUB	2026-06-14 00:54:48.931203+00	\N
3596	4398	2026-06-14	85.1100	0.0000	\N	49006.34	44.7057	FINNHUB	2026-06-14 00:54:51.266846+00	\N
3597	4399	2026-06-14	88.9800	0.0000	\N	50321.82	26.3189	FINNHUB	2026-06-14 00:54:53.611769+00	\N
3598	4400	2026-06-14	79.2200	0.0000	\N	49454.64	23.6512	FINNHUB	2026-06-14 00:54:55.952004+00	\N
3599	4401	2026-06-14	3.2500	0.0000	\N	262235.80	16.8340	FINNHUB	2026-06-14 00:54:58.303398+00	\N
3600	4402	2026-06-14	67.9400	0.0000	\N	40838.73	45.9896	FINNHUB	2026-06-14 00:55:00.66263+00	\N
3601	4403	2026-06-14	15.9100	0.0000	\N	7978582.50	41.6067	FINNHUB	2026-06-14 00:55:03.004178+00	\N
3602	4404	2026-06-14	198.4300	0.0000	\N	41868.73	28.6184	FINNHUB	2026-06-14 00:55:05.34049+00	\N
3603	4405	2026-06-14	108.6100	0.0000	\N	48222.84	23.6386	FINNHUB	2026-06-14 00:55:07.670369+00	\N
3604	4406	2026-06-14	223.8500	0.0000	\N	52426.98	33.7151	FINNHUB	2026-06-14 00:55:10.011042+00	\N
3605	4407	2026-06-14	95.2400	0.0000	\N	51627.63	224.4679	FINNHUB	2026-06-14 00:55:12.343736+00	\N
3606	4408	2026-06-14	54.7300	0.0000	\N	49602.43	22.8267	FINNHUB	2026-06-14 00:55:14.663915+00	\N
3607	4409	2026-06-14	46.2100	0.0000	\N	47282.45	17.0142	FINNHUB	2026-06-14 00:55:16.993419+00	\N
3608	4410	2026-06-14	331.6100	0.0000	\N	39030.20	49.4287	FINNHUB	2026-06-14 00:55:19.336285+00	\N
3609	4411	2026-06-14	116.7900	0.0000	\N	45770.38	79.7810	FINNHUB	2026-06-14 00:55:21.663385+00	\N
3610	4412	2026-06-14	238.1000	0.0000	\N	45919.06	26.4481	FINNHUB	2026-06-14 00:55:23.9911+00	\N
3611	4413	2026-06-14	100.9600	0.0000	\N	43971.41	94.5579	FINNHUB	2026-06-14 00:55:26.320342+00	\N
3612	4414	2026-06-14	599.1200	0.0000	\N	43615.94	33.0498	FINNHUB	2026-06-14 00:55:28.681268+00	\N
3613	4415	2026-06-14	167.6300	0.0000	\N	46394.46	15.1369	FINNHUB	2026-06-14 00:55:31.037813+00	\N
3614	4416	2026-06-14	230.0800	0.0000	\N	44621.22	18.0653	FINNHUB	2026-06-14 00:55:33.363061+00	\N
3615	4417	2026-06-14	81.7900	0.0000	\N	33498.54	18.6041	FINNHUB	2026-06-14 00:55:35.702743+00	\N
3616	4418	2026-06-14	560.8800	0.0000	\N	44243.90	40.3968	FINNHUB	2026-06-14 00:55:38.043722+00	\N
3617	4419	2026-06-14	265.2000	0.0000	\N	44998.43	37.1888	FINNHUB	2026-06-14 00:55:40.379527+00	\N
3618	4420	2026-06-14	36.6100	0.0000	\N	48094.13	49.7869	FINNHUB	2026-06-14 00:55:42.697651+00	\N
3619	4421	2026-06-14	214.0000	0.0000	\N	46996.61	\N	FINNHUB	2026-06-14 00:55:45.017633+00	\N
3620	4422	2026-06-14	393.1200	0.0000	\N	61884.27	46.1451	FINNHUB	2026-06-14 00:55:47.390645+00	\N
3621	4423	2026-06-14	12.2800	0.0000	\N	376001.70	14.9403	FINNHUB	2026-06-14 00:55:49.742261+00	\N
3622	4424	2026-06-14	86.3000	0.0000	\N	43582.15	12.5452	FINNHUB	2026-06-14 00:55:52.119819+00	\N
3623	4425	2026-06-14	123.9700	0.0000	\N	43444.99	\N	FINNHUB	2026-06-14 00:55:54.447259+00	\N
3624	4426	2026-06-14	209.4600	0.0000	\N	55960.89	29.1784	FINNHUB	2026-06-14 00:55:56.795634+00	\N
3625	4427	2026-06-14	379.2200	0.0000	\N	45529.72	40.2918	FINNHUB	2026-06-14 00:55:59.131195+00	\N
3626	4428	2026-06-14	38.6700	0.0000	\N	6306607.50	14.1004	FINNHUB	2026-06-14 00:56:01.512485+00	\N
3627	4429	2026-06-14	146.2400	0.0000	\N	40295.04	35.4086	FINNHUB	2026-06-14 00:56:03.855189+00	\N
3628	4430	2026-06-14	154.3100	0.0000	\N	42531.10	24.4713	FINNHUB	2026-06-14 00:56:06.18503+00	\N
3629	4431	2026-06-14	23.0700	0.0000	\N	58287.73	15.1107	FINNHUB	2026-06-14 00:56:08.528113+00	\N
3630	4432	2026-06-14	31.7100	0.0000	\N	43143.34	23.5499	FINNHUB	2026-06-14 00:56:10.898443+00	\N
3631	4433	2026-06-14	99.3400	0.0000	\N	44029.24	19.6000	FINNHUB	2026-06-14 00:56:13.243221+00	\N
3632	4434	2026-06-14	134.9000	0.0000	\N	29951.64	48.0934	FINNHUB	2026-06-14 00:56:15.565998+00	\N
3633	4435	2026-06-14	81.3800	0.0000	\N	44630.13	57.2916	FINNHUB	2026-06-14 00:56:17.889658+00	\N
3634	4436	2026-06-14	115.7700	0.0000	\N	39881.26	689.7622	FINNHUB	2026-06-14 00:56:20.218932+00	\N
3635	4437	2026-06-14	154.0900	0.0000	\N	43696.78	13.7732	FINNHUB	2026-06-14 00:56:22.561412+00	\N
3636	4438	2026-06-14	92.1600	0.0000	\N	40223.41	37.9824	FINNHUB	2026-06-14 00:56:24.887275+00	\N
3637	4439	2026-06-14	69.5200	0.0000	\N	41376.98	51.2673	FINNHUB	2026-06-14 00:56:27.206641+00	\N
3638	4440	2026-06-14	76.6400	0.0000	\N	58644.25	17.8793	FINNHUB	2026-06-14 00:56:29.58507+00	\N
3639	4441	2026-06-14	459.1300	0.0000	\N	41274.45	10.5968	FINNHUB	2026-06-14 00:56:31.938324+00	\N
3640	4442	2026-06-14	282.8500	0.0000	\N	37764.04	65.4243	FINNHUB	2026-06-14 00:56:34.288114+00	\N
3641	4443	2026-06-14	84.6000	0.0000	\N	41129.96	157.9340	FINNHUB	2026-06-14 00:56:36.615745+00	\N
3642	4444	2026-06-14	159.7800	0.0000	\N	42095.80	52.5802	FINNHUB	2026-06-14 00:56:38.943015+00	\N
3643	4445	2026-06-14	92.2500	0.0000	\N	41157.98	34.3366	FINNHUB	2026-06-14 00:56:41.264995+00	\N
3644	4446	2026-06-14	75.7400	0.0000	\N	40157.82	12.7042	FINNHUB	2026-06-14 00:56:43.594164+00	\N
3645	4447	2026-06-14	9.1300	0.0000	\N	29490.16	17.6906	FINNHUB	2026-06-14 00:56:45.932911+00	\N
3646	4448	2026-06-14	34.6300	0.0000	\N	118560.23	25.8917	FINNHUB	2026-06-14 00:56:48.309819+00	\N
3647	4449	2026-06-14	211.7500	0.0000	\N	39329.77	\N	FINNHUB	2026-06-14 00:56:50.639947+00	\N
3648	4450	2026-06-14	79.7000	0.0000	\N	39716.22	17.5502	FINNHUB	2026-06-14 00:56:52.984417+00	\N
3649	4451	2026-06-14	156.1100	0.0000	\N	55171.13	37.4018	FINNHUB	2026-06-14 00:56:55.335099+00	\N
3650	4452	2026-06-14	441.7300	0.0000	\N	35604.36	172.8468	FINNHUB	2026-06-14 00:56:57.678757+00	\N
3651	4453	2026-06-14	107.7400	0.0000	\N	39705.39	18.4248	FINNHUB	2026-06-14 00:57:00.018857+00	\N
3652	4454	2026-06-14	107.8000	0.0000	\N	51112704.00	8.4788	FINNHUB	2026-06-14 00:57:02.37419+00	\N
3653	4455	2026-06-14	28.5600	0.0000	\N	264229.25	16.4737	FINNHUB	2026-06-14 00:57:04.874797+00	\N
3654	4456	2026-06-14	80.2400	0.0000	\N	38672.20	35.7745	FINNHUB	2026-06-14 00:57:07.227453+00	\N
3655	4457	2026-06-14	64.7100	0.0000	\N	39897.65	39.2693	FINNHUB	2026-06-14 00:57:09.555699+00	\N
3656	4458	2026-06-14	203.3600	0.0000	\N	38867.44	169.9338	FINNHUB	2026-06-14 00:57:11.88181+00	\N
3657	4459	2026-06-14	247.0900	0.0000	\N	39030.20	49.4287	FINNHUB	2026-06-14 00:57:14.251555+00	\N
3658	4460	2026-06-14	282.7600	0.0000	\N	40777.61	29.7239	FINNHUB	2026-06-14 00:57:16.582401+00	\N
3659	4461	2026-06-14	854.0600	0.0000	\N	122288.63	71.1283	FINNHUB	2026-06-14 00:57:18.97269+00	\N
3660	4462	2026-06-14	133.4100	0.0000	\N	39064.66	29.7749	FINNHUB	2026-06-14 00:57:21.354705+00	\N
3661	4463	2026-06-14	129.8400	0.0000	\N	36670.97	25.9342	FINNHUB	2026-06-14 00:57:23.694377+00	\N
3662	4464	2026-06-14	250.8100	0.0000	\N	46261.89	97.9546	FINNHUB	2026-06-14 00:57:26.024409+00	\N
3663	4465	2026-06-14	29.1800	0.0000	\N	40364.05	13.0333	FINNHUB	2026-06-14 00:57:28.354304+00	\N
3664	4466	2026-06-14	129.3700	0.0000	\N	646375.44	22.7096	FINNHUB	2026-06-14 00:57:30.757953+00	\N
3665	4467	2026-06-14	16.9500	0.0000	\N	37327.72	12.6363	FINNHUB	2026-06-14 00:57:33.090511+00	\N
3666	4468	2026-06-14	81.4100	0.0000	\N	48922.91	22.9011	FINNHUB	2026-06-14 00:57:35.452553+00	\N
3667	4469	2026-06-14	32.2300	0.0000	\N	41342.52	28.4731	FINNHUB	2026-06-14 00:57:37.801138+00	\N
3668	4470	2026-06-14	90.8100	0.0000	\N	154033.73	148.3947	FINNHUB	2026-06-14 00:57:40.123609+00	\N
3669	4471	2026-06-14	181.6600	0.0000	\N	36848.57	33.6775	FINNHUB	2026-06-14 00:57:42.463005+00	\N
3670	4472	2026-06-14	384.8200	0.0000	\N	40599.52	50.1848	FINNHUB	2026-06-14 00:57:44.800081+00	\N
3671	4473	2026-06-14	172.5100	0.0000	\N	40145.29	479.8337	FINNHUB	2026-06-14 00:57:47.133896+00	\N
3672	4474	2026-06-14	127.2400	0.0000	\N	37857.04	139.0249	FINNHUB	2026-06-14 00:57:49.46465+00	\N
3673	4475	2026-06-14	113.4400	0.0000	\N	36950.33	22.5458	FINNHUB	2026-06-14 00:57:51.798971+00	\N
3674	4476	2026-06-14	286.4700	0.0000	\N	37170.88	33.3880	FINNHUB	2026-06-14 00:57:54.140075+00	\N
3675	4477	2026-06-14	79.1900	0.0000	\N	37867.28	21.8129	FINNHUB	2026-06-14 00:57:56.47122+00	\N
3676	4478	2026-06-14	41.5300	0.0000	\N	36633.84	7.2413	FINNHUB	2026-06-14 00:57:58.791797+00	\N
3677	4479	2026-06-14	108.5000	0.0000	\N	37649.50	10.8625	FINNHUB	2026-06-14 00:58:01.127111+00	\N
3678	4480	2026-06-14	82.4100	0.0000	\N	31985.34	\N	FINNHUB	2026-06-14 00:58:03.457807+00	\N
3679	4481	2026-06-14	823.0500	0.0000	\N	36576.57	27.3444	FINNHUB	2026-06-14 00:58:05.798363+00	\N
3680	4482	2026-06-14	129.6200	0.0000	\N	35532.83	8.7476	FINNHUB	2026-06-14 00:58:08.127829+00	\N
3681	4483	2026-06-14	100.6300	0.0000	\N	36054.81	22.0290	FINNHUB	2026-06-14 00:58:10.463873+00	\N
3682	4484	2026-06-14	355.5300	0.0000	\N	34908.02	77.7032	FINNHUB	2026-06-14 00:58:12.795558+00	\N
3683	4485	2026-06-14	13.0700	0.0000	\N	36980.65	154.4832	FINNHUB	2026-06-14 00:58:15.113783+00	\N
3684	4486	2026-06-14	130.8000	0.0000	\N	32307.60	38.1436	FINNHUB	2026-06-14 00:58:17.462328+00	\N
3685	4487	2026-06-14	26.4400	0.0000	\N	5556617.50	\N	FINNHUB	2026-06-14 00:58:19.977996+00	\N
3686	4488	2026-06-14	60.3300	0.0000	\N	26154.75	12.0324	FINNHUB	2026-06-14 00:58:22.323044+00	\N
3687	4489	2026-06-14	46.0900	0.0000	\N	1124829.80	28.8248	FINNHUB	2026-06-14 00:58:24.683127+00	\N
3688	4490	2026-06-14	577.3300	0.0000	\N	34666.30	13.6805	FINNHUB	2026-06-14 00:58:27.013198+00	\N
3689	4491	2026-06-14	588.7300	0.0000	\N	36508.56	38.7521	FINNHUB	2026-06-14 00:58:29.33957+00	\N
3690	4492	2026-06-14	115.5200	0.0000	\N	37214.19	10.1567	FINNHUB	2026-06-14 00:58:31.675005+00	\N
3691	4493	2026-06-14	204.0800	0.0000	\N	30382.09	292.2591	FINNHUB	2026-06-14 00:58:34.007026+00	\N
3692	4494	2026-06-14	18.1400	0.0000	\N	34828.96	21.4728	FINNHUB	2026-06-14 00:58:36.37909+00	\N
3693	4495	2026-06-14	15.5300	0.0000	\N	27176.80	\N	FINNHUB	2026-06-14 00:58:38.742574+00	\N
3694	4496	2026-06-14	114.0800	0.0000	\N	33061.92	\N	FINNHUB	2026-06-14 00:58:41.066691+00	\N
3695	4497	2026-06-14	51.9400	0.0000	\N	32487.33	9.8916	FINNHUB	2026-06-14 00:58:43.409111+00	\N
3696	4498	2026-06-14	334.9700	0.0000	\N	33804.29	19.7213	FINNHUB	2026-06-14 00:58:45.742949+00	\N
3697	4499	2026-06-14	3.5000	0.0000	\N	174797.20	7.3515	FINNHUB	2026-06-14 00:58:48.131489+00	\N
3698	4500	2026-06-14	17.5200	0.0000	\N	35515.33	16.0921	FINNHUB	2026-06-14 00:58:50.450915+00	\N
3699	4501	2026-06-14	162.1000	0.0000	\N	31205.71	44.1043	FINNHUB	2026-06-14 00:58:53.309053+00	\N
3700	4502	2026-06-14	79.5700	0.0000	\N	33357.98	12.6213	FINNHUB	2026-06-14 00:58:55.634719+00	\N
3701	4503	2026-06-14	50.6700	0.0000	\N	33575.83	18.2279	FINNHUB	2026-06-14 00:58:58.145843+00	\N
3702	4504	2026-06-14	74.8500	0.0000	\N	34157.09	35.7666	FINNHUB	2026-06-14 00:59:00.7818+00	\N
3703	4505	2026-06-14	36.5000	0.0000	\N	506538.97	8.7270	FINNHUB	2026-06-14 00:59:03.154484+00	\N
3704	4506	2026-06-14	102.2900	0.0000	\N	33954.18	16.0237	FINNHUB	2026-06-14 00:59:05.488448+00	\N
3705	4507	2026-06-14	67.3000	0.0000	\N	44875390.00	8.7891	FINNHUB	2026-06-14 00:59:07.828058+00	\N
3706	4508	2026-06-14	39.6000	0.0000	\N	33081.75	21.4817	FINNHUB	2026-06-14 00:59:10.156688+00	\N
3707	4509	2026-06-14	161.6100	0.0000	\N	31662.62	24.8140	FINNHUB	2026-06-14 00:59:12.487521+00	\N
3708	4510	2026-06-14	66.8500	0.0000	\N	26334.19	40.3338	FINNHUB	2026-06-14 00:59:14.832041+00	\N
3709	4511	2026-06-14	231.8800	0.0000	\N	33957.68	11.5857	FINNHUB	2026-06-14 00:59:17.155271+00	\N
3710	4512	2026-06-14	82.3700	0.0000	\N	34043.51	\N	FINNHUB	2026-06-14 00:59:19.504267+00	\N
3711	4513	2026-06-14	67.6200	0.0000	\N	44091.79	13.2035	FINNHUB	2026-06-14 00:59:21.887046+00	\N
3712	4514	2026-06-14	54.8700	0.0000	\N	31598.66	38.1955	FINNHUB	2026-06-14 00:59:24.218033+00	\N
3713	4515	2026-06-14	150.6000	0.0000	\N	31815.90	33.6997	FINNHUB	2026-06-14 00:59:26.543766+00	\N
3714	4516	2026-06-14	26.5800	0.0000	\N	23744.23	8.0023	FINNHUB	2026-06-14 00:59:28.891659+00	\N
3715	4517	2026-06-14	13.0800	0.0000	\N	32495.40	11.6346	FINNHUB	2026-06-14 00:59:31.210838+00	\N
3716	4518	2026-06-14	91.6600	0.0000	\N	32025.05	6.5733	FINNHUB	2026-06-14 00:59:33.712747+00	\N
3717	4519	2026-06-14	153.8700	0.0000	\N	32712.22	\N	FINNHUB	2026-06-14 00:59:36.029896+00	\N
3718	4520	2026-06-14	62.9200	0.0000	\N	29115.38	17.1256	FINNHUB	2026-06-14 00:59:38.37692+00	\N
3719	4521	2026-06-14	174.3400	0.0000	\N	32261.14	17.2483	FINNHUB	2026-06-14 00:59:40.718223+00	\N
3720	4522	2026-06-14	25.5800	0.0000	\N	41399.45	10.3285	FINNHUB	2026-06-14 00:59:43.094216+00	\N
3721	4523	2026-06-14	63.1900	0.0000	\N	30587.38	12.0803	FINNHUB	2026-06-14 00:59:45.44651+00	\N
3722	4524	2026-06-14	16.5800	0.0000	\N	116565830.00	12.9111	FINNHUB	2026-06-14 00:59:47.790984+00	\N
3723	4525	2026-06-14	212.0700	0.0000	\N	30371.69	\N	FINNHUB	2026-06-14 00:59:50.113041+00	\N
3724	4526	2026-06-14	65.1900	0.0000	\N	32190.63	\N	FINNHUB	2026-06-14 00:59:52.438748+00	\N
3725	4527	2026-06-14	181.4600	0.0000	\N	30285.67	21.8669	FINNHUB	2026-06-14 00:59:54.760961+00	\N
3726	4528	2026-06-14	28.5200	0.0000	\N	31167.85	10.0403	FINNHUB	2026-06-14 00:59:57.111448+00	\N
3727	4529	2026-06-14	147.4200	0.0000	\N	30667.53	24.2623	FINNHUB	2026-06-14 00:59:59.460085+00	\N
3728	4530	2026-06-14	109.0000	0.0000	\N	30165.93	19.7939	FINNHUB	2026-06-14 01:00:01.83747+00	\N
3729	4531	2026-06-14	89.6800	0.0000	\N	32445.77	\N	FINNHUB	2026-06-14 01:00:04.230287+00	\N
3730	4532	2026-06-14	64.8400	0.0000	\N	31746.27	35.3607	FINNHUB	2026-06-14 01:00:06.589133+00	\N
3731	4533	2026-06-14	46.4700	0.0000	\N	242604.58	6.2889	FINNHUB	2026-06-14 01:00:09.007698+00	\N
3732	4534	2026-06-14	264.4800	0.0000	\N	200415.28	63.3625	FINNHUB	2026-06-14 01:00:11.361315+00	\N
3733	4535	2026-06-14	267.3100	0.0000	\N	28723.36	17.2480	FINNHUB	2026-06-14 01:00:13.690387+00	\N
3734	4536	2026-06-14	43.3100	0.0000	\N	31009.04	\N	FINNHUB	2026-06-14 01:00:16.037851+00	\N
3735	4537	2026-06-14	93.6800	0.0000	\N	27470.00	13.2627	FINNHUB	2026-06-14 01:00:18.366472+00	\N
3736	4538	2026-06-14	53.1700	0.0000	\N	29388.97	25.4230	FINNHUB	2026-06-14 01:00:20.717807+00	\N
3737	4539	2026-06-14	150.6500	0.0000	\N	31536.95	68.2618	FINNHUB	2026-06-14 01:00:23.03722+00	\N
3738	4540	2026-06-14	154.4000	0.0000	\N	30089.94	14.0149	FINNHUB	2026-06-14 01:00:25.538753+00	\N
3739	4541	2026-06-14	294.9100	0.0000	\N	30863.45	24.9886	FINNHUB	2026-06-14 01:00:27.86143+00	\N
3740	4542	2026-06-14	65.1800	0.0000	\N	29649.85	15.5235	FINNHUB	2026-06-14 01:00:30.178984+00	\N
3741	4543	2026-06-14	53.7800	0.0000	\N	28678.40	8.9620	FINNHUB	2026-06-14 01:00:32.576076+00	\N
3742	4544	2026-06-14	217.4300	0.0000	\N	29279.43	26.5798	FINNHUB	2026-06-14 01:00:34.9317+00	\N
3743	4545	2026-06-14	200.0500	0.0000	\N	29534.81	21.5284	FINNHUB	2026-06-14 01:00:37.295453+00	\N
3744	4546	2026-06-14	30.7500	0.0000	\N	28468.70	18.3291	FINNHUB	2026-06-14 01:00:39.625205+00	\N
3745	4547	2026-06-14	56.9100	0.0000	\N	39998.34	22.1966	FINNHUB	2026-06-14 01:00:42.037226+00	\N
3746	4548	2026-06-14	48.3500	0.0000	\N	39479.44	23.3606	FINNHUB	2026-06-14 01:00:44.430934+00	\N
3747	4549	2026-06-14	169.9600	0.0000	\N	28369.69	21.0742	FINNHUB	2026-06-14 01:00:46.763242+00	\N
3748	4550	2026-06-14	362.9700	0.0000	\N	28681.37	63.7393	FINNHUB	2026-06-14 01:00:49.106206+00	\N
3749	4551	2026-06-14	194.7800	0.0000	\N	28254.08	18.5935	FINNHUB	2026-06-14 01:00:51.43691+00	\N
3750	4552	2026-06-14	147.4200	0.0000	\N	29785.43	44.9388	FINNHUB	2026-06-14 01:00:53.763509+00	\N
3751	4553	2026-06-14	74.0000	0.0000	\N	28958.93	49.3338	FINNHUB	2026-06-14 01:00:56.095663+00	\N
3752	4554	2026-06-14	72.9500	0.0000	\N	28070.72	7.4281	FINNHUB	2026-06-14 01:00:58.465033+00	\N
3753	4555	2026-06-14	342.8000	0.0000	\N	27572.07	\N	FINNHUB	2026-06-14 01:01:00.804151+00	\N
3754	4556	2026-06-14	895.1400	0.0000	\N	33083.51	46.3064	FINNHUB	2026-06-14 01:01:03.140744+00	\N
3755	4557	2026-06-14	75.3700	0.0000	\N	29083.24	31.2589	FINNHUB	2026-06-14 01:01:05.468848+00	\N
3756	4558	2026-06-14	10.2800	0.0000	\N	118592.19	12.4284	FINNHUB	2026-06-14 01:01:07.852518+00	\N
3757	4559	2026-06-14	65.8500	0.0000	\N	26192.52	15.3083	FINNHUB	2026-06-14 01:01:10.178235+00	\N
3758	4560	2026-06-14	159.5400	0.0000	\N	26036.72	27.6500	FINNHUB	2026-06-14 01:01:12.547309+00	\N
3759	4561	2026-06-14	42.9000	0.0000	\N	28063.87	26.2034	FINNHUB	2026-06-14 01:01:14.886225+00	\N
3760	4562	2026-06-14	626.0200	0.0000	\N	29002.97	31.0857	FINNHUB	2026-06-14 01:01:17.221167+00	\N
3761	4563	2026-06-14	224.8900	0.0000	\N	26991.66	18.1396	FINNHUB	2026-06-14 01:01:19.554608+00	\N
3762	4564	2026-06-14	125.4700	0.0000	\N	26472.47	110.7635	FINNHUB	2026-06-14 01:01:21.895492+00	\N
3763	4565	2026-06-14	16.8200	0.0000	\N	30192.98	\N	FINNHUB	2026-06-14 01:01:24.256572+00	\N
3764	4566	2026-06-14	758.0000	0.0000	\N	28001.40	54.7890	FINNHUB	2026-06-14 01:01:26.599417+00	\N
3765	4567	2026-06-14	187.0300	0.0000	\N	26534.33	23.2669	FINNHUB	2026-06-14 01:01:28.930492+00	\N
3766	4568	2026-06-14	858.9900	0.0000	\N	26358.93	76.0401	FINNHUB	2026-06-14 01:01:31.259369+00	\N
3767	4569	2026-06-14	67.6500	0.0000	\N	28607.96	14.4850	FINNHUB	2026-06-14 01:01:33.687682+00	\N
3768	4570	2026-06-14	70.7500	0.0000	\N	27147.91	18.3308	FINNHUB	2026-06-14 01:01:36.011769+00	\N
3769	4571	2026-06-14	35.8500	0.0000	\N	26971.76	22.1261	FINNHUB	2026-06-14 01:01:38.366143+00	\N
3770	4572	2026-06-14	378.9100	0.0000	\N	26135.10	51.8939	FINNHUB	2026-06-14 01:01:40.732905+00	\N
3771	4573	2026-06-14	279.8900	0.0000	\N	25469.99	30.2890	FINNHUB	2026-06-14 01:01:43.062054+00	\N
3772	4574	2026-06-14	289.3600	0.0000	\N	27286.42	43.8621	FINNHUB	2026-06-14 01:01:45.392474+00	\N
3773	4575	2026-06-14	47.0300	0.0000	\N	27203.62	25.5433	FINNHUB	2026-06-14 01:01:47.724333+00	\N
\.


--
-- Data for Name: stocks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stocks (id, ticker, exchange_code, finnhub_symbol, name_ko, name_en, logo_url, market_type, is_active, created_at, updated_at, ticker_normalized, name_ko_normalized, name_en_normalized, search_text) FROM stdin;
4076	NVDA	NASDAQ	NVDA	\N	NVIDIA Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/NVDA.png	COMMON_STOCK	t	2026-06-06 14:55:14.292628+00	2026-06-06 14:55:14.292628+00	nvda	\N	nvidia corp	nvda nvidia corp
4077	AAPL	NASDAQ	AAPL	\N	Apple Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AAPL.png	COMMON_STOCK	t	2026-06-06 14:55:14.787354+00	2026-06-06 14:55:14.787354+00	aapl	\N	apple inc	aapl apple inc
4078	GOOGL	NASDAQ	GOOGL	\N	Alphabet Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/GOOG.png	COMMON_STOCK	t	2026-06-06 14:55:15.260401+00	2026-06-06 14:55:15.260401+00	googl	\N	alphabet inc	googl alphabet inc
4079	MSFT	NASDAQ	MSFT	\N	Microsoft Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MSFT.png	COMMON_STOCK	t	2026-06-06 14:55:15.72862+00	2026-06-06 14:55:15.72862+00	msft	\N	microsoft corp	msft microsoft corp
4080	AMZN	NASDAQ	AMZN	\N	Amazon.com Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AMZN.png	COMMON_STOCK	t	2026-06-06 14:55:16.221646+00	2026-06-06 14:55:16.221646+00	amzn	\N	amazon.com inc	amzn amazon.com inc
4081	TSM	NASDAQ	TSM	\N	Taiwan Semiconductor Manufacturing Co Ltd	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/2330.TW.png	COMMON_STOCK	t	2026-06-06 14:55:16.745631+00	2026-06-06 14:55:16.745631+00	tsm	\N	taiwan semiconductor manufacturing co ltd	tsm taiwan semiconductor manufacturing co ltd
4082	AVGO	NASDAQ	AVGO	\N	Broadcom Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AVGO.png	COMMON_STOCK	t	2026-06-06 14:55:17.219833+00	2026-06-06 14:55:17.219833+00	avgo	\N	broadcom inc	avgo broadcom inc
4083	META	NASDAQ	META	\N	Meta Platforms Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/FB.png	COMMON_STOCK	t	2026-06-06 14:55:17.707194+00	2026-06-06 14:55:17.707194+00	meta	\N	meta platforms inc	meta meta platforms inc
4084	TSLA	NASDAQ	TSLA	\N	Tesla Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/TSLA.png	COMMON_STOCK	t	2026-06-06 14:55:18.195534+00	2026-06-06 14:55:18.195534+00	tsla	\N	tesla inc	tsla tesla inc
4085	BRK.B	NYSE	BRK.B	\N	Berkshire Hathaway Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/BRK.B.png	COMMON_STOCK	t	2026-06-06 14:55:18.683733+00	2026-06-06 14:55:18.683733+00	brk.b	\N	berkshire hathaway inc	brk.b berkshire hathaway inc
4086	LLY	NYSE	LLY	\N	Eli Lilly and Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/LLY.png	COMMON_STOCK	t	2026-06-06 14:55:19.176599+00	2026-06-06 14:55:19.176599+00	lly	\N	eli lilly and co	lly eli lilly and co
4087	MU	NASDAQ	MU	\N	Micron Technology Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MU.png	COMMON_STOCK	t	2026-06-06 14:55:19.658577+00	2026-06-06 14:55:19.658577+00	mu	\N	micron technology inc	mu micron technology inc
4088	WMT	NASDAQ	WMT	\N	Walmart Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/WMT.png	COMMON_STOCK	t	2026-06-06 14:55:20.141786+00	2026-06-06 14:55:20.141786+00	wmt	\N	walmart inc	wmt walmart inc
4089	JPM	NYSE	JPM	\N	JPMorgan Chase & Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/JPM.png	COMMON_STOCK	t	2026-06-06 14:58:33.074566+00	2026-06-06 14:58:33.074566+00	jpm	\N	jpmorgan chase & co	jpm jpmorgan chase & co
4090	AMD	NASDAQ	AMD	\N	Advanced Micro Devices Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AMD.png	COMMON_STOCK	t	2026-06-06 14:55:21.100626+00	2026-06-06 14:55:21.100626+00	amd	\N	advanced micro devices inc	amd advanced micro devices inc
4091	ASML	NYSE	ASML	\N	ASML Holding NV	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ASML.AS.png	COMMON_STOCK	t	2026-06-06 14:55:21.596384+00	2026-06-06 14:55:21.596384+00	asml	\N	asml holding nv	asml asml holding nv
4092	XOM	NYSE	XOM	\N	Exxon Mobil Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/XOM.png	COMMON_STOCK	t	2026-06-06 14:55:22.097732+00	2026-06-06 14:55:22.097732+00	xom	\N	exxon mobil corp	xom exxon mobil corp
4093	ORCL	NYSE	ORCL	\N	Oracle Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ORCL.png	COMMON_STOCK	t	2026-06-06 14:55:22.568255+00	2026-06-06 14:55:22.568255+00	orcl	\N	oracle corp	orcl oracle corp
4094	V	NYSE	V	\N	Visa Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/V.png	COMMON_STOCK	t	2026-06-06 14:55:23.055071+00	2026-06-06 14:55:23.055071+00	v	\N	visa inc	v visa inc
4095	JNJ	NYSE	JNJ	\N	Johnson & Johnson	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/JNJ.png	COMMON_STOCK	t	2026-06-06 14:55:23.53604+00	2026-06-06 14:55:23.53604+00	jnj	\N	johnson & johnson	jnj johnson & johnson
4096	INTC	NASDAQ	INTC	\N	Intel Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/INTC.png	COMMON_STOCK	t	2026-06-06 14:55:24.035641+00	2026-06-06 14:55:24.035641+00	intc	\N	intel corp	intc intel corp
4097	CSCO	NASDAQ	CSCO	\N	Cisco Systems Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950800186156.png	COMMON_STOCK	t	2026-06-06 14:55:24.531489+00	2026-06-06 14:55:24.531489+00	csco	\N	cisco systems inc	csco cisco systems inc
4098	MA	NYSE	MA	\N	Mastercard Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MA.png	COMMON_STOCK	t	2026-06-06 14:55:25.007326+00	2026-06-06 14:55:25.007326+00	ma	\N	mastercard inc	ma mastercard inc
4099	COST	NASDAQ	COST	\N	Costco Wholesale Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/COST.png	COMMON_STOCK	t	2026-06-06 14:58:37.937349+00	2026-06-06 14:58:37.937349+00	cost	\N	costco wholesale corp	cost costco wholesale corp
4100	CAT	NYSE	CAT	\N	Caterpillar Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/CAT.png	COMMON_STOCK	t	2026-06-06 14:55:25.965562+00	2026-06-06 14:55:25.965562+00	cat	\N	caterpillar inc	cat caterpillar inc
4101	ABBV	NYSE	ABBV	\N	AbbVie Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ABBV.png	COMMON_STOCK	t	2026-06-06 14:55:26.447433+00	2026-06-06 14:55:26.447433+00	abbv	\N	abbvie inc	abbv abbvie inc
4102	BAC	NYSE	BAC	\N	Bank of America Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/BAC.png	COMMON_STOCK	t	2026-06-06 14:55:26.927132+00	2026-06-06 14:55:26.927132+00	bac	\N	bank of america corp	bac bank of america corp
4103	LRCX	NASDAQ	LRCX	\N	Lam Research Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/LRCX.png	COMMON_STOCK	t	2026-06-06 14:55:27.429797+00	2026-06-06 14:55:27.429797+00	lrcx	\N	lam research corp	lrcx lam research corp
4104	CVX	NYSE	CVX	\N	Chevron Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/CVX.png	COMMON_STOCK	t	2026-06-06 14:55:27.90247+00	2026-06-06 14:55:27.90247+00	cvx	\N	chevron corp	cvx chevron corp
4105	ARM	NASDAQ	ARM	\N	Arm Holdings PLC	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950867383596.png	COMMON_STOCK	t	2026-06-06 14:55:28.393092+00	2026-06-06 14:55:28.393092+00	arm	\N	arm holdings plc	arm arm holdings plc
4106	UNH	NYSE	UNH	\N	UnitedHealth Group Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/UNH.png	COMMON_STOCK	t	2026-06-06 14:55:28.886156+00	2026-06-06 14:55:28.886156+00	unh	\N	unitedhealth group inc	unh unitedhealth group inc
4107	AMAT	NASDAQ	AMAT	\N	Applied Materials Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AMAT.png	COMMON_STOCK	t	2026-06-06 14:55:29.372655+00	2026-06-06 14:55:29.372655+00	amat	\N	applied materials inc	amat applied materials inc
4108	NFLX	NASDAQ	NFLX	\N	Netflix Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/NFLX.png	COMMON_STOCK	t	2026-06-06 14:55:29.872915+00	2026-06-06 14:55:29.872915+00	nflx	\N	netflix inc	nflx netflix inc
4109	GE	NYSE	GE	\N	General Electric Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/GE.png	COMMON_STOCK	t	2026-06-06 14:55:30.355373+00	2026-06-06 14:55:30.355373+00	ge	\N	general electric co	ge general electric co
4110	KO	NYSE	KO	\N	Coca-Cola Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/KO.png	COMMON_STOCK	t	2026-06-06 14:55:30.853598+00	2026-06-06 14:55:30.853598+00	ko	\N	coca-cola co	ko coca-cola co
4111	PG	NYSE	PG	\N	Procter & Gamble Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/PG.png	COMMON_STOCK	t	2026-06-06 14:55:31.351334+00	2026-06-06 14:55:31.351334+00	pg	\N	procter & gamble co	pg procter & gamble co
4112	MS	NYSE	MS	\N	Morgan Stanley	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MS.png	COMMON_STOCK	t	2026-06-06 14:55:31.863845+00	2026-06-06 14:55:31.863845+00	ms	\N	morgan stanley	ms morgan stanley
4113	PLTR	NASDAQ	PLTR	\N	Palantir Technologies Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/PLTR.png	COMMON_STOCK	t	2026-06-06 14:55:32.357664+00	2026-06-06 14:55:32.357664+00	pltr	\N	palantir technologies inc	pltr palantir technologies inc
4114	GS	NYSE	GS	\N	Goldman Sachs Group Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/GS.png	COMMON_STOCK	t	2026-06-06 14:55:32.845414+00	2026-06-06 14:55:32.845414+00	gs	\N	goldman sachs group inc	gs goldman sachs group inc
4115	HSBC	NASDAQ	HSBC	\N	HSBC Holdings PLC	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/HSBA.L.png	COMMON_STOCK	t	2026-06-06 14:55:33.337713+00	2026-06-06 14:55:33.337713+00	hsbc	\N	hsbc holdings plc	hsbc hsbc holdings plc
4116	HD	NYSE	HD	\N	Home Depot Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/HD.png	COMMON_STOCK	t	2026-06-06 14:55:33.81757+00	2026-06-06 14:55:33.81757+00	hd	\N	home depot inc	hd home depot inc
4117	MRK	NYSE	MRK	\N	Merck & Co Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MRK.png	COMMON_STOCK	t	2026-06-06 14:55:34.286478+00	2026-06-06 14:55:34.286478+00	mrk	\N	merck & co inc	mrk merck & co inc
4118	AZN	NASDAQ	AZN	\N	AstraZeneca PLC	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AZN.L.png	COMMON_STOCK	t	2026-06-06 14:55:34.759672+00	2026-06-06 14:55:34.759672+00	azn	\N	astrazeneca plc	azn astrazeneca plc
4119	PM	NYSE	PM	\N	Philip Morris International Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/PM.png	COMMON_STOCK	t	2026-06-06 14:58:47.716856+00	2026-06-06 14:58:47.716856+00	pm	\N	philip morris international inc	pm philip morris international inc
4120	BABA	NYSE	BABA	\N	Alibaba Group Holding Ltd	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/BABA.png	COMMON_STOCK	t	2026-06-06 14:55:35.755043+00	2026-06-06 14:55:35.755043+00	baba	\N	alibaba group holding ltd	baba alibaba group holding ltd
4121	NVS	NASDAQ	NVS	\N	Novartis AG	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/NOVN.SW.png	COMMON_STOCK	t	2026-06-06 14:55:36.251504+00	2026-06-06 14:55:36.251504+00	nvs	\N	novartis ag	nvs novartis ag
4122	RY	NASDAQ	RY	\N	Royal Bank of Canada	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/RY.TO.png	COMMON_STOCK	t	2026-06-06 14:55:36.732957+00	2026-06-06 14:55:36.732957+00	ry	\N	royal bank of canada	ry royal bank of canada
4123	IBM	NYSE	IBM	\N	International Business Machines Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/IBM.png	COMMON_STOCK	t	2026-06-06 14:55:37.21379+00	2026-06-06 14:55:37.21379+00	ibm	\N	international business machines corp	ibm international business machines corp
4124	TXN	NASDAQ	TXN	\N	Texas Instruments Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/TXN.png	COMMON_STOCK	t	2026-06-06 14:55:37.687052+00	2026-06-06 14:55:37.687052+00	txn	\N	texas instruments inc	txn texas instruments inc
4125	DELL	NYSE	DELL	\N	Dell Technologies Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/DELL.png	COMMON_STOCK	t	2026-06-06 14:55:38.179482+00	2026-06-06 14:55:38.179482+00	dell	\N	dell technologies inc	dell dell technologies inc
4126	KLAC	NASDAQ	KLAC	\N	KLA Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/KLAC.png	COMMON_STOCK	t	2026-06-06 14:55:38.679279+00	2026-06-06 14:55:38.679279+00	klac	\N	kla corp	klac kla corp
4127	GEV	NYSE	GEV	\N	GE Vernova Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950867201126.png	COMMON_STOCK	t	2026-06-06 14:55:39.160716+00	2026-06-06 14:55:39.160716+00	gev	\N	ge vernova inc	gev ge vernova inc
4128	WFC	NYSE	WFC	\N	Wells Fargo & Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/WFC.png	COMMON_STOCK	t	2026-06-06 14:55:39.643304+00	2026-06-06 14:55:39.643304+00	wfc	\N	wells fargo & co	wfc wells fargo & co
4129	RTX	NYSE	RTX	\N	RTX Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/RTX.png	COMMON_STOCK	t	2026-06-06 14:55:40.142803+00	2026-06-06 14:55:40.142803+00	rtx	\N	rtx corp	rtx rtx corp
4130	SHEL	NASDAQ	SHEL	\N	Shell PLC	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/SHEL.L.png	COMMON_STOCK	t	2026-06-06 14:58:53.099674+00	2026-06-06 14:58:53.099674+00	shel	\N	shell plc	shel shell plc
4131	LIN	NASDAQ	LIN	\N	Linde PLC	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950838588696.png	COMMON_STOCK	t	2026-06-06 14:55:41.111193+00	2026-06-06 14:55:41.111193+00	lin	\N	linde plc	lin linde plc
4132	TM	NASDAQ	TM	\N	Toyota Motor Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/7203.T.png	COMMON_STOCK	t	2026-06-06 14:55:41.590252+00	2026-06-06 14:55:41.590252+00	tm	\N	toyota motor corp	tm toyota motor corp
4133	SNDK	NASDAQ	SNDK	\N	Sandisk Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950906460416.png	COMMON_STOCK	t	2026-06-06 14:55:42.066391+00	2026-06-06 14:55:42.066391+00	sndk	\N	sandisk corp	sndk sandisk corp
4134	MRVL	NASDAQ	MRVL	\N	Marvell Technology Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MRVL.png	COMMON_STOCK	t	2026-06-06 14:55:42.561179+00	2026-06-06 14:55:42.561179+00	mrvl	\N	marvell technology inc	mrvl marvell technology inc
4135	QCOM	NASDAQ	QCOM	\N	Qualcomm Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/QCOM.png	COMMON_STOCK	t	2026-06-06 14:55:43.029075+00	2026-06-06 14:55:43.029075+00	qcom	\N	qualcomm inc	qcom qualcomm inc
4136	MUFG	NASDAQ	MUFG	\N	Mitsubishi UFJ Financial Group, Inc.		COMMON_STOCK	t	2026-06-06 14:55:43.532337+00	2026-06-06 14:55:43.532337+00	mufg	\N	mitsubishi ufj financial group, inc.	mufg mitsubishi ufj financial group, inc.
4137	C	NASDAQ	C	\N	Citigroup Inc.		COMMON_STOCK	t	2026-06-06 14:55:44.012331+00	2026-06-06 14:55:44.012331+00	c	\N	citigroup inc.	c citigroup inc.
4138	PANW	NASDAQ	PANW	\N	Palo Alto Networks, Inc.		COMMON_STOCK	t	2026-06-06 14:55:44.495756+00	2026-06-06 14:55:44.495756+00	panw	\N	palo alto networks, inc.	panw palo alto networks, inc.
4139	BHP	NASDAQ	BHP	\N	BHP Group Limited		COMMON_STOCK	t	2026-06-06 14:55:44.974234+00	2026-06-06 14:55:44.974234+00	bhp	\N	bhp group limited	bhp bhp group limited
4140	SAP	NASDAQ	SAP	\N	SAP SE		COMMON_STOCK	t	2026-06-06 14:58:57.910318+00	2026-06-06 14:58:57.910318+00	sap	\N	sap se	sap sap se
4141	AXP	NASDAQ	AXP	\N	American Express Company		COMMON_STOCK	t	2026-06-06 14:55:45.961544+00	2026-06-06 14:55:45.961544+00	axp	\N	american express company	axp american express company
4142	MCD	NASDAQ	MCD	\N	McDonald's Corporation		COMMON_STOCK	t	2026-06-06 14:55:46.439053+00	2026-06-06 14:55:46.439053+00	mcd	\N	mcdonald's corporation	mcd mcdonald's corporation
4143	TTE	NASDAQ	TTE	\N	TotalEnergies SE		COMMON_STOCK	t	2026-06-06 14:55:46.938312+00	2026-06-06 14:55:46.938312+00	tte	\N	totalenergies se	tte totalenergies se
4144	NVO	NASDAQ	NVO	\N	Novo Nordisk A/S		COMMON_STOCK	t	2026-06-06 14:55:47.408901+00	2026-06-06 14:55:47.408901+00	nvo	\N	novo nordisk a/s	nvo novo nordisk a/s
4145	ADI	NASDAQ	ADI	\N	Analog Devices, Inc.		COMMON_STOCK	t	2026-06-06 14:55:47.887891+00	2026-06-06 14:55:47.887891+00	adi	\N	analog devices, inc.	adi analog devices, inc.
4146	ANET	NASDAQ	ANET	\N	Arista Networks, Inc.		COMMON_STOCK	t	2026-06-06 14:55:48.392677+00	2026-06-06 14:55:48.392677+00	anet	\N	arista networks, inc.	anet arista networks, inc.
4147	PEP	NASDAQ	PEP	\N	PepsiCo, Inc.		COMMON_STOCK	t	2026-06-06 14:55:48.870041+00	2026-06-06 14:55:48.870041+00	pep	\N	pepsico, inc.	pep pepsico, inc.
4148	TMUS	NASDAQ	TMUS	\N	T-Mobile US, Inc.		COMMON_STOCK	t	2026-06-06 14:55:49.360041+00	2026-06-06 14:55:49.360041+00	tmus	\N	t-mobile us, inc.	tmus t-mobile us, inc.
4149	STX	NASDAQ	STX	\N	Seagate Technology Holdings plc		COMMON_STOCK	t	2026-06-06 14:55:49.852741+00	2026-06-06 14:55:49.852741+00	stx	\N	seagate technology holdings plc	stx seagate technology holdings plc
4150	VZ	NASDAQ	VZ	\N	Verizon Communications Inc.		COMMON_STOCK	t	2026-06-06 14:55:50.34627+00	2026-06-06 14:55:50.34627+00	vz	\N	verizon communications inc.	vz verizon communications inc.
4151	AMGN	NASDAQ	AMGN	\N	Amgen Inc.		COMMON_STOCK	t	2026-06-06 14:55:50.826011+00	2026-06-06 14:55:50.826011+00	amgn	\N	amgen inc.	amgn amgen inc.
4152	APP	NASDAQ	APP	\N	AppLovin Corporation		COMMON_STOCK	t	2026-06-06 14:55:51.318581+00	2026-06-06 14:55:51.318581+00	app	\N	applovin corporation	app applovin corporation
4153	TD	NASDAQ	TD	\N	The Toronto-Dominion Bank		COMMON_STOCK	t	2026-06-06 14:55:51.784493+00	2026-06-06 14:55:51.784493+00	td	\N	the toronto-dominion bank	td the toronto-dominion bank
4154	NEE	NASDAQ	NEE	\N	NextEra Energy, Inc.		COMMON_STOCK	t	2026-06-06 14:55:52.255646+00	2026-06-06 14:55:52.255646+00	nee	\N	nextera energy, inc.	nee nextera energy, inc.
4155	TJX	NASDAQ	TJX	\N	The TJX Companies, Inc.		COMMON_STOCK	t	2026-06-06 14:55:52.723838+00	2026-06-06 14:55:52.723838+00	tjx	\N	the tjx companies, inc.	tjx the tjx companies, inc.
4156	SAN	NASDAQ	SAN	\N	Banco Santander, S.A.		COMMON_STOCK	t	2026-06-06 14:55:53.211383+00	2026-06-06 14:55:53.211383+00	san	\N	banco santander, s.a.	san banco santander, s.a.
4157	WDC	NASDAQ	WDC	\N	Western Digital Corporation		COMMON_STOCK	t	2026-06-06 14:55:53.710954+00	2026-06-06 14:55:53.710954+00	wdc	\N	western digital corporation	wdc western digital corporation
4158	RIO	NASDAQ	RIO	\N	Rio Tinto Group		COMMON_STOCK	t	2026-06-06 14:55:54.203305+00	2026-06-06 14:55:54.203305+00	rio	\N	rio tinto group	rio rio tinto group
4159	TMO	NASDAQ	TMO	\N	Thermo Fisher Scientific Inc.		COMMON_STOCK	t	2026-06-06 14:55:54.68147+00	2026-06-06 14:55:54.68147+00	tmo	\N	thermo fisher scientific inc.	tmo thermo fisher scientific inc.
4160	DIS	NASDAQ	DIS	\N	The Walt Disney Company		COMMON_STOCK	t	2026-06-06 14:55:55.158943+00	2026-06-06 14:55:55.158943+00	dis	\N	the walt disney company	dis the walt disney company
4161	CRWD	NASDAQ	CRWD	\N	CrowdStrike Holdings, Inc.		COMMON_STOCK	t	2026-06-06 14:59:08.101149+00	2026-06-06 14:59:08.101149+00	crwd	\N	crowdstrike holdings, inc.	crwd crowdstrike holdings, inc.
4162	APH	NASDAQ	APH	\N	Amphenol Corporation		COMMON_STOCK	t	2026-06-06 14:55:56.136166+00	2026-06-06 14:55:56.136166+00	aph	\N	amphenol corporation	aph amphenol corporation
4163	BA	NASDAQ	BA	\N	The Boeing Company		COMMON_STOCK	t	2026-06-06 14:55:56.624557+00	2026-06-06 14:55:56.624557+00	ba	\N	the boeing company	ba the boeing company
4164	BLK	NASDAQ	BLK	\N	BlackRock, Inc.		COMMON_STOCK	t	2026-06-06 14:55:57.119657+00	2026-06-06 14:55:57.119657+00	blk	\N	blackrock, inc.	blk blackrock, inc.
4165	UNP	NASDAQ	UNP	\N	Union Pacific Corporation		COMMON_STOCK	t	2026-06-06 14:55:57.59802+00	2026-06-06 14:55:57.59802+00	unp	\N	union pacific corporation	unp union pacific corporation
4166	GILD	NASDAQ	GILD	\N	Gilead Sciences, Inc.		COMMON_STOCK	t	2026-06-06 14:55:58.073754+00	2026-06-06 14:55:58.073754+00	gild	\N	gilead sciences, inc.	gild gilead sciences, inc.
4167	ABT	NASDAQ	ABT	\N	Abbott Laboratories		COMMON_STOCK	t	2026-06-06 14:55:58.565462+00	2026-06-06 14:55:58.565462+00	abt	\N	abbott laboratories	abt abbott laboratories
4168	T	NASDAQ	T	\N	AT&T Inc.		COMMON_STOCK	t	2026-06-06 14:55:59.05077+00	2026-06-06 14:55:59.05077+00	t	\N	at&t inc.	t at&t inc.
4169	DE	NASDAQ	DE	\N	Deere & Company		COMMON_STOCK	t	2026-06-06 14:55:59.543214+00	2026-06-06 14:55:59.543214+00	de	\N	deere & company	de deere & company
4170	SCHW	NASDAQ	SCHW	\N	The Charles Schwab Corporation		COMMON_STOCK	t	2026-06-06 14:56:00.029319+00	2026-06-06 14:56:00.029319+00	schw	\N	the charles schwab corporation	schw the charles schwab corporation
4171	ETN	NASDAQ	ETN	\N	Eaton Corporation plc		COMMON_STOCK	t	2026-06-06 14:59:12.969851+00	2026-06-06 14:59:12.969851+00	etn	\N	eaton corporation plc	etn eaton corporation plc
4172	GLW	NASDAQ	GLW	\N	Corning Incorporated		COMMON_STOCK	t	2026-06-06 14:56:00.995381+00	2026-06-06 14:56:00.995381+00	glw	\N	corning incorporated	glw corning incorporated
4173	BUD	NASDAQ	BUD	\N	Anheuser-Busch InBev SA/NV		COMMON_STOCK	t	2026-06-06 14:56:01.47003+00	2026-06-06 14:56:01.47003+00	bud	\N	anheuser-busch inbev sa/nv	bud anheuser-busch inbev sa/nv
4174	CRM	NASDAQ	CRM	\N	Salesforce, Inc.		COMMON_STOCK	t	2026-06-06 14:56:01.940713+00	2026-06-06 14:56:01.940713+00	crm	\N	salesforce, inc.	crm salesforce, inc.
4175	ISRG	NASDAQ	ISRG	\N	Intuitive Surgical, Inc.		COMMON_STOCK	t	2026-06-06 14:56:02.420235+00	2026-06-06 14:56:02.420235+00	isrg	\N	intuitive surgical, inc.	isrg intuitive surgical, inc.
4176	PFE	NASDAQ	PFE	\N	Pfizer Inc.		COMMON_STOCK	t	2026-06-06 14:56:02.909166+00	2026-06-06 14:56:02.909166+00	pfe	\N	pfizer inc.	pfe pfizer inc.
4177	SMFG	NASDAQ	SMFG	\N	Sumitomo Mitsui Financial Group, Inc.		COMMON_STOCK	t	2026-06-06 14:56:03.379642+00	2026-06-06 14:56:03.379642+00	smfg	\N	sumitomo mitsui financial group, inc.	smfg sumitomo mitsui financial group, inc.
4178	WELL	NASDAQ	WELL	\N	Welltower Inc.		COMMON_STOCK	t	2026-06-06 14:56:03.855953+00	2026-06-06 14:56:03.855953+00	well	\N	welltower inc.	well welltower inc.
4179	SCCO	NASDAQ	SCCO	\N	Southern Copper Corporation		COMMON_STOCK	t	2026-06-06 14:56:04.348762+00	2026-06-06 14:56:04.348762+00	scco	\N	southern copper corporation	scco southern copper corporation
4180	UBS	NASDAQ	UBS	\N	UBS Group AG		COMMON_STOCK	t	2026-06-06 14:56:04.828256+00	2026-06-06 14:56:04.828256+00	ubs	\N	ubs group ag	ubs ubs group ag
4181	UBER	NASDAQ	UBER	\N	Uber Technologies, Inc.		COMMON_STOCK	t	2026-06-06 14:59:17.772876+00	2026-06-06 14:59:17.772876+00	uber	\N	uber technologies, inc.	uber uber technologies, inc.
4182	COP	NASDAQ	COP	\N	ConocoPhillips		COMMON_STOCK	t	2026-06-06 14:56:05.795211+00	2026-06-06 14:56:05.795211+00	cop	\N	conocophillips	cop conocophillips
4183	SHOP	NASDAQ	SHOP	\N	Shopify Inc.		COMMON_STOCK	t	2026-06-06 14:56:06.282947+00	2026-06-06 14:56:06.282947+00	shop	\N	shopify inc.	shop shopify inc.
4184	BX	NASDAQ	BX	\N	Blackstone Inc.		COMMON_STOCK	t	2026-06-06 14:56:06.760806+00	2026-06-06 14:56:06.760806+00	bx	\N	blackstone inc.	bx blackstone inc.
4185	PLD	NASDAQ	PLD	\N	Prologis, Inc.		COMMON_STOCK	t	2026-06-06 14:56:07.255963+00	2026-06-06 14:56:07.255963+00	pld	\N	prologis, inc.	pld prologis, inc.
4186	HON	NASDAQ	HON	\N	Honeywell International Inc.		COMMON_STOCK	t	2026-06-06 14:56:07.754926+00	2026-06-06 14:56:07.754926+00	hon	\N	honeywell international inc.	hon honeywell international inc.
4187	SONY	NASDAQ	SONY	\N	Sony Group Corporation		COMMON_STOCK	t	2026-06-06 14:56:08.237602+00	2026-06-06 14:56:08.237602+00	sony	\N	sony group corporation	sony sony group corporation
4188	DHR	NASDAQ	DHR	\N	Danaher Corporation		COMMON_STOCK	t	2026-06-06 14:56:08.733698+00	2026-06-06 14:56:08.733698+00	dhr	\N	danaher corporation	dhr danaher corporation
4189	BKNG	NASDAQ	BKNG	\N	Booking Holdings Inc.		COMMON_STOCK	t	2026-06-06 14:56:09.221626+00	2026-06-06 14:56:09.221626+00	bkng	\N	booking holdings inc.	bkng booking holdings inc.
4190	BTI	NASDAQ	BTI	\N	British American Tobacco p.l.c.		COMMON_STOCK	t	2026-06-06 14:56:09.719746+00	2026-06-06 14:56:09.719746+00	bti	\N	british american tobacco p.l.c.	bti british american tobacco p.l.c.
4191	CB	NASDAQ	CB	\N	Chubb Limited		COMMON_STOCK	t	2026-06-06 14:56:10.231965+00	2026-06-06 14:56:10.231965+00	cb	\N	chubb limited	cb chubb limited
4192	SPGI	NASDAQ	SPGI	\N	S&P Global Inc.		COMMON_STOCK	t	2026-06-06 14:59:23.167673+00	2026-06-06 14:59:23.167673+00	spgi	\N	s&p global inc.	spgi s&p global inc.
4193	BBVA	NASDAQ	BBVA	\N	Banco Bilbao Vizcaya Argentaria, S.A.		COMMON_STOCK	t	2026-06-06 14:56:11.203405+00	2026-06-06 14:56:11.203405+00	bbva	\N	banco bilbao vizcaya argentaria, s.a.	bbva banco bilbao vizcaya argentaria, s.a.
4194	ENB	NASDAQ	ENB	\N	Enbridge Inc.		COMMON_STOCK	t	2026-06-06 14:56:11.677338+00	2026-06-06 14:56:11.677338+00	enb	\N	enbridge inc.	enb enbridge inc.
4195	CVS	NASDAQ	CVS	\N	CVS Health Corporation		COMMON_STOCK	t	2026-06-06 14:56:12.191684+00	2026-06-06 14:56:12.191684+00	cvs	\N	cvs health corporation	cvs cvs health corporation
4196	UL	NASDAQ	UL	\N	Unilever PLC		COMMON_STOCK	t	2026-06-06 14:56:12.864729+00	2026-06-06 14:56:12.864729+00	ul	\N	unilever plc	ul unilever plc
4197	PDD	NASDAQ	PDD	\N	PDD Holdings Inc.		COMMON_STOCK	t	2026-06-06 14:56:13.345317+00	2026-06-06 14:56:13.345317+00	pdd	\N	pdd holdings inc.	pdd pdd holdings inc.
4198	LMT	NASDAQ	LMT	\N	Lockheed Martin Corporation		COMMON_STOCK	t	2026-06-06 14:56:13.831636+00	2026-06-06 14:56:13.831636+00	lmt	\N	lockheed martin corporation	lmt lockheed martin corporation
4199	HDB	NASDAQ	HDB	\N	HDFC Bank Ltd	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/HDFCBANK.NS.png	COMMON_STOCK	t	2026-06-06 14:56:14.314499+00	2026-06-06 14:56:14.314499+00	hdb	\N	hdfc bank ltd	hdb hdfc bank ltd
4200	MO	NYSE	MO	\N	Altria Group Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MO.png	COMMON_STOCK	t	2026-06-06 14:56:14.806566+00	2026-06-06 14:56:14.806566+00	mo	\N	altria group inc	mo altria group inc
4201	PGR	NYSE	PGR	\N	Progressive Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/PGR.png	COMMON_STOCK	t	2026-06-06 14:56:15.307827+00	2026-06-06 14:56:15.307827+00	pgr	\N	progressive corp	pgr progressive corp
4202	LOW	NYSE	LOW	\N	Lowe's Companies Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/LOW.png	COMMON_STOCK	t	2026-06-06 14:56:15.786749+00	2026-06-06 14:56:15.786749+00	low	\N	lowe's companies inc	low lowe's companies inc
4203	MFG	NASDAQ	MFG	\N	Mizuho Financial Group Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/8411.T.png	COMMON_STOCK	t	2026-06-06 14:56:16.275884+00	2026-06-06 14:56:16.275884+00	mfg	\N	mizuho financial group inc	mfg mizuho financial group inc
4204	SYK	NYSE	SYK	\N	Stryker Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/SYK.png	COMMON_STOCK	t	2026-06-06 14:56:16.773637+00	2026-06-06 14:56:16.773637+00	syk	\N	stryker corp	syk stryker corp
4205	BMY	NYSE	BMY	\N	Bristol-Myers Squibb Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/BMY.png	COMMON_STOCK	t	2026-06-06 14:56:17.26966+00	2026-06-06 14:56:17.26966+00	bmy	\N	bristol-myers squibb co	bmy bristol-myers squibb co
4206	NOW	NYSE	NOW	\N	ServiceNow Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/NOW.png	COMMON_STOCK	t	2026-06-06 14:56:17.745308+00	2026-06-06 14:56:17.745308+00	now	\N	servicenow inc	now servicenow inc
4207	VRT	NYSE	VRT	\N	Vertiv Holdings Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/VRT.png	COMMON_STOCK	t	2026-06-06 14:56:18.229926+00	2026-06-06 14:56:18.229926+00	vrt	\N	vertiv holdings co	vrt vertiv holdings co
4208	BMO	NASDAQ	BMO	\N	Bank of Montreal	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/BMO.TO.png	COMMON_STOCK	t	2026-06-06 14:56:18.714443+00	2026-06-06 14:56:18.714443+00	bmo	\N	bank of montreal	bmo bank of montreal
4209	VRTX	NASDAQ	VRTX	\N	Vertex Pharmaceuticals Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/VRTX.png	COMMON_STOCK	t	2026-06-06 14:56:19.213541+00	2026-06-06 14:56:19.213541+00	vrtx	\N	vertex pharmaceuticals inc	vrtx vertex pharmaceuticals inc
4210	BP	NASDAQ	BP	\N	BP PLC	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/BP.L.png	COMMON_STOCK	t	2026-06-06 14:56:19.682506+00	2026-06-06 14:56:19.682506+00	bp	\N	bp plc	bp bp plc
4211	COF	NYSE	COF	\N	Capital One Financial Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/COF.png	COMMON_STOCK	t	2026-06-06 14:56:20.184112+00	2026-06-06 14:56:20.184112+00	cof	\N	capital one financial corp	cof capital one financial corp
4212	PH	NYSE	PH	\N	Parker-Hannifin Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/PH.png	COMMON_STOCK	t	2026-06-06 14:59:33.130424+00	2026-06-06 14:59:33.130424+00	ph	\N	parker-hannifin corp	ph parker-hannifin corp
4213	PBR	NASDAQ	PBR	\N	Petroleo Brasileiro SA Petrobras	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/PETR4.SA.png	COMMON_STOCK	t	2026-06-06 14:56:21.166892+00	2026-06-06 14:56:21.166892+00	pbr	\N	petroleo brasileiro sa petrobras	pbr petroleo brasileiro sa petrobras
4214	PBR.A	NYSE	PBR.A	\N	Petroleo Brasileiro SA Petrobras	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/PETR4.SA.png	COMMON_STOCK	t	2026-06-06 14:56:21.644243+00	2026-06-06 14:56:21.644243+00	pbr.a	\N	petroleo brasileiro sa petrobras	pbr.a petroleo brasileiro sa petrobras
4215	ACN	NYSE	ACN	\N	Accenture PLC	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ACN.png	COMMON_STOCK	t	2026-06-06 14:56:22.141709+00	2026-06-06 14:56:22.141709+00	acn	\N	accenture plc	acn accenture plc
4216	SBUX	NASDAQ	SBUX	\N	Starbucks Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/SBUX.png	COMMON_STOCK	t	2026-06-06 14:56:22.659619+00	2026-06-06 14:56:22.659619+00	sbux	\N	starbucks corp	sbux starbucks corp
4217	SNY	NYSE	SNY	\N	Sanofi SA	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/SAN.PA.png	COMMON_STOCK	t	2026-06-06 14:56:23.133279+00	2026-06-06 14:56:23.133279+00	sny	\N	sanofi sa	sny sanofi sa
4218	EQIX	NASDAQ	EQIX	\N	Equinix Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/942959004916.png	COMMON_STOCK	t	2026-06-06 14:56:23.599097+00	2026-06-06 14:56:23.599097+00	eqix	\N	equinix inc	eqix equinix inc
4219	NEM	NYSE	NEM	\N	Newmont Corporation	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/NEM.png	COMMON_STOCK	t	2026-06-06 14:56:24.083127+00	2026-06-06 14:56:24.083127+00	nem	\N	newmont corporation	nem newmont corporation
4220	FTNT	NASDAQ	FTNT	\N	Fortinet Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/FTNT.png	COMMON_STOCK	t	2026-06-06 14:56:24.566812+00	2026-06-06 14:56:24.566812+00	ftnt	\N	fortinet inc	ftnt fortinet inc
4221	MDT	NYSE	MDT	\N	Medtronic PLC	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MDT.png	COMMON_STOCK	t	2026-06-06 14:56:25.054716+00	2026-06-06 14:56:25.054716+00	mdt	\N	medtronic plc	mdt medtronic plc
4222	SO	NYSE	SO	\N	Southern Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/SO.png	COMMON_STOCK	t	2026-06-06 14:59:38.011129+00	2026-06-06 14:59:38.011129+00	so	\N	southern co	so southern co
4223	SOMN	NYSE	SOMN	\N	Southern Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/SO.png	COMMON_STOCK	t	2026-06-06 14:56:26.041899+00	2026-06-06 14:56:26.041899+00	somn	\N	southern co	somn southern co
4224	PWR	NYSE	PWR	\N	Quanta Services Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/PWR.png	COMMON_STOCK	t	2026-06-06 14:56:26.522167+00	2026-06-06 14:56:26.522167+00	pwr	\N	quanta services inc	pwr quanta services inc
4225	CDNS	NASDAQ	CDNS	\N	Cadence Design Systems Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/CDNS.png	COMMON_STOCK	t	2026-06-06 14:56:27.028797+00	2026-06-06 14:56:27.028797+00	cdns	\N	cadence design systems inc	cdns cadence design systems inc
4226	MAR	NASDAQ	MAR	\N	Marriott International Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MAR.png	COMMON_STOCK	t	2026-06-06 14:56:27.507882+00	2026-06-06 14:56:27.507882+00	mar	\N	marriott international inc	mar marriott international inc
4227	GSK	NASDAQ	GSK	\N	GSK plc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/GSK.L.png	COMMON_STOCK	t	2026-06-06 14:56:27.994156+00	2026-06-06 14:56:27.994156+00	gsk	\N	gsk plc	gsk gsk plc
4228	SPOT	NYSE	SPOT	\N	Spotify Technology SA	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/SPOT.png	COMMON_STOCK	t	2026-06-06 14:56:28.460071+00	2026-06-06 14:56:28.460071+00	spot	\N	spotify technology sa	spot spotify technology sa
4229	ADBE	NASDAQ	ADBE	\N	Adobe Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ADBE.png	COMMON_STOCK	t	2026-06-06 14:56:28.935261+00	2026-06-06 14:56:28.935261+00	adbe	\N	adobe inc	adbe adobe inc
4230	TT	NYSE	TT	\N	Trane Technologies PLC	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/TT.png	COMMON_STOCK	t	2026-06-06 14:56:29.42763+00	2026-06-06 14:56:29.42763+00	tt	\N	trane technologies plc	tt trane technologies plc
4231	HWM	NYSE	HWM	\N	Howmet Aerospace Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/HWM.png	COMMON_STOCK	t	2026-06-06 14:56:29.924477+00	2026-06-06 14:56:29.924477+00	hwm	\N	howmet aerospace inc	hwm howmet aerospace inc
4232	CM	NASDAQ	CM	\N	Canadian Imperial Bank of Commerce	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/CM.TO.png	COMMON_STOCK	t	2026-06-06 14:56:30.412846+00	2026-06-06 14:56:30.412846+00	cm	\N	canadian imperial bank of commerce	cm canadian imperial bank of commerce
4233	BN	NYSE	BN	\N	Brookfield Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/BAM.png	COMMON_STOCK	t	2026-06-06 14:56:30.911697+00	2026-06-06 14:56:30.911697+00	bn	\N	brookfield corp	bn brookfield corp
4234	BNS	NASDAQ	BNS	\N	Bank of Nova Scotia	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/BNS.TO.png	COMMON_STOCK	t	2026-06-06 14:56:31.391095+00	2026-06-06 14:56:31.391095+00	bns	\N	bank of nova scotia	bns bank of nova scotia
4235	BNY	NYSE	BNY	\N	Bank of New York Mellon Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/BK.png	COMMON_STOCK	t	2026-06-06 14:56:31.872668+00	2026-06-06 14:56:31.872668+00	bny	\N	bank of new york mellon corp	bny bank of new york mellon corp
4236	DUK	NYSE	DUK	\N	Duke Energy Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/DUK.png	COMMON_STOCK	t	2026-06-06 14:56:32.386686+00	2026-06-06 14:56:32.386686+00	duk	\N	duke energy corp	duk duke energy corp
4237	CNQ	NASDAQ	CNQ	\N	Canadian Natural Resources Ltd	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/CNQ.TO.png	COMMON_STOCK	t	2026-06-06 14:56:32.884205+00	2026-06-06 14:56:32.884205+00	cnq	\N	canadian natural resources ltd	cnq canadian natural resources ltd
4238	IBN	NASDAQ	IBN	\N	ICICI Bank Ltd	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ICICIBANK.NS.png	COMMON_STOCK	t	2026-06-06 14:56:33.374605+00	2026-06-06 14:56:33.374605+00	ibn	\N	icici bank ltd	ibn icici bank ltd
4239	GD	NYSE	GD	\N	General Dynamics Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/GD.png	COMMON_STOCK	t	2026-06-06 14:56:33.867976+00	2026-06-06 14:56:33.867976+00	gd	\N	general dynamics corp	gd general dynamics corp
4240	EQNR	NASDAQ	EQNR	\N	Equinor ASA	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/EQNR.OL.png	COMMON_STOCK	t	2026-06-06 14:56:34.362995+00	2026-06-06 14:56:34.362995+00	eqnr	\N	equinor asa	eqnr equinor asa
4241	CME	NASDAQ	CME	\N	CME Group Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/CME.png	COMMON_STOCK	t	2026-06-06 14:56:34.880273+00	2026-06-06 14:56:34.880273+00	cme	\N	cme group inc	cme cme group inc
4242	MCK	NYSE	MCK	\N	McKesson Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MCK.png	COMMON_STOCK	t	2026-06-06 14:59:47.826452+00	2026-06-06 14:59:47.826452+00	mck	\N	mckesson corp	mck mckesson corp
4243	ADP	NASDAQ	ADP	\N	Automatic Data Processing Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ADP.png	COMMON_STOCK	t	2026-06-06 14:56:35.849861+00	2026-06-06 14:56:35.849861+00	adp	\N	automatic data processing inc	adp automatic data processing inc
4244	UPS	NYSE	UPS	\N	United Parcel Service Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/UPS.png	COMMON_STOCK	t	2026-06-06 14:56:36.330128+00	2026-06-06 14:56:36.330128+00	ups	\N	united parcel service inc	ups united parcel service inc
4245	PNC	NYSE	PNC	\N	PNC Financial Services Group Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/PNC.png	COMMON_STOCK	t	2026-06-06 14:56:36.828367+00	2026-06-06 14:56:36.828367+00	pnc	\N	pnc financial services group inc	pnc pnc financial services group inc
4246	FCX	NYSE	FCX	\N	Freeport-McMoRan Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/FCX.png	COMMON_STOCK	t	2026-06-06 14:56:37.321908+00	2026-06-06 14:56:37.321908+00	fcx	\N	freeport-mcmoran inc	fcx freeport-mcmoran inc
4247	CEG	NASDAQ	CEG	\N	Constellation Energy Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950815008846.png	COMMON_STOCK	t	2026-06-06 14:56:37.797834+00	2026-06-06 14:56:37.797834+00	ceg	\N	constellation energy corp	ceg constellation energy corp
4248	AMT	NYSE	AMT	\N	American Tower Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/942959033886.png	COMMON_STOCK	t	2026-06-06 14:56:38.296679+00	2026-06-06 14:56:38.296679+00	amt	\N	american tower corp	amt american tower corp
4249	ELV	NYSE	ELV	\N	Elevance Health Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ANTM.png	COMMON_STOCK	t	2026-06-06 14:56:38.778064+00	2026-06-06 14:56:38.778064+00	elv	\N	elevance health inc	elv elevance health inc
4250	CMI	NYSE	CMI	\N	Cummins Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/CMI.png	COMMON_STOCK	t	2026-06-06 14:56:39.267102+00	2026-06-06 14:56:39.267102+00	cmi	\N	cummins inc	cmi cummins inc
4251	SNPS	NASDAQ	SNPS	\N	Synopsys Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/SNPS.png	COMMON_STOCK	t	2026-06-06 14:56:39.749919+00	2026-06-06 14:56:39.749919+00	snps	\N	synopsys inc	snps synopsys inc
4252	WM	NYSE	WM	\N	Waste Management Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/WM.png	COMMON_STOCK	t	2026-06-06 14:56:40.421139+00	2026-06-06 14:56:40.421139+00	wm	\N	waste management inc	wm waste management inc
4253	NET	NYSE	NET	\N	Cloudflare Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/NET.png	COMMON_STOCK	t	2026-06-06 14:56:40.891145+00	2026-06-06 14:56:40.891145+00	net	\N	cloudflare inc	net cloudflare inc
4254	WMB	NYSE	WMB	\N	Williams Companies Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/WMB.png	COMMON_STOCK	t	2026-06-06 14:56:41.365665+00	2026-06-06 14:56:41.365665+00	wmb	\N	williams companies inc	wmb williams companies inc
4255	JCI	NYSE	JCI	\N	Johnson Controls International PLC	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/JCI.png	COMMON_STOCK	t	2026-06-06 14:56:41.863584+00	2026-06-06 14:56:41.863584+00	jci	\N	johnson controls international plc	jci johnson controls international plc
4256	MNST	NASDAQ	MNST	\N	Monster Beverage Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MNST.png	COMMON_STOCK	t	2026-06-06 14:56:42.371321+00	2026-06-06 14:56:42.371321+00	mnst	\N	monster beverage corp	mnst monster beverage corp
4257	CSX	NASDAQ	CSX	\N	CSX Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/CSX.png	COMMON_STOCK	t	2026-06-06 14:56:42.856035+00	2026-06-06 14:56:42.856035+00	csx	\N	csx corp	csx csx corp
4258	USB	NYSE	USB	\N	US Bancorp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/USB.png	COMMON_STOCK	t	2026-06-06 14:56:43.334439+00	2026-06-06 14:56:43.334439+00	usb	\N	us bancorp	usb us bancorp
4259	ING	NASDAQ	ING	\N	ING Groep N.V.		COMMON_STOCK	t	2026-06-06 14:56:43.821066+00	2026-06-06 14:56:43.821066+00	ing	\N	ing groep n.v.	ing ing groep n.v.
4260	CMCSA	NASDAQ	CMCSA	\N	Comcast Corporation		COMMON_STOCK	t	2026-06-06 14:56:44.308427+00	2026-06-06 14:56:44.308427+00	cmcsa	\N	comcast corporation	cmcsa comcast corporation
4261	ITUB	NASDAQ	ITUB	\N	Itaú Unibanco Holding S.A.		COMMON_STOCK	t	2026-06-06 14:56:44.797808+00	2026-06-06 14:56:44.797808+00	itub	\N	itaú unibanco holding s.a.	itub itaú unibanco holding s.a.
4262	NOK	NASDAQ	NOK	\N	Nokia Oyj		COMMON_STOCK	t	2026-06-06 14:56:45.298205+00	2026-06-06 14:56:45.298205+00	nok	\N	nokia oyj	nok nokia oyj
4263	KKR	NASDAQ	KKR	\N	KKR & Co. Inc.		COMMON_STOCK	t	2026-06-06 14:59:58.229459+00	2026-06-06 14:59:58.229459+00	kkr	\N	kkr & co. inc.	kkr kkr & co. inc.
4264	DDOG	NASDAQ	DDOG	\N	Datadog, Inc.		COMMON_STOCK	t	2026-06-06 14:56:46.269843+00	2026-06-06 14:56:46.269843+00	ddog	\N	datadog, inc.	ddog datadog, inc.
4265	BCS	NASDAQ	BCS	\N	Barclays PLC		COMMON_STOCK	t	2026-06-06 14:56:46.758988+00	2026-06-06 14:56:46.758988+00	bcs	\N	barclays plc	bcs barclays plc
4266	SNOW	NASDAQ	SNOW	\N	Snowflake Inc.		COMMON_STOCK	t	2026-06-06 14:56:47.247297+00	2026-06-06 14:56:47.247297+00	snow	\N	snowflake inc.	snow snowflake inc.
4267	HCA	NASDAQ	HCA	\N	HCA Healthcare, Inc.		COMMON_STOCK	t	2026-06-06 14:56:47.716411+00	2026-06-06 14:56:47.716411+00	hca	\N	hca healthcare, inc.	hca hca healthcare, inc.
4268	SLB	NASDAQ	SLB	\N	SLB N.V.		COMMON_STOCK	t	2026-06-06 14:56:48.204212+00	2026-06-06 14:56:48.204212+00	slb	\N	slb n.v.	slb slb n.v.
4269	AEM	NASDAQ	AEM	\N	Agnico Eagle Mines Limited		COMMON_STOCK	t	2026-06-06 14:56:48.71586+00	2026-06-06 14:56:48.71586+00	aem	\N	agnico eagle mines limited	aem agnico eagle mines limited
4270	EPD	NASDAQ	EPD	\N	Enterprise Products Partners L.P.		COMMON_STOCK	t	2026-06-06 14:56:49.197781+00	2026-06-06 14:56:49.197781+00	epd	\N	enterprise products partners l.p.	epd enterprise products partners l.p.
4271	MELI	NASDAQ	MELI	\N	MercadoLibre, Inc.		COMMON_STOCK	t	2026-06-06 14:56:49.685455+00	2026-06-06 14:56:49.685455+00	meli	\N	mercadolibre, inc.	meli mercadolibre, inc.
4272	INTU	NASDAQ	INTU	\N	Intuit Inc.		COMMON_STOCK	t	2026-06-06 14:56:50.18224+00	2026-06-06 14:56:50.18224+00	intu	\N	intuit inc.	intu intuit inc.
4273	NGG	NASDAQ	NGG	\N	National Grid plc		COMMON_STOCK	t	2026-06-06 15:00:03.126863+00	2026-06-06 15:00:03.126863+00	ngg	\N	national grid plc	ngg national grid plc
4274	ASX	NASDAQ	ASX	\N	ASE Technology Holding Co., Ltd.		COMMON_STOCK	t	2026-06-06 14:56:51.17936+00	2026-06-06 14:56:51.17936+00	asx	\N	ase technology holding co., ltd.	asx ase technology holding co., ltd.
4275	MMM	NASDAQ	MMM	\N	3M Company		COMMON_STOCK	t	2026-06-06 14:56:51.664355+00	2026-06-06 14:56:51.664355+00	mmm	\N	3m company	mmm 3m company
4276	ICE	NASDAQ	ICE	\N	Intercontinental Exchange, Inc.		COMMON_STOCK	t	2026-06-06 14:56:52.157515+00	2026-06-06 14:56:52.157515+00	ice	\N	intercontinental exchange, inc.	ice intercontinental exchange, inc.
4277	SPG	NASDAQ	SPG	\N	Simon Property Group, Inc.		COMMON_STOCK	t	2026-06-06 14:56:52.642166+00	2026-06-06 14:56:52.642166+00	spg	\N	simon property group, inc.	spg simon property group, inc.
4278	E	NASDAQ	E	\N	Eni S.p.A.		COMMON_STOCK	t	2026-06-06 14:56:53.12054+00	2026-06-06 14:56:53.12054+00	e	\N	eni s.p.a.	e eni s.p.a.
4279	CP	NASDAQ	CP	\N	Canadian Pacific Kansas City Limited		COMMON_STOCK	t	2026-06-06 14:56:53.593443+00	2026-06-06 14:56:53.593443+00	cp	\N	canadian pacific kansas city limited	cp canadian pacific kansas city limited
4280	MRSH	NASDAQ	MRSH	\N	Marsh & McLennan Companies, Inc.		COMMON_STOCK	t	2026-06-06 14:56:54.062934+00	2026-06-06 14:56:54.062934+00	mrsh	\N	marsh & mclennan companies, inc.	mrsh marsh & mclennan companies, inc.
4281	MDLZ	NASDAQ	MDLZ	\N	Mondelez International, Inc.		COMMON_STOCK	t	2026-06-06 14:56:54.561145+00	2026-06-06 14:56:54.561145+00	mdlz	\N	mondelez international, inc.	mdlz mondelez international, inc.
4282	ABNB	NASDAQ	ABNB	\N	Airbnb, Inc.		COMMON_STOCK	t	2026-06-06 14:56:55.06082+00	2026-06-06 14:56:55.06082+00	abnb	\N	airbnb, inc.	abnb airbnb, inc.
4283	FDX	NASDAQ	FDX	\N	FedEx Corporation		COMMON_STOCK	t	2026-06-06 15:00:08.023808+00	2026-06-06 15:00:08.023808+00	fdx	\N	fedex corporation	fdx fedex corporation
4284	MCO	NASDAQ	MCO	\N	Moody's Corporation		COMMON_STOCK	t	2026-06-06 14:56:56.061301+00	2026-06-06 14:56:56.061301+00	mco	\N	moody's corporation	mco moody's corporation
4285	HLT	NASDAQ	HLT	\N	Hilton Worldwide Holdings Inc.		COMMON_STOCK	t	2026-06-06 14:56:56.557379+00	2026-06-06 14:56:56.557379+00	hlt	\N	hilton worldwide holdings inc.	hlt hilton worldwide holdings inc.
4286	EMR	NASDAQ	EMR	\N	Emerson Electric Co.		COMMON_STOCK	t	2026-06-06 14:56:57.045931+00	2026-06-06 14:56:57.045931+00	emr	\N	emerson electric co.	emr emerson electric co.
4287	NOC	NASDAQ	NOC	\N	Northrop Grumman Corporation		COMMON_STOCK	t	2026-06-06 14:56:57.524616+00	2026-06-06 14:56:57.524616+00	noc	\N	northrop grumman corporation	noc northrop grumman corporation
4288	LYG	NASDAQ	LYG	\N	Lloyds Banking Group plc		COMMON_STOCK	t	2026-06-06 14:56:57.993512+00	2026-06-06 14:56:57.993512+00	lyg	\N	lloyds banking group plc	lyg lloyds banking group plc
4289	NTES	NASDAQ	NTES	\N	NetEase, Inc.		COMMON_STOCK	t	2026-06-06 14:56:58.495723+00	2026-06-06 14:56:58.495723+00	ntes	\N	netease, inc.	ntes netease, inc.
4290	CI	NASDAQ	CI	\N	The Cigna Group		COMMON_STOCK	t	2026-06-06 14:56:58.979859+00	2026-06-06 14:56:58.979859+00	ci	\N	the cigna group	ci the cigna group
4291	MPC	NASDAQ	MPC	\N	Marathon Petroleum Corporation		COMMON_STOCK	t	2026-06-06 14:56:59.465516+00	2026-06-06 14:56:59.465516+00	mpc	\N	marathon petroleum corporation	mpc marathon petroleum corporation
4292	VLO	NASDAQ	VLO	\N	Valero Energy Corporation		COMMON_STOCK	t	2026-06-06 14:56:59.963676+00	2026-06-06 14:56:59.963676+00	vlo	\N	valero energy corporation	vlo valero energy corporation
4293	RCL	NASDAQ	RCL	\N	Royal Caribbean Cruises Ltd.		COMMON_STOCK	t	2026-06-06 14:57:00.461672+00	2026-06-06 14:57:00.461672+00	rcl	\N	royal caribbean cruises ltd.	rcl royal caribbean cruises ltd.
4294	BE	NASDAQ	BE	\N	Bloom Energy Corporation		COMMON_STOCK	t	2026-06-06 14:57:00.962614+00	2026-06-06 14:57:00.962614+00	be	\N	bloom energy corporation	be bloom energy corporation
4295	SHW	NASDAQ	SHW	\N	The Sherwin-Williams Company		COMMON_STOCK	t	2026-06-06 14:57:01.443984+00	2026-06-06 14:57:01.443984+00	shw	\N	the sherwin-williams company	shw the sherwin-williams company
4296	ORLY	NASDAQ	ORLY	\N	O'Reilly Automotive, Inc.		COMMON_STOCK	t	2026-06-06 14:57:01.929942+00	2026-06-06 14:57:01.929942+00	orly	\N	o'reilly automotive, inc.	orly o'reilly automotive, inc.
4297	NXPI	NASDAQ	NXPI	\N	NXP Semiconductors N.V.		COMMON_STOCK	t	2026-06-06 14:57:02.423378+00	2026-06-06 14:57:02.423378+00	nxpi	\N	nxp semiconductors n.v.	nxpi nxp semiconductors n.v.
4298	AMX	NASDAQ	AMX	\N	América Móvil, S.A.B. de C.V.		COMMON_STOCK	t	2026-06-06 14:57:02.89852+00	2026-06-06 14:57:02.89852+00	amx	\N	américa móvil, s.a.b. de c.v.	amx américa móvil, s.a.b. de c.v.
4299	HOOD	NASDAQ	HOOD	\N	Robinhood Markets, Inc.		COMMON_STOCK	t	2026-06-06 14:57:03.373674+00	2026-06-06 14:57:03.373674+00	hood	\N	robinhood markets, inc.	hood robinhood markets, inc.
4300	GM	NASDAQ	GM	\N	General Motors Company		COMMON_STOCK	t	2026-06-06 14:57:03.866366+00	2026-06-06 14:57:03.866366+00	gm	\N	general motors company	gm general motors company
4301	ROST	NASDAQ	ROST	\N	Ross Stores, Inc.		COMMON_STOCK	t	2026-06-06 14:57:04.335704+00	2026-06-06 14:57:04.335704+00	rost	\N	ross stores, inc.	rost ross stores, inc.
4302	BAM	NASDAQ	BAM	\N	Brookfield Asset Management Ltd.		COMMON_STOCK	t	2026-06-06 14:57:04.8021+00	2026-06-06 14:57:04.8021+00	bam	\N	brookfield asset management ltd.	bam brookfield asset management ltd.
4303	APO	NASDAQ	APO	\N	Apollo Global Management, Inc.		COMMON_STOCK	t	2026-06-06 15:00:17.741578+00	2026-06-06 15:00:17.741578+00	apo	\N	apollo global management, inc.	apo apollo global management, inc.
4304	COHR	NASDAQ	COHR	\N	Coherent Corp.		COMMON_STOCK	t	2026-06-06 15:00:18.224278+00	2026-06-06 15:00:18.224278+00	cohr	\N	coherent corp.	cohr coherent corp.
4305	SU	NASDAQ	SU	\N	Suncor Energy Inc.		COMMON_STOCK	t	2026-06-06 14:57:06.260961+00	2026-06-06 14:57:06.260961+00	su	\N	suncor energy inc.	su suncor energy inc.
4306	CVNA	NASDAQ	CVNA	\N	Carvana Co.		COMMON_STOCK	t	2026-06-06 14:57:06.750846+00	2026-06-06 14:57:06.750846+00	cvna	\N	carvana co.	cvna carvana co.
4307	PSX	NASDAQ	PSX	\N	Phillips 66		COMMON_STOCK	t	2026-06-06 14:57:07.236281+00	2026-06-06 14:57:07.236281+00	psx	\N	phillips 66	psx phillips 66
4308	EOG	NASDAQ	EOG	\N	EOG Resources, Inc.		COMMON_STOCK	t	2026-06-06 14:57:07.698302+00	2026-06-06 14:57:07.698302+00	eog	\N	eog resources, inc.	eog eog resources, inc.
4309	CNI	NASDAQ	CNI	\N	Canadian National Railway Company		COMMON_STOCK	t	2026-06-06 14:57:08.194102+00	2026-06-06 14:57:08.194102+00	cni	\N	canadian national railway company	cni canadian national railway company
4310	MPWR	NASDAQ	MPWR	\N	Monolithic Power Systems, Inc.		COMMON_STOCK	t	2026-06-06 14:57:08.667415+00	2026-06-06 14:57:08.667415+00	mpwr	\N	monolithic power systems, inc.	mpwr monolithic power systems, inc.
4311	ITW	NASDAQ	ITW	\N	Illinois Tool Works Inc.		COMMON_STOCK	t	2026-06-06 14:57:09.150064+00	2026-06-06 14:57:09.150064+00	itw	\N	illinois tool works inc.	itw illinois tool works inc.
4312	ECL	NASDAQ	ECL	\N	Ecolab Inc.		COMMON_STOCK	t	2026-06-06 14:57:09.643465+00	2026-06-06 14:57:09.643465+00	ecl	\N	ecolab inc.	ecl ecolab inc.
4313	BSX	NASDAQ	BSX	\N	Boston Scientific Corporation		COMMON_STOCK	t	2026-06-06 14:57:10.117719+00	2026-06-06 14:57:10.117719+00	bsx	\N	boston scientific corporation	bsx boston scientific corporation
4314	CTAS	NASDAQ	CTAS	\N	Cintas Corporation		COMMON_STOCK	t	2026-06-06 15:00:23.063291+00	2026-06-06 15:00:23.063291+00	ctas	\N	cintas corporation	ctas cintas corporation
4315	TRP	NASDAQ	TRP	\N	TC Energy Corporation		COMMON_STOCK	t	2026-06-06 14:57:11.096488+00	2026-06-06 14:57:11.096488+00	trp	\N	tc energy corporation	trp tc energy corporation
4316	CL	NASDAQ	CL	\N	Colgate-Palmolive Company		COMMON_STOCK	t	2026-06-06 14:57:11.594286+00	2026-06-06 14:57:11.594286+00	cl	\N	colgate-palmolive company	cl colgate-palmolive company
4317	KMI	NASDAQ	KMI	\N	Kinder Morgan, Inc.		COMMON_STOCK	t	2026-06-06 14:57:12.104618+00	2026-06-06 14:57:12.104618+00	kmi	\N	kinder morgan, inc.	kmi kinder morgan, inc.
4318	NSC	NASDAQ	NSC	\N	Norfolk Southern Corporation		COMMON_STOCK	t	2026-06-06 14:57:12.603097+00	2026-06-06 14:57:12.603097+00	nsc	\N	norfolk southern corporation	nsc norfolk southern corporation
4319	AEP	NASDAQ	AEP	\N	American Electric Power Company, Inc.		COMMON_STOCK	t	2026-06-06 14:57:13.072246+00	2026-06-06 14:57:13.072246+00	aep	\N	american electric power company, inc.	aep american electric power company, inc.
4320	CRH	NASDAQ	CRH	\N	CRH plc		COMMON_STOCK	t	2026-06-06 14:57:13.566851+00	2026-06-06 14:57:13.566851+00	crh	\N	crh plc	crh crh plc
4321	AON	NASDAQ	AON	\N	Aon plc		COMMON_STOCK	t	2026-06-06 14:57:14.044995+00	2026-06-06 14:57:14.044995+00	aon	\N	aon plc	aon aon plc
4322	TDG	NYSE	TDG	\N	TransDigm Group Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/TDG.png	COMMON_STOCK	t	2026-06-06 14:57:14.522853+00	2026-06-06 14:57:14.522853+00	tdg	\N	transdigm group inc	tdg transdigm group inc
4323	CIEN	NYSE	CIEN	\N	Ciena Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/CIEN.png	COMMON_STOCK	t	2026-06-06 14:57:15.023294+00	2026-06-06 14:57:15.023294+00	cien	\N	ciena corp	cien ciena corp
4324	DASH	NASDAQ	DASH	\N	DoorDash Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/DASH.png	COMMON_STOCK	t	2026-06-06 14:57:15.51015+00	2026-06-06 14:57:15.51015+00	dash	\N	doordash inc	dash doordash inc
4325	MSI	NYSE	MSI	\N	Motorola Solutions Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MSI.png	COMMON_STOCK	t	2026-06-06 14:57:16.004022+00	2026-06-06 14:57:16.004022+00	msi	\N	motorola solutions inc	msi motorola solutions inc
4326	LITE	NASDAQ	LITE	\N	Lumentum Holdings Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/LITE.png	COMMON_STOCK	t	2026-06-06 14:57:16.485926+00	2026-06-06 14:57:16.485926+00	lite	\N	lumentum holdings inc	lite lumentum holdings inc
4327	URI	NYSE	URI	\N	United Rentals Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/URI.png	COMMON_STOCK	t	2026-06-06 14:57:16.964905+00	2026-06-06 14:57:16.964905+00	uri	\N	united rentals inc	uri united rentals inc
4328	DLR	NYSE	DLR	\N	Digital Realty Trust Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/942959090646.png	COMMON_STOCK	t	2026-06-06 14:57:17.449822+00	2026-06-06 14:57:17.449822+00	dlr	\N	digital realty trust inc	dlr digital realty trust inc
4329	ET	NYSE	ET	\N	Energy Transfer LP	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ET.png	COMMON_STOCK	t	2026-06-06 14:57:17.945433+00	2026-06-06 14:57:17.945433+00	et	\N	energy transfer lp	et energy transfer lp
4330	B	NASDAQ	B	\N	Barrick Mining Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ABX.TO.png	COMMON_STOCK	t	2026-06-06 14:57:18.431574+00	2026-06-06 14:57:18.431574+00	b	\N	barrick mining corp	b barrick mining corp
4331	WBD	NASDAQ	WBD	\N	Warner Bros Discovery Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/942959073106.png	COMMON_STOCK	t	2026-06-06 14:57:18.905098+00	2026-06-06 14:57:18.905098+00	wbd	\N	warner bros discovery inc	wbd warner bros discovery inc
4332	VALE	NASDAQ	VALE	\N	Vale SA	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/VALE3.SA.png	COMMON_STOCK	t	2026-06-06 14:57:19.412398+00	2026-06-06 14:57:19.412398+00	vale	\N	vale sa	vale vale sa
4333	HPE	NYSE	HPE	\N	Hewlett Packard Enterprise Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/HPE.png	COMMON_STOCK	t	2026-06-06 14:57:19.876257+00	2026-06-06 14:57:19.876257+00	hpe	\N	hewlett packard enterprise co	hpe hewlett packard enterprise co
4334	FIX	NYSE	FIX	\N	Comfort Systems USA Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/FIX.png	COMMON_STOCK	t	2026-06-06 14:57:20.348724+00	2026-06-06 14:57:20.348724+00	fix	\N	comfort systems usa inc	fix comfort systems usa inc
4335	MFC	NASDAQ	MFC	\N	Manulife Financial Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MFC.TO.png	COMMON_STOCK	t	2026-06-06 15:00:33.294297+00	2026-06-06 15:00:33.294297+00	mfc	\N	manulife financial corp	mfc manulife financial corp
4336	REGN	NASDAQ	REGN	\N	Regeneron Pharmaceuticals Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/REGN.png	COMMON_STOCK	t	2026-06-06 14:57:21.346187+00	2026-06-06 14:57:21.346187+00	regn	\N	regeneron pharmaceuticals inc	regn regeneron pharmaceuticals inc
4337	RSG	NYSE	RSG	\N	Republic Services Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/RSG.png	COMMON_STOCK	t	2026-06-06 14:57:21.848302+00	2026-06-06 14:57:21.848302+00	rsg	\N	republic services inc	rsg republic services inc
4338	TRV	NYSE	TRV	\N	Travelers Companies Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/TRV.png	COMMON_STOCK	t	2026-06-06 14:57:22.332423+00	2026-06-06 14:57:22.332423+00	trv	\N	travelers companies inc	trv travelers companies inc
4339	STM	NYSE	STM	\N	STMicroelectronics NV	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/STM.PA.png	COMMON_STOCK	t	2026-06-06 14:57:22.815257+00	2026-06-06 14:57:22.815257+00	stm	\N	stmicroelectronics nv	stm stmicroelectronics nv
4340	RKLB	NASDAQ	RKLB	\N	Rocket Lab Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950811866506.png	COMMON_STOCK	t	2026-06-06 14:57:23.327248+00	2026-06-06 14:57:23.327248+00	rklb	\N	rocket lab corp	rklb rocket lab corp
4341	NKE	NYSE	NKE	\N	Nike Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/NKE.png	COMMON_STOCK	t	2026-06-06 14:57:23.801052+00	2026-06-06 14:57:23.801052+00	nke	\N	nike inc	nke nike inc
4342	NWG	NASDAQ	NWG	\N	NatWest Group PLC	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/NWG.L.png	COMMON_STOCK	t	2026-06-06 14:57:24.284108+00	2026-06-06 14:57:24.284108+00	nwg	\N	natwest group plc	nwg natwest group plc
4343	APD	NYSE	APD	\N	Air Products and Chemicals Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/APD.png	COMMON_STOCK	t	2026-06-06 14:57:24.777096+00	2026-06-06 14:57:24.777096+00	apd	\N	air products and chemicals inc	apd air products and chemicals inc
4344	BKR	NASDAQ	BKR	\N	Baker Hughes Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/BKR.png	COMMON_STOCK	t	2026-06-06 14:57:25.272526+00	2026-06-06 14:57:25.272526+00	bkr	\N	baker hughes co	bkr baker hughes co
4345	TEL	NYSE	TEL	\N	TE Connectivity PLC	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/TEL.png	COMMON_STOCK	t	2026-06-06 15:00:38.197499+00	2026-06-06 15:00:38.197499+00	tel	\N	te connectivity plc	tel te connectivity plc
4346	RELX	NASDAQ	RELX	\N	Relx PLC	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/REL.L.png	COMMON_STOCK	t	2026-06-06 14:57:26.243285+00	2026-06-06 14:57:26.243285+00	relx	\N	relx plc	relx relx plc
4347	PCAR	NASDAQ	PCAR	\N	Paccar Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/PCAR.png	COMMON_STOCK	t	2026-06-06 14:57:26.739249+00	2026-06-06 14:57:26.739249+00	pcar	\N	paccar inc	pcar paccar inc
4348	GWW	NYSE	GWW	\N	WW Grainger Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/GWW.png	COMMON_STOCK	t	2026-06-06 14:57:27.203785+00	2026-06-06 14:57:27.203785+00	gww	\N	ww grainger inc	gww ww grainger inc
4349	TFC	NYSE	TFC	\N	Truist Financial Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/TFC.png	COMMON_STOCK	t	2026-06-06 14:57:27.688656+00	2026-06-06 14:57:27.688656+00	tfc	\N	truist financial corp	tfc truist financial corp
4350	RACE	NASDAQ	RACE	\N	Ferrari NV	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/RACE.MI.png	COMMON_STOCK	t	2026-06-06 14:57:28.163384+00	2026-06-06 14:57:28.163384+00	race	\N	ferrari nv	race ferrari nv
4351	AFL	NYSE	AFL	\N	Aflac Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AFL.png	COMMON_STOCK	t	2026-06-06 14:57:28.659863+00	2026-06-06 14:57:28.659863+00	afl	\N	aflac inc	afl aflac inc
4352	SRE	NYSE	SRE	\N	Sempra	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/SRE.png	COMMON_STOCK	t	2026-06-06 14:57:29.149731+00	2026-06-06 14:57:29.149731+00	sre	\N	sempra	sre sempra
4353	DB	NASDAQ	DB	\N	Deutsche Bank AG	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/DBK.DE.png	COMMON_STOCK	t	2026-06-06 14:57:29.640034+00	2026-06-06 14:57:29.640034+00	db	\N	deutsche bank ag	db deutsche bank ag
4354	F	NYSE	F	\N	Ford Motor Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/F.png	COMMON_STOCK	t	2026-06-06 14:57:30.134463+00	2026-06-06 14:57:30.134463+00	f	\N	ford motor co	f ford motor co
4355	IMO	NASDAQ	IMO	\N	Imperial Oil Ltd	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/IMO.TO.png	COMMON_STOCK	t	2026-06-06 14:57:30.631708+00	2026-06-06 14:57:30.631708+00	imo	\N	imperial oil ltd	imo imperial oil ltd
4356	D	NYSE	D	\N	Dominion Energy Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/D.png	COMMON_STOCK	t	2026-06-06 14:57:31.107979+00	2026-06-06 14:57:31.107979+00	d	\N	dominion energy inc	d dominion energy inc
4357	NBIS	NASDAQ	NBIS	\N	Nebius Group NV	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/942983351666.png	COMMON_STOCK	t	2026-06-06 14:57:31.592855+00	2026-06-06 14:57:31.592855+00	nbis	\N	nebius group nv	nbis nebius group nv
4358	NU	NYSE	NU	\N	Nu Holdings Ltd.	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/NU.png	COMMON_STOCK	t	2026-06-06 14:57:32.080328+00	2026-06-06 14:57:32.080328+00	nu	\N	nu holdings ltd.	nu nu holdings ltd.
4359	NUE	NYSE	NUE	\N	Nucor Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/NUE.png	COMMON_STOCK	t	2026-06-06 14:57:32.597337+00	2026-06-06 14:57:32.597337+00	nue	\N	nucor corp	nue nucor corp
4360	LHX	NYSE	LHX	\N	L3Harris Technologies Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/LHX.png	COMMON_STOCK	t	2026-06-06 14:57:33.07369+00	2026-06-06 14:57:33.07369+00	lhx	\N	l3harris technologies inc	lhx l3harris technologies inc
4361	MPLX	NYSE	MPLX	\N	MPLX LP	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MPLX.png	COMMON_STOCK	t	2026-06-06 14:57:33.547662+00	2026-06-06 14:57:33.547662+00	mplx	\N	mplx lp	mplx mplx lp
4362	O	NYSE	O	\N	Realty Income Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/942959030586.png	COMMON_STOCK	t	2026-06-06 14:57:34.020223+00	2026-06-06 14:57:34.020223+00	o	\N	realty income corp	o realty income corp
4363	ALL	NYSE	ALL	\N	Allstate Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ALL.png	COMMON_STOCK	t	2026-06-06 14:57:34.497416+00	2026-06-06 14:57:34.497416+00	all	\N	allstate corp	all allstate corp
4364	TRGP	NYSE	TRGP	\N	Targa Resources Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/TRGP.png	COMMON_STOCK	t	2026-06-06 14:57:34.990244+00	2026-06-06 14:57:34.990244+00	trgp	\N	targa resources corp	trgp targa resources corp
4365	OXY	NYSE	OXY	\N	Occidental Petroleum Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/OXY.png	COMMON_STOCK	t	2026-06-06 14:57:36.289003+00	2026-06-06 14:57:36.289003+00	oxy	\N	occidental petroleum corp	oxy occidental petroleum corp
4366	KEYS	NYSE	KEYS	\N	Keysight Technologies Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/KEYS.png	COMMON_STOCK	t	2026-06-06 14:57:36.765064+00	2026-06-06 14:57:36.765064+00	keys	\N	keysight technologies inc	keys keysight technologies inc
4367	TER	NASDAQ	TER	\N	Teradyne Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/TER.png	COMMON_STOCK	t	2026-06-06 14:57:37.278826+00	2026-06-06 14:57:37.278826+00	ter	\N	teradyne inc	ter teradyne inc
4368	CARR	NYSE	CARR	\N	Carrier Global Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/CARR.png	COMMON_STOCK	t	2026-06-06 14:57:37.768545+00	2026-06-06 14:57:37.768545+00	carr	\N	carrier global corp	carr carrier global corp
4369	TGT	NYSE	TGT	\N	Target Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/TGT.png	COMMON_STOCK	t	2026-06-06 14:57:38.27495+00	2026-06-06 14:57:38.27495+00	tgt	\N	target corp	tgt target corp
4370	FLEX	NASDAQ	FLEX	\N	Flex Ltd	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/FLEX.png	COMMON_STOCK	t	2026-06-06 14:57:38.756304+00	2026-06-06 14:57:38.756304+00	flex	\N	flex ltd	flex flex ltd
4371	OKE	NYSE	OKE	\N	ONEOK Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/OKE.png	COMMON_STOCK	t	2026-06-06 14:57:39.248974+00	2026-06-06 14:57:39.248974+00	oke	\N	oneok inc	oke oneok inc
4372	AJG	NYSE	AJG	\N	Arthur J. Gallagher & Co.	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AJG.png	COMMON_STOCK	t	2026-06-06 14:57:39.723839+00	2026-06-06 14:57:39.723839+00	ajg	\N	arthur j. gallagher & co.	ajg arthur j. gallagher & co.
4373	ARGX	NYSE	ARGX	\N	argenx SE	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ARGX.BR.png	COMMON_STOCK	t	2026-06-06 14:57:40.206618+00	2026-06-06 14:57:40.206618+00	argx	\N	argenx se	argx argenx se
4374	CRWV	NASDAQ	CRWV	\N	CoreWeave Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950683281286.png	COMMON_STOCK	t	2026-06-06 15:00:53.146658+00	2026-06-06 15:00:53.146658+00	crwv	\N	coreweave inc	crwv coreweave inc
4375	PSA	NYSE	PSA	\N	Public Storage	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950680574146.png	COMMON_STOCK	t	2026-06-06 14:57:41.18144+00	2026-06-06 14:57:41.18144+00	psa	\N	public storage	psa public storage
4376	MET	NYSE	MET	\N	MetLife Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MET.png	COMMON_STOCK	t	2026-06-06 14:57:41.660728+00	2026-06-06 14:57:41.660728+00	met	\N	metlife inc	met metlife inc
4377	ALAB	NASDAQ	ALAB	\N	Astera Labs, Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950633134526.png	COMMON_STOCK	t	2026-06-06 14:57:42.167721+00	2026-06-06 14:57:42.167721+00	alab	\N	astera labs, inc	alab astera labs, inc
4378	FANG	NASDAQ	FANG	\N	Diamondback Energy Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/FANG.png	COMMON_STOCK	t	2026-06-06 14:57:42.634457+00	2026-06-06 14:57:42.634457+00	fang	\N	diamondback energy inc	fang diamondback energy inc
4379	FAST	NASDAQ	FAST	\N	Fastenal Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/FAST.png	COMMON_STOCK	t	2026-06-06 14:57:43.109419+00	2026-06-06 14:57:43.109419+00	fast	\N	fastenal co	fast fastenal co
4380	COR	NYSE	COR	\N	Cencora Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ABC.png	COMMON_STOCK	t	2026-06-06 14:57:43.592294+00	2026-06-06 14:57:43.592294+00	cor	\N	cencora inc	cor cencora inc
4381	SE	NYSE	SE	\N	Sea Ltd	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/SE.png	COMMON_STOCK	t	2026-06-06 14:57:44.268823+00	2026-06-06 14:57:44.268823+00	se	\N	sea ltd	se sea ltd
4382	CVE	NASDAQ	CVE	\N	Cenovus Energy Inc.		COMMON_STOCK	t	2026-06-06 14:57:44.7659+00	2026-06-06 14:57:44.7659+00	cve	\N	cenovus energy inc.	cve cenovus energy inc.
4383	WPM	NASDAQ	WPM	\N	Wheaton Precious Metals Corp.		COMMON_STOCK	t	2026-06-06 14:57:45.236525+00	2026-06-06 14:57:45.236525+00	wpm	\N	wheaton precious metals corp.	wpm wheaton precious metals corp.
4384	UMC	NASDAQ	UMC	\N	United Microelectronics Corporation		COMMON_STOCK	t	2026-06-06 15:00:58.174575+00	2026-06-06 15:00:58.174575+00	umc	\N	united microelectronics corporation	umc united microelectronics corporation
4385	MT	NASDAQ	MT	\N	ArcelorMittal S.A.		COMMON_STOCK	t	2026-06-06 14:57:46.194723+00	2026-06-06 14:57:46.194723+00	mt	\N	arcelormittal s.a.	mt arcelormittal s.a.
4386	AME	NASDAQ	AME	\N	AMETEK, Inc.		COMMON_STOCK	t	2026-06-06 14:57:46.672183+00	2026-06-06 14:57:46.672183+00	ame	\N	ametek, inc.	ame ametek, inc.
4387	DAL	NASDAQ	DAL	\N	Delta Air Lines, Inc.		COMMON_STOCK	t	2026-06-06 14:57:47.142517+00	2026-06-06 14:57:47.142517+00	dal	\N	delta air lines, inc.	dal delta air lines, inc.
4388	CTVA	NASDAQ	CTVA	\N	Corteva, Inc.		COMMON_STOCK	t	2026-06-06 14:57:47.638797+00	2026-06-06 14:57:47.638797+00	ctva	\N	corteva, inc.	ctva corteva, inc.
4389	DVN	NASDAQ	DVN	\N	Devon Energy Corporation		COMMON_STOCK	t	2026-06-06 14:57:48.116132+00	2026-06-06 14:57:48.116132+00	dvn	\N	devon energy corporation	dvn devon energy corporation
4390	AZO	NASDAQ	AZO	\N	AutoZone, Inc.		COMMON_STOCK	t	2026-06-06 14:57:48.621253+00	2026-06-06 14:57:48.621253+00	azo	\N	autozone, inc.	azo autozone, inc.
4391	EA	NASDAQ	EA	\N	Electronic Arts Inc.		COMMON_STOCK	t	2026-06-06 14:57:49.107144+00	2026-06-06 14:57:49.107144+00	ea	\N	electronic arts inc.	ea electronic arts inc.
4392	INFY	NASDAQ	INFY	\N	Infosys Limited		COMMON_STOCK	t	2026-06-06 14:57:49.57915+00	2026-06-06 14:57:49.57915+00	infy	\N	infosys limited	infy infosys limited
4393	ETR	NASDAQ	ETR	\N	Entergy Corporation		COMMON_STOCK	t	2026-06-06 14:57:50.077577+00	2026-06-06 14:57:50.077577+00	etr	\N	entergy corporation	etr entergy corporation
4394	ODFL	NASDAQ	ODFL	\N	Old Dominion Freight Line, Inc.		COMMON_STOCK	t	2026-06-06 14:57:50.571554+00	2026-06-06 14:57:50.571554+00	odfl	\N	old dominion freight line, inc.	odfl old dominion freight line, inc.
4395	VST	NASDAQ	VST	\N	Vistra Corp.		COMMON_STOCK	t	2026-06-06 14:57:51.048523+00	2026-06-06 14:57:51.048523+00	vst	\N	vistra corp.	vst vistra corp.
4396	LNG	NASDAQ	LNG	\N	Cheniere Energy, Inc.		COMMON_STOCK	t	2026-06-06 14:57:51.545874+00	2026-06-06 14:57:51.545874+00	lng	\N	cheniere energy, inc.	lng cheniere energy, inc.
4397	ROK	NASDAQ	ROK	\N	Rockwell Automation, Inc.		COMMON_STOCK	t	2026-06-06 14:57:52.047619+00	2026-06-06 14:57:52.047619+00	rok	\N	rockwell automation, inc.	rok rockwell automation, inc.
4398	EW	NASDAQ	EW	\N	Edwards Lifesciences Corporation		COMMON_STOCK	t	2026-06-06 14:57:52.517195+00	2026-06-06 14:57:52.517195+00	ew	\N	edwards lifesciences corporation	ew edwards lifesciences corporation
4399	NDAQ	NASDAQ	NDAQ	\N	Nasdaq, Inc.		COMMON_STOCK	t	2026-06-06 14:57:52.994993+00	2026-06-06 14:57:52.994993+00	ndaq	\N	nasdaq, inc.	ndaq nasdaq, inc.
4400	XEL	NASDAQ	XEL	\N	Xcel Energy Inc.		COMMON_STOCK	t	2026-06-06 14:57:53.468098+00	2026-06-06 14:57:53.468098+00	xel	\N	xcel energy inc.	xel xcel energy inc.
4401	ABEV	NASDAQ	ABEV	\N	Ambev S.A.		COMMON_STOCK	t	2026-06-06 14:57:53.956669+00	2026-06-06 14:57:53.956669+00	abev	\N	ambev s.a.	abev ambev s.a.
4402	FER	NASDAQ	FER	\N	Ferrovial N.V.		COMMON_STOCK	t	2026-06-06 14:57:54.448463+00	2026-06-06 14:57:54.448463+00	fer	\N	ferrovial n.v.	fer ferrovial n.v.
4403	TAK	NASDAQ	TAK	\N	Takeda Pharmaceutical Company Limited		COMMON_STOCK	t	2026-06-06 14:57:54.946387+00	2026-06-06 14:57:54.946387+00	tak	\N	takeda pharmaceutical company limited	tak takeda pharmaceutical company limited
4404	ADSK	NASDAQ	ADSK	\N	Autodesk, Inc.		COMMON_STOCK	t	2026-06-06 14:57:55.434085+00	2026-06-06 14:57:55.434085+00	adsk	\N	autodesk, inc.	adsk autodesk, inc.
4405	EBAY	NASDAQ	EBAY	\N	eBay Inc.		COMMON_STOCK	t	2026-06-06 15:01:08.357509+00	2026-06-06 15:01:08.357509+00	ebay	\N	ebay inc.	ebay ebay inc.
4406	CAH	NASDAQ	CAH	\N	Cardinal Health, Inc.		COMMON_STOCK	t	2026-06-06 14:57:56.395832+00	2026-06-06 14:57:56.395832+00	cah	\N	cardinal health, inc.	cah cardinal health, inc.
4407	MCHP	NASDAQ	MCHP	\N	Microchip Technology Incorporated		COMMON_STOCK	t	2026-06-06 14:57:56.890358+00	2026-06-06 14:57:56.890358+00	mchp	\N	microchip technology incorporated	mchp microchip technology incorporated
4408	FITB	NASDAQ	FITB	\N	Fifth Third Bancorp		COMMON_STOCK	t	2026-06-06 14:57:57.37298+00	2026-06-06 14:57:57.37298+00	fitb	\N	fifth third bancorp	fitb fifth third bancorp
4409	EXC	NASDAQ	EXC	\N	Exelon Corporation		COMMON_STOCK	t	2026-06-06 14:57:57.942617+00	2026-06-06 14:57:57.942617+00	exc	\N	exelon corporation	exc exelon corporation
4410	HEI	NASDAQ	HEI	\N	HEICO Corporation		COMMON_STOCK	t	2026-06-06 14:57:58.420144+00	2026-06-06 14:57:58.420144+00	hei	\N	heico corporation	hei heico corporation
4411	ON	NASDAQ	ON	\N	ON Semiconductor Corporation		COMMON_STOCK	t	2026-06-06 14:57:59.090361+00	2026-06-06 14:57:59.090361+00	on	\N	on semiconductor corporation	on on semiconductor corporation
4412	GRMN	NASDAQ	GRMN	\N	Garmin Ltd.		COMMON_STOCK	t	2026-06-06 14:57:59.573192+00	2026-06-06 14:57:59.573192+00	grmn	\N	garmin ltd.	grmn garmin ltd.
4413	CCJ	NASDAQ	CCJ	\N	Cameco Corporation		COMMON_STOCK	t	2026-06-06 14:58:00.070982+00	2026-06-06 14:58:00.070982+00	ccj	\N	cameco corporation	ccj cameco corporation
4414	MSCI	NASDAQ	MSCI	\N	MSCI Inc.		COMMON_STOCK	t	2026-06-06 14:58:00.566518+00	2026-06-06 14:58:00.566518+00	msci	\N	msci inc.	msci msci inc.
4415	STT	NASDAQ	STT	\N	State Street Corporation		COMMON_STOCK	t	2026-06-06 14:58:01.0247+00	2026-06-06 14:58:01.0247+00	stt	\N	state street corporation	stt state street corporation
4416	FERG	NASDAQ	FERG	\N	Ferguson Enterprises Inc.		COMMON_STOCK	t	2026-06-06 14:58:01.495572+00	2026-06-06 14:58:01.495572+00	ferg	\N	ferguson enterprises inc.	ferg ferguson enterprises inc.
4417	DEO	NASDAQ	DEO	\N	Diageo plc		COMMON_STOCK	t	2026-06-06 14:58:01.970367+00	2026-06-06 14:58:01.970367+00	deo	\N	diageo plc	deo diageo plc
4418	IDXX	NASDAQ	IDXX	\N	IDEXX Laboratories, Inc.		COMMON_STOCK	t	2026-06-06 14:58:02.468059+00	2026-06-06 14:58:02.468059+00	idxx	\N	idexx laboratories, inc.	idxx idexx laboratories, inc.
4419	WAB	NASDAQ	WAB	\N	Westinghouse Air Brake Technologies Corporation		COMMON_STOCK	t	2026-06-06 14:58:02.970453+00	2026-06-06 14:58:02.970453+00	wab	\N	westinghouse air brake technologies corporation	wab westinghouse air brake technologies corporation
4420	MDLN	NASDAQ	MDLN	\N	Medline Inc.		COMMON_STOCK	t	2026-06-06 14:58:03.460571+00	2026-06-06 14:58:03.460571+00	mdln	\N	medline inc.	mdln medline inc.
4421	CBRS	NASDAQ	CBRS	\N	Cerebras Systems Inc.		COMMON_STOCK	t	2026-06-06 14:58:03.927847+00	2026-06-06 14:58:03.927847+00	cbrs	\N	cerebras systems inc.	cbrs cerebras systems inc.
4422	CLS	NASDAQ	CLS	\N	Celestica Inc.		COMMON_STOCK	t	2026-06-06 14:58:04.402223+00	2026-06-06 14:58:04.402223+00	cls	\N	celestica inc.	cls celestica inc.
4423	ERIC	NASDAQ	ERIC	\N	Telefonaktiebolaget LM Ericsson (publ)		COMMON_STOCK	t	2026-06-06 14:58:04.8788+00	2026-06-06 14:58:04.8788+00	eric	\N	telefonaktiebolaget lm ericsson (publ)	eric telefonaktiebolaget lm ericsson (publ)
4424	AU	NASDAQ	AU	\N	AngloGold Ashanti plc		COMMON_STOCK	t	2026-06-06 15:01:17.83003+00	2026-06-06 15:01:17.83003+00	au	\N	anglogold ashanti plc	au anglogold ashanti plc
4425	MSTR	NASDAQ	MSTR	\N	Strategy Inc		COMMON_STOCK	t	2026-06-06 15:01:18.327973+00	2026-06-06 15:01:18.327973+00	mstr	\N	strategy inc	mstr strategy inc
4426	FNV	NASDAQ	FNV	\N	Franco-Nevada Corporation		COMMON_STOCK	t	2026-06-06 14:58:06.364574+00	2026-06-06 14:58:06.364574+00	fnv	\N	franco-nevada corporation	fnv franco-nevada corporation
4427	HUM	NASDAQ	HUM	\N	Humana Inc.		COMMON_STOCK	t	2026-06-06 14:58:06.885204+00	2026-06-06 14:58:06.885204+00	hum	\N	humana inc.	hum humana inc.
4428	IX	NASDAQ	IX	\N	ORIX Corporation		COMMON_STOCK	t	2026-06-06 14:58:07.368384+00	2026-06-06 14:58:07.368384+00	ix	\N	orix corporation	ix orix corporation
4429	BDX	NASDAQ	BDX	\N	Becton, Dickinson and Company		COMMON_STOCK	t	2026-06-06 14:58:07.85476+00	2026-06-06 14:58:07.85476+00	bdx	\N	becton, dickinson and company	bdx becton, dickinson and company
4430	YUM	NASDAQ	YUM	\N	Yum! Brands, Inc.		COMMON_STOCK	t	2026-06-06 14:58:08.324946+00	2026-06-06 14:58:08.324946+00	yum	\N	yum! brands, inc.	yum yum! brands, inc.
4431	WDS	NASDAQ	WDS	\N	Woodside Energy Group Ltd		COMMON_STOCK	t	2026-06-06 14:58:08.790109+00	2026-06-06 14:58:08.790109+00	wds	\N	woodside energy group ltd	wds woodside energy group ltd
4432	KDP	NASDAQ	KDP	\N	Keurig Dr Pepper Inc.		COMMON_STOCK	t	2026-06-06 14:58:09.269399+00	2026-06-06 14:58:09.269399+00	kdp	\N	keurig dr pepper inc.	kdp keurig dr pepper inc.
4433	CCEP	NASDAQ	CCEP	\N	Coca-Cola Europacific Partners PLC		COMMON_STOCK	t	2026-06-06 14:58:09.752752+00	2026-06-06 14:58:09.752752+00	ccep	\N	coca-cola europacific partners plc	ccep coca-cola europacific partners plc
4434	ARES	NASDAQ	ARES	\N	Ares Management Corporation		COMMON_STOCK	t	2026-06-06 14:58:10.241833+00	2026-06-06 14:58:10.241833+00	ares	\N	ares management corporation	ares ares management corporation
4552	TPR	NASDAQ	TPR	\N	Tapestry, Inc.		COMMON_STOCK	t	2026-06-06 14:59:08.966174+00	2026-06-06 14:59:08.966174+00	tpr	\N	tapestry, inc.	tpr tapestry, inc.
4435	GFS	NASDAQ	GFS	\N	GLOBALFOUNDRIES Inc.		COMMON_STOCK	t	2026-06-06 15:01:23.186471+00	2026-06-06 15:01:23.186471+00	gfs	\N	globalfoundries inc.	gfs globalfoundries inc.
4436	BIDU	NASDAQ	BIDU	\N	Baidu, Inc.		COMMON_STOCK	t	2026-06-06 14:58:11.232709+00	2026-06-06 14:58:11.232709+00	bidu	\N	baidu, inc.	bidu baidu, inc.
4437	DHI	NASDAQ	DHI	\N	D.R. Horton, Inc.		COMMON_STOCK	t	2026-06-06 14:58:11.704355+00	2026-06-06 14:58:11.704355+00	dhi	\N	d.r. horton, inc.	dhi d.r. horton, inc.
4438	CCI	NASDAQ	CCI	\N	Crown Castle Inc.		COMMON_STOCK	t	2026-06-06 14:58:12.1877+00	2026-06-06 14:58:12.1877+00	cci	\N	crown castle inc.	cci crown castle inc.
4439	XYZ	NASDAQ	XYZ	\N	Block, Inc.		COMMON_STOCK	t	2026-06-06 14:58:12.680747+00	2026-06-06 14:58:12.680747+00	xyz	\N	block, inc.	xyz block, inc.
4440	SLF	NASDAQ	SLF	\N	Sun Life Financial Inc.		COMMON_STOCK	t	2026-06-06 14:58:13.181659+00	2026-06-06 14:58:13.181659+00	slf	\N	sun life financial inc.	slf sun life financial inc.
4441	AMP	NASDAQ	AMP	\N	Ameriprise Financial, Inc.		COMMON_STOCK	t	2026-06-06 14:58:13.672483+00	2026-06-06 14:58:13.672483+00	amp	\N	ameriprise financial, inc.	amp ameriprise financial, inc.
4442	ALNY	NASDAQ	ALNY	\N	Alnylam Pharmaceuticals, Inc.		COMMON_STOCK	t	2026-06-06 14:58:14.233141+00	2026-06-06 14:58:14.233141+00	alny	\N	alnylam pharmaceuticals, inc.	alny alnylam pharmaceuticals, inc.
4443	VTR	NYSE	VTR	\N	Ventas Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/942959052106.png	COMMON_STOCK	t	2026-06-06 14:58:14.725856+00	2026-06-06 14:58:14.725856+00	vtr	\N	ventas inc	vtr ventas inc
4444	COIN	NASDAQ	COIN	\N	Coinbase Global Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/COIN.png	COMMON_STOCK	t	2026-06-06 14:58:15.220754+00	2026-06-06 14:58:15.220754+00	coin	\N	coinbase global inc	coin coinbase global inc
4445	VIK	NYSE	VIK	\N	Viking Holdings Ltd(Pembroke)	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950871554636.png	COMMON_STOCK	t	2026-06-06 14:58:15.710725+00	2026-06-06 14:58:15.710725+00	vik	\N	viking holdings ltd(pembroke)	vik viking holdings ltd(pembroke)
4446	AIG	NYSE	AIG	\N	American International Group Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AIG.png	COMMON_STOCK	t	2026-06-06 14:58:16.183432+00	2026-06-06 14:58:16.183432+00	aig	\N	american international group inc	aig american international group inc
4447	HLN	NASDAQ	HLN	\N	Haleon PLC	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950814881206.png	COMMON_STOCK	t	2026-06-06 14:58:17.512041+00	2026-06-06 14:58:17.512041+00	hln	\N	haleon plc	hln haleon plc
4448	TEVA	NASDAQ	TEVA	\N	Teva Pharmaceutical Industries Ltd	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/TEVA.TA.png	COMMON_STOCK	t	2026-06-06 14:58:17.998229+00	2026-06-06 14:58:17.998229+00	teva	\N	teva pharmaceutical industries ltd	teva teva pharmaceutical industries ltd
4449	TTWO	NASDAQ	TTWO	\N	Take-Two Interactive Software Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/TTWO.png	COMMON_STOCK	t	2026-06-06 14:58:18.490725+00	2026-06-06 14:58:18.490725+00	ttwo	\N	take-two interactive software inc	ttwo take-two interactive software inc
4450	PEG	NYSE	PEG	\N	Public Service Enterprise Group Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/PEG.png	COMMON_STOCK	t	2026-06-06 14:58:18.963012+00	2026-06-06 14:58:18.963012+00	peg	\N	public service enterprise group inc	peg public service enterprise group inc
4451	WCN	NASDAQ	WCN	\N	Waste Connections, Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/WCN.TO.png	COMMON_STOCK	t	2026-06-06 14:58:19.444919+00	2026-06-06 14:58:19.444919+00	wcn	\N	waste connections, inc	wcn waste connections, inc
4452	AXON	NASDAQ	AXON	\N	Axon Enterprise Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AXON.png	COMMON_STOCK	t	2026-06-06 14:58:19.937676+00	2026-06-06 14:58:19.937676+00	axon	\N	axon enterprise inc	axon axon enterprise inc
4453	ED	NYSE	ED	\N	Consolidated Edison Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ED.png	COMMON_STOCK	t	2026-06-06 14:58:20.428632+00	2026-06-06 14:58:20.428632+00	ed	\N	consolidated edison inc	ed consolidated edison inc
4454	KB	NASDAQ	KB	\N	KB Financial Group Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/105560.KS.png	COMMON_STOCK	t	2026-06-06 15:01:33.354491+00	2026-06-06 15:01:33.354491+00	kb	\N	kb financial group inc	kb kb financial group inc
4455	JD	NASDAQ	JD	\N	JD.com Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/9618.HK.png	COMMON_STOCK	t	2026-06-06 14:58:21.393333+00	2026-06-06 14:58:21.393333+00	jd	\N	jd.com inc	jd jd.com inc
4456	ADM	NYSE	ADM	\N	Archer-Daniels-Midland Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ADM.png	COMMON_STOCK	t	2026-06-06 14:58:21.877868+00	2026-06-06 14:58:21.877868+00	adm	\N	archer-daniels-midland co	adm archer-daniels-midland co
4457	KR	NYSE	KR	\N	Kroger Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/KR.png	COMMON_STOCK	t	2026-06-06 14:58:22.367049+00	2026-06-06 14:58:22.367049+00	kr	\N	kroger co	kr kroger co
4458	TKO	NYSE	TKO	\N	TKO Group Holdings Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950865844746.png	COMMON_STOCK	t	2026-06-06 14:58:22.869407+00	2026-06-06 14:58:22.869407+00	tko	\N	tko group holdings inc	tko tko group holdings inc
4459	HEI.A	NYSE	HEI.A	\N	HEICO Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/HEI.png	COMMON_STOCK	t	2026-06-06 14:58:23.353657+00	2026-06-06 14:58:23.353657+00	hei.a	\N	heico corp	hei.a heico corp
4460	STLD	NASDAQ	STLD	\N	Steel Dynamics Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/STLD.png	COMMON_STOCK	t	2026-06-06 14:58:23.850775+00	2026-06-06 14:58:23.850775+00	stld	\N	steel dynamics inc	stld steel dynamics inc
4461	ESLT	NASDAQ	ESLT	\N	Elbit Systems Ltd	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ESLT.TA.png	COMMON_STOCK	t	2026-06-06 14:58:24.315414+00	2026-06-06 14:58:24.315414+00	eslt	\N	elbit systems ltd	eslt elbit systems ltd
4462	CBRE	NYSE	CBRE	\N	CBRE Group Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/CBRE.png	COMMON_STOCK	t	2026-06-06 14:58:24.792498+00	2026-06-06 14:58:24.792498+00	cbre	\N	cbre group inc	cbre cbre group inc
4463	A	NYSE	A	\N	Agilent Technologies Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/A.png	COMMON_STOCK	t	2026-06-06 14:58:25.284798+00	2026-06-06 14:58:25.284798+00	a	\N	agilent technologies inc	a agilent technologies inc
4464	CRDO	NASDAQ	CRDO	\N	Credo Technology Group Holding Ltd	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950739588346.png	COMMON_STOCK	t	2026-06-06 15:01:38.21796+00	2026-06-06 15:01:38.21796+00	crdo	\N	credo technology group holding ltd	crdo credo technology group holding ltd
4465	CCL	NYSE	CCL	\N	Carnival Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/CCL.png	COMMON_STOCK	t	2026-06-06 14:58:26.26011+00	2026-06-06 14:58:26.26011+00	ccl	\N	carnival corp	ccl carnival corp
4466	FMX	NASDAQ	FMX	\N	Fomento Economico Mexicano SAB de CV	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/FEMSAUBD.MX.png	COMMON_STOCK	t	2026-06-06 14:58:26.750352+00	2026-06-06 14:58:26.750352+00	fmx	\N	fomento economico mexicano sab de cv	fmx fomento economico mexicano sab de cv
4467	PCG	NYSE	PCG	\N	PG&E Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/PCG.png	COMMON_STOCK	t	2026-06-06 14:58:27.238144+00	2026-06-06 14:58:27.238144+00	pcg	\N	pg&e corp	pcg pg&e corp
4468	TRI	NASDAQ	TRI	\N	Thomson Reuters Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/TRI.TO.png	COMMON_STOCK	t	2026-06-06 14:58:27.743366+00	2026-06-06 14:58:27.743366+00	tri	\N	thomson reuters corp	tri thomson reuters corp
4469	CMG	NYSE	CMG	\N	Chipotle Mexican Grill Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/CMG.png	COMMON_STOCK	t	2026-06-06 14:58:28.234481+00	2026-06-06 14:58:28.234481+00	cmg	\N	chipotle mexican grill inc	cmg chipotle mexican grill inc
4470	IBKR	NASDAQ	IBKR	\N	Interactive Brokers Group Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/IBKR.png	COMMON_STOCK	t	2026-06-06 14:58:28.703174+00	2026-06-06 14:58:28.703174+00	ibkr	\N	interactive brokers group inc	ibkr interactive brokers group inc
4471	HSY	NYSE	HSY	\N	Hershey Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/HSY.png	COMMON_STOCK	t	2026-06-06 14:58:29.178023+00	2026-06-06 14:58:29.178023+00	hsy	\N	hershey co	hsy hershey co
4472	JBL	NYSE	JBL	\N	Jabil Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/JBL.png	COMMON_STOCK	t	2026-06-06 14:58:29.663363+00	2026-06-06 14:58:29.663363+00	jbl	\N	jabil inc	jbl jabil inc
4473	LYV	NYSE	LYV	\N	Live Nation Entertainment Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/LYV.png	COMMON_STOCK	t	2026-06-06 14:58:30.162741+00	2026-06-06 14:58:30.162741+00	lyv	\N	live nation entertainment inc	lyv live nation entertainment inc
4474	IRM	NYSE	IRM	\N	Iron Mountain Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950443403966.png	COMMON_STOCK	t	2026-06-06 14:58:30.663753+00	2026-06-06 14:58:30.663753+00	irm	\N	iron mountain inc	irm iron mountain inc
4475	WEC	NYSE	WEC	\N	WEC Energy Group Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/WEC.png	COMMON_STOCK	t	2026-06-06 14:58:31.137319+00	2026-06-06 14:58:31.137319+00	wec	\N	wec energy group inc	wec wec energy group inc
4476	VMC	NYSE	VMC	\N	Vulcan Materials Co	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/VMC.png	COMMON_STOCK	t	2026-06-06 14:58:31.618928+00	2026-06-06 14:58:31.618928+00	vmc	\N	vulcan materials co	vmc vulcan materials co
4477	SYY	NYSE	SYY	\N	Sysco Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/SYY.png	COMMON_STOCK	t	2026-06-06 14:58:32.106723+00	2026-06-06 14:58:32.106723+00	syy	\N	sysco corp	syy sysco corp
4478	PYPL	NASDAQ	PYPL	\N	PayPal Holdings Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/PYPL.png	COMMON_STOCK	t	2026-06-06 14:58:32.594021+00	2026-06-06 14:58:32.594021+00	pypl	\N	paypal holdings inc	pypl paypal holdings inc
4479	PRU	NYSE	PRU	\N	Prudential Financial Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/PRU.png	COMMON_STOCK	t	2026-06-06 14:58:33.075707+00	2026-06-06 14:58:33.075707+00	pru	\N	prudential financial inc	pru prudential financial inc
4480	ASTS	NASDAQ	ASTS	\N	AST SpaceMobile Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950711601196.png	COMMON_STOCK	t	2026-06-06 14:58:33.56256+00	2026-06-06 14:58:33.56256+00	asts	\N	ast spacemobile inc	asts ast spacemobile inc
4481	EME	NYSE	EME	\N	EMCOR Group Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/EME.png	COMMON_STOCK	t	2026-06-06 14:58:34.039042+00	2026-06-06 14:58:34.039042+00	eme	\N	emcor group inc	eme emcor group inc
4482	HIG	NYSE	HIG	\N	Hartford Insurance Group Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/HIG.png	COMMON_STOCK	t	2026-06-06 14:58:34.508578+00	2026-06-06 14:58:34.508578+00	hig	\N	hartford insurance group inc	hig hartford insurance group inc
4483	PAYX	NASDAQ	PAYX	\N	Paychex Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/PAYX.png	COMMON_STOCK	t	2026-06-06 14:58:34.994886+00	2026-06-06 14:58:34.994886+00	payx	\N	paychex inc	payx paychex inc
4484	WAT	NYSE	WAT	\N	Waters Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/WAT.png	COMMON_STOCK	t	2026-06-06 14:58:35.499336+00	2026-06-06 14:58:35.499336+00	wat	\N	waters corp	wat waters corp
4485	RKT	NYSE	RKT	\N	Rocket Companies Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/RKT.png	COMMON_STOCK	t	2026-06-06 15:01:48.448454+00	2026-06-06 15:01:48.448454+00	rkt	\N	rocket companies inc	rkt rocket companies inc
4486	WDAY	NASDAQ	WDAY	\N	Workday Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/WDAY.png	COMMON_STOCK	t	2026-06-06 14:58:36.494596+00	2026-06-06 14:58:36.494596+00	wday	\N	workday inc	wday workday inc
4487	HMC	NASDAQ	HMC	\N	Honda Motor Co Ltd	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/7267.T.png	COMMON_STOCK	t	2026-06-06 14:58:36.989031+00	2026-06-06 14:58:36.989031+00	hmc	\N	honda motor co ltd	hmc honda motor co ltd
4488	RYAAY	NASDAQ	RYAAY	\N	Ryanair Holdings PLC	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/RYA.IR.png	COMMON_STOCK	t	2026-06-06 14:58:37.460891+00	2026-06-06 14:58:37.460891+00	ryaay	\N	ryanair holdings plc	ryaay ryanair holdings plc
4489	CHT	NASDAQ	CHT	\N	Chunghwa Telecom Co Ltd	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/2412.TW.png	COMMON_STOCK	t	2026-06-06 14:58:38.137535+00	2026-06-06 14:58:38.137535+00	cht	\N	chunghwa telecom co ltd	cht chunghwa telecom co ltd
4490	MLM	NYSE	MLM	\N	Martin Marietta Materials Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MLM.png	COMMON_STOCK	t	2026-06-06 14:58:38.634764+00	2026-06-06 14:58:38.634764+00	mlm	\N	martin marietta materials inc	mlm martin marietta materials inc
4491	UI	NYSE	UI	\N	Ubiquiti Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/UI.png	COMMON_STOCK	t	2026-06-06 14:58:39.113051+00	2026-06-06 14:58:39.113051+00	ui	\N	ubiquiti inc	ui ubiquiti inc
4492	UAL	NASDAQ	UAL	\N	United Airlines Holdings Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/UAL.png	COMMON_STOCK	t	2026-06-06 14:58:39.679073+00	2026-06-06 14:58:39.679073+00	ual	\N	united airlines holdings inc	ual united airlines holdings inc
4493	TWLO	NYSE	TWLO	\N	Twilio Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/TWLO.png	COMMON_STOCK	t	2026-06-06 14:58:40.157226+00	2026-06-06 14:58:40.157226+00	twlo	\N	twilio inc	twlo twilio inc
4494	KVUE	NYSE	KVUE	\N	Kenvue Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950835574756.png	COMMON_STOCK	t	2026-06-06 14:58:40.644814+00	2026-06-06 14:58:40.644814+00	kvue	\N	kenvue inc	kvue kenvue inc
4495	VOD	NASDAQ	VOD	\N	Vodafone Group PLC	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/VOD.L.png	COMMON_STOCK	t	2026-06-06 14:58:41.140158+00	2026-06-06 14:58:41.140158+00	vod	\N	vodafone group plc	vod vodafone group plc
4496	SATS	NASDAQ	SATS	\N	EchoStar Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/SATS.png	COMMON_STOCK	t	2026-06-06 14:58:41.644038+00	2026-06-06 14:58:41.644038+00	sats	\N	echostar corp	sats echostar corp
4497	EQT	NYSE	EQT	\N	EQT Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/EQT.png	COMMON_STOCK	t	2026-06-06 14:58:42.145945+00	2026-06-06 14:58:42.145945+00	eqt	\N	eqt corp	eqt eqt corp
4498	ROP	NASDAQ	ROP	\N	Roper Technologies Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ROP.png	COMMON_STOCK	t	2026-06-06 14:58:42.642184+00	2026-06-06 14:58:42.642184+00	rop	\N	roper technologies inc	rop roper technologies inc
4499	BBD	NASDAQ	BBD	\N	Banco Bradesco SA	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/BBDC4.SA.png	COMMON_STOCK	t	2026-06-06 14:58:43.139553+00	2026-06-06 14:58:43.139553+00	bbd	\N	banco bradesco sa	bbd banco bradesco sa
4500	HBAN	NASDAQ	HBAN	\N	Huntington Bancshares Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/HBAN.png	COMMON_STOCK	t	2026-06-06 14:58:43.633377+00	2026-06-06 14:58:43.633377+00	hban	\N	huntington bancshares inc	hban huntington bancshares inc
4501	RDDT	NYSE	RDDT	\N	Reddit Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/950440227326.png	COMMON_STOCK	t	2026-06-06 14:58:44.110316+00	2026-06-06 14:58:44.110316+00	rddt	\N	reddit inc	rddt reddit inc
4502	ZTS	NYSE	ZTS	\N	Zoetis Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/ZTS.png	COMMON_STOCK	t	2026-06-06 14:58:44.604024+00	2026-06-06 14:58:44.604024+00	zts	\N	zoetis inc	zts zoetis inc
4503	LVS	NASDAQ	LVS	\N	Las Vegas Sands Corp.		COMMON_STOCK	t	2026-06-06 14:58:45.084306+00	2026-06-06 14:58:45.084306+00	lvs	\N	las vegas sands corp.	lvs las vegas sands corp.
4504	QSR	NASDAQ	QSR	\N	Restaurant Brands International Inc.		COMMON_STOCK	t	2026-06-06 14:58:45.569233+00	2026-06-06 14:58:45.569233+00	qsr	\N	restaurant brands international inc.	qsr restaurant brands international inc.
4505	GFI	NASDAQ	GFI	\N	Gold Fields Limited		COMMON_STOCK	t	2026-06-06 14:58:46.07632+00	2026-06-06 14:58:46.07632+00	gfi	\N	gold fields limited	gfi gold fields limited
4506	KMB	NASDAQ	KMB	\N	Kimberly-Clark Corporation		COMMON_STOCK	t	2026-06-06 14:58:46.5751+00	2026-06-06 14:58:46.5751+00	kmb	\N	kimberly-clark corporation	kmb kimberly-clark corporation
4507	SHG	NASDAQ	SHG	\N	Shinhan Financial Group Co., Ltd.		COMMON_STOCK	t	2026-06-06 14:58:47.076279+00	2026-06-06 14:58:47.076279+00	shg	\N	shinhan financial group co., ltd.	shg shinhan financial group co., ltd.
4508	HAL	NASDAQ	HAL	\N	Halliburton Company		COMMON_STOCK	t	2026-06-06 14:58:47.559919+00	2026-06-06 14:58:47.559919+00	hal	\N	halliburton company	hal halliburton company
4509	NTAP	NASDAQ	NTAP	\N	NetApp, Inc.		COMMON_STOCK	t	2026-06-06 14:58:48.031094+00	2026-06-06 14:58:48.031094+00	ntap	\N	netapp, inc.	ntap netapp, inc.
4510	ALC	NASDAQ	ALC	\N	Alcon Inc.		COMMON_STOCK	t	2026-06-06 14:58:48.525152+00	2026-06-06 14:58:48.525152+00	alc	\N	alcon inc.	alc alcon inc.
4511	MTB	NASDAQ	MTB	\N	M&T Bank Corporation		COMMON_STOCK	t	2026-06-06 14:58:49.010547+00	2026-06-06 14:58:49.010547+00	mtb	\N	m&t bank corporation	mtb m&t bank corporation
4512	SUNB	NASDAQ	SUNB	\N	Sunbelt Rentals Holdings, Inc.		COMMON_STOCK	t	2026-06-06 14:58:49.499327+00	2026-06-06 14:58:49.499327+00	sunb	\N	sunbelt rentals holdings, inc.	sunb sunbelt rentals holdings, inc.
4513	NTR	NASDAQ	NTR	\N	Nutrien Ltd.		COMMON_STOCK	t	2026-06-06 14:58:49.986776+00	2026-06-06 14:58:49.986776+00	ntr	\N	nutrien ltd.	ntr nutrien ltd.
4514	RPRX	NASDAQ	RPRX	\N	Royalty Pharma plc		COMMON_STOCK	t	2026-06-06 14:58:50.472288+00	2026-06-06 14:58:50.472288+00	rprx	\N	royalty pharma plc	rprx royalty pharma plc
4515	EXR	NASDAQ	EXR	\N	Extra Space Storage Inc.		COMMON_STOCK	t	2026-06-06 15:02:03.404671+00	2026-06-06 15:02:03.404671+00	exr	\N	extra space storage inc.	exr extra space storage inc.
4516	PUK	NASDAQ	PUK	\N	Prudential plc		COMMON_STOCK	t	2026-06-06 14:58:51.452847+00	2026-06-06 14:58:51.452847+00	puk	\N	prudential plc	puk prudential plc
4517	VG	NASDAQ	VG	\N	Venture Global, Inc.		COMMON_STOCK	t	2026-06-06 14:58:51.947126+00	2026-06-06 14:58:51.947126+00	vg	\N	venture global, inc.	vg venture global, inc.
4518	ACGL	NASDAQ	ACGL	\N	Arch Capital Group Ltd.		COMMON_STOCK	t	2026-06-06 14:58:52.443766+00	2026-06-06 14:58:52.443766+00	acgl	\N	arch capital group ltd.	acgl arch capital group ltd.
4519	RVMD	NASDAQ	RVMD	\N	Revolution Medicines, Inc.		COMMON_STOCK	t	2026-06-06 14:58:52.911753+00	2026-06-06 14:58:52.911753+00	rvmd	\N	revolution medicines, inc.	rvmd revolution medicines, inc.
4520	TS	NASDAQ	TS	\N	Tenaris S.A.		COMMON_STOCK	t	2026-06-06 14:58:53.378873+00	2026-06-06 14:58:53.378873+00	ts	\N	tenaris s.a.	ts tenaris s.a.
4521	NTRS	NASDAQ	NTRS	\N	Northern Trust Corporation		COMMON_STOCK	t	2026-06-06 14:58:53.861438+00	2026-06-06 14:58:53.861438+00	ntrs	\N	northern trust corporation	ntrs northern trust corporation
4522	KGC	NASDAQ	KGC	\N	Kinross Gold Corporation		COMMON_STOCK	t	2026-06-06 14:58:54.34304+00	2026-06-06 14:58:54.34304+00	kgc	\N	kinross gold corporation	kgc kinross gold corporation
4523	CQP	NASDAQ	CQP	\N	Cheniere Energy Partners, L.P.		COMMON_STOCK	t	2026-06-06 14:58:54.832435+00	2026-06-06 14:58:54.832435+00	cqp	\N	cheniere energy partners, l.p.	cqp cheniere energy partners, l.p.
4524	EC	NASDAQ	EC	\N	Ecopetrol S.A.		COMMON_STOCK	t	2026-06-06 14:58:55.317816+00	2026-06-06 14:58:55.317816+00	ec	\N	ecopetrol s.a.	ec ecopetrol s.a.
4525	NTRA	NASDAQ	NTRA	\N	Natera, Inc.		COMMON_STOCK	t	2026-06-06 15:02:08.265525+00	2026-06-06 15:02:08.265525+00	ntra	\N	natera, inc.	ntra natera, inc.
4526	CNC	NASDAQ	CNC	\N	Centene Corporation		COMMON_STOCK	t	2026-06-06 14:58:56.291146+00	2026-06-06 14:58:56.291146+00	cnc	\N	centene corporation	cnc centene corporation
4527	IQV	NASDAQ	IQV	\N	IQVIA Holdings Inc.		COMMON_STOCK	t	2026-06-06 14:58:56.775486+00	2026-06-06 14:58:56.775486+00	iqv	\N	iqvia holdings inc.	iqv iqvia holdings inc.
4528	VICI	NASDAQ	VICI	\N	VICI Properties Inc.		COMMON_STOCK	t	2026-06-06 14:58:57.277956+00	2026-06-06 14:58:57.277956+00	vici	\N	vici properties inc.	vici vici properties inc.
4529	DTE	NASDAQ	DTE	\N	DTE Energy Company		COMMON_STOCK	t	2026-06-06 14:58:57.765487+00	2026-06-06 14:58:57.765487+00	dte	\N	dte energy company	dte dte energy company
4530	AEE	NASDAQ	AEE	\N	Ameren Corporation		COMMON_STOCK	t	2026-06-06 14:58:58.240927+00	2026-06-06 14:58:58.240927+00	aee	\N	ameren corporation	aee ameren corporation
4531	EL	NASDAQ	EL	\N	The Estée Lauder Companies Inc.		COMMON_STOCK	t	2026-06-06 14:58:58.802234+00	2026-06-06 14:58:58.802234+00	el	\N	the estée lauder companies inc.	el the estée lauder companies inc.
4532	TECK	NASDAQ	TECK	\N	Teck Resources Limited		COMMON_STOCK	t	2026-06-06 14:58:59.298433+00	2026-06-06 14:58:59.298433+00	teck	\N	teck resources limited	teck teck resources limited
4533	TCOM	NASDAQ	TCOM	\N	Trip.com Group Limited		COMMON_STOCK	t	2026-06-06 14:58:59.798261+00	2026-06-06 14:58:59.798261+00	tcom	\N	trip.com group limited	tcom trip.com group limited
4534	ONC	NASDAQ	ONC	\N	BeOne Medicines AG		COMMON_STOCK	t	2026-06-06 14:59:00.297199+00	2026-06-06 14:59:00.297199+00	onc	\N	beone medicines ag	onc beone medicines ag
4535	FSLR	NASDAQ	FSLR	\N	First Solar, Inc.		COMMON_STOCK	t	2026-06-06 14:59:00.782576+00	2026-06-06 14:59:00.782576+00	fslr	\N	first solar, inc.	fslr first solar, inc.
4536	RBLX	NASDAQ	RBLX	\N	Roblox Corporation		COMMON_STOCK	t	2026-06-06 14:59:01.256153+00	2026-06-06 14:59:01.256153+00	rblx	\N	roblox corporation	rblx roblox corporation
4537	ZM	NASDAQ	ZM	\N	Zoom Communications, Inc.		COMMON_STOCK	t	2026-06-06 14:59:01.733102+00	2026-06-06 14:59:01.733102+00	zm	\N	zoom communications, inc.	zm zoom communications, inc.
4538	AMRZ	NASDAQ	AMRZ	\N	Amrize AG		COMMON_STOCK	t	2026-06-06 14:59:02.205244+00	2026-06-06 14:59:02.205244+00	amrz	\N	amrize ag	amrz amrize ag
4539	Q	NASDAQ	Q	\N	Qnity Electronics, Inc.		COMMON_STOCK	t	2026-06-06 14:59:02.68795+00	2026-06-06 14:59:02.68795+00	q	\N	qnity electronics, inc.	q qnity electronics, inc.
4540	RJF	NASDAQ	RJF	\N	Raymond James Financial, Inc.		COMMON_STOCK	t	2026-06-06 14:59:03.177258+00	2026-06-06 14:59:03.177258+00	rjf	\N	raymond james financial, inc.	rjf raymond james financial, inc.
4541	CBOE	NASDAQ	CBOE	\N	Cboe Global Markets, Inc.		COMMON_STOCK	t	2026-06-06 14:59:03.656504+00	2026-06-06 14:59:03.656504+00	cboe	\N	cboe global markets, inc.	cboe cboe global markets, inc.
4542	GEHC	NASDAQ	GEHC	\N	GE HealthCare Technologies Inc.		COMMON_STOCK	t	2026-06-06 14:59:04.143852+00	2026-06-06 14:59:04.143852+00	gehc	\N	ge healthcare technologies inc.	gehc ge healthcare technologies inc.
4543	FISV	NASDAQ	FISV	\N	Fiserv, Inc.		COMMON_STOCK	t	2026-06-06 14:59:04.643004+00	2026-06-06 14:59:04.643004+00	fisv	\N	fiserv, inc.	fisv fiserv, inc.
4544	DOV	NASDAQ	DOV	\N	Dover Corporation		COMMON_STOCK	t	2026-06-06 14:59:05.121508+00	2026-06-06 14:59:05.121508+00	dov	\N	dover corporation	dov dover corporation
4545	BIIB	NASDAQ	BIIB	\N	Biogen Inc.		COMMON_STOCK	t	2026-06-06 14:59:05.58363+00	2026-06-06 14:59:05.58363+00	biib	\N	biogen inc.	biib biogen inc.
4546	CPRT	NASDAQ	CPRT	\N	Copart, Inc.		COMMON_STOCK	t	2026-06-06 15:02:18.52019+00	2026-06-06 15:02:18.52019+00	cprt	\N	copart, inc.	cprt copart, inc.
4547	FTS	NASDAQ	FTS	\N	Fortis Inc.		COMMON_STOCK	t	2026-06-06 14:59:06.548628+00	2026-06-06 14:59:06.548628+00	fts	\N	fortis inc.	fts fortis inc.
4548	PBA	NASDAQ	PBA	\N	Pembina Pipeline Corporation		COMMON_STOCK	t	2026-06-06 14:59:07.018076+00	2026-06-06 14:59:07.018076+00	pba	\N	pembina pipeline corporation	pba pembina pipeline corporation
4549	ATO	NASDAQ	ATO	\N	Atmos Energy Corporation		COMMON_STOCK	t	2026-06-06 14:59:07.502548+00	2026-06-06 14:59:07.502548+00	ato	\N	atmos energy corporation	ato atmos energy corporation
4550	MTZ	NASDAQ	MTZ	\N	MasTec, Inc.		COMMON_STOCK	t	2026-06-06 14:59:07.991848+00	2026-06-06 14:59:07.991848+00	mtz	\N	mastec, inc.	mtz mastec, inc.
4551	RMD	NASDAQ	RMD	\N	ResMed Inc.		COMMON_STOCK	t	2026-06-06 14:59:08.463022+00	2026-06-06 14:59:08.463022+00	rmd	\N	resmed inc.	rmd resmed inc.
4553	IR	NASDAQ	IR	\N	Ingersoll Rand Inc.		COMMON_STOCK	t	2026-06-06 14:59:09.456076+00	2026-06-06 14:59:09.456076+00	ir	\N	ingersoll rand inc.	ir ingersoll rand inc.
4554	EIX	NASDAQ	EIX	\N	Edison International		COMMON_STOCK	t	2026-06-06 14:59:09.926701+00	2026-06-06 14:59:09.926701+00	eix	\N	edison international	eix edison international
4555	MDB	NASDAQ	MDB	\N	MongoDB, Inc.		COMMON_STOCK	t	2026-06-06 14:59:10.401122+00	2026-06-06 14:59:10.401122+00	mdb	\N	mongodb, inc.	mdb mongodb, inc.
4556	CASY	NASDAQ	CASY	\N	Casey's General Stores, Inc.		COMMON_STOCK	t	2026-06-06 15:02:23.339781+00	2026-06-06 15:02:23.339781+00	casy	\N	casey's general stores, inc.	casy casey's general stores, inc.
4557	DXCM	NASDAQ	DXCM	\N	DexCom, Inc.		COMMON_STOCK	t	2026-06-06 14:59:11.562022+00	2026-06-06 14:59:11.562022+00	dxcm	\N	dexcom, inc.	dxcm dexcom, inc.
4558	AXIA	NASDAQ	AXIA	\N	AXIA Energia SA		COMMON_STOCK	t	2026-06-06 14:59:12.034951+00	2026-06-06 14:59:12.034951+00	axia	\N	axia energia sa	axia axia energia sa
4559	FOXA	NASDAQ	FOXA	\N	Fox Corporation		COMMON_STOCK	t	2026-06-06 14:59:12.509896+00	2026-06-06 14:59:12.509896+00	foxa	\N	fox corporation	foxa fox corporation
4560	VEEV	NASDAQ	VEEV	\N	Veeva Systems Inc.		COMMON_STOCK	t	2026-06-06 14:59:12.999543+00	2026-06-06 14:59:12.999543+00	veev	\N	veeva systems inc.	veev veeva systems inc.
4561	CNP	NASDAQ	CNP	\N	CenterPoint Energy, Inc.		COMMON_STOCK	t	2026-06-06 14:59:13.482068+00	2026-06-06 14:59:13.482068+00	cnp	\N	centerpoint energy, inc.	cnp centerpoint energy, inc.
4562	TDY	NASDAQ	TDY	\N	Teledyne Technologies Incorporated		COMMON_STOCK	t	2026-06-06 14:59:14.054286+00	2026-06-06 14:59:14.054286+00	tdy	\N	teledyne technologies incorporated	tdy teledyne technologies incorporated
4563	EXPE	NASDAQ	EXPE	\N	Expedia Group, Inc.		COMMON_STOCK	t	2026-06-06 14:59:14.534063+00	2026-06-06 14:59:14.534063+00	expe	\N	expedia group, inc.	expe expedia group, inc.
4564	NRG	NYSE	NRG	\N	NRG Energy Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/NRG.png	COMMON_STOCK	t	2026-06-06 14:59:14.9977+00	2026-06-06 14:59:14.9977+00	nrg	\N	nrg energy inc	nrg nrg energy inc
4565	CPNG	NYSE	CPNG	\N	Coupang Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/CPNG.png	COMMON_STOCK	t	2026-06-06 14:59:15.498042+00	2026-06-06 14:59:15.498042+00	cpng	\N	coupang inc	cpng coupang inc
4566	CW	NYSE	CW	\N	Curtiss-Wright Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/CW.png	COMMON_STOCK	t	2026-06-06 15:02:28.425408+00	2026-06-06 15:02:28.425408+00	cw	\N	curtiss-wright corp	cw curtiss-wright corp
4567	AVB	NYSE	AVB	\N	AvalonBay Communities Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/942959034786.png	COMMON_STOCK	t	2026-06-06 14:59:16.446465+00	2026-06-06 14:59:16.446465+00	avb	\N	avalonbay communities inc	avb avalonbay communities inc
4568	STRL	NASDAQ	STRL	\N	Sterling Infrastructure Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/STRL.png	COMMON_STOCK	t	2026-06-06 14:59:16.927711+00	2026-06-06 14:59:16.927711+00	strl	\N	sterling infrastructure inc	strl sterling infrastructure inc
4569	CFG	NYSE	CFG	\N	Citizens Financial Group Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/CFG.png	COMMON_STOCK	t	2026-06-06 14:59:17.412931+00	2026-06-06 14:59:17.412931+00	cfg	\N	citizens financial group inc	cfg citizens financial group inc
4570	OTIS	NYSE	OTIS	\N	Otis Worldwide Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/OTIS.png	COMMON_STOCK	t	2026-06-06 14:59:17.909667+00	2026-06-06 14:59:17.909667+00	otis	\N	otis worldwide corp	otis otis worldwide corp
4571	PPL	NYSE	PPL	\N	PPL Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/PPL.png	COMMON_STOCK	t	2026-06-06 14:59:18.409571+00	2026-06-06 14:59:18.409571+00	ppl	\N	ppl corp	ppl ppl corp
4572	TPL	NYSE	TPL	\N	Texas Pacific Land Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/TPL.png	COMMON_STOCK	t	2026-06-06 14:59:18.88427+00	2026-06-06 14:59:18.88427+00	tpl	\N	texas pacific land corp	tpl texas pacific land corp
4573	VRSN	NASDAQ	VRSN	\N	VeriSign, Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/VRSN.png	COMMON_STOCK	t	2026-06-06 14:59:19.359176+00	2026-06-06 14:59:19.359176+00	vrsn	\N	verisign, inc	vrsn verisign, inc
4574	JBHT	NASDAQ	JBHT	\N	J B Hunt Transport Services Inc	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/JBHT.png	COMMON_STOCK	t	2026-06-06 14:59:19.827182+00	2026-06-06 14:59:19.827182+00	jbht	\N	j b hunt transport services inc	jbht j b hunt transport services inc
4575	FE	NYSE	FE	\N	FirstEnergy Corp	https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/FE.png	COMMON_STOCK	t	2026-06-06 14:59:20.292532+00	2026-06-06 14:59:20.292532+00	fe	\N	firstenergy corp	fe firstenergy corp
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, password_hash, nickname, status, created_at, updated_at, google_subject, profile_image_url, auth_token, auth_token_expires_at, last_login_at) FROM stdin;
1	dev@maemoji.local	LOCAL_DEV_ONLY	MaeMoJi 개발 사용자	ACTIVE	2026-06-06 10:24:08.482852+00	2026-06-06 10:24:08.482852+00	\N	\N	\N	\N	\N
2	onetwotown123@gmail.com	GOOGLE_AUTH	ff 123	ACTIVE	2026-06-10 12:21:48.581455+00	2026-06-10 12:21:48.581455+00	111960185236941552176		fadd9debf98a4601b9e75b5026f622d99c4fc0f213bf46f1828629b3fa99c3d6	2026-07-13 23:51:40.898336+00	2026-06-13 23:51:40.898336+00
\.


--
-- Name: news_analysis_cache_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.news_analysis_cache_id_seq', 218, true);


--
-- Name: portfolio_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.portfolio_items_id_seq', 15, true);


--
-- Name: recommendation_evidence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recommendation_evidence_id_seq', 876, true);


--
-- Name: recommendation_factor_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recommendation_factor_details_id_seq', 1, false);


--
-- Name: recommendations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recommendations_id_seq', 186, true);


--
-- Name: stock_price_snapshots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stock_price_snapshots_id_seq', 3773, true);


--
-- Name: stocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stocks_id_seq', 4575, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 2, true);


--
-- Name: news_analysis_cache news_analysis_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_analysis_cache
    ADD CONSTRAINT news_analysis_cache_pkey PRIMARY KEY (id);


--
-- Name: portfolio_items portfolio_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.portfolio_items
    ADD CONSTRAINT portfolio_items_pkey PRIMARY KEY (id);


--
-- Name: recommendation_evidence recommendation_evidence_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendation_evidence
    ADD CONSTRAINT recommendation_evidence_pkey PRIMARY KEY (id);


--
-- Name: recommendation_factor_details recommendation_factor_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendation_factor_details
    ADD CONSTRAINT recommendation_factor_details_pkey PRIMARY KEY (id);


--
-- Name: recommendations recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_pkey PRIMARY KEY (id);


--
-- Name: stock_price_snapshots stock_price_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_price_snapshots
    ADD CONSTRAINT stock_price_snapshots_pkey PRIMARY KEY (id);


--
-- Name: stocks stocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stocks
    ADD CONSTRAINT stocks_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_news_analysis_cache_stock_published_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_news_analysis_cache_stock_published_at ON public.news_analysis_cache USING btree (stock_id, news_published_at DESC);


--
-- Name: idx_news_analysis_cache_symbol_analyzed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_news_analysis_cache_symbol_analyzed_at ON public.news_analysis_cache USING btree (symbol, analyzed_at DESC);


--
-- Name: idx_portfolio_items_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_portfolio_items_user_id ON public.portfolio_items USING btree (user_id);


--
-- Name: idx_recommendation_evidence_recommendation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recommendation_evidence_recommendation_id ON public.recommendation_evidence USING btree (recommendation_id);


--
-- Name: idx_recommendation_factor_details_factor_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recommendation_factor_details_factor_code ON public.recommendation_factor_details USING btree (factor_code);


--
-- Name: idx_recommendation_factor_details_recommendation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recommendation_factor_details_recommendation_id ON public.recommendation_factor_details USING btree (recommendation_id);


--
-- Name: idx_recommendations_portfolio_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recommendations_portfolio_item_id ON public.recommendations USING btree (portfolio_item_id);


--
-- Name: idx_recommendations_user_id_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recommendations_user_id_date ON public.recommendations USING btree (user_id, recommendation_date DESC);


--
-- Name: idx_stock_price_snapshots_stock_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_stock_price_snapshots_stock_date ON public.stock_price_snapshots USING btree (stock_id, snapshot_date DESC);


--
-- Name: idx_stocks_name_en; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_stocks_name_en ON public.stocks USING btree (name_en);


--
-- Name: idx_stocks_name_en_normalized; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_stocks_name_en_normalized ON public.stocks USING btree (name_en_normalized);


--
-- Name: idx_stocks_name_ko; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_stocks_name_ko ON public.stocks USING btree (name_ko);


--
-- Name: idx_stocks_name_ko_normalized; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_stocks_name_ko_normalized ON public.stocks USING btree (name_ko_normalized);


--
-- Name: idx_stocks_ticker_normalized; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_stocks_ticker_normalized ON public.stocks USING btree (ticker_normalized);


--
-- Name: uk_news_analysis_cache_stock_content; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_news_analysis_cache_stock_content ON public.news_analysis_cache USING btree (stock_id, content_hash);


--
-- Name: uk_portfolio_items_user_stock; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_portfolio_items_user_stock ON public.portfolio_items USING btree (user_id, stock_id);


--
-- Name: uk_recommendations_portfolio_item_date; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_recommendations_portfolio_item_date ON public.recommendations USING btree (portfolio_item_id, recommendation_date);


--
-- Name: uk_stock_price_snapshots_stock_date; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_stock_price_snapshots_stock_date ON public.stock_price_snapshots USING btree (stock_id, snapshot_date);


--
-- Name: uk_stocks_finnhub_symbol; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_stocks_finnhub_symbol ON public.stocks USING btree (finnhub_symbol) WHERE (finnhub_symbol IS NOT NULL);


--
-- Name: uk_stocks_ticker_exchange; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_stocks_ticker_exchange ON public.stocks USING btree (ticker, exchange_code);


--
-- Name: uk_users_auth_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_users_auth_token ON public.users USING btree (auth_token) WHERE (auth_token IS NOT NULL);


--
-- Name: uk_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_users_email ON public.users USING btree (email);


--
-- Name: uk_users_google_subject; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_users_google_subject ON public.users USING btree (google_subject);


--
-- Name: news_analysis_cache fk_news_analysis_cache_stock; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_analysis_cache
    ADD CONSTRAINT fk_news_analysis_cache_stock FOREIGN KEY (stock_id) REFERENCES public.stocks(id);


--
-- Name: portfolio_items fk_portfolio_items_stock; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.portfolio_items
    ADD CONSTRAINT fk_portfolio_items_stock FOREIGN KEY (stock_id) REFERENCES public.stocks(id);


--
-- Name: portfolio_items fk_portfolio_items_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.portfolio_items
    ADD CONSTRAINT fk_portfolio_items_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: recommendation_evidence fk_recommendation_evidence_recommendation; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendation_evidence
    ADD CONSTRAINT fk_recommendation_evidence_recommendation FOREIGN KEY (recommendation_id) REFERENCES public.recommendations(id);


--
-- Name: recommendation_factor_details fk_recommendation_factor_details_recommendation; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendation_factor_details
    ADD CONSTRAINT fk_recommendation_factor_details_recommendation FOREIGN KEY (recommendation_id) REFERENCES public.recommendations(id);


--
-- Name: recommendations fk_recommendations_portfolio_item; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT fk_recommendations_portfolio_item FOREIGN KEY (portfolio_item_id) REFERENCES public.portfolio_items(id);


--
-- Name: recommendations fk_recommendations_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT fk_recommendations_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: stock_price_snapshots fk_stock_price_snapshots_stock; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_price_snapshots
    ADD CONSTRAINT fk_stock_price_snapshots_stock FOREIGN KEY (stock_id) REFERENCES public.stocks(id);


--
-- PostgreSQL database dump complete
--

\unrestrict DeaVx5Jo0Zd29JdxFbBplE5YOqJW9DngMVp1ltftk86GpJNOHr5cMAKMinawsG7

