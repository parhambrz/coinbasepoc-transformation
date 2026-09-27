-- Run manually as a Snowflake administrator after reviewing organization naming.
-- This is a starting template, not a CI migration. Replace the source relation,
-- developer ID/user, and consumer role with your approved identifiers.

use role ACCOUNTADMIN;

create role if not exists ROLE_COINBASEPOC_DEV;
create role if not exists ROLE_COINBASEPOC_CI;
create role if not exists ROLE_COINBASEPOC_PROD;
create role if not exists ROLE_COINBASEPOC_BI_READER;
create role if not exists ROLE_COINBASEPOC_DEV_<DEVELOPER_ID>;
grant role ROLE_COINBASEPOC_DEV to role ROLE_COINBASEPOC_DEV_<DEVELOPER_ID>;

create warehouse if not exists WH_COINBASEPOC_DEV warehouse_size = XSMALL auto_suspend = 60 auto_resume = true initially_suspended = true;
create warehouse if not exists WH_COINBASEPOC_CI warehouse_size = XSMALL auto_suspend = 60 auto_resume = true initially_suspended = true;
create warehouse if not exists WH_COINBASEPOC_PROD warehouse_size = XSMALL auto_suspend = 60 auto_resume = true initially_suspended = true;
grant usage on warehouse WH_COINBASEPOC_DEV to role ROLE_COINBASEPOC_DEV;
grant usage on warehouse WH_COINBASEPOC_CI to role ROLE_COINBASEPOC_CI;
grant usage on warehouse WH_COINBASEPOC_PROD to role ROLE_COINBASEPOC_PROD;

create database if not exists COINBASEPOC_DEV;
create database if not exists COINBASEPOC_CI;
create database if not exists COINBASEPOC_PROD;
grant usage on database COINBASEPOC_DEV to role ROLE_COINBASEPOC_DEV;
grant usage on database COINBASEPOC_CI to role ROLE_COINBASEPOC_CI;
grant create schema on database COINBASEPOC_CI to role ROLE_COINBASEPOC_CI;
grant usage on database COINBASEPOC_PROD to role ROLE_COINBASEPOC_PROD;

-- Dev schemas are per developer; only that developer role can write them.
create schema if not exists COINBASEPOC_DEV.DBT_<DEVELOPER_ID>_STAGING;
create schema if not exists COINBASEPOC_DEV.DBT_<DEVELOPER_ID>_INTERMEDIATE;
create schema if not exists COINBASEPOC_DEV.DBT_<DEVELOPER_ID>_CORE;
create schema if not exists COINBASEPOC_DEV.DBT_<DEVELOPER_ID>_MARTS;
create schema if not exists COINBASEPOC_DEV.DBT_<DEVELOPER_ID>_SERVE;
grant ownership on schema COINBASEPOC_DEV.DBT_<DEVELOPER_ID>_STAGING to role ROLE_COINBASEPOC_DEV_<DEVELOPER_ID> copy current grants;
grant ownership on schema COINBASEPOC_DEV.DBT_<DEVELOPER_ID>_INTERMEDIATE to role ROLE_COINBASEPOC_DEV_<DEVELOPER_ID> copy current grants;
grant ownership on schema COINBASEPOC_DEV.DBT_<DEVELOPER_ID>_CORE to role ROLE_COINBASEPOC_DEV_<DEVELOPER_ID> copy current grants;
grant ownership on schema COINBASEPOC_DEV.DBT_<DEVELOPER_ID>_MARTS to role ROLE_COINBASEPOC_DEV_<DEVELOPER_ID> copy current grants;
grant ownership on schema COINBASEPOC_DEV.DBT_<DEVELOPER_ID>_SERVE to role ROLE_COINBASEPOC_DEV_<DEVELOPER_ID> copy current grants;

