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
│   ├── google-ads-setup.md
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

## Required Google Cloud APIs

Enable the following APIs in the same Google Cloud project that hosts your server-side GTM Cloud Run service:

```text
Data Manager API
BigQuery API
```

The Data Manager API is required for sending events to Google products. The BigQuery API is required only if BigQuery logging and automatic dataset/table creation are enabled.

## BigQuery logging configuration

Recommended fields in the template UI:

| Field name | Type | Example | Required |
|---|---|---:|---:|
| `enableBigQueryLogging` | Checkbox | `true` | Yes, for logging |
| `bqProjectId` | Text | `PROJECT_ID` | Yes |
| `bqDatasetId` | Text | `google_ads_logs` | Yes |
| `bqLocation` | Dropdown | `US` | Optional |

## BigQuery project requirement

The BigQuery dataset should be created in the **same Google Cloud project as the server-side GTM tagging server**.

Use the Google Cloud project that hosts the sGTM Cloud Run service as the `bqProjectId` value.

```text
sGTM Cloud Run project = bqProjectId
```

This keeps authentication, IAM, billing, and troubleshooting simpler. Cross-project BigQuery logging is not recommended for the default setup because the Cloud Run service account must be granted additional cross-project IAM permissions.

## Default BigQuery table

```text
PROJECT_ID.DATASET_ID.google_dm_api_logs
```

The manual schema is available in:

```text
examples/bigquery_schema.sql
```

If the dataset and table do not exist, the tag can create them automatically on the first successful run, provided that the service account has the required IAM permissions.

## Service account used by the tag

When this template runs in a server-side GTM container hosted on Google Cloud Run, it uses the **service account attached to the Cloud Run tagging server**.

You usually do **not** need to create or upload a JSON key for Cloud Run-based sGTM. The preferred setup is:

1. Use the Cloud Run service account as the execution identity.
2. Grant this service account access to Google Ads / Data Manager API and BigQuery.
3. Let the template request Google credentials through the sGTM runtime.

Example service account:

```text
sgtm-data-manager-logger@PROJECT_ID.iam.gserviceaccount.com
```


## Required IAM role for Google API access tokens

When using **Own Google Credentials**, the template calls Google APIs from the sGTM Cloud Run environment. The Cloud Run runtime service account must be able to mint OAuth access tokens for Google APIs.

Grant the Cloud Run service account the following role on the service account it runs as:

```text
Service Account Token Creator
roles/iam.serviceAccountTokenCreator
```

This role includes the permission needed to generate OAuth access tokens:

```text
iam.serviceAccounts.getAccessToken
```

For a Cloud Run-based sGTM setup, this usually means granting the role to the service account **on itself**:

```bash
PROJECT_ID="PROJECT_ID"
SA_EMAIL="sgtm-data-manager-logger@PROJECT_ID.iam.gserviceaccount.com"

gcloud iam service-accounts add-iam-policy-binding "$SA_EMAIL"   --project="$PROJECT_ID"   --member="serviceAccount:$SA_EMAIL"   --role="roles/iam.serviceAccountTokenCreator"
```

If you test locally with impersonation, for example with `gcloud auth print-access-token --impersonate-service-account=...`, your user also needs `roles/iam.serviceAccountTokenCreator` on that service account:

```bash
gcloud iam service-accounts add-iam-policy-binding "$SA_EMAIL"   --project="$PROJECT_ID"   --member="user:YOUR_EMAIL@example.com"   --role="roles/iam.serviceAccountTokenCreator"
```

Without this role, Data Manager or BigQuery REST calls may fail before the request is sent because the runtime cannot obtain the access token required by `getGoogleAuth()`.

## Google Ads requirements for sending conversions

BigQuery permissions are not enough. To send conversions to Google Ads through Data Manager API, the same Cloud Run service account also needs Google Ads access and the Google Ads destination must be configured correctly.

### 1. Add the service account to Google Ads

Add the Cloud Run service account email as a user in Google Ads:

```text
Google Ads → Admin → Access and security → Users → +
```

Use the service account email, for example:

```text
sgtm-data-manager-logger@PROJECT_ID.iam.gserviceaccount.com
```

