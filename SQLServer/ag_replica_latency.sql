
;WITH
	ag_stats AS
			(
			SELECT AR.replica_server_name
				   ,HARS.role_desc
				   ,DB_NAME(DRS.database_id) [db_name]
				   ,DRS.last_commit_time
			FROM   sys.dm_hadr_database_replica_states DRS
				JOIN 	sys.availability_replicas AR
					ON 		DRS.replica_id = AR.replica_id
				JOIN 	sys.dm_hadr_availability_replica_states HARS
					ON 		AR.group_id = HARS.group_id
				AND AR.replica_id = HARS.replica_id
			),
	pri_commit_time AS
			(
			SELECT	replica_server_name
					,db_name
					,last_commit_time
			FROM	ag_stats
			WHERE	role_desc = 'PRIMARY'
			),
	sec_commit_time AS
			(
			SELECT	replica_server_name
					, db_name
					, last_commit_time
			FROM	ag_stats
			WHERE	role_desc = 'SECONDARY'
			)
SELECT 	SYSUTCDATETIME() AS metric_time
		,p.replica_server_name AS primary_replica
		,p.[db_name] AS database_name
		,s.replica_server_name AS secondary_replica
		,DATEDIFF(ss, s.last_commit_time, p.last_commit_time) AS replica_latency_s
FROM 	pri_commit_time p
	LEFT JOIN 	sec_commit_time s
		ON 			s.db_name = p.db_name;
