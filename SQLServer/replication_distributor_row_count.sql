WITH MaxXact (ServerName, DistAgentName, PublisherDBID, XactSeqNo)
AS (SELECT S.name,
           DA.name,
           DA.publisher_database_id,
           MAX(H.xact_seqno)
    FROM dbo.MSdistribution_history H WITH (NOLOCK)
        INNER JOIN dbo.MSdistribution_agents DA WITH (NOLOCK)
            ON DA.id = H.agent_id
        INNER JOIN master.sys.servers S WITH (NOLOCK)
            ON S.server_id = DA.subscriber_id
    GROUP BY S.name,
             DA.name,
             DA.publisher_database_id)
SELECT MX.ServerName,
       MX.DistAgentName,
       MX.PublisherDBID,
       COUNT(*) AS TransactionsNotReplicated
FROM dbo.msrepl_transactions T WITH (NOLOCK)
    RIGHT JOIN MaxXact MX
        ON MX.XactSeqNo < T.xact_seqno
           AND MX.PublisherDBID = T.publisher_database_id
-- where MX.DistAgentName = '<agentNAme>'
GROUP BY MX.ServerName,
         MX.DistAgentName,
         MX.PublisherDBID
ORDER BY 4 DESC;