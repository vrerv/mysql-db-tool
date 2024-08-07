# MySQL Backup & Restore Tool

[🇰🇷 (한국어)](./README_KO.md) | [🇬🇧 (English)](./README.md)

A ruby script tool for backing up and restoring MySQL data.

## Requirements

* Tested on linux, Mac OS X environments only
* ruby, mysql, mysqldump, pv, gzip, zcat commands must be installed

## Data backup

```shell
./backup.rb {profile} {backup id} {run?} {gzip?}
```

* profile - default (dev), mapped to db-info-<profile> in config, has DB connection information
* backup id - default (0), ID to use when restoring as a string
* run? - Default (false), you can check in advance which command will be executed, if true, it will be executed
* gzip? - default (true), whether to compress with gzip or not

* DUMP_OPTIONS - you can set common mysqldump command options by this Environment variable,
  if not set, it will use default options for mysqldump. (--single-transaction --skip-lock-tables)

After execution, a directory named "backup-{backup id}" will be created under the current directory.

## restore backup data

```shell
./restore.rb <profile> {backup id} {run?} {drop all tables?}
```

* drop all tables? - Default (false), to keep existing tables, or true, which may cause integration check error if not set to true

## config

* config/ directory contains the configuration files.
* data-tables.rb - allows you to set a column for putting a --where condition to backup only the latest rows of a large table.
* ignore-tables.rb - allows you to set which tables should be excluded from backups as unused tables.
* db-info-{profile}.rb - configures db access information for each profile.

## Installing Ruby

Install using `rbenv` on Mac OS X

```bash
brew install rbenv
rbenv init
rbenv install 3.3.0
rbenv global 3.3.0
ruby -v
```

## TODO

* [ ] Add option to get db configuration information from spring cloud config
* [ ] Need to write automated unit tests
* [ ] Change linux standard command line argument input format to --backup-id=1 when inputting arguments
