--Total Active Connections
SELECT
  COUNT(*) as active_query_count
FROM
  pg_stat_activity
WHERE
  state='active';


-- show running queries 
SELECT pid, age(clock_timestamp(), query_start), usename, query 
FROM pg_stat_activity 
WHERE query != '<IDLE>' AND query NOT ILIKE '%pg_stat_activity%' 
ORDER BY query_start desc;


-- kill running query
SELECT pg_cancel_backend(procpid);

-- kill idle query
SELECT pg_terminate_backend(procpid);