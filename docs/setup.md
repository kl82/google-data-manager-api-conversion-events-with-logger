# Setup

## 1. Import the template

In your server-side GTM container:

```text
Templates → New → More actions → Import
```

Import:

```text
template/Google_Data_Manager_API_Conversion_Events_with_Logger.tpl
```

## 2. Enable required Google Cloud APIs

In the same Google Cloud project that hosts the sGTM Cloud Run service, enable:

```text
Data Manager API
BigQuery API
```

## 3. Confirm the Cloud Run service account

Find the service account attached to the sGTM Cloud Run service.

This service account is the identity used by the template when `Authentication Type = Own Google Credentials`.

## 4. Grant BigQuery permissions

For testing, grant the Cloud Run service account:

```text
BigQuery Admin
```

For production, use narrower permissions. See:

```text
docs/permissions.md
```

## 5. Add the service account to Google Ads

Open the Google Ads account or manager account that should provide access:

```text
Google Ads → Admin → Access and security → Users → +
```

Add the Cloud Run service account email, for example:

```text
sgtm-data-manager-logger@PROJECT_ID.iam.gserviceaccount.com
```

Recommended access level:

```text
Standard
```

Use `Admin` only if the service account also needs to create/edit conversion actions or manage account access.

## 6. Configure the Google Ads conversion action

Create or use a conversion action for offline/enhanced lead imports:

```text
Source: Website / Import from clicks
Type: UPLOAD_CLICKS
```

Open the conversion action details page and copy the `ctId` value from the URL.

```text
https://ads.google.com/aw/conversions/detail?...&ctId=CONVERSION_ACTION_ID&...
```

Use this value as the tag's Conversion Event ID / Product Destination ID.

## 7. Configure Data Manager destination in the tag

For Google Ads with your own Google credentials:

```text
Authentication Type: Own Google Credentials
Product: Google Ads
Operating Customer ID: GOOGLE_ADS_CUSTOMER_ID
Customer ID / Login Account ID: GOOGLE_ADS_LOGIN_CUSTOMER_ID
Conversion Event ID: GOOGLE_ADS_CONVERSION_ACTION_ID
```

Use numeric IDs without dashes.

### Direct account access example

```text
Operating Customer ID = 1234567890
Login Account ID      = 1234567890
Conversion Event ID   = 9876543210
```

### Manager account access example

```text
Operating Customer ID = CLIENT_ACCOUNT_ID
Login Account ID      = MANAGER_ACCOUNT_ID
Conversion Event ID   = CONVERSION_ACTION_ID_FROM_CLIENT_ACCOUNT
```

## 8. Configure BigQuery logging

Recommended UI values:

```text
enableBigQueryLogging = true
bqProjectId = PROJECT_ID
bqDatasetId = google_ads_logs
bqLocation = US
```

`bqProjectId` should be the same Google Cloud project that hosts the sGTM Cloud Run service.

If the `bqTableId` UI field does not exist, the tag uses this table automatically:

```text
google_dm_api_logs
```

## 9. Debug settings

For debugging, use:

```text
Use Optimistic Scenario = false
Validate Only = false
enableBigQueryLogging = true
```

The tag should log:

```text
Data Manager request URL
Data Manager request body
HTTP response status code
HTTP response body
Data Manager requestId
```

## 10. Validate processing

After receiving a `requestId`, use the Data Manager API request status endpoint to check whether Google processed the request successfully.

A successful initial HTTP response only confirms that the API accepted the request. It does not guarantee that the conversion will be visible in Google Ads reporting immediately.

## 11. Troubleshooting checklist

```text
Data Manager API enabled in the Cloud project
Template allows https://www.googleapis.com/auth/datamanager
Template allows https://datamanager.googleapis.com/*
Cloud Run service account is attached to the sGTM service
Service account is added to Google Ads with Standard access
Operating Customer ID is the target Google Ads account ID
Login Account ID is the account where the service account has access
Conversion Event ID is the ctId of an UPLOAD_CLICKS conversion action
Event has at least one matching signal
BigQuery dataset is in the same project as the sGTM Cloud Run service
```


## Service Account Token Creator role

When using **Own Google Credentials**, grant the Cloud Run runtime service account `roles/iam.serviceAccountTokenCreator` on itself so the tag can obtain OAuth access tokens for Google APIs.

```bash
PROJECT_ID="PROJECT_ID"
SA_EMAIL="sgtm-data-manager-logger@PROJECT_ID.iam.gserviceaccount.com"

gcloud iam service-accounts add-iam-policy-binding "$SA_EMAIL"   --project="$PROJECT_ID"   --member="serviceAccount:$SA_EMAIL"   --role="roles/iam.serviceAccountTokenCreator"
```

Also grant this role to any human user or CI/CD principal that impersonates the service account during testing or deployment.
