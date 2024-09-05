DECLARE @loginname VARCHAR(MAX) = 'pricing_desk_app'
-- Create a temporary table to store results

DROP TABLE IF EXISTS #AllDatabasesPermissions
CREATE TABLE #AllDatabasesPermissions
(
	[database] NVARCHAR(256),
    UserName NVARCHAR(256),
    UserType NVARCHAR(256),
    DatabaseUserName NVARCHAR(256),
    Role NVARCHAR(256),
    PermissionType NVARCHAR(256),
    PermissionState NVARCHAR(256),
    ObjectType NVARCHAR(256),
    ObjectName NVARCHAR(256),
    ColumnName NVARCHAR(256)
);

DECLARE @DbName NVARCHAR(256);
DECLARE @DynamicSQL NVARCHAR(MAX);

-- Cursor to iterate through all databases
DECLARE db_cursor CURSOR FOR 
SELECT name 
FROM sys.databases 
WHERE state = 0 -- Only online databases
AND name NOT IN ('master', 'tempdb', 'model', 'msdb'); -- Exclude system databases

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @DbName  

WHILE @@FETCH_STATUS = 0  
BEGIN  
    -- Construct the dynamic SQL command to execute the query in the context of the current database
    SET @DynamicSQL = '
    USE [' + @DbName + '];
    INSERT INTO #AllDatabasesPermissions ([database],UserName, UserType, DatabaseUserName, Role, PermissionType, PermissionState, ObjectType, ObjectName, ColumnName)
    SELECT  
	db_name(),
    [UserName] = CASE princ.[type] 
                    WHEN ''S'' THEN princ.[name]
                    WHEN ''U'' THEN ulogin.[name] COLLATE Latin1_General_CI_AI
                 END,
    [UserType] = CASE princ.[type]
                    WHEN ''S'' THEN ''SQL User''
                    WHEN ''U'' THEN ''Windows User''
                 END,  
    [DatabaseUserName] = princ.[name],       
    [Role] = null,      
    [PermissionType] = perm.[permission_name],       
    [PermissionState] = perm.[state_desc],       
    [ObjectType] = obj.type_desc,--perm.[class_desc],       
    [ObjectName] = OBJECT_NAME(perm.major_id),
    [ColumnName] = col.[name]
FROM    
    --database user
    sys.database_principals princ  
LEFT JOIN
    --Login accounts
    sys.login_token ulogin on princ.[sid] = ulogin.[sid]
LEFT JOIN        
    --Permissions
    sys.database_permissions perm ON perm.[grantee_principal_id] = princ.[principal_id]
LEFT JOIN
    --Table columns
    sys.columns col ON col.[object_id] = perm.major_id 
                    AND col.[column_id] = perm.[minor_id]
LEFT JOIN
    sys.objects obj ON perm.[major_id] = obj.[object_id]
	 
WHERE 
    princ.[type] in (''S'',''U'') AND princ.[name]=''' + @loginname + ''' OR ulogin.[name]=''' + @loginname + '''
UNION
--List all access provisioned to a sql user or windows user/group through a database or application role
SELECT  
db_name(),
    [UserName] = CASE memberprinc.[type] 
                    WHEN ''S'' THEN memberprinc.[name]
                    WHEN ''U'' THEN ulogin.[name] COLLATE Latin1_General_CI_AI
                 END,
    [UserType] = CASE memberprinc.[type]
                    WHEN ''S'' THEN ''SQL User''
                     WHEN ''U'' THEN ''Windows User''
                 END,    
    [DatabaseUserName] = memberprinc.[name],   
    [Role] = roleprinc.[name],      
    [PermissionType] = perm.[permission_name],       
    [PermissionState] = perm.[state_desc],       
    [ObjectType] = obj.type_desc,--perm.[class_desc],   
    [ObjectName] = OBJECT_NAME(perm.major_id),
    [ColumnName] = col.[name]
FROM    
    --Role/member associations
    sys.database_role_members members
JOIN
    --Roles
    sys.database_principals roleprinc ON roleprinc.[principal_id] = members.[role_principal_id]
JOIN
    --Role members (database users)
    sys.database_principals memberprinc ON memberprinc.[principal_id] = members.[member_principal_id]
LEFT JOIN
    --Login accounts
    sys.login_token ulogin on memberprinc.[sid] = ulogin.[sid]
LEFT JOIN        
    --Permissions
    sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
LEFT JOIN
    --Table columns
    sys.columns col on col.[object_id] = perm.major_id 
                    AND col.[column_id] = perm.[minor_id]
LEFT JOIN
    sys.objects obj ON perm.[major_id] = obj.[object_id]
	WHERE memberprinc.[name]=''' + @loginname + ''' OR ulogin.[name]=''' + @loginname + ''''

    -- Execute the dynamic SQL
    EXEC sp_executesql @DynamicSQL;

    FETCH NEXT FROM db_cursor INTO @DbName  
END  

CLOSE db_cursor;
DEALLOCATE db_cursor;

-- Select the results
SELECT * FROM #AllDatabasesPermissions;

-- Drop the temporary table
DROP TABLE #AllDatabasesPermissions;
