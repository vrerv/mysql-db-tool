# spec/mysql_db_tool/backup_spec.rb
require 'spec_helper'

require 'mysql_db_tool/config/config_loader'
require 'mysql_db_tool/backup'

RSpec.describe MySQLDBTool::Backup do
  let(:options) { { env: 'backup-test-env', id: '42', run: false, gzip: false } }
  let(:instance) { described_class.new(options) }

  before do
    allow(MySQLDBTool::Config::ConfigLoader).to receive(:load).and_return ({
      db_info: { user: 'test-user', password: '', host: 'my-host', database: ['test_db-abc'] },
      data_tables: [],
      ignore_tables: []
    })
  end

  describe '#perform' do
    it 'backs up each database' do
      fixed_time = DateTime.new(2024, 7, 17, 12, 0, 0)
      allow(DateTime).to receive(:now).and_return(fixed_time)

      commands = instance.perform
      expect(commands).to eq ([
        "mkdir -p backup-42/0_test_db-abc",
        "mysqldump --no-data  --column-statistics=0  --ssl-mode=disabled -h my-host -u test-user   test_db-abc   > backup-42/0_test_db-abc/2024-07-17_42-schema.sql",
        "mysqldump --no-create-info --single-transaction --skip-lock-tables --column-statistics=0  --ssl-mode=disabled -h my-host -u test-user   test_db-abc    > backup-42/0_test_db-abc/2024-07-17_42-all-other-tables.sql"
      ])
    end
  end

end