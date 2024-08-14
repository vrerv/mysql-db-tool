# MySQL Backup & Restore Tool

[🇰🇷 (한국어)](./README_KO.md) | [🇬🇧 (English)](./README.md)

A ruby script tool for backing up and restoring MySQL data.

## Requirements

* Tested on linux, Mac OS X environments only
* ruby, mysql, mysqldump, gzip, zcat commands must be installed

## Configuration

Create a config-<env>.json file under the current directory according to the database environment.

```json
{
  "dataTables": [],
  "ignoreTables": [],
  "dbInfo": {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "",
    "database": [
      "test_db"
    ]
  }
}
```

* dataTables - allows you to set a column for putting a --where condition to backup only the latest(3 days) rows of a large table.
    * { "name": "table_name", "where": "column_name" }
* ignoreTables - allows you to set which tables should be excluded from backups as unused tables.

## Install

```shell
gem install mysql_db_tool
```

## Data backup

```shell
mysql_backup -e {env} -i {backup id} -r {run?} --gzip
```

you can get help by running `mysql_backup -h`

* env - default (local), key to find the configuration file. e.g.) config-local.json
* backup id - default (0), ID to use when restoring as a string
* run? - Default (false), you can check in advance which command will be executed, if true, it will be executed
* gzip? - default (true), whether to compress with gzip or not

* DUMP_OPTIONS - you can set common mysqldump command options by this Environment variable,
  if not set, it will use default options for mysqldump. (--single-transaction --skip-lock-tables)

After execution, a directory named "backup-{backup id}" will be created under the current directory.

## restore backup data

```shell
mysql_restore -e {env} -i {backup id} -r {run?} --drop-all-tables
```

you can get help by running `mysql_restore -h`

* drop all tables? - Default (false), to keep existing tables, or true, which may cause integration check error if not set to true

## Generate creating db and user sql

You can generate a sql script to create a db and user.

```shell
gen_create_db_user {user} {password} {db} {host}
```

## Installing Ruby

You can use OS default ruby if it is already installed.

Below is additional steps to install or develop with the latest version of Ruby.

Install using `rbenv` on Mac OS X

```bash
brew install rbenv
rbenv init
rbenv install 3.3.0
rbenv global 3.3.0
ruby -v
```

