# Google Data Manager API Conversion Events with BigQuery Logger

Server-side Google Tag Manager tag template for sending conversion events to Google's Data Manager API and logging the outbound request plus the API response to BigQuery.

This is a fork/customized version of the Stape Google Data Manager API Conversion Events template with an added BigQuery logger and optional automatic dataset/table creation.

## What it does

- Sends conversion events to Google Data Manager API.
- Supports Google Ads, Campaign Manager 360, Search Ads 360, and Display & Video 360 destinations supported by the original template.
- Logs the Data Manager request body sent by the tag.
- Logs the HTTP response status, response body, response headers, and extracted `requestId`.
- Adds diagnostic fields such as click ID presence, user-data presence, conversion action ID, and Google Ads customer IDs.
- Creates the BigQuery dataset and table automatically on first run when they do not exist and the service account has sufficient IAM permissions.

## Files

```text
.
├── template/
│   └── Google_Data_Manager_API_Conversion_Events_with_Logger.tpl
├── src/
│   └── template.js
├── examples/
│   ├── bigquery_schema.sql
│   └── diagnostics_queries.sql
├── docs/
│   ├── setup.md
│   ├── permissions.md
│   └── privacy.md
├── SECURITY.md
├── NOTICE.md
└── CHANGELOG.md
```

## Installation

1. Open your **server-side GTM container**.
2. Go to **Templates → New → More actions → Import**.
3. Import:

```text
template/Google_Data_Manager_API_Conversion_Events_with_Logger.tpl
```

4. Review and approve permissions.
5. Configure the tag.

## BigQuery logging fields

Recommended fields in the template UI:

| Field name | Type | Example | Required |
|---|---|---:|---:|
| `enableBigQueryLogging` | Checkbox | `true` | Yes, for logging |
| `bqProjectId` | Text | `PROJECT_ID` | Yes |
| `bqDatasetId` | Text | `google_ads_logs` | Yes |
| `bqLocation` | Dropdown | `US` | Optional |

`bqTableId` is optional. If it is not present in the template UI, the tag uses:

```text
google_dm_api_logs
```

## Default BigQuery table

```text
PROJECT_ID.DATASET_ID.google_dm_api_logs
```

The manual schema is available in:

```text
examples/bigquery_schema.sql
```

## Required IAM permissions

For logging into an existing dataset/table, the server-side GTM Cloud Run service account needs permissions to insert rows into the table.

For automatic dataset/table creation, it also needs permissions to create datasets and tables.

See:

```text
docs/permissions.md
```

## Important privacy note

The logged `request_body` is the body sent to Google Data Manager API. User identifiers are normally hashed by the template before sending, but the request can still contain sensitive metadata such as IP address, user agent, transaction IDs, and custom variables.

Use restricted dataset access, retention controls, and avoid mapping unnecessary PII or sensitive business data.

See:

```text
docs/privacy.md
```

## License

No license is included in this repository package. Before publishing this repository publicly, verify the license terms of the upstream Stape template and choose an appropriate license.
