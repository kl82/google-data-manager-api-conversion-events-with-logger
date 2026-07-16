# Permissions

## Template permissions

The template requires the following server-side GTM permissions.

### Sends HTTP requests

```text
https://datamanager.googleapis.com/*
https://bigquery.googleapis.com/*
https://*.stape.io/*
https://*.stape.net/*
```

`bigquery.googleapis.com` is required only for automatic dataset/table creation through the BigQuery REST API.

### Uses Google credentials

```text
https://www.googleapis.com/auth/datamanager
https://www.googleapis.com/auth/bigquery
```

`datamanager` is required for Data Manager API ingestion.

`bigquery` is required for automatic BigQuery dataset/table creation via REST API.

### Accesses BigQuery

```text
operation: write
projectId: *
datasetId: *
tableId: *
```

You can narrow these permissions after importing the template.

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

## Cloud Run service account IAM

For writing rows to an existing table, the Cloud Run service account needs a role that includes:

```text
bigquery.tables.updateData
```

For automatic resource creation, it also needs:

```text
bigquery.datasets.create
bigquery.tables.create
bigquery.tables.get
```

For a quick test, you can temporarily grant:

```text
BigQuery Admin
```

After validation, reduce the permissions to a custom role or narrower dataset-level access.
