-- Manual BigQuery schema for Google Data Manager API request/response logs.
-- Replace PROJECT_ID and DATASET_ID before running.

CREATE SCHEMA IF NOT EXISTS `PROJECT_ID.DATASET_ID`
OPTIONS(location = 'US');

CREATE TABLE IF NOT EXISTS `PROJECT_ID.DATASET_ID.google_dm_api_logs`
(
  timestamp INT64,
  trace_id STRING,
  tag_name STRING,
  event_name STRING,

  contact_id STRING,
  transaction_id STRING,

  request_url STRING,
  request_body STRING,

  response_status_code INT64,
  response_body STRING,
  response_headers STRING,

  datamanager_request_id STRING,

  is_success BOOL,
  error_message STRING,

  has_gclid BOOL,
  has_gbraid BOOL,
  has_wbraid BOOL,
  has_any_google_click_id BOOL,

  has_email BOOL,
  has_phone BOOL,

  event_timestamp STRING,
  validate_only BOOL,

  conversion_action_id STRING,
  google_ads_customer_id STRING,
  google_ads_login_customer_id STRING
)
PARTITION BY DATE(_PARTITIONTIME)
CLUSTER BY transaction_id, datamanager_request_id, response_status_code;
