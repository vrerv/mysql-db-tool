
## Example

A script for dump db from `myapp-prod` to `myapp-dev`

```bash
DUMP_ID=myapp-prod-$BUILD_NUMBER
DUMP_OPTIONS="--lock-tables=false" mysql_backup -e myapp-prod -i $DUMP_ID -r --no-gzip
DUMP_OPTIONS="--lock-tables=false" mysql_backup -e myapp-dev -i myapp-dev-$BUILD_NUMBER -r --no-gzip

# remove limited command in AWS master account
find ./backup-$DUMP_ID -name "*.sql" -exec ruby -i.bak -pe 'gsub(/SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;/i, "")' {} \;
find ./backup-$DUMP_ID -name "*.sql" -exec ruby -i.bak -pe 'gsub(/SET @@SESSION.SQL_LOG_BIN= 0;/i, "")' {} \;
find ./backup-$DUMP_ID -name "*.sql" -exec ruby -i.bak -pe 'gsub(/SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;/i, "")' {} \;
find ./backup-$DUMP_ID -name "*.sql" -exec ruby -i.bak -pe 'gsub(/SET @@GLOBAL.GTID_PURGED=.*;/i, "")' {} \;
find ./backup-$DUMP_ID -name "*.sql" -exec ruby -i.bak -pe 'gsub(/utf8mb4_0900_ai_ci/i, "utf8mb4_general_ci")' {} \;
# keey original backup file or remove it by uncommenting the following line
# find $1 -name "*.sql.bak" -exec rm {} \;

mysql_restore -e myapp-dev -i $DUMP_ID -r --no-drop-all-tables
```