DECLARE 
  @RC INT = 1;

WHILE (@RC > 0)
BEGIN

  DELETE TOP (1000) <tableName>
  WHERE <condition>;

  SET @RC = @@ROWCOUNT

END