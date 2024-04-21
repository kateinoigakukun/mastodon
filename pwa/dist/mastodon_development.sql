--
-- PostgreSQL database dump
--

-- Dumped from database version 14.11
-- Dumped by pg_dump version 14.11

--
-- Name: timestamp_id(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.timestamp_id(table_name text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
  DECLARE
    time_part bigint;
    sequence_base bigint;
    tail bigint;
  BEGIN
    time_part := (
      -- Get the time in milliseconds
      ((date_part('epoch', now()) * 1000))::bigint
      -- And shift it over two bytes
      << 16);

    sequence_base := (
      'x' ||
      -- Take the first two bytes (four hex characters)
      substr(
        -- Of the MD5 hash of the data we documented
        md5(table_name || 'd94a73dae93953f7307e4d54de12545c' || time_part::text),
        1, 4
      )
    -- And turn it into a bigint
    )::bit(16)::bigint;

    -- Finally, add our sequence number to our base, and chop
    -- it to the last two bytes
    tail := (
      (sequence_base + nextval(table_name || '_id_seq'))
      & 65535);

    -- Return the time part and the sequence part. OR appears
    -- faster here than addition, but they're equivalent:
    -- time_part has no trailing two bytes, and tail is only
    -- the last two bytes.
    RETURN time_part | tail;
  END
$$;


ALTER FUNCTION public.timestamp_id(table_name text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_aliases; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_aliases (
    id bigint NOT NULL,
    account_id bigint,
    acct character varying DEFAULT ''::character varying NOT NULL,
    uri character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.account_aliases OWNER TO postgres;

--
-- Name: account_aliases_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_aliases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_aliases_id_seq OWNER TO postgres;

--
-- Name: account_aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_aliases_id_seq OWNED BY public.account_aliases.id;


--
-- Name: account_conversations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_conversations (
    id bigint NOT NULL,
    account_id bigint,
    conversation_id bigint,
    participant_account_ids bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    status_ids bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    last_status_id bigint,
    lock_version integer DEFAULT 0 NOT NULL,
    unread boolean DEFAULT false NOT NULL
);


ALTER TABLE public.account_conversations OWNER TO postgres;

--
-- Name: account_conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_conversations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_conversations_id_seq OWNER TO postgres;

--
-- Name: account_conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_conversations_id_seq OWNED BY public.account_conversations.id;


--
-- Name: account_deletion_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_deletion_requests (
    id bigint NOT NULL,
    account_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.account_deletion_requests OWNER TO postgres;

--
-- Name: account_deletion_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_deletion_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_deletion_requests_id_seq OWNER TO postgres;

--
-- Name: account_deletion_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_deletion_requests_id_seq OWNED BY public.account_deletion_requests.id;


--
-- Name: account_domain_blocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_domain_blocks (
    id bigint NOT NULL,
    domain character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint
);


ALTER TABLE public.account_domain_blocks OWNER TO postgres;

--
-- Name: account_domain_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_domain_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_domain_blocks_id_seq OWNER TO postgres;

--
-- Name: account_domain_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_domain_blocks_id_seq OWNED BY public.account_domain_blocks.id;


--
-- Name: account_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_migrations (
    id bigint NOT NULL,
    account_id bigint,
    acct character varying DEFAULT ''::character varying NOT NULL,
    followers_count bigint DEFAULT 0 NOT NULL,
    target_account_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.account_migrations OWNER TO postgres;

--
-- Name: account_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_migrations_id_seq OWNER TO postgres;

--
-- Name: account_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_migrations_id_seq OWNED BY public.account_migrations.id;


--
-- Name: account_moderation_notes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_moderation_notes (
    id bigint NOT NULL,
    content text NOT NULL,
    account_id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.account_moderation_notes OWNER TO postgres;

--
-- Name: account_moderation_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_moderation_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_moderation_notes_id_seq OWNER TO postgres;

--
-- Name: account_moderation_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_moderation_notes_id_seq OWNED BY public.account_moderation_notes.id;


--
-- Name: account_notes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_notes (
    id bigint NOT NULL,
    account_id bigint,
    target_account_id bigint,
    comment text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.account_notes OWNER TO postgres;

--
-- Name: account_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_notes_id_seq OWNER TO postgres;

--
-- Name: account_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_notes_id_seq OWNED BY public.account_notes.id;


--
-- Name: account_pins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_pins (
    id bigint NOT NULL,
    account_id bigint,
    target_account_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.account_pins OWNER TO postgres;

--
-- Name: account_pins_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_pins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_pins_id_seq OWNER TO postgres;

--
-- Name: account_pins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_pins_id_seq OWNED BY public.account_pins.id;


--
-- Name: account_relationship_severance_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_relationship_severance_events (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    relationship_severance_event_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    followers_count integer DEFAULT 0 NOT NULL,
    following_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.account_relationship_severance_events OWNER TO postgres;

--
-- Name: account_relationship_severance_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_relationship_severance_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_relationship_severance_events_id_seq OWNER TO postgres;

--
-- Name: account_relationship_severance_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_relationship_severance_events_id_seq OWNED BY public.account_relationship_severance_events.id;


--
-- Name: account_stats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_stats (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    statuses_count bigint DEFAULT 0 NOT NULL,
    following_count bigint DEFAULT 0 NOT NULL,
    followers_count bigint DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_status_at timestamp without time zone
);


ALTER TABLE public.account_stats OWNER TO postgres;

--
-- Name: account_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_stats_id_seq OWNER TO postgres;

--
-- Name: account_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_stats_id_seq OWNED BY public.account_stats.id;


--
-- Name: account_statuses_cleanup_policies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_statuses_cleanup_policies (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    min_status_age integer DEFAULT 1209600 NOT NULL,
    keep_direct boolean DEFAULT true NOT NULL,
    keep_pinned boolean DEFAULT true NOT NULL,
    keep_polls boolean DEFAULT false NOT NULL,
    keep_media boolean DEFAULT false NOT NULL,
    keep_self_fav boolean DEFAULT true NOT NULL,
    keep_self_bookmark boolean DEFAULT true NOT NULL,
    min_favs integer,
    min_reblogs integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.account_statuses_cleanup_policies OWNER TO postgres;

--
-- Name: account_statuses_cleanup_policies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_statuses_cleanup_policies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_statuses_cleanup_policies_id_seq OWNER TO postgres;

--
-- Name: account_statuses_cleanup_policies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_statuses_cleanup_policies_id_seq OWNED BY public.account_statuses_cleanup_policies.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts (
    id bigint DEFAULT public.timestamp_id('accounts'::text) NOT NULL,
    username character varying DEFAULT ''::character varying NOT NULL,
    domain character varying,
    private_key text,
    public_key text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    display_name character varying DEFAULT ''::character varying NOT NULL,
    uri character varying DEFAULT ''::character varying NOT NULL,
    url character varying,
    avatar_file_name character varying,
    avatar_content_type character varying,
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    header_file_name character varying,
    header_content_type character varying,
    header_file_size integer,
    header_updated_at timestamp without time zone,
    avatar_remote_url character varying,
    locked boolean DEFAULT false NOT NULL,
    header_remote_url character varying DEFAULT ''::character varying NOT NULL,
    last_webfingered_at timestamp without time zone,
    inbox_url character varying DEFAULT ''::character varying NOT NULL,
    outbox_url character varying DEFAULT ''::character varying NOT NULL,
    shared_inbox_url character varying DEFAULT ''::character varying NOT NULL,
    followers_url character varying DEFAULT ''::character varying NOT NULL,
    protocol integer DEFAULT 0 NOT NULL,
    memorial boolean DEFAULT false NOT NULL,
    moved_to_account_id bigint,
    featured_collection_url character varying,
    fields jsonb,
    actor_type character varying,
    discoverable boolean,
    also_known_as character varying[],
    silenced_at timestamp without time zone,
    suspended_at timestamp without time zone,
    hide_collections boolean,
    avatar_storage_schema_version integer,
    header_storage_schema_version integer,
    devices_url character varying,
    suspension_origin integer,
    sensitized_at timestamp without time zone,
    trendable boolean,
    reviewed_at timestamp without time zone,
    requested_review_at timestamp without time zone,
    indexable boolean DEFAULT false NOT NULL
);


ALTER TABLE public.accounts OWNER TO postgres;

--
-- Name: statuses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.statuses (
    id bigint DEFAULT public.timestamp_id('statuses'::text) NOT NULL,
    uri character varying,
    text text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    in_reply_to_id bigint,
    reblog_of_id bigint,
    url character varying,
    sensitive boolean DEFAULT false NOT NULL,
    visibility integer DEFAULT 0 NOT NULL,
    spoiler_text text DEFAULT ''::text NOT NULL,
    reply boolean DEFAULT false NOT NULL,
    language character varying,
    conversation_id bigint,
    local boolean,
    account_id bigint NOT NULL,
    application_id bigint,
    in_reply_to_account_id bigint,
    poll_id bigint,
    deleted_at timestamp without time zone,
    edited_at timestamp without time zone,
    trendable boolean,
    ordered_media_attachment_ids bigint[]
);


ALTER TABLE public.statuses OWNER TO postgres;

--
-- Name: account_summaries; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.account_summaries AS
 SELECT accounts.id AS account_id,
    mode() WITHIN GROUP (ORDER BY t0.language) AS language,
    mode() WITHIN GROUP (ORDER BY t0.sensitive) AS sensitive
   FROM (public.accounts
     CROSS JOIN LATERAL ( SELECT statuses.account_id,
            statuses.language,
            statuses.sensitive
           FROM public.statuses
          WHERE ((statuses.account_id = accounts.id) AND (statuses.deleted_at IS NULL) AND (statuses.reblog_of_id IS NULL))
          ORDER BY statuses.id DESC
         LIMIT 20) t0)
  WHERE ((accounts.suspended_at IS NULL) AND (accounts.silenced_at IS NULL) AND (accounts.moved_to_account_id IS NULL) AND (accounts.discoverable = true) AND (accounts.locked = false))
  GROUP BY accounts.id
  WITH NO DATA;


ALTER TABLE public.account_summaries OWNER TO postgres;

--
-- Name: account_warning_presets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_warning_presets (
    id bigint NOT NULL,
    text text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.account_warning_presets OWNER TO postgres;

--
-- Name: account_warning_presets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_warning_presets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_warning_presets_id_seq OWNER TO postgres;

--
-- Name: account_warning_presets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_warning_presets_id_seq OWNED BY public.account_warning_presets.id;


--
-- Name: account_warnings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_warnings (
    id bigint NOT NULL,
    account_id bigint,
    target_account_id bigint,
    action integer DEFAULT 0 NOT NULL,
    text text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    report_id bigint,
    status_ids character varying[],
    overruled_at timestamp without time zone
);


ALTER TABLE public.account_warnings OWNER TO postgres;

--
-- Name: account_warnings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_warnings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_warnings_id_seq OWNER TO postgres;

--
-- Name: account_warnings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_warnings_id_seq OWNED BY public.account_warnings.id;


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounts_id_seq OWNER TO postgres;

--
-- Name: accounts_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts_tags (
    account_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


ALTER TABLE public.accounts_tags OWNER TO postgres;

--
-- Name: admin_action_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_action_logs (
    id bigint NOT NULL,
    account_id bigint,
    action character varying DEFAULT ''::character varying NOT NULL,
    target_type character varying,
    target_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    human_identifier character varying,
    route_param character varying,
    permalink character varying
);


ALTER TABLE public.admin_action_logs OWNER TO postgres;

--
-- Name: admin_action_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admin_action_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.admin_action_logs_id_seq OWNER TO postgres;

--
-- Name: admin_action_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admin_action_logs_id_seq OWNED BY public.admin_action_logs.id;


--
-- Name: announcement_mutes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcement_mutes (
    id bigint NOT NULL,
    account_id bigint,
    announcement_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.announcement_mutes OWNER TO postgres;

--
-- Name: announcement_mutes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.announcement_mutes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.announcement_mutes_id_seq OWNER TO postgres;

--
-- Name: announcement_mutes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.announcement_mutes_id_seq OWNED BY public.announcement_mutes.id;


--
-- Name: announcement_reactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcement_reactions (
    id bigint NOT NULL,
    account_id bigint,
    announcement_id bigint,
    name character varying DEFAULT ''::character varying NOT NULL,
    custom_emoji_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.announcement_reactions OWNER TO postgres;

--
-- Name: announcement_reactions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.announcement_reactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.announcement_reactions_id_seq OWNER TO postgres;

--
-- Name: announcement_reactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.announcement_reactions_id_seq OWNED BY public.announcement_reactions.id;


--
-- Name: announcements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcements (
    id bigint NOT NULL,
    text text DEFAULT ''::text NOT NULL,
    published boolean DEFAULT false NOT NULL,
    all_day boolean DEFAULT false NOT NULL,
    scheduled_at timestamp without time zone,
    starts_at timestamp without time zone,
    ends_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    published_at timestamp without time zone,
    status_ids bigint[]
);


ALTER TABLE public.announcements OWNER TO postgres;

--
-- Name: announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.announcements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.announcements_id_seq OWNER TO postgres;

--
-- Name: announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.announcements_id_seq OWNED BY public.announcements.id;


--
-- Name: appeals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.appeals (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    account_warning_id bigint NOT NULL,
    text text DEFAULT ''::text NOT NULL,
    approved_at timestamp without time zone,
    approved_by_account_id bigint,
    rejected_at timestamp without time zone,
    rejected_by_account_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.appeals OWNER TO postgres;

--
-- Name: appeals_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.appeals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.appeals_id_seq OWNER TO postgres;

--
-- Name: appeals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.appeals_id_seq OWNED BY public.appeals.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO postgres;

--
-- Name: backups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.backups (
    id bigint NOT NULL,
    user_id bigint,
    dump_file_name character varying,
    dump_content_type character varying,
    dump_updated_at timestamp without time zone,
    processed boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    dump_file_size bigint
);


ALTER TABLE public.backups OWNER TO postgres;

--
-- Name: backups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.backups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.backups_id_seq OWNER TO postgres;

--
-- Name: backups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.backups_id_seq OWNED BY public.backups.id;


--
-- Name: blocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.blocks (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    uri character varying
);


ALTER TABLE public.blocks OWNER TO postgres;

--
-- Name: blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blocks_id_seq OWNER TO postgres;

--
-- Name: blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.blocks_id_seq OWNED BY public.blocks.id;


--
-- Name: bookmarks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bookmarks (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    status_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.bookmarks OWNER TO postgres;

--
-- Name: bookmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bookmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bookmarks_id_seq OWNER TO postgres;

--
-- Name: bookmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bookmarks_id_seq OWNED BY public.bookmarks.id;


--
-- Name: bulk_import_rows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bulk_import_rows (
    id bigint NOT NULL,
    bulk_import_id bigint NOT NULL,
    data jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.bulk_import_rows OWNER TO postgres;

--
-- Name: bulk_import_rows_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bulk_import_rows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bulk_import_rows_id_seq OWNER TO postgres;

--
-- Name: bulk_import_rows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bulk_import_rows_id_seq OWNED BY public.bulk_import_rows.id;


--
-- Name: bulk_imports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bulk_imports (
    id bigint NOT NULL,
    type integer NOT NULL,
    state integer NOT NULL,
    total_items integer DEFAULT 0 NOT NULL,
    imported_items integer DEFAULT 0 NOT NULL,
    processed_items integer DEFAULT 0 NOT NULL,
    finished_at timestamp without time zone,
    overwrite boolean DEFAULT false NOT NULL,
    likely_mismatched boolean DEFAULT false NOT NULL,
    original_filename character varying DEFAULT ''::character varying NOT NULL,
    account_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.bulk_imports OWNER TO postgres;

--
-- Name: bulk_imports_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bulk_imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bulk_imports_id_seq OWNER TO postgres;

--
-- Name: bulk_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bulk_imports_id_seq OWNED BY public.bulk_imports.id;


--
-- Name: canonical_email_blocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.canonical_email_blocks (
    id bigint NOT NULL,
    canonical_email_hash character varying DEFAULT ''::character varying NOT NULL,
    reference_account_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.canonical_email_blocks OWNER TO postgres;

--
-- Name: canonical_email_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.canonical_email_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.canonical_email_blocks_id_seq OWNER TO postgres;

--
-- Name: canonical_email_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.canonical_email_blocks_id_seq OWNED BY public.canonical_email_blocks.id;


--
-- Name: conversation_mutes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversation_mutes (
    id bigint NOT NULL,
    conversation_id bigint NOT NULL,
    account_id bigint NOT NULL
);


ALTER TABLE public.conversation_mutes OWNER TO postgres;

--
-- Name: conversation_mutes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.conversation_mutes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.conversation_mutes_id_seq OWNER TO postgres;

--
-- Name: conversation_mutes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.conversation_mutes_id_seq OWNED BY public.conversation_mutes.id;


--
-- Name: conversations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversations (
    id bigint NOT NULL,
    uri character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.conversations OWNER TO postgres;

--
-- Name: conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.conversations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.conversations_id_seq OWNER TO postgres;

--
-- Name: conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.conversations_id_seq OWNED BY public.conversations.id;


--
-- Name: custom_emoji_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.custom_emoji_categories (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.custom_emoji_categories OWNER TO postgres;

--
-- Name: custom_emoji_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.custom_emoji_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_emoji_categories_id_seq OWNER TO postgres;

--
-- Name: custom_emoji_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.custom_emoji_categories_id_seq OWNED BY public.custom_emoji_categories.id;


--
-- Name: custom_emojis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.custom_emojis (
    id bigint NOT NULL,
    shortcode character varying DEFAULT ''::character varying NOT NULL,
    domain character varying,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size integer,
    image_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    disabled boolean DEFAULT false NOT NULL,
    uri character varying,
    image_remote_url character varying,
    visible_in_picker boolean DEFAULT true NOT NULL,
    category_id bigint,
    image_storage_schema_version integer
);


ALTER TABLE public.custom_emojis OWNER TO postgres;

--
-- Name: custom_emojis_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.custom_emojis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_emojis_id_seq OWNER TO postgres;

--
-- Name: custom_emojis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.custom_emojis_id_seq OWNED BY public.custom_emojis.id;


--
-- Name: custom_filter_keywords; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.custom_filter_keywords (
    id bigint NOT NULL,
    custom_filter_id bigint NOT NULL,
    keyword text DEFAULT ''::text NOT NULL,
    whole_word boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.custom_filter_keywords OWNER TO postgres;

--
-- Name: custom_filter_keywords_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.custom_filter_keywords_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_filter_keywords_id_seq OWNER TO postgres;

--
-- Name: custom_filter_keywords_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.custom_filter_keywords_id_seq OWNED BY public.custom_filter_keywords.id;


--
-- Name: custom_filter_statuses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.custom_filter_statuses (
    id bigint NOT NULL,
    custom_filter_id bigint NOT NULL,
    status_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.custom_filter_statuses OWNER TO postgres;

--
-- Name: custom_filter_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.custom_filter_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_filter_statuses_id_seq OWNER TO postgres;

--
-- Name: custom_filter_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.custom_filter_statuses_id_seq OWNED BY public.custom_filter_statuses.id;


--
-- Name: custom_filters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.custom_filters (
    id bigint NOT NULL,
    account_id bigint,
    expires_at timestamp without time zone,
    phrase text DEFAULT ''::text NOT NULL,
    context character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    action integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.custom_filters OWNER TO postgres;

--
-- Name: custom_filters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.custom_filters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_filters_id_seq OWNER TO postgres;

--
-- Name: custom_filters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.custom_filters_id_seq OWNED BY public.custom_filters.id;


--
-- Name: deprecated_preview_cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.deprecated_preview_cards (
    status_id bigint,
    url character varying DEFAULT ''::character varying NOT NULL,
    title character varying,
    description character varying,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size bigint,
    image_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    type integer DEFAULT 0 NOT NULL,
    html text DEFAULT ''::text NOT NULL,
    author_name character varying DEFAULT ''::character varying NOT NULL,
    author_url character varying DEFAULT ''::character varying NOT NULL,
    provider_name character varying DEFAULT ''::character varying NOT NULL,
    provider_url character varying DEFAULT ''::character varying NOT NULL,
    width integer DEFAULT 0 NOT NULL,
    height integer DEFAULT 0 NOT NULL,
    id bigint NOT NULL
);


ALTER TABLE public.deprecated_preview_cards OWNER TO postgres;

--
-- Name: deprecated_preview_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.deprecated_preview_cards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.deprecated_preview_cards_id_seq OWNER TO postgres;

--
-- Name: deprecated_preview_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.deprecated_preview_cards_id_seq OWNED BY public.deprecated_preview_cards.id;


--
-- Name: devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices (
    id bigint NOT NULL,
    access_token_id bigint,
    account_id bigint,
    device_id character varying DEFAULT ''::character varying NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    fingerprint_key text DEFAULT ''::text NOT NULL,
    identity_key text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.devices OWNER TO postgres;

--
-- Name: devices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.devices_id_seq OWNER TO postgres;

--
-- Name: devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.devices_id_seq OWNED BY public.devices.id;


--
-- Name: domain_allows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.domain_allows (
    id bigint NOT NULL,
    domain character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.domain_allows OWNER TO postgres;

--
-- Name: domain_allows_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.domain_allows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.domain_allows_id_seq OWNER TO postgres;

--
-- Name: domain_allows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.domain_allows_id_seq OWNED BY public.domain_allows.id;


--
-- Name: domain_blocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.domain_blocks (
    id bigint NOT NULL,
    domain character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    severity integer DEFAULT 0,
    reject_media boolean DEFAULT false NOT NULL,
    reject_reports boolean DEFAULT false NOT NULL,
    private_comment text,
    public_comment text,
    obfuscate boolean DEFAULT false NOT NULL
);


ALTER TABLE public.domain_blocks OWNER TO postgres;

--
-- Name: domain_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.domain_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.domain_blocks_id_seq OWNER TO postgres;

--
-- Name: domain_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.domain_blocks_id_seq OWNED BY public.domain_blocks.id;


--
-- Name: email_domain_blocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_domain_blocks (
    id bigint NOT NULL,
    domain character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parent_id bigint,
    allow_with_approval boolean DEFAULT false NOT NULL
);


ALTER TABLE public.email_domain_blocks OWNER TO postgres;

--
-- Name: email_domain_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.email_domain_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.email_domain_blocks_id_seq OWNER TO postgres;

--
-- Name: email_domain_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.email_domain_blocks_id_seq OWNED BY public.email_domain_blocks.id;


--
-- Name: encrypted_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.encrypted_messages (
    id bigint DEFAULT public.timestamp_id('encrypted_messages'::text) NOT NULL,
    device_id bigint,
    from_account_id bigint,
    from_device_id character varying DEFAULT ''::character varying NOT NULL,
    type integer DEFAULT 0 NOT NULL,
    body text DEFAULT ''::text NOT NULL,
    digest text DEFAULT ''::text NOT NULL,
    message_franking text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.encrypted_messages OWNER TO postgres;

--
-- Name: encrypted_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.encrypted_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.encrypted_messages_id_seq OWNER TO postgres;

--
-- Name: favourites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.favourites (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    status_id bigint NOT NULL
);


ALTER TABLE public.favourites OWNER TO postgres;

--
-- Name: favourites_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.favourites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.favourites_id_seq OWNER TO postgres;

--
-- Name: favourites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.favourites_id_seq OWNED BY public.favourites.id;


--
-- Name: featured_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.featured_tags (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    tag_id bigint NOT NULL,
    statuses_count bigint DEFAULT 0 NOT NULL,
    last_status_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying
);


ALTER TABLE public.featured_tags OWNER TO postgres;

--
-- Name: featured_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.featured_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.featured_tags_id_seq OWNER TO postgres;

--
-- Name: featured_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.featured_tags_id_seq OWNED BY public.featured_tags.id;


--
-- Name: follow_recommendation_mutes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.follow_recommendation_mutes (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.follow_recommendation_mutes OWNER TO postgres;

--
-- Name: follow_recommendation_mutes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.follow_recommendation_mutes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.follow_recommendation_mutes_id_seq OWNER TO postgres;

--
-- Name: follow_recommendation_mutes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.follow_recommendation_mutes_id_seq OWNED BY public.follow_recommendation_mutes.id;


--
-- Name: follow_recommendation_suppressions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.follow_recommendation_suppressions (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.follow_recommendation_suppressions OWNER TO postgres;

--
-- Name: follow_recommendation_suppressions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.follow_recommendation_suppressions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.follow_recommendation_suppressions_id_seq OWNER TO postgres;

--
-- Name: follow_recommendation_suppressions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.follow_recommendation_suppressions_id_seq OWNED BY public.follow_recommendation_suppressions.id;


--
-- Name: follow_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.follow_requests (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    show_reblogs boolean DEFAULT true NOT NULL,
    uri character varying,
    notify boolean DEFAULT false NOT NULL,
    languages character varying[]
);


ALTER TABLE public.follow_requests OWNER TO postgres;

--
-- Name: follow_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.follow_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.follow_requests_id_seq OWNER TO postgres;

--
-- Name: follow_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.follow_requests_id_seq OWNED BY public.follow_requests.id;


--
-- Name: follows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.follows (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    show_reblogs boolean DEFAULT true NOT NULL,
    uri character varying,
    notify boolean DEFAULT false NOT NULL,
    languages character varying[]
);


ALTER TABLE public.follows OWNER TO postgres;

--
-- Name: follows_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.follows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.follows_id_seq OWNER TO postgres;

--
-- Name: follows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.follows_id_seq OWNED BY public.follows.id;


--
-- Name: generated_annual_reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.generated_annual_reports (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    year integer NOT NULL,
    data jsonb NOT NULL,
    schema_version integer NOT NULL,
    viewed_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.generated_annual_reports OWNER TO postgres;

--
-- Name: generated_annual_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.generated_annual_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.generated_annual_reports_id_seq OWNER TO postgres;

--
-- Name: generated_annual_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.generated_annual_reports_id_seq OWNED BY public.generated_annual_reports.id;


--
-- Name: status_stats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.status_stats (
    id bigint NOT NULL,
    status_id bigint NOT NULL,
    replies_count bigint DEFAULT 0 NOT NULL,
    reblogs_count bigint DEFAULT 0 NOT NULL,
    favourites_count bigint DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.status_stats OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    locale character varying,
    encrypted_otp_secret character varying,
    encrypted_otp_secret_iv character varying,
    encrypted_otp_secret_salt character varying,
    consumed_timestep integer,
    otp_required_for_login boolean DEFAULT false NOT NULL,
    last_emailed_at timestamp without time zone,
    otp_backup_codes character varying[],
    account_id bigint NOT NULL,
    disabled boolean DEFAULT false NOT NULL,
    invite_id bigint,
    chosen_languages character varying[],
    created_by_application_id bigint,
    approved boolean DEFAULT true NOT NULL,
    sign_in_token character varying,
    sign_in_token_sent_at timestamp without time zone,
    webauthn_id character varying,
    sign_up_ip inet,
    skip_sign_in_token boolean,
    role_id bigint,
    settings text,
    time_zone character varying
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: global_follow_recommendations; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.global_follow_recommendations AS
 SELECT t0.account_id,
    sum(t0.rank) AS rank,
    array_agg(t0.reason) AS reason
   FROM ( SELECT account_summaries.account_id,
            ((count(follows.id))::numeric / (1.0 + (count(follows.id))::numeric)) AS rank,
            'most_followed'::text AS reason
           FROM ((public.follows
             JOIN public.account_summaries ON ((account_summaries.account_id = follows.target_account_id)))
             JOIN public.users ON ((users.account_id = follows.account_id)))
          WHERE ((users.current_sign_in_at >= (now() - '30 days'::interval)) AND (account_summaries.sensitive = false) AND (NOT (EXISTS ( SELECT 1
                   FROM public.follow_recommendation_suppressions
                  WHERE (follow_recommendation_suppressions.account_id = follows.target_account_id)))))
          GROUP BY account_summaries.account_id
         HAVING (count(follows.id) >= 5)
        UNION ALL
         SELECT account_summaries.account_id,
            (sum((status_stats.reblogs_count + status_stats.favourites_count)) / (1.0 + sum((status_stats.reblogs_count + status_stats.favourites_count)))) AS rank,
            'most_interactions'::text AS reason
           FROM ((public.status_stats
             JOIN public.statuses ON ((statuses.id = status_stats.status_id)))
             JOIN public.account_summaries ON ((account_summaries.account_id = statuses.account_id)))
          WHERE ((statuses.id >= (((date_part('epoch'::text, (now() - '30 days'::interval)) * (1000)::double precision))::bigint << 16)) AND (account_summaries.sensitive = false) AND (NOT (EXISTS ( SELECT 1
                   FROM public.follow_recommendation_suppressions
                  WHERE (follow_recommendation_suppressions.account_id = statuses.account_id)))))
          GROUP BY account_summaries.account_id
         HAVING (sum((status_stats.reblogs_count + status_stats.favourites_count)) >= (5)::numeric)) t0
  GROUP BY t0.account_id
  ORDER BY (sum(t0.rank)) DESC
  WITH NO DATA;


ALTER TABLE public.global_follow_recommendations OWNER TO postgres;

--
-- Name: identities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.identities (
    id bigint NOT NULL,
    provider character varying DEFAULT ''::character varying NOT NULL,
    uid character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);


ALTER TABLE public.identities OWNER TO postgres;

--
-- Name: identities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.identities_id_seq OWNER TO postgres;

--
-- Name: identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.identities_id_seq OWNED BY public.identities.id;


--
-- Name: imports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.imports (
    id bigint NOT NULL,
    type integer NOT NULL,
    approved boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_file_name character varying,
    data_content_type character varying,
    data_file_size integer,
    data_updated_at timestamp without time zone,
    account_id bigint NOT NULL,
    overwrite boolean DEFAULT false NOT NULL
);


ALTER TABLE public.imports OWNER TO postgres;

--
-- Name: imports_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.imports_id_seq OWNER TO postgres;

--
-- Name: imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.imports_id_seq OWNED BY public.imports.id;


--
-- Name: instances; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.instances AS
 WITH domain_counts(domain, accounts_count) AS (
         SELECT accounts.domain,
            count(*) AS accounts_count
           FROM public.accounts
          WHERE (accounts.domain IS NOT NULL)
          GROUP BY accounts.domain
        )
 SELECT domain_counts.domain,
    domain_counts.accounts_count
   FROM domain_counts
UNION
 SELECT domain_blocks.domain,
    COALESCE(domain_counts.accounts_count, (0)::bigint) AS accounts_count
   FROM (public.domain_blocks
     LEFT JOIN domain_counts ON (((domain_counts.domain)::text = (domain_blocks.domain)::text)))
UNION
 SELECT domain_allows.domain,
    COALESCE(domain_counts.accounts_count, (0)::bigint) AS accounts_count
   FROM (public.domain_allows
     LEFT JOIN domain_counts ON (((domain_counts.domain)::text = (domain_allows.domain)::text)))
  WITH NO DATA;


ALTER TABLE public.instances OWNER TO postgres;

--
-- Name: invites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invites (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    code character varying DEFAULT ''::character varying NOT NULL,
    expires_at timestamp without time zone,
    max_uses integer,
    uses integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    autofollow boolean DEFAULT false NOT NULL,
    comment text
);


ALTER TABLE public.invites OWNER TO postgres;

--
-- Name: invites_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invites_id_seq OWNER TO postgres;

--
-- Name: invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.invites_id_seq OWNED BY public.invites.id;


--
-- Name: ip_blocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ip_blocks (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone,
    ip inet DEFAULT '0.0.0.0'::inet NOT NULL,
    severity integer DEFAULT 0 NOT NULL,
    comment text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.ip_blocks OWNER TO postgres;

--
-- Name: ip_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ip_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ip_blocks_id_seq OWNER TO postgres;

--
-- Name: ip_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ip_blocks_id_seq OWNED BY public.ip_blocks.id;


--
-- Name: list_accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.list_accounts (
    id bigint NOT NULL,
    list_id bigint NOT NULL,
    account_id bigint NOT NULL,
    follow_id bigint,
    follow_request_id bigint
);


ALTER TABLE public.list_accounts OWNER TO postgres;

--
-- Name: list_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.list_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.list_accounts_id_seq OWNER TO postgres;

--
-- Name: list_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.list_accounts_id_seq OWNED BY public.list_accounts.id;


--
-- Name: lists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lists (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    title character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    replies_policy integer DEFAULT 0 NOT NULL,
    exclusive boolean DEFAULT false NOT NULL
);


ALTER TABLE public.lists OWNER TO postgres;

--
-- Name: lists_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lists_id_seq OWNER TO postgres;

--
-- Name: lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lists_id_seq OWNED BY public.lists.id;


--
-- Name: login_activities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.login_activities (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    authentication_method character varying,
    provider character varying,
    success boolean,
    failure_reason character varying,
    ip inet,
    user_agent character varying,
    created_at timestamp without time zone
);


ALTER TABLE public.login_activities OWNER TO postgres;

--
-- Name: login_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.login_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.login_activities_id_seq OWNER TO postgres;

--
-- Name: login_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.login_activities_id_seq OWNED BY public.login_activities.id;


--
-- Name: markers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.markers (
    id bigint NOT NULL,
    user_id bigint,
    timeline character varying DEFAULT ''::character varying NOT NULL,
    last_read_id bigint DEFAULT 0 NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.markers OWNER TO postgres;

--
-- Name: markers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.markers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.markers_id_seq OWNER TO postgres;

--
-- Name: markers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.markers_id_seq OWNED BY public.markers.id;


--
-- Name: media_attachments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.media_attachments (
    id bigint DEFAULT public.timestamp_id('media_attachments'::text) NOT NULL,
    status_id bigint,
    file_file_name character varying,
    file_content_type character varying,
    file_file_size integer,
    file_updated_at timestamp without time zone,
    remote_url character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    shortcode character varying,
    type integer DEFAULT 0 NOT NULL,
    file_meta json,
    account_id bigint,
    description text,
    scheduled_status_id bigint,
    blurhash character varying,
    processing integer,
    file_storage_schema_version integer,
    thumbnail_file_name character varying,
    thumbnail_content_type character varying,
    thumbnail_file_size integer,
    thumbnail_updated_at timestamp without time zone,
    thumbnail_remote_url character varying
);


ALTER TABLE public.media_attachments OWNER TO postgres;

--
-- Name: media_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.media_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.media_attachments_id_seq OWNER TO postgres;

--
-- Name: mentions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mentions (
    id bigint NOT NULL,
    status_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint,
    silent boolean DEFAULT false NOT NULL
);


ALTER TABLE public.mentions OWNER TO postgres;

--
-- Name: mentions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mentions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mentions_id_seq OWNER TO postgres;

--
-- Name: mentions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mentions_id_seq OWNED BY public.mentions.id;


--
-- Name: mutes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mutes (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    hide_notifications boolean DEFAULT true NOT NULL,
    account_id bigint NOT NULL,
    target_account_id bigint NOT NULL,
    expires_at timestamp without time zone
);


ALTER TABLE public.mutes OWNER TO postgres;

--
-- Name: mutes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mutes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mutes_id_seq OWNER TO postgres;

--
-- Name: mutes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mutes_id_seq OWNED BY public.mutes.id;


--
-- Name: notification_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_permissions (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    from_account_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.notification_permissions OWNER TO postgres;

--
-- Name: notification_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notification_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notification_permissions_id_seq OWNER TO postgres;

--
-- Name: notification_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notification_permissions_id_seq OWNED BY public.notification_permissions.id;


--
-- Name: notification_policies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_policies (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    filter_not_following boolean DEFAULT false NOT NULL,
    filter_not_followers boolean DEFAULT false NOT NULL,
    filter_new_accounts boolean DEFAULT false NOT NULL,
    filter_private_mentions boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.notification_policies OWNER TO postgres;

--
-- Name: notification_policies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notification_policies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notification_policies_id_seq OWNER TO postgres;

--
-- Name: notification_policies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notification_policies_id_seq OWNED BY public.notification_policies.id;


--
-- Name: notification_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_requests (
    id bigint DEFAULT public.timestamp_id('notification_requests'::text) NOT NULL,
    account_id bigint NOT NULL,
    from_account_id bigint NOT NULL,
    last_status_id bigint,
    notifications_count bigint DEFAULT 0 NOT NULL,
    dismissed boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.notification_requests OWNER TO postgres;

--
-- Name: notification_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notification_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notification_requests_id_seq OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    activity_id bigint NOT NULL,
    activity_type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    from_account_id bigint NOT NULL,
    type character varying,
    filtered boolean DEFAULT false NOT NULL
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oauth_access_grants (
    id bigint NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying,
    application_id bigint NOT NULL,
    resource_owner_id bigint NOT NULL
);


ALTER TABLE public.oauth_access_grants OWNER TO postgres;

--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oauth_access_grants_id_seq OWNER TO postgres;

--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.oauth_access_grants_id_seq OWNED BY public.oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oauth_access_tokens (
    id bigint NOT NULL,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying,
    application_id bigint,
    resource_owner_id bigint,
    last_used_at timestamp without time zone,
    last_used_ip inet
);


ALTER TABLE public.oauth_access_tokens OWNER TO postgres;

--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oauth_access_tokens_id_seq OWNER TO postgres;

--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.oauth_access_tokens_id_seq OWNED BY public.oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oauth_applications (
    id bigint NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    superapp boolean DEFAULT false NOT NULL,
    website character varying,
    owner_type character varying,
    owner_id bigint,
    confidential boolean DEFAULT true NOT NULL
);


ALTER TABLE public.oauth_applications OWNER TO postgres;

--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oauth_applications_id_seq OWNER TO postgres;

--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.oauth_applications_id_seq OWNED BY public.oauth_applications.id;


--
-- Name: one_time_keys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.one_time_keys (
    id bigint NOT NULL,
    device_id bigint,
    key_id character varying DEFAULT ''::character varying NOT NULL,
    key text DEFAULT ''::text NOT NULL,
    signature text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.one_time_keys OWNER TO postgres;

--
-- Name: one_time_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.one_time_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.one_time_keys_id_seq OWNER TO postgres;

--
-- Name: one_time_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.one_time_keys_id_seq OWNED BY public.one_time_keys.id;


--
-- Name: pghero_space_stats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pghero_space_stats (
    id bigint NOT NULL,
    database text,
    schema text,
    relation text,
    size bigint,
    captured_at timestamp without time zone
);


ALTER TABLE public.pghero_space_stats OWNER TO postgres;

--
-- Name: pghero_space_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pghero_space_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pghero_space_stats_id_seq OWNER TO postgres;

--
-- Name: pghero_space_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pghero_space_stats_id_seq OWNED BY public.pghero_space_stats.id;


--
-- Name: poll_votes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.poll_votes (
    id bigint NOT NULL,
    account_id bigint,
    poll_id bigint,
    choice integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    uri character varying
);


ALTER TABLE public.poll_votes OWNER TO postgres;

--
-- Name: poll_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.poll_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.poll_votes_id_seq OWNER TO postgres;

--
-- Name: poll_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.poll_votes_id_seq OWNED BY public.poll_votes.id;


--
-- Name: polls; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.polls (
    id bigint NOT NULL,
    account_id bigint,
    status_id bigint,
    expires_at timestamp without time zone,
    options character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    cached_tallies bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    multiple boolean DEFAULT false NOT NULL,
    hide_totals boolean DEFAULT false NOT NULL,
    votes_count bigint DEFAULT 0 NOT NULL,
    last_fetched_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL,
    voters_count bigint
);


ALTER TABLE public.polls OWNER TO postgres;

--
-- Name: polls_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.polls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.polls_id_seq OWNER TO postgres;

--
-- Name: polls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.polls_id_seq OWNED BY public.polls.id;


--
-- Name: preview_card_providers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.preview_card_providers (
    id bigint NOT NULL,
    domain character varying DEFAULT ''::character varying NOT NULL,
    icon_file_name character varying,
    icon_content_type character varying,
    icon_file_size bigint,
    icon_updated_at timestamp without time zone,
    trendable boolean,
    reviewed_at timestamp without time zone,
    requested_review_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.preview_card_providers OWNER TO postgres;

--
-- Name: preview_card_providers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.preview_card_providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.preview_card_providers_id_seq OWNER TO postgres;

--
-- Name: preview_card_providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.preview_card_providers_id_seq OWNED BY public.preview_card_providers.id;


--
-- Name: preview_card_trends; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.preview_card_trends (
    id bigint NOT NULL,
    preview_card_id bigint NOT NULL,
    score double precision DEFAULT 0.0 NOT NULL,
    rank integer DEFAULT 0 NOT NULL,
    allowed boolean DEFAULT false NOT NULL,
    language character varying
);


ALTER TABLE public.preview_card_trends OWNER TO postgres;

--
-- Name: preview_card_trends_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.preview_card_trends_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.preview_card_trends_id_seq OWNER TO postgres;

--
-- Name: preview_card_trends_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.preview_card_trends_id_seq OWNED BY public.preview_card_trends.id;


--
-- Name: preview_cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.preview_cards (
    id bigint NOT NULL,
    url character varying DEFAULT ''::character varying NOT NULL,
    title character varying DEFAULT ''::character varying NOT NULL,
    description character varying DEFAULT ''::character varying NOT NULL,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size integer,
    image_updated_at timestamp without time zone,
    type integer DEFAULT 0 NOT NULL,
    html text DEFAULT ''::text NOT NULL,
    author_name character varying DEFAULT ''::character varying NOT NULL,
    author_url character varying DEFAULT ''::character varying NOT NULL,
    provider_name character varying DEFAULT ''::character varying NOT NULL,
    provider_url character varying DEFAULT ''::character varying NOT NULL,
    width integer DEFAULT 0 NOT NULL,
    height integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    embed_url character varying DEFAULT ''::character varying NOT NULL,
    image_storage_schema_version integer,
    blurhash character varying,
    language character varying,
    max_score double precision,
    max_score_at timestamp without time zone,
    trendable boolean,
    link_type integer,
    published_at timestamp(6) without time zone,
    image_description character varying DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.preview_cards OWNER TO postgres;

--
-- Name: preview_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.preview_cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.preview_cards_id_seq OWNER TO postgres;

--
-- Name: preview_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.preview_cards_id_seq OWNED BY public.preview_cards.id;


--
-- Name: preview_cards_statuses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.preview_cards_statuses (
    preview_card_id bigint NOT NULL,
    status_id bigint NOT NULL,
    url character varying
);


ALTER TABLE public.preview_cards_statuses OWNER TO postgres;

--
-- Name: relationship_severance_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.relationship_severance_events (
    id bigint NOT NULL,
    type integer NOT NULL,
    target_name character varying NOT NULL,
    purged boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.relationship_severance_events OWNER TO postgres;

--
-- Name: relationship_severance_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.relationship_severance_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.relationship_severance_events_id_seq OWNER TO postgres;

--
-- Name: relationship_severance_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.relationship_severance_events_id_seq OWNED BY public.relationship_severance_events.id;


--
-- Name: relays; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.relays (
    id bigint NOT NULL,
    inbox_url character varying DEFAULT ''::character varying NOT NULL,
    follow_activity_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.relays OWNER TO postgres;

--
-- Name: relays_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.relays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.relays_id_seq OWNER TO postgres;

--
-- Name: relays_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.relays_id_seq OWNED BY public.relays.id;


--
-- Name: report_notes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.report_notes (
    id bigint NOT NULL,
    content text NOT NULL,
    report_id bigint NOT NULL,
    account_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.report_notes OWNER TO postgres;

--
-- Name: report_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.report_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.report_notes_id_seq OWNER TO postgres;

--
-- Name: report_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.report_notes_id_seq OWNED BY public.report_notes.id;


--
-- Name: reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reports (
    id bigint NOT NULL,
    status_ids bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    comment text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id bigint NOT NULL,
    action_taken_by_account_id bigint,
    target_account_id bigint NOT NULL,
    assigned_account_id bigint,
    uri character varying,
    forwarded boolean,
    category integer DEFAULT 0 NOT NULL,
    action_taken_at timestamp without time zone,
    rule_ids bigint[]
);


ALTER TABLE public.reports OWNER TO postgres;

--
-- Name: reports_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reports_id_seq OWNER TO postgres;

--
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reports_id_seq OWNED BY public.reports.id;


--
-- Name: rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rules (
    id bigint NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    deleted_at timestamp without time zone,
    text text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    hint text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.rules OWNER TO postgres;

--
-- Name: rules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rules_id_seq OWNER TO postgres;

--
-- Name: rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rules_id_seq OWNED BY public.rules.id;


--
-- Name: scheduled_statuses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scheduled_statuses (
    id bigint NOT NULL,
    account_id bigint,
    scheduled_at timestamp without time zone,
    params jsonb
);


ALTER TABLE public.scheduled_statuses OWNER TO postgres;

--
-- Name: scheduled_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.scheduled_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scheduled_statuses_id_seq OWNER TO postgres;

--
-- Name: scheduled_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.scheduled_statuses_id_seq OWNED BY public.scheduled_statuses.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: session_activations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_activations (
    id bigint NOT NULL,
    session_id character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_agent character varying DEFAULT ''::character varying NOT NULL,
    ip inet,
    access_token_id bigint,
    user_id bigint NOT NULL,
    web_push_subscription_id bigint
);


ALTER TABLE public.session_activations OWNER TO postgres;

--
-- Name: session_activations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.session_activations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.session_activations_id_seq OWNER TO postgres;

--
-- Name: session_activations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.session_activations_id_seq OWNED BY public.session_activations.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.settings (
    id bigint NOT NULL,
    var character varying NOT NULL,
    value text,
    thing_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    thing_id bigint
);


ALTER TABLE public.settings OWNER TO postgres;

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.settings_id_seq OWNER TO postgres;

--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: severed_relationships; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.severed_relationships (
    id bigint NOT NULL,
    relationship_severance_event_id bigint NOT NULL,
    local_account_id bigint NOT NULL,
    remote_account_id bigint NOT NULL,
    direction integer NOT NULL,
    show_reblogs boolean,
    notify boolean,
    languages character varying[],
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.severed_relationships OWNER TO postgres;

--
-- Name: severed_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.severed_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.severed_relationships_id_seq OWNER TO postgres;

--
-- Name: severed_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.severed_relationships_id_seq OWNED BY public.severed_relationships.id;


--
-- Name: site_uploads; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.site_uploads (
    id bigint NOT NULL,
    var character varying DEFAULT ''::character varying NOT NULL,
    file_file_name character varying,
    file_content_type character varying,
    file_file_size integer,
    file_updated_at timestamp without time zone,
    meta json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    blurhash character varying
);


ALTER TABLE public.site_uploads OWNER TO postgres;

--
-- Name: site_uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.site_uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_uploads_id_seq OWNER TO postgres;

--
-- Name: site_uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.site_uploads_id_seq OWNED BY public.site_uploads.id;


--
-- Name: software_updates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.software_updates (
    id bigint NOT NULL,
    version character varying NOT NULL,
    urgent boolean DEFAULT false NOT NULL,
    type integer DEFAULT 0 NOT NULL,
    release_notes character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.software_updates OWNER TO postgres;

--
-- Name: software_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.software_updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.software_updates_id_seq OWNER TO postgres;

--
-- Name: software_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.software_updates_id_seq OWNED BY public.software_updates.id;


--
-- Name: status_edits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.status_edits (
    id bigint NOT NULL,
    status_id bigint NOT NULL,
    account_id bigint,
    text text DEFAULT ''::text NOT NULL,
    spoiler_text text DEFAULT ''::text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    ordered_media_attachment_ids bigint[],
    media_descriptions text[],
    poll_options character varying[],
    sensitive boolean
);


ALTER TABLE public.status_edits OWNER TO postgres;

--
-- Name: status_edits_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.status_edits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.status_edits_id_seq OWNER TO postgres;

--
-- Name: status_edits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.status_edits_id_seq OWNED BY public.status_edits.id;


--
-- Name: status_pins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.status_pins (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    status_id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.status_pins OWNER TO postgres;

--
-- Name: status_pins_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.status_pins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.status_pins_id_seq OWNER TO postgres;

--
-- Name: status_pins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.status_pins_id_seq OWNED BY public.status_pins.id;


--
-- Name: status_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.status_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.status_stats_id_seq OWNER TO postgres;

--
-- Name: status_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.status_stats_id_seq OWNED BY public.status_stats.id;


--
-- Name: status_trends; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.status_trends (
    id bigint NOT NULL,
    status_id bigint NOT NULL,
    account_id bigint NOT NULL,
    score double precision DEFAULT 0.0 NOT NULL,
    rank integer DEFAULT 0 NOT NULL,
    allowed boolean DEFAULT false NOT NULL,
    language character varying
);


ALTER TABLE public.status_trends OWNER TO postgres;

--
-- Name: status_trends_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.status_trends_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.status_trends_id_seq OWNER TO postgres;

--
-- Name: status_trends_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.status_trends_id_seq OWNED BY public.status_trends.id;


--
-- Name: statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.statuses_id_seq OWNER TO postgres;

--
-- Name: statuses_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.statuses_tags (
    status_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


ALTER TABLE public.statuses_tags OWNER TO postgres;

--
-- Name: system_keys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system_keys (
    id bigint NOT NULL,
    key bytea,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.system_keys OWNER TO postgres;

--
-- Name: system_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.system_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.system_keys_id_seq OWNER TO postgres;

--
-- Name: system_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.system_keys_id_seq OWNED BY public.system_keys.id;


--
-- Name: tag_follows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tag_follows (
    id bigint NOT NULL,
    tag_id bigint NOT NULL,
    account_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.tag_follows OWNER TO postgres;

--
-- Name: tag_follows_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tag_follows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tag_follows_id_seq OWNER TO postgres;

--
-- Name: tag_follows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tag_follows_id_seq OWNED BY public.tag_follows.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    usable boolean,
    trendable boolean,
    listable boolean,
    reviewed_at timestamp without time zone,
    requested_review_at timestamp without time zone,
    last_status_at timestamp without time zone,
    max_score double precision,
    max_score_at timestamp without time zone,
    display_name character varying
);


ALTER TABLE public.tags OWNER TO postgres;

--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tags_id_seq OWNER TO postgres;

--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: tombstones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tombstones (
    id bigint NOT NULL,
    account_id bigint,
    uri character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    by_moderator boolean
);


ALTER TABLE public.tombstones OWNER TO postgres;

--
-- Name: tombstones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tombstones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tombstones_id_seq OWNER TO postgres;

--
-- Name: tombstones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tombstones_id_seq OWNED BY public.tombstones.id;


--
-- Name: unavailable_domains; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.unavailable_domains (
    id bigint NOT NULL,
    domain character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.unavailable_domains OWNER TO postgres;

--
-- Name: unavailable_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.unavailable_domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.unavailable_domains_id_seq OWNER TO postgres;

--
-- Name: unavailable_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.unavailable_domains_id_seq OWNED BY public.unavailable_domains.id;


--
-- Name: user_invite_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_invite_requests (
    id bigint NOT NULL,
    user_id bigint,
    text text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.user_invite_requests OWNER TO postgres;

--
-- Name: user_invite_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_invite_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_invite_requests_id_seq OWNER TO postgres;

--
-- Name: user_invite_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_invite_requests_id_seq OWNED BY public.user_invite_requests.id;


--
-- Name: user_ips; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.user_ips AS
 SELECT t0.user_id,
    t0.ip,
    max(t0.used_at) AS used_at
   FROM ( SELECT users.id AS user_id,
            users.sign_up_ip AS ip,
            users.created_at AS used_at
           FROM public.users
          WHERE (users.sign_up_ip IS NOT NULL)
        UNION ALL
         SELECT session_activations.user_id,
            session_activations.ip,
            session_activations.updated_at
           FROM public.session_activations
        UNION ALL
         SELECT login_activities.user_id,
            login_activities.ip,
            login_activities.created_at
           FROM public.login_activities
          WHERE (login_activities.success = true)) t0
  GROUP BY t0.user_id, t0.ip;


ALTER TABLE public.user_ips OWNER TO postgres;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_roles (
    id bigint NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    color character varying DEFAULT ''::character varying NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    permissions bigint DEFAULT 0 NOT NULL,
    highlighted boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.user_roles OWNER TO postgres;

--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_roles_id_seq OWNER TO postgres;

--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_roles_id_seq OWNED BY public.user_roles.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: web_push_subscriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.web_push_subscriptions (
    id bigint NOT NULL,
    endpoint character varying NOT NULL,
    key_p256dh character varying NOT NULL,
    key_auth character varying NOT NULL,
    data json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    access_token_id bigint,
    user_id bigint
);


ALTER TABLE public.web_push_subscriptions OWNER TO postgres;

--
-- Name: web_push_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.web_push_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.web_push_subscriptions_id_seq OWNER TO postgres;

--
-- Name: web_push_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.web_push_subscriptions_id_seq OWNED BY public.web_push_subscriptions.id;


--
-- Name: web_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.web_settings (
    id bigint NOT NULL,
    data json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.web_settings OWNER TO postgres;

--
-- Name: web_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.web_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.web_settings_id_seq OWNER TO postgres;

--
-- Name: web_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.web_settings_id_seq OWNED BY public.web_settings.id;


--
-- Name: webauthn_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.webauthn_credentials (
    id bigint NOT NULL,
    external_id character varying NOT NULL,
    public_key character varying NOT NULL,
    nickname character varying NOT NULL,
    sign_count bigint DEFAULT 0 NOT NULL,
    user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.webauthn_credentials OWNER TO postgres;

--
-- Name: webauthn_credentials_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.webauthn_credentials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.webauthn_credentials_id_seq OWNER TO postgres;

--
-- Name: webauthn_credentials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.webauthn_credentials_id_seq OWNED BY public.webauthn_credentials.id;


--
-- Name: webhooks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.webhooks (
    id bigint NOT NULL,
    url character varying NOT NULL,
    events character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    secret character varying DEFAULT ''::character varying NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    template text
);


ALTER TABLE public.webhooks OWNER TO postgres;

--
-- Name: webhooks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.webhooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.webhooks_id_seq OWNER TO postgres;

--
-- Name: webhooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.webhooks_id_seq OWNED BY public.webhooks.id;


--
-- Name: account_aliases id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_aliases ALTER COLUMN id SET DEFAULT nextval('public.account_aliases_id_seq'::regclass);


--
-- Name: account_conversations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_conversations ALTER COLUMN id SET DEFAULT nextval('public.account_conversations_id_seq'::regclass);


--
-- Name: account_deletion_requests id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_deletion_requests ALTER COLUMN id SET DEFAULT nextval('public.account_deletion_requests_id_seq'::regclass);


--
-- Name: account_domain_blocks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_domain_blocks ALTER COLUMN id SET DEFAULT nextval('public.account_domain_blocks_id_seq'::regclass);


--
-- Name: account_migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_migrations ALTER COLUMN id SET DEFAULT nextval('public.account_migrations_id_seq'::regclass);


--
-- Name: account_moderation_notes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_moderation_notes ALTER COLUMN id SET DEFAULT nextval('public.account_moderation_notes_id_seq'::regclass);


--
-- Name: account_notes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_notes ALTER COLUMN id SET DEFAULT nextval('public.account_notes_id_seq'::regclass);


--
-- Name: account_pins id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_pins ALTER COLUMN id SET DEFAULT nextval('public.account_pins_id_seq'::regclass);


--
-- Name: account_relationship_severance_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_relationship_severance_events ALTER COLUMN id SET DEFAULT nextval('public.account_relationship_severance_events_id_seq'::regclass);


--
-- Name: account_stats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_stats ALTER COLUMN id SET DEFAULT nextval('public.account_stats_id_seq'::regclass);


--
-- Name: account_statuses_cleanup_policies id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_statuses_cleanup_policies ALTER COLUMN id SET DEFAULT nextval('public.account_statuses_cleanup_policies_id_seq'::regclass);


--
-- Name: account_warning_presets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_warning_presets ALTER COLUMN id SET DEFAULT nextval('public.account_warning_presets_id_seq'::regclass);


--
-- Name: account_warnings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_warnings ALTER COLUMN id SET DEFAULT nextval('public.account_warnings_id_seq'::regclass);


--
-- Name: admin_action_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_action_logs ALTER COLUMN id SET DEFAULT nextval('public.admin_action_logs_id_seq'::regclass);


--
-- Name: announcement_mutes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_mutes ALTER COLUMN id SET DEFAULT nextval('public.announcement_mutes_id_seq'::regclass);


--
-- Name: announcement_reactions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_reactions ALTER COLUMN id SET DEFAULT nextval('public.announcement_reactions_id_seq'::regclass);


--
-- Name: announcements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements ALTER COLUMN id SET DEFAULT nextval('public.announcements_id_seq'::regclass);


--
-- Name: appeals id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appeals ALTER COLUMN id SET DEFAULT nextval('public.appeals_id_seq'::regclass);


--
-- Name: backups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.backups ALTER COLUMN id SET DEFAULT nextval('public.backups_id_seq'::regclass);


--
-- Name: blocks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks ALTER COLUMN id SET DEFAULT nextval('public.blocks_id_seq'::regclass);


--
-- Name: bookmarks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookmarks ALTER COLUMN id SET DEFAULT nextval('public.bookmarks_id_seq'::regclass);


--
-- Name: bulk_import_rows id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulk_import_rows ALTER COLUMN id SET DEFAULT nextval('public.bulk_import_rows_id_seq'::regclass);


--
-- Name: bulk_imports id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulk_imports ALTER COLUMN id SET DEFAULT nextval('public.bulk_imports_id_seq'::regclass);


--
-- Name: canonical_email_blocks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canonical_email_blocks ALTER COLUMN id SET DEFAULT nextval('public.canonical_email_blocks_id_seq'::regclass);


--
-- Name: conversation_mutes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversation_mutes ALTER COLUMN id SET DEFAULT nextval('public.conversation_mutes_id_seq'::regclass);


--
-- Name: conversations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations ALTER COLUMN id SET DEFAULT nextval('public.conversations_id_seq'::regclass);


--
-- Name: custom_emoji_categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_emoji_categories ALTER COLUMN id SET DEFAULT nextval('public.custom_emoji_categories_id_seq'::regclass);


--
-- Name: custom_emojis id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_emojis ALTER COLUMN id SET DEFAULT nextval('public.custom_emojis_id_seq'::regclass);


--
-- Name: custom_filter_keywords id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_filter_keywords ALTER COLUMN id SET DEFAULT nextval('public.custom_filter_keywords_id_seq'::regclass);


--
-- Name: custom_filter_statuses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_filter_statuses ALTER COLUMN id SET DEFAULT nextval('public.custom_filter_statuses_id_seq'::regclass);


--
-- Name: custom_filters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_filters ALTER COLUMN id SET DEFAULT nextval('public.custom_filters_id_seq'::regclass);


--
-- Name: deprecated_preview_cards id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deprecated_preview_cards ALTER COLUMN id SET DEFAULT nextval('public.deprecated_preview_cards_id_seq'::regclass);


--
-- Name: devices id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices ALTER COLUMN id SET DEFAULT nextval('public.devices_id_seq'::regclass);


--
-- Name: domain_allows id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domain_allows ALTER COLUMN id SET DEFAULT nextval('public.domain_allows_id_seq'::regclass);


--
-- Name: domain_blocks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domain_blocks ALTER COLUMN id SET DEFAULT nextval('public.domain_blocks_id_seq'::regclass);


--
-- Name: email_domain_blocks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_domain_blocks ALTER COLUMN id SET DEFAULT nextval('public.email_domain_blocks_id_seq'::regclass);


--
-- Name: favourites id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favourites ALTER COLUMN id SET DEFAULT nextval('public.favourites_id_seq'::regclass);


--
-- Name: featured_tags id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.featured_tags ALTER COLUMN id SET DEFAULT nextval('public.featured_tags_id_seq'::regclass);


--
-- Name: follow_recommendation_mutes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follow_recommendation_mutes ALTER COLUMN id SET DEFAULT nextval('public.follow_recommendation_mutes_id_seq'::regclass);


--
-- Name: follow_recommendation_suppressions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follow_recommendation_suppressions ALTER COLUMN id SET DEFAULT nextval('public.follow_recommendation_suppressions_id_seq'::regclass);


--
-- Name: follow_requests id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follow_requests ALTER COLUMN id SET DEFAULT nextval('public.follow_requests_id_seq'::regclass);


--
-- Name: follows id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follows ALTER COLUMN id SET DEFAULT nextval('public.follows_id_seq'::regclass);


--
-- Name: generated_annual_reports id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generated_annual_reports ALTER COLUMN id SET DEFAULT nextval('public.generated_annual_reports_id_seq'::regclass);


--
-- Name: identities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.identities ALTER COLUMN id SET DEFAULT nextval('public.identities_id_seq'::regclass);


--
-- Name: imports id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.imports ALTER COLUMN id SET DEFAULT nextval('public.imports_id_seq'::regclass);


--
-- Name: invites id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invites ALTER COLUMN id SET DEFAULT nextval('public.invites_id_seq'::regclass);


--
-- Name: ip_blocks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ip_blocks ALTER COLUMN id SET DEFAULT nextval('public.ip_blocks_id_seq'::regclass);


--
-- Name: list_accounts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_accounts ALTER COLUMN id SET DEFAULT nextval('public.list_accounts_id_seq'::regclass);


--
-- Name: lists id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lists ALTER COLUMN id SET DEFAULT nextval('public.lists_id_seq'::regclass);


--
-- Name: login_activities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_activities ALTER COLUMN id SET DEFAULT nextval('public.login_activities_id_seq'::regclass);


--
-- Name: markers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.markers ALTER COLUMN id SET DEFAULT nextval('public.markers_id_seq'::regclass);


--
-- Name: mentions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentions ALTER COLUMN id SET DEFAULT nextval('public.mentions_id_seq'::regclass);


--
-- Name: mutes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mutes ALTER COLUMN id SET DEFAULT nextval('public.mutes_id_seq'::regclass);


--
-- Name: notification_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_permissions ALTER COLUMN id SET DEFAULT nextval('public.notification_permissions_id_seq'::regclass);


--
-- Name: notification_policies id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_policies ALTER COLUMN id SET DEFAULT nextval('public.notification_policies_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: oauth_access_grants id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_grants_id_seq'::regclass);


--
-- Name: oauth_access_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_tokens_id_seq'::regclass);


--
-- Name: oauth_applications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_applications ALTER COLUMN id SET DEFAULT nextval('public.oauth_applications_id_seq'::regclass);


--
-- Name: one_time_keys id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.one_time_keys ALTER COLUMN id SET DEFAULT nextval('public.one_time_keys_id_seq'::regclass);


--
-- Name: pghero_space_stats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pghero_space_stats ALTER COLUMN id SET DEFAULT nextval('public.pghero_space_stats_id_seq'::regclass);


--
-- Name: poll_votes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.poll_votes ALTER COLUMN id SET DEFAULT nextval('public.poll_votes_id_seq'::regclass);


--
-- Name: polls id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.polls ALTER COLUMN id SET DEFAULT nextval('public.polls_id_seq'::regclass);


--
-- Name: preview_card_providers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preview_card_providers ALTER COLUMN id SET DEFAULT nextval('public.preview_card_providers_id_seq'::regclass);


--
-- Name: preview_card_trends id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preview_card_trends ALTER COLUMN id SET DEFAULT nextval('public.preview_card_trends_id_seq'::regclass);


--
-- Name: preview_cards id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preview_cards ALTER COLUMN id SET DEFAULT nextval('public.preview_cards_id_seq'::regclass);


--
-- Name: relationship_severance_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relationship_severance_events ALTER COLUMN id SET DEFAULT nextval('public.relationship_severance_events_id_seq'::regclass);


--
-- Name: relays id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relays ALTER COLUMN id SET DEFAULT nextval('public.relays_id_seq'::regclass);


--
-- Name: report_notes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.report_notes ALTER COLUMN id SET DEFAULT nextval('public.report_notes_id_seq'::regclass);


--
-- Name: reports id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reports ALTER COLUMN id SET DEFAULT nextval('public.reports_id_seq'::regclass);


--
-- Name: rules id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rules ALTER COLUMN id SET DEFAULT nextval('public.rules_id_seq'::regclass);


--
-- Name: scheduled_statuses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scheduled_statuses ALTER COLUMN id SET DEFAULT nextval('public.scheduled_statuses_id_seq'::regclass);


--
-- Name: session_activations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_activations ALTER COLUMN id SET DEFAULT nextval('public.session_activations_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: severed_relationships id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.severed_relationships ALTER COLUMN id SET DEFAULT nextval('public.severed_relationships_id_seq'::regclass);


--
-- Name: site_uploads id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_uploads ALTER COLUMN id SET DEFAULT nextval('public.site_uploads_id_seq'::regclass);


--
-- Name: software_updates id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.software_updates ALTER COLUMN id SET DEFAULT nextval('public.software_updates_id_seq'::regclass);


--
-- Name: status_edits id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_edits ALTER COLUMN id SET DEFAULT nextval('public.status_edits_id_seq'::regclass);


--
-- Name: status_pins id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_pins ALTER COLUMN id SET DEFAULT nextval('public.status_pins_id_seq'::regclass);


--
-- Name: status_stats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_stats ALTER COLUMN id SET DEFAULT nextval('public.status_stats_id_seq'::regclass);


--
-- Name: status_trends id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_trends ALTER COLUMN id SET DEFAULT nextval('public.status_trends_id_seq'::regclass);


--
-- Name: system_keys id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_keys ALTER COLUMN id SET DEFAULT nextval('public.system_keys_id_seq'::regclass);


--
-- Name: tag_follows id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag_follows ALTER COLUMN id SET DEFAULT nextval('public.tag_follows_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: tombstones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tombstones ALTER COLUMN id SET DEFAULT nextval('public.tombstones_id_seq'::regclass);


--
-- Name: unavailable_domains id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unavailable_domains ALTER COLUMN id SET DEFAULT nextval('public.unavailable_domains_id_seq'::regclass);


--
-- Name: user_invite_requests id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_invite_requests ALTER COLUMN id SET DEFAULT nextval('public.user_invite_requests_id_seq'::regclass);


--
-- Name: user_roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles ALTER COLUMN id SET DEFAULT nextval('public.user_roles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: web_push_subscriptions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.web_push_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.web_push_subscriptions_id_seq'::regclass);


--
-- Name: web_settings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.web_settings ALTER COLUMN id SET DEFAULT nextval('public.web_settings_id_seq'::regclass);


--
-- Name: webauthn_credentials id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.webauthn_credentials ALTER COLUMN id SET DEFAULT nextval('public.webauthn_credentials_id_seq'::regclass);


--
-- Name: webhooks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.webhooks ALTER COLUMN id SET DEFAULT nextval('public.webhooks_id_seq'::regclass);


--
-- Data for Name: account_aliases; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: account_conversations; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: account_deletion_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: account_domain_blocks; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: account_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: account_moderation_notes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: account_notes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: account_pins; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: account_relationship_severance_events; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: account_stats; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.account_stats (id, account_id, statuses_count, following_count, followers_count, created_at, updated_at, last_status_at) VALUES (1, 112376043092649131, 0, 0, 0, '2024-05-04 09:35:09.673852', '2024-05-04 09:35:09.673852', '2024-05-04 09:35:09.673852');


--
-- Data for Name: account_statuses_cleanup_policies; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: account_warning_presets; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: account_warnings; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.accounts (id, username, domain, private_key, public_key, created_at, updated_at, note, display_name, uri, url, avatar_file_name, avatar_content_type, avatar_file_size, avatar_updated_at, header_file_name, header_content_type, header_file_size, header_updated_at, avatar_remote_url, locked, header_remote_url, last_webfingered_at, inbox_url, outbox_url, shared_inbox_url, followers_url, protocol, memorial, moved_to_account_id, featured_collection_url, fields, actor_type, discoverable, also_known_as, silenced_at, suspended_at, hide_collections, avatar_storage_schema_version, header_storage_schema_version, devices_url, suspension_origin, sensitized_at, trendable, reviewed_at, requested_review_at, indexable) VALUES (-99, 'mastodon.internal', NULL, '-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAurex3vT1UIy5/BGfrRu05ATq+mDhCHVdfLE2R0dSAH+afwn2
/4XGH5L6DpHKQk4/4u9NBaUY30pHs0y+eZ8R7XiS8HSdLiU66K0Bfi0baD8TYj0X
WQOZ6ug7Vgkmdt2HZneMP0fv4aZ4cOIgN3Ica+W6kAsdQrnme4s59d8Xyzdlb4Ut
LcX9Cgdx/kifJUpwn37Ew/5SA1TbQQEIAmNcj1FXYb8+Re48LINpfsw2k/QfndNF
vDs6XVL36cDzunl3sfoa3TeC7JiPDOdav6WgyvxQOiffEFXyLbf/qN1S1Q63HPNS
7YPQE1W8aEJLKIanBKJShE74Yqrcwaxh+wnTtwIDAQABAoIBAGOyS84he47r5S6b
dmfnAFoz6geQjPeIO0emE7ZRdY6Ak8y7VGAxXI1lXBFFdPqcb25LmhOmiLZJIimx
k467CcaDd+neSkLmbCLqpX5qtVSfQUlWF05XJusP3wbcUeZr+K0UrhTn40TYLz0O
8GbKjjRqcIgS9ye2vUNAHs2StlCxtHo574uCHUbTXluVMqOXTQKl7KPEd53BY7F6
4dOTro9Q1IGJe0WlNK5n5ptZgVd9BlPzMRehS3D2lx+CxungdjP7z4jXpMyG/4iZ
2HGMLEQdGvf7JGAdt8QgpgCMi1MoSghN+x0Epxgo9uTrlI+uDkbEf2JBcnJBE8ZR
B07v9KkCgYEA6gXye8viocl1LN61erWldU8KDA93R+lh4/DqPR2ONRTxLVZAbDW4
TJgCQhBU15nPEcZhM+LwYOLPiUrwJ0hEzg76iAVfPrOZWt6pPbBNMft5zCzMjm4N
X4QHxfpYzWQ5tris0zEa4QRjIceUDCEO616HTK2UfEGXZLpteDSSIAsCgYEAzEB9
+BQaLMh06RswRpKsNmsorfQKw5cuFrLIFmV4Ey8lGwIjff1kHietsTUJbqPjro+7
mZnkKkd04WV7moamhj1niK8hn8cqUolfRKZf45M9br+CTijIaL6m/A1p3vN8oDqp
zqTGQLBax6ZNkKgJXFGRALZV5x/MnZlfOOcUSoUCgYAeKbwSRrokPjITIXVkpor3
7sMNwOSP6T3Lwl5+mBOfNd7MCCTvjZD+lk0cNLyquVFeKiKXLHXtFu7G9Fi1x3PO
11FlPMQE8eMfOjm4EMQyYAZX0aJf7UFeAUd7NgRCHNvveCgWZGrhe85HKVEkqxIg
NiPcNzc/OLkJq5m2d5gp9wKBgFgf6znB0plH08lPhcCtP8gq695B0PMaozP/5vxi
wy/jw2qnvZB6Z1vrWrF+ZJdr9qw2L4bSMvNa6T7mfjHprqd0jtsWVLePQt9hjc0c
y3pw6KyDzEDUr8MhnwJY9zjObRLkvKb/yNnYPRKu2gBzv7YpKxrXkLCrs6i7p63x
ZXvRAoGBANK57Aoi94jCtboVgTctR15uMJDe2ii5HzPh9DxnLCZeNX8UeWUGO5gz
cR/er3ah8W5xWtRKdm6Bwvky2fBhvzSS8MMhC/jJ4I6Iz1L/CqlS5+eqcgoXdN3k
9exuMQlhxKqFvL8WOrzP4VqaEHpLt0KEbMve9QIAGBqPVkwxfihP
-----END RSA PRIVATE KEY-----
', '-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAurex3vT1UIy5/BGfrRu0
5ATq+mDhCHVdfLE2R0dSAH+afwn2/4XGH5L6DpHKQk4/4u9NBaUY30pHs0y+eZ8R
7XiS8HSdLiU66K0Bfi0baD8TYj0XWQOZ6ug7Vgkmdt2HZneMP0fv4aZ4cOIgN3Ic
a+W6kAsdQrnme4s59d8Xyzdlb4UtLcX9Cgdx/kifJUpwn37Ew/5SA1TbQQEIAmNc
j1FXYb8+Re48LINpfsw2k/QfndNFvDs6XVL36cDzunl3sfoa3TeC7JiPDOdav6Wg
yvxQOiffEFXyLbf/qN1S1Q63HPNS7YPQE1W8aEJLKIanBKJShE74Yqrcwaxh+wnT
twIDAQAB
-----END PUBLIC KEY-----
', '2024-05-03 07:45:37.102426', '2024-05-03 07:45:37.102426', '', '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, true, '', NULL, '', '', '', '', 0, false, NULL, NULL, NULL, 'Application', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false);
INSERT INTO public.accounts (id, username, domain, private_key, public_key, created_at, updated_at, note, display_name, uri, url, avatar_file_name, avatar_content_type, avatar_file_size, avatar_updated_at, header_file_name, header_content_type, header_file_size, header_updated_at, avatar_remote_url, locked, header_remote_url, last_webfingered_at, inbox_url, outbox_url, shared_inbox_url, followers_url, protocol, memorial, moved_to_account_id, featured_collection_url, fields, actor_type, discoverable, also_known_as, silenced_at, suspended_at, hide_collections, avatar_storage_schema_version, header_storage_schema_version, devices_url, suspension_origin, sensitized_at, trendable, reviewed_at, requested_review_at, indexable) VALUES (112376043092649131, 'admin', NULL, '-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAw1M5JDDVF6HXKNAAr2QxorfdaIW6lbGvc96KFs43NBuFqrPC
LmCruPD0qR4+To4UOhQ+mxb8nby47yfypx+qtoHim3hMKE8IVdkXueXIQ9lphpOx
rnZAXD8V5ZapLSP5N7qBnW+/Vg458hBWu4DrQ+Uk/vXwQUSbvQWACLqfoLpEVsER
tecM5+OZyzy6dzSTGIEGyxRJDeZrLg7r8RhMqlibedic1pv1KQRFmN1R8Fvi1A+p
J/FRmjeSYNNGXXjUkSWzWnp7/F4r87TAcwkLY5qXlPqtw7HPIcWXAmnGOrgTKn+I
lm8sNRKkacJCwgJ0OFd49qFZCncZgEtVVHSDAQIDAQABAoIBAE54a9dvStzApyj9
T5km/o3poiiwuQIUrXE2cXGyDRmBCRVIPHXXXoXhP9mFjfCPQe8HXRN/i6NvQzjJ
asHbhgDmc3yUOrxi6+1ZVx/XAbrIaI2pXlPBrB+jNI/VFEhPUHskEZiHYW4YLw1h
pQaVR28yaseHVKtT/eFViVd4alLubOO3OMcWKQlvXvEE2orb3V3zHRvfwghpVWUS
LcVqsqVfqLJj5ryix2AVd5574uI4fzcp0A8n53fucymE3m/Pa7+w5hSMWCSv3L38
FeGi8vVVBtyhEKlk0mpFThtWNId4A3fme5GS8d/7+Cgadz55fyMDpVO0azk4nLOC
y9aB38ECgYEA/8dlM3VmbYsER/3TPirpO40x0vX8GceJPbnGx9XJPH6IbxsnWc/W
ZRwdpm6nFaYLoydv67TUT+pqykzrXBcl6n8Lj3oV51aBl8qNudrog+ihGHyzIB5K
VBL5q9fcUbu4/P3Ac0sPydrK7fnj5BLuPRDf+l7CIw93m9Vc+KKmavkCgYEAw35z
A51qyvwQpCnDpH8GjHgLD/HJ550jpdKPsewbtvrzmA2OkYkQ9KWpjcBSekOwNjAX
CmEYwuCA+q1bGviguRgiRVlQsK3pjhDbJdjYhhPXdDVSu2iK4mnlKnea8Ty1akfV
45lY1g73Y3qHYipU7TRzAkKkOyqYIogeFGtukkkCgYBu8gOApZzPSSyLOZtGbQCL
1zvUYOSAHh/2iT2i8qV+OvhdES8pctBxPRfTWE3bQxHrLDEM0XwCShEWPPUeFeBZ
bdAK5Q7ZMJm3yKFfC4gtp1sxLu3XsavV+gEYO+KSBVZBTqQKnnVzvhal0O27wUZb
cJVmmXGmGZBtJMhWBN8gqQKBgHeMQy9Ju33H6TFKrO5SE6Ig4rrsZEj0ClGkUuU9
+rDKA97PI4kSJcFF8UrS+lz0ObTZca2SNP8vJRCmpFj5A+hMvuBjvvlcUL/kxO7/
DWHojk/tL9uVEaFlmpN+ssylEFee+EiHhRDZ9CTsUBASzP6FnXMbZ60a3g/351Ub
YXGpAoGANsylP5WaQSqg93aRqosJSAOP9Mppy2+wPF1ImKmHmI1LqTHhpKtu3Hod
S5s2XjN58vL9I+e/wWgCUHrQsfSFHNtU8obC26+8hugBERFq1JHDd7WtElSQmqZq
gbXstMxicdLV8VtjoAbfZmL49vup9EzLl7rjKC+aPJNfsZX7Byw=
-----END RSA PRIVATE KEY-----
', '-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw1M5JDDVF6HXKNAAr2Qx
orfdaIW6lbGvc96KFs43NBuFqrPCLmCruPD0qR4+To4UOhQ+mxb8nby47yfypx+q
toHim3hMKE8IVdkXueXIQ9lphpOxrnZAXD8V5ZapLSP5N7qBnW+/Vg458hBWu4Dr
Q+Uk/vXwQUSbvQWACLqfoLpEVsERtecM5+OZyzy6dzSTGIEGyxRJDeZrLg7r8RhM
qlibedic1pv1KQRFmN1R8Fvi1A+pJ/FRmjeSYNNGXXjUkSWzWnp7/F4r87TAcwkL
Y5qXlPqtw7HPIcWXAmnGOrgTKn+Ilm8sNRKkacJCwgJ0OFd49qFZCncZgEtVVHSD
AQIDAQAB
-----END PUBLIC KEY-----
', '2024-05-03 07:45:37.199998', '2024-05-04 09:35:47.258855', '', '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, '', NULL, '', '', '', '', 0, false, NULL, NULL, NULL, NULL, true, NULL, NULL, NULL, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, true);


--
-- Data for Name: accounts_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: admin_action_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: announcement_mutes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: announcement_reactions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: announcements; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: appeals; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ar_internal_metadata (key, value, created_at, updated_at) VALUES ('environment', 'development', '2024-05-02 18:15:22.038231', '2024-05-02 18:15:22.038236');
INSERT INTO public.ar_internal_metadata (key, value, created_at, updated_at) VALUES ('schema_sha1', 'a6e0fcf6ff3b1dbc77fc37f36aa49acca7c81751', '2024-05-02 18:17:29.021297', '2024-05-02 18:17:29.021308');


--
-- Data for Name: backups; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: blocks; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: bookmarks; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: bulk_import_rows; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: bulk_imports; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: canonical_email_blocks; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: conversation_mutes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.conversations (id, uri, created_at, updated_at) VALUES (3, NULL, '2024-05-04 09:35:09.65469', '2024-05-04 09:35:09.65469');


--
-- Data for Name: custom_emoji_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: custom_emojis; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: custom_filter_keywords; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: custom_filter_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: custom_filters; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: deprecated_preview_cards; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: domain_allows; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: domain_blocks; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: email_domain_blocks; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: encrypted_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: favourites; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: featured_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: follow_recommendation_mutes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: follow_recommendation_suppressions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: follow_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: follows; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: generated_annual_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: identities; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: imports; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: invites; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: ip_blocks; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: list_accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: lists; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: login_activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.login_activities (id, user_id, authentication_method, provider, success, failure_reason, ip, user_agent, created_at) VALUES (1, 1, 'password', NULL, true, NULL, '172.21.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36', '2024-05-04 09:34:32.032205');


--
-- Data for Name: markers; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: media_attachments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: mentions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: mutes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: notification_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: notification_policies; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: notification_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: oauth_access_grants; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: oauth_access_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.oauth_access_tokens (id, token, refresh_token, expires_in, revoked_at, created_at, scopes, application_id, resource_owner_id, last_used_at, last_used_ip) VALUES (1, 'RjmrKc-lDP-SIZVD0xJKLOoT20YquP2Hn2F_xaMJyjo', NULL, NULL, NULL, '2024-05-04 09:34:31.51955', 'read write follow', 1, 1, '2024-05-04 09:35:05.439491', '172.21.0.1');


--
-- Data for Name: oauth_applications; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.oauth_applications (id, name, uid, secret, redirect_uri, scopes, created_at, updated_at, superapp, website, owner_type, owner_id, confidential) VALUES (1, 'Web', 'dMHkQsTyFP_VpdyR0Qd69lhvNYU1RNm_1SpAiTBY1Tc', 'k9wafpuBq0WJWeujTo_Dko2CFKvNkndFh4MDHKgfVkg', 'urn:ietf:wg:oauth:2.0:oob', 'read write follow push', '2024-05-03 07:45:36.935276', '2024-05-03 07:45:36.935276', true, NULL, NULL, NULL, true);


--
-- Data for Name: one_time_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: pghero_space_stats; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: poll_votes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: polls; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: preview_card_providers; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: preview_card_trends; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: preview_cards; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: preview_cards_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: relationship_severance_events; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: relays; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: report_notes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: reports; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: rules; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: scheduled_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.schema_migrations (version) VALUES ('20160220174730');
INSERT INTO public.schema_migrations (version) VALUES ('20160220211917');
INSERT INTO public.schema_migrations (version) VALUES ('20160221003140');
INSERT INTO public.schema_migrations (version) VALUES ('20160221003621');
INSERT INTO public.schema_migrations (version) VALUES ('20160222122600');
INSERT INTO public.schema_migrations (version) VALUES ('20160222143943');
INSERT INTO public.schema_migrations (version) VALUES ('20160223162837');
INSERT INTO public.schema_migrations (version) VALUES ('20160223164502');
INSERT INTO public.schema_migrations (version) VALUES ('20160223165723');
INSERT INTO public.schema_migrations (version) VALUES ('20160223165855');
INSERT INTO public.schema_migrations (version) VALUES ('20160223171800');
INSERT INTO public.schema_migrations (version) VALUES ('20160224223247');
INSERT INTO public.schema_migrations (version) VALUES ('20160227230233');
INSERT INTO public.schema_migrations (version) VALUES ('20160305115639');
INSERT INTO public.schema_migrations (version) VALUES ('20160306172223');
INSERT INTO public.schema_migrations (version) VALUES ('20160312193225');
INSERT INTO public.schema_migrations (version) VALUES ('20160314164231');
INSERT INTO public.schema_migrations (version) VALUES ('20160316103650');
INSERT INTO public.schema_migrations (version) VALUES ('20160322193748');
INSERT INTO public.schema_migrations (version) VALUES ('20160325130944');
INSERT INTO public.schema_migrations (version) VALUES ('20160826155805');
INSERT INTO public.schema_migrations (version) VALUES ('20160905150353');
INSERT INTO public.schema_migrations (version) VALUES ('20160919221059');
INSERT INTO public.schema_migrations (version) VALUES ('20160920003904');
INSERT INTO public.schema_migrations (version) VALUES ('20160926213048');
INSERT INTO public.schema_migrations (version) VALUES ('20161003142332');
INSERT INTO public.schema_migrations (version) VALUES ('20161003145426');
INSERT INTO public.schema_migrations (version) VALUES ('20161006213403');
INSERT INTO public.schema_migrations (version) VALUES ('20161009120834');
INSERT INTO public.schema_migrations (version) VALUES ('20161027172456');
INSERT INTO public.schema_migrations (version) VALUES ('20161104173623');
INSERT INTO public.schema_migrations (version) VALUES ('20161105130633');
INSERT INTO public.schema_migrations (version) VALUES ('20161116162355');
INSERT INTO public.schema_migrations (version) VALUES ('20161119211120');
INSERT INTO public.schema_migrations (version) VALUES ('20161122163057');
INSERT INTO public.schema_migrations (version) VALUES ('20161123093447');
INSERT INTO public.schema_migrations (version) VALUES ('20161128103007');
INSERT INTO public.schema_migrations (version) VALUES ('20161130142058');
INSERT INTO public.schema_migrations (version) VALUES ('20161130185319');
INSERT INTO public.schema_migrations (version) VALUES ('20161202132159');
INSERT INTO public.schema_migrations (version) VALUES ('20161203164520');
INSERT INTO public.schema_migrations (version) VALUES ('20161205214545');
INSERT INTO public.schema_migrations (version) VALUES ('20161221152630');
INSERT INTO public.schema_migrations (version) VALUES ('20161222201034');
INSERT INTO public.schema_migrations (version) VALUES ('20161222204147');
INSERT INTO public.schema_migrations (version) VALUES ('20170105224407');
INSERT INTO public.schema_migrations (version) VALUES ('20170109120109');
INSERT INTO public.schema_migrations (version) VALUES ('20170112154826');
INSERT INTO public.schema_migrations (version) VALUES ('20170114194937');
INSERT INTO public.schema_migrations (version) VALUES ('20170114203041');
INSERT INTO public.schema_migrations (version) VALUES ('20170119214911');
INSERT INTO public.schema_migrations (version) VALUES ('20170123162658');
INSERT INTO public.schema_migrations (version) VALUES ('20170123203248');
INSERT INTO public.schema_migrations (version) VALUES ('20170125145934');
INSERT INTO public.schema_migrations (version) VALUES ('20170127165745');
INSERT INTO public.schema_migrations (version) VALUES ('20170205175257');
INSERT INTO public.schema_migrations (version) VALUES ('20170209184350');
INSERT INTO public.schema_migrations (version) VALUES ('20170214110202');
INSERT INTO public.schema_migrations (version) VALUES ('20170217012631');
INSERT INTO public.schema_migrations (version) VALUES ('20170301222600');
INSERT INTO public.schema_migrations (version) VALUES ('20170303212857');
INSERT INTO public.schema_migrations (version) VALUES ('20170304202101');
INSERT INTO public.schema_migrations (version) VALUES ('20170317193015');
INSERT INTO public.schema_migrations (version) VALUES ('20170318214217');
INSERT INTO public.schema_migrations (version) VALUES ('20170322021028');
INSERT INTO public.schema_migrations (version) VALUES ('20170322143850');
INSERT INTO public.schema_migrations (version) VALUES ('20170322162804');
INSERT INTO public.schema_migrations (version) VALUES ('20170330021336');
INSERT INTO public.schema_migrations (version) VALUES ('20170330163835');
INSERT INTO public.schema_migrations (version) VALUES ('20170330164118');
INSERT INTO public.schema_migrations (version) VALUES ('20170403172249');
INSERT INTO public.schema_migrations (version) VALUES ('20170405112956');
INSERT INTO public.schema_migrations (version) VALUES ('20170406215816');
INSERT INTO public.schema_migrations (version) VALUES ('20170409170753');
INSERT INTO public.schema_migrations (version) VALUES ('20170414080609');
INSERT INTO public.schema_migrations (version) VALUES ('20170414132105');
INSERT INTO public.schema_migrations (version) VALUES ('20170418160728');
INSERT INTO public.schema_migrations (version) VALUES ('20170423005413');
INSERT INTO public.schema_migrations (version) VALUES ('20170424003227');
INSERT INTO public.schema_migrations (version) VALUES ('20170424112722');
INSERT INTO public.schema_migrations (version) VALUES ('20170425131920');
INSERT INTO public.schema_migrations (version) VALUES ('20170425202925');
INSERT INTO public.schema_migrations (version) VALUES ('20170427011934');
INSERT INTO public.schema_migrations (version) VALUES ('20170506235850');
INSERT INTO public.schema_migrations (version) VALUES ('20170507000211');
INSERT INTO public.schema_migrations (version) VALUES ('20170507141759');
INSERT INTO public.schema_migrations (version) VALUES ('20170508230434');
INSERT INTO public.schema_migrations (version) VALUES ('20170516072309');
INSERT INTO public.schema_migrations (version) VALUES ('20170520145338');
INSERT INTO public.schema_migrations (version) VALUES ('20170601210557');
INSERT INTO public.schema_migrations (version) VALUES ('20170604144747');
INSERT INTO public.schema_migrations (version) VALUES ('20170606113804');
INSERT INTO public.schema_migrations (version) VALUES ('20170609145826');
INSERT INTO public.schema_migrations (version) VALUES ('20170610000000');
INSERT INTO public.schema_migrations (version) VALUES ('20170623152212');
INSERT INTO public.schema_migrations (version) VALUES ('20170624134742');
INSERT INTO public.schema_migrations (version) VALUES ('20170625140443');
INSERT INTO public.schema_migrations (version) VALUES ('20170711225116');
INSERT INTO public.schema_migrations (version) VALUES ('20170713112503');
INSERT INTO public.schema_migrations (version) VALUES ('20170713175513');
INSERT INTO public.schema_migrations (version) VALUES ('20170713190709');
INSERT INTO public.schema_migrations (version) VALUES ('20170714184731');
INSERT INTO public.schema_migrations (version) VALUES ('20170716191202');
INSERT INTO public.schema_migrations (version) VALUES ('20170718211102');
INSERT INTO public.schema_migrations (version) VALUES ('20170720000000');
INSERT INTO public.schema_migrations (version) VALUES ('20170823162448');
INSERT INTO public.schema_migrations (version) VALUES ('20170824103029');
INSERT INTO public.schema_migrations (version) VALUES ('20170829215220');
INSERT INTO public.schema_migrations (version) VALUES ('20170901141119');
INSERT INTO public.schema_migrations (version) VALUES ('20170901142658');
INSERT INTO public.schema_migrations (version) VALUES ('20170905044538');
INSERT INTO public.schema_migrations (version) VALUES ('20170905165803');
INSERT INTO public.schema_migrations (version) VALUES ('20170913000752');
INSERT INTO public.schema_migrations (version) VALUES ('20170917153509');
INSERT INTO public.schema_migrations (version) VALUES ('20170918125918');
INSERT INTO public.schema_migrations (version) VALUES ('20170920024819');
INSERT INTO public.schema_migrations (version) VALUES ('20170920032311');
INSERT INTO public.schema_migrations (version) VALUES ('20170924022025');
INSERT INTO public.schema_migrations (version) VALUES ('20170927215609');
INSERT INTO public.schema_migrations (version) VALUES ('20170928082043');
INSERT INTO public.schema_migrations (version) VALUES ('20171005102658');
INSERT INTO public.schema_migrations (version) VALUES ('20171005171936');
INSERT INTO public.schema_migrations (version) VALUES ('20171006142024');
INSERT INTO public.schema_migrations (version) VALUES ('20171010023049');
INSERT INTO public.schema_migrations (version) VALUES ('20171010025614');
INSERT INTO public.schema_migrations (version) VALUES ('20171020084748');
INSERT INTO public.schema_migrations (version) VALUES ('20171028221157');
INSERT INTO public.schema_migrations (version) VALUES ('20171107143332');
INSERT INTO public.schema_migrations (version) VALUES ('20171107143624');
INSERT INTO public.schema_migrations (version) VALUES ('20171109012327');
INSERT INTO public.schema_migrations (version) VALUES ('20171114080328');
INSERT INTO public.schema_migrations (version) VALUES ('20171114231651');
INSERT INTO public.schema_migrations (version) VALUES ('20171116161857');
INSERT INTO public.schema_migrations (version) VALUES ('20171118012443');
INSERT INTO public.schema_migrations (version) VALUES ('20171119172437');
INSERT INTO public.schema_migrations (version) VALUES ('20171122120436');
INSERT INTO public.schema_migrations (version) VALUES ('20171125024930');
INSERT INTO public.schema_migrations (version) VALUES ('20171125031751');
INSERT INTO public.schema_migrations (version) VALUES ('20171125185353');
INSERT INTO public.schema_migrations (version) VALUES ('20171125190735');
INSERT INTO public.schema_migrations (version) VALUES ('20171129172043');
INSERT INTO public.schema_migrations (version) VALUES ('20171130000000');
INSERT INTO public.schema_migrations (version) VALUES ('20171201000000');
INSERT INTO public.schema_migrations (version) VALUES ('20171212195226');
INSERT INTO public.schema_migrations (version) VALUES ('20171226094803');
INSERT INTO public.schema_migrations (version) VALUES ('20180106000232');
INSERT INTO public.schema_migrations (version) VALUES ('20180109143959');
INSERT INTO public.schema_migrations (version) VALUES ('20180204034416');
INSERT INTO public.schema_migrations (version) VALUES ('20180206000000');
INSERT INTO public.schema_migrations (version) VALUES ('20180211015820');
INSERT INTO public.schema_migrations (version) VALUES ('20180304013859');
INSERT INTO public.schema_migrations (version) VALUES ('20180310000000');
INSERT INTO public.schema_migrations (version) VALUES ('20180402031200');
INSERT INTO public.schema_migrations (version) VALUES ('20180402040909');
INSERT INTO public.schema_migrations (version) VALUES ('20180410204633');
INSERT INTO public.schema_migrations (version) VALUES ('20180416210259');
INSERT INTO public.schema_migrations (version) VALUES ('20180506221944');
INSERT INTO public.schema_migrations (version) VALUES ('20180510214435');
INSERT INTO public.schema_migrations (version) VALUES ('20180510230049');
INSERT INTO public.schema_migrations (version) VALUES ('20180514130000');
INSERT INTO public.schema_migrations (version) VALUES ('20180514140000');
INSERT INTO public.schema_migrations (version) VALUES ('20180528141303');
INSERT INTO public.schema_migrations (version) VALUES ('20180608213548');
INSERT INTO public.schema_migrations (version) VALUES ('20180609104432');
INSERT INTO public.schema_migrations (version) VALUES ('20180615122121');
INSERT INTO public.schema_migrations (version) VALUES ('20180616192031');
INSERT INTO public.schema_migrations (version) VALUES ('20180617162849');
INSERT INTO public.schema_migrations (version) VALUES ('20180628181026');
INSERT INTO public.schema_migrations (version) VALUES ('20180707154237');
INSERT INTO public.schema_migrations (version) VALUES ('20180711152640');
INSERT INTO public.schema_migrations (version) VALUES ('20180808175627');
INSERT INTO public.schema_migrations (version) VALUES ('20180812123222');
INSERT INTO public.schema_migrations (version) VALUES ('20180812162710');
INSERT INTO public.schema_migrations (version) VALUES ('20180812173710');
INSERT INTO public.schema_migrations (version) VALUES ('20180813113448');
INSERT INTO public.schema_migrations (version) VALUES ('20180814171349');
INSERT INTO public.schema_migrations (version) VALUES ('20180820232245');
INSERT INTO public.schema_migrations (version) VALUES ('20180831171112');
INSERT INTO public.schema_migrations (version) VALUES ('20180929222014');
INSERT INTO public.schema_migrations (version) VALUES ('20181007025445');
INSERT INTO public.schema_migrations (version) VALUES ('20181010141500');
INSERT INTO public.schema_migrations (version) VALUES ('20181017170937');
INSERT INTO public.schema_migrations (version) VALUES ('20181018205649');
INSERT INTO public.schema_migrations (version) VALUES ('20181024224956');
INSERT INTO public.schema_migrations (version) VALUES ('20181026034033');
INSERT INTO public.schema_migrations (version) VALUES ('20181116165755');
INSERT INTO public.schema_migrations (version) VALUES ('20181116173541');
INSERT INTO public.schema_migrations (version) VALUES ('20181116184611');
INSERT INTO public.schema_migrations (version) VALUES ('20181127130500');
INSERT INTO public.schema_migrations (version) VALUES ('20181127165847');
INSERT INTO public.schema_migrations (version) VALUES ('20181203003808');
INSERT INTO public.schema_migrations (version) VALUES ('20181203021853');
INSERT INTO public.schema_migrations (version) VALUES ('20181204193439');
INSERT INTO public.schema_migrations (version) VALUES ('20181204215309');
INSERT INTO public.schema_migrations (version) VALUES ('20181207011115');
INSERT INTO public.schema_migrations (version) VALUES ('20181213184704');
INSERT INTO public.schema_migrations (version) VALUES ('20181213185533');
INSERT INTO public.schema_migrations (version) VALUES ('20181219235220');
INSERT INTO public.schema_migrations (version) VALUES ('20181226021420');
INSERT INTO public.schema_migrations (version) VALUES ('20190103124649');
INSERT INTO public.schema_migrations (version) VALUES ('20190103124754');
INSERT INTO public.schema_migrations (version) VALUES ('20190117114553');
INSERT INTO public.schema_migrations (version) VALUES ('20190201012802');
INSERT INTO public.schema_migrations (version) VALUES ('20190203180359');
INSERT INTO public.schema_migrations (version) VALUES ('20190225031541');
INSERT INTO public.schema_migrations (version) VALUES ('20190225031625');
INSERT INTO public.schema_migrations (version) VALUES ('20190226003449');
INSERT INTO public.schema_migrations (version) VALUES ('20190304152020');
INSERT INTO public.schema_migrations (version) VALUES ('20190306145741');
INSERT INTO public.schema_migrations (version) VALUES ('20190307234537');
INSERT INTO public.schema_migrations (version) VALUES ('20190314181829');
INSERT INTO public.schema_migrations (version) VALUES ('20190316190352');
INSERT INTO public.schema_migrations (version) VALUES ('20190317135723');
INSERT INTO public.schema_migrations (version) VALUES ('20190403141604');
INSERT INTO public.schema_migrations (version) VALUES ('20190409054914');
INSERT INTO public.schema_migrations (version) VALUES ('20190420025523');
INSERT INTO public.schema_migrations (version) VALUES ('20190509164208');
INSERT INTO public.schema_migrations (version) VALUES ('20190511134027');
INSERT INTO public.schema_migrations (version) VALUES ('20190511152737');
INSERT INTO public.schema_migrations (version) VALUES ('20190519130537');
INSERT INTO public.schema_migrations (version) VALUES ('20190529143559');
INSERT INTO public.schema_migrations (version) VALUES ('20190627222225');
INSERT INTO public.schema_migrations (version) VALUES ('20190627222826');
INSERT INTO public.schema_migrations (version) VALUES ('20190701022101');
INSERT INTO public.schema_migrations (version) VALUES ('20190705002136');
INSERT INTO public.schema_migrations (version) VALUES ('20190706233204');
INSERT INTO public.schema_migrations (version) VALUES ('20190715031050');
INSERT INTO public.schema_migrations (version) VALUES ('20190715164535');
INSERT INTO public.schema_migrations (version) VALUES ('20190726175042');
INSERT INTO public.schema_migrations (version) VALUES ('20190729185330');
INSERT INTO public.schema_migrations (version) VALUES ('20190805123746');
INSERT INTO public.schema_migrations (version) VALUES ('20190807135426');
INSERT INTO public.schema_migrations (version) VALUES ('20190815225426');
INSERT INTO public.schema_migrations (version) VALUES ('20190819134503');
INSERT INTO public.schema_migrations (version) VALUES ('20190820003045');
INSERT INTO public.schema_migrations (version) VALUES ('20190823221802');
INSERT INTO public.schema_migrations (version) VALUES ('20190901035623');
INSERT INTO public.schema_migrations (version) VALUES ('20190901040524');
INSERT INTO public.schema_migrations (version) VALUES ('20190904222339');
INSERT INTO public.schema_migrations (version) VALUES ('20190914202517');
INSERT INTO public.schema_migrations (version) VALUES ('20190915194355');
INSERT INTO public.schema_migrations (version) VALUES ('20190917213523');
INSERT INTO public.schema_migrations (version) VALUES ('20190927124642');
INSERT INTO public.schema_migrations (version) VALUES ('20190927232842');
INSERT INTO public.schema_migrations (version) VALUES ('20191001213028');
INSERT INTO public.schema_migrations (version) VALUES ('20191007013357');
INSERT INTO public.schema_migrations (version) VALUES ('20191031163205');
INSERT INTO public.schema_migrations (version) VALUES ('20191212003415');
INSERT INTO public.schema_migrations (version) VALUES ('20191212163405');
INSERT INTO public.schema_migrations (version) VALUES ('20191218153258');
INSERT INTO public.schema_migrations (version) VALUES ('20200113125135');
INSERT INTO public.schema_migrations (version) VALUES ('20200114113335');
INSERT INTO public.schema_migrations (version) VALUES ('20200119112504');
INSERT INTO public.schema_migrations (version) VALUES ('20200126203551');
INSERT INTO public.schema_migrations (version) VALUES ('20200306035625');
INSERT INTO public.schema_migrations (version) VALUES ('20200309150742');
INSERT INTO public.schema_migrations (version) VALUES ('20200312144258');
INSERT INTO public.schema_migrations (version) VALUES ('20200312162302');
INSERT INTO public.schema_migrations (version) VALUES ('20200312185443');
INSERT INTO public.schema_migrations (version) VALUES ('20200317021758');
INSERT INTO public.schema_migrations (version) VALUES ('20200407201300');
INSERT INTO public.schema_migrations (version) VALUES ('20200407202420');
INSERT INTO public.schema_migrations (version) VALUES ('20200417125749');
INSERT INTO public.schema_migrations (version) VALUES ('20200508212852');
INSERT INTO public.schema_migrations (version) VALUES ('20200510110808');
INSERT INTO public.schema_migrations (version) VALUES ('20200510181721');
INSERT INTO public.schema_migrations (version) VALUES ('20200516180352');
INSERT INTO public.schema_migrations (version) VALUES ('20200516183822');
INSERT INTO public.schema_migrations (version) VALUES ('20200518083523');
INSERT INTO public.schema_migrations (version) VALUES ('20200521180606');
INSERT INTO public.schema_migrations (version) VALUES ('20200529214050');
INSERT INTO public.schema_migrations (version) VALUES ('20200601222558');
INSERT INTO public.schema_migrations (version) VALUES ('20200605155027');
INSERT INTO public.schema_migrations (version) VALUES ('20200608113046');
INSERT INTO public.schema_migrations (version) VALUES ('20200614002136');
INSERT INTO public.schema_migrations (version) VALUES ('20200620164023');
INSERT INTO public.schema_migrations (version) VALUES ('20200622213645');
INSERT INTO public.schema_migrations (version) VALUES ('20200627125810');
INSERT INTO public.schema_migrations (version) VALUES ('20200628133322');
INSERT INTO public.schema_migrations (version) VALUES ('20200630190240');
INSERT INTO public.schema_migrations (version) VALUES ('20200630190544');
INSERT INTO public.schema_migrations (version) VALUES ('20200908193330');
INSERT INTO public.schema_migrations (version) VALUES ('20200917192924');
INSERT INTO public.schema_migrations (version) VALUES ('20200917193034');
INSERT INTO public.schema_migrations (version) VALUES ('20200917193528');
INSERT INTO public.schema_migrations (version) VALUES ('20200917222316');
INSERT INTO public.schema_migrations (version) VALUES ('20200917222734');
INSERT INTO public.schema_migrations (version) VALUES ('20201008202037');
INSERT INTO public.schema_migrations (version) VALUES ('20201008220312');
INSERT INTO public.schema_migrations (version) VALUES ('20201017233919');
INSERT INTO public.schema_migrations (version) VALUES ('20201017234926');
INSERT INTO public.schema_migrations (version) VALUES ('20201206004238');
INSERT INTO public.schema_migrations (version) VALUES ('20201218054746');
INSERT INTO public.schema_migrations (version) VALUES ('20210221045109');
INSERT INTO public.schema_migrations (version) VALUES ('20210306164523');
INSERT INTO public.schema_migrations (version) VALUES ('20210308133107');
INSERT INTO public.schema_migrations (version) VALUES ('20210322164601');
INSERT INTO public.schema_migrations (version) VALUES ('20210323114347');
INSERT INTO public.schema_migrations (version) VALUES ('20210324171613');
INSERT INTO public.schema_migrations (version) VALUES ('20210416200740');
INSERT INTO public.schema_migrations (version) VALUES ('20210421121431');
INSERT INTO public.schema_migrations (version) VALUES ('20210425135952');
INSERT INTO public.schema_migrations (version) VALUES ('20210502233513');
INSERT INTO public.schema_migrations (version) VALUES ('20210505174616');
INSERT INTO public.schema_migrations (version) VALUES ('20210507001928');
INSERT INTO public.schema_migrations (version) VALUES ('20210526193025');
INSERT INTO public.schema_migrations (version) VALUES ('20210609202149');
INSERT INTO public.schema_migrations (version) VALUES ('20210616214135');
INSERT INTO public.schema_migrations (version) VALUES ('20210616214526');
INSERT INTO public.schema_migrations (version) VALUES ('20210621221010');
INSERT INTO public.schema_migrations (version) VALUES ('20210630000137');
INSERT INTO public.schema_migrations (version) VALUES ('20210722120340');
INSERT INTO public.schema_migrations (version) VALUES ('20210808071221');
INSERT INTO public.schema_migrations (version) VALUES ('20210904215403');
INSERT INTO public.schema_migrations (version) VALUES ('20210908220918');
INSERT INTO public.schema_migrations (version) VALUES ('20211031031021');
INSERT INTO public.schema_migrations (version) VALUES ('20211112011713');
INSERT INTO public.schema_migrations (version) VALUES ('20211115032527');
INSERT INTO public.schema_migrations (version) VALUES ('20211123212714');
INSERT INTO public.schema_migrations (version) VALUES ('20211126000907');
INSERT INTO public.schema_migrations (version) VALUES ('20211213040746');
INSERT INTO public.schema_migrations (version) VALUES ('20211231080958');
INSERT INTO public.schema_migrations (version) VALUES ('20220105163928');
INSERT INTO public.schema_migrations (version) VALUES ('20220109213908');
INSERT INTO public.schema_migrations (version) VALUES ('20220115125126');
INSERT INTO public.schema_migrations (version) VALUES ('20220115125341');
INSERT INTO public.schema_migrations (version) VALUES ('20220116202951');
INSERT INTO public.schema_migrations (version) VALUES ('20220118183010');
INSERT INTO public.schema_migrations (version) VALUES ('20220118183123');
INSERT INTO public.schema_migrations (version) VALUES ('20220124141035');
INSERT INTO public.schema_migrations (version) VALUES ('20220202200743');
INSERT INTO public.schema_migrations (version) VALUES ('20220202200926');
INSERT INTO public.schema_migrations (version) VALUES ('20220202201015');
INSERT INTO public.schema_migrations (version) VALUES ('20220210153119');
INSERT INTO public.schema_migrations (version) VALUES ('20220224010024');
INSERT INTO public.schema_migrations (version) VALUES ('20220227041951');
INSERT INTO public.schema_migrations (version) VALUES ('20220302232632');
INSERT INTO public.schema_migrations (version) VALUES ('20220303000827');
INSERT INTO public.schema_migrations (version) VALUES ('20220303203437');
INSERT INTO public.schema_migrations (version) VALUES ('20220304195405');
INSERT INTO public.schema_migrations (version) VALUES ('20220307083603');
INSERT INTO public.schema_migrations (version) VALUES ('20220307094650');
INSERT INTO public.schema_migrations (version) VALUES ('20220309213005');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060545');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060556');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060614');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060626');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060641');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060653');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060706');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060722');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060740');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060750');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060809');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060833');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060854');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060913');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060926');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060939');
INSERT INTO public.schema_migrations (version) VALUES ('20220310060959');
INSERT INTO public.schema_migrations (version) VALUES ('20220316233212');
INSERT INTO public.schema_migrations (version) VALUES ('20220428112511');
INSERT INTO public.schema_migrations (version) VALUES ('20220428112727');
INSERT INTO public.schema_migrations (version) VALUES ('20220428114454');
INSERT INTO public.schema_migrations (version) VALUES ('20220428114902');
INSERT INTO public.schema_migrations (version) VALUES ('20220429101025');
INSERT INTO public.schema_migrations (version) VALUES ('20220429101850');
INSERT INTO public.schema_migrations (version) VALUES ('20220527114923');
INSERT INTO public.schema_migrations (version) VALUES ('20220606044941');
INSERT INTO public.schema_migrations (version) VALUES ('20220611210335');
INSERT INTO public.schema_migrations (version) VALUES ('20220611212541');
INSERT INTO public.schema_migrations (version) VALUES ('20220613110628');
INSERT INTO public.schema_migrations (version) VALUES ('20220613110711');
INSERT INTO public.schema_migrations (version) VALUES ('20220613110802');
INSERT INTO public.schema_migrations (version) VALUES ('20220613110834');
INSERT INTO public.schema_migrations (version) VALUES ('20220613110903');
INSERT INTO public.schema_migrations (version) VALUES ('20220617202502');
INSERT INTO public.schema_migrations (version) VALUES ('20220704024901');
INSERT INTO public.schema_migrations (version) VALUES ('20220710102457');
INSERT INTO public.schema_migrations (version) VALUES ('20220714171049');
INSERT INTO public.schema_migrations (version) VALUES ('20220729171123');
INSERT INTO public.schema_migrations (version) VALUES ('20220808101323');
INSERT INTO public.schema_migrations (version) VALUES ('20220824164433');
INSERT INTO public.schema_migrations (version) VALUES ('20220824164532');
INSERT INTO public.schema_migrations (version) VALUES ('20220824233535');
INSERT INTO public.schema_migrations (version) VALUES ('20220827195229');
INSERT INTO public.schema_migrations (version) VALUES ('20220829192633');
INSERT INTO public.schema_migrations (version) VALUES ('20220829192658');
INSERT INTO public.schema_migrations (version) VALUES ('20221006061337');
INSERT INTO public.schema_migrations (version) VALUES ('20221012181003');
INSERT INTO public.schema_migrations (version) VALUES ('20221021055441');
INSERT INTO public.schema_migrations (version) VALUES ('20221025171544');
INSERT INTO public.schema_migrations (version) VALUES ('20221101190723');
INSERT INTO public.schema_migrations (version) VALUES ('20221104133904');
INSERT INTO public.schema_migrations (version) VALUES ('20221206114142');
INSERT INTO public.schema_migrations (version) VALUES ('20230129023109');
INSERT INTO public.schema_migrations (version) VALUES ('20230215074327');
INSERT INTO public.schema_migrations (version) VALUES ('20230215074423');
INSERT INTO public.schema_migrations (version) VALUES ('20230330135507');
INSERT INTO public.schema_migrations (version) VALUES ('20230330140036');
INSERT INTO public.schema_migrations (version) VALUES ('20230330155710');
INSERT INTO public.schema_migrations (version) VALUES ('20230524190515');
INSERT INTO public.schema_migrations (version) VALUES ('20230524192812');
INSERT INTO public.schema_migrations (version) VALUES ('20230524194155');
INSERT INTO public.schema_migrations (version) VALUES ('20230531153942');
INSERT INTO public.schema_migrations (version) VALUES ('20230531154811');
INSERT INTO public.schema_migrations (version) VALUES ('20230605085710');
INSERT INTO public.schema_migrations (version) VALUES ('20230605085711');
INSERT INTO public.schema_migrations (version) VALUES ('20230630145300');
INSERT INTO public.schema_migrations (version) VALUES ('20230702131023');
INSERT INTO public.schema_migrations (version) VALUES ('20230702151753');
INSERT INTO public.schema_migrations (version) VALUES ('20230724160715');
INSERT INTO public.schema_migrations (version) VALUES ('20230725213448');
INSERT INTO public.schema_migrations (version) VALUES ('20230803082451');
INSERT INTO public.schema_migrations (version) VALUES ('20230803112520');
INSERT INTO public.schema_migrations (version) VALUES ('20230811103651');
INSERT INTO public.schema_migrations (version) VALUES ('20230814223300');
INSERT INTO public.schema_migrations (version) VALUES ('20230818141056');
INSERT INTO public.schema_migrations (version) VALUES ('20230818142253');
INSERT INTO public.schema_migrations (version) VALUES ('20230822081029');
INSERT INTO public.schema_migrations (version) VALUES ('20230904134623');
INSERT INTO public.schema_migrations (version) VALUES ('20230907150100');
INSERT INTO public.schema_migrations (version) VALUES ('20231006183200');
INSERT INTO public.schema_migrations (version) VALUES ('20231211234923');
INSERT INTO public.schema_migrations (version) VALUES ('20231212073317');
INSERT INTO public.schema_migrations (version) VALUES ('20231222100226');
INSERT INTO public.schema_migrations (version) VALUES ('20240109103012');
INSERT INTO public.schema_migrations (version) VALUES ('20240111033014');
INSERT INTO public.schema_migrations (version) VALUES ('20240221195424');
INSERT INTO public.schema_migrations (version) VALUES ('20240221195828');
INSERT INTO public.schema_migrations (version) VALUES ('20240221211359');
INSERT INTO public.schema_migrations (version) VALUES ('20240222193403');
INSERT INTO public.schema_migrations (version) VALUES ('20240222203722');
INSERT INTO public.schema_migrations (version) VALUES ('20240227191620');
INSERT INTO public.schema_migrations (version) VALUES ('20240304090449');
INSERT INTO public.schema_migrations (version) VALUES ('20240310123453');
INSERT INTO public.schema_migrations (version) VALUES ('20240312100644');
INSERT INTO public.schema_migrations (version) VALUES ('20240312105620');
INSERT INTO public.schema_migrations (version) VALUES ('20240320140159');
INSERT INTO public.schema_migrations (version) VALUES ('20240320163441');
INSERT INTO public.schema_migrations (version) VALUES ('20240321160706');
INSERT INTO public.schema_migrations (version) VALUES ('20240322125607');
INSERT INTO public.schema_migrations (version) VALUES ('20240322130318');
INSERT INTO public.schema_migrations (version) VALUES ('20240322161611');


--
-- Data for Name: session_activations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.session_activations (id, session_id, created_at, updated_at, user_agent, ip, access_token_id, user_id, web_push_subscription_id) VALUES (1, 'bf8ef759511d4a39a67767e865cd4ed9', '2024-05-04 09:34:31.484406', '2024-05-04 09:34:31.484406', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36', '172.21.0.1', 1, 1, NULL);


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: severed_relationships; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: site_uploads; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: software_updates; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: status_edits; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: status_pins; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: status_stats; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: status_trends; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--


--
-- Data for Name: statuses_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: system_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: tag_follows; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: tombstones; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: unavailable_domains; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: user_invite_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.user_roles (id, name, color, "position", permissions, highlighted, created_at, updated_at) VALUES (-99, '', '', -1, 65536, false, '2024-05-03 07:45:37.170749', '2024-05-03 07:45:37.170749');
INSERT INTO public.user_roles (id, name, color, "position", permissions, highlighted, created_at, updated_at) VALUES (1, 'Moderator', '', 10, 1308, true, '2024-05-03 07:45:37.178653', '2024-05-03 07:45:37.178653');
INSERT INTO public.user_roles (id, name, color, "position", permissions, highlighted, created_at, updated_at) VALUES (2, 'Admin', '', 100, 983036, true, '2024-05-03 07:45:37.185581', '2024-05-03 07:45:37.185581');
INSERT INTO public.user_roles (id, name, color, "position", permissions, highlighted, created_at, updated_at) VALUES (3, 'Owner', '', 1000, 1, true, '2024-05-03 07:45:37.19228', '2024-05-03 07:45:37.19228');


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users (id, email, created_at, updated_at, encrypted_password, reset_password_token, reset_password_sent_at, sign_in_count, current_sign_in_at, last_sign_in_at, confirmation_token, confirmed_at, confirmation_sent_at, unconfirmed_email, locale, encrypted_otp_secret, encrypted_otp_secret_iv, encrypted_otp_secret_salt, consumed_timestep, otp_required_for_login, last_emailed_at, otp_backup_codes, account_id, disabled, invite_id, chosen_languages, created_by_application_id, approved, sign_in_token, sign_in_token_sent_at, webauthn_id, sign_up_ip, skip_sign_in_token, role_id, settings, time_zone) VALUES (1, 'admin@localhost', '2024-05-03 07:45:37.371847', '2024-05-04 09:35:47.288806', '$2a$10$JeJBn/4ey6gd1FOfOO.rz.KQVWke/T/Z0m69QccEYh7DbEIVOCZYu', NULL, NULL, 1, '2024-05-04 09:34:31.99488', '2024-05-04 09:34:31.99488', NULL, '2024-05-03 07:45:37.241183', NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, NULL, NULL, 112376043092649131, false, NULL, NULL, NULL, true, NULL, NULL, NULL, NULL, NULL, 3, '{"show_application":true,"noindex":false}', NULL);


--
-- Data for Name: web_push_subscriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: web_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: webhooks; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: account_aliases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_aliases_id_seq', 1, false);


--
-- Name: account_conversations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_conversations_id_seq', 1, false);


--
-- Name: account_deletion_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_deletion_requests_id_seq', 1, false);


--
-- Name: account_domain_blocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_domain_blocks_id_seq', 1, false);


--
-- Name: account_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_migrations_id_seq', 1, false);


--
-- Name: account_moderation_notes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_moderation_notes_id_seq', 1, false);


--
-- Name: account_notes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_notes_id_seq', 1, false);


--
-- Name: account_pins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_pins_id_seq', 1, false);


--
-- Name: account_relationship_severance_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_relationship_severance_events_id_seq', 1, false);


--
-- Name: account_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_stats_id_seq', 1, true);


--
-- Name: account_statuses_cleanup_policies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_statuses_cleanup_policies_id_seq', 1, false);


--
-- Name: account_warning_presets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_warning_presets_id_seq', 1, false);


--
-- Name: account_warnings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_warnings_id_seq', 1, false);


--
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.accounts_id_seq', 7, true);


--
-- Name: admin_action_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_action_logs_id_seq', 1, false);


--
-- Name: announcement_mutes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.announcement_mutes_id_seq', 1, false);


--
-- Name: announcement_reactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.announcement_reactions_id_seq', 1, false);


--
-- Name: announcements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.announcements_id_seq', 1, false);


--
-- Name: appeals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.appeals_id_seq', 1, false);


--
-- Name: backups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.backups_id_seq', 1, false);


--
-- Name: blocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.blocks_id_seq', 1, false);


--
-- Name: bookmarks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bookmarks_id_seq', 1, false);


--
-- Name: bulk_import_rows_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bulk_import_rows_id_seq', 1, false);


--
-- Name: bulk_imports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bulk_imports_id_seq', 1, false);


--
-- Name: canonical_email_blocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.canonical_email_blocks_id_seq', 1, false);


--
-- Name: conversation_mutes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conversation_mutes_id_seq', 1, false);


--
-- Name: conversations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conversations_id_seq', 3, true);


--
-- Name: custom_emoji_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.custom_emoji_categories_id_seq', 1, false);


--
-- Name: custom_emojis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.custom_emojis_id_seq', 1, false);


--
-- Name: custom_filter_keywords_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.custom_filter_keywords_id_seq', 1, false);


--
-- Name: custom_filter_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.custom_filter_statuses_id_seq', 1, false);


--
-- Name: custom_filters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.custom_filters_id_seq', 1, false);


--
-- Name: deprecated_preview_cards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.deprecated_preview_cards_id_seq', 1, false);


--
-- Name: devices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.devices_id_seq', 1, false);


--
-- Name: domain_allows_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.domain_allows_id_seq', 1, false);


--
-- Name: domain_blocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.domain_blocks_id_seq', 1, false);


--
-- Name: email_domain_blocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.email_domain_blocks_id_seq', 1, false);


--
-- Name: encrypted_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.encrypted_messages_id_seq', 1, false);


--
-- Name: favourites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.favourites_id_seq', 1, false);


--
-- Name: featured_tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.featured_tags_id_seq', 1, false);


--
-- Name: follow_recommendation_mutes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.follow_recommendation_mutes_id_seq', 1, false);


--
-- Name: follow_recommendation_suppressions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.follow_recommendation_suppressions_id_seq', 1, false);


--
-- Name: follow_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.follow_requests_id_seq', 1, false);


--
-- Name: follows_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.follows_id_seq', 1, false);


--
-- Name: generated_annual_reports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.generated_annual_reports_id_seq', 1, false);


--
-- Name: identities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.identities_id_seq', 1, false);


--
-- Name: imports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.imports_id_seq', 1, false);


--
-- Name: invites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invites_id_seq', 1, false);


--
-- Name: ip_blocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ip_blocks_id_seq', 1, false);


--
-- Name: list_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.list_accounts_id_seq', 1, false);


--
-- Name: lists_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lists_id_seq', 1, false);


--
-- Name: login_activities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.login_activities_id_seq', 1, true);


--
-- Name: markers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.markers_id_seq', 1, false);


--
-- Name: media_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.media_attachments_id_seq', 1, true);


--
-- Name: mentions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mentions_id_seq', 1, false);


--
-- Name: mutes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mutes_id_seq', 1, false);


--
-- Name: notification_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notification_permissions_id_seq', 1, false);


--
-- Name: notification_policies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notification_policies_id_seq', 1, false);


--
-- Name: notification_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notification_requests_id_seq', 1, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1, false);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.oauth_access_grants_id_seq', 1, false);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.oauth_access_tokens_id_seq', 1, true);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.oauth_applications_id_seq', 1, true);


--
-- Name: one_time_keys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.one_time_keys_id_seq', 1, false);


--
-- Name: pghero_space_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pghero_space_stats_id_seq', 1, false);


--
-- Name: poll_votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.poll_votes_id_seq', 1, false);


--
-- Name: polls_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.polls_id_seq', 1, false);


--
-- Name: preview_card_providers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.preview_card_providers_id_seq', 1, false);


--
-- Name: preview_card_trends_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.preview_card_trends_id_seq', 1, false);


--
-- Name: preview_cards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.preview_cards_id_seq', 1, false);


--
-- Name: relationship_severance_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.relationship_severance_events_id_seq', 1, false);


--
-- Name: relays_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.relays_id_seq', 1, false);


--
-- Name: report_notes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.report_notes_id_seq', 1, false);


--
-- Name: reports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reports_id_seq', 1, false);


--
-- Name: rules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rules_id_seq', 1, false);


--
-- Name: scheduled_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.scheduled_statuses_id_seq', 1, false);


--
-- Name: session_activations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.session_activations_id_seq', 1, true);


--
-- Name: settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.settings_id_seq', 1, false);


--
-- Name: severed_relationships_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.severed_relationships_id_seq', 1, false);


--
-- Name: site_uploads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.site_uploads_id_seq', 1, false);


--
-- Name: software_updates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.software_updates_id_seq', 1, false);


--
-- Name: status_edits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.status_edits_id_seq', 1, false);


--
-- Name: status_pins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.status_pins_id_seq', 1, false);


--
-- Name: status_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.status_stats_id_seq', 1, false);


--
-- Name: status_trends_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.status_trends_id_seq', 1, false);


--
-- Name: statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.statuses_id_seq', 3, true);


--
-- Name: system_keys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.system_keys_id_seq', 1, false);


--
-- Name: tag_follows_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tag_follows_id_seq', 1, false);


--
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tags_id_seq', 1, false);


--
-- Name: tombstones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tombstones_id_seq', 1, false);


--
-- Name: unavailable_domains_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.unavailable_domains_id_seq', 1, false);


--
-- Name: user_invite_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_invite_requests_id_seq', 1, false);


--
-- Name: user_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_roles_id_seq', 3, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- Name: web_push_subscriptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.web_push_subscriptions_id_seq', 1, false);


--
-- Name: web_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.web_settings_id_seq', 1, false);


--
-- Name: webauthn_credentials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.webauthn_credentials_id_seq', 1, false);


--
-- Name: webhooks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.webhooks_id_seq', 1, false);


--
-- Name: account_aliases account_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_aliases
    ADD CONSTRAINT account_aliases_pkey PRIMARY KEY (id);


--
-- Name: account_conversations account_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_conversations
    ADD CONSTRAINT account_conversations_pkey PRIMARY KEY (id);


--
-- Name: account_deletion_requests account_deletion_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_deletion_requests
    ADD CONSTRAINT account_deletion_requests_pkey PRIMARY KEY (id);


--
-- Name: account_domain_blocks account_domain_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_domain_blocks
    ADD CONSTRAINT account_domain_blocks_pkey PRIMARY KEY (id);


--
-- Name: account_migrations account_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_migrations
    ADD CONSTRAINT account_migrations_pkey PRIMARY KEY (id);


--
-- Name: account_moderation_notes account_moderation_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_moderation_notes
    ADD CONSTRAINT account_moderation_notes_pkey PRIMARY KEY (id);


--
-- Name: account_notes account_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_notes
    ADD CONSTRAINT account_notes_pkey PRIMARY KEY (id);


--
-- Name: account_pins account_pins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_pins
    ADD CONSTRAINT account_pins_pkey PRIMARY KEY (id);


--
-- Name: account_relationship_severance_events account_relationship_severance_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_relationship_severance_events
    ADD CONSTRAINT account_relationship_severance_events_pkey PRIMARY KEY (id);


--
-- Name: account_stats account_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_stats
    ADD CONSTRAINT account_stats_pkey PRIMARY KEY (id);


--
-- Name: account_statuses_cleanup_policies account_statuses_cleanup_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_statuses_cleanup_policies
    ADD CONSTRAINT account_statuses_cleanup_policies_pkey PRIMARY KEY (id);


--
-- Name: account_warning_presets account_warning_presets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_warning_presets
    ADD CONSTRAINT account_warning_presets_pkey PRIMARY KEY (id);


--
-- Name: account_warnings account_warnings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_warnings
    ADD CONSTRAINT account_warnings_pkey PRIMARY KEY (id);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: accounts_tags accounts_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_tags
    ADD CONSTRAINT accounts_tags_pkey PRIMARY KEY (tag_id, account_id);


--
-- Name: admin_action_logs admin_action_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_action_logs
    ADD CONSTRAINT admin_action_logs_pkey PRIMARY KEY (id);


--
-- Name: announcement_mutes announcement_mutes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_mutes
    ADD CONSTRAINT announcement_mutes_pkey PRIMARY KEY (id);


--
-- Name: announcement_reactions announcement_reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_reactions
    ADD CONSTRAINT announcement_reactions_pkey PRIMARY KEY (id);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: appeals appeals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appeals
    ADD CONSTRAINT appeals_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: backups backups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.backups
    ADD CONSTRAINT backups_pkey PRIMARY KEY (id);


--
-- Name: blocks blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_pkey PRIMARY KEY (id);


--
-- Name: bookmarks bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_pkey PRIMARY KEY (id);


--
-- Name: bulk_import_rows bulk_import_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulk_import_rows
    ADD CONSTRAINT bulk_import_rows_pkey PRIMARY KEY (id);


--
-- Name: bulk_imports bulk_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulk_imports
    ADD CONSTRAINT bulk_imports_pkey PRIMARY KEY (id);


--
-- Name: canonical_email_blocks canonical_email_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canonical_email_blocks
    ADD CONSTRAINT canonical_email_blocks_pkey PRIMARY KEY (id);


--
-- Name: conversation_mutes conversation_mutes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversation_mutes
    ADD CONSTRAINT conversation_mutes_pkey PRIMARY KEY (id);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: custom_emoji_categories custom_emoji_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_emoji_categories
    ADD CONSTRAINT custom_emoji_categories_pkey PRIMARY KEY (id);


--
-- Name: custom_emojis custom_emojis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_emojis
    ADD CONSTRAINT custom_emojis_pkey PRIMARY KEY (id);


--
-- Name: custom_filter_keywords custom_filter_keywords_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_filter_keywords
    ADD CONSTRAINT custom_filter_keywords_pkey PRIMARY KEY (id);


--
-- Name: custom_filter_statuses custom_filter_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_filter_statuses
    ADD CONSTRAINT custom_filter_statuses_pkey PRIMARY KEY (id);


--
-- Name: custom_filters custom_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_filters
    ADD CONSTRAINT custom_filters_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: domain_allows domain_allows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domain_allows
    ADD CONSTRAINT domain_allows_pkey PRIMARY KEY (id);


--
-- Name: domain_blocks domain_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.domain_blocks
    ADD CONSTRAINT domain_blocks_pkey PRIMARY KEY (id);


--
-- Name: email_domain_blocks email_domain_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_domain_blocks
    ADD CONSTRAINT email_domain_blocks_pkey PRIMARY KEY (id);


--
-- Name: encrypted_messages encrypted_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.encrypted_messages
    ADD CONSTRAINT encrypted_messages_pkey PRIMARY KEY (id);


--
-- Name: favourites favourites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favourites
    ADD CONSTRAINT favourites_pkey PRIMARY KEY (id);


--
-- Name: featured_tags featured_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.featured_tags
    ADD CONSTRAINT featured_tags_pkey PRIMARY KEY (id);


--
-- Name: follow_recommendation_mutes follow_recommendation_mutes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follow_recommendation_mutes
    ADD CONSTRAINT follow_recommendation_mutes_pkey PRIMARY KEY (id);


--
-- Name: follow_recommendation_suppressions follow_recommendation_suppressions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follow_recommendation_suppressions
    ADD CONSTRAINT follow_recommendation_suppressions_pkey PRIMARY KEY (id);


--
-- Name: follow_requests follow_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follow_requests
    ADD CONSTRAINT follow_requests_pkey PRIMARY KEY (id);


--
-- Name: follows follows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_pkey PRIMARY KEY (id);


--
-- Name: generated_annual_reports generated_annual_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generated_annual_reports
    ADD CONSTRAINT generated_annual_reports_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: imports imports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT imports_pkey PRIMARY KEY (id);


--
-- Name: deprecated_preview_cards index_deprecated_preview_cards_on_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deprecated_preview_cards
    ADD CONSTRAINT index_deprecated_preview_cards_on_id PRIMARY KEY (id);


--
-- Name: invites invites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_pkey PRIMARY KEY (id);


--
-- Name: ip_blocks ip_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ip_blocks
    ADD CONSTRAINT ip_blocks_pkey PRIMARY KEY (id);


--
-- Name: list_accounts list_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_accounts
    ADD CONSTRAINT list_accounts_pkey PRIMARY KEY (id);


--
-- Name: lists lists_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lists
    ADD CONSTRAINT lists_pkey PRIMARY KEY (id);


--
-- Name: login_activities login_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_activities
    ADD CONSTRAINT login_activities_pkey PRIMARY KEY (id);


--
-- Name: markers markers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.markers
    ADD CONSTRAINT markers_pkey PRIMARY KEY (id);


--
-- Name: media_attachments media_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media_attachments
    ADD CONSTRAINT media_attachments_pkey PRIMARY KEY (id);


--
-- Name: mentions mentions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT mentions_pkey PRIMARY KEY (id);


--
-- Name: mutes mutes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mutes
    ADD CONSTRAINT mutes_pkey PRIMARY KEY (id);


--
-- Name: notification_permissions notification_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_permissions
    ADD CONSTRAINT notification_permissions_pkey PRIMARY KEY (id);


--
-- Name: notification_policies notification_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_policies
    ADD CONSTRAINT notification_policies_pkey PRIMARY KEY (id);


--
-- Name: notification_requests notification_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_requests
    ADD CONSTRAINT notification_requests_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: one_time_keys one_time_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.one_time_keys
    ADD CONSTRAINT one_time_keys_pkey PRIMARY KEY (id);


--
-- Name: pghero_space_stats pghero_space_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pghero_space_stats
    ADD CONSTRAINT pghero_space_stats_pkey PRIMARY KEY (id);


--
-- Name: poll_votes poll_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT poll_votes_pkey PRIMARY KEY (id);


--
-- Name: polls polls_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT polls_pkey PRIMARY KEY (id);


--
-- Name: preview_card_providers preview_card_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preview_card_providers
    ADD CONSTRAINT preview_card_providers_pkey PRIMARY KEY (id);


--
-- Name: preview_card_trends preview_card_trends_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preview_card_trends
    ADD CONSTRAINT preview_card_trends_pkey PRIMARY KEY (id);


--
-- Name: preview_cards preview_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preview_cards
    ADD CONSTRAINT preview_cards_pkey PRIMARY KEY (id);


--
-- Name: preview_cards_statuses preview_cards_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preview_cards_statuses
    ADD CONSTRAINT preview_cards_statuses_pkey PRIMARY KEY (status_id, preview_card_id);


--
-- Name: relationship_severance_events relationship_severance_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relationship_severance_events
    ADD CONSTRAINT relationship_severance_events_pkey PRIMARY KEY (id);


--
-- Name: relays relays_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relays
    ADD CONSTRAINT relays_pkey PRIMARY KEY (id);


--
-- Name: report_notes report_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.report_notes
    ADD CONSTRAINT report_notes_pkey PRIMARY KEY (id);


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: rules rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT rules_pkey PRIMARY KEY (id);


--
-- Name: scheduled_statuses scheduled_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scheduled_statuses
    ADD CONSTRAINT scheduled_statuses_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: session_activations session_activations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_activations
    ADD CONSTRAINT session_activations_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: severed_relationships severed_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.severed_relationships
    ADD CONSTRAINT severed_relationships_pkey PRIMARY KEY (id);


--
-- Name: site_uploads site_uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_uploads
    ADD CONSTRAINT site_uploads_pkey PRIMARY KEY (id);


--
-- Name: software_updates software_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.software_updates
    ADD CONSTRAINT software_updates_pkey PRIMARY KEY (id);


--
-- Name: status_edits status_edits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_edits
    ADD CONSTRAINT status_edits_pkey PRIMARY KEY (id);


--
-- Name: status_pins status_pins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_pins
    ADD CONSTRAINT status_pins_pkey PRIMARY KEY (id);


--
-- Name: status_stats status_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_stats
    ADD CONSTRAINT status_stats_pkey PRIMARY KEY (id);


--
-- Name: status_trends status_trends_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_trends
    ADD CONSTRAINT status_trends_pkey PRIMARY KEY (id);


--
-- Name: statuses statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT statuses_pkey PRIMARY KEY (id);


--
-- Name: statuses_tags statuses_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statuses_tags
    ADD CONSTRAINT statuses_tags_pkey PRIMARY KEY (tag_id, status_id);


--
-- Name: system_keys system_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_keys
    ADD CONSTRAINT system_keys_pkey PRIMARY KEY (id);


--
-- Name: tag_follows tag_follows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag_follows
    ADD CONSTRAINT tag_follows_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tombstones tombstones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tombstones
    ADD CONSTRAINT tombstones_pkey PRIMARY KEY (id);


--
-- Name: unavailable_domains unavailable_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.unavailable_domains
    ADD CONSTRAINT unavailable_domains_pkey PRIMARY KEY (id);


--
-- Name: user_invite_requests user_invite_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_invite_requests
    ADD CONSTRAINT user_invite_requests_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: web_push_subscriptions web_push_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.web_push_subscriptions
    ADD CONSTRAINT web_push_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: web_settings web_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.web_settings
    ADD CONSTRAINT web_settings_pkey PRIMARY KEY (id);


--
-- Name: webauthn_credentials webauthn_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_pkey PRIMARY KEY (id);


--
-- Name: webhooks webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_pkey PRIMARY KEY (id);


--
-- Name: idx_on_account_id_language_sensitive_250461e1eb; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_on_account_id_language_sensitive_250461e1eb ON public.account_summaries USING btree (account_id, language, sensitive);


--
-- Name: idx_on_account_id_relationship_severance_event_id_7bd82bf20e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_on_account_id_relationship_severance_event_id_7bd82bf20e ON public.account_relationship_severance_events USING btree (account_id, relationship_severance_event_id);


--
-- Name: idx_on_account_id_target_account_id_a8c8ddf44e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_on_account_id_target_account_id_a8c8ddf44e ON public.follow_recommendation_mutes USING btree (account_id, target_account_id);


--
-- Name: idx_on_relationship_severance_event_id_403f53e707; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_on_relationship_severance_event_id_403f53e707 ON public.account_relationship_severance_events USING btree (relationship_severance_event_id);


--
-- Name: index_account_aliases_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_account_aliases_on_account_id ON public.account_aliases USING btree (account_id);


--
-- Name: index_account_conversations_on_conversation_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_account_conversations_on_conversation_id ON public.account_conversations USING btree (conversation_id);


--
-- Name: index_account_deletion_requests_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_account_deletion_requests_on_account_id ON public.account_deletion_requests USING btree (account_id);


--
-- Name: index_account_domain_blocks_on_account_id_and_domain; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_account_domain_blocks_on_account_id_and_domain ON public.account_domain_blocks USING btree (account_id, domain);


--
-- Name: index_account_migrations_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_account_migrations_on_account_id ON public.account_migrations USING btree (account_id);


--
-- Name: index_account_migrations_on_target_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_account_migrations_on_target_account_id ON public.account_migrations USING btree (target_account_id) WHERE (target_account_id IS NOT NULL);


--
-- Name: index_account_moderation_notes_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_account_moderation_notes_on_account_id ON public.account_moderation_notes USING btree (account_id);


--
-- Name: index_account_moderation_notes_on_target_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_account_moderation_notes_on_target_account_id ON public.account_moderation_notes USING btree (target_account_id);


--
-- Name: index_account_notes_on_account_id_and_target_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_account_notes_on_account_id_and_target_account_id ON public.account_notes USING btree (account_id, target_account_id);


--
-- Name: index_account_notes_on_target_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_account_notes_on_target_account_id ON public.account_notes USING btree (target_account_id);


--
-- Name: index_account_pins_on_account_id_and_target_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_account_pins_on_account_id_and_target_account_id ON public.account_pins USING btree (account_id, target_account_id);


--
-- Name: index_account_pins_on_target_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_account_pins_on_target_account_id ON public.account_pins USING btree (target_account_id);


--
-- Name: index_account_relationship_severance_events_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_account_relationship_severance_events_on_account_id ON public.account_relationship_severance_events USING btree (account_id);


--
-- Name: index_account_stats_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_account_stats_on_account_id ON public.account_stats USING btree (account_id);


--
-- Name: index_account_stats_on_last_status_at_and_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_account_stats_on_last_status_at_and_account_id ON public.account_stats USING btree (last_status_at DESC NULLS LAST, account_id);


--
-- Name: index_account_statuses_cleanup_policies_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_account_statuses_cleanup_policies_on_account_id ON public.account_statuses_cleanup_policies USING btree (account_id);


--
-- Name: index_account_summaries_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_account_summaries_on_account_id ON public.account_summaries USING btree (account_id);


--
-- Name: index_account_warnings_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_account_warnings_on_account_id ON public.account_warnings USING btree (account_id);


--
-- Name: index_account_warnings_on_target_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_account_warnings_on_target_account_id ON public.account_warnings USING btree (target_account_id);


--
-- Name: index_accounts_on_domain_and_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_accounts_on_domain_and_id ON public.accounts USING btree (domain, id);


--
-- Name: index_accounts_on_moved_to_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_accounts_on_moved_to_account_id ON public.accounts USING btree (moved_to_account_id) WHERE (moved_to_account_id IS NOT NULL);


--
-- Name: index_accounts_on_uri; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_accounts_on_uri ON public.accounts USING btree (uri);


--
-- Name: index_accounts_on_url; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_accounts_on_url ON public.accounts USING btree (url text_pattern_ops) WHERE (url IS NOT NULL);


--
-- Name: index_accounts_on_username_and_domain_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_accounts_on_username_and_domain_lower ON public.accounts USING btree (lower((username)::text), COALESCE(lower((domain)::text), ''::text));


--
-- Name: index_accounts_tags_on_account_id_and_tag_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_accounts_tags_on_account_id_and_tag_id ON public.accounts_tags USING btree (account_id, tag_id);


--
-- Name: index_admin_action_logs_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_admin_action_logs_on_account_id ON public.admin_action_logs USING btree (account_id);


--
-- Name: index_admin_action_logs_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_admin_action_logs_on_target_type_and_target_id ON public.admin_action_logs USING btree (target_type, target_id);


--
-- Name: index_announcement_mutes_on_account_id_and_announcement_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_announcement_mutes_on_account_id_and_announcement_id ON public.announcement_mutes USING btree (account_id, announcement_id);


--
-- Name: index_announcement_mutes_on_announcement_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_announcement_mutes_on_announcement_id ON public.announcement_mutes USING btree (announcement_id);


--
-- Name: index_announcement_reactions_on_account_id_and_announcement_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_announcement_reactions_on_account_id_and_announcement_id ON public.announcement_reactions USING btree (account_id, announcement_id, name);


--
-- Name: index_announcement_reactions_on_announcement_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_announcement_reactions_on_announcement_id ON public.announcement_reactions USING btree (announcement_id);


--
-- Name: index_announcement_reactions_on_custom_emoji_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_announcement_reactions_on_custom_emoji_id ON public.announcement_reactions USING btree (custom_emoji_id) WHERE (custom_emoji_id IS NOT NULL);


--
-- Name: index_appeals_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_appeals_on_account_id ON public.appeals USING btree (account_id);


--
-- Name: index_appeals_on_account_warning_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_appeals_on_account_warning_id ON public.appeals USING btree (account_warning_id);


--
-- Name: index_appeals_on_approved_by_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_appeals_on_approved_by_account_id ON public.appeals USING btree (approved_by_account_id) WHERE (approved_by_account_id IS NOT NULL);


--
-- Name: index_appeals_on_rejected_by_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_appeals_on_rejected_by_account_id ON public.appeals USING btree (rejected_by_account_id) WHERE (rejected_by_account_id IS NOT NULL);


--
-- Name: index_backups_on_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_backups_on_user_id ON public.backups USING btree (user_id);


--
-- Name: index_blocks_on_account_id_and_target_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_blocks_on_account_id_and_target_account_id ON public.blocks USING btree (account_id, target_account_id);


--
-- Name: index_blocks_on_target_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_blocks_on_target_account_id ON public.blocks USING btree (target_account_id);


--
-- Name: index_bookmarks_on_account_id_and_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_bookmarks_on_account_id_and_status_id ON public.bookmarks USING btree (account_id, status_id);


--
-- Name: index_bookmarks_on_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_bookmarks_on_status_id ON public.bookmarks USING btree (status_id);


--
-- Name: index_bulk_import_rows_on_bulk_import_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_bulk_import_rows_on_bulk_import_id ON public.bulk_import_rows USING btree (bulk_import_id);


--
-- Name: index_bulk_imports_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_bulk_imports_on_account_id ON public.bulk_imports USING btree (account_id);


--
-- Name: index_bulk_imports_unconfirmed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_bulk_imports_unconfirmed ON public.bulk_imports USING btree (id) WHERE (state = 0);


--
-- Name: index_canonical_email_blocks_on_canonical_email_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_canonical_email_blocks_on_canonical_email_hash ON public.canonical_email_blocks USING btree (canonical_email_hash);


--
-- Name: index_canonical_email_blocks_on_reference_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_canonical_email_blocks_on_reference_account_id ON public.canonical_email_blocks USING btree (reference_account_id);


--
-- Name: index_conversation_mutes_on_account_id_and_conversation_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_conversation_mutes_on_account_id_and_conversation_id ON public.conversation_mutes USING btree (account_id, conversation_id);


--
-- Name: index_conversations_on_uri; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_conversations_on_uri ON public.conversations USING btree (uri text_pattern_ops) WHERE (uri IS NOT NULL);


--
-- Name: index_custom_emoji_categories_on_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_custom_emoji_categories_on_name ON public.custom_emoji_categories USING btree (name);


--
-- Name: index_custom_emojis_on_shortcode_and_domain; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_custom_emojis_on_shortcode_and_domain ON public.custom_emojis USING btree (shortcode, domain);


--
-- Name: index_custom_filter_keywords_on_custom_filter_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_custom_filter_keywords_on_custom_filter_id ON public.custom_filter_keywords USING btree (custom_filter_id);


--
-- Name: index_custom_filter_statuses_on_custom_filter_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_custom_filter_statuses_on_custom_filter_id ON public.custom_filter_statuses USING btree (custom_filter_id);


--
-- Name: index_custom_filter_statuses_on_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_custom_filter_statuses_on_status_id ON public.custom_filter_statuses USING btree (status_id);


--
-- Name: index_custom_filters_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_custom_filters_on_account_id ON public.custom_filters USING btree (account_id);


--
-- Name: index_deprecated_preview_cards_on_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_deprecated_preview_cards_on_status_id ON public.deprecated_preview_cards USING btree (status_id);


--
-- Name: index_devices_on_access_token_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_devices_on_access_token_id ON public.devices USING btree (access_token_id);


--
-- Name: index_devices_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_devices_on_account_id ON public.devices USING btree (account_id);


--
-- Name: index_domain_allows_on_domain; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_domain_allows_on_domain ON public.domain_allows USING btree (domain);


--
-- Name: index_domain_blocks_on_domain; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_domain_blocks_on_domain ON public.domain_blocks USING btree (domain);


--
-- Name: index_email_domain_blocks_on_domain; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_email_domain_blocks_on_domain ON public.email_domain_blocks USING btree (domain);


--
-- Name: index_encrypted_messages_on_device_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_encrypted_messages_on_device_id ON public.encrypted_messages USING btree (device_id);


--
-- Name: index_encrypted_messages_on_from_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_encrypted_messages_on_from_account_id ON public.encrypted_messages USING btree (from_account_id);


--
-- Name: index_favourites_on_account_id_and_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_favourites_on_account_id_and_id ON public.favourites USING btree (account_id, id);


--
-- Name: index_favourites_on_account_id_and_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_favourites_on_account_id_and_status_id ON public.favourites USING btree (account_id, status_id);


--
-- Name: index_favourites_on_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_favourites_on_status_id ON public.favourites USING btree (status_id);


--
-- Name: index_featured_tags_on_account_id_and_tag_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_featured_tags_on_account_id_and_tag_id ON public.featured_tags USING btree (account_id, tag_id);


--
-- Name: index_featured_tags_on_tag_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_featured_tags_on_tag_id ON public.featured_tags USING btree (tag_id);


--
-- Name: index_follow_recommendation_mutes_on_target_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_follow_recommendation_mutes_on_target_account_id ON public.follow_recommendation_mutes USING btree (target_account_id);


--
-- Name: index_follow_recommendation_suppressions_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_follow_recommendation_suppressions_on_account_id ON public.follow_recommendation_suppressions USING btree (account_id);


--
-- Name: index_follow_requests_on_account_id_and_target_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_follow_requests_on_account_id_and_target_account_id ON public.follow_requests USING btree (account_id, target_account_id);


--
-- Name: index_follows_on_account_id_and_target_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_follows_on_account_id_and_target_account_id ON public.follows USING btree (account_id, target_account_id);


--
-- Name: index_follows_on_target_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_follows_on_target_account_id ON public.follows USING btree (target_account_id);


--
-- Name: index_generated_annual_reports_on_account_id_and_year; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_generated_annual_reports_on_account_id_and_year ON public.generated_annual_reports USING btree (account_id, year);


--
-- Name: index_global_follow_recommendations_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_global_follow_recommendations_on_account_id ON public.global_follow_recommendations USING btree (account_id);


--
-- Name: index_identities_on_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_identities_on_user_id ON public.identities USING btree (user_id);


--
-- Name: index_instances_on_domain; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_instances_on_domain ON public.instances USING btree (domain);


--
-- Name: index_instances_on_reverse_domain; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_instances_on_reverse_domain ON public.instances USING btree (reverse(('.'::text || (domain)::text)), domain);


--
-- Name: index_invites_on_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_invites_on_code ON public.invites USING btree (code);


--
-- Name: index_invites_on_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_invites_on_user_id ON public.invites USING btree (user_id);


--
-- Name: index_ip_blocks_on_ip; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_ip_blocks_on_ip ON public.ip_blocks USING btree (ip);


--
-- Name: index_list_accounts_on_account_id_and_list_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_list_accounts_on_account_id_and_list_id ON public.list_accounts USING btree (account_id, list_id);


--
-- Name: index_list_accounts_on_follow_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_list_accounts_on_follow_id ON public.list_accounts USING btree (follow_id) WHERE (follow_id IS NOT NULL);


--
-- Name: index_list_accounts_on_follow_request_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_list_accounts_on_follow_request_id ON public.list_accounts USING btree (follow_request_id) WHERE (follow_request_id IS NOT NULL);


--
-- Name: index_list_accounts_on_list_id_and_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_list_accounts_on_list_id_and_account_id ON public.list_accounts USING btree (list_id, account_id);


--
-- Name: index_lists_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_lists_on_account_id ON public.lists USING btree (account_id);


--
-- Name: index_login_activities_on_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_login_activities_on_user_id ON public.login_activities USING btree (user_id);


--
-- Name: index_markers_on_user_id_and_timeline; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_markers_on_user_id_and_timeline ON public.markers USING btree (user_id, timeline);


--
-- Name: index_media_attachments_on_account_id_and_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_media_attachments_on_account_id_and_status_id ON public.media_attachments USING btree (account_id, status_id DESC);


--
-- Name: index_media_attachments_on_scheduled_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_media_attachments_on_scheduled_status_id ON public.media_attachments USING btree (scheduled_status_id) WHERE (scheduled_status_id IS NOT NULL);


--
-- Name: index_media_attachments_on_shortcode; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_media_attachments_on_shortcode ON public.media_attachments USING btree (shortcode text_pattern_ops) WHERE (shortcode IS NOT NULL);


--
-- Name: index_media_attachments_on_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_media_attachments_on_status_id ON public.media_attachments USING btree (status_id);


--
-- Name: index_mentions_on_account_id_and_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_mentions_on_account_id_and_status_id ON public.mentions USING btree (account_id, status_id);


--
-- Name: index_mentions_on_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_mentions_on_status_id ON public.mentions USING btree (status_id);


--
-- Name: index_mutes_on_account_id_and_target_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_mutes_on_account_id_and_target_account_id ON public.mutes USING btree (account_id, target_account_id);


--
-- Name: index_mutes_on_target_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_mutes_on_target_account_id ON public.mutes USING btree (target_account_id);


--
-- Name: index_notification_permissions_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_notification_permissions_on_account_id ON public.notification_permissions USING btree (account_id);


--
-- Name: index_notification_permissions_on_from_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_notification_permissions_on_from_account_id ON public.notification_permissions USING btree (from_account_id);


--
-- Name: index_notification_policies_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_notification_policies_on_account_id ON public.notification_policies USING btree (account_id);


--
-- Name: index_notification_requests_on_account_id_and_from_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_notification_requests_on_account_id_and_from_account_id ON public.notification_requests USING btree (account_id, from_account_id);


--
-- Name: index_notification_requests_on_account_id_and_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_notification_requests_on_account_id_and_id ON public.notification_requests USING btree (account_id, id DESC) WHERE (dismissed = false);


--
-- Name: index_notification_requests_on_from_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_notification_requests_on_from_account_id ON public.notification_requests USING btree (from_account_id);


--
-- Name: index_notification_requests_on_last_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_notification_requests_on_last_status_id ON public.notification_requests USING btree (last_status_id);


--
-- Name: index_notifications_on_account_id_and_id_and_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_notifications_on_account_id_and_id_and_type ON public.notifications USING btree (account_id, id DESC, type);


--
-- Name: index_notifications_on_activity_id_and_activity_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_notifications_on_activity_id_and_activity_type ON public.notifications USING btree (activity_id, activity_type);


--
-- Name: index_notifications_on_filtered; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_notifications_on_filtered ON public.notifications USING btree (account_id, id DESC, type) WHERE (filtered = false);


--
-- Name: index_notifications_on_from_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_notifications_on_from_account_id ON public.notifications USING btree (from_account_id);


--
-- Name: index_oauth_access_grants_on_resource_owner_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_oauth_access_grants_on_resource_owner_id ON public.oauth_access_grants USING btree (resource_owner_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON public.oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON public.oauth_access_tokens USING btree (refresh_token text_pattern_ops) WHERE (refresh_token IS NOT NULL);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON public.oauth_access_tokens USING btree (resource_owner_id) WHERE (resource_owner_id IS NOT NULL);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON public.oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_owner_id_and_owner_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_oauth_applications_on_owner_id_and_owner_type ON public.oauth_applications USING btree (owner_id, owner_type);


--
-- Name: index_oauth_applications_on_superapp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_oauth_applications_on_superapp ON public.oauth_applications USING btree (superapp) WHERE (superapp = true);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON public.oauth_applications USING btree (uid);


--
-- Name: index_one_time_keys_on_device_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_one_time_keys_on_device_id ON public.one_time_keys USING btree (device_id);


--
-- Name: index_one_time_keys_on_key_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_one_time_keys_on_key_id ON public.one_time_keys USING btree (key_id);


--
-- Name: index_pghero_space_stats_on_database_and_captured_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_pghero_space_stats_on_database_and_captured_at ON public.pghero_space_stats USING btree (database, captured_at);


--
-- Name: index_poll_votes_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_poll_votes_on_account_id ON public.poll_votes USING btree (account_id);


--
-- Name: index_poll_votes_on_poll_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_poll_votes_on_poll_id ON public.poll_votes USING btree (poll_id);


--
-- Name: index_polls_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_polls_on_account_id ON public.polls USING btree (account_id);


--
-- Name: index_polls_on_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_polls_on_status_id ON public.polls USING btree (status_id);


--
-- Name: index_preview_card_providers_on_domain; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_preview_card_providers_on_domain ON public.preview_card_providers USING btree (domain);


--
-- Name: index_preview_card_trends_on_preview_card_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_preview_card_trends_on_preview_card_id ON public.preview_card_trends USING btree (preview_card_id);


--
-- Name: index_preview_cards_on_url; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_preview_cards_on_url ON public.preview_cards USING btree (url);


--
-- Name: index_relationship_severance_events_on_type_and_target_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_relationship_severance_events_on_type_and_target_name ON public.relationship_severance_events USING btree (type, target_name);


--
-- Name: index_report_notes_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_report_notes_on_account_id ON public.report_notes USING btree (account_id);


--
-- Name: index_report_notes_on_report_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_report_notes_on_report_id ON public.report_notes USING btree (report_id);


--
-- Name: index_reports_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_reports_on_account_id ON public.reports USING btree (account_id);


--
-- Name: index_reports_on_action_taken_by_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_reports_on_action_taken_by_account_id ON public.reports USING btree (action_taken_by_account_id) WHERE (action_taken_by_account_id IS NOT NULL);


--
-- Name: index_reports_on_assigned_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_reports_on_assigned_account_id ON public.reports USING btree (assigned_account_id) WHERE (assigned_account_id IS NOT NULL);


--
-- Name: index_reports_on_target_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_reports_on_target_account_id ON public.reports USING btree (target_account_id);


--
-- Name: index_scheduled_statuses_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_scheduled_statuses_on_account_id ON public.scheduled_statuses USING btree (account_id);


--
-- Name: index_scheduled_statuses_on_scheduled_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_scheduled_statuses_on_scheduled_at ON public.scheduled_statuses USING btree (scheduled_at);


--
-- Name: index_session_activations_on_access_token_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_session_activations_on_access_token_id ON public.session_activations USING btree (access_token_id);


--
-- Name: index_session_activations_on_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_session_activations_on_session_id ON public.session_activations USING btree (session_id);


--
-- Name: index_session_activations_on_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_session_activations_on_user_id ON public.session_activations USING btree (user_id);


--
-- Name: index_settings_on_thing_type_and_thing_id_and_var; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_settings_on_thing_type_and_thing_id_and_var ON public.settings USING btree (thing_type, thing_id, var);


--
-- Name: index_severed_relationships_on_local_account_and_event; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_severed_relationships_on_local_account_and_event ON public.severed_relationships USING btree (local_account_id, relationship_severance_event_id);


--
-- Name: index_severed_relationships_on_remote_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_severed_relationships_on_remote_account_id ON public.severed_relationships USING btree (remote_account_id);


--
-- Name: index_severed_relationships_on_unique_tuples; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_severed_relationships_on_unique_tuples ON public.severed_relationships USING btree (relationship_severance_event_id, local_account_id, direction, remote_account_id);


--
-- Name: index_site_uploads_on_var; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_site_uploads_on_var ON public.site_uploads USING btree (var);


--
-- Name: index_software_updates_on_version; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_software_updates_on_version ON public.software_updates USING btree (version);


--
-- Name: index_status_edits_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_status_edits_on_account_id ON public.status_edits USING btree (account_id);


--
-- Name: index_status_edits_on_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_status_edits_on_status_id ON public.status_edits USING btree (status_id);


--
-- Name: index_status_pins_on_account_id_and_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_status_pins_on_account_id_and_status_id ON public.status_pins USING btree (account_id, status_id);


--
-- Name: index_status_pins_on_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_status_pins_on_status_id ON public.status_pins USING btree (status_id);


--
-- Name: index_status_stats_on_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_status_stats_on_status_id ON public.status_stats USING btree (status_id);


--
-- Name: index_status_trends_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_status_trends_on_account_id ON public.status_trends USING btree (account_id);


--
-- Name: index_status_trends_on_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_status_trends_on_status_id ON public.status_trends USING btree (status_id);


--
-- Name: index_statuses_20190820; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_statuses_20190820 ON public.statuses USING btree (account_id, id DESC, visibility, updated_at) WHERE (deleted_at IS NULL);


--
-- Name: index_statuses_local_20190824; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_statuses_local_20190824 ON public.statuses USING btree (id DESC, account_id) WHERE ((local OR (uri IS NULL)) AND (deleted_at IS NULL) AND (visibility = 0) AND (reblog_of_id IS NULL) AND ((NOT reply) OR (in_reply_to_account_id = account_id)));


--
-- Name: index_statuses_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_statuses_on_account_id ON public.statuses USING btree (account_id);


--
-- Name: index_statuses_on_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_statuses_on_deleted_at ON public.statuses USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: index_statuses_on_in_reply_to_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_statuses_on_in_reply_to_account_id ON public.statuses USING btree (in_reply_to_account_id) WHERE (in_reply_to_account_id IS NOT NULL);


--
-- Name: index_statuses_on_in_reply_to_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_statuses_on_in_reply_to_id ON public.statuses USING btree (in_reply_to_id) WHERE (in_reply_to_id IS NOT NULL);


--
-- Name: index_statuses_on_reblog_of_id_and_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_statuses_on_reblog_of_id_and_account_id ON public.statuses USING btree (reblog_of_id, account_id);


--
-- Name: index_statuses_on_uri; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_statuses_on_uri ON public.statuses USING btree (uri text_pattern_ops) WHERE (uri IS NOT NULL);


--
-- Name: index_statuses_public_20200119; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_statuses_public_20200119 ON public.statuses USING btree (id DESC, account_id) WHERE ((deleted_at IS NULL) AND (visibility = 0) AND (reblog_of_id IS NULL) AND ((NOT reply) OR (in_reply_to_account_id = account_id)));


--
-- Name: index_statuses_tags_on_status_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_statuses_tags_on_status_id ON public.statuses_tags USING btree (status_id);


--
-- Name: index_tag_follows_on_account_id_and_tag_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_tag_follows_on_account_id_and_tag_id ON public.tag_follows USING btree (account_id, tag_id);


--
-- Name: index_tag_follows_on_tag_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_tag_follows_on_tag_id ON public.tag_follows USING btree (tag_id);


--
-- Name: index_tags_on_name_lower_btree; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_tags_on_name_lower_btree ON public.tags USING btree (lower((name)::text) text_pattern_ops);


--
-- Name: index_tombstones_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_tombstones_on_account_id ON public.tombstones USING btree (account_id);


--
-- Name: index_tombstones_on_uri; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_tombstones_on_uri ON public.tombstones USING btree (uri);


--
-- Name: index_unavailable_domains_on_domain; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_unavailable_domains_on_domain ON public.unavailable_domains USING btree (domain);


--
-- Name: index_unique_conversations; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_unique_conversations ON public.account_conversations USING btree (account_id, conversation_id, participant_account_ids);


--
-- Name: index_user_invite_requests_on_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_user_invite_requests_on_user_id ON public.user_invite_requests USING btree (user_id);


--
-- Name: index_users_on_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_users_on_account_id ON public.users USING btree (account_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_created_by_application_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_users_on_created_by_application_id ON public.users USING btree (created_by_application_id) WHERE (created_by_application_id IS NOT NULL);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token text_pattern_ops) WHERE (reset_password_token IS NOT NULL);


--
-- Name: index_users_on_role_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_users_on_role_id ON public.users USING btree (role_id) WHERE (role_id IS NOT NULL);


--
-- Name: index_users_on_unconfirmed_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_users_on_unconfirmed_email ON public.users USING btree (unconfirmed_email) WHERE (unconfirmed_email IS NOT NULL);


--
-- Name: index_web_push_subscriptions_on_access_token_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_web_push_subscriptions_on_access_token_id ON public.web_push_subscriptions USING btree (access_token_id) WHERE (access_token_id IS NOT NULL);


--
-- Name: index_web_push_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_web_push_subscriptions_on_user_id ON public.web_push_subscriptions USING btree (user_id);


--
-- Name: index_web_settings_on_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_web_settings_on_user_id ON public.web_settings USING btree (user_id);


--
-- Name: index_webauthn_credentials_on_external_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_webauthn_credentials_on_external_id ON public.webauthn_credentials USING btree (external_id);


--
-- Name: index_webauthn_credentials_on_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_webauthn_credentials_on_user_id ON public.webauthn_credentials USING btree (user_id);


--
-- Name: index_webhooks_on_url; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_webhooks_on_url ON public.webhooks USING btree (url);


--
-- Name: search_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX search_index ON public.accounts USING gin ((((setweight(to_tsvector('simple'::regconfig, (display_name)::text), 'A'::"char") || setweight(to_tsvector('simple'::regconfig, (username)::text), 'B'::"char")) || setweight(to_tsvector('simple'::regconfig, (COALESCE(domain, ''::character varying))::text), 'C'::"char"))));


--
-- Name: web_settings fk_11910667b2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.web_settings
    ADD CONSTRAINT fk_11910667b2 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: account_domain_blocks fk_206c6029bd; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_domain_blocks
    ADD CONSTRAINT fk_206c6029bd FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: conversation_mutes fk_225b4212bb; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversation_mutes
    ADD CONSTRAINT fk_225b4212bb FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: statuses_tags fk_3081861e21; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statuses_tags
    ADD CONSTRAINT fk_3081861e21 FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: follows fk_32ed1b5560; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT fk_32ed1b5560 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: oauth_access_grants fk_34d54b0a33; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_34d54b0a33 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id) ON DELETE CASCADE;


--
-- Name: blocks fk_4269e03e65; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT fk_4269e03e65 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: reports fk_4b81f7522c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_4b81f7522c FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: users fk_50500f500d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_50500f500d FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: favourites fk_5eb6c2b873; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favourites
    ADD CONSTRAINT fk_5eb6c2b873 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: oauth_access_grants fk_63b044929b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_63b044929b FOREIGN KEY (resource_owner_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: imports fk_6db1b6e408; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT fk_6db1b6e408 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: follows fk_745ca29eac; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT fk_745ca29eac FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: follow_requests fk_76d644b0e7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follow_requests
    ADD CONSTRAINT fk_76d644b0e7 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: follow_requests fk_9291ec025d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follow_requests
    ADD CONSTRAINT fk_9291ec025d FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: blocks fk_9571bfabc1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT fk_9571bfabc1 FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: session_activations fk_957e5bda89; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_activations
    ADD CONSTRAINT fk_957e5bda89 FOREIGN KEY (access_token_id) REFERENCES public.oauth_access_tokens(id) ON DELETE CASCADE;


--
-- Name: media_attachments fk_96dd81e81b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media_attachments
    ADD CONSTRAINT fk_96dd81e81b FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: mentions fk_970d43f9d1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT fk_970d43f9d1 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: statuses fk_9bda1543f7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT fk_9bda1543f7 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: oauth_applications fk_b0988c7c0a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT fk_b0988c7c0a FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: favourites fk_b0e856845e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favourites
    ADD CONSTRAINT fk_b0e856845e FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: mutes fk_b8d8daf315; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mutes
    ADD CONSTRAINT fk_b8d8daf315 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: reports fk_bca45b75fd; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_bca45b75fd FOREIGN KEY (action_taken_by_account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: identities fk_bea040f377; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.identities
    ADD CONSTRAINT fk_bea040f377 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications fk_c141c8ee55; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_c141c8ee55 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: statuses fk_c7fa917661; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT fk_c7fa917661 FOREIGN KEY (in_reply_to_account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: status_pins fk_d4cb435b62; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_pins
    ADD CONSTRAINT fk_d4cb435b62 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: session_activations fk_e5fda67334; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_activations
    ADD CONSTRAINT fk_e5fda67334 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: oauth_access_tokens fk_e84df68546; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_e84df68546 FOREIGN KEY (resource_owner_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: reports fk_eb37af34f0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_eb37af34f0 FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: mutes fk_eecff219ea; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mutes
    ADD CONSTRAINT fk_eecff219ea FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: oauth_access_tokens fk_f5fc4c1ee3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_f5fc4c1ee3 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id) ON DELETE CASCADE;


--
-- Name: notifications fk_fbd6b0bf9e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_fbd6b0bf9e FOREIGN KEY (from_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_relationship_severance_events fk_rails_030c916965; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_relationship_severance_events
    ADD CONSTRAINT fk_rails_030c916965 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: tag_follows fk_rails_091e831473; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag_follows
    ADD CONSTRAINT fk_rails_091e831473 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: backups fk_rails_096669d221; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.backups
    ADD CONSTRAINT fk_rails_096669d221 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: tag_follows fk_rails_0deefe597f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag_follows
    ADD CONSTRAINT fk_rails_0deefe597f FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: bookmarks fk_rails_11207ffcfd; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT fk_rails_11207ffcfd FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: account_conversations fk_rails_1491654f9f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_conversations
    ADD CONSTRAINT fk_rails_1491654f9f FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: featured_tags fk_rails_174efcf15f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.featured_tags
    ADD CONSTRAINT fk_rails_174efcf15f FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: bulk_imports fk_rails_1d89c0f8b2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulk_imports
    ADD CONSTRAINT fk_rails_1d89c0f8b2 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: canonical_email_blocks fk_rails_1ecb262096; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canonical_email_blocks
    ADD CONSTRAINT fk_rails_1ecb262096 FOREIGN KEY (reference_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_stats fk_rails_215bb31ff1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_stats
    ADD CONSTRAINT fk_rails_215bb31ff1 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: accounts fk_rails_2320833084; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT fk_rails_2320833084 FOREIGN KEY (moved_to_account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: featured_tags fk_rails_23a9055c7c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.featured_tags
    ADD CONSTRAINT fk_rails_23a9055c7c FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: scheduled_statuses fk_rails_23bd9018f9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scheduled_statuses
    ADD CONSTRAINT fk_rails_23bd9018f9 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_statuses_cleanup_policies fk_rails_23d5f73cfe; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_statuses_cleanup_policies
    ADD CONSTRAINT fk_rails_23d5f73cfe FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: statuses fk_rails_256483a9ab; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT fk_rails_256483a9ab FOREIGN KEY (reblog_of_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: account_notes fk_rails_2801b48f1a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_notes
    ADD CONSTRAINT fk_rails_2801b48f1a FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: custom_filter_statuses fk_rails_2f6d20c0cf; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_filter_statuses
    ADD CONSTRAINT fk_rails_2f6d20c0cf FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: media_attachments fk_rails_31fc5aeef1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media_attachments
    ADD CONSTRAINT fk_rails_31fc5aeef1 FOREIGN KEY (scheduled_status_id) REFERENCES public.scheduled_statuses(id) ON DELETE SET NULL;


--
-- Name: preview_card_trends fk_rails_371593db34; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preview_card_trends
    ADD CONSTRAINT fk_rails_371593db34 FOREIGN KEY (preview_card_id) REFERENCES public.preview_cards(id) ON DELETE CASCADE;


--
-- Name: user_invite_requests fk_rails_3773f15361; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_invite_requests
    ADD CONSTRAINT fk_rails_3773f15361 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: lists fk_rails_3853b78dac; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lists
    ADD CONSTRAINT fk_rails_3853b78dac FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: devices fk_rails_393f74df68; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT fk_rails_393f74df68 FOREIGN KEY (access_token_id) REFERENCES public.oauth_access_tokens(id) ON DELETE CASCADE;


--
-- Name: polls fk_rails_3e0d9f1115; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT fk_rails_3e0d9f1115 FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: media_attachments fk_rails_3ec0cfdd70; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media_attachments
    ADD CONSTRAINT fk_rails_3ec0cfdd70 FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE SET NULL;


--
-- Name: account_moderation_notes fk_rails_3f8b75089b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_moderation_notes
    ADD CONSTRAINT fk_rails_3f8b75089b FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: email_domain_blocks fk_rails_408efe0a15; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_domain_blocks
    ADD CONSTRAINT fk_rails_408efe0a15 FOREIGN KEY (parent_id) REFERENCES public.email_domain_blocks(id) ON DELETE CASCADE;


--
-- Name: list_accounts fk_rails_40f9cc29f1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_accounts
    ADD CONSTRAINT fk_rails_40f9cc29f1 FOREIGN KEY (follow_id) REFERENCES public.follows(id) ON DELETE CASCADE;


--
-- Name: account_deletion_requests fk_rails_45bf2626b9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_deletion_requests
    ADD CONSTRAINT fk_rails_45bf2626b9 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: status_stats fk_rails_4a247aac42; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_stats
    ADD CONSTRAINT fk_rails_4a247aac42 FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: generated_annual_reports fk_rails_4ca37f035c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generated_annual_reports
    ADD CONSTRAINT fk_rails_4ca37f035c FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: reports fk_rails_4e7a498fb4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_rails_4e7a498fb4 FOREIGN KEY (assigned_account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: account_notes fk_rails_4ee4503c69; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_notes
    ADD CONSTRAINT fk_rails_4ee4503c69 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: appeals fk_rails_501c3a6e13; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appeals
    ADD CONSTRAINT fk_rails_501c3a6e13 FOREIGN KEY (rejected_by_account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: severed_relationships fk_rails_5054494e1e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.severed_relationships
    ADD CONSTRAINT fk_rails_5054494e1e FOREIGN KEY (relationship_severance_event_id) REFERENCES public.relationship_severance_events(id) ON DELETE CASCADE;


--
-- Name: notification_policies fk_rails_506d62f0da; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_policies
    ADD CONSTRAINT fk_rails_506d62f0da FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: notification_requests fk_rails_5632f121b4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_requests
    ADD CONSTRAINT fk_rails_5632f121b4 FOREIGN KEY (from_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: mentions fk_rails_59edbe2887; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT fk_rails_59edbe2887 FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: custom_filter_keywords fk_rails_5a49a74012; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_filter_keywords
    ADD CONSTRAINT fk_rails_5a49a74012 FOREIGN KEY (custom_filter_id) REFERENCES public.custom_filters(id) ON DELETE CASCADE;


--
-- Name: conversation_mutes fk_rails_5ab139311f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversation_mutes
    ADD CONSTRAINT fk_rails_5ab139311f FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: polls fk_rails_5b19a0c011; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT fk_rails_5b19a0c011 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: notification_requests fk_rails_61c7aa9c1f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_requests
    ADD CONSTRAINT fk_rails_61c7aa9c1f FOREIGN KEY (last_status_id) REFERENCES public.statuses(id) ON DELETE SET NULL;


--
-- Name: users fk_rails_642f17018b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_642f17018b FOREIGN KEY (role_id) REFERENCES public.user_roles(id) ON DELETE SET NULL;


--
-- Name: status_pins fk_rails_65c05552f1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_pins
    ADD CONSTRAINT fk_rails_65c05552f1 FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: status_trends fk_rails_68c610dc1a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_trends
    ADD CONSTRAINT fk_rails_68c610dc1a FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: account_conversations fk_rails_6f5278b6e9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_conversations
    ADD CONSTRAINT fk_rails_6f5278b6e9 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: announcement_reactions fk_rails_7444ad831f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_reactions
    ADD CONSTRAINT fk_rails_7444ad831f FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: web_push_subscriptions fk_rails_751a9f390b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.web_push_subscriptions
    ADD CONSTRAINT fk_rails_751a9f390b FOREIGN KEY (access_token_id) REFERENCES public.oauth_access_tokens(id) ON DELETE CASCADE;


--
-- Name: notification_permissions fk_rails_7c0bed08df; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_permissions
    ADD CONSTRAINT fk_rails_7c0bed08df FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: report_notes fk_rails_7fa83a61eb; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.report_notes
    ADD CONSTRAINT fk_rails_7fa83a61eb FOREIGN KEY (report_id) REFERENCES public.reports(id) ON DELETE CASCADE;


--
-- Name: list_accounts fk_rails_85fee9d6ab; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_accounts
    ADD CONSTRAINT fk_rails_85fee9d6ab FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: notification_requests fk_rails_881c7f71c4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_requests
    ADD CONSTRAINT fk_rails_881c7f71c4 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_relationship_severance_events fk_rails_8a34c3a361; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_relationship_severance_events
    ADD CONSTRAINT fk_rails_8a34c3a361 FOREIGN KEY (relationship_severance_event_id) REFERENCES public.relationship_severance_events(id) ON DELETE CASCADE;


--
-- Name: custom_filters fk_rails_8b8d786993; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_filters
    ADD CONSTRAINT fk_rails_8b8d786993 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_warnings fk_rails_8f2bab4b16; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_warnings
    ADD CONSTRAINT fk_rails_8f2bab4b16 FOREIGN KEY (report_id) REFERENCES public.reports(id) ON DELETE CASCADE;


--
-- Name: users fk_rails_8fb2a43e88; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_8fb2a43e88 FOREIGN KEY (invite_id) REFERENCES public.invites(id) ON DELETE SET NULL;


--
-- Name: statuses fk_rails_94a6f70399; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT fk_rails_94a6f70399 FOREIGN KEY (in_reply_to_id) REFERENCES public.statuses(id) ON DELETE SET NULL;


--
-- Name: severed_relationships fk_rails_98ff099d4c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.severed_relationships
    ADD CONSTRAINT fk_rails_98ff099d4c FOREIGN KEY (local_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: announcement_mutes fk_rails_9c99f8e835; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_mutes
    ADD CONSTRAINT fk_rails_9c99f8e835 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: appeals fk_rails_9deb2f63ad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appeals
    ADD CONSTRAINT fk_rails_9deb2f63ad FOREIGN KEY (approved_by_account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: bookmarks fk_rails_9f6ac182a6; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT fk_rails_9f6ac182a6 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: announcement_reactions fk_rails_a1226eaa5c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_reactions
    ADD CONSTRAINT fk_rails_a1226eaa5c FOREIGN KEY (announcement_id) REFERENCES public.announcements(id) ON DELETE CASCADE;


--
-- Name: account_pins fk_rails_a176e26c37; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_pins
    ADD CONSTRAINT fk_rails_a176e26c37 FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: encrypted_messages fk_rails_a42ad0f8d5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.encrypted_messages
    ADD CONSTRAINT fk_rails_a42ad0f8d5 FOREIGN KEY (from_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: webauthn_credentials fk_rails_a4355aef77; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.webauthn_credentials
    ADD CONSTRAINT fk_rails_a4355aef77 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: account_warnings fk_rails_a65a1bf71b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_warnings
    ADD CONSTRAINT fk_rails_a65a1bf71b FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: status_trends fk_rails_a6b527ea49; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_trends
    ADD CONSTRAINT fk_rails_a6b527ea49 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: poll_votes fk_rails_a6e6974b7e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT fk_rails_a6e6974b7e FOREIGN KEY (poll_id) REFERENCES public.polls(id) ON DELETE CASCADE;


--
-- Name: markers fk_rails_a7009bc2b6; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.markers
    ADD CONSTRAINT fk_rails_a7009bc2b6 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: admin_action_logs fk_rails_a7667297fa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_action_logs
    ADD CONSTRAINT fk_rails_a7667297fa FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: devices fk_rails_a796b75798; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT fk_rails_a796b75798 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_warnings fk_rails_a7ebbb1e37; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_warnings
    ADD CONSTRAINT fk_rails_a7ebbb1e37 FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: encrypted_messages fk_rails_a83e4df7ae; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.encrypted_messages
    ADD CONSTRAINT fk_rails_a83e4df7ae FOREIGN KEY (device_id) REFERENCES public.devices(id) ON DELETE CASCADE;


--
-- Name: status_edits fk_rails_a960f234a0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_edits
    ADD CONSTRAINT fk_rails_a960f234a0 FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: appeals fk_rails_a99f14546e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appeals
    ADD CONSTRAINT fk_rails_a99f14546e FOREIGN KEY (account_warning_id) REFERENCES public.account_warnings(id) ON DELETE CASCADE;


--
-- Name: follow_recommendation_mutes fk_rails_a9f09ec9a8; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follow_recommendation_mutes
    ADD CONSTRAINT fk_rails_a9f09ec9a8 FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: web_push_subscriptions fk_rails_b006f28dac; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.web_push_subscriptions
    ADD CONSTRAINT fk_rails_b006f28dac FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: poll_votes fk_rails_b6c18cf44a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT fk_rails_b6c18cf44a FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: announcement_reactions fk_rails_b742c91c0e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_reactions
    ADD CONSTRAINT fk_rails_b742c91c0e FOREIGN KEY (custom_emoji_id) REFERENCES public.custom_emojis(id) ON DELETE CASCADE;


--
-- Name: account_migrations fk_rails_c9f701caaf; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_migrations
    ADD CONSTRAINT fk_rails_c9f701caaf FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: report_notes fk_rails_cae66353f3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.report_notes
    ADD CONSTRAINT fk_rails_cae66353f3 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: follow_recommendation_mutes fk_rails_d36abd69ea; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follow_recommendation_mutes
    ADD CONSTRAINT fk_rails_d36abd69ea FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: bulk_import_rows fk_rails_d39af34335; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bulk_import_rows
    ADD CONSTRAINT fk_rails_d39af34335 FOREIGN KEY (bulk_import_id) REFERENCES public.bulk_imports(id) ON DELETE CASCADE;


--
-- Name: one_time_keys fk_rails_d3edd8c878; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.one_time_keys
    ADD CONSTRAINT fk_rails_d3edd8c878 FOREIGN KEY (device_id) REFERENCES public.devices(id) ON DELETE CASCADE;


--
-- Name: account_pins fk_rails_d44979e5dd; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_pins
    ADD CONSTRAINT fk_rails_d44979e5dd FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_migrations fk_rails_d9a8dad070; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_migrations
    ADD CONSTRAINT fk_rails_d9a8dad070 FOREIGN KEY (target_account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: status_edits fk_rails_dc8988c545; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_edits
    ADD CONSTRAINT fk_rails_dc8988c545 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: account_moderation_notes fk_rails_dd62ed5ac3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_moderation_notes
    ADD CONSTRAINT fk_rails_dd62ed5ac3 FOREIGN KEY (target_account_id) REFERENCES public.accounts(id);


--
-- Name: statuses_tags fk_rails_df0fe11427; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.statuses_tags
    ADD CONSTRAINT fk_rails_df0fe11427 FOREIGN KEY (status_id) REFERENCES public.statuses(id) ON DELETE CASCADE;


--
-- Name: follow_recommendation_suppressions fk_rails_dfb9a1dbe2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.follow_recommendation_suppressions
    ADD CONSTRAINT fk_rails_dfb9a1dbe2 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: custom_filter_statuses fk_rails_e2ddaf5b14; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_filter_statuses
    ADD CONSTRAINT fk_rails_e2ddaf5b14 FOREIGN KEY (custom_filter_id) REFERENCES public.custom_filters(id) ON DELETE CASCADE;


--
-- Name: announcement_mutes fk_rails_e35401adf1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcement_mutes
    ADD CONSTRAINT fk_rails_e35401adf1 FOREIGN KEY (announcement_id) REFERENCES public.announcements(id) ON DELETE CASCADE;


--
-- Name: notification_permissions fk_rails_e3e0aaad70; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_permissions
    ADD CONSTRAINT fk_rails_e3e0aaad70 FOREIGN KEY (from_account_id) REFERENCES public.accounts(id);


--
-- Name: login_activities fk_rails_e4b6396b41; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_activities
    ADD CONSTRAINT fk_rails_e4b6396b41 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: list_accounts fk_rails_e54e356c88; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_accounts
    ADD CONSTRAINT fk_rails_e54e356c88 FOREIGN KEY (list_id) REFERENCES public.lists(id) ON DELETE CASCADE;


--
-- Name: appeals fk_rails_ea84881569; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appeals
    ADD CONSTRAINT fk_rails_ea84881569 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: users fk_rails_ecc9536e7c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_ecc9536e7c FOREIGN KEY (created_by_application_id) REFERENCES public.oauth_applications(id) ON DELETE SET NULL;


--
-- Name: list_accounts fk_rails_f11f9d1fcc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_accounts
    ADD CONSTRAINT fk_rails_f11f9d1fcc FOREIGN KEY (follow_request_id) REFERENCES public.follow_requests(id) ON DELETE CASCADE;


--
-- Name: severed_relationships fk_rails_f7afd97ba4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.severed_relationships
    ADD CONSTRAINT fk_rails_f7afd97ba4 FOREIGN KEY (remote_account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: tombstones fk_rails_f95b861449; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tombstones
    ADD CONSTRAINT fk_rails_f95b861449 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: account_aliases fk_rails_fc91575d08; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_aliases
    ADD CONSTRAINT fk_rails_fc91575d08 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: invites fk_rails_ff69dbb2ac; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT fk_rails_ff69dbb2ac FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: account_summaries; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

-- REFRESH MATERIALIZED VIEW public.account_summaries;


-- --
-- -- Name: global_follow_recommendations; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
-- --

-- REFRESH MATERIALIZED VIEW public.global_follow_recommendations;


-- --
-- -- Name: instances; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
-- --

-- REFRESH MATERIALIZED VIEW public.instances;


-- --
-- -- PostgreSQL database dump complete
-- --

