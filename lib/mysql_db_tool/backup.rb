require 'date'
require_relative "db_backup_base"
require_relative "config/config_loader"

module MySQLDBTool

  class Backup

    def initialize(options = {})
      @options = options
      config = MySQLDBTool::Config::ConfigLoader.load(options[:env])
      @data_tables = config[:data_tables]
      @ignore_tables = config[:ignore_tables]
      @db_info = config[:db_info]

      @db_info[:database] = @options[:database] if @options[:database]
    end

    def perform

      verify_tools_exist

      id=@options[:id] || "0"
      use_gzip=@options[:gzip]
      limit_days=@options[:limit_days] || 3
      gzip_suffix = @options[:gzip_suffix] || '.gz'

      Array(@db_info[:database]).flat_map.each_with_index do |database, index |

        default_options="--column-statistics=0 #{mysql_default_options(@db_info, database)}"
        backup_dir=backup_dir_name(id, "#{index}_#{database}")

        commands = []
        if File.exist? backup_dir
          puts "[skip - directory exists] #{backup_dir}"
          return commands
        end
        commands.push "mkdir -p #{backup_dir}"

        backup_file="#{backup_dir}/#{DateTime.now.strftime("%Y-%m-%d")}_#{id}"
        where_date=(Date.today - limit_days).strftime("%Y-%m-%d 00:00:00")
        options=ENV['DUMP_OPTIONS'] || "--single-transaction --skip-lock-tables"

        puts "backupFile=#{backup_file}"

        ignore_tables_option = @ignore_tables.map { |e| "--ignore-table=#{e.include?('.') ? e : "#{database}.#{e}"}" }.join(' ')

        commands.push gzip_command("mysqldump --no-data #{ignore_tables_option} #{default_options}", use_gzip, "#{backup_file}-schema.sql", gzip_suffix)

        backup_tables = []

        @data_tables.each {|table|
          where = table[:where].empty? ? "" : "--where=\"#{table[:where]} >= '#{where_date}'\""
          if where.empty?
            backup_tables.push(table[:name])
            next
          else
            commands.push(gzip_command("mysqldump --no-create-info #{options} #{where} #{default_options} #{table[:name]}", use_gzip, "#{backup_file}-#{table[:name]}.sql", gzip_suffix))
          end
        }

        commands.push(gzip_command("mysqldump --no-create-info #{ignore_tables_option} #{options} #{default_options} #{backup_tables.join(' ')}", use_gzip, "#{backup_file}-all-other-tables.sql", gzip_suffix))
        commands
      end
    end

    def gzip_command(command, use_gzip, file, gzip_suffix = '.gz')
      "#{command} #{use_gzip ? '| gzip ' : ''} > #{file}#{use_gzip ? gzip_suffix : ''}"
    end

  end

end
