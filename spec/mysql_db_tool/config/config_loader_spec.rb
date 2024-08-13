# spec/mysql_backup_restore/config/config_loader_spec.rb
require 'spec_helper'

require 'mysql_db_tool/config/config_loader'

RSpec.describe MySQLDBTool::Config::ConfigLoader do
  describe '.load' do
    context 'when config file exists' do
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return(JSON.dump(
          {
            dbInfo: {
              host: 'localhost',
              user: 'test_user',
              password: 'test_password',
              database: ['test_db'],
              port: 3306
            },
            dataTables: [{ name: 'large_table', where: 'updated_at' }],
            ignoreTables: ['temp_table']
          }))
      end

      it 'returns parsed configuration' do
        config = described_class.load('test')
        expect(config[:db_info]).to eq({
                                         host: 'localhost',
                                         user: 'test_user',
                                         password: 'test_password',
                                         database: ['test_db'],
                                         port: 3306
                                       })
        expect(config[:data_tables]).to eq([{ name: 'large_table', where: 'updated_at' }])
        expect(config[:ignore_tables]).to eq(['temp_table'])
      end
    end

    context 'when config file does not exist' do
      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it 'returns default configuration' do
        config = described_class.load('test')
        expect(config).to eq(described_class::DEFAULT_CONFIG)
      end
    end
  end
end