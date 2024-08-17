# spec/mysql_db_tool/backup_spec.rb
require 'spec_helper'

require 'mysql_db_tool/config/config_loader'
require 'mysql_db_tool/backup'

RSpec.describe MySQLDBTool::Backup do

  before do
    allow(MySQLDBTool::Config::ConfigLoader).to receive(:load).and_return ({
      db_info: { user: 'test-user', password: '', host: 'my-host', database: ['test_db-abc'] },
      data_tables: [],
      ignore_tables: []
    })

    fixed_time = DateTime.new(2024, 7, 17, 12, 0, 0)
    allow(DateTime).to receive(:now).and_return(fixed_time)
  end

  describe '#perform' do

    let(:options) { { env: 'backup-test-env', id: '42', run: false, gzip: false } }
    let(:instance) { described_class.new(options) }

    it 'backs up each database' do

      commands = instance.perform
      expect(commands).to eq ([
        "mkdir -p backup-42/0_test_db-abc",
        "mysqldump --no-data  --column-statistics=0  --ssl-mode=disabled -h my-host -u test-user   test_db-abc   > backup-42/0_test_db-abc/2024-07-17_42-schema.sql",
        "mysqldump --no-create-info  --single-transaction --skip-lock-tables --column-statistics=0  --ssl-mode=disabled -h my-host -u test-user   test_db-abc    > backup-42/0_test_db-abc/2024-07-17_42-all-other-tables.sql"
      ])
    end
  end

  describe '#perform' do

    let(:options) { { env: 'backup-test-env', id: '42', run: false, gzip: true } }
    let(:instance) { described_class.new(options) }

    it 'backs up with gzip' do

      commands = instance.perform
      expect(commands).to eq ([
        "mkdir -p backup-42/0_test_db-abc",
        "mysqldump --no-data  --column-statistics=0  --ssl-mode=disabled -h my-host -u test-user   test_db-abc  | gzip  > backup-42/0_test_db-abc/2024-07-17_42-schema.sql.gz",
        "mysqldump --no-create-info  --single-transaction --skip-lock-tables --column-statistics=0  --ssl-mode=disabled -h my-host -u test-user   test_db-abc   | gzip  > backup-42/0_test_db-abc/2024-07-17_42-all-other-tables.sql.gz"
      ])
    end
  end

  describe '#perform' do

    let(:options) { { env: 'backup-test-env', id: '42', run: false, gzip: true, gzip_suffix: '.Z' } }
    let(:instance) { described_class.new(options) }

    it 'backs up with gzip and set gzip suffix' do

      commands = instance.perform
      expect(commands).to eq ([
        "mkdir -p backup-42/0_test_db-abc",
        "mysqldump --no-data  --column-statistics=0  --ssl-mode=disabled -h my-host -u test-user   test_db-abc  | gzip  > backup-42/0_test_db-abc/2024-07-17_42-schema.sql.Z",
        "mysqldump --no-create-info  --single-transaction --skip-lock-tables --column-statistics=0  --ssl-mode=disabled -h my-host -u test-user   test_db-abc   | gzip  > backup-42/0_test_db-abc/2024-07-17_42-all-other-tables.sql.Z"
      ])
    end
  end

  describe '#perform' do

    let(:options) { { env: 'backup-test-env', id: '42', run: false, gzip: false } }
    let(:instance) { described_class.new(options) }

    it 'backs up with ignore table' do

      allow(MySQLDBTool::Config::ConfigLoader).to receive(:load).and_return ({
        db_info: { user: 'test-user', password: '', host: 'my-host', database: ['test_db-abc'] },
        data_tables: [],
        ignore_tables: ['ignore_table1', 'ignore_table2']
      })

      commands = instance.perform
      expect(commands).to eq ([
        "mkdir -p backup-42/0_test_db-abc",
        "mysqldump --no-data --ignore-table=test_db-abc.ignore_table1 --ignore-table=test_db-abc.ignore_table2 --column-statistics=0  --ssl-mode=disabled -h my-host -u test-user   test_db-abc   > backup-42/0_test_db-abc/2024-07-17_42-schema.sql",
        "mysqldump --no-create-info --ignore-table=test_db-abc.ignore_table1 --ignore-table=test_db-abc.ignore_table2 --single-transaction --skip-lock-tables --column-statistics=0  --ssl-mode=disabled -h my-host -u test-user   test_db-abc    > backup-42/0_test_db-abc/2024-07-17_42-all-other-tables.sql"
      ])
    end
  end

  describe '#perform' do

    let(:options) { { env: 'backup-test-env', id: '42', run: false, gzip: false, database: 'test_db2' } }
    let(:instance) { described_class.new(options) }

    it 'backs up with database option' do

      commands = instance.perform
      expect(commands).to eq ([
        "mkdir -p backup-42/0_test_db2",
        "mysqldump --no-data  --column-statistics=0  --ssl-mode=disabled -h my-host -u test-user   test_db2   > backup-42/0_test_db2/2024-07-17_42-schema.sql",
        "mysqldump --no-create-info  --single-transaction --skip-lock-tables --column-statistics=0  --ssl-mode=disabled -h my-host -u test-user   test_db2    > backup-42/0_test_db2/2024-07-17_42-all-other-tables.sql"
      ])
    end
  end

end