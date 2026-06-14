--
-- PostgreSQL database dump
--

\restrict wupSDgjNbls2cfD5PZFoldQnU8f50ooIRBTi4zJWH8zqCTsPWh7gEZL96tHOqDh

-- Dumped from database version 16.14 (Debian 16.14-1.pgdg13+1)
-- Dumped by pg_dump version 16.14

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
    CONSTRAINT ck_news_analysis_impact_level CHECK (((impact_level)::text = ANY ((ARRAY['LOW'::character varying, 'MEDIUM'::character varying, 'HIGH'::character varying])::text[]))),
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
99	4077	2026-06-10 02:22:14+00	Why Apple (AAPL) Shares Are Sliding Today	WWDC 키노트에서 투자자들이 기대했던 AI 도약이 이루어지지 않으면서 애플 주가가 하락했습니다.	Yahoo	https://finnhub.io/api/news?id=14f0e64fe824438fc92b1aa5453e14cbd0ed37814867160a36c01546a60f9d0c	NEGATIVE	-51	gemini-2.5-flash-lite	2026-06-10 14:28:09.89794+00	140589923	AAPL	0	90	HIGH	AI에 대한 투자자들의 높은 기대감이 충족되지 못한 점이 애플 주가 하락의 직접적인 원인으로 분석됩니다.	1.0000	1.3500	-61.9650	da4479e9f2d1faa0d77dfa0c4094cd0a0dade7640a0a2e43a0525c5c78ddb40e	2026-06-10 14:28:12.25556+00	b86f8962f821ca2c8f30f0beae9394c6da3a4a63e42948c8826473c5fc55e660
100	4077	2026-06-10 13:08:04+00	Apple (AAPL) Declined Defies Strong Fundamentals	런던 컴퍼니의 투자 서한에 따르면 2026년 1분기 미국 주식이 전반적으로 하락했으며, 이는 애플의 주가에도 부정적인 영향을 미칠 수 있습니다.	Yahoo	https://finnhub.io/api/news?id=7a7ca43bcf0341ce8917c1035a5193824bdf8d2ecfb1012cea8c83482de76263	NEGATIVE	-23	gemini-2.5-flash-lite	2026-06-10 14:28:09.89794+00	140592712	AAPL	18	90	MEDIUM	투자 서한은 전반적인 시장 상황을 설명하지만, 애플 주가 하락에 대한 구체적인 언급은 부족합니다.	1.0000	1.0000	-20.7000	7899e9029d9edae9417569806af48bb17d201d716a8143225a83fec724687203	2026-06-10 14:28:12.258209+00	b86f8962f821ca2c8f30f0beae9394c6da3a4a63e42948c8826473c5fc55e660
101	4077	2026-06-09 22:07:54+00	S&P 500, Nasdaq End Lower As Investors Take Breather From AI And Chips — AAPL, ASTS, APLD, RIVN, ZVRA In Focus	S&P 500과 나스닥이 AI 및 반도체 관련 투자 열기가 식으면서 하락했으며, 해당 기사에서는 애플을 포함한 여러 종목을 중점적으로 다룹니다.	Yahoo	https://finnhub.io/api/news?id=34a7d68cf886e3ee6dc68de76f007d35624f2425aacbabea652c73d586e84ecb	NEUTRAL	0	gemini-2.5-flash-lite	2026-06-10 14:28:09.89794+00	140588210	AAPL	0	90	LOW	기사는 전반적인 시장 동향을 다루며 애플의 주가에 직접적인 영향을 주는 요인을 언급하지 않습니다.	1.0000	0.7500	0.0000	f5e3cbef0082f96450c7adc905abaa25e864d8389519b0d73d49832d9fc6fcc6	2026-06-10 14:28:12.260352+00	b86f8962f821ca2c8f30f0beae9394c6da3a4a63e42948c8826473c5fc55e660
102	4078	2026-06-10 09:01:59+00	Alphabet's Google Backs Anthropic in $35 Billion Chip Arrangement	Alphabet은 AI 인프라에 800억 달러를 투자할 예정이며, 이는 올해 남은 기간 동안 AI 인프라 지출이 연간 30%씩 증가할 것으로 예상되는 가운데 관련 반도체 주식에 긍정적인 영향을 미칩니다.	Yahoo	https://finnhub.io/api/news?id=27dcea23707e27d80ef7bd0b856c754fd70d168e55d2a386c0a09c25be2c17e9	POSITIVE	68	gemini-2.5-flash-lite	2026-06-10 14:37:33.488316+00	140591378	GOOGL	0	75	HIGH	Alphabet이 AI 인프라 구축을 위해 800억 달러를 투자하는 것은 AI 분야의 성장 잠재력과 관련 반도체 기업들의 수혜를 시사하며, Alphabet 자체의 AI 역량 강화에 긍정적입니다.	1.0000	1.3500	68.8500	89c2ad21e1532255111597ce1b5336f50d21c39d0ea394b2b3799c61d2c56335	2026-06-10 14:37:36.309912+00	fcba68238035eb5a1e6410f87212c2f20d19160f1a3833a1da9d36ccdce20658
98	4142	2026-06-10 03:16:05+00	Is McDonald's (MCD) Price Justified After Mixed Returns And Conflicting Valuation Signals?	Jim Cramer는 맥도날드 주식에 대해 걱정할 필요가 없다고 언급하며 긍정적인 견해를 보였습니다.	Yahoo	https://finnhub.io/api/news?id=93823359877a0caee389f50a052ee11268ccd0a92f0cb9ddbb576ec90740634b	POSITIVE	51	gemini-2.5-flash-lite	2026-06-10 14:27:55.731168+00	140589968	MCD	0	78	MEDIUM	Jim Cramer가 맥도날드 주가에 대해 긍정적인 발언을 하며 투자 심리에 영향을 미칠 수 있기 때문입니다.	1.0000	1.0000	39.7800	5f2c2b5833f98dcf2a24a8b53d489cfb0e80edbc199c18b5cec57829d7c98bf6	2026-06-10 14:27:59.665833+00	015b9295fec6698735c9c906bddc84a609744cbd1a4fd9f71a9bce6cd5f6fa18
103	4078	2026-06-10 13:54:14+00	Apple's AI Push Deepens Alphabet Dependency	Alphabet의 Google은 AI 모델 Claude의 개발사인 Anthropic이 고가의 강력한 컴퓨터 칩을 5개의 데이터 센터에서 임대하는 데 지원합니다.	Yahoo	https://finnhub.io/api/news?id=a50a4a1671ab8a72b6d1d2721c21f3b90ea6dff5f915891006ec019ee4bc906f	POSITIVE	60	gemini-2.5-flash-lite	2026-06-10 14:37:33.488316+00	140592709	GOOGL	0	75	HIGH	Alphabet이 AI 모델 Claude 개발사인 Anthropic과의 350억 달러 규모 칩 계약에 참여하는 것은 AI 분야에서의 입지를 강화하고 관련 매출 증대에 기여할 수 있습니다.	1.0000	1.3500	60.7500	1ed6c10a0e6d50cb88081e924c2052368b5aa45d7a7fd0473ab12a270fb0caa8	2026-06-10 14:37:36.313069+00	fcba68238035eb5a1e6410f87212c2f20d19160f1a3833a1da9d36ccdce20658
97	4142	2026-06-10 09:43:01+00	Jim Cramer Discusses a Strategic Buying Plan to Build a Great Cost Basis in McDonald’s	맥도날드는 다세대 소유에 적합한 구조적 특성을 가지고 있어 장기 투자에 매우 적합한 기업으로 평가됩니다.	Yahoo	https://finnhub.io/api/news?id=2c03ba8ecd8de0968b787ddd8db1f8063278751ec0975bd4ef02ffaf001669a7	POSITIVE	68	gemini-2.5-flash-lite	2026-06-10 14:27:55.731168+00	140591443	MCD	0	75	HIGH	기사에서 맥도날드를 향후 25년간 보유할 만한 '멈출 수 없는 거대 기업'으로 극찬하며 강력한 매수 의견을 제시하기 때문입니다.	1.0000	1.3500	68.8500	90ea0c0486cef9399c6cdcd5fb6caf6fdd86d7e612ade985bc73f858fdf3acb9	2026-06-10 14:27:59.661887+00	015b9295fec6698735c9c906bddc84a609744cbd1a4fd9f71a9bce6cd5f6fa18
96	4341	2026-06-10 03:15:54+00	A Look At Nike (NKE) Valuation As Recent Share Performance Remains Mixed	나이키의 최근 주가 성과가 혼조세를 보이며, 지난 주와 월에는 상승했지만 3개월 및 연초 대비 하락했다는 내용입니다.	Yahoo	https://finnhub.io/api/news?id=dab969ef221a683b305565ddf4d28d6b07f28721f6ea975de6772bad93f2363f	NEUTRAL	0	gemini-2.5-flash-lite	2026-06-10 14:22:12.106328+00	140590021	NKE	0	90	LOW	주가 성과가 혼조세를 보이는 것은 긍정적 또는 부정적 영향으로 단정하기 어렵습니다.	1.0000	0.7500	0.0000	9cbcc032ff05cfb1bbe7cf144998a480801d4567330bb67e8a0b6a0e2a5c0cc4	2026-06-10 14:22:15.492427+00	e7a0de6eebdf35405c02662d2fba4e4c58cfecd9b2ed473c72b1f0f3a2340009
94	4341	2026-06-10 08:43:14+00	Why Is NKE Stock Falling Premarket Today?	RBC Capital Markets가 나이키의 투자의견을 '아웃퍼폼'에서 '섹터 퍼폼'으로 하향하고 목표주가를 50달러로 낮췄다는 소식입니다.	Yahoo	https://finnhub.io/api/news?id=a89fc467cd4b7b7a198e074068d6c64b03bf755f5623205e3080f0a3f2ab9f9a	NEGATIVE	-59	gemini-2.5-flash-lite	2026-06-10 14:22:12.106328+00	140591478	NKE	0	90	HIGH	증권사의 투자의견 하향과 목표주가 절하는 단기 주가에 부정적인 영향을 미칠 수 있습니다.	1.0000	1.3500	-71.6850	a8baa13a9a5449550c719da919f4a84fa54464f55cd2095bf1f32b2aeb0f707d	2026-06-10 14:22:15.485619+00	e7a0de6eebdf35405c02662d2fba4e4c58cfecd9b2ed473c72b1f0f3a2340009
95	4341	2026-06-10 13:42:21+00	Nike downgraded, Oscar Health upgraded: Wall Street's top analyst calls	월스트리트 애널리스트들의 분석에서 나이키의 투자의견이 하향 조정되었다는 소식입니다.	Yahoo	https://finnhub.io/api/news?id=ce53bffcd338c472bc29c9a9e53f3907cf622b2cc643bd1cebb523037366c2d7	NEGATIVE	-51	gemini-2.5-flash-lite	2026-06-10 14:22:12.106328+00	140592876	NKE	0	75	MEDIUM	애널리스트의 투자의견 하향은 해당 기업에 대한 투자 심리에 부정적인 영향을 줄 수 있습니다.	1.0000	1.0000	-38.2500	bb8d6cc2c334d4820f0a0c9395c8bdd5af4d9b788142c0012e41e23bf9d81a8b	2026-06-10 14:22:15.489072+00	e7a0de6eebdf35405c02662d2fba4e4c58cfecd9b2ed473c72b1f0f3a2340009
\.


--
-- Data for Name: portfolio_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.portfolio_items (id, user_id, stock_id, daily_invest_amount, holding_quantity, investment_start_date, memo, is_active, created_at, updated_at) FROM stdin;
3	1	4239	50.00	2.000000	2026-06-11	2	f	2026-06-06 23:31:51.933337+00	2026-06-07 00:41:03.943058+00
5	1	4078	20.00	2.000000	2026-06-01	\N	t	2026-06-07 00:49:00.427339+00	2026-06-07 00:49:00.427339+00
4	1	4077	12.00	2.000000	2026-06-02	\N	t	2026-06-06 23:57:37.533449+00	2026-06-07 00:49:09.47846+00
6	1	4142	5.00	1.000000	2026-06-01	\N	t	2026-06-07 10:34:55.036004+00	2026-06-07 10:34:55.036004+00
7	1	4341	22.00	2.000000	2026-06-08	12312312	t	2026-06-07 13:46:18.623769+00	2026-06-07 13:46:18.623769+00
\.


--
-- Data for Name: recommendation_evidence; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recommendation_evidence (id, recommendation_id, evidence_type, title, body, score_impact, display_order, created_at) FROM stdin;
141	1	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-07 10:02:54.473347+00
142	1	NEWS	관련 뉴스 분석	애플은 AI 전략을 중심으로 긍정적인 투자 전망을 받고 있습니다. 모건 스탠리는 AI 성공이 주가 가치를 높일 것이라며 "Overweight" 등급과 높은 목표 주가를 제시했습니다. 현재 주가는 사상 최고치에 근접해 있지만, 시리(Siri)의 대규모 AI 개편이 새로운 성장 동력으로 작용할 것으로 기대됩니다. 특히 애플이 시리 개선을 위해 엔비디아 칩과 구글 클라우드를 활용하는 등 전통적인 자체 구축 방식에서 벗어나 외부 기술과 협력하는 전략적 변화는 장기적인 관점에서 긍정적인 영향을 미칠 것으로 분석됩니다. Gemini 종합 감성 +62점을 정규화해 뉴스 점수 81점으로 계산했습니다.	81	2	2026-06-07 10:02:54.473347+00
143	1	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 81점, 위험 조정 +0점, 최종 81점입니다.	0	3	2026-06-07 10:02:54.473347+00
144	1	AI_NOTE	최종 해석	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-07 10:02:54.473347+00
145	2	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-07 10:02:54.473347+00
146	2	NEWS	관련 뉴스 분석	최근 관련 뉴스는 전반적으로 긍정적이며 최신성과 영향도를 반영한 가중 점수도 양호합니다. Gemini 종합 감성 +54점을 정규화해 뉴스 점수 77점으로 계산했습니다.	77	2	2026-06-07 10:02:54.473347+00
147	2	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 77점, 위험 조정 +0점, 최종 77점입니다.	0	3	2026-06-07 10:02:54.473347+00
148	2	AI_NOTE	최종 해석	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-07 10:02:54.473347+00
230	3	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 14:37:28.451277+00
231	3	NEWS	관련 뉴스 분석	최근 관련 뉴스는 전반적으로 부정적이며 최신성과 영향도를 반영해 보수적으로 평가했습니다. Gemini 종합 감성 -42점을 정규화해 뉴스 점수 29점으로 계산했습니다.	29	2	2026-06-10 14:37:28.451277+00
232	3	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 29점, 위험 조정 +0점, 최종 29점입니다.	0	3	2026-06-10 14:37:28.451277+00
233	3	AI_NOTE	최종 해석	Nike Inc은 현재 데이터 기준으로 리스크 관리가 우선이라, 매수보다 중단 또는 관망 쪽에 더 가까운 상태입니다.	\N	4	2026-06-10 14:37:28.451277+00
254	50	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 15:07:14.320013+00
255	50	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-10 15:07:14.320013+00
256	50	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-10 15:07:14.320013+00
257	50	AI_NOTE	최종 해석	Nike Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-10 15:07:14.320013+00
339	61	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-13 13:30:29.347095+00
340	61	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-13 13:30:29.347095+00
341	61	AI_NOTE	최종 해석	McDonald's Corporation은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-13 13:30:29.347095+00
346	55	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-13 13:37:20.990403+00
347	55	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-13 13:37:20.990403+00
348	55	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-13 13:37:20.990403+00
349	55	AI_NOTE	최종 해석	Nike Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-13 13:37:20.990403+00
350	70	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-13 13:42:57.554248+00
351	70	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-13 13:42:57.554248+00
352	70	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-13 13:42:57.554248+00
353	70	AI_NOTE	최종 해석	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-13 13:42:57.554248+00
354	79	PRICE	가격 흐름	가격 데이터가 충분하지 않아 가격 흐름 평가는 보수적으로 반영했어요.	\N	1	2026-06-14 01:22:28.019195+00
355	79	NEWS	관련 뉴스 분석	최근 관련 뉴스는 전반적으로 부정적이며 최신성과 영향도를 반영해 보수적으로 평가했습니다. 종합 뉴스 점수 29를 반영했어요.	29	2	2026-06-14 01:22:28.019195+00
356	79	EARNINGS	기업 체력	시총과 밸류에이션 기반의 1차 기초체력 점수 66를 함께 반영했어요.	66	3	2026-06-14 01:22:28.019195+00
357	79	INSTITUTION	내 투자 상황	현재 매일 모으기 금액과 보유 상황을 반영한 적합도 점수 62를 적용했어요.	62	4	2026-06-14 01:22:28.019195+00
358	79	FORMULA	최종 점수 계산	V4 멀티 팩터 모델로 계산했어요. 원점수 50점에 위험 조정 +0점을 반영해 최종 50점이 되었어요.	0	5	2026-06-14 01:22:28.019195+00
314	62	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-13 13:20:23.181787+00
315	62	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-13 13:20:23.181787+00
316	62	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-13 13:20:23.181787+00
317	62	AI_NOTE	최종 해석	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-13 13:20:23.181787+00
234	6	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 14:37:33.488316+00
235	6	NEWS	관련 뉴스 분석	Alphabet은 Apple의 AI 기능 강화에 따른 Google AI 인프라 의존도 증가, Anthropic과의 AI 칩 계약, 그리고 AI 인프라 구축을 위한 대규모 투자 등 AI 분야에서의 긍정적인 소식들로 인해 주가 및 장기 투자에 긍정적인 영향을 받을 것으로 예상됩니다. Gemini 종합 감성 +54점을 정규화해 뉴스 점수 77점으로 계산했습니다.	77	2	2026-06-10 14:37:33.488316+00
236	6	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 77점, 위험 조정 +0점, 최종 77점입니다.	0	3	2026-06-10 14:37:33.488316+00
237	6	AI_NOTE	최종 해석	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-10 14:37:33.488316+00
242	51	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 15:06:07.988866+00
243	51	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-10 15:06:07.988866+00
244	51	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-10 15:06:07.988866+00
245	51	AI_NOTE	최종 해석	McDonald's Corporation은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-10 15:06:07.988866+00
246	52	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 15:06:07.988866+00
247	52	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-10 15:06:07.988866+00
248	52	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-10 15:06:07.988866+00
249	52	AI_NOTE	최종 해석	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-10 15:06:07.988866+00
338	61	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-13 13:30:29.347095+00
250	53	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 15:06:07.988866+00
251	53	NEWS	관련 뉴스 분석	오늘 표시 가능한 관련 뉴스가 없어 이번 계산의 뉴스 가중치에서 제외했습니다.	\N	2	2026-06-10 15:06:07.988866+00
252	53	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 0%를 적용해 원점수 50점, 위험 조정 +0점, 최종 50점입니다.	0	3	2026-06-10 15:06:07.988866+00
253	53	AI_NOTE	최종 해석	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-10 15:06:07.988866+00
198	4	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 14:27:55.731168+00
199	4	NEWS	관련 뉴스 분석	맥도날드 주가는 현재 가치 평가에 대한 혼합된 신호와 함께 긍정적인 전망이 공존하고 있습니다. Jim Cramer는 맥도날드에 대해 걱정할 필요가 없다고 언급했으며, 장기 투자 관점에서 매우 긍정적인 평가를 받고 있어 향후 주가 상승 가능성이 있습니다. Gemini 종합 감성 +52점을 정규화해 뉴스 점수 76점으로 계산했습니다.	76	2	2026-06-10 14:27:55.731168+00
200	4	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 76점, 위험 조정 +0점, 최종 76점입니다.	0	3	2026-06-10 14:27:55.731168+00
201	4	AI_NOTE	최종 해석	McDonald's Corporation은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	\N	4	2026-06-10 14:27:55.731168+00
202	5	PRICE	30일 가격 흐름	가격 이력 데이터가 없어 이번 계산의 가격 가중치에서 제외했습니다.	\N	1	2026-06-10 14:28:09.89794+00
203	5	NEWS	관련 뉴스 분석	애플 주가는 WWDC에서 AI 관련 기대치가 충족되지 못한 영향으로 하락했으며, 전반적인 시장 약세 및 투자 열기 식음 현상도 주가에 부정적인 영향을 미치고 있습니다. Gemini 종합 감성 -30점을 정규화해 뉴스 점수 35점으로 계산했습니다.	35	2	2026-06-10 14:28:09.89794+00
204	5	FORMULA	최종 점수 계산	사용 가능한 데이터만 가중 평균했습니다. 가격 0%, 뉴스 45%를 적용해 원점수 35점, 위험 조정 +0점, 최종 35점입니다.	0	3	2026-06-10 14:28:09.89794+00
205	5	AI_NOTE	최종 해석	Apple Inc은 현재 데이터 기준으로 리스크 관리가 우선이라, 매수보다 중단 또는 관망 쪽에 더 가까운 상태입니다.	\N	4	2026-06-10 14:28:09.89794+00
359	79	AI_NOTE	최종 해석	Nike Inc은 현재 점수 50점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	\N	6	2026-06-14 01:22:28.019195+00
360	80	PRICE	가격 흐름	가격 데이터가 충분하지 않아 가격 흐름 평가는 보수적으로 반영했어요.	\N	1	2026-06-14 01:23:52.900674+00
361	80	NEWS	관련 뉴스 분석	최근 관련 뉴스는 전반적으로 부정적이며 최신성과 영향도를 반영해 보수적으로 평가했습니다. 종합 뉴스 점수 35를 반영했어요.	35	2	2026-06-14 01:23:52.900674+00
362	80	EARNINGS	기업 체력	시총과 밸류에이션 기반의 1차 기초체력 점수 68를 함께 반영했어요.	68	3	2026-06-14 01:23:52.900674+00
363	80	INSTITUTION	내 투자 상황	현재 매일 모으기 금액과 보유 상황을 반영한 적합도 점수 64를 적용했어요.	64	4	2026-06-14 01:23:52.900674+00
364	80	FORMULA	최종 점수 계산	V4 멀티 팩터 모델로 계산했어요. 원점수 53점에 위험 조정 +0점을 반영해 최종 53점이 되었어요.	0	5	2026-06-14 01:23:52.900674+00
365	80	AI_NOTE	최종 해석	Apple Inc은 현재 점수 53점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	\N	6	2026-06-14 01:23:52.900674+00
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
70	1	5	2026-06-13	MAINTAIN	50	65	20.00	20.00	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-13 13:20:35.698777+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
62	1	4	2026-06-13	MAINTAIN	50	65	12.00	12.00	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-13 13:16:36.857148+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
51	1	6	2026-06-11	MAINTAIN	50	65	5.00	5.00	McDonald's Corporation은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-10 15:06:07.988866+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
5	1	4	2026-06-10	STOP	35	75	12.00	0.00	Apple Inc은 현재 데이터 기준으로 리스크 관리가 우선이라, 매수보다 중단 또는 관망 쪽에 더 가까운 상태입니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-09 22:59:49.585848+00	SCORE_V3_PRICE_NEWS	35	0	\N	35	0	45	\N	-30	f	\N	\N	\N	\N	\N	\N	\N	\N
1	1	4	2026-06-07	MAINTAIN	81	75	12.00	12.00	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE	2026-06-07 01:03:29.435271+00	SCORE_V3_PRICE_NEWS	81	0	\N	81	0	45	\N	62	f	\N	\N	\N	\N	\N	\N	\N	\N
2	1	5	2026-06-07	MAINTAIN	77	75	20.00	20.00	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE	2026-06-07 01:03:29.435271+00	SCORE_V3_PRICE_NEWS	77	0	\N	77	0	45	\N	54	f	\N	\N	\N	\N	\N	\N	\N	\N
52	1	4	2026-06-11	MAINTAIN	50	65	12.00	12.00	Apple Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-10 15:06:07.988866+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
53	1	5	2026-06-11	MAINTAIN	50	65	20.00	20.00	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-10 15:06:07.988866+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
4	1	6	2026-06-10	MAINTAIN	76	74	5.00	5.00	McDonald's Corporation은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-09 22:59:49.585848+00	SCORE_V3_PRICE_NEWS	76	0	\N	76	0	45	\N	52	f	\N	\N	\N	\N	\N	\N	\N	\N
50	1	7	2026-06-11	MAINTAIN	50	70	22.00	22.00	Nike Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-10 15:06:07.988866+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
3	1	7	2026-06-10	STOP	29	80	22.00	0.00	Nike Inc은 현재 데이터 기준으로 리스크 관리가 우선이라, 매수보다 중단 또는 관망 쪽에 더 가까운 상태입니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-09 22:59:49.585848+00	SCORE_V3_PRICE_NEWS	29	0	\N	29	0	45	\N	-42	f	\N	\N	\N	\N	\N	\N	\N	\N
6	1	5	2026-06-10	MAINTAIN	77	74	20.00	20.00	Alphabet Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-09 22:59:49.585848+00	SCORE_V3_PRICE_NEWS	77	0	\N	77	0	45	\N	54	f	\N	\N	\N	\N	\N	\N	\N	\N
61	1	6	2026-06-13	MAINTAIN	50	65	5.00	5.00	McDonald's Corporation은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-13 13:16:30.755681+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
55	1	7	2026-06-13	MAINTAIN	50	70	22.00	22.00	Nike Inc은 현재 기준에서 뚜렷한 경고 신호가 없어, 기존 모으기 금액을 유지하는 전략이 가장 자연스럽습니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-13 13:04:30.04446+00	SCORE_V3_PRICE_NEWS	50	0	\N	\N	0	0	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N
79	1	7	2026-06-14	REDUCE	50	80	22.00	15.40	Nike Inc은 현재 점수 50점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-14 01:22:28.019195+00	SCORE_V4_MULTI_FACTOR	50	0	\N	29	0	25	\N	-42	f	0	0	66	62	0	0	BALANCED	{"hasMemo": true, "hasRelatedNews": true, "finalConfidence": 80, "newsCacheReused": true, "hasInvestmentStartDate": true, "newsAnalysisConfidence": 95}
80	1	4	2026-06-14	REDUCE	53	75	12.00	8.40	Apple Inc은 현재 점수 53점으로 공격적으로 늘리기보다 금액을 줄여 관찰하는 보수적 전략이 적절합니다.	RULE_V3_EXPLAINABLE_SCORE_V2	2026-06-14 01:23:52.900674+00	SCORE_V4_MULTI_FACTOR	53	0	\N	35	0	25	\N	-30	f	0	0	68	64	0	0	BALANCED	{"hasMemo": false, "hasRelatedNews": true, "finalConfidence": 75, "newsCacheReused": true, "hasInvestmentStartDate": true, "newsAnalysisConfidence": 95}
\.


--
-- Data for Name: stock_price_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock_price_snapshots (id, stock_id, snapshot_date, current_price, change_rate_1d, change_rate_30d, market_cap, per_value, source, created_at, change_rate_7d) FROM stdin;
75	4132	2026-06-07	177.1600	\N	\N	33610830.00	8.7344	FINNHUB	2026-06-07 10:46:13.771145+00	\N
76	4133	2026-06-07	1559.3200	\N	\N	230919.34	51.2357	FINNHUB	2026-06-07 10:46:16.354402+00	\N
77	4134	2026-06-07	263.4700	\N	\N	230483.55	91.2192	FINNHUB	2026-06-07 10:46:18.987818+00	\N
1	4076	2026-06-07	205.1000	\N	\N	4963420.00	31.0966	FINNHUB	2026-06-07 06:46:38.373156+00	\N
2	4077	2026-06-07	307.3400	\N	\N	4514012.50	36.8265	FINNHUB	2026-06-07 06:46:39.388905+00	\N
3	4078	2026-06-07	368.5300	\N	\N	4465109.50	27.8707	FINNHUB	2026-06-07 06:46:40.397118+00	\N
4	4079	2026-06-07	416.6700	\N	\N	3095205.80	24.7189	FINNHUB	2026-06-07 06:46:41.486449+00	\N
5	4080	2026-06-07	246.0300	\N	\N	2646571.50	29.1479	FINNHUB	2026-06-07 06:46:42.528661+00	\N
6	4081	2026-06-07	415.1700	\N	\N	61848700.00	32.0659	FINNHUB	2026-06-07 06:46:43.551356+00	\N
7	4082	2026-06-07	385.7300	\N	\N	1826303.50	62.2950	FINNHUB	2026-06-07 06:46:44.589992+00	\N
8	4083	2026-06-07	593.0000	\N	\N	1505284.90	21.3252	FINNHUB	2026-06-07 06:46:45.485525+00	\N
9	4084	2026-06-07	391.0000	\N	\N	1468488.00	380.2403	FINNHUB	2026-06-07 06:46:46.541803+00	\N
10	4085	2026-06-07	488.1300	\N	\N	1054321.50	14.5482	FINNHUB	2026-06-07 06:46:47.618841+00	\N
11	4086	2026-06-07	1131.4200	\N	\N	1065505.10	42.1536	FINNHUB	2026-06-07 06:46:48.583581+00	\N
12	4087	2026-06-07	864.0100	\N	\N	974373.44	40.4120	FINNHUB	2026-06-07 06:46:49.577954+00	\N
13	4088	2026-06-07	118.8800	\N	\N	930219.94	40.9140	FINNHUB	2026-06-07 06:46:50.65794+00	\N
14	4089	2026-06-07	312.3700	\N	\N	836999.06	14.2108	FINNHUB	2026-06-07 06:46:51.599359+00	\N
15	4090	2026-06-07	466.3800	\N	\N	760479.50	151.8226	FINNHUB	2026-06-07 06:46:53.164789+00	\N
34	4091	2026-06-07	1641.7400	\N	\N	572213.25	56.0279	FINNHUB	2026-06-07 10:44:26.050447+00	\N
35	4092	2026-06-07	149.9200	\N	\N	632228.80	24.9755	FINNHUB	2026-06-07 10:44:28.700811+00	\N
36	4093	2026-06-07	213.6800	\N	\N	614553.50	37.9120	FINNHUB	2026-06-07 10:44:31.332624+00	\N
37	4094	2026-06-07	323.5700	\N	\N	588600.60	26.4706	FINNHUB	2026-06-07 10:44:33.954241+00	\N
38	4095	2026-06-07	232.7700	\N	\N	560327.90	26.6316	FINNHUB	2026-06-07 10:44:36.629006+00	\N
39	4096	2026-06-07	99.1700	\N	\N	498428.40	\N	FINNHUB	2026-06-07 10:44:39.26939+00	\N
40	4097	2026-06-07	121.6400	\N	\N	479436.12	40.0933	FINNHUB	2026-06-07 10:44:41.893551+00	\N
41	4098	2026-06-07	491.0800	\N	\N	433910.38	27.8684	FINNHUB	2026-06-07 10:44:44.472619+00	\N
42	4099	2026-06-07	971.8700	\N	\N	431003.75	48.7671	FINNHUB	2026-06-07 10:44:47.124867+00	\N
43	4100	2026-06-07	904.2800	\N	\N	416544.84	44.1723	FINNHUB	2026-06-07 10:44:49.833669+00	\N
44	4101	2026-06-07	227.2300	\N	\N	401468.34	110.4452	FINNHUB	2026-06-07 10:44:52.416494+00	\N
45	4102	2026-06-07	53.8300	\N	\N	382009.44	12.0519	FINNHUB	2026-06-07 10:44:55.009224+00	\N
46	4103	2026-06-07	303.2800	\N	\N	379273.20	56.5387	FINNHUB	2026-06-07 10:44:57.836684+00	\N
47	4104	2026-06-07	187.3100	\N	\N	373046.20	33.8856	FINNHUB	2026-06-07 10:45:00.551559+00	\N
48	4105	2026-06-07	342.9300	\N	\N	418620.16	463.0754	FINNHUB	2026-06-07 10:45:03.151285+00	\N
49	4106	2026-06-07	399.4700	\N	\N	360052.00	29.8947	FINNHUB	2026-06-07 10:45:05.792679+00	\N
50	4107	2026-06-07	453.0100	\N	\N	359671.56	42.2745	FINNHUB	2026-06-07 10:45:08.418138+00	\N
51	4108	2026-06-07	82.1800	\N	\N	346043.40	25.8750	FINNHUB	2026-06-07 10:45:10.991362+00	\N
52	4109	2026-06-07	328.0000	\N	\N	342214.62	39.6541	FINNHUB	2026-06-07 10:45:13.628826+00	\N
53	4110	2026-06-07	79.4800	\N	\N	341961.30	24.9589	FINNHUB	2026-06-07 10:45:16.292792+00	\N
54	4111	2026-06-07	146.5400	\N	\N	341232.90	20.5364	FINNHUB	2026-06-07 10:45:18.891139+00	\N
55	4112	2026-06-07	211.9300	\N	\N	334274.00	18.4549	FINNHUB	2026-06-07 10:45:21.525822+00	\N
56	4113	2026-06-07	135.5300	\N	\N	324907.72	142.4079	FINNHUB	2026-06-07 10:45:24.093369+00	\N
57	4114	2026-06-07	1038.6800	\N	\N	306418.30	16.9592	FINNHUB	2026-06-07 10:45:26.671318+00	\N
58	4115	2026-06-07	90.8000	\N	\N	234899.33	14.0485	FINNHUB	2026-06-07 10:45:29.253187+00	\N
59	4116	2026-06-07	310.7800	\N	\N	309883.94	22.1156	FINNHUB	2026-06-07 10:45:31.898176+00	\N
60	4117	2026-06-07	120.7900	\N	\N	298330.10	33.3889	FINNHUB	2026-06-07 10:45:34.569875+00	\N
61	4118	2026-06-07	185.9500	\N	\N	210203.86	26.9921	FINNHUB	2026-06-07 10:45:37.193264+00	\N
62	4119	2026-06-07	178.2900	\N	\N	277875.47	25.0429	FINNHUB	2026-06-07 10:45:39.777015+00	\N
63	4120	2026-06-07	121.0600	\N	\N	302455.94	19.3870	FINNHUB	2026-06-07 10:45:42.347608+00	\N
64	4121	2026-06-07	149.1600	\N	\N	211478.11	19.6229	FINNHUB	2026-06-07 10:45:44.966006+00	\N
65	4122	2026-06-07	194.0400	\N	\N	378397.47	17.0927	FINNHUB	2026-06-07 10:45:47.594495+00	\N
66	4123	2026-06-07	284.8400	\N	\N	267716.90	24.8993	FINNHUB	2026-06-07 10:45:50.238521+00	\N
67	4124	2026-06-07	285.0600	\N	\N	259431.06	48.3382	FINNHUB	2026-06-07 10:45:52.858546+00	\N
68	4125	2026-06-07	394.3900	\N	\N	257309.69	30.5993	FINNHUB	2026-06-07 10:45:55.429768+00	\N
69	4126	2026-06-07	1929.2000	\N	\N	252006.62	53.9564	FINNHUB	2026-06-07 10:45:58.0433+00	\N
70	4127	2026-06-07	933.6100	\N	\N	250879.69	26.7634	FINNHUB	2026-06-07 10:46:00.597102+00	\N
71	4128	2026-06-07	81.9400	\N	\N	240775.70	11.0972	FINNHUB	2026-06-07 10:46:03.209073+00	\N
72	4129	2026-06-07	180.9900	\N	\N	243736.22	33.5910	FINNHUB	2026-06-07 10:46:05.841406+00	\N
73	4130	2026-06-07	85.4000	\N	\N	179551.80	12.7756	FINNHUB	2026-06-07 10:46:08.538796+00	\N
74	4131	2026-06-07	507.9000	\N	\N	234954.30	33.1763	FINNHUB	2026-06-07 10:46:11.179643+00	\N
78	4135	2026-06-07	215.9400	\N	\N	227600.77	22.9367	FINNHUB	2026-06-07 10:46:21.622014+00	\N
79	4136	2026-06-07	19.9100	\N	\N	35435760.00	14.5993	FINNHUB	2026-06-07 10:46:24.259229+00	\N
80	4137	2026-06-07	132.4700	\N	\N	227173.78	14.1753	FINNHUB	2026-06-07 10:46:26.845587+00	\N
81	4138	2026-06-07	272.0500	\N	\N	221720.75	263.0764	FINNHUB	2026-06-07 10:46:29.419649+00	\N
82	4139	2026-06-07	82.7200	\N	\N	319067.30	21.9411	FINNHUB	2026-06-07 10:46:32.010403+00	\N
83	4140	2026-06-07	184.7700	\N	\N	192063.45	26.2633	FINNHUB	2026-06-07 10:46:34.820107+00	\N
84	4141	2026-06-07	310.6600	\N	\N	211971.53	18.8923	FINNHUB	2026-06-07 10:46:37.452829+00	\N
85	4142	2026-06-07	279.8400	\N	\N	198827.95	22.9144	FINNHUB	2026-06-07 10:46:40.085397+00	\N
86	4143	2026-06-07	88.7100	\N	\N	172297.33	13.1609	FINNHUB	2026-06-07 10:46:42.690303+00	\N
87	4144	2026-06-07	42.9600	\N	\N	1261429.40	10.3432	FINNHUB	2026-06-07 10:46:45.322815+00	\N
88	4145	2026-06-07	401.3900	\N	\N	195511.88	59.0059	FINNHUB	2026-06-07 10:46:47.908555+00	\N
89	4146	2026-06-07	154.2700	\N	\N	194257.19	52.2127	FINNHUB	2026-06-07 10:46:50.538244+00	\N
90	4147	2026-06-07	141.9200	\N	\N	193971.77	22.2114	FINNHUB	2026-06-07 10:46:53.178563+00	\N
91	4148	2026-06-07	178.1000	\N	\N	192740.66	18.2814	FINNHUB	2026-06-07 10:46:55.80764+00	\N
92	4149	2026-06-07	847.4700	\N	\N	190027.34	79.9106	FINNHUB	2026-06-07 10:46:58.400281+00	\N
93	4150	2026-06-07	45.3700	\N	\N	194789.81	11.2336	FINNHUB	2026-06-07 10:47:00.985168+00	\N
94	4151	2026-06-07	349.5800	\N	\N	188671.22	24.1886	FINNHUB	2026-06-07 10:47:03.579198+00	\N
95	4152	2026-06-07	557.2000	\N	\N	187185.77	47.2340	FINNHUB	2026-06-07 10:47:06.229101+00	\N
96	4153	2026-06-07	113.1600	\N	\N	266991.03	17.9068	FINNHUB	2026-06-07 10:47:08.923544+00	\N
97	4154	2026-06-07	85.8400	\N	\N	179005.72	21.8753	FINNHUB	2026-06-07 10:47:11.552795+00	\N
98	4155	2026-06-07	160.7100	\N	\N	177537.06	30.6627	FINNHUB	2026-06-07 10:47:14.833342+00	\N
99	4156	2026-06-07	12.1500	\N	\N	157420.42	9.7450	FINNHUB	2026-06-07 10:47:17.416228+00	\N
100	4157	2026-06-07	511.7200	\N	\N	204779.11	31.4513	FINNHUB	2026-06-07 10:47:20.052226+00	\N
101	4158	2026-06-07	100.6900	\N	\N	135580.52	18.1488	FINNHUB	2026-06-07 10:47:22.723858+00	\N
102	4159	2026-06-07	472.8000	\N	\N	175702.62	25.6650	FINNHUB	2026-06-07 10:47:25.38689+00	\N
103	4160	2026-06-07	99.7100	\N	\N	173147.55	15.4265	FINNHUB	2026-06-07 10:47:28.062341+00	\N
104	4161	2026-06-07	671.0200	\N	\N	170799.10	\N	FINNHUB	2026-06-07 10:47:30.660026+00	\N
105	4162	2026-06-07	138.8100	\N	\N	170768.86	38.2418	FINNHUB	2026-06-07 10:47:33.285714+00	\N
106	4163	2026-06-07	215.4500	\N	\N	169839.73	74.8852	FINNHUB	2026-06-07 10:47:35.916223+00	\N
107	4164	2026-06-07	995.6000	\N	\N	162124.40	25.9192	FINNHUB	2026-06-07 10:47:38.541964+00	\N
108	4165	2026-06-07	272.3200	\N	\N	156680.90	21.7220	FINNHUB	2026-06-07 10:47:41.174404+00	\N
109	4166	2026-06-07	129.1600	\N	\N	160361.16	17.3984	FINNHUB	2026-06-07 10:47:43.814873+00	\N
110	4167	2026-06-07	91.0700	\N	\N	158626.84	25.2751	FINNHUB	2026-06-07 10:47:46.475673+00	\N
111	4168	2026-06-07	22.7500	\N	\N	158074.72	7.3760	FINNHUB	2026-06-07 10:47:49.10056+00	\N
112	4169	2026-06-07	583.4400	\N	\N	157492.30	32.9275	FINNHUB	2026-06-07 10:47:51.727219+00	\N
113	4170	2026-06-07	88.8400	\N	\N	154504.80	16.3983	FINNHUB	2026-06-07 10:47:54.354951+00	\N
114	4171	2026-06-07	395.9400	\N	\N	153743.48	38.5225	FINNHUB	2026-06-07 10:47:57.689574+00	\N
115	4172	2026-06-07	177.5800	\N	\N	152832.06	84.4376	FINNHUB	2026-06-07 10:48:00.338228+00	\N
116	4173	2026-06-07	78.5000	\N	\N	134027.83	21.2940	FINNHUB	2026-06-07 10:48:02.945216+00	\N
117	4174	2026-06-07	185.6600	\N	\N	152055.55	18.9525	FINNHUB	2026-06-07 10:48:05.573682+00	\N
118	4175	2026-06-07	422.0600	\N	\N	149477.97	50.1755	FINNHUB	2026-06-07 10:48:08.186922+00	\N
119	4176	2026-06-07	26.0400	\N	\N	148413.52	19.8122	FINNHUB	2026-06-07 10:48:10.840348+00	\N
120	4177	2026-06-07	23.1600	\N	\N	23393220.00	14.7780	FINNHUB	2026-06-07 10:48:13.502277+00	\N
121	4178	2026-06-07	206.9300	\N	\N	140893.45	100.0977	FINNHUB	2026-06-07 10:48:16.119339+00	\N
122	4179	2026-06-07	172.9700	\N	\N	144313.31	29.0620	FINNHUB	2026-06-07 10:48:18.744805+00	\N
123	4180	2026-06-07	47.0100	\N	\N	113789.34	15.6755	FINNHUB	2026-06-07 10:48:21.355258+00	\N
124	4181	2026-06-07	70.7100	\N	\N	146624.19	17.1691	FINNHUB	2026-06-07 10:48:23.951717+00	\N
125	4182	2026-06-07	117.1400	\N	\N	142710.95	19.4907	FINNHUB	2026-06-07 10:48:26.60799+00	\N
126	4183	2026-06-07	109.5400	\N	\N	142145.08	106.7155	FINNHUB	2026-06-07 10:48:29.21128+00	\N
127	4184	2026-06-07	115.3500	\N	\N	140901.66	46.1354	FINNHUB	2026-06-07 10:48:31.813192+00	\N
128	4185	2026-06-07	144.5400	\N	\N	137606.56	37.0183	FINNHUB	2026-06-07 10:48:34.405523+00	\N
129	4186	2026-06-07	213.9700	\N	\N	135582.77	30.0560	FINNHUB	2026-06-07 10:48:37.122655+00	\N
130	4187	2026-06-07	21.8900	\N	\N	20976390.00	\N	FINNHUB	2026-06-07 10:48:39.756697+00	\N
131	4188	2026-06-07	184.3000	\N	\N	130442.13	35.3598	FINNHUB	2026-06-07 10:48:42.407227+00	\N
132	4189	2026-06-07	165.8400	\N	\N	128505.84	20.8817	FINNHUB	2026-06-07 10:48:44.978762+00	\N
133	4190	2026-06-07	59.7200	\N	\N	99118.05	12.7664	FINNHUB	2026-06-07 10:48:47.57327+00	\N
134	4191	2026-06-07	326.2700	\N	\N	126547.12	11.1999	FINNHUB	2026-06-07 10:48:50.259417+00	\N
135	4192	2026-06-07	424.4400	\N	\N	125634.24	26.2998	FINNHUB	2026-06-07 10:48:52.828589+00	\N
136	4193	2026-06-07	22.2200	\N	\N	110426.16	10.2218	FINNHUB	2026-06-07 10:48:55.404289+00	\N
137	4194	2026-06-07	56.3100	\N	\N	172140.80	24.9299	FINNHUB	2026-06-07 10:48:58.036914+00	\N
138	4195	2026-06-07	95.9300	\N	\N	122399.70	41.7461	FINNHUB	2026-06-07 10:49:00.628611+00	\N
139	4196	2026-06-07	56.7200	\N	\N	88227.22	10.7878	FINNHUB	2026-06-07 10:49:03.237585+00	\N
140	4197	2026-06-07	85.0700	\N	\N	122241.28	8.6757	FINNHUB	2026-06-07 10:49:05.803216+00	\N
141	4198	2026-06-07	523.7600	\N	\N	120759.99	25.1951	FINNHUB	2026-06-07 10:49:08.436772+00	\N
142	4199	2026-06-07	23.4100	\N	\N	11604413.00	15.2637	FINNHUB	2026-06-07 10:49:11.018499+00	\N
143	4200	2026-06-07	72.1900	\N	\N	120549.45	14.9695	FINNHUB	2026-06-07 10:49:13.666959+00	\N
144	4201	2026-06-07	204.0200	\N	\N	119216.32	10.3137	FINNHUB	2026-06-07 10:49:16.240367+00	\N
145	4202	2026-06-07	210.7400	\N	\N	118163.41	17.7903	FINNHUB	2026-06-07 10:49:18.852308+00	\N
146	4203	2026-06-07	9.5200	\N	\N	18642272.00	14.9301	FINNHUB	2026-06-07 10:49:21.444047+00	\N
147	4204	2026-06-07	305.6600	\N	\N	117178.05	35.1148	FINNHUB	2026-06-07 10:49:24.155461+00	\N
148	4205	2026-06-07	57.2700	\N	\N	116949.42	19.5675	FINNHUB	2026-06-07 10:49:26.884031+00	\N
149	4206	2026-06-07	112.4500	\N	\N	115970.59	66.0049	FINNHUB	2026-06-07 10:49:29.481821+00	\N
150	4207	2026-06-07	300.5100	\N	\N	127309.02	81.6921	FINNHUB	2026-06-07 10:49:32.072632+00	\N
151	4208	2026-06-07	164.3700	\N	\N	162156.66	16.6639	FINNHUB	2026-06-07 10:49:34.666843+00	\N
152	4209	2026-06-07	446.8300	\N	\N	108715.02	25.0594	FINNHUB	2026-06-07 10:49:37.313009+00	\N
153	4210	2026-06-07	42.9700	\N	\N	84158.03	34.9753	FINNHUB	2026-06-07 10:49:39.972727+00	\N
154	4211	2026-06-07	180.6700	\N	\N	112429.63	34.8835	FINNHUB	2026-06-07 10:49:42.547033+00	\N
155	4212	2026-06-07	882.3400	\N	\N	111251.06	31.9671	FINNHUB	2026-06-07 10:49:45.155183+00	\N
156	4213	2026-06-07	17.7500	\N	\N	561060.30	5.2151	FINNHUB	2026-06-07 10:49:47.824097+00	\N
157	4214	2026-06-07	15.8500	\N	\N	561060.30	5.2151	FINNHUB	2026-06-07 10:49:50.555041+00	\N
158	4215	2026-06-07	178.2500	\N	\N	109434.67	14.3084	FINNHUB	2026-06-07 10:49:53.187836+00	\N
159	4216	2026-06-07	95.2900	\N	\N	108602.01	72.6095	FINNHUB	2026-06-07 10:49:55.789738+00	\N
160	4217	2026-06-07	45.0200	\N	\N	92175.07	7.5374	FINNHUB	2026-06-07 10:49:58.382917+00	\N
161	4218	2026-06-07	1080.9500	\N	\N	106607.89	74.9704	FINNHUB	2026-06-07 10:50:01.009136+00	\N
162	4219	2026-06-07	99.7100	\N	\N	106445.69	12.5882	FINNHUB	2026-06-07 10:50:03.682206+00	\N
163	4220	2026-06-07	144.6800	\N	\N	105999.56	54.2336	FINNHUB	2026-06-07 10:50:06.31377+00	\N
164	4221	2026-06-07	81.6700	\N	\N	104854.89	21.8357	FINNHUB	2026-06-07 10:50:08.957773+00	\N
165	4222	2026-06-07	92.6000	\N	\N	104388.09	23.9258	FINNHUB	2026-06-07 10:50:11.583405+00	\N
166	4223	2026-06-07	50.4800	\N	\N	104388.09	23.9258	FINNHUB	2026-06-07 10:50:14.23152+00	\N
167	4224	2026-06-07	695.1100	\N	\N	104308.31	94.4184	FINNHUB	2026-06-07 10:50:16.88221+00	\N
168	4225	2026-06-07	376.1900	\N	\N	103759.23	88.6097	FINNHUB	2026-06-07 10:50:19.503008+00	\N
169	4226	2026-06-07	392.5100	\N	\N	103500.42	40.0543	FINNHUB	2026-06-07 10:50:22.089387+00	\N
170	4227	2026-06-07	51.5200	\N	\N	76278.88	13.0861	FINNHUB	2026-06-07 10:50:24.683786+00	\N
171	4228	2026-06-07	496.9500	\N	\N	102288.48	32.7792	FINNHUB	2026-06-07 10:50:27.346008+00	\N
172	4229	2026-06-07	251.4400	\N	\N	101632.06	14.0999	FINNHUB	2026-06-07 10:50:30.00352+00	\N
173	4230	2026-06-07	456.8400	\N	\N	100986.98	34.8459	FINNHUB	2026-06-07 10:50:32.630488+00	\N
174	4231	2026-06-07	251.9000	\N	\N	100787.08	57.7908	FINNHUB	2026-06-07 10:50:35.325809+00	\N
175	4232	2026-06-07	108.8400	\N	\N	140464.89	14.3069	FINNHUB	2026-06-07 10:50:37.902839+00	\N
176	4233	2026-06-07	44.6000	\N	\N	99779.73	74.6854	FINNHUB	2026-06-07 10:50:40.550864+00	\N
177	4234	2026-06-07	80.5600	\N	\N	139411.92	14.6012	FINNHUB	2026-06-07 10:50:43.123669+00	\N
178	4235	2026-06-07	142.3900	\N	\N	97733.52	\N	FINNHUB	2026-06-07 10:50:45.675161+00	\N
179	4236	2026-06-07	124.2200	\N	\N	96841.44	18.8444	FINNHUB	2026-06-07 10:50:48.304844+00	\N
180	4237	2026-06-07	45.7000	\N	\N	138133.06	14.2259	FINNHUB	2026-06-07 10:50:50.88769+00	\N
181	4238	2026-06-07	25.9500	\N	\N	8908024.00	16.4331	FINNHUB	2026-06-07 10:50:53.4758+00	\N
182	4239	2026-06-07	346.4400	\N	\N	93687.83	21.5821	FINNHUB	2026-06-07 10:50:56.104794+00	\N
183	4240	2026-06-07	36.9400	\N	\N	892034.70	17.0633	FINNHUB	2026-06-07 10:50:58.750808+00	\N
184	4241	2026-06-07	257.4000	\N	\N	93271.31	21.8419	FINNHUB	2026-06-07 10:51:01.33466+00	\N
185	4242	2026-06-07	775.6600	\N	\N	93237.48	19.5795	FINNHUB	2026-06-07 10:51:03.956443+00	\N
186	4243	2026-06-07	231.9500	\N	\N	92718.37	21.3366	FINNHUB	2026-06-07 10:51:06.572221+00	\N
187	4244	2026-06-07	108.5400	\N	\N	92370.19	17.5977	FINNHUB	2026-06-07 10:51:09.187446+00	\N
188	4245	2026-06-07	228.3700	\N	\N	91705.32	12.7104	FINNHUB	2026-06-07 10:51:11.782149+00	\N
189	4246	2026-06-07	63.3700	\N	\N	91098.17	33.3327	FINNHUB	2026-06-07 10:51:14.401884+00	\N
190	4247	2026-06-07	254.8300	\N	\N	92042.06	24.2791	FINNHUB	2026-06-07 10:51:16.974538+00	\N
191	4248	2026-06-07	194.1200	\N	\N	90439.16	31.1827	FINNHUB	2026-06-07 10:51:19.562402+00	\N
192	4249	2026-06-07	415.5300	\N	\N	90237.48	17.2110	FINNHUB	2026-06-07 10:51:22.224368+00	\N
193	4250	2026-06-07	651.2200	\N	\N	89861.23	33.6181	FINNHUB	2026-06-07 10:51:24.854878+00	\N
194	4251	2026-06-07	464.8500	\N	\N	89009.16	115.1078	FINNHUB	2026-06-07 10:51:27.436633+00	\N
195	4252	2026-06-07	220.4000	\N	\N	87543.52	31.3327	FINNHUB	2026-06-07 10:51:30.036444+00	\N
196	4253	2026-06-07	250.1100	\N	\N	88405.45	\N	FINNHUB	2026-06-07 10:51:32.63438+00	\N
197	4254	2026-06-07	71.9600	\N	\N	87640.05	31.3897	FINNHUB	2026-06-07 10:51:35.256935+00	\N
198	4255	2026-06-07	143.6500	\N	\N	87643.10	24.8210	FINNHUB	2026-06-07 10:51:37.888649+00	\N
199	4256	2026-06-07	89.5500	\N	\N	87580.63	43.1023	FINNHUB	2026-06-07 10:51:40.497017+00	\N
200	4257	2026-06-07	46.9900	\N	\N	87313.95	28.6275	FINNHUB	2026-06-07 10:51:43.091772+00	\N
201	4258	2026-06-07	55.6900	\N	\N	82489.20	10.5674	FINNHUB	2026-06-07 10:51:45.732215+00	\N
202	4259	2026-06-07	29.6700	\N	\N	74653.13	7.7193	FINNHUB	2026-06-07 10:51:48.344223+00	\N
203	4260	2026-06-07	23.8200	\N	\N	85090.48	4.5268	FINNHUB	2026-06-07 10:51:50.979439+00	\N
204	4261	2026-06-07	7.5400	\N	\N	432650.44	12.4150	FINNHUB	2026-06-07 10:51:53.55812+00	\N
205	4262	2026-06-07	14.3800	\N	\N	77555.14	99.3024	FINNHUB	2026-06-07 10:51:56.195061+00	\N
206	4263	2026-06-07	93.4000	\N	\N	83861.33	28.3161	FINNHUB	2026-06-07 10:51:58.870617+00	\N
207	4264	2026-06-07	234.1100	\N	\N	83333.84	614.2257	FINNHUB	2026-06-07 10:52:01.444897+00	\N
208	4265	2026-06-07	24.2700	\N	\N	62817.62	5.6797	FINNHUB	2026-06-07 10:52:04.02644+00	\N
209	4266	2026-06-07	238.2600	\N	\N	82580.91	\N	FINNHUB	2026-06-07 10:52:06.603044+00	\N
210	4267	2026-06-07	372.1300	\N	\N	82553.24	12.1509	FINNHUB	2026-06-07 10:52:09.262306+00	\N
211	4268	2026-06-07	54.8700	\N	\N	82033.81	24.6422	FINNHUB	2026-06-07 10:52:11.89698+00	\N
212	4269	2026-06-07	163.6600	\N	\N	123113.16	16.5390	FINNHUB	2026-06-07 10:52:14.53938+00	\N
213	4270	2026-06-07	37.8100	\N	\N	81802.63	13.8578	FINNHUB	2026-06-07 10:52:17.164017+00	\N
214	4271	2026-06-07	1607.8000	\N	\N	81510.93	42.4536	FINNHUB	2026-06-07 10:52:19.816603+00	\N
215	4272	2026-06-07	296.7600	\N	\N	81174.84	17.7083	FINNHUB	2026-06-07 10:52:22.426026+00	\N
216	4273	2026-06-07	81.8600	\N	\N	59658.77	18.4075	FINNHUB	2026-06-07 10:52:25.007852+00	\N
217	4274	2026-06-07	34.0300	\N	\N	2602020.00	55.0657	FINNHUB	2026-06-07 10:52:27.58537+00	\N
218	4275	2026-06-07	153.7600	\N	\N	80196.19	28.7751	FINNHUB	2026-06-07 10:52:30.197843+00	\N
219	4276	2026-06-07	141.5000	\N	\N	80020.02	20.3561	FINNHUB	2026-06-07 10:52:32.851337+00	\N
220	4277	2026-06-07	210.3100	\N	\N	68199.73	14.5307	FINNHUB	2026-06-07 10:52:35.468635+00	\N
221	4278	2026-06-07	53.8000	\N	\N	68484.14	15.2798	FINNHUB	2026-06-07 10:52:38.071171+00	\N
222	4279	2026-06-07	89.9300	\N	\N	110407.77	27.0806	FINNHUB	2026-06-07 10:52:40.696931+00	\N
223	4280	2026-06-07	165.4400	\N	\N	79708.08	20.3078	FINNHUB	2026-06-07 10:52:43.290723+00	\N
224	4281	2026-06-07	62.0400	\N	\N	79637.63	30.4542	FINNHUB	2026-06-07 10:52:45.850037+00	\N
225	4282	2026-06-07	133.5400	\N	\N	80485.21	31.9766	FINNHUB	2026-06-07 10:52:48.429716+00	\N
226	4283	2026-06-07	331.0000	\N	\N	78978.84	17.6135	FINNHUB	2026-06-07 10:52:51.040045+00	\N
227	4284	2026-06-07	451.3500	\N	\N	78850.84	31.6035	FINNHUB	2026-06-07 10:52:53.669505+00	\N
228	4285	2026-06-07	343.1000	\N	\N	78106.16	50.6525	FINNHUB	2026-06-07 10:52:56.259001+00	\N
229	4286	2026-06-07	138.1200	\N	\N	77361.01	31.6534	FINNHUB	2026-06-07 10:52:58.86457+00	\N
230	4287	2026-06-07	544.4000	\N	\N	77323.02	16.8975	FINNHUB	2026-06-07 10:53:01.510343+00	\N
231	4288	2026-06-07	5.3100	\N	\N	58554.57	9.3077	FINNHUB	2026-06-07 10:53:04.073531+00	\N
232	4289	2026-06-07	119.4800	\N	\N	76842.88	15.2825	FINNHUB	2026-06-07 10:53:06.677636+00	\N
233	4290	2026-06-07	289.4800	\N	\N	76576.84	12.1783	FINNHUB	2026-06-07 10:53:09.288075+00	\N
234	4291	2026-06-07	262.0100	\N	\N	76490.31	16.5135	FINNHUB	2026-06-07 10:53:11.87474+00	\N
235	4292	2026-06-07	255.8200	\N	\N	77633.09	18.4577	FINNHUB	2026-06-07 10:53:14.493648+00	\N
236	4293	2026-06-07	280.0000	\N	\N	75094.59	16.7659	FINNHUB	2026-06-07 10:53:17.117712+00	\N
237	4294	2026-06-07	263.6100	\N	\N	74982.25	12428.6839	FINNHUB	2026-06-07 10:53:19.736099+00	\N
238	4295	2026-06-07	305.3000	\N	\N	75297.85	28.9685	FINNHUB	2026-06-07 10:53:22.38622+00	\N
239	4296	2026-06-07	90.3300	\N	\N	74857.84	28.7483	FINNHUB	2026-06-07 10:53:25.022214+00	\N
240	4297	2026-06-07	295.9600	\N	\N	74721.34	28.1648	FINNHUB	2026-06-07 10:53:27.612855+00	\N
241	4298	2026-06-07	24.8400	\N	\N	1321162.90	15.0960	FINNHUB	2026-06-07 10:53:30.213837+00	\N
242	4299	2026-06-07	82.4700	\N	\N	74330.65	39.1833	FINNHUB	2026-06-07 10:53:32.805071+00	\N
243	4300	2026-06-07	82.1100	\N	\N	74035.73	29.1709	FINNHUB	2026-06-07 10:53:35.39431+00	\N
244	4301	2026-06-07	230.3700	\N	\N	73898.34	31.9111	FINNHUB	2026-06-07 10:53:38.053532+00	\N
245	4302	2026-06-07	46.1800	\N	\N	73739.60	29.2501	FINNHUB	2026-06-07 10:53:40.623936+00	\N
246	4303	2026-06-07	128.0300	\N	\N	73811.54	64.5206	FINNHUB	2026-06-07 10:53:43.20936+00	\N
247	4304	2026-06-07	376.9900	\N	\N	73754.07	157.3088	FINNHUB	2026-06-07 10:53:45.825007+00	\N
248	4305	2026-06-07	62.2200	\N	\N	108020.77	17.0676	FINNHUB	2026-06-07 10:53:48.450323+00	\N
249	4306	2026-06-07	66.5100	\N	\N	72950.55	50.6249	FINNHUB	2026-06-07 10:53:51.024782+00	\N
250	4307	2026-06-07	183.0800	\N	\N	73403.19	17.8033	FINNHUB	2026-06-07 10:53:53.606754+00	\N
251	4308	2026-06-07	137.7800	\N	\N	73385.56	13.3501	FINNHUB	2026-06-07 10:53:56.230328+00	\N
252	4309	2026-06-07	120.3800	\N	\N	100816.91	21.4276	FINNHUB	2026-06-07 10:53:58.84441+00	\N
253	4310	2026-06-07	1481.0500	\N	\N	72763.98	106.8616	FINNHUB	2026-06-07 10:54:01.428509+00	\N
254	4311	2026-06-07	252.7200	\N	\N	72707.55	23.1996	FINNHUB	2026-06-07 10:54:04.071778+00	\N
255	4312	2026-06-07	257.9700	\N	\N	72602.43	34.4790	FINNHUB	2026-06-07 10:54:06.716742+00	\N
256	4313	2026-06-07	48.5500	\N	\N	72162.54	20.2419	FINNHUB	2026-06-07 10:54:09.370891+00	\N
257	4314	2026-06-07	179.8500	\N	\N	71955.67	37.1435	FINNHUB	2026-06-07 10:54:11.998061+00	\N
258	4315	2026-06-07	68.6800	\N	\N	95750.00	27.8343	FINNHUB	2026-06-07 10:54:14.68438+00	\N
259	4316	2026-06-07	88.5800	\N	\N	70880.77	33.9630	FINNHUB	2026-06-07 10:54:17.311584+00	\N
260	4317	2026-06-07	31.6800	\N	\N	70482.48	21.2617	FINNHUB	2026-06-07 10:54:19.95248+00	\N
261	4318	2026-06-07	313.4500	\N	\N	70398.98	26.3667	FINNHUB	2026-06-07 10:54:22.527082+00	\N
262	4319	2026-06-07	129.1400	\N	\N	70265.73	19.2309	FINNHUB	2026-06-07 10:54:25.118493+00	\N
263	4320	2026-06-07	105.0600	\N	\N	70201.11	19.1232	FINNHUB	2026-06-07 10:54:27.700031+00	\N
264	4321	2026-06-07	328.5300	\N	\N	70166.43	17.7997	FINNHUB	2026-06-07 10:54:30.34399+00	\N
265	4322	2026-06-07	1238.7400	\N	\N	69287.16	33.2791	FINNHUB	2026-06-07 10:54:32.918323+00	\N
266	4323	2026-06-07	488.2100	\N	\N	69032.13	301.3858	FINNHUB	2026-06-07 10:54:35.556522+00	\N
267	4324	2026-06-07	156.8000	\N	\N	68320.70	73.7805	FINNHUB	2026-06-07 10:54:38.118658+00	\N
268	4325	2026-06-07	410.3400	\N	\N	68114.63	32.5907	FINNHUB	2026-06-07 10:54:40.766726+00	\N
269	4326	2026-06-07	863.6600	\N	\N	67192.75	152.7455	FINNHUB	2026-06-07 10:54:43.345128+00	\N
270	4327	2026-06-07	1067.7700	\N	\N	66191.10	26.4025	FINNHUB	2026-06-07 10:54:46.022315+00	\N
271	4328	2026-06-07	186.7900	\N	\N	65639.14	47.6375	FINNHUB	2026-06-07 10:54:48.614898+00	\N
272	4329	2026-06-07	19.3900	\N	\N	66724.08	15.2897	FINNHUB	2026-06-07 10:54:51.199671+00	\N
273	4330	2026-06-07	39.4600	\N	\N	99600.17	11.6778	FINNHUB	2026-06-07 10:54:53.846227+00	\N
274	4331	2026-06-07	26.2400	\N	\N	67692.70	\N	FINNHUB	2026-06-07 10:54:56.431359+00	\N
275	4332	2026-06-07	15.2300	\N	\N	367651.22	23.5629	FINNHUB	2026-06-07 10:54:59.001251+00	\N
276	4333	2026-06-07	49.2000	\N	\N	65150.81	41.8707	FINNHUB	2026-06-07 10:55:01.567753+00	\N
277	4334	2026-06-07	1843.9400	\N	\N	64911.16	53.0473	FINNHUB	2026-06-07 10:55:04.19854+00	\N
278	4335	2026-06-07	38.7100	\N	\N	89705.75	13.9772	FINNHUB	2026-06-07 10:55:06.819578+00	\N
279	4336	2026-06-07	635.4500	\N	\N	66619.96	15.0608	FINNHUB	2026-06-07 10:55:09.419711+00	\N
280	4337	2026-06-07	210.0400	\N	\N	64621.77	29.7933	FINNHUB	2026-06-07 10:55:12.003288+00	\N
281	4338	2026-06-07	303.2500	\N	\N	64484.50	8.4803	FINNHUB	2026-06-07 10:55:14.624341+00	\N
282	4339	2026-06-07	70.7200	\N	\N	59545.07	229.4854	FINNHUB	2026-06-07 10:55:17.251516+00	\N
283	4340	2026-06-07	110.0800	\N	\N	63721.73	\N	FINNHUB	2026-06-07 10:55:19.816187+00	\N
284	4341	2026-06-07	42.9800	\N	\N	63648.53	28.2882	FINNHUB	2026-06-07 10:55:22.438358+00	\N
285	4342	2026-06-07	15.7900	\N	\N	47890.68	7.9898	FINNHUB	2026-06-07 10:55:25.031985+00	\N
286	4343	2026-06-07	282.3500	\N	\N	62873.90	29.8362	FINNHUB	2026-06-07 10:55:27.65849+00	\N
287	4344	2026-06-07	62.5900	\N	\N	62093.58	19.9273	FINNHUB	2026-06-07 10:55:30.336394+00	\N
288	4345	2026-06-07	212.6500	\N	\N	62071.65	21.3598	FINNHUB	2026-06-07 10:55:32.948312+00	\N
289	4346	2026-06-07	35.1500	\N	\N	45543.99	22.0552	FINNHUB	2026-06-07 10:55:35.558668+00	\N
290	4347	2026-06-07	116.6800	\N	\N	61407.08	24.8009	FINNHUB	2026-06-07 10:55:38.181529+00	\N
291	4348	2026-06-07	1300.0100	\N	\N	61377.52	34.4431	FINNHUB	2026-06-07 10:55:40.801879+00	\N
292	4349	2026-06-07	49.2000	\N	\N	61297.26	11.0905	FINNHUB	2026-06-07 10:55:43.372282+00	\N
293	4350	2026-06-07	346.9900	\N	\N	58253.57	36.4509	FINNHUB	2026-06-07 10:55:45.981392+00	\N
294	4351	2026-06-07	118.2400	\N	\N	60182.38	12.9815	FINNHUB	2026-06-07 10:55:48.604759+00	\N
295	4352	2026-06-07	91.4200	\N	\N	59760.34	30.5367	FINNHUB	2026-06-07 10:55:51.187602+00	\N
296	4353	2026-06-07	31.5100	\N	\N	51955.40	7.3373	FINNHUB	2026-06-07 10:55:53.754818+00	\N
297	4354	2026-06-07	14.9000	\N	\N	59371.92	\N	FINNHUB	2026-06-07 10:55:56.393963+00	\N
298	4355	2026-06-07	121.7200	\N	\N	85223.54	29.1861	FINNHUB	2026-06-07 10:55:59.055682+00	\N
299	4356	2026-06-07	66.9000	\N	\N	58839.39	19.9185	FINNHUB	2026-06-07 10:56:01.678858+00	\N
300	4357	2026-06-07	227.8100	\N	\N	57328.49	70.1523	FINNHUB	2026-06-07 10:56:04.2405+00	\N
301	4358	2026-06-07	11.9700	\N	\N	58181.37	18.2745	FINNHUB	2026-06-07 10:56:06.810025+00	\N
302	4359	2026-06-07	254.3900	\N	\N	57935.02	24.8541	FINNHUB	2026-06-07 10:56:09.459296+00	\N
303	4360	2026-06-07	307.8300	\N	\N	57347.18	33.1104	FINNHUB	2026-06-07 10:56:12.084603+00	\N
304	4361	2026-06-07	56.4800	\N	\N	57312.16	12.1993	FINNHUB	2026-06-07 10:56:14.659662+00	\N
305	4362	2026-06-07	60.8400	\N	\N	56732.84	50.6299	FINNHUB	2026-06-07 10:56:17.252758+00	\N
306	4363	2026-06-07	221.0100	\N	\N	56892.60	4.6848	FINNHUB	2026-06-07 10:56:19.923253+00	\N
307	4364	2026-06-07	264.0900	\N	\N	56685.31	26.5866	FINNHUB	2026-06-07 10:56:22.529283+00	\N
308	4365	2026-06-07	56.9300	\N	\N	56624.55	11.9587	FINNHUB	2026-06-07 10:56:25.100016+00	\N
309	4366	2026-06-07	329.8300	\N	\N	56566.67	53.6686	FINNHUB	2026-06-07 10:56:27.681878+00	\N
310	4367	2026-06-07	357.9300	\N	\N	56031.13	65.6058	FINNHUB	2026-06-07 10:56:30.243068+00	\N
311	4368	2026-06-07	67.1600	\N	\N	55781.79	42.5815	FINNHUB	2026-06-07 10:56:32.85546+00	\N
312	4369	2026-06-07	122.5700	\N	\N	55670.21	16.1363	FINNHUB	2026-06-07 10:56:35.467166+00	\N
313	4370	2026-06-07	151.9200	\N	\N	55660.13	63.2502	FINNHUB	2026-06-07 10:56:38.062579+00	\N
314	4371	2026-06-07	88.2500	\N	\N	55600.40	15.7464	FINNHUB	2026-06-07 10:56:40.665746+00	\N
315	4372	2026-06-07	216.1400	\N	\N	55526.36	34.4542	FINNHUB	2026-06-07 10:56:43.295449+00	\N
316	4373	2026-06-07	891.3200	\N	\N	45100.63	23.1225	FINNHUB	2026-06-07 10:56:45.976689+00	\N
317	4374	2026-06-07	100.3900	\N	\N	54769.81	\N	FINNHUB	2026-06-07 10:56:48.524678+00	\N
318	4375	2026-06-07	309.6800	\N	\N	54363.01	28.5696	FINNHUB	2026-06-07 10:56:51.149391+00	\N
319	4376	2026-06-07	84.4900	\N	\N	54363.97	15.0218	FINNHUB	2026-06-07 10:56:53.737266+00	\N
320	4377	2026-06-07	317.0600	\N	\N	54346.60	203.0700	FINNHUB	2026-06-07 10:56:56.296927+00	\N
321	4378	2026-06-07	192.6200	\N	\N	54186.57	190.7978	FINNHUB	2026-06-07 10:56:58.917524+00	\N
322	4379	2026-06-07	46.7900	\N	\N	53716.56	41.3331	FINNHUB	2026-06-07 10:57:01.5434+00	\N
323	4380	2026-06-07	275.0400	\N	\N	53512.08	20.9960	FINNHUB	2026-06-07 10:57:04.158255+00	\N
324	4381	2026-06-07	86.5600	\N	\N	56403.70	35.1855	FINNHUB	2026-06-07 10:57:06.730743+00	\N
325	4382	2026-06-07	28.2200	\N	\N	77254.95	16.6462	FINNHUB	2026-06-07 10:57:09.354379+00	\N
326	4383	2026-06-07	116.2300	\N	\N	78981.44	31.4942	FINNHUB	2026-06-07 10:57:11.981004+00	\N
327	4384	2026-06-07	19.7000	\N	\N	1572123.10	31.3728	FINNHUB	2026-06-07 10:57:14.60564+00	\N
328	4385	2026-06-07	67.2100	\N	\N	46220.52	18.2278	FINNHUB	2026-06-07 10:57:17.252087+00	\N
329	4386	2026-06-07	226.5500	\N	\N	51925.94	33.9887	FINNHUB	2026-06-07 10:57:19.852851+00	\N
330	4387	2026-06-07	79.4200	\N	\N	52178.49	11.6548	FINNHUB	2026-06-07 10:57:22.484554+00	\N
331	4388	2026-06-07	77.0300	\N	\N	51519.20	44.3367	FINNHUB	2026-06-07 10:57:25.056075+00	\N
332	4389	2026-06-07	44.2800	\N	\N	51072.69	22.5188	FINNHUB	2026-06-07 10:57:27.684+00	\N
333	4390	2026-06-07	3116.4300	\N	\N	51348.86	20.7209	FINNHUB	2026-06-07 10:57:30.30289+00	\N
334	4391	2026-06-07	203.0000	\N	\N	50902.55	57.3873	FINNHUB	2026-06-07 10:57:32.966151+00	\N
335	4392	2026-06-07	12.4000	\N	\N	4957683.00	16.8400	FINNHUB	2026-06-07 10:57:35.568255+00	\N
336	4393	2026-06-07	110.7400	\N	\N	50706.39	28.1435	FINNHUB	2026-06-07 10:57:38.199568+00	\N
337	4394	2026-06-07	242.5700	\N	\N	50446.87	50.0812	FINNHUB	2026-06-07 10:57:40.77714+00	\N
338	4395	2026-06-07	148.7600	\N	\N	51858.66	23.1409	FINNHUB	2026-06-07 10:57:43.368306+00	\N
339	4396	2026-06-07	238.8200	\N	\N	50045.18	33.9289	FINNHUB	2026-06-07 10:57:46.001545+00	\N
340	4397	2026-06-07	446.7100	\N	\N	49707.19	45.6868	FINNHUB	2026-06-07 10:57:48.645871+00	\N
341	4398	2026-06-07	85.9600	\N	\N	49495.77	45.1521	FINNHUB	2026-06-07 10:57:51.235326+00	\N
342	4399	2026-06-07	87.2800	\N	\N	49360.40	25.8161	FINNHUB	2026-06-07 10:57:53.844723+00	\N
343	4400	2026-06-07	79.0400	\N	\N	48312.22	23.1048	FINNHUB	2026-06-07 10:57:56.426423+00	\N
344	4401	2026-06-07	3.1200	\N	\N	253253.00	16.2574	FINNHUB	2026-06-07 10:57:59.053335+00	\N
345	4402	2026-06-07	66.8100	\N	\N	40896.18	46.0543	FINNHUB	2026-06-07 10:58:01.667235+00	\N
346	4403	2026-06-07	15.6000	\N	\N	7688481.00	40.0939	FINNHUB	2026-06-07 10:58:04.329354+00	\N
347	4404	2026-06-07	229.9600	\N	\N	48521.56	33.1658	FINNHUB	2026-06-07 10:58:06.960166+00	\N
348	4405	2026-06-07	109.3500	\N	\N	48551.40	23.7997	FINNHUB	2026-06-07 10:58:09.52584+00	\N
349	4406	2026-06-07	205.7100	\N	\N	48178.49	30.9830	FINNHUB	2026-06-07 10:58:12.152566+00	\N
350	4407	2026-06-07	88.3400	\N	\N	47887.28	208.2056	FINNHUB	2026-06-07 10:58:14.778063+00	\N
351	4408	2026-06-07	52.0100	\N	\N	47137.27	21.6923	FINNHUB	2026-06-07 10:58:17.418144+00	\N
352	4409	2026-06-07	45.7500	\N	\N	46811.77	16.8448	FINNHUB	2026-06-07 10:58:20.081939+00	\N
353	4410	2026-06-07	331.4300	\N	\N	38998.54	49.3886	FINNHUB	2026-06-07 10:58:22.696801+00	\N
354	4411	2026-06-07	117.2600	\N	\N	45954.57	80.1021	FINNHUB	2026-06-07 10:58:25.302303+00	\N
355	4412	2026-06-07	236.5700	\N	\N	45623.99	26.2781	FINNHUB	2026-06-07 10:58:27.881407+00	\N
356	4413	2026-06-07	103.4400	\N	\N	45051.53	96.4929	FINNHUB	2026-06-07 10:58:30.499333+00	\N
357	4414	2026-06-07	615.4600	\N	\N	44805.49	33.9511	FINNHUB	2026-06-07 10:58:33.096103+00	\N
358	4415	2026-06-07	161.7500	\N	\N	44767.07	14.6059	FINNHUB	2026-06-07 10:58:35.705313+00	\N
359	4416	2026-06-07	229.5800	\N	\N	44524.25	18.0260	FINNHUB	2026-06-07 10:58:38.282957+00	\N
360	4417	2026-06-07	80.4300	\N	\N	32753.63	18.1006	FINNHUB	2026-06-07 10:58:40.841906+00	\N
361	4418	2026-06-07	562.1600	\N	\N	44344.87	40.4890	FINNHUB	2026-06-07 10:58:43.519961+00	\N
362	4419	2026-06-07	260.4000	\N	\N	44587.81	36.8494	FINNHUB	2026-06-07 10:58:46.140953+00	\N
363	4420	2026-06-07	33.6100	\N	\N	44153.06	45.7071	FINNHUB	2026-06-07 10:58:48.732022+00	\N
364	4421	2026-06-07	201.0100	\N	\N	44143.88	\N	FINNHUB	2026-06-07 10:58:51.290755+00	\N
365	4422	2026-06-07	371.7100	\N	\N	67950.26	50.8719	FINNHUB	2026-06-07 10:58:53.9026+00	\N
366	4423	2026-06-07	12.5600	\N	\N	414308.30	16.4624	FINNHUB	2026-06-07 10:58:56.549098+00	\N
367	4424	2026-06-07	84.1200	\N	\N	42481.23	12.2283	FINNHUB	2026-06-07 10:58:59.159164+00	\N
368	4425	2026-06-07	120.4400	\N	\N	42207.91	\N	FINNHUB	2026-06-07 10:59:01.77938+00	\N
369	4426	2026-06-07	218.7400	\N	\N	63288.10	33.1315	FINNHUB	2026-06-07 10:59:04.432866+00	\N
370	4427	2026-06-07	350.0800	\N	\N	42031.13	37.1957	FINNHUB	2026-06-07 10:59:07.056675+00	\N
371	4428	2026-06-07	37.8800	\N	\N	6515090.00	14.5665	FINNHUB	2026-06-07 10:59:09.670958+00	\N
372	4429	2026-06-07	151.1600	\N	\N	41650.69	36.5999	FINNHUB	2026-06-07 10:59:12.327334+00	\N
373	4430	2026-06-07	150.8700	\N	\N	40913.21	23.5404	FINNHUB	2026-06-07 10:59:14.997148+00	\N
374	4431	2026-06-07	21.3300	\N	\N	58287.73	15.1054	FINNHUB	2026-06-07 10:59:17.637712+00	\N
375	4432	2026-06-07	30.5300	\N	\N	41537.88	22.6735	FINNHUB	2026-06-07 10:59:20.256316+00	\N
376	4433	2026-06-07	94.7400	\N	\N	41990.44	18.7638	FINNHUB	2026-06-07 10:59:22.80178+00	\N
377	4434	2026-06-07	125.6500	\N	\N	27897.87	44.7956	FINNHUB	2026-06-07 10:59:25.362593+00	\N
378	4435	2026-06-07	75.5300	\N	\N	41421.89	53.1732	FINNHUB	2026-06-07 10:59:27.94668+00	\N
379	4436	2026-06-07	121.6600	\N	\N	45886.58	796.6544	FINNHUB	2026-06-07 10:59:30.548655+00	\N
380	4437	2026-06-07	145.6000	\N	\N	41289.20	13.0143	FINNHUB	2026-06-07 10:59:33.157083+00	\N
381	4438	2026-06-07	94.4900	\N	\N	41240.35	38.9427	FINNHUB	2026-06-07 10:59:35.783397+00	\N
382	4439	2026-06-07	68.1500	\N	\N	41543.63	51.4738	FINNHUB	2026-06-07 10:59:38.36728+00	\N
383	4440	2026-06-07	73.7200	\N	\N	56195.20	17.1327	FINNHUB	2026-06-07 10:59:41.037427+00	\N
384	4441	2026-06-07	454.6600	\N	\N	40872.61	10.4936	FINNHUB	2026-06-07 10:59:43.645964+00	\N
385	4442	2026-06-07	303.0500	\N	\N	40460.99	70.0967	FINNHUB	2026-06-07 10:59:46.280909+00	\N
386	4443	2026-06-07	82.0200	\N	\N	38426.86	147.5544	FINNHUB	2026-06-07 10:59:48.876205+00	\N
387	4444	2026-06-07	152.4000	\N	\N	40151.46	50.1516	FINNHUB	2026-06-07 10:59:51.449734+00	\N
388	4445	2026-06-07	89.9400	\N	\N	39547.36	32.9929	FINNHUB	2026-06-07 10:59:54.015523+00	\N
389	4446	2026-06-07	75.4900	\N	\N	40025.27	12.6622	FINNHUB	2026-06-07 10:59:56.62847+00	\N
390	4447	2026-06-07	9.1200	\N	\N	29173.98	17.5009	FINNHUB	2026-06-07 10:59:59.220451+00	\N
391	4448	2026-06-07	34.1900	\N	\N	114938.20	24.8448	FINNHUB	2026-06-07 11:00:02.146995+00	\N
392	4449	2026-06-07	214.3900	\N	\N	39805.07	\N	FINNHUB	2026-06-07 11:00:04.756146+00	\N
393	4450	2026-06-07	79.4800	\N	\N	39606.59	17.5018	FINNHUB	2026-06-07 11:00:07.34866+00	\N
394	4451	2026-06-07	155.2200	\N	\N	53260.44	36.2516	FINNHUB	2026-06-07 11:00:09.964109+00	\N
395	4452	2026-06-07	486.1200	\N	\N	39182.29	190.2163	FINNHUB	2026-06-07 11:00:12.58267+00	\N
396	4453	2026-06-07	106.2600	\N	\N	39159.97	18.1717	FINNHUB	2026-06-07 11:00:15.222685+00	\N
397	4454	2026-06-07	107.9100	\N	\N	58379720.00	9.6843	FINNHUB	2026-06-07 11:00:17.797081+00	\N
398	4455	2026-06-07	28.8800	\N	\N	279029.97	17.4657	FINNHUB	2026-06-07 11:00:20.38939+00	\N
399	4456	2026-06-07	80.9200	\N	\N	38999.93	36.0776	FINNHUB	2026-06-07 11:00:23.021555+00	\N
400	4457	2026-06-07	63.5700	\N	\N	39194.76	38.5775	FINNHUB	2026-06-07 11:00:25.658098+00	\N
401	4458	2026-06-07	203.4900	\N	\N	38892.29	170.0425	FINNHUB	2026-06-07 11:00:28.277487+00	\N
402	4459	2026-06-07	243.5000	\N	\N	38998.54	49.3886	FINNHUB	2026-06-07 11:00:30.912191+00	\N
403	4460	2026-06-07	268.5000	\N	\N	38721.13	28.2249	FINNHUB	2026-06-07 11:00:33.548563+00	\N
404	4461	2026-06-07	823.3600	\N	\N	111690.95	64.3019	FINNHUB	2026-06-07 11:00:36.151967+00	\N
405	4462	2026-06-07	130.9300	\N	\N	38338.48	29.2214	FINNHUB	2026-06-07 11:00:38.76829+00	\N
406	4463	2026-06-07	135.4400	\N	\N	38252.58	27.0527	FINNHUB	2026-06-07 11:00:41.368969+00	\N
407	4464	2026-06-07	206.8900	\N	\N	38160.85	80.8015	FINNHUB	2026-06-07 11:00:43.936138+00	\N
408	4465	2026-06-07	27.4100	\N	\N	37915.65	12.2427	FINNHUB	2026-06-07 11:00:46.498033+00	\N
409	4466	2026-06-07	122.8800	\N	\N	646375.44	22.7096	FINNHUB	2026-06-07 11:00:49.133741+00	\N
410	4467	2026-06-07	17.1100	\N	\N	37680.07	12.7556	FINNHUB	2026-06-07 11:00:51.711746+00	\N
411	4468	2026-06-07	86.0400	\N	\N	52100.91	24.4867	FINNHUB	2026-06-07 11:00:54.358707+00	\N
412	4469	2026-06-07	29.3400	\N	\N	37635.42	25.9200	FINNHUB	2026-06-07 11:00:56.933613+00	\N
413	4470	2026-06-07	84.4000	\N	\N	143160.97	137.9200	FINNHUB	2026-06-07 11:00:59.507852+00	\N
414	4471	2026-06-07	184.5800	\N	\N	37440.88	34.2188	FINNHUB	2026-06-07 11:01:02.133993+00	\N
415	4472	2026-06-07	353.2400	\N	\N	37267.75	46.0664	FINNHUB	2026-06-07 11:01:04.766309+00	\N
416	4473	2026-06-07	160.0700	\N	\N	37250.34	445.2320	FINNHUB	2026-06-07 11:01:07.339749+00	\N
417	4474	2026-06-07	124.6600	\N	\N	37089.43	136.2060	FINNHUB	2026-06-07 11:01:09.945852+00	\N
418	4475	2026-06-07	112.9500	\N	\N	35846.11	21.8721	FINNHUB	2026-06-07 11:01:12.520768+00	\N
419	4476	2026-06-07	281.3800	\N	\N	37019.07	33.2517	FINNHUB	2026-06-07 11:01:15.199397+00	\N
420	4477	2026-06-07	76.2900	\N	\N	36480.55	21.0141	FINNHUB	2026-06-07 11:01:17.835996+00	\N
421	4478	2026-06-07	41.2900	\N	\N	36422.14	7.1995	FINNHUB	2026-06-07 11:01:20.454473+00	\N
422	4479	2026-06-07	104.6200	\N	\N	36303.14	10.4741	FINNHUB	2026-06-07 11:01:23.038135+00	\N
423	4480	2026-06-07	93.6000	\N	\N	36328.46	\N	FINNHUB	2026-06-07 11:01:25.60293+00	\N
424	4481	2026-06-07	817.4400	\N	\N	36327.26	27.1581	FINNHUB	2026-06-07 11:01:28.223727+00	\N
425	4482	2026-06-07	132.1400	\N	\N	36223.65	8.9177	FINNHUB	2026-06-07 11:01:30.875735+00	\N
426	4483	2026-06-07	100.5300	\N	\N	36018.98	22.0071	FINNHUB	2026-06-07 11:01:33.582607+00	\N
427	4484	2026-06-07	365.3600	\N	\N	37288.04	83.0010	FINNHUB	2026-06-07 11:01:36.222327+00	\N
428	4485	2026-06-07	12.6500	\N	\N	35792.29	149.5189	FINNHUB	2026-06-07 11:01:38.821007+00	\N
429	4486	2026-06-07	144.2800	\N	\N	36284.30	42.8386	FINNHUB	2026-06-07 11:01:41.41427+00	\N
430	4487	2026-06-07	26.7000	\N	\N	5856344.00	\N	FINNHUB	2026-06-07 11:01:44.031632+00	\N
431	4488	2026-06-07	56.9800	\N	\N	26154.75	12.0324	FINNHUB	2026-06-07 11:01:46.651821+00	\N
432	4489	2026-06-07	44.5600	\N	\N	1097678.60	28.1290	FINNHUB	2026-06-07 11:01:49.291148+00	\N
433	4490	2026-06-07	575.8300	\N	\N	34576.23	13.6449	FINNHUB	2026-06-07 11:01:51.89704+00	\N
434	4491	2026-06-07	567.3300	\N	\N	35181.49	37.3435	FINNHUB	2026-06-07 11:01:54.603042+00	\N
435	4492	2026-06-07	105.7300	\N	\N	34060.38	9.2960	FINNHUB	2026-06-07 11:01:57.201089+00	\N
436	4493	2026-06-07	225.9900	\N	\N	34299.38	329.9413	FINNHUB	2026-06-07 11:01:59.76103+00	\N
437	4494	2026-06-07	17.7100	\N	\N	34003.35	20.9638	FINNHUB	2026-06-07 11:02:02.431591+00	\N
438	4495	2026-06-07	14.7000	\N	\N	25732.18	\N	FINNHUB	2026-06-07 11:02:05.045931+00	\N
439	4496	2026-06-07	116.2800	\N	\N	33699.51	\N	FINNHUB	2026-06-07 11:02:07.633669+00	\N
440	4497	2026-06-07	53.7500	\N	\N	33619.45	10.2363	FINNHUB	2026-06-07 11:02:10.254844+00	\N
441	4498	2026-06-07	332.1800	\N	\N	33522.73	19.5570	FINNHUB	2026-06-07 11:02:12.886193+00	\N
442	4499	2026-06-07	3.3600	\N	\N	171522.84	7.2138	FINNHUB	2026-06-07 11:02:15.459709+00	\N
443	4500	2026-06-07	16.5200	\N	\N	33488.20	15.1736	FINNHUB	2026-06-07 11:02:18.076436+00	\N
444	4501	2026-06-07	173.4500	\N	\N	33390.69	47.1924	FINNHUB	2026-06-07 11:02:20.691485+00	\N
445	4502	2026-06-07	79.4400	\N	\N	32527.91	12.3072	FINNHUB	2026-06-07 11:02:23.322468+00	\N
446	4503	2026-06-07	50.2500	\N	\N	33297.53	18.0768	FINNHUB	2026-06-07 11:02:25.93856+00	\N
447	4504	2026-06-07	72.6600	\N	\N	33157.70	34.7201	FINNHUB	2026-06-07 11:02:28.520691+00	\N
448	4505	2026-06-07	36.6200	\N	\N	556910.94	9.4337	FINNHUB	2026-06-07 11:02:31.138994+00	\N
449	4506	2026-06-07	99.0400	\N	\N	32875.37	15.5146	FINNHUB	2026-06-07 11:02:33.72876+00	\N
450	4507	2026-06-07	67.1700	\N	\N	46357348.00	9.0793	FINNHUB	2026-06-07 11:02:36.345976+00	\N
451	4508	2026-06-07	39.1800	\N	\N	32730.89	21.2538	FINNHUB	2026-06-07 11:02:38.958034+00	\N
452	4509	2026-06-07	167.0400	\N	\N	32962.07	25.8323	FINNHUB	2026-06-07 11:02:41.542108+00	\N
453	4510	2026-06-07	66.8100	\N	\N	26024.38	39.9043	FINNHUB	2026-06-07 11:02:44.113971+00	\N
454	4511	2026-06-07	222.4400	\N	\N	32575.24	11.1140	FINNHUB	2026-06-07 11:02:46.701522+00	\N
455	4512	2026-06-07	79.3600	\N	\N	32799.47	\N	FINNHUB	2026-06-07 11:02:49.283608+00	\N
456	4513	2026-06-07	67.2000	\N	\N	46136.64	13.8713	FINNHUB	2026-06-07 11:02:51.937491+00	\N
457	4514	2026-06-07	55.8700	\N	\N	32174.54	38.8916	FINNHUB	2026-06-07 11:02:54.493173+00	\N
458	4515	2026-06-07	145.3100	\N	\N	30698.33	32.5159	FINNHUB	2026-06-07 11:02:57.073605+00	\N
459	4516	2026-06-07	25.4900	\N	\N	24393.76	8.1806	FINNHUB	2026-06-07 11:02:59.666619+00	\N
460	4517	2026-06-07	12.8000	\N	\N	31104.16	11.1365	FINNHUB	2026-06-07 11:03:02.283392+00	\N
461	4518	2026-06-07	91.1900	\N	\N	31860.84	6.5396	FINNHUB	2026-06-07 11:03:04.941841+00	\N
462	4519	2026-06-07	149.2300	\N	\N	31725.77	\N	FINNHUB	2026-06-07 11:03:07.501059+00	\N
463	4520	2026-06-07	61.4400	\N	\N	29351.22	17.1986	FINNHUB	2026-06-07 11:03:10.104645+00	\N
464	4521	2026-06-07	170.4700	\N	\N	31545.01	16.8654	FINNHUB	2026-06-07 11:03:12.720762+00	\N
465	4522	2026-06-07	26.2200	\N	\N	47465.47	11.8895	FINNHUB	2026-06-07 11:03:15.377152+00	\N
466	4523	2026-06-07	64.4700	\N	\N	31206.97	12.3250	FINNHUB	2026-06-07 11:03:18.351919+00	\N
467	4524	2026-06-07	15.1500	\N	\N	115126744.00	12.7517	FINNHUB	2026-06-07 11:03:26.857089+00	\N
468	4525	2026-06-07	215.3100	\N	\N	30835.70	\N	FINNHUB	2026-06-07 11:03:30.639197+00	\N
469	4526	2026-06-07	62.3300	\N	\N	30778.37	\N	FINNHUB	2026-06-07 11:03:33.237072+00	\N
470	4527	2026-06-07	183.4500	\N	\N	30617.81	22.1067	FINNHUB	2026-06-07 11:03:35.839204+00	\N
471	4528	2026-06-07	27.8600	\N	\N	29812.73	9.6038	FINNHUB	2026-06-07 11:03:38.463248+00	\N
472	4529	2026-06-07	145.7700	\N	\N	30324.29	23.9907	FINNHUB	2026-06-07 11:03:41.107749+00	\N
473	4530	2026-06-07	109.2700	\N	\N	30240.65	19.8429	FINNHUB	2026-06-07 11:03:43.755382+00	\N
474	4531	2026-06-07	83.4900	\N	\N	30206.26	\N	FINNHUB	2026-06-07 11:03:46.374254+00	\N
475	4532	2026-06-07	61.6700	\N	\N	30197.84	33.5013	FINNHUB	2026-06-07 11:03:49.184982+00	\N
476	4533	2026-06-07	47.6900	\N	\N	246955.66	6.4272	FINNHUB	2026-06-07 11:03:51.972044+00	\N
477	4534	2026-06-07	270.1000	\N	\N	216439.66	68.4287	FINNHUB	2026-06-07 11:03:54.959208+00	\N
478	4535	2026-06-07	279.0100	\N	\N	29980.56	18.0030	FINNHUB	2026-06-07 11:03:57.545616+00	\N
479	4536	2026-06-07	41.8200	\N	\N	29942.23	\N	FINNHUB	2026-06-07 11:04:00.140152+00	\N
480	4537	2026-06-07	101.6200	\N	\N	31141.26	15.0352	FINNHUB	2026-06-07 11:04:02.740356+00	\N
481	4538	2026-06-07	53.5800	\N	\N	29615.59	25.6190	FINNHUB	2026-06-07 11:04:05.311426+00	\N
482	4539	2026-06-07	142.0500	\N	\N	29736.64	64.3650	FINNHUB	2026-06-07 11:04:07.890816+00	\N
483	4540	2026-06-07	151.4500	\N	\N	29515.03	13.7471	FINNHUB	2026-06-07 11:04:10.534384+00	\N
484	4541	2026-06-07	281.9100	\N	\N	29502.95	23.8871	FINNHUB	2026-06-07 11:04:13.127202+00	\N
485	4542	2026-06-07	64.6700	\N	\N	29417.85	15.4020	FINNHUB	2026-06-07 11:04:15.70444+00	\N
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
1	dev@maemoji.local	LOCAL_DEV_ONLY	MaeMoJi 개발 사용자	ACTIVE	2026-06-06 10:24:08.482852+00	2026-06-06 10:24:08.482852+00	\N	\N	8d05c61c90f44982bf81092fbcd1d059d9436e9fe4fd44f596b46fe304c5a848	2026-07-13 13:04:14.146302+00	2026-06-13 13:04:14.146302+00
\.


--
-- Name: news_analysis_cache_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.news_analysis_cache_id_seq', 103, true);


--
-- Name: portfolio_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.portfolio_items_id_seq', 7, true);


--
-- Name: recommendation_evidence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recommendation_evidence_id_seq', 365, true);


--
-- Name: recommendation_factor_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recommendation_factor_details_id_seq', 1, false);


--
-- Name: recommendations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recommendations_id_seq', 80, true);


--
-- Name: stock_price_snapshots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stock_price_snapshots_id_seq', 485, true);


--
-- Name: stocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stocks_id_seq', 4575, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


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

\unrestrict wupSDgjNbls2cfD5PZFoldQnU8f50ooIRBTi4zJWH8zqCTsPWh7gEZL96tHOqDh