-- CI schemas are PR-scoped and are dropped by the trusted cleanup workflow.
-- Production layer schemas are provisioned up front; prod dbt cannot create arbitrary schemas.
create schema if not exists COINBASEPOC_PROD.STAGING;
create schema if not exists COINBASEPOC_PROD.INTERMEDIATE;
create schema if not exists COINBASEPOC_PROD.CORE;
create schema if not exists COINBASEPOC_PROD.MARTS;
create schema if not exists COINBASEPOC_PROD.SERVE;
grant usage on schema COINBASEPOC_PROD.STAGING to role ROLE_COINBASEPOC_PROD;
grant usage on schema COINBASEPOC_PROD.INTERMEDIATE to role ROLE_COINBASEPOC_PROD;
grant usage on schema COINBASEPOC_PROD.CORE to role ROLE_COINBASEPOC_PROD;
grant usage on schema COINBASEPOC_PROD.MARTS to role ROLE_COINBASEPOC_PROD;
grant usage on schema COINBASEPOC_PROD.SERVE to role ROLE_COINBASEPOC_PROD;
grant create view, create table, create dynamic table on schema COINBASEPOC_PROD.STAGING to role ROLE_COINBASEPOC_PROD;
grant create view, create table, create dynamic table on schema COINBASEPOC_PROD.INTERMEDIATE to role ROLE_COINBASEPOC_PROD;
grant create view, create table, create dynamic table on schema COINBASEPOC_PROD.CORE to role ROLE_COINBASEPOC_PROD;
grant create view, create table, create dynamic table on schema COINBASEPOC_PROD.MARTS to role ROLE_COINBASEPOC_PROD;
grant create view, create table, create dynamic table on schema COINBASEPOC_PROD.SERVE to role ROLE_COINBASEPOC_PROD;

-- Replace COINBASEPOC.INGEST.RAW_STREAM if the actual ingestion object differs.
grant usage on database COINBASEPOC to role ROLE_COINBASEPOC_DEV;
grant usage on schema COINBASEPOC.INGEST to role ROLE_COINBASEPOC_DEV;
grant select on table COINBASEPOC.INGEST.RAW_STREAM to role ROLE_COINBASEPOC_DEV;
grant usage on database COINBASEPOC to role ROLE_COINBASEPOC_CI;
grant usage on schema COINBASEPOC.INGEST to role ROLE_COINBASEPOC_CI;
grant select on table COINBASEPOC.INGEST.RAW_STREAM to role ROLE_COINBASEPOC_CI;
grant usage on database COINBASEPOC to role ROLE_COINBASEPOC_PROD;
grant usage on schema COINBASEPOC.INGEST to role ROLE_COINBASEPOC_PROD;
grant select on table COINBASEPOC.INGEST.RAW_STREAM to role ROLE_COINBASEPOC_PROD;

grant usage on database COINBASEPOC_PROD to role ROLE_COINBASEPOC_BI_READER;
grant usage on schema COINBASEPOC_PROD.CORE to role ROLE_COINBASEPOC_BI_READER;
grant usage on schema COINBASEPOC_PROD.MARTS to role ROLE_COINBASEPOC_BI_READER;
grant usage on schema COINBASEPOC_PROD.SERVE to role ROLE_COINBASEPOC_BI_READER;
grant select on all tables in schema COINBASEPOC_PROD.CORE to role ROLE_COINBASEPOC_BI_READER;
grant select on all views in schema COINBASEPOC_PROD.CORE to role ROLE_COINBASEPOC_BI_READER;
grant select on future tables in schema COINBASEPOC_PROD.CORE to role ROLE_COINBASEPOC_BI_READER;
grant select on future views in schema COINBASEPOC_PROD.CORE to role ROLE_COINBASEPOC_BI_READER;
grant select on all tables in schema COINBASEPOC_PROD.MARTS to role ROLE_COINBASEPOC_BI_READER;
grant select on all views in schema COINBASEPOC_PROD.MARTS to role ROLE_COINBASEPOC_BI_READER;
grant select on future tables in schema COINBASEPOC_PROD.MARTS to role ROLE_COINBASEPOC_BI_READER;
grant select on future views in schema COINBASEPOC_PROD.MARTS to role ROLE_COINBASEPOC_BI_READER;
grant select on all views in schema COINBASEPOC_PROD.SERVE to role ROLE_COINBASEPOC_BI_READER;
grant select on future views in schema COINBASEPOC_PROD.SERVE to role ROLE_COINBASEPOC_BI_READER;

-- Grant ROLE_COINBASEPOC_DEV_<DEVELOPER_ID> to the named developer user using approved identity.
-- Configure RSA public keys on dedicated CI and prod service users out of band.
