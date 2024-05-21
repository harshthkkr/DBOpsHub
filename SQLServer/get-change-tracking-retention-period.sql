/* 
 more about change tracking tuning here: https://www.brentozar.com/archive/2014/06/performance-tuning-sql-server-change-tracking/
*/
SELECT  db.name AS change_tracking_db,
        is_auto_cleanup_on,
        retention_period,
        retention_period_units_desc
FROM    sys.change_tracking_databases ct
  JOIN    sys.databases db 
     ON     ct.database_id=db.database_id;
