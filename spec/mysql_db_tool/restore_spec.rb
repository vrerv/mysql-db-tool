# spec/mysql_db_tool/restore_spec.rb
require 'spec_helper'

require 'mysql_db_tool/config/config_loader'
require 'mysql_db_tool/restore'

RSpec.describe MySQLDBTool::Restore do
  let(:options) { { environment: 'test', backup_id: '1', run: false, drop_all_tables: false } }
  let(:instance) { described_class.new(options) }

  before do
    allow(MySQLDBTool::Config::ConfigLoader).to receive(:load).and_return ({
      db_info: { user: 'test-user', password: '', host: 'my-host', database: ['test_db-abc'] },
      data_tables: [],
      ignore_tables: []
    })

  end

  describe '#perform' do
    it 'restores each database' do
      allow(Dir).to receive(:entries).with('backup-0').and_return(['.', '..', '0-my-db'])
      allow(Dir).to receive(:entries).with('backup-0/0-my-db').and_return(['.', '..', 'a.sql'])

      commands = instance.perform
      expect(commands).to eq ([
        "cat backup-0/0-my-db/a.sql  | ruby -pe '$_=$_.gsub(/``\\./, \"`test_db-abc`.\")' | mysql  --ssl-mode=disabled -h my-host -u test-user   test_db-abc "
      ])
    end
  end

end