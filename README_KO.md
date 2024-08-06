# MySQL Backup & Restore Tool

[🇰🇷 (한국어)](./README_KO.md) | [🇬🇧 (English)](./README.md)

MySQL 데이터 백업 및 복구를 위한 Ruby 스크립트 도구

## 요구사항

* linux, Mac OS X 환경에서만 테스트 됨
* ruby, mysql, mysqldump, pv, gzip, zcat 명령이 설치되어 있어야 한다

## 데이터 백업

```shell
./backup.rb {profile} {backup id} {run?} {gzip?}
```

* profile - 기본(dev), config 안에 db-info-<profile> 로 맵핑, DB 접속 정보가 있음
* backup id - 기본(0), 문자열로 복구할때 사용할 id
* run? - 기본(false), 실제 구동될 명령을 미리 확인 할 수 있음, true 이면 실제 실행됨
* gzip? - 기본(true), gzip 으로 압축할지 여부

실행 완료후 현재 디렉토리 안에 backup-{backup id} 로 디렉토리가 생성된다.

## 백업 데이터 복구

```shell
./restore.rb <profile> {backup id} {run?} {drop all tables?}
```

* drop all tables? - 기본(false), 기존 테이블을 유지하면 false, 아니면 true, true 로 하지 않으면 integration check 오류 날 수 있음

## config 

* config/ 디렉토리 안에 설정 파일들이 있다.
* data-tables.rb - 큰 테이블 중 최신 row 만 백업하기 위해 --where 조건을 넣기 위한 컬럼을 설정할 수 있다.
* ignore-tables.rb - 사용하지 않는 테이블로 백업에서 제외해야 할 테이블 설정 할 수 있다.
* db-info-{profile}.rb - {profile} 별 db 접속 정보를 설정할 수 있다.

## Installing Ruby

Install using `rbenv` on Mac OS X

```shell
brew install rbenv
rbenv init
rbenv install 3.3.0
rbenv global 3.3.0
ruby -v
```

## TODO

* [ ] db 설정 정보는 spring cloud config 에서 가져 오는 옵션 추가
* [ ] 자동화된 unit test 작성 필요
* [ ] 인수 입력시 linux 표준 명령행 인수 입력 형식 --backup-id=1 형태로 변경
* [ ] 멀티 데이터 베이스 지원