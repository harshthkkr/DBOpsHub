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
