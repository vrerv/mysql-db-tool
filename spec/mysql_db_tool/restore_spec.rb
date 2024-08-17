# spec/mysql_db_tool/restore_spec.rb
require 'spec_helper'

require 'mysql_db_tool/config/config_loader'
require 'mysql_db_tool/restore'

RSpec.describe MySQLDBTool::Restore do

  before do

  end

  describe '#perform' do
    let(:options) { { environment: 'test', backup_id: '1', run: false, drop_all_tables: false } }
    let(:instance) { described_class.new(options) }

    it 'restores one db' do
      allow(MySQLDBTool::Config::ConfigLoader).to receive(:load).and_return ({
        db_info: { user: 'test-user', password: '', host: 'my-host', database: ['test_db-abc'] },
        data_tables: [],
        ignore_tables: []
      })
      allow(Dir).to receive(:entries).with('backup-0').and_return(['.', '..', '0-my-db'])
      allow(Dir).to receive(:entries).with('backup-0/0-my-db').and_return(['.', '..', 'a.sql'])

      commands = instance.perform
      expect(commands).to eq ([
        "cat backup-0/0-my-db/a.sql  | ruby -pe '$_=$_.gsub(/``\\./, \"`test_db-abc`.\")' | mysql  --ssl-mode=disabled -h my-host -u test-user   test_db-abc "
      ])
    end
    it 'restores each database' do
      allow(MySQLDBTool::Config::ConfigLoader).to receive(:load).and_return ({
        db_info: { user: 'test-user', password: '', host: 'my-host', database: ['db-1', 'db-2'] },
        data_tables: [],
        ignore_tables: []
      })
      allow(Dir).to receive(:entries).with('backup-0').and_return(['.', '..', '0_db-1', '1_db-2'])
      allow(Dir).to receive(:entries).with('backup-0/0_db-1').and_return(['.', '..', 'a.sql'])
      allow(Dir).to receive(:entries).with('backup-0/1_db-2').and_return(['.', '..', 'b.sql'])

      commands = instance.perform
      puts "commands=#{commands}"
      expect(commands).to eq ([
        "cat backup-0/0_db-1/a.sql  | mysql  --ssl-mode=disabled -h my-host -u test-user   db-1 ",
        "cat backup-0/1_db-2/b.sql  | mysql  --ssl-mode=disabled -h my-host -u test-user   db-2 "
      ])
    end
  end

  describe '#perform with database option' do
    let(:options) { { environment: 'test', backup_id: '1', run: false, drop_all_tables: false, database: ['rdb-1', 'rdb-2'] } }
    let(:instance) { described_class.new(options) }

    it 'restores' do

      allow(MySQLDBTool::Config::ConfigLoader).to receive(:load).and_return ({
        db_info: { user: 'test-user', password: '', host: 'my-host', database: ['db-1', 'db-2'] },
        data_tables: [],
        ignore_tables: []
      })
      allow(Dir).to receive(:entries).with('backup-0').and_return(['.', '..', '0_db-1', '1_db-2'])
      allow(Dir).to receive(:entries).with('backup-0/0_db-1').and_return(['.', '..', 'a.sql'])
      allow(Dir).to receive(:entries).with('backup-0/1_db-2').and_return(['.', '..', 'b.sql'])

      commands = instance.perform
      puts "commands=#{commands}"
      expect(commands).to eq ([
        "cat backup-0/0_db-1/a.sql  | ruby -pe '$_=$_.gsub(/`db-1`\\./, \"`rdb-1`.\").gsub(/`db-2`\\./, \"`rdb-2`.\")' | mysql  --ssl-mode=disabled -h my-host -u test-user   rdb-1 ",
        "cat backup-0/1_db-2/b.sql  | ruby -pe '$_=$_.gsub(/`db-1`\\./, \"`rdb-1`.\").gsub(/`db-2`\\./, \"`rdb-2`.\")' | mysql  --ssl-mode=disabled -h my-host -u test-user   rdb-2 "
      ])
    end
  end

end