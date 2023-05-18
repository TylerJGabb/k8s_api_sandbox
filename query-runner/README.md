# Query Runner

does two things

1. keeps a catalog of pii service endpoints in the namespace
2. runs queries for users by obtaining tokens from said services to use when invoking the BQ rest API

## TODO: REname this directory query-runner

https://cloud.google.com/bigquery/docs/reference/rest/v2/jobs/query

```
curl -X GET \
  -H "Content-Type: application/json" \
  -d '{
    "query": "select * from `sb-05-386818.multiregion.table_with_pii`",
    "piiPermission": "all"
}' 'http://localhost/query'
```
