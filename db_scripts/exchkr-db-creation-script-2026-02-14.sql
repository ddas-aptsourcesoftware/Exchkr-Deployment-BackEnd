--
-- PostgreSQL database dump
--
SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: exchkr; Type: DATABASE; Schema: -; Owner: postgres
--
CREATE DATABASE exchkr WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'English_United States.1252' LC_CTYPE = 'English_United States.1252';


ALTER DATABASE exchkr OWNER TO postgres;

connect exchkr

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--
CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--
COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;
SET default_tablespace = '';
SET default_with_oids = false;


--
-- Name: ecm_budget_category_master; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_budget_category_master (
    category_id bigint NOT NULL,
    club_id bigint NOT NULL,
    category_name character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

COMMENT ON TABLE ecm_budget_category_master IS 'Defines available budget categories per club.';


--
-- Name: ecm_budget_category_master_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE ecm_budget_category_master_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ecm_budget_category_master_category_id_seq OWNED BY ecm_budget_category_master.category_id;


--
-- Name: ecm_club_budget_categories; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_club_budget_categories (
    allocation_id bigint NOT NULL,
    budget_id bigint NOT NULL,
    category_id bigint NOT NULL,
    total_budgeted numeric(38,2) DEFAULT 0.00 NOT NULL,
    total_spent numeric(38,2) DEFAULT 0.00 NOT NULL
);

COMMENT ON TABLE ecm_club_budget_categories IS 'Stores the actual money allocated to specific categories for a budget year.';


--
-- Name: ecm_club_budget_categories_allocation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE ecm_club_budget_categories_allocation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ecm_club_budget_categories_allocation_id_seq OWNED BY ecm_club_budget_categories.allocation_id;


--
-- Name: ecm_club_budgets; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_club_budgets (
    budget_id bigint NOT NULL,
    club_id bigint NOT NULL,
    total_budget numeric(38,2) NOT NULL,
    fiscal_year integer NOT NULL,
    created_by bigint NOT NULL,
    active_ind integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: ecm_club_budgets_budget_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE ecm_club_budgets_budget_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ecm_club_budgets_budget_id_seq OWNED BY ecm_club_budgets.budget_id;


--
-- Name: ecm_club_stripe_account; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_club_stripe_account (
    club_id bigint NOT NULL,
    stripe_account_id character varying(255) NOT NULL,
    stripe_bank_account_id character varying(255),
    stripe_account_status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    payouts_enabled boolean DEFAULT false,
    charges_enabled boolean DEFAULT false,
    created_on timestamp with time zone DEFAULT now(),
    updated_on timestamp with time zone DEFAULT now(),
    last_updated_by_user_id bigint,
    created_by_user_id bigint,
    CONSTRAINT chk_ecm_club_stripe_account_status CHECK (((stripe_account_status)::text = ANY (ARRAY[('Pending'::character varying)::text, ('Enabled'::character varying)::text, ('Restricted'::character varying)::text])))
);

COMMENT ON TABLE ecm_club_stripe_account IS 'Stores Stripe Express account and payout bank details for each club';
COMMENT ON COLUMN ecm_club_stripe_account.club_id IS 'Club identifier, references ecm_clubs table';
COMMENT ON COLUMN ecm_club_stripe_account.stripe_account_id IS 'Stripe Express account ID';
COMMENT ON COLUMN ecm_club_stripe_account.stripe_bank_account_id IS 'Stripe external bank account ID currently used for payouts';
COMMENT ON COLUMN ecm_club_stripe_account.stripe_account_status IS 'Tracks current onboarding stage: pending, active, restricted';
COMMENT ON COLUMN ecm_club_stripe_account.payouts_enabled IS 'True if Stripe can send payouts to the connected bank account';
COMMENT ON COLUMN ecm_club_stripe_account.charges_enabled IS 'True if Stripe can receive charges';
COMMENT ON COLUMN ecm_club_stripe_account.created_on IS 'Record creation timestamp';
COMMENT ON COLUMN ecm_club_stripe_account.updated_on IS 'Last status update timestamp';
COMMENT ON COLUMN ecm_club_stripe_account.last_updated_by_user_id IS 'User who last updated this Stripe account record';


--
-- Name: ecm_clubs_s; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE ecm_clubs_s
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ecm_clubs; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_clubs (
    club_id bigint DEFAULT nextval('ecm_clubs_s'::regclass) NOT NULL,
    club_name character varying(255),
    active_ind smallint DEFAULT 1,
    created_by_user_id bigint,
    created_on timestamp with time zone DEFAULT now(),
    last_updated_by_user_id bigint,
    last_updated_on timestamp with time zone DEFAULT now(),
    school_name character varying(255) DEFAULT ''::text NOT NULL
);

COMMENT ON COLUMN ecm_clubs.club_id IS 'Club primary key';
COMMENT ON COLUMN ecm_clubs.club_name IS 'Club name';
COMMENT ON COLUMN ecm_clubs.active_ind IS 'Club''s active indicator. 1=Active 0=Inactive';
COMMENT ON COLUMN ecm_clubs.created_by_user_id IS 'Club created by';
COMMENT ON COLUMN ecm_clubs.created_on IS 'Club created on';
COMMENT ON COLUMN ecm_clubs.last_updated_by_user_id IS 'Club last updated by';
COMMENT ON COLUMN ecm_clubs.last_updated_on IS 'Club last updated on';


--
-- Name: ecm_clubs_donations_s; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE ecm_clubs_donations_s
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ecm_clubs_donations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_clubs_donations (
    donation_id bigint DEFAULT nextval('ecm_clubs_donations_s'::regclass) NOT NULL,
    club_id bigint NOT NULL,
    donator_name character varying(255) NOT NULL,
    donator_email character varying(255) NOT NULL,
    amount_usd numeric(14,2) NOT NULL,
    donation_date timestamp with time zone DEFAULT now() NOT NULL,
    stripe_ref_id character varying(255),
    is_visible_to_club smallint DEFAULT 1 NOT NULL,
    CONSTRAINT ecm_donation_amount_chk CHECK ((amount_usd > (0)::numeric)),
    CONSTRAINT ecm_donation_visible_chk CHECK ((is_visible_to_club = ANY (ARRAY[0, 1])))
);

COMMENT ON COLUMN ecm_clubs_donations.donation_id IS 'Primary key for club donation';
COMMENT ON COLUMN ecm_clubs_donations.club_id IS 'Club ID that received the donation';
COMMENT ON COLUMN ecm_clubs_donations.donator_name IS 'Name of the person who made the donation';
COMMENT ON COLUMN ecm_clubs_donations.donator_email IS 'Email address of the donator';
COMMENT ON COLUMN ecm_clubs_donations.amount_usd IS 'Donation amount in USD';
COMMENT ON COLUMN ecm_clubs_donations.donation_date IS 'Timestamp when the donation was made';
COMMENT ON COLUMN ecm_clubs_donations.stripe_ref_id IS 'Stripe reference ID for the donation payment';
COMMENT ON COLUMN ecm_clubs_donations.is_visible_to_club IS 'Indicates whether donation details are visible on the club dashboard (1 = visible, 0 = hidden)';


--
-- Name: ecm_clubs_transactions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_clubs_transactions (
    trans_id bigint NOT NULL,
    club_id bigint NOT NULL,
    done_by_user_id bigint,
    trans_date timestamp with time zone NOT NULL,
    description character varying(255) NOT NULL,
    category character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    amount numeric(38,2) NOT NULL,
    status character varying(255) NOT NULL,
    stripe_ref_id character varying(255),
    paid_to_user_id bigint,
    due_id bigint,
    platform_fees numeric(38,2) DEFAULT 0.00,
    payment_gateway_service_charge numeric(38,2) DEFAULT 0.00,
    public_donation_id bigint
);


--
-- Name: ecm_clubs_transactions_trans_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE ecm_clubs_transactions_trans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ecm_clubs_transactions_trans_id_seq OWNED BY ecm_clubs_transactions.trans_id;


--
-- Name: ecm_invoice_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE ecm_invoice_details_id_seq
    START WITH 11
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ecm_invoice_details; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_invoice_details (
    invoice_detail_id bigint DEFAULT nextval('ecm_invoice_details_id_seq'::regclass) NOT NULL,
    invoice_id bigint DEFAULT 0 NOT NULL,
    line_item_description character varying(255) DEFAULT ''::text,
    line_item_amount double precision DEFAULT 0.00,
    platform_fees double precision DEFAULT 0.00,
    payment_gateway_service_charge double precision DEFAULT 0.00,
    active_ind smallint DEFAULT 1,
    created_by bigint DEFAULT 0 NOT NULL,
    created_on timestamp with time zone DEFAULT now()
);

COMMENT ON COLUMN ecm_invoice_details.invoice_detail_id IS 'Invoice detail ID as primary key';
COMMENT ON COLUMN ecm_invoice_details.invoice_id IS 'Invoice header ID. Refers to ecm_invoice_headers table on invoice_id';
COMMENT ON COLUMN ecm_invoice_details.line_item_description IS 'Invoice line item description';
COMMENT ON COLUMN ecm_invoice_details.line_item_amount IS 'Invoice line item amount';
COMMENT ON COLUMN ecm_invoice_details.platform_fees IS 'Exchkr platform fees';
COMMENT ON COLUMN ecm_invoice_details.payment_gateway_service_charge IS 'Payment gateway service charge';
COMMENT ON COLUMN ecm_invoice_details.active_ind IS 'Active indicator 1=Active 0=Inactive';
COMMENT ON COLUMN ecm_invoice_details.created_by IS 'Officer member ID, who has created the invoice';
COMMENT ON COLUMN ecm_invoice_details.created_on IS 'Invoice created on';


--
-- Name: ecm_invoice_headers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE ecm_invoice_headers_id_seq
    START WITH 7
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ecm_invoice_headers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_invoice_headers (
    invoice_id bigint DEFAULT nextval('ecm_invoice_headers_id_seq'::regclass) NOT NULL,
    club_id bigint DEFAULT 0 NOT NULL,
    invoice_title character varying(255) DEFAULT ''::text,
    invoice_creation_date timestamp with time zone DEFAULT now(),
    invoice_due_date timestamp with time zone DEFAULT now(),
    invoice_total_amount numeric(38,2) DEFAULT 0.00,
    additional_note character varying(255) DEFAULT ''::text,
    invoice_send_to text DEFAULT ''::text,
    is_paid smallint DEFAULT 0,
    active_ind smallint DEFAULT 1,
    created_by bigint DEFAULT 0 NOT NULL,
    created_on timestamp with time zone DEFAULT now(),
    platform_fees numeric(38,2) DEFAULT 0.00,
    payment_gateway_service_charge numeric(38,2) DEFAULT 0.00
);

COMMENT ON COLUMN ecm_invoice_headers.invoice_id IS 'Invoice header ID as primary key';
COMMENT ON COLUMN ecm_invoice_headers.club_id IS 'Club ID. Refers to ecm_clubs table on club_id';
COMMENT ON COLUMN ecm_invoice_headers.invoice_title IS 'Invoice title';
COMMENT ON COLUMN ecm_invoice_headers.invoice_creation_date IS 'Invoice creation date';
COMMENT ON COLUMN ecm_invoice_headers.invoice_due_date IS 'Invoice due date';
COMMENT ON COLUMN ecm_invoice_headers.invoice_total_amount IS 'Invoice total amount';
COMMENT ON COLUMN ecm_invoice_headers.additional_note IS 'Additional note';
COMMENT ON COLUMN ecm_invoice_headers.invoice_send_to IS 'Member''s emails as a comma separated value';
COMMENT ON COLUMN ecm_invoice_headers.is_paid IS 'Invoice payment status 1=Paid 0=Un-Paid';
COMMENT ON COLUMN ecm_invoice_headers.active_ind IS 'Active indicator 1=Active 0=Inactive';
COMMENT ON COLUMN ecm_invoice_headers.created_by IS 'Officer member ID, who has created the invoice';
COMMENT ON COLUMN ecm_invoice_headers.created_on IS 'Invoice created on';


--
-- Name: ecm_invoice_member_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE ecm_invoice_member_mapping_id_seq
    START WITH 9
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ecm_invoice_member_mapping; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_invoice_member_mapping (
    invoice_member_mapping_id bigint DEFAULT nextval('ecm_invoice_member_mapping_id_seq'::regclass) NOT NULL,
    invoice_id bigint DEFAULT 0 NOT NULL,
    club_id bigint DEFAULT 0 NOT NULL,
    member_id bigint DEFAULT 0 NOT NULL,
    invoice_file_name character varying(255) DEFAULT ''::text,
    created_by bigint DEFAULT 0 NOT NULL,
    created_on timestamp with time zone DEFAULT now()
);

COMMENT ON COLUMN ecm_invoice_member_mapping.invoice_member_mapping_id IS 'Invoice member mapping ID as primary key';
COMMENT ON COLUMN ecm_invoice_member_mapping.invoice_id IS 'Invoice header ID. Refers to ecm_invoice_headers(invoice_id)';
COMMENT ON COLUMN ecm_invoice_member_mapping.club_id IS 'Club ID. Refers to ecm_clubs(club_id)';
COMMENT ON COLUMN ecm_invoice_member_mapping.member_id IS 'Club member ID. Refers to ecm_users(user_id)';
COMMENT ON COLUMN ecm_invoice_member_mapping.invoice_file_name IS 'Invoice PDF file name';
COMMENT ON COLUMN ecm_invoice_member_mapping.created_by IS 'Officer member ID, who created the invoice';
COMMENT ON COLUMN ecm_invoice_member_mapping.created_on IS 'Invoice creation timestamp';


--
-- Name: ecm_member_dues; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_member_dues (
    due_id bigint NOT NULL,
    club_id bigint NOT NULL,
    description character varying(255) NOT NULL,
    total_amount numeric(38,2) NOT NULL,
    paid_amount numeric(38,2) DEFAULT 0.00,
    due_date date NOT NULL,
    status character varying(255) NOT NULL,
    last_payment_date timestamp(6) with time zone,
    created_by_user_id bigint NOT NULL,
    assigned_user_id bigint NOT NULL,
    invoice_id bigint
);


--
-- Name: ecm_member_dues_due_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE ecm_member_dues_due_id_seq
    START WITH 8
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ecm_member_dues_due_id_seq1; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE ecm_member_dues_due_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ecm_member_dues_due_id_seq1 OWNED BY ecm_member_dues.due_id;


--
-- Name: ecm_member_stripe_account; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_member_stripe_account (
    user_id bigint NOT NULL,
    stripe_account_id character varying(255) NOT NULL,
    stripe_bank_account_id character varying(255),
    stripe_account_status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    payouts_enabled boolean DEFAULT false,
    charges_enabled boolean DEFAULT false,
    created_on timestamp with time zone DEFAULT now(),
    updated_on timestamp with time zone DEFAULT now(),
    CONSTRAINT chk_ecm_member_stripe_account_payouts_ready CHECK ((((payouts_enabled = false) AND (stripe_bank_account_id IS NULL)) OR ((payouts_enabled = true) AND (stripe_bank_account_id IS NOT NULL)))),
    CONSTRAINT chk_ecm_member_stripe_account_status CHECK (((stripe_account_status)::text = ANY (ARRAY[('Pending'::character varying)::text, ('Enabled'::character varying)::text, ('Restricted'::character varying)::text])))
);


--
-- Name: ecm_privileges_s; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE ecm_privileges_s
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ecm_privileges; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_privileges (
    privilege_id bigint DEFAULT nextval('ecm_privileges_s'::regclass) NOT NULL,
    privilege_category text,
    privilege_name text,
    comment text,
    active_ind smallint DEFAULT 1,
    created_by_user_id bigint,
    created_on timestamp with time zone DEFAULT now(),
    last_updated_by_user_id bigint,
    last_updated_on timestamp with time zone DEFAULT now()
);

COMMENT ON COLUMN ecm_privileges.privilege_id IS 'Privilege primary key';
COMMENT ON COLUMN ecm_privileges.privilege_category IS 'Privilege category';
COMMENT ON COLUMN ecm_privileges.privilege_name IS 'Privilege name';
COMMENT ON COLUMN ecm_privileges.comment IS 'Privilege comment';
COMMENT ON COLUMN ecm_privileges.active_ind IS 'Privilege''s active indicator. 1=Active 0=Inactive';
COMMENT ON COLUMN ecm_privileges.created_by_user_id IS 'Privilege created by';
COMMENT ON COLUMN ecm_privileges.created_on IS 'Privilege created on';
COMMENT ON COLUMN ecm_privileges.last_updated_by_user_id IS 'Privilege last updated by';
COMMENT ON COLUMN ecm_privileges.last_updated_on IS 'Privilege last updated on';


--
-- Name: ecm_reimbursement_requests_s; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE ecm_reimbursement_requests_s
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ecm_reimbursement_requests; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_reimbursement_requests (
    reimbursement_id bigint DEFAULT nextval('ecm_reimbursement_requests_s'::regclass) NOT NULL,
    club_id bigint NOT NULL,
    submitted_by_member_id bigint NOT NULL,
    receipt_file_name character varying(255) NOT NULL,
    receipt_file_system_name character varying(255) NOT NULL,
    amount_usd numeric(14,2) NOT NULL,
    purchase_date date NOT NULL,
    category character varying(50) NOT NULL,
    description character varying(255),
    status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    submitted_at timestamp with time zone DEFAULT now() NOT NULL,
    rejected_by_officer_id bigint,
    rejected_at timestamp with time zone,
    stripe_ref_id character varying(255),
    approved_by_officer_id bigint,
    approved_at timestamp with time zone,
    reject_reason character varying(255),
    paid_transaction_id bigint,
    CONSTRAINT ecm_reimbursement_approved_chk CHECK ((((((status)::text = ANY ((ARRAY['APPROVED'::character varying, 'PAID'::character varying])::text[])) AND (approved_by_officer_id IS NOT NULL)) AND (approved_at IS NOT NULL)) OR ((((status)::text <> ALL ((ARRAY['APPROVED'::character varying, 'PAID'::character varying])::text[])) AND (approved_by_officer_id IS NULL)) AND (approved_at IS NULL)))),
    CONSTRAINT ecm_reimbursement_requests_amount_usd_check CHECK ((amount_usd > (0)::numeric)),
    CONSTRAINT ecm_reimbursement_status_chk CHECK (((status)::text = ANY (ARRAY[('PENDING'::character varying)::text, ('APPROVED'::character varying)::text, ('REJECTED'::character varying)::text, ('PAID'::character varying)::text])))
);

COMMENT ON COLUMN ecm_reimbursement_requests.reimbursement_id IS 'Primary key for reimbursement request';
COMMENT ON COLUMN ecm_reimbursement_requests.club_id IS 'Club ID for which the reimbursement is requested';
COMMENT ON COLUMN ecm_reimbursement_requests.submitted_by_member_id IS 'Member (user) who submitted the reimbursement';
COMMENT ON COLUMN ecm_reimbursement_requests.receipt_file_name IS 'Original uploaded receipt file name';
COMMENT ON COLUMN ecm_reimbursement_requests.receipt_file_system_name IS 'System generated receipt file name with epoch timestamp';
COMMENT ON COLUMN ecm_reimbursement_requests.amount_usd IS 'Reimbursement amount in USD';
COMMENT ON COLUMN ecm_reimbursement_requests.purchase_date IS 'Date when the expense was incurred';
COMMENT ON COLUMN ecm_reimbursement_requests.category IS 'Expense category such as travel, food, office etc';
COMMENT ON COLUMN ecm_reimbursement_requests.description IS 'Expense description provided by the member';
COMMENT ON COLUMN ecm_reimbursement_requests.status IS 'Status of reimbursement: PENDING, APPROVED, REJECTED or PAID';
COMMENT ON COLUMN ecm_reimbursement_requests.submitted_at IS 'Timestamp when reimbursement was submitted';
COMMENT ON COLUMN ecm_reimbursement_requests.rejected_by_officer_id IS 'Officer user ID who rejected the reimbursement';
COMMENT ON COLUMN ecm_reimbursement_requests.rejected_at IS 'Timestamp when reimbursement was rejected';
COMMENT ON COLUMN ecm_reimbursement_requests.stripe_ref_id IS 'Stripe transaction or payout reference ID when reimbursement is paid';
COMMENT ON COLUMN ecm_reimbursement_requests.approved_by_officer_id IS 'Officer user ID who approved the reimbursement';
COMMENT ON COLUMN ecm_reimbursement_requests.approved_at IS 'Timestamp when reimbursement was approved';
COMMENT ON COLUMN ecm_reimbursement_requests.reject_reason IS 'Reason provided by officer when reimbursement is rejected';


--
-- Name: ecm_role_privilege_mappings_s; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE ecm_role_privilege_mappings_s
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ecm_role_privilege_mappings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_role_privilege_mappings (
    role_privilege_mapping_id bigint DEFAULT nextval('ecm_role_privilege_mappings_s'::regclass) NOT NULL,
    role_id bigint NOT NULL,
    privilege_id bigint NOT NULL,
    active_ind smallint DEFAULT 1,
    created_by_user_id bigint,
    created_on timestamp with time zone DEFAULT now(),
    last_updated_by_user_id bigint,
    last_updated_on timestamp with time zone DEFAULT now()
);


--
-- Name: ecm_roles_s; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE ecm_roles_s
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ecm_roles; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_roles (
    role_id bigint DEFAULT nextval('ecm_roles_s'::regclass) NOT NULL,
    role_name character varying(255),
    active_ind smallint DEFAULT 1,
    created_by_user_id bigint,
    created_on timestamp with time zone DEFAULT now(),
    last_updated_by_user_id bigint,
    last_updated_on timestamp with time zone DEFAULT now()
);

COMMENT ON COLUMN ecm_roles.role_id IS 'Role primary key';
COMMENT ON COLUMN ecm_roles.role_name IS 'Role name';
COMMENT ON COLUMN ecm_roles.active_ind IS 'Role''s active indicator. 1=Active 0=Inactive';
COMMENT ON COLUMN ecm_roles.created_by_user_id IS 'Role created by';
COMMENT ON COLUMN ecm_roles.created_on IS 'Role created on';
COMMENT ON COLUMN ecm_roles.last_updated_by_user_id IS 'Role last updated by';
COMMENT ON COLUMN ecm_roles.last_updated_on IS 'Role last updated on';


--
-- Name: ecm_token_blacklist; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_token_blacklist (
    jti character varying(255) NOT NULL,
    expiry_date timestamp without time zone NOT NULL
);


--
-- Name: ecm_user_clubs_mappings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_user_clubs_mappings (
    user_id bigint NOT NULL,
    club_id bigint NOT NULL,
    role_id bigint NOT NULL,
    joined_at timestamp with time zone DEFAULT now(),
    status character varying(255) DEFAULT 'Active'::text
);


--
-- Name: ecm_users_s; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE ecm_users_s
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ecm_users; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE ecm_users (
    user_id bigint DEFAULT nextval('ecm_users_s'::regclass) NOT NULL,
    first_name character varying(255),
    middle_name text,
    last_name character varying(255),
    full_name character varying(255) NOT NULL,
    user_name character varying(255) NOT NULL,
    user_pwd character varying(255) NOT NULL,
    address_line_1 text,
    address_line_2 text,
    pin text,
    city text,
    state text,
    country text,
    cell_number text,
    email character varying(255) NOT NULL,
    image_file_name text,
    club_joined_on date DEFAULT now(),
    active_ind smallint DEFAULT 1,
    created_by_user_id bigint,
    created_on timestamp with time zone DEFAULT now(),
    last_updated_by_user_id bigint,
    last_updated_on timestamp with time zone DEFAULT now(),
    authentication_token character varying(255),
    token_expiry timestamp with time zone,
    plaid_access_token character varying(255)
);

COMMENT ON COLUMN ecm_users.user_id IS 'User''s primary key';
COMMENT ON COLUMN ecm_users.first_name IS 'User''s first name';
COMMENT ON COLUMN ecm_users.middle_name IS 'User''s middle name';
COMMENT ON COLUMN ecm_users.last_name IS 'User''s last name';
COMMENT ON COLUMN ecm_users.full_name IS 'User''s full name';
COMMENT ON COLUMN ecm_users.user_name IS 'User''s user name / login id';
COMMENT ON COLUMN ecm_users.user_pwd IS 'User''s password which will be stored encrypted';
COMMENT ON COLUMN ecm_users.address_line_1 IS 'User''s address line 1';
COMMENT ON COLUMN ecm_users.address_line_2 IS 'User''s address line 2';
COMMENT ON COLUMN ecm_users.pin IS 'User''s pin';
COMMENT ON COLUMN ecm_users.city IS 'User''s city';
COMMENT ON COLUMN ecm_users.state IS 'User''s state';
COMMENT ON COLUMN ecm_users.country IS 'User''s country';
COMMENT ON COLUMN ecm_users.cell_number IS 'User''s cell number';
COMMENT ON COLUMN ecm_users.email IS 'User''s email address';
COMMENT ON COLUMN ecm_users.image_file_name IS 'User''s  profile image file name';
COMMENT ON COLUMN ecm_users.club_joined_on IS 'Date on which user joined this club';
COMMENT ON COLUMN ecm_users.active_ind IS 'User''s active indicator. 1=Active 0=Inactive';
COMMENT ON COLUMN ecm_users.created_by_user_id IS 'User created by';
COMMENT ON COLUMN ecm_users.created_on IS 'User created on';
COMMENT ON COLUMN ecm_users.last_updated_by_user_id IS 'User last updated by';
COMMENT ON COLUMN ecm_users.last_updated_on IS 'User last updated on';


--
-- Name: plaid_accounts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE plaid_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    club_id bigint NOT NULL,
    created_by_user_id bigint NOT NULL,
    active_ind boolean DEFAULT true NOT NULL,
    stripe_bank_account_id text,
    access_token character varying(255),
    institution_id character varying(255) NOT NULL,
    institution_name character varying(255),
    item_id character varying(255) NOT NULL,
    account_ids jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    stripe_id character varying(255),
    default_bank_account character varying(255) DEFAULT ''::text NOT NULL
);


ALTER TABLE ONLY ecm_budget_category_master ALTER COLUMN category_id SET DEFAULT nextval('ecm_budget_category_master_category_id_seq'::regclass);

ALTER TABLE ONLY ecm_club_budget_categories ALTER COLUMN allocation_id SET DEFAULT nextval('ecm_club_budget_categories_allocation_id_seq'::regclass);

ALTER TABLE ONLY ecm_club_budgets ALTER COLUMN budget_id SET DEFAULT nextval('ecm_club_budgets_budget_id_seq'::regclass);

ALTER TABLE ONLY ecm_clubs_transactions ALTER COLUMN trans_id SET DEFAULT nextval('ecm_clubs_transactions_trans_id_seq'::regclass);

ALTER TABLE ONLY ecm_member_dues ALTER COLUMN due_id SET DEFAULT nextval('ecm_member_dues_due_id_seq1'::regclass);


--
-- Data for Name: ecm_budget_category_master; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_budget_category_master VALUES (1, 1, 'Marketing Materials', '2026-02-18 15:53:34.91468+05:30', '2026-02-18 15:53:34.91468+05:30');
INSERT INTO ecm_budget_category_master VALUES (2, 1, 'Transportation', '2026-02-18 15:53:34.916679+05:30', '2026-02-18 15:53:34.916679+05:30');
INSERT INTO ecm_budget_category_master VALUES (3, 1, 'Food & Supplies', '2026-02-18 15:53:34.918679+05:30', '2026-02-18 15:53:34.918679+05:30');
INSERT INTO ecm_budget_category_master VALUES (4, 1, 'Groceries', '2026-02-18 15:54:06.535515+05:30', '2026-02-18 15:54:06.535515+05:30');
INSERT INTO ecm_budget_category_master VALUES (5, 1, 'Beverages', '2026-02-18 15:55:34.60984+05:30', '2026-02-18 15:55:34.60984+05:30');
INSERT INTO ecm_budget_category_master VALUES (6, 11, 'Transportation', '2026-02-18 16:42:38.004106+05:30', '2026-02-18 16:42:38.004106+05:30');
INSERT INTO ecm_budget_category_master VALUES (7, 11, 'Marketing', '2026-02-18 16:42:38.009178+05:30', '2026-02-18 16:42:38.01015+05:30');
INSERT INTO ecm_budget_category_master VALUES (8, 11, 'Food', '2026-02-18 16:42:38.015122+05:30', '2026-02-18 16:42:38.015122+05:30');
INSERT INTO ecm_budget_category_master VALUES (9, 11, 'Groceries', '2026-02-18 16:43:40.075761+05:30', '2026-02-18 16:43:40.075761+05:30');
INSERT INTO ecm_budget_category_master VALUES (10, 11, 'Event expenses', '2026-02-18 21:18:59.479066+05:30', '2026-02-18 21:18:59.479066+05:30');
INSERT INTO ecm_budget_category_master VALUES (11, 13, 'Food & Meeting Refreshments', '2026-02-27 11:35:50.273674+05:30', '2026-02-27 11:35:50.273674+05:30');
INSERT INTO ecm_budget_category_master VALUES (12, 13, 'Software Licenses', '2026-02-27 11:35:50.276672+05:30', '2026-02-27 11:35:50.276672+05:30');
INSERT INTO ecm_budget_category_master VALUES (13, 13, 'Marketing Materials', '2026-02-27 11:35:50.278673+05:30', '2026-02-27 11:35:50.278673+05:30');
INSERT INTO ecm_budget_category_master VALUES (14, 13, 'Workshop Supplies', '2026-02-27 11:37:23.692449+05:30', '2026-02-27 11:37:23.692449+05:30');


--
-- Name: ecm_budget_category_master_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
SELECT pg_catalog.setval('ecm_budget_category_master_category_id_seq', 14, true);


--
-- Data for Name: ecm_club_budget_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_club_budget_categories VALUES (1, 1, 3, 5000.00, 0.00);
INSERT INTO ecm_club_budget_categories VALUES (2, 1, 2, 4000.00, 0.00);
INSERT INTO ecm_club_budget_categories VALUES (3, 1, 1, 1000.00, 0.00);
INSERT INTO ecm_club_budget_categories VALUES (4, 1, 4, 2000.00, 0.00);
INSERT INTO ecm_club_budget_categories VALUES (9, 2, 8, 2500.00, 0.00);
INSERT INTO ecm_club_budget_categories VALUES (10, 2, 10, 4000.00, 0.00);
INSERT INTO ecm_club_budget_categories VALUES (6, 2, 7, 3500.00, 0.00);
INSERT INTO ecm_club_budget_categories VALUES (11, 3, 13, 800.00, 0.00);
INSERT INTO ecm_club_budget_categories VALUES (12, 3, 12, 3000.00, 0.00);
INSERT INTO ecm_club_budget_categories VALUES (13, 3, 11, 5000.00, 0.00);


--
-- Name: ecm_club_budget_categories_allocation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
SELECT pg_catalog.setval('ecm_club_budget_categories_allocation_id_seq', 14, true);


--
-- Data for Name: ecm_club_budgets; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_club_budgets VALUES (1, 1, 12000.00, 2026, 12, 1, '2026-02-18 15:54:06.520518+05:30');
INSERT INTO ecm_club_budgets VALUES (2, 11, 10000.00, 2026, 26, 1, '2026-02-18 16:43:40.064765+05:30');
INSERT INTO ecm_club_budgets VALUES (3, 13, 8800.00, 2026, 36, 1, '2026-02-27 11:37:23.682454+05:30');


--
-- Name: ecm_club_budgets_budget_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
SELECT pg_catalog.setval('ecm_club_budgets_budget_id_seq', 3, true);


--
-- Data for Name: ecm_club_stripe_account; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_club_stripe_account VALUES (11, 'acct_1Sp5OXF1BM1shAgT', NULL, 'Enabled', false, false, '2026-01-13 16:34:21.26+05:30', '2026-01-13 16:34:21.26+05:30', NULL, NULL);
INSERT INTO ecm_club_stripe_account VALUES (1, 'acct_1T2OqNFJPBaD3e9l', NULL, 'Enabled', false, false, '2026-02-19 09:58:07.41+05:30', '2026-02-19 10:56:18.766+05:30', NULL, NULL);
INSERT INTO ecm_club_stripe_account VALUES (13, 'acct_1T5JKaFa9QKYbDRG', NULL, 'Enabled', false, false, '2026-02-27 10:41:20.243+05:30', '2026-02-27 10:47:42.624+05:30', NULL, NULL);


--
-- Data for Name: ecm_clubs; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_clubs VALUES (1, 'Stanford Film Society', 1, NULL, '2025-11-28 21:44:10.951+05:30', NULL, '2025-11-28 21:44:10.951+05:30', '');
INSERT INTO ecm_clubs VALUES (2, 'Berkeley Documentary Club', 1, NULL, '2025-11-28 21:44:19.312+05:30', NULL, '2025-11-28 21:44:19.312+05:30', '');
INSERT INTO ecm_clubs VALUES (9, 'USC South Asian Film Collective', 1, NULL, '2025-12-19 15:36:07.159471+05:30', NULL, '2025-12-19 15:36:07.159471+05:30', '');
INSERT INTO ecm_clubs VALUES (5, 'MIT Media Lab Club', 1, NULL, '2025-11-28 21:44:46.167+05:30', NULL, '2025-11-28 21:44:46.167+05:30', '');
INSERT INTO ecm_clubs VALUES (4, 'USC Film Production', 1, NULL, '2025-11-28 21:44:38.21+05:30', NULL, '2025-11-28 21:44:38.21+05:30', '');
INSERT INTO ecm_clubs VALUES (3, 'UCLA Cinema Collective', 1, NULL, '2025-11-28 21:44:29.662+05:30', NULL, '2025-11-28 21:44:29.662+05:30', '');
INSERT INTO ecm_clubs VALUES (11, 'Aptsource', 1, NULL, '2026-01-13 16:29:37.350647+05:30', NULL, '2026-01-13 16:29:37.350647+05:30', 'Exchkr School');
INSERT INTO ecm_clubs VALUES (13, 'Tech Club', 1, NULL, '2026-02-27 10:10:38.187164+05:30', NULL, '2026-02-27 10:10:38.187164+05:30', 'Boston University');


--
-- Data for Name: ecm_clubs_donations; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_clubs_donations VALUES (3, 11, 'Nivin', 'nivinvarghese16@gmail.com', 25.00, '2026-02-11 17:41:16.871+05:30', 'pi_3SzcG5F6a9VUxk6R0Z994YSz', 1);
INSERT INTO ecm_clubs_donations VALUES (4, 11, 'Nivin', 'nivinvarghese16@gmail.com', 100.00, '2026-02-11 17:54:11.688+05:30', 'pi_3SzcSWF6a9VUxk6R0P6UHEW7', 1);
INSERT INTO ecm_clubs_donations VALUES (5, 11, 'Debashis Das', 'debashisd@aptsourcesoftware.com', 50.00, '2026-02-11 20:42:15.107+05:30', 'pi_3Szf3pF6a9VUxk6R1WHdfjzg', 1);
INSERT INTO ecm_clubs_donations VALUES (6, 11, 'Debashis Das', 'debashisd@aptsourcesoftware.com', 125.00, '2026-02-11 21:20:42.95+05:30', 'pi_3SzffCF6a9VUxk6R0UGjWmgd', 1);
INSERT INTO ecm_clubs_donations VALUES (7, 13, 'Christopher Miller', 'nivinv@aptsourcesoftware.com', 100.00, '2026-02-27 11:38:27.415+05:30', 'pi_3T5KD4F6a9VUxk6R0vL3aaWB', 1);


--
-- Name: ecm_clubs_donations_s; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
SELECT pg_catalog.setval('ecm_clubs_donations_s', 7, true);


--
-- Name: ecm_clubs_s; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
SELECT pg_catalog.setval('ecm_clubs_s', 13, true);


--
-- Data for Name: ecm_clubs_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_clubs_transactions VALUES (1, 11, 29, '2026-01-21 19:35:18.56739+05:30', 'Member dues payment', 'Dues', 'Income', 250.00, 'Completed', 'pi_3Ss21lF6a9VUxk6R0VzE2JBk', NULL, 1, 0.00, 0.00, NULL);
INSERT INTO ecm_clubs_transactions VALUES (4, 11, 29, '2026-01-21 21:11:17.48+05:30', 'Club donation', 'Donation', 'Income', 225.00, 'Completed', 'pi_3Ss3WkF6a9VUxk6R1nULoVLJ', NULL, NULL, 0.00, 0.00, NULL);
INSERT INTO ecm_clubs_transactions VALUES (3, 11, 29, '2026-01-21 21:08:09.653322+05:30', 'Member dues payment', 'Dues', 'Income', 350.00, 'Completed', 'pi_3Ss3S6F6a9VUxk6R1SqMfXXV', NULL, 2, 0.00, 0.00, NULL);
INSERT INTO ecm_clubs_transactions VALUES (2, 11, 29, '2026-01-21 19:38:55.914+05:30', 'Club donation', 'Donation', 'Income', 100.00, 'Completed', 'pi_3Ss25NF6a9VUxk6R1edS6sw3', NULL, NULL, 0.00, 0.00, NULL);
INSERT INTO ecm_clubs_transactions VALUES (5, 11, 29, '2026-01-30 19:19:14.594669+05:30', 'Club donation', 'Donation', 'Income', 10.00, 'Completed', 'pi_3SvI4BF6a9VUxk6R1FyIHmOP', NULL, NULL, 0.00, 0.00, NULL);
INSERT INTO ecm_clubs_transactions VALUES (6, 11, 26, '2026-01-31 12:19:40.561087+05:30', 'Club donation', 'Donation', 'Income', 10.00, 'Completed', 'pi_3SvXzTF6a9VUxk6R1tL77dcB', NULL, NULL, 0.00, 0.00, NULL);
INSERT INTO ecm_clubs_transactions VALUES (7, 11, 29, '2026-02-04 21:11:44.327083+05:30', 'Winter ending event', 'Dues', 'Income', 40.00, 'Completed', 'pi_3Sx8CpF6a9VUxk6R0MSVehqf', NULL, 4, 0.00, 0.00, NULL);
INSERT INTO ecm_clubs_transactions VALUES (9, 11, NULL, '2026-02-11 17:41:17.41624+05:30', 'Club donation', 'Public Donation', 'Income', 25.00, 'Completed', 'pi_3SzcG5F6a9VUxk6R0Z994YSz', NULL, NULL, 0.00, 0.00, 3);
INSERT INTO ecm_clubs_transactions VALUES (10, 11, 26, '2026-02-11 17:44:38.126682+05:30', 'Member donation', 'Donation', 'Income', 10.00, 'Completed', 'pi_3SzcJKF6a9VUxk6R14zGIDMi', NULL, NULL, 0.11, 0.61, NULL);
INSERT INTO ecm_clubs_transactions VALUES (11, 11, NULL, '2026-02-11 17:54:11.979891+05:30', 'Club donation', 'Public Donation', 'Income', 100.00, 'Completed', 'pi_3SzcSWF6a9VUxk6R0P6UHEW7', NULL, NULL, 0.00, 0.00, 4);
INSERT INTO ecm_clubs_transactions VALUES (12, 11, 26, '2026-02-11 18:09:58.951592+05:30', 'Member donation', 'Donation', 'Income', 50.00, 'Completed', 'pi_3SzcdJF6a9VUxk6R1yvTqQiL', NULL, NULL, 0.51, 0.41, NULL);
INSERT INTO ecm_clubs_transactions VALUES (13, 11, NULL, '2026-02-11 20:42:34.034513+05:30', 'Club donation', 'Public Donation', 'Income', 50.00, 'Completed', 'pi_3Szf3pF6a9VUxk6R1WHdfjzg', NULL, NULL, 0.00, 0.00, 5);
INSERT INTO ecm_clubs_transactions VALUES (14, 11, NULL, '2026-02-11 21:21:05.220444+05:30', 'Club donation', 'Public Donation', 'Income', 125.00, 'Completed', 'pi_3SzffCF6a9VUxk6R0UGjWmgd', NULL, NULL, 0.00, 0.00, 6);
INSERT INTO ecm_clubs_transactions VALUES (15, 11, 29, '2026-02-13 16:09:10.344538+05:30', 'Member donation', 'Donation', 'Income', 10.00, 'Completed', 'pi_3T0JlvF6a9VUxk6R1BVI5842', NULL, NULL, 0.11, 0.61, NULL);
INSERT INTO ecm_clubs_transactions VALUES (16, 11, 33, '2026-02-18 00:46:32.087369+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 250.00, 'Failed', NULL, 29, NULL, 2.60, 7.85, NULL);
INSERT INTO ecm_clubs_transactions VALUES (19, 11, 26, '2026-02-18 17:03:34.751314+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 100.00, 'Processing', 'pi_3T28znF6a9VUxk6R1oN3pNg2', 26, NULL, 1.04, 3.33, NULL);
INSERT INTO ecm_clubs_transactions VALUES (20, 11, 26, '2026-02-18 17:32:44.048591+05:30', 'neww invoicee', 'Dues', 'Income', 80.00, 'Completed', 'pi_3T29SaF6a9VUxk6R0ouEyrY4', NULL, 11, 0.84, 2.72, NULL);
INSERT INTO ecm_clubs_transactions VALUES (21, 11, 26, '2026-02-18 18:01:02.660484+05:30', 'Member donation', 'Donation', 'Income', 10.00, 'Completed', 'pi_3T29u2F6a9VUxk6R0r9VCKGm', NULL, NULL, 0.11, 0.61, NULL);
INSERT INTO ecm_clubs_transactions VALUES (22, 11, 26, '2026-02-18 18:02:41.624102+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 100.00, 'Processing', 'pi_3T29vUF6a9VUxk6R1PE4RUcm', 26, NULL, 1.04, 3.33, NULL);
INSERT INTO ecm_clubs_transactions VALUES (23, 11, 26, '2026-02-18 18:18:19.479858+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 100.00, 'Completed', 'pi_3T2AAHF6a9VUxk6R0OrHfpLw', 26, NULL, 1.04, 3.33, NULL);
INSERT INTO ecm_clubs_transactions VALUES (24, 11, 26, '2026-02-18 18:32:07.272728+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 150.00, 'Processing', 'pi_3T2AO5F6a9VUxk6R12ajfAnw', 26, NULL, 1.56, 4.84, NULL);
INSERT INTO ecm_clubs_transactions VALUES (25, 11, 26, '2026-02-18 18:37:00.544358+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 180.00, 'Completed', 'pi_3T2ASqF6a9VUxk6R0M4C3Rpg', 26, NULL, 1.88, 5.74, NULL);
INSERT INTO ecm_clubs_transactions VALUES (26, 1, 12, '2026-02-19 11:21:57.774829+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 50.00, 'Processing', 'pi_3T2Q9HF6a9VUxk6R05Zk6grB', 12, NULL, 0.52, 1.82, NULL);
INSERT INTO ecm_clubs_transactions VALUES (28, 1, 12, '2026-02-19 16:28:08.43466+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 70.00, 'Completed', 'pi_3T2UvUF6a9VUxk6R1E2fiF0m', 12, NULL, 0.73, 2.42, NULL);
INSERT INTO ecm_clubs_transactions VALUES (29, 1, 12, '2026-02-19 19:45:53.398424+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 70.00, 'Processing', 'pi_3T2Y0wF6a9VUxk6R0eEpntTa', 12, NULL, 0.73, 2.42, NULL);
INSERT INTO ecm_clubs_transactions VALUES (30, 1, 12, '2026-02-19 19:47:53.707598+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 90.00, 'Processing', 'pi_3T2Y2qF6a9VUxk6R1Kfr3Tqa', 12, NULL, 0.94, 3.02, NULL);
INSERT INTO ecm_clubs_transactions VALUES (31, 11, 26, '2026-02-19 22:18:49.260796+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 190.00, 'Completed', 'pi_3T2aOyF6a9VUxk6R1p6578xJ', 26, NULL, 1.98, 6.04, NULL);
INSERT INTO ecm_clubs_transactions VALUES (32, 1, 12, '2026-02-20 10:56:32.822912+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 95.00, 'Completed', 'pi_3T2mEFF6a9VUxk6R1aDtWKof', 12, NULL, 0.99, 3.18, NULL);
INSERT INTO ecm_clubs_transactions VALUES (33, 1, 12, '2026-02-20 11:05:11.131578+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 25.00, 'Completed', 'pi_3T2mMfF6a9VUxk6R0EAnsxiG', 12, NULL, 0.26, 1.06, NULL);
INSERT INTO ecm_clubs_transactions VALUES (34, 1, 12, '2026-02-20 12:30:51.893711+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 10.00, 'Completed', 'pi_3T2nhNF6a9VUxk6R0XrtkNzk', 12, NULL, 0.11, 0.61, NULL);
INSERT INTO ecm_clubs_transactions VALUES (35, 11, 26, '2026-02-20 14:40:49.502718+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 140.00, 'Completed', 'pi_3T2o64F6a9VUxk6R0HXizWu4', 26, NULL, 1.46, 4.53, NULL);
INSERT INTO ecm_clubs_transactions VALUES (36, 11, 26, '2026-02-20 14:51:47.065107+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 145.00, 'Completed', 'pi_3T2ptpF6a9VUxk6R0mCLtevg', 26, NULL, 1.51, 4.68, NULL);
INSERT INTO ecm_clubs_transactions VALUES (37, 11, 26, '2026-02-20 15:52:52.727524+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 125.00, 'Completed', 'pi_3T2qr7F6a9VUxk6R1gQoZFru', 26, NULL, 1.30, 4.08, NULL);
INSERT INTO ecm_clubs_transactions VALUES (38, 11, 26, '2026-02-24 16:05:00.982258+05:30', 'Member donation', 'Donation', 'Income', 10.00, 'Completed', 'pi_3T4GF3F6a9VUxk6R09c740UI', NULL, NULL, 0.11, 0.61, NULL);
INSERT INTO ecm_clubs_transactions VALUES (27, 11, 26, '2026-02-24 16:15:35.002655+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 180.00, 'Completed', 'pi_3T2QD5F6a9VUxk6R0Dspnw9n', 26, NULL, 1.88, 5.74, NULL);
INSERT INTO ecm_clubs_transactions VALUES (18, 11, 33, '2026-02-24 16:16:03.778345+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 50.00, 'Completed', 'pi_3T1tmIF6a9VUxk6R1lUN22QE', 29, NULL, 0.52, 1.82, NULL);
INSERT INTO ecm_clubs_transactions VALUES (17, 11, 33, '2026-02-24 16:16:47.213403+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 250.00, 'Completed', 'pi_3T1tlAF6a9VUxk6R1xdqI1nb', 29, NULL, 2.60, 7.85, NULL);
INSERT INTO ecm_clubs_transactions VALUES (39, 11, 26, '2026-02-25 18:33:08.367426+05:30', 'Member donation', 'Donation', 'Income', 10.00, 'Completed', 'pi_3T4hjrF6a9VUxk6R0mmZXRiD', NULL, NULL, 0.11, 0.61, NULL);
INSERT INTO ecm_clubs_transactions VALUES (40, 11, 26, '2026-02-25 18:34:04.321902+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 130.00, 'Completed', 'pi_3T4hkmF6a9VUxk6R1MwUFK5E', 26, NULL, 1.36, 4.23, NULL);
INSERT INTO ecm_clubs_transactions VALUES (41, 13, 37, '2026-02-27 11:11:47.286728+05:30', 'Member donation', 'Donation', 'Income', 100.00, 'Completed', 'pi_3T5JnjF6a9VUxk6R0asCsqfh', NULL, NULL, 1.04, 3.33, NULL);
INSERT INTO ecm_clubs_transactions VALUES (43, 13, 36, '2026-02-27 11:51:59.335243+05:30', 'Club reimbursement payment', 'Reimbursement', 'Expense', 300.00, 'Completed', 'pi_3T5KQjF6a9VUxk6R142mztiQ', 37, NULL, 3.12, 9.36, NULL);
INSERT INTO ecm_clubs_transactions VALUES (44, 13, 37, '2026-02-27 12:33:01.246577+05:30', 'Tech Club Materials Invoice', 'Dues', 'Income', 46.00, 'Completed', 'pi_3T5L4TF6a9VUxk6R1A1meYRF', NULL, 13, 0.48, 1.70, NULL);
INSERT INTO ecm_clubs_transactions VALUES (42, 13, NULL, '2026-02-27 12:39:28.600655+05:30', 'Club donation', 'Public Donation', 'Income', 100.00, 'Completed', 'pi_3T5KD4F6a9VUxk6R0vL3aaWB', NULL, NULL, 0.00, 0.00, 7);


--
-- Name: ecm_clubs_transactions_trans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
SELECT pg_catalog.setval('ecm_clubs_transactions_trans_id_seq', 44, true);


--
-- Data for Name: ecm_invoice_details; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_invoice_details VALUES (11, 7, 'Winter Fees', 250, 0, 0, 1, 29, '2026-01-21 19:33:03.36+05:30');
INSERT INTO ecm_invoice_details VALUES (12, 8, 'Fees for Winter 2026', 350, 0, 0, 1, 29, '2026-01-21 21:05:33.258+05:30');
INSERT INTO ecm_invoice_details VALUES (13, 9, 'Dues', 40, 0, 0, 1, 29, '2026-02-04 17:19:51.513+05:30');
INSERT INTO ecm_invoice_details VALUES (14, 10, 'Test due fees', 40, 0, 0, 1, 29, '2026-02-04 21:04:56.579+05:30');
INSERT INTO ecm_invoice_details VALUES (15, 11, 'Dues', 650, 0, 0, 1, 33, '2026-02-18 00:21:38.466+05:30');
INSERT INTO ecm_invoice_details VALUES (16, 12, 'jacket', 20, 0, 0, 1, 26, '2026-02-18 17:28:51.409+05:30');
INSERT INTO ecm_invoice_details VALUES (17, 12, 'shoes', 40, 0, 0, 1, 26, '2026-02-18 17:28:51.409+05:30');
INSERT INTO ecm_invoice_details VALUES (18, 13, 'shoees', 80, 0, 0, 1, 26, '2026-02-18 17:31:54.646+05:30');
INSERT INTO ecm_invoice_details VALUES (19, 14, 'sprung dues', 1800, 0, 0, 1, 33, '2026-02-25 23:59:43.327+05:30');
INSERT INTO ecm_invoice_details VALUES (20, 15, '3D Printing Materials', 28, 0, 0, 1, 36, '2026-02-27 11:19:28.074+05:30');
INSERT INTO ecm_invoice_details VALUES (21, 15, 'Club T-Shirts', 18, 0, 0, 1, 36, '2026-02-27 11:19:28.074+05:30');
INSERT INTO ecm_invoice_details VALUES (22, 16, 'Raspberry Pi Development Boards', 75, 0, 0, 1, 36, '2026-02-27 13:16:04.937+05:30');
INSERT INTO ecm_invoice_details VALUES (23, 16, 'Sensor kits(Advanced Pack)', 95, 0, 0, 1, 36, '2026-02-27 13:16:04.937+05:30');
INSERT INTO ecm_invoice_details VALUES (24, 17, 'Team Travel Reimbursement(Local Transport)', 300, 0, 0, 1, 36, '2026-02-27 13:18:25.88+05:30');
INSERT INTO ecm_invoice_details VALUES (25, 17, 'Lodging for Competition', 120, 0, 0, 1, 36, '2026-02-27 13:18:25.88+05:30');
INSERT INTO ecm_invoice_details VALUES (26, 18, 'Social Dues', 200, 0, 0, 1, 33, '2026-03-02 21:12:55.8+05:30');
INSERT INTO ecm_invoice_details VALUES (27, 18, 'Insurance Fee', 1000, 0, 0, 1, 33, '2026-03-02 21:12:55.8+05:30');
INSERT INTO ecm_invoice_details VALUES (28, 18, 'Nationals Fee', 50, 0, 0, 1, 33, '2026-03-02 21:12:55.8+05:30');
INSERT INTO ecm_invoice_details VALUES (29, 19, 'Social Fee', 150, 0, 0, 1, 33, '2026-03-02 22:58:02.294+05:30');
INSERT INTO ecm_invoice_details VALUES (30, 19, 'Insurance Fee', 30, 0, 0, 1, 33, '2026-03-02 22:58:02.294+05:30');
INSERT INTO ecm_invoice_details VALUES (31, 19, 'House Fee', 250, 0, 0, 1, 33, '2026-03-02 22:58:02.294+05:30');


--
-- Name: ecm_invoice_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
SELECT pg_catalog.setval('ecm_invoice_details_id_seq', 31, true);


--
-- Data for Name: ecm_invoice_headers; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_invoice_headers VALUES (7, 11, 'Winter Fees', '2026-01-21 19:33:03.36+05:30', '2026-01-25 00:00:00+05:30', 250.00, 'Please pay the amount before due date.', '', 0, 1, 29, '2026-01-21 19:33:03.36+05:30', 0.00, 0.00);
INSERT INTO ecm_invoice_headers VALUES (8, 11, 'Winter Fees 2026', '2026-01-21 21:05:33.258+05:30', '2026-01-25 00:00:00+05:30', 350.00, 'Pay dues before due date.', '', 0, 1, 29, '2026-01-21 21:05:33.258+05:30', 0.00, 0.00);
INSERT INTO ecm_invoice_headers VALUES (9, 11, 'Winter ending event', '2026-02-04 17:19:51.513+05:30', '2026-02-05 00:00:00+05:30', 40.00, '', '', 0, 1, 29, '2026-02-04 17:19:51.513+05:30', 0.00, 0.00);
INSERT INTO ecm_invoice_headers VALUES (10, 11, 'Winter Club Invoice', '2026-02-04 21:04:56.579+05:30', '2026-02-05 00:00:00+05:30', 40.00, 'Additional test note for the invoice.', '', 0, 1, 29, '2026-02-04 21:04:56.579+05:30', 0.00, 0.00);
INSERT INTO ecm_invoice_headers VALUES (11, 11, 'Dues', '2026-02-18 00:21:38.466+05:30', '2026-02-26 00:00:00+05:30', 676.69, '', '', 0, 1, 33, '2026-02-18 00:21:38.466+05:30', 6.77, 19.92);
INSERT INTO ecm_invoice_headers VALUES (12, 11, 'new invoice', '2026-02-18 17:28:51.409+05:30', '2026-02-20 00:00:00+05:30', 62.75, 'testinnnngggg', '', 0, 1, 26, '2026-02-18 17:28:51.409+05:30', 0.63, 2.12);
INSERT INTO ecm_invoice_headers VALUES (13, 11, 'neww invoicee', '2026-02-18 17:31:54.646+05:30', '2026-02-20 00:00:00+05:30', 83.56, 'testiunnggg', '', 0, 1, 26, '2026-02-18 17:31:54.646+05:30', 0.84, 2.72);
INSERT INTO ecm_invoice_headers VALUES (14, 11, 'dues', '2026-02-25 23:59:43.327+05:30', '2026-02-25 00:00:00+05:30', 1873.36, '', '', 0, 1, 33, '2026-02-25 23:59:43.327+05:30', 18.73, 54.63);
INSERT INTO ecm_invoice_headers VALUES (15, 13, 'Tech Club Materials Invoice', '2026-02-27 11:19:28.074+05:30', '2026-03-05 00:00:00+05:30', 48.18, 'Thank you for supporting the Tech Club. Please remit payment within the provided due date.', '', 0, 1, 36, '2026-02-27 11:19:28.074+05:30', 0.48, 1.70);
INSERT INTO ecm_invoice_headers VALUES (16, 13, 'Tech Club Equpment & Software Invoice', '2026-02-27 13:16:04.937+05:30', '2026-03-07 00:00:00+05:30', 177.21, 'Thank you for supporting the Tech Club. Please remit payment within the due date.', '', 0, 1, 36, '2026-02-27 13:16:04.937+05:30', 1.77, 5.44);
INSERT INTO ecm_invoice_headers VALUES (17, 13, 'Tech Club Event & Competition Expenses Invoice', '2026-02-27 13:18:25.88+05:30', '2026-03-07 00:00:00+05:30', 437.36, 'Thank you for supporting the Tech Club. Please remit payment within due date.', '', 0, 1, 36, '2026-02-27 13:18:25.88+05:30', 4.37, 12.98);
INSERT INTO ecm_invoice_headers VALUES (18, 11, 'Spring Dues', '2026-03-02 21:12:55.8+05:30', '2026-03-04 00:00:00+05:30', 1301.04, '', '', 0, 1, 33, '2026-03-02 21:12:55.8+05:30', 13.01, 38.03);
INSERT INTO ecm_invoice_headers VALUES (19, 11, 'Spring Dues', '2026-03-02 22:58:02.294+05:30', '2026-03-14 00:00:00+05:30', 447.76, '', '', 0, 1, 33, '2026-03-02 22:58:02.294+05:30', 4.48, 13.29);


--
-- Name: ecm_invoice_headers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
SELECT pg_catalog.setval('ecm_invoice_headers_id_seq', 19, true);


--
-- Data for Name: ecm_invoice_member_mapping; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_invoice_member_mapping VALUES (9, 7, 11, 29, 'INV_7_e1de1fcd.pdf', 29, '2026-01-21 19:33:03.36+05:30');
INSERT INTO ecm_invoice_member_mapping VALUES (10, 8, 11, 29, 'INV_8_fedeadc1.pdf', 29, '2026-01-21 21:05:33.258+05:30');
INSERT INTO ecm_invoice_member_mapping VALUES (11, 8, 11, 31, 'INV_8_fedeadc1.pdf', 29, '2026-01-21 21:05:33.258+05:30');
INSERT INTO ecm_invoice_member_mapping VALUES (12, 9, 11, 29, 'INV_29_75199dc7.pdf', 29, '2026-02-04 17:19:51.513+05:30');
INSERT INTO ecm_invoice_member_mapping VALUES (13, 10, 11, 29, 'INV_29_aef6e514.pdf', 29, '2026-02-04 21:04:56.579+05:30');
INSERT INTO ecm_invoice_member_mapping VALUES (14, 10, 11, 28, 'INV_28_5321cf80.pdf', 29, '2026-02-04 21:04:56.579+05:30');
INSERT INTO ecm_invoice_member_mapping VALUES (15, 10, 11, 31, 'INV_31_a4152f66.pdf', 29, '2026-02-04 21:04:56.579+05:30');
INSERT INTO ecm_invoice_member_mapping VALUES (16, 11, 11, 33, 'INV_33_a2fb54fe.pdf', 33, '2026-02-18 00:21:38.466+05:30');
INSERT INTO ecm_invoice_member_mapping VALUES (17, 11, 11, 31, 'INV_31_e7bc6bee.pdf', 33, '2026-02-18 00:21:38.466+05:30');
INSERT INTO ecm_invoice_member_mapping VALUES (18, 12, 11, 27, 'INV_27_481ee8f8.pdf', 26, '2026-02-18 17:28:51.409+05:30');
INSERT INTO ecm_invoice_member_mapping VALUES (19, 13, 11, 26, 'INV_26_161fa2b5.pdf', 26, '2026-02-18 17:31:54.646+05:30');
INSERT INTO ecm_invoice_member_mapping VALUES (20, 14, 11, 31, 'INV_31_da907159.pdf', 33, '2026-02-25 23:59:43.327+05:30');
INSERT INTO ecm_invoice_member_mapping VALUES (21, 15, 13, 37, 'INV_37_7fa4a312.pdf', 36, '2026-02-27 11:19:28.074+05:30');
INSERT INTO ecm_invoice_member_mapping VALUES (22, 16, 13, 37, 'INV_37_1c65ace4.pdf', 36, '2026-02-27 13:16:04.937+05:30');
INSERT INTO ecm_invoice_member_mapping VALUES (23, 17, 13, 37, 'INV_37_26b90c15.pdf', 36, '2026-02-27 13:18:25.88+05:30');
INSERT INTO ecm_invoice_member_mapping VALUES (24, 18, 11, 31, 'INV_31_73b49333.pdf', 33, '2026-03-02 21:12:55.8+05:30');
INSERT INTO ecm_invoice_member_mapping VALUES (25, 19, 11, 31, 'INV_31_b78b952d.pdf', 33, '2026-03-02 22:58:02.294+05:30');


--
-- Name: ecm_invoice_member_mapping_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
SELECT pg_catalog.setval('ecm_invoice_member_mapping_id_seq', 25, true);


--
-- Data for Name: ecm_member_dues; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_member_dues VALUES (1, 11, 'Winter Fees', 250.00, 250.00, '2026-01-25', 'Paid', '2026-01-21 19:35:18.629392+05:30', 29, 29, 7);
INSERT INTO ecm_member_dues VALUES (3, 11, 'Winter Fees 2026', 350.00, 0.00, '2026-01-25', 'Unpaid', NULL, 29, 31, 8);
INSERT INTO ecm_member_dues VALUES (2, 11, 'Winter Fees 2026', 350.00, 350.00, '2026-01-25', 'Paid', '2026-01-21 21:08:09.664404+05:30', 29, 29, 8);
INSERT INTO ecm_member_dues VALUES (5, 11, 'Winter Club Invoice', 40.00, 0.00, '2026-02-05', 'Unpaid', NULL, 29, 29, 10);
INSERT INTO ecm_member_dues VALUES (6, 11, 'Winter Club Invoice', 40.00, 0.00, '2026-02-05', 'Unpaid', NULL, 29, 28, 10);
INSERT INTO ecm_member_dues VALUES (7, 11, 'Winter Club Invoice', 40.00, 0.00, '2026-02-05', 'Unpaid', NULL, 29, 31, 10);
INSERT INTO ecm_member_dues VALUES (4, 11, 'Winter ending event', 40.00, 40.00, '2026-02-05', 'Paid', '2026-02-04 21:11:44.337082+05:30', 29, 29, 9);
INSERT INTO ecm_member_dues VALUES (8, 11, 'Dues', 650.00, 0.00, '2026-02-26', 'Unpaid', NULL, 33, 33, 11);
INSERT INTO ecm_member_dues VALUES (9, 11, 'Dues', 650.00, 0.00, '2026-02-26', 'Unpaid', NULL, 33, 31, 11);
INSERT INTO ecm_member_dues VALUES (10, 11, 'new invoice', 60.00, 0.00, '2026-02-20', 'Unpaid', NULL, 26, 27, 12);
INSERT INTO ecm_member_dues VALUES (11, 11, 'neww invoicee', 80.00, 80.00, '2026-02-20', 'Paid', '2026-02-18 17:32:44.066589+05:30', 26, 26, 13);
INSERT INTO ecm_member_dues VALUES (12, 11, 'dues', 1800.00, 0.00, '2026-02-25', 'Unpaid', NULL, 33, 31, 14);
INSERT INTO ecm_member_dues VALUES (13, 13, 'Tech Club Materials Invoice', 46.00, 46.00, '2026-03-05', 'Paid', '2026-02-27 12:33:01.25158+05:30', 36, 37, 15);
INSERT INTO ecm_member_dues VALUES (14, 13, 'Tech Club Equpment & Software Invoice', 170.00, 0.00, '2026-03-07', 'Unpaid', NULL, 36, 37, 16);
INSERT INTO ecm_member_dues VALUES (15, 13, 'Tech Club Event & Competition Expenses Invoice', 420.00, 0.00, '2026-03-07', 'Unpaid', NULL, 36, 37, 17);
INSERT INTO ecm_member_dues VALUES (16, 11, 'Spring Dues', 1250.00, 0.00, '2026-03-04', 'Unpaid', NULL, 33, 31, 18);
INSERT INTO ecm_member_dues VALUES (17, 11, 'Spring Dues', 430.00, 0.00, '2026-03-14', 'Unpaid', NULL, 33, 31, 19);


--
-- Name: ecm_member_dues_due_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
SELECT pg_catalog.setval('ecm_member_dues_due_id_seq', 8, false);


--
-- Name: ecm_member_dues_due_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
SELECT pg_catalog.setval('ecm_member_dues_due_id_seq1', 17, true);


--
-- Data for Name: ecm_member_stripe_account; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_member_stripe_account VALUES (29, 'acct_1Sp5ePFGILXDJpCI', NULL, 'Enabled', false, false, '2026-01-13 16:50:44.646+05:30', '2026-01-13 16:50:44.646+05:30');
INSERT INTO ecm_member_stripe_account VALUES (31, 'acct_1Skl9g2WYOJR2pum', NULL, 'Enabled', false, false, '2026-01-13 16:50:44.646+05:30', '2026-01-13 16:50:44.646+05:30');
INSERT INTO ecm_member_stripe_account VALUES (26, 'acct_1SusikF1mROv2PjS', NULL, 'Enabled', false, false, '2026-02-18 16:47:22.735+05:30', '2026-02-18 17:51:25.996+05:30');
INSERT INTO ecm_member_stripe_account VALUES (12, 'acct_1T2PKVF7DFZt9ly9', NULL, 'Enabled', false, false, '2026-02-19 10:29:14.416+05:30', '2026-02-19 10:39:55.364+05:30');
INSERT INTO ecm_member_stripe_account VALUES (33, 'acct_1T4oxtFC8Ks8S4ux', NULL, 'Restricted', false, false, '2026-02-26 02:15:52.328+05:30', '2026-02-26 03:16:35.031+05:30');
INSERT INTO ecm_member_stripe_account VALUES (37, 'acct_1T5K3aJv14i8JNtI', NULL, 'Enabled', false, false, '2026-02-27 11:27:49.339+05:30', '2026-02-27 11:32:58.053+05:30');


--
-- Data for Name: ecm_privileges; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_privileges VALUES (1, 'Financial Access', 'View Finances', 'Can view transactions, budgets and balance', 1, NULL, '2025-11-28 22:11:01.609+05:30', NULL, '2025-11-28 22:11:01.609+05:30');
INSERT INTO ecm_privileges VALUES (2, 'Financial Access', 'Edit Finances', 'Can create transactions and manage budgets', 1, NULL, '2025-11-28 22:11:01.609+05:30', NULL, '2025-11-28 22:11:01.609+05:30');
INSERT INTO ecm_privileges VALUES (3, 'Events Management', 'View Events', 'Can view all events including drafts', 1, NULL, '2025-11-28 22:11:01.609+05:30', NULL, '2025-11-28 22:11:01.609+05:30');
INSERT INTO ecm_privileges VALUES (4, 'Events Management', 'Edit Events', 'Can create, edit, and publish events', 1, NULL, '2025-11-28 22:11:01.609+05:30', NULL, '2025-11-28 22:11:01.609+05:30');
INSERT INTO ecm_privileges VALUES (5, 'Member Management', 'View Members', 'Can view member directory and profiles', 1, NULL, '2025-11-28 22:11:01.609+05:30', NULL, '2025-11-28 22:11:01.609+05:30');
INSERT INTO ecm_privileges VALUES (6, 'Member Management', 'Manage Members', 'Can add, edit, and remove members', 1, NULL, '2025-11-28 22:11:01.609+05:30', NULL, '2025-11-28 22:11:01.609+05:30');
INSERT INTO ecm_privileges VALUES (7, 'Analytics & Reports', 'Access Analytics', 'Can view reports and analytics dashboards', 1, NULL, '2025-11-28 22:11:01.609+05:30', NULL, '2025-11-28 22:11:01.609+05:30');
INSERT INTO ecm_privileges VALUES (8, 'Administrative', 'Manage Permissions', 'Can modify permissions for other users (Admin only)', 1, NULL, '2025-11-28 22:11:01.609+05:30', NULL, '2025-11-28 22:11:01.609+05:30');


--
-- Name: ecm_privileges_s; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
SELECT pg_catalog.setval('ecm_privileges_s', 8, true);


--
-- Data for Name: ecm_reimbursement_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_reimbursement_requests VALUES (1, 11, 29, 'HID.jpg', '1770205260809.jpg', 250.00, '2026-02-03', 'Equipment', 'Equipment purchased for an event.', 'APPROVED', '2026-02-04 17:11:00.86+05:30', NULL, NULL, 'pi_3T1tlAF6a9VUxk6R1xdqI1nb', 33, '2026-02-18 00:47:38.205+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (2, 11, 29, 'istockphoto-1171408085-612x612.jpg', '1770219662855.jpg', 50.00, '2026-02-03', 'Equipment', 'Purchase equipments', 'APPROVED', '2026-02-04 21:11:02.901+05:30', NULL, NULL, 'pi_3T1tmIF6a9VUxk6R1lUN22QE', 33, '2026-02-18 00:48:06.228+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (3, 11, 26, 'Screenshot 2026-01-02 181016.png', '1771414332740.png', 100.00, '2026-02-18', 'Groceries', 'Testing budget', 'APPROVED', '2026-02-18 17:02:12.778+05:30', NULL, NULL, 'pi_3T28znF6a9VUxk6R1oN3pNg2', 26, '2026-02-18 17:03:33.865+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (4, 11, 26, 'Screenshot 2026-01-27 183453.png', '1771417925550.png', 100.00, '2026-02-18', 'Groceries', 'Testing 2', 'APPROVED', '2026-02-18 18:02:05.579+05:30', NULL, NULL, 'pi_3T29vUF6a9VUxk6R1PE4RUcm', 26, '2026-02-18 18:02:40.567+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (5, 11, 26, 'Screenshot 2026-01-27 183453.png', '1771418839577.png', 100.00, '2026-02-18', 'Groceries', '', 'APPROVED', '2026-02-18 18:17:19.597+05:30', NULL, NULL, 'pi_3T2AAHF6a9VUxk6R0OrHfpLw', 26, '2026-02-18 18:18:19.932+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (6, 11, 26, 'Screenshot 2026-01-27 183453.png', '1771419684473.png', 150.00, '2026-02-18', 'Transportation', 'test 3', 'APPROVED', '2026-02-18 18:31:24.499+05:30', NULL, NULL, 'pi_3T2AO5F6a9VUxk6R12ajfAnw', 26, '2026-02-18 18:32:06.278+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (7, 11, 26, 'Screenshot 2026-01-27 183453.png', '1771419924019.png', 180.00, '2026-02-18', 'Groceries', 'Test 4', 'APPROVED', '2026-02-18 18:35:24.073+05:30', NULL, NULL, 'pi_3T2ASqF6a9VUxk6R0M4C3Rpg', 26, '2026-02-18 18:37:00.982+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (9, 1, 12, 'Screenshot 2026-02-19 at 11.19.14 AM.jpg', '1771480184265.jpg', 50.00, '2026-02-18', 'Transportation', 'dummytest', 'APPROVED', '2026-02-19 11:19:44.345+05:30', NULL, NULL, 'pi_3T2Q9HF6a9VUxk6R05Zk6grB', 12, '2026-02-19 11:21:57.753+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (10, 11, 26, 'Screenshot 2026-01-27 183453.png', '1771480504729.png', 180.00, '2026-02-19', 'Groceries', 'Groceries', 'APPROVED', '2026-02-19 11:25:04.766+05:30', NULL, NULL, 'pi_3T2QD5F6a9VUxk6R0Dspnw9n', 26, '2026-02-19 11:25:49.805+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (12, 1, 12, 'Screenshot 2026-02-19 at 11.19.14 AM.jpg', '1771498632203.jpg', 70.00, '2026-02-18', 'Groceries', '', 'APPROVED', '2026-02-19 16:27:12.29+05:30', NULL, NULL, 'pi_3T2UvUF6a9VUxk6R1E2fiF0m', 12, '2026-02-19 16:28:08.215+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (11, 1, 12, 'Colorful Peacock Feather on Transparent Background - 960x1200.png', '1771497457610.png', 70.00, '2026-02-18', 'Groceries', '', 'APPROVED', '2026-02-19 16:07:37.638+05:30', NULL, NULL, 'pi_3T2Y0wF6a9VUxk6R0eEpntTa', 12, '2026-02-19 19:45:52.433+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (13, 1, 12, 'Screenshot 2026-02-19 at 11.19.14 AM.jpg', '1771510489897.jpg', 90.00, '2026-02-17', 'Transportation', 'just testing', 'APPROVED', '2026-02-19 19:44:49.96+05:30', NULL, NULL, 'pi_3T2Y2qF6a9VUxk6R1Kfr3Tqa', 12, '2026-02-19 19:47:52.833+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (8, 11, 26, 'Screenshot 2026-01-27 183453.png', '1771420832820.png', 190.00, '2026-02-18', 'Groceries', 'Testing 5', 'APPROVED', '2026-02-18 18:50:32.878+05:30', NULL, NULL, 'pi_3T2aOyF6a9VUxk6R1p6578xJ', 26, '2026-02-19 22:18:49.194+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (14, 1, 12, 'Screenshot 2026-02-19 at 11.19.14 AM.jpg', '1771565147170.jpg', 95.00, '2026-02-17', 'Transportation', 'testing reimbursement', 'APPROVED', '2026-02-20 10:55:47.252+05:30', NULL, NULL, 'pi_3T2mEFF6a9VUxk6R1aDtWKof', 12, '2026-02-20 10:56:31.486+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (15, 1, 12, 'Screenshot 2026-02-19 at 11.19.14 AM.jpg', '1771565681553.jpg', 25.00, '2026-02-17', 'Groceries', 'testing again', 'APPROVED', '2026-02-20 11:04:41.589+05:30', NULL, NULL, 'pi_3T2mMfF6a9VUxk6R0EAnsxiG', 12, '2026-02-20 11:05:09.825+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (16, 1, 12, 'Screenshot 2026-02-19 at 11.19.14 AM.jpg', '1771570676776.jpg', 10.00, '2026-02-17', 'Transportation', 'testing againn', 'APPROVED', '2026-02-20 12:27:56.803+05:30', NULL, NULL, 'pi_3T2nhNF6a9VUxk6R0XrtkNzk', 12, '2026-02-20 12:30:52.092+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (18, 11, 26, 'Screenshot 2026-01-27 183453.png', '1771572291855.png', 140.00, '2026-02-20', 'Transportation', 'Transport 2', 'APPROVED', '2026-02-20 12:54:51.886+05:30', NULL, NULL, 'pi_3T2o64F6a9VUxk6R0HXizWu4', 26, '2026-02-20 12:56:31.258+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (19, 11, 26, 'Screenshot 2026-01-27 183453.png', '1771579232970.png', 145.00, '2026-02-20', 'Transportation', 'Transport 3', 'APPROVED', '2026-02-20 14:50:32.991+05:30', NULL, NULL, 'pi_3T2ptpF6a9VUxk6R0mCLtevg', 26, '2026-02-20 14:51:47.491+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (20, 11, 26, 'Screenshot 2026-01-27 183453.png', '1771582945188.png', 125.00, '2026-02-20', 'Marketing', 'Marketing', 'APPROVED', '2026-02-20 15:52:25.245+05:30', NULL, NULL, 'pi_3T2qr7F6a9VUxk6R1gQoZFru', 26, '2026-02-20 15:52:53.45+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (17, 11, 26, 'Screenshot 2026-01-27 183453.png', '1771572176129.png', 130.00, '2026-02-20', 'Transportation', 'Transport', 'APPROVED', '2026-02-20 12:52:56.161+05:30', NULL, NULL, 'pi_3T4hkmF6a9VUxk6R1MwUFK5E', 26, '2026-02-25 18:34:05.165+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (21, 13, 37, 'Reimbursement Receipt.png', '1772173003333.png', 300.00, '2026-02-27', 'Software Licenses', 'Reimbursement request for software licensing', 'APPROVED', '2026-02-27 11:46:43.361+05:30', NULL, NULL, 'pi_3T5KQjF6a9VUxk6R142mztiQ', 36, '2026-02-27 11:51:58.477+05:30', NULL, NULL);
INSERT INTO ecm_reimbursement_requests VALUES (22, 13, 37, 'Reimbursement Receipt.png', '1772175996682.png', 150.00, '2026-02-27', 'Software Licenses', 'Purchase for software license', 'REJECTED', '2026-02-27 12:36:36.704+05:30', 36, '2026-02-27 12:38:25.5+05:30', NULL, NULL, NULL, 'Request rejected due to mismatch in reciept', NULL);


--
-- Name: ecm_reimbursement_requests_s; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
SELECT pg_catalog.setval('ecm_reimbursement_requests_s', 22, true);


--
-- Data for Name: ecm_role_privilege_mappings; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_role_privilege_mappings VALUES (1, 1, 3, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (2, 1, 5, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (3, 2, 1, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (4, 2, 2, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (5, 2, 3, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (6, 2, 4, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (7, 2, 5, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (8, 2, 6, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (9, 2, 7, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (10, 2, 8, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (11, 3, 1, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (12, 3, 2, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (13, 3, 3, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (14, 3, 4, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (15, 3, 5, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (16, 3, 6, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (17, 3, 7, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (18, 3, 8, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (19, 4, 1, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (20, 4, 2, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (21, 4, 3, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (22, 4, 5, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (23, 4, 7, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (24, 5, 1, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (25, 5, 2, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (26, 5, 3, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (27, 5, 4, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (28, 5, 5, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (29, 5, 6, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (30, 5, 7, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (31, 5, 8, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (32, 6, 1, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (33, 6, 3, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (34, 6, 4, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (35, 6, 5, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (36, 6, 6, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (37, 6, 7, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (38, 7, 3, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (39, 7, 4, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');
INSERT INTO ecm_role_privilege_mappings VALUES (40, 7, 5, 1, NULL, '2025-11-28 22:27:25.057+05:30', NULL, '2025-11-28 22:27:25.057+05:30');


--
-- Name: ecm_role_privilege_mappings_s; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
SELECT pg_catalog.setval('ecm_role_privilege_mappings_s', 40, true);


--
-- Data for Name: ecm_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_roles VALUES (1, 'Member', 1, NULL, '2025-11-28 21:33:07.604+05:30', NULL, '2025-11-28 21:33:07.604+05:30');
INSERT INTO ecm_roles VALUES (2, 'President', 1, NULL, '2025-11-28 21:33:15.034+05:30', NULL, '2025-11-28 21:33:15.034+05:30');
INSERT INTO ecm_roles VALUES (3, 'Vice President', 1, NULL, '2025-11-28 21:33:23.395+05:30', NULL, '2025-11-28 21:33:23.395+05:30');
INSERT INTO ecm_roles VALUES (4, 'Treasurer', 1, NULL, '2025-11-28 21:33:52.22+05:30', NULL, '2025-11-28 21:33:52.22+05:30');
INSERT INTO ecm_roles VALUES (5, 'Secretary', 1, NULL, '2025-11-28 21:34:04.023+05:30', NULL, '2025-11-28 21:34:04.023+05:30');
INSERT INTO ecm_roles VALUES (6, 'Officer', 1, NULL, '2025-11-28 21:53:22.042+05:30', NULL, '2025-11-28 21:53:22.042+05:30');
INSERT INTO ecm_roles VALUES (7, 'Event Coordinator', 1, NULL, '2025-11-28 21:53:41.782+05:30', NULL, '2025-11-28 21:53:41.782+05:30');


--
-- Name: ecm_roles_s; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('ecm_roles_s', 7, true);


--
-- Data for Name: ecm_user_clubs_mappings; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_user_clubs_mappings VALUES (2, 1, 4, '2026-01-21 17:55:29.255+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (3, 1, 7, '2026-01-21 17:55:29.255+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (4, 1, 6, '2026-01-21 17:55:29.255+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (1, 1, 6, '2026-01-21 17:55:29.255+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (12, 1, 6, '2026-01-21 17:55:29.255+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (5, 1, 6, '2026-01-21 17:55:29.255+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (16, 9, 6, '2026-01-21 17:55:29.255+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (19, 1, 6, '2026-01-21 17:55:29.255+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (25, 1, 1, '2026-01-21 17:55:29.255+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (27, 11, 6, '2026-01-21 17:55:29.255+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (28, 11, 6, '2026-01-21 17:55:29.255+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (29, 11, 6, '2026-01-21 17:55:29.255+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (26, 11, 6, '2026-01-21 17:55:29.255+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (30, 11, 6, '2026-01-21 17:55:29.255+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (31, 11, 6, '2026-01-21 17:55:29.255+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (32, 11, 6, '2026-02-03 22:18:57.665999+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (33, 11, 6, '2026-02-17 00:09:51.856081+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (34, 11, 6, '2026-02-17 00:10:43.754358+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (36, 13, 6, '2026-02-27 10:10:38.187164+05:30', 'Active');
INSERT INTO ecm_user_clubs_mappings VALUES (37, 13, 1, '2026-02-27 10:50:30.058766+05:30', 'Active');


--
-- Data for Name: ecm_users; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO ecm_users VALUES (2, 'Alex', NULL, 'Rodriguez', 'Alex Rodriguez', 'alex.r@filmclub.edu', 'UEBzc3cwcmQ=', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'alex.r@filmclub.edu', NULL, '2025-11-28', 1, NULL, '2025-11-28 23:16:16.781+05:30', NULL, '2025-11-28 23:16:16.781+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (3, 'Jamie', NULL, 'Park', 'Jamie Park', 'jamie.p@filmclub.edu', 'UEBzc3cwcmQ=', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'jamie.p@filmclub.edu', NULL, '2025-11-28', 1, NULL, '2025-11-28 23:16:16.781+05:30', NULL, '2025-11-28 23:16:16.781+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (4, 'Sarah', NULL, 'Chen', 'Sarah Chen', 'sarah.c@filmclub.edu', 'UEBzc3cwcmQ=', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'sarah.c@filmclub.edu', NULL, '2025-11-28', 1, NULL, '2025-11-28 23:16:16.781+05:30', NULL, '2025-11-28 23:16:16.781+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (1, 'Luca', NULL, 'Martinez', 'Luca Martinez', 'luca@filmclub.edu', '{bcrypt}$2a$10$Jxj9DVW5iYDEfBKcsRveJ.cuqJfX7m2X4HkAFI2vAr5AGzh2yh1U6', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'luca@filmclub.edu', NULL, '2025-11-28', 1, NULL, '2025-11-28 23:16:16.781+05:30', NULL, '2025-11-28 23:16:16.781+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (5, 'Mike', NULL, 'Johnson', 'Mike Johnson', 'mike.j@filmclub.edu', 'UEBzc3cwcmQ=', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'mike.j@filmclub.edu', NULL, '2025-11-28', 1, NULL, '2025-11-28 23:16:16.781+05:30', NULL, '2025-11-28 23:16:16.781+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (16, 'Vignesh', NULL, 'Iyer', 'Vignesh Iyer', 'yugdevem0025@gmail.com', '{bcrypt}$2a$10$2e1nkGwrTSKyD2nW6GtRjurXlznjnPd.j.MSwVg/EUCNh59i7z6je', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'yugdevem0025@gmail.com', NULL, '2025-12-19', 1, NULL, '2025-12-19 15:36:07.159471+05:30', NULL, '2025-12-19 15:36:07.159471+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (19, 'Debashis', NULL, 'Das', 'Debashis Das', 'debashisd@aptsourceindia.net', '{bcrypt}$2a$10$hBgs6wh7/q8/z27ZgynoFeW7V499BbycUUKWWFja7OGuGz62gI3em', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'debashisd@aptsourceindia.net', NULL, '2026-01-05', 1, NULL, '2026-01-05 15:04:05.512535+05:30', NULL, '2026-01-05 15:04:05.512535+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (25, 'Rony', NULL, '', 'Rony', 'dasdebashisindia@gmail.com', '{bcrypt}$2a$10$ltViXSDytur91vHjrtwrdOXVMuYE4FJeoVC.RpZYYWH7JPGVUoiSy', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'dasdebashisindia@gmail.com', NULL, '2026-01-10', 1, NULL, '2026-01-10 14:57:17.006626+05:30', NULL, '2026-01-10 14:57:17.006626+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (27, 'Nivin', NULL, 'Mathew', 'Nivin Mathew', 'nivin.volkkommen@gmail.com', '{bcrypt}$2a$10$FZrq2n6BlFSy6KvRakpPKeXZY4JQHZZTMGNJJqGp7puhTDD/Ewvcm', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'nivin.volkkommen@gmail.com', NULL, '2026-01-13', 1, NULL, '2026-01-13 16:31:15.359248+05:30', NULL, '2026-01-13 16:31:15.359248+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (28, 'Isita', NULL, 'Das', 'Isita Das', 'isitad@aptsourcesoftware.com', '{bcrypt}$2a$10$OTcttJgC4vwk3SbbZQxW7ekQB0Oo1GVwvsfFNpdfESi6f3yuarJqO', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'isitad@aptsourcesoftware.com', NULL, '2026-01-13', 1, NULL, '2026-01-13 17:22:47.129294+05:30', NULL, '2026-01-13 17:22:47.129294+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (29, 'Debashis', NULL, 'Das', 'Debashis Das', 'debashisd@aptsourcesoftware.com', '{bcrypt}$2a$10$PxWkGq88UEJmWRegaFoXo.QurqGUZ4HquoV4NDrVOoZKZ57bls6bi', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'debashisd@aptsourcesoftware.com', NULL, '2026-01-13', 1, NULL, '2026-01-13 17:24:06.829346+05:30', NULL, '2026-01-13 17:24:06.829346+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (26, 'Nivin', NULL, 'Varghese', 'Nivin Varghese', 'nivinvarghese16@gmail.com', '{bcrypt}$2a$10$I674Ruj5Eyh0TAzP4faEZOwdeQK.942Nexg9t5Ds3m75SqfT8DGH2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'nivinvarghese16@gmail.com', NULL, '2026-01-13', 1, NULL, '2026-01-13 16:29:37.350647+05:30', NULL, '2026-01-13 18:04:18.203622+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (30, 'Isita', NULL, 'Das', 'Isita Das', 'isitadas2015@gmail.com', '{bcrypt}$2a$10$fMdcolvQ8DOrRDq0JnrHnupKOihUMiU8oP3Iu37N1wuUB2/X695kO', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'isitadas2015@gmail.com', NULL, '2026-01-14', 1, NULL, '2026-01-14 11:25:26.602532+05:30', NULL, '2026-01-14 11:25:26.602532+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (31, 'Gabi', NULL, '', 'Gabi', 'gabriel.josefson@gmail.com', '{bcrypt}$2a$10$yr/9EpiwdAqcosaOWPQQ8.GZxI.hHxhRoFIp8Zu/MjYMLTA6WJzvu', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'gabriel.josefson@gmail.com', NULL, '2026-01-14', 1, NULL, '2026-01-14 21:07:33.071565+05:30', NULL, '2026-01-14 21:07:33.071565+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (32, 'Manisha', NULL, 'Chowdhury', 'Manisha Chowdhury', 'manishac@aptsourceindia.net', '{bcrypt}$2a$10$504QQNiHRy74JV3qvST9x.S3PDtMeeKNwK6IgUCzu8SBa/FVGVil2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'manishac@aptsourceindia.net', NULL, '2026-02-03', 1, NULL, '2026-02-03 22:18:57.623987+05:30', NULL, '2026-02-03 22:18:57.623987+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (33, 'Mitchell', NULL, 'Breakstone', 'Mitchell Breakstone', 'Mitchellbreakstone@icloud.com', '{bcrypt}$2a$10$FDsCm89M9WM3NhvWSmOb..SRFldJLuvAiO.f3mrBcSwLqqezdUgj2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Mitchellbreakstone@icloud.com', NULL, '2026-02-17', 1, NULL, '2026-02-17 00:09:51.833081+05:30', NULL, '2026-02-17 00:09:51.833081+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (34, 'Sam', NULL, 'Benoit', 'Sam Benoit', 'smbenoit6@gmail.com', '{bcrypt}$2a$10$PzAXdN3MW.8mqMkSemMHr.p7l1BFHN1skVSX6UJO3sttEE7ZdPVW6', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'smbenoit6@gmail.com', NULL, '2026-02-17', 1, NULL, '2026-02-17 00:10:43.741359+05:30', NULL, '2026-02-17 00:10:43.741359+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (37, 'Christopher', NULL, 'Miller', 'Christopher Miller', 'nivinv@aptsourcesoftware.com', '{bcrypt}$2a$10$rl608egqkCe3uTW7xwakUeylY7uC/AioUt06A6EYHj6JGErx5AiSS', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'nivinv@aptsourcesoftware.com', NULL, '2026-02-27', 1, NULL, '2026-02-27 10:50:30.039764+05:30', NULL, '2026-02-27 10:50:30.039764+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (12, 'Yugdev', NULL, 'EM', 'Yugdev EM', 'yugdevem285@gmail.com', '{bcrypt}$2a$10$0VR0VRfCscB3kKUkUI18FOwgdX7eAAzv6M/nvkUD5XcgxIYzETNQK', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'yugdevem285@gmail.com', NULL, '2025-12-12', 1, NULL, '2025-12-12 20:12:37.958116+05:30', NULL, '2026-02-27 10:57:20.389586+05:30', NULL, NULL, NULL);
INSERT INTO ecm_users VALUES (36, 'Ethan', NULL, 'Walker', 'Ethan Walker', 'yugdevem@aptsourcesoftware.com', '{bcrypt}$2a$10$GMam.PBn04ynJaVcT9b3Qu0yahCrlsG/1CM4Yqz25uMaesMAOxpT2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'yugdevem@aptsourcesoftware.com', NULL, '2026-02-27', 1, NULL, '2026-02-27 10:10:38.187164+05:30', NULL, '2026-02-27 13:44:57.748597+05:30', NULL, NULL, NULL);


--
-- Name: ecm_users_s; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
SELECT pg_catalog.setval('ecm_users_s', 37, true);


--
-- Data for Name: plaid_accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--
INSERT INTO plaid_accounts VALUES ('4cf1eada-45fe-44b9-8b08-9e772193ee89', 11, 29, true, NULL, '31e6ea547e67d9d3496d8710343b0dbc99c5e0e404b3b3e5a403df28b61bcba979891b5b953070e45f63f7e37f044e650389dde154cc572989bc7860e23d93b6040aab58e62c6ef8cdb8232e33d1fc55', 'ins_109511', 'Tartan Bank', '3yM3l5jEoxsmkqZE3vlKfWEm9BW1mBtqLxVx9', '["dx1o4bWzB9u8z9p6V3mXCKPRlkv8gLF5lKVQX"]', '2026-02-05 12:52:55.925303+05:30', '2026-02-05 12:52:55.925303+05:30', NULL, 'dx1o4bWzB9u8z9p6V3mXCKPRlkv8gLF5lKVQX');
INSERT INTO plaid_accounts VALUES ('b846d376-780a-4f91-8aff-5be8f6ce8270', 13, 36, true, NULL, '12229556bb2b6a4c91ecc192b3535566fb372bea4ab9a2baed61264d46c179259b703318550486a15abc7740bd4276e8889cbbdcffb3e0f0b75e3c909a1083dbc9b719828f30aef4bc8ce296809d2fea', 'ins_109511', 'Tartan Bank', 'jQZxgAX8JBfgv4j1q4KDTB3KjgoWlefyb5wjQ', '["r8Re53ymgkfKVzpDazvdI6qMKKdEAeiaZNn3D"]', '2026-02-27 11:05:13.479246+05:30', '2026-02-27 11:05:13.479246+05:30', NULL, 'r8Re53ymgkfKVzpDazvdI6qMKKdEAeiaZNn3D');


--
-- Name: ecm_budget_category_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_budget_category_master
    ADD CONSTRAINT ecm_budget_category_master_pkey PRIMARY KEY (category_id);


--
-- Name: ecm_club_budget_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_club_budget_categories
    ADD CONSTRAINT ecm_club_budget_categories_pkey PRIMARY KEY (allocation_id);


--
-- Name: ecm_club_budgets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_club_budgets
    ADD CONSTRAINT ecm_club_budgets_pkey PRIMARY KEY (budget_id);


--
-- Name: ecm_invoice_details_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_invoice_details
    ADD CONSTRAINT ecm_invoice_details_pk PRIMARY KEY (invoice_detail_id);


--
-- Name: ecm_invoice_headers_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_invoice_headers
    ADD CONSTRAINT ecm_invoice_headers_pk PRIMARY KEY (invoice_id);


--
-- Name: ecm_invoice_member_mapping_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_invoice_member_mapping
    ADD CONSTRAINT ecm_invoice_member_mapping_pk PRIMARY KEY (invoice_member_mapping_id);


--
-- Name: ecm_token_blacklist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_token_blacklist
    ADD CONSTRAINT ecm_token_blacklist_pkey PRIMARY KEY (jti);


--
-- Name: pk_ecm_club_stripe_account; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_club_stripe_account
    ADD CONSTRAINT pk_ecm_club_stripe_account PRIMARY KEY (club_id);


--
-- Name: pk_ecm_clubs; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_clubs
    ADD CONSTRAINT pk_ecm_clubs PRIMARY KEY (club_id);


--
-- Name: pk_ecm_clubs_donations; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_clubs_donations
    ADD CONSTRAINT pk_ecm_clubs_donations PRIMARY KEY (donation_id);


--
-- Name: pk_ecm_clubs_transactions; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_clubs_transactions
    ADD CONSTRAINT pk_ecm_clubs_transactions PRIMARY KEY (trans_id);


--
-- Name: pk_ecm_member_dues; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_member_dues
    ADD CONSTRAINT pk_ecm_member_dues PRIMARY KEY (due_id);


--
-- Name: pk_ecm_member_stripe_account; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_member_stripe_account
    ADD CONSTRAINT pk_ecm_member_stripe_account PRIMARY KEY (user_id);


--
-- Name: pk_ecm_privileges; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_privileges
    ADD CONSTRAINT pk_ecm_privileges PRIMARY KEY (privilege_id);


--
-- Name: pk_ecm_reimbursement_requests; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_reimbursement_requests
    ADD CONSTRAINT pk_ecm_reimbursement_requests PRIMARY KEY (reimbursement_id);


--
-- Name: pk_ecm_role_privilege_mappings; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_role_privilege_mappings
    ADD CONSTRAINT pk_ecm_role_privilege_mappings PRIMARY KEY (role_privilege_mapping_id);


--
-- Name: pk_ecm_roles; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_roles
    ADD CONSTRAINT pk_ecm_roles PRIMARY KEY (role_id);


--
-- Name: pk_ecm_user_clubs; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_user_clubs_mappings
    ADD CONSTRAINT pk_ecm_user_clubs PRIMARY KEY (user_id, club_id);


--
-- Name: pk_ecm_users; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_users
    ADD CONSTRAINT pk_ecm_users PRIMARY KEY (user_id);


--
-- Name: plaid_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY plaid_accounts
    ADD CONSTRAINT plaid_accounts_pkey PRIMARY KEY (id);


--
-- Name: uq_due_stripe_ref; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_clubs_transactions
    ADD CONSTRAINT uq_due_stripe_ref UNIQUE (due_id, stripe_ref_id);


--
-- Name: uq_ecm_club_stripe_account_stripe_account; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY ecm_club_stripe_account
    ADD CONSTRAINT uq_ecm_club_stripe_account_stripe_account UNIQUE (stripe_account_id);


--
-- Name: uq_plaid_item; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--
ALTER TABLE ONLY plaid_accounts
    ADD CONSTRAINT uq_plaid_item UNIQUE (item_id);


--
-- Name: idx_club_school; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--
CREATE INDEX idx_club_school ON ecm_clubs USING btree (club_name, school_name);


--
-- Name: idx_don_club_latest_visible; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--
CREATE INDEX idx_don_club_latest_visible ON ecm_clubs_donations USING btree (club_id, donation_date DESC NULLS LAST) WHERE (is_visible_to_club = 1);


--
-- Name: idx_ecm_clubs_transactions_club_date; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--
CREATE INDEX idx_ecm_clubs_transactions_club_date ON ecm_clubs_transactions USING btree (club_id, trans_date DESC);


--
-- Name: idx_ecm_clubs_transactions_due; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--
CREATE INDEX idx_ecm_clubs_transactions_due ON ecm_clubs_transactions USING btree (due_id);


--
-- Name: idx_ecm_clubs_transactions_paid_to_user; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--
CREATE INDEX idx_ecm_clubs_transactions_paid_to_user ON ecm_clubs_transactions USING btree (paid_to_user_id);


--
-- Name: idx_ecm_clubs_transactions_type; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--
CREATE INDEX idx_ecm_clubs_transactions_type ON ecm_clubs_transactions USING btree (type);


--
-- Name: idx_member_dues_invoice; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--
CREATE INDEX idx_member_dues_invoice ON ecm_member_dues USING btree (invoice_id);


--
-- Name: idx_plaid_club_active; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--
CREATE INDEX idx_plaid_club_active ON plaid_accounts USING btree (club_id, active_ind);


--
-- Name: idx_plaid_item_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--
CREATE INDEX idx_plaid_item_id ON plaid_accounts USING btree (item_id);


--
-- Name: idx_reim_club_pending_submitted_at; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--
CREATE INDEX idx_reim_club_pending_submitted_at ON ecm_reimbursement_requests USING btree (club_id, submitted_at) WHERE ((status)::text = 'PENDING'::text);


--
-- Name: idx_reimbursement_stripe_ref; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--
CREATE INDEX idx_reimbursement_stripe_ref ON ecm_reimbursement_requests USING btree (stripe_ref_id);


--
-- Name: idx_trans_date; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--
CREATE INDEX idx_trans_date ON ecm_clubs_transactions USING btree (trans_date);


--
-- Name: idx_unique_due_stripe_payment; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--
CREATE UNIQUE INDEX idx_unique_due_stripe_payment ON ecm_clubs_transactions USING btree (due_id, stripe_ref_id) WHERE ((due_id IS NOT NULL) AND (stripe_ref_id IS NOT NULL));


--
-- Name: ecm_don_fk01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_clubs_donations
    ADD CONSTRAINT ecm_don_fk01 FOREIGN KEY (club_id) REFERENCES ecm_clubs(club_id);


--
-- Name: ecm_invoice_details_fk01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_invoice_details
    ADD CONSTRAINT ecm_invoice_details_fk01 FOREIGN KEY (invoice_id) REFERENCES ecm_invoice_headers(invoice_id);


--
-- Name: ecm_invoice_headers_fk01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_invoice_headers
    ADD CONSTRAINT ecm_invoice_headers_fk01 FOREIGN KEY (club_id) REFERENCES ecm_clubs(club_id);


--
-- Name: ecm_invoice_member_mapping_fk01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_invoice_member_mapping
    ADD CONSTRAINT ecm_invoice_member_mapping_fk01 FOREIGN KEY (invoice_id) REFERENCES ecm_invoice_headers(invoice_id);


--
-- Name: ecm_invoice_member_mapping_fk02; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_invoice_member_mapping
    ADD CONSTRAINT ecm_invoice_member_mapping_fk02 FOREIGN KEY (club_id) REFERENCES ecm_clubs(club_id);


--
-- Name: ecm_invoice_member_mapping_fk03; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_invoice_member_mapping
    ADD CONSTRAINT ecm_invoice_member_mapping_fk03 FOREIGN KEY (member_id) REFERENCES ecm_users(user_id);


--
-- Name: ecm_invoice_member_mapping_fk04; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_invoice_member_mapping
    ADD CONSTRAINT ecm_invoice_member_mapping_fk04 FOREIGN KEY (member_id, club_id) REFERENCES ecm_user_clubs_mappings(user_id, club_id);


--
-- Name: ecm_reim_fk01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_reimbursement_requests
    ADD CONSTRAINT ecm_reim_fk01 FOREIGN KEY (club_id) REFERENCES ecm_clubs(club_id);


--
-- Name: ecm_reim_fk02; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_reimbursement_requests
    ADD CONSTRAINT ecm_reim_fk02 FOREIGN KEY (submitted_by_member_id) REFERENCES ecm_users(user_id);


--
-- Name: ecm_reim_fk03; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_reimbursement_requests
    ADD CONSTRAINT ecm_reim_fk03 FOREIGN KEY (rejected_by_officer_id) REFERENCES ecm_users(user_id);


--
-- Name: ecm_reim_fk04; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_reimbursement_requests
    ADD CONSTRAINT ecm_reim_fk04 FOREIGN KEY (approved_by_officer_id) REFERENCES ecm_users(user_id);


--
-- Name: ecm_role_privilege_mapping_fk01; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_role_privilege_mappings
    ADD CONSTRAINT ecm_role_privilege_mapping_fk01 FOREIGN KEY (role_id) REFERENCES ecm_roles(role_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: ecm_role_privilege_mapping_fk02; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_role_privilege_mappings
    ADD CONSTRAINT ecm_role_privilege_mapping_fk02 FOREIGN KEY (privilege_id) REFERENCES ecm_privileges(privilege_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: fk_budget_club; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_club_budgets
    ADD CONSTRAINT fk_budget_club FOREIGN KEY (club_id) REFERENCES ecm_clubs(club_id);


--
-- Name: fk_budget_header; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_club_budget_categories
    ADD CONSTRAINT fk_budget_header FOREIGN KEY (budget_id) REFERENCES ecm_club_budgets(budget_id) ON DELETE CASCADE;


--
-- Name: fk_category_lookup; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_club_budget_categories
    ADD CONSTRAINT fk_category_lookup FOREIGN KEY (category_id) REFERENCES ecm_budget_category_master(category_id);


--
-- Name: fk_club; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_user_clubs_mappings
    ADD CONSTRAINT fk_club FOREIGN KEY (club_id) REFERENCES ecm_clubs(club_id);


--
-- Name: fk_dues_assigned_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_member_dues
    ADD CONSTRAINT fk_dues_assigned_user FOREIGN KEY (assigned_user_id) REFERENCES ecm_users(user_id);


--
-- Name: fk_dues_clubs; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_member_dues
    ADD CONSTRAINT fk_dues_clubs FOREIGN KEY (club_id) REFERENCES ecm_clubs(club_id);


--
-- Name: fk_dues_created_by_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_member_dues
    ADD CONSTRAINT fk_dues_created_by_user FOREIGN KEY (created_by_user_id) REFERENCES ecm_users(user_id);


--
-- Name: fk_ecm_club_stripe_account_club; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_club_stripe_account
    ADD CONSTRAINT fk_ecm_club_stripe_account_club FOREIGN KEY (club_id) REFERENCES ecm_clubs(club_id) ON DELETE CASCADE;


--
-- Name: fk_ecm_club_stripe_account_created_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_club_stripe_account
    ADD CONSTRAINT fk_ecm_club_stripe_account_created_user FOREIGN KEY (created_by_user_id) REFERENCES ecm_users(user_id);


--
-- Name: fk_ecm_club_stripe_account_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_club_stripe_account
    ADD CONSTRAINT fk_ecm_club_stripe_account_user FOREIGN KEY (last_updated_by_user_id) REFERENCES ecm_users(user_id) ON DELETE SET NULL;


--
-- Name: fk_ecm_clubs_transactions_club; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_clubs_transactions
    ADD CONSTRAINT fk_ecm_clubs_transactions_club FOREIGN KEY (club_id) REFERENCES ecm_clubs(club_id);


--
-- Name: fk_ecm_clubs_transactions_paid_to_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_clubs_transactions
    ADD CONSTRAINT fk_ecm_clubs_transactions_paid_to_user FOREIGN KEY (paid_to_user_id) REFERENCES ecm_users(user_id);


--
-- Name: fk_ecm_clubs_transactions_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_clubs_transactions
    ADD CONSTRAINT fk_ecm_clubs_transactions_user FOREIGN KEY (done_by_user_id) REFERENCES ecm_users(user_id);


--
-- Name: fk_ecm_member_stripe_account_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_member_stripe_account
    ADD CONSTRAINT fk_ecm_member_stripe_account_user FOREIGN KEY (user_id) REFERENCES ecm_users(user_id) ON DELETE CASCADE;


--
-- Name: fk_master_club; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_budget_category_master
    ADD CONSTRAINT fk_master_club FOREIGN KEY (club_id) REFERENCES ecm_clubs(club_id) ON DELETE CASCADE;


--
-- Name: fk_member_dues_invoice; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_member_dues
    ADD CONSTRAINT fk_member_dues_invoice FOREIGN KEY (invoice_id) REFERENCES ecm_invoice_headers(invoice_id);


--
-- Name: fk_plaid_club; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY plaid_accounts
    ADD CONSTRAINT fk_plaid_club FOREIGN KEY (club_id) REFERENCES ecm_clubs(club_id);


--
-- Name: fk_plaid_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY plaid_accounts
    ADD CONSTRAINT fk_plaid_user FOREIGN KEY (created_by_user_id) REFERENCES ecm_users(user_id);


--
-- Name: fk_transactions_due; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_clubs_transactions
    ADD CONSTRAINT fk_transactions_due FOREIGN KEY (due_id) REFERENCES ecm_member_dues(due_id);


--
-- Name: fk_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY ecm_user_clubs_mappings
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES ecm_users(user_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;
