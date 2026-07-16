-- Replace PROJECT_ID and DATASET_ID before running.

-- Daily upload health by match path.
SELECT
  DATE(TIMESTAMP_MILLIS(timestamp)) AS upload_date,
  CASE
    WHEN has_any_google_click_id AND (has_email OR has_phone) THEN 'click_id_plus_pii'
    WHEN has_any_google_click_id THEN 'click_id_only'
    WHEN has_email OR has_phone THEN 'pii_only'
    ELSE 'no_match_data'
  END AS match_path,
  COUNT(*) AS uploaded,
  COUNTIF(response_status_code BETWEEN 200 AND 399) AS http_success,
  COUNTIF(datamanager_request_id IS NOT NULL AND datamanager_request_id != '') AS got_request_id,
  COUNTIF(error_message IS NOT NULL AND error_message != '') AS with_errors
FROM `PROJECT_ID.DATASET_ID.google_dm_api_logs`
GROUP BY upload_date, match_path
ORDER BY upload_date DESC, match_path;

-- Recent failed/non-2xx responses.
SELECT
  TIMESTAMP_MILLIS(timestamp) AS log_time,
  event_name,
  transaction_id,
  response_status_code,
  datamanager_request_id,
  error_message,
  response_body
FROM `PROJECT_ID.DATASET_ID.google_dm_api_logs`
WHERE response_status_code IS NULL
   OR response_status_code < 200
   OR response_status_code >= 400
ORDER BY timestamp DESC
LIMIT 100;

-- Recent successful uploads with request IDs.
SELECT
  TIMESTAMP_MILLIS(timestamp) AS log_time,
  transaction_id,
  datamanager_request_id,
  conversion_action_id,
  google_ads_customer_id,
  has_gclid,
  has_gbraid,
  has_wbraid,
  has_email,
  has_phone
FROM `PROJECT_ID.DATASET_ID.google_dm_api_logs`
WHERE response_status_code BETWEEN 200 AND 399
ORDER BY timestamp DESC
LIMIT 100;
