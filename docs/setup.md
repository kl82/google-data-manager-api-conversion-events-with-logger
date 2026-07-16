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

## 2. Configure Data Manager destination

For Google Ads with your own Google credentials:

```text
Authentication Type: Own Google Credentials
Product: Google Ads
Operating Customer ID: GOOGLE_ADS_CUSTOMER_ID
Customer ID / Login Account ID: GOOGLE_ADS_LOGIN_CUSTOMER_ID
Conversion Event ID: GOOGLE_ADS_CONVERSION_ACTION_ID
```

Use numeric IDs without dashes.

## 3. Configure BigQuery logging

Recommended UI values:

```text
enableBigQueryLogging = true
bqProjectId = PROJECT_ID
bqDatasetId = google_ads_logs
bqLocation = US
```

If the `bqTableId` UI field does not exist, the tag uses this table automatically:

```text
google_dm_api_logs
```

## 4. Debug settings

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

## 5. Validate processing

After receiving a `requestId`, use the Data Manager API request status endpoint to check whether Google processed the request successfully.

A successful initial HTTP response only confirms that the API accepted the request. It does not guarantee that the conversion will be visible in Google Ads reporting immediately.
