## pg_dump and pg_restore

pg_dump is a command-line tool that helps you back up PostgreSQL databases. It creates a dump file that can be used to restore the database later.

The pg_dump and pg_restore utility is suitable for the following use cases if:
- Your database size is less than 100 GB.
- You plan to migrate database metadata as well as table data.
- You have a relatively large number of tables to migrate.

### Export Data
You can use the following command to create dump files for your source database.

```
pg_dump -h <hostname> -p 5432 -U <username> -Fc -b -v -f <dumpfilelocation.sql> -d  <database_name>

-h is the name of source server where you would like to migrate your database.
-U is the name of the user present on the source server
-Fc: Sets the output as a custom-format archive suitable for input into pg_restore.
-b: Include large objects in the dump.
-v: Specifies verbose mode
-f: Dump file path
```

### Import Data
You can use the following command to import the dump file into your destination instance.

```
pg_restore -v -h <hostname> -U <username> -d <database_name> -j 2 <dumpfilelocation.sql>
```


Reference link: https://docs.aws.amazon.com/dms/latest/sbs/chap-manageddatabases.postgresql-rds-postgresql-full-load-pd_dump.html