Recommended Google Ads access level:

```text
Standard
```

Use `Admin` only if the service account also needs to create/edit conversion actions or manage account access. For sending conversions to an existing conversion action, `Standard` is the recommended starting point. `Read-only` is not appropriate for conversion upload workflows.

You can grant access directly to the Google Ads client account or indirectly through a linked manager account. If access is through a manager account, use that manager account ID as the `loginAccountId` in the tag.

### 2. Configure the Google Ads conversion action

Create or use an existing Google Ads conversion action for offline/enhanced lead imports.

For Google Ads offline conversions or enhanced conversions for leads, the Data Manager API destination must point to a Google Ads conversion action with type:

```text
UPLOAD_CLICKS
```

In the Google Ads UI, this is shown as:

```text
Website (Import from clicks)
```

The conversion action ID is the `ctId` value in the Google Ads conversion action URL:

```text
https://ads.google.com/aw/conversions/detail?...&ctId=CONVERSION_ACTION_ID&...
```

Use this ID as the tag's `productDestinationId` / `Conversion Event ID`.

### 3. Configure the Data Manager destination in the tag

For Google Ads using your own Google credentials:

```text
Authentication Type: Own Google Credentials
Product: Google Ads
Operating Customer ID: GOOGLE_ADS_CUSTOMER_ID
Customer ID / Login Account ID: GOOGLE_ADS_LOGIN_CUSTOMER_ID
Conversion Event ID: GOOGLE_ADS_CONVERSION_ACTION_ID
```

Use numeric IDs without dashes.

Examples:

```text
Direct access to the Google Ads account:
Operating Customer ID = 1234567890
Login Account ID      = 1234567890
Conversion Event ID   = 9876543210
```

```text
Access through a manager account:
Operating Customer ID = CLIENT_ACCOUNT_ID
Login Account ID      = MANAGER_ACCOUNT_ID
Conversion Event ID   = CONVERSION_ACTION_ID_FROM_CLIENT_ACCOUNT
```

### 4. Required match data in the event

For Google Ads offline conversions or enhanced conversions for leads, each event should include at least one usable matching signal, such as:

```text
gclid / gbraid / wbraid
userData such as hashed email or phone
session attributes
IP / user agent device information where applicable
```

The strongest attribution path is usually:

```text
Google click ID + hashed user data
```

PII-only events can be accepted by the API, but matching and reporting are not guaranteed 1:1 for every lead.

### 5. Consent fields

If consent is applicable, map consent explicitly:

```text
adUserData = CONSENT_GRANTED or CONSENT_DENIED
adPersonalization = CONSENT_GRANTED or CONSENT_DENIED
```

Do not send user-provided data where consent is not available or not valid for your use case.

## Required IAM permissions

### Simple setup for testing

For initial testing, grant the Cloud Run service account:

```text
roles/bigquery.admin
```

on the same Google Cloud project that hosts the sGTM tagging server.

This allows the tag to:

- check whether the dataset exists;
- create the dataset if missing;
- check whether the table exists;
- create the table if missing;
- insert log rows into the table.

This does **not** grant access to Google Ads. Google Ads access must be granted separately in the Google Ads UI.

After testing, consider replacing this broad role with a custom least-privilege role.

### Least-privilege production setup

For production, the Cloud Run service account should have the minimum BigQuery permissions needed by your chosen setup.

If the dataset and table are created manually in advance, the service account needs permissions equivalent to:

```text
bigquery.datasets.get
bigquery.tables.get
bigquery.tables.updateData
```

If the tag should auto-create the dataset and table, the service account also needs:

```text
bigquery.datasets.create
bigquery.tables.create
```

A practical production approach is:

1. Create the dataset and table manually.
2. Grant the Cloud Run service account BigQuery write access only to that dataset/table.
3. Disable or avoid relying on auto-create in production.

## Template permissions

The imported sGTM template must allow the APIs used by the code.

### Uses Google credentials

Required OAuth scopes:

```text
https://www.googleapis.com/auth/datamanager
https://www.googleapis.com/auth/bigquery
```

`datamanager` is required for Data Manager API ingestion. `bigquery` is required for automatic dataset/table creation through BigQuery REST API.

### Sends HTTP requests

Required URL patterns:

```text
https://datamanager.googleapis.com/*
https://bigquery.googleapis.com/*
```

If you use the Stape authentication flow instead of your own Google credentials, also allow the relevant Stape endpoint pattern used by your server container.

### Accesses BigQuery

Allow write access to the configured BigQuery table:

```text
PROJECT_ID.DATASET_ID.google_dm_api_logs
```

## Assigning IAM roles to the Cloud Run service account

### Google Cloud Console

1. Open **Google Cloud Console**.
2. Select the Google Cloud project that hosts the sGTM Cloud Run service.
3. Go to **IAM & Admin → IAM**.
4. Click **Grant access**.
5. In **New principals**, enter the Cloud Run service account email.
6. Add the required BigQuery role, for example:

```text
BigQuery Admin
```

for testing, or a custom least-privilege role for production.

7. Save.

### gcloud CLI

```bash
PROJECT_ID="your-project-id"
SA_EMAIL="sgtm-data-manager-logger@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/bigquery.admin"
```

## Creating a service account

Create a dedicated service account if you do not want to use the default Cloud Run service account.

### Google Cloud Console

1. Open **Google Cloud Console**.
2. Go to **IAM & Admin → Service Accounts**.
3. Click **Create service account**.
4. Enter a name, for example:

```text
sgtm-data-manager-logger
```

5. Click **Create and continue**.
6. Grant the required BigQuery role.
7. Click **Done**.
8. Attach this service account to the Cloud Run service that runs the sGTM tagging server.
9. Add this same service account email as a user in Google Ads with `Standard` access.

### gcloud CLI

```bash
PROJECT_ID="your-project-id"
SA_NAME="sgtm-data-manager-logger"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud iam service-accounts create "${SA_NAME}" \
  --project="${PROJECT_ID}" \
  --display-name="sGTM Data Manager Logger"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/bigquery.admin"
```

Attach the service account to your Cloud Run tagging server:

```bash
PROJECT_ID="your-project-id"
REGION="us-central1"
SERVICE_NAME="your-cloud-run-sgtm-service"
SA_EMAIL="sgtm-data-manager-logger@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud run services update "${SERVICE_NAME}" \
  --project="${PROJECT_ID}" \
  --region="${REGION}" \
  --service-account="${SA_EMAIL}"
```

Then add the service account email to Google Ads manually in:

```text
Admin → Access and security → Users
```

## Creating service account keys

For a Cloud Run-based sGTM setup, service account keys are normally **not required** and should be avoided when possible.

Create a JSON key only if you have a specific external system that cannot use the Cloud Run attached service account or service account impersonation.

Never commit service account keys to GitHub.

### Google Cloud Console

1. Open **Google Cloud Console**.
2. Go to **IAM & Admin → Service Accounts**.
3. Open the service account.
4. Go to **Keys**.
5. Click **Add key → Create new key**.
6. Select **JSON**.
7. Click **Create**.
8. Store the downloaded JSON file securely.

### gcloud CLI

```bash
PROJECT_ID="your-project-id"
SA_NAME="sgtm-data-manager-logger"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud iam service-accounts keys create "./${SA_NAME}.json" \
  --iam-account="${SA_EMAIL}" \
  --project="${PROJECT_ID}"
```

Security reminders:

- Do not commit `.json` key files.
- Add service account key files to `.gitignore`.
- Rotate or delete unused keys.
- Prefer Cloud Run attached service accounts over long-lived keys.

## Debug checklist

Use this checklist when conversions do not appear in Google Ads:

```text
Data Manager API enabled in the Cloud project
Cloud Run service account attached to the sGTM service
Service account added to Google Ads with Standard access
Operating Customer ID is the target Google Ads account ID
Login Account ID is the account where the service account has access
Conversion Event ID is the ctId of an UPLOAD_CLICKS conversion action
Template scope includes https://www.googleapis.com/auth/datamanager
Template can send HTTP requests to https://datamanager.googleapis.com/*
Event has at least one matching signal: click ID, userData, session attributes, or device info
requestId is returned by Data Manager API
requestStatus later becomes SUCCESS
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
