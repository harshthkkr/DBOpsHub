/* 
  simple query to find plan handles for a plan based on 
  a unique text string. 
  WARNING: be sure the plan you find is correct. If your search
  string is not unique enough, you could wind up looking at
  or clearing the wrong plan.
*/
SELECT top 10 * 
FROM sys.dm_exec_cached_plans AS cp 
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st  
WHERE st.TEXT LIKE '%<insert unique text here>%'

--Get the execution plan from handle
SELECT * FROM sys.dm_exec_query_plan (<plan handle from the first query>)

-- Remove the specific plan from the cache.
--DBCC FREEPROCCACHE (0x060006001ECA270EC0215D05000000000000000000000000);
