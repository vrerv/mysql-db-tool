require 'date'
require_relative "db_backup_base"
require_relative "config/config_loader"

module MySQLDBTool

  class Backup

    def initialize(options = {})
      @options = options
      tableConfig = MySQLDBTool::Config::ConfigLoader.load(options[:env])
      @data_tables = tableConfig[:data_tables]
      @ignore_tables = tableConfig[:ignore_tables]
      @db_info = tableConfig[:db_info]
    end

    def perform

      verify_tools_exist

      id=@options[:id] || "0"
      isGzip=@options[:gzip]
      limitDays=@options[:limit_days] || 3
      gzipSuffix = @options[:gzip_suffix] || '.gz'

      Array(@db_info[:database]).flat_map.each_with_index do |database, index |

        defaultOptions="--column-statistics=0 #{mysqlDefaultOptions(@db_info, database)}"
        backupDir=backupDirName(id, "#{index}_#{database}")

        commands = []
        if File.exist? backupDir
          puts "[skip - directory exists] #{backupDir}"
          return commands
        end
        commands.push "mkdir -p #{backupDir}"

        backupFile="#{backupDir}/#{DateTime.now.strftime("%Y-%m-%d")}_#{id}"
        whereDate=(Date.today - limitDays).strftime("%Y-%m-%d 00:00:00")
        options=ENV['DUMP_OPTIONS'] || "--single-transaction --skip-lock-tables"

        puts "backupFile=#{backupFile}"

        ignoreTablesOption = @ignore_tables.map { |e| "--ignore-table=#{e.include?('.') ? e : "#{database}.#{e}"}" }.join(' ')

        commands.push gzipCommand("mysqldump --no-data #{ignoreTablesOption} #{defaultOptions}", isGzip, "#{backupFile}-schema.sql", gzipSuffix)

        backupTables = []

        @data_tables.each {|table|
          where = table[:where].empty? ? "" : "--where=\"#{table[:where]} >= '#{whereDate}'\""
          if where.empty?
            backupTables.push(table[:name])
            next
          else
            commands.push(gzipCommand("mysqldump --no-create-info #{options} #{where} #{defaultOptions} #{table[:name]}", isGzip, "#{backupFile}-#{table[:name]}.sql", gzipSuffix))
          end
        }

        commands.push(gzipCommand("mysqldump --no-create-info #{ignoreTablesOption} #{options} #{defaultOptions} #{backupTables.join(' ')}", isGzip, "#{backupFile}-all-other-tables.sql", gzipSuffix))
        commands
      end
    end

    def gzipCommand(command, isGzip, file, gzipSuffix = '.gz')
      "#{command} #{isGzip ? '| gzip ' : ''} > #{file}#{isGzip ? gzipSuffix : ''}"
    end

  end

end
