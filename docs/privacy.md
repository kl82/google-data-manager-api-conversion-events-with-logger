# Privacy and security notes

This template can log conversion payloads and API responses to BigQuery.

## What may be logged

The BigQuery row can include:

- Data Manager request body
- Data Manager response body
- response headers
- request URL
- transaction ID
- contact ID
- conversion action ID
- Google Ads customer IDs
- click ID presence flags
- user-data presence flags
- IP address and user agent if these are mapped into the Data Manager request

User identifiers such as email and phone are normally hashed before the request is sent to Google and before `request_body` is logged. However, custom variables, event metadata, IP address, user agent, and internal IDs may still be sensitive.

## Recommendations

- Do not map unnecessary PII into custom variables.
- Do not log raw inbound webhook bodies unless they are sanitized.
- Restrict BigQuery dataset access.
- Set a retention policy for the logging dataset.
- Avoid public sharing of exported logs.
- Use a separate dataset for debugging if needed.
- Disable or narrow logging after validation if permanent request/response logging is not required.

## Public repository warning

Do not commit:

- service account keys
- access tokens
- client secrets
- real request logs
- real lead records
- customer emails, phone numbers, addresses, IPs, or application data
