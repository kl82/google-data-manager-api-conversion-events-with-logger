# Google Ads setup for Data Manager API conversion uploads

This template can send conversion events to Google Ads through Google's Data Manager API. The BigQuery logger only proves that the request was sent and what response Google returned. Google Ads conversion ingestion also requires Google Ads account access and a valid conversion action.

## 1. Service account access in Google Ads

Add the Cloud Run service account email as a Google Ads user:

```text
Google Ads → Admin → Access and security → Users → +
```

Recommended access level:

```text
Standard
```

Use `Admin` only if the service account also needs to create or edit conversion actions, manage account access, or perform admin-only account changes.


## 1A. Google Cloud IAM role for token creation

Before Google Ads can receive conversions, the sGTM Cloud Run runtime must be able to obtain OAuth access tokens for Google APIs.

Grant the Cloud Run service account:

```text
Service Account Token Creator
roles/iam.serviceAccountTokenCreator
```

Recommended binding for Cloud Run-based sGTM:

```bash
PROJECT_ID="PROJECT_ID"
SA_EMAIL="sgtm-data-manager-logger@PROJECT_ID.iam.gserviceaccount.com"

gcloud iam service-accounts add-iam-policy-binding "$SA_EMAIL"   --project="$PROJECT_ID"   --member="serviceAccount:$SA_EMAIL"   --role="roles/iam.serviceAccountTokenCreator"
```

This role is required for access-token creation. It does **not** replace adding the same service account as a user in Google Ads.

## 2. Direct access vs manager account access

### Direct access

If the service account is added directly to the target Google Ads account:

```text
Operating Customer ID = target Google Ads account ID
Login Account ID      = target Google Ads account ID
```

### Manager account access

If the service account is added to a manager account:

```text
Operating Customer ID = client account ID that receives the conversion
Login Account ID      = manager account ID where the service account has access
```

The manager account must be linked to the client account.

## 3. Conversion action requirement

For offline conversions and enhanced conversions for leads, use a Google Ads conversion action with type:

```text
UPLOAD_CLICKS
```

In the Google Ads UI, this is shown as:

```text
Website (Import from clicks)
```

The conversion action ID is the `ctId` query parameter in the conversion action detail page URL.

## 4. Destination configuration in the tag

```text
Authentication Type: Own Google Credentials
Product: Google Ads
Operating Customer ID: target Google Ads account ID
Customer ID / Login Account ID: direct account ID or manager account ID
Conversion Event ID: Google Ads conversion action ctId
```

Use IDs without dashes.

## 5. Event match data

For each event, provide at least one useful matching signal:

```text
gclid
gbraid
wbraid
hashed email
hashed phone
session attributes
IP / user agent device information where applicable
```

Recommended for lead-generation tracking:

```text
click ID + hashed email/phone + transactionId/contact_id
```

## 6. Consent

Map consent fields where applicable:

```text
adUserData
adPersonalization
```

Only send user-provided data where consent and local privacy requirements allow it.

## 7. Validation

A valid debug sequence is:

```text
Tag fires
Data Manager HTTP response includes requestId
BigQuery log row is written
requestStatus later returns SUCCESS
Google Ads diagnostics show no upload/configuration errors
```

`requestStatus = SUCCESS` confirms that Data Manager processed the request. It does not guarantee that every event will immediately appear as a visible conversion in Google Ads reporting, especially for PII-only events without click IDs.
