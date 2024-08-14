# MySQL Backup & Restore Tool

[🇰🇷 (한국어)](./README_KO.md) | [🇬🇧 (English)](./README.md)

MySQL 데이터 백업 및 복구를 위한 Ruby 스크립트 도구

## 요구사항

* linux, Mac OS X 환경에서만 테스트 됨
* ruby, mysql, mysqldump, gzip, zcat 명령이 설치되어 있어야 한다

## 설정

데이터베이스 환경에 따라 config-<env>.json 파일을 현재 디렉토링 아래와 같이 만든다.

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

* dataTables - 큰 테이블 중 최신(3일) row 만 백업하기 위해 --where 조건을 넣기 위한 컬럼을 설정할 수 있다.
    * { "name": "table_name", "where": "column_name" }
* ignoreTables - 제외할 테이블을 설정한다.

## 설치

```shell
gem install mysql_db_tool
```

## 데이터 백업

```shell
mysql_backup -e {env} -i {backup id} -r {run?} --gzip
```

`mysql_backup -h` 로 도움말을 표시할 수 있다.

* env - 기본(dev), 설정 파일을 찾기위한 키, DB 접속 정보가 있음
* backup id - 기본(0), 문자열로 복구할때 사용할 id
* run? - 기본(false), 실제 구동될 명령을 미리 확인 할 수 있음, true 이면 실제 실행됨
* gzip? - 기본(true), gzip 으로 압축할지 여부

* DUMP_OPTIONS - 환경 변수로 공통 mysqldump 명령 옵션을 설정할 수 있음,
  해당 환경 변수가 없다면, 기본 공통 옵션이 사용됨 (--single-transaction --skip-lock-tables)

실행 완료후 현재 디렉토리 안에 backup-{backup id} 로 디렉토리가 생성된다.

## 백업 데이터 복구

```shell
mysql_restore -e {env} -i {backup id} -r {run?} --drop-all-tables
```

`mysql_restore -h` 로 도움말을 표시할 수 있다.

* drop all tables? - 기본(false), 기존 테이블을 유지하면 false, 아니면 true, true 로 하지 않으면 integration check 오류 날 수 있음

## 사용자와 데이터베이스 생성 sql 생성

데이터베이스와 사용자를 생성하는 sql 문을 생성할 수 있다.

```shell
gen_create_db_user {user} {password} {db} {host}
```

## Installing Ruby

OS 에 기본으로 설치된 ruby 를 사용해도 된다.

아래는 최신 버전의 루비를 설치하거나 개발하기 위해 추가로 진행할 수 있다.

Install using `rbenv` on Mac OS X

```shell
brew install rbenv
rbenv init
rbenv install 3.3.0
rbenv global 3.3.0
ruby -v
```
