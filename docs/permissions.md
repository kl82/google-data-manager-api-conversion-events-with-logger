# Permissions

This template has two permission layers:

1. **Server-side GTM template permissions** — what the custom template is allowed to do.
2. **External account permissions** — what the Cloud Run service account is allowed to access in Google Cloud and Google Ads.

## Template permissions

The template requires the following server-side GTM permissions.

### Sends HTTP requests

```text
https://datamanager.googleapis.com/*
https://bigquery.googleapis.com/*
https://*.stape.io/*
https://*.stape.net/*
```

`datamanager.googleapis.com` is required to send conversion events.

`bigquery.googleapis.com` is required only for automatic dataset/table creation through the BigQuery REST API.

Stape endpoints are required only if you use the Stape authentication flow.

### Uses Google credentials

```text
https://www.googleapis.com/auth/datamanager
https://www.googleapis.com/auth/bigquery
```

`datamanager` is required for Data Manager API ingestion.

`bigquery` is required for automatic BigQuery dataset/table creation via REST API.

If you create the BigQuery dataset/table manually and remove auto-create logic, the template can rely on `BigQuery.insert` and does not need BigQuery REST calls.

### Accesses BigQuery

Recommended during initial testing:

```text
operation: write
projectId: PROJECT_ID
datasetId: DATASET_ID
tableId: google_dm_api_logs
```

You can temporarily use wildcards while debugging, then narrow the permissions after the final project/dataset/table are known.

### Reads request headers

The template reads headers used by the original Stape template and by tracing/logging, including:

```text
trace-id
referer
x-gtm-identifier
x-gtm-default-domain
x-gtm-api-key
```

### Reads event data

The template reads event data to build the Data Manager event payload and diagnostic logging fields.



## Google Cloud IAM for Data Manager API / Google Ads uploads

For **Own Google Credentials**, the tag uses Google Cloud Application Default Credentials from the sGTM Cloud Run runtime and requests OAuth tokens for Google APIs.

The Cloud Run runtime service account should have:

```text
Service Account Token Creator
roles/iam.serviceAccountTokenCreator
```

Grant it on the service account itself in the same project:

```bash
PROJECT_ID="PROJECT_ID"
SA_EMAIL="sgtm-data-manager-logger@PROJECT_ID.iam.gserviceaccount.com"

gcloud iam service-accounts add-iam-policy-binding "$SA_EMAIL"   --project="$PROJECT_ID"   --member="serviceAccount:$SA_EMAIL"   --role="roles/iam.serviceAccountTokenCreator"
```

This is separate from Google Ads account access. The IAM role allows the Cloud Run service account to obtain Google API access tokens; Google Ads access determines whether those API calls are authorized to upload conversions to the Ads account.

If a human user or CI/CD job impersonates this service account for testing/deployment, grant the same role to that principal on the service account:

```bash
gcloud iam service-accounts add-iam-policy-binding "$SA_EMAIL"   --project="$PROJECT_ID"   --member="user:YOUR_EMAIL@example.com"   --role="roles/iam.serviceAccountTokenCreator"
```

## Google Cloud IAM for BigQuery logging

The Cloud Run service account attached to the server-side GTM service needs BigQuery access in the same Google Cloud project as the tagging server.

For writing rows to an existing table, the service account needs a role that includes:

```text
bigquery.datasets.get
bigquery.tables.get
bigquery.tables.updateData
```

For automatic resource creation, it also needs:

```text
bigquery.datasets.create
bigquery.tables.create
```

For a quick test, you can temporarily grant:

```text
BigQuery Admin
```

After validation, reduce the permissions to a custom role or narrower dataset-level access.

## Google Ads access for conversion uploads

The Cloud Run service account also needs access in Google Ads. BigQuery IAM roles do not grant Google Ads access.

Add the service account email in:

```text
Google Ads → Admin → Access and security → Users
```

Recommended access level:

```text
Standard
```

Use `Admin` only if the service account also needs to create/edit conversion actions or manage users/access.

If the service account is added directly to the target Google Ads account, use the target account ID as both:

```text
Operating Customer ID
Login Account ID
```

If the service account is added to a manager account, use:

```text
Operating Customer ID = target client account ID
Login Account ID      = manager account ID
```

The effective access path must allow the service account to reach the target Google Ads account.

## Google Ads conversion action requirements

For Google Ads offline conversions or enhanced conversions for leads, the Data Manager API destination should use a conversion action with type:

```text
UPLOAD_CLICKS
```

In Google Ads UI this is:

```text
Website (Import from clicks)
```

Use the conversion action `ctId` as the template's Conversion Event ID / Product Destination ID.

## Required Data Manager destination fields

For Google Ads with own Google credentials:

```text
Product: Google Ads
Operating Customer ID: target Google Ads account ID
Login Account ID: account where the service account has access
Conversion Event ID: Google Ads conversion action ctId
```

Use numeric IDs without dashes.
