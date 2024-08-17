require_relative "db_backup_base"

module MySQLDBTool

  class Restore

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

      env=@options[:env] || "local"

      if env.downcase.end_with? "prod"
        abort "Aborted. Never restore production DB!"
      end

      id=@options[:id] || "0"
      is_drop_all_tables=@options[:drop_all_tables]

      backup_dir=backup_dir_name(id)

      puts "backupDir=#{backup_dir}"
      databases = Array(@db_info[:database])

      database_map = {}
      same_db = true

      Dir.entries(backup_dir).reject {|f| File.directory? f}.sort.each do |f|

        index, origin_database = split_integer_and_string(f)
        database = get_element_or_last(databases, index)
        same_db = same_db && (database == origin_database)
        database_map["`#{origin_database}`\\."] = "`#{database}`."
      end

      replace_db_names_command = same_db ? "" : database_map.map { |k,v| ".gsub(/#{k}/, \"#{v}\")" }.join("")

      Dir.entries(backup_dir).reject {|f| File.directory? f}.sort.flat_map do |f|

        commands = []

        index, origin_database = split_integer_and_string(f)
        database = get_element_or_last(databases, index)

        default_options=mysql_default_options(@db_info, database)
        backup_dir=backup_dir_name(id, f)

        commands.push("cat #{MySQLDBTool.find_resource('sql/drop_all_tables.sql')} | mysql #{default_options}") if is_drop_all_tables
        commands.push("cat #{MySQLDBTool.find_resource('sql/drop_all_views.sql')} | mysql #{default_options}") if is_drop_all_tables

        Dir.entries(backup_dir).reject {|f| File.directory? f}.select {|f| f.include?("-schema.sql")}.each {|f|
          restore_each(commands, backup_dir+"/"+f, default_options, replace_db_names_command)
        }
        Dir.entries(backup_dir).reject {|f| File.directory? f}.reject {|f| f.include?("-schema.sql")}.each {|f|
          restore_each(commands, backup_dir+"/"+f, default_options, replace_db_names_command)
        }
        commands
      end
    end

    private

    def restore_each(commands, file, default_options, replace_db_names_command)
      command = ""
      replacing = " | ruby -pe '$_=$_#{replace_db_names_command}'" unless replace_db_names_command.empty?
      if file.end_with? ".sql"
        command = "cat #{file} #{replacing} | mysql #{default_options}"
      elsif gzip_file?(file)
        command = "zcat #{file} #{replacing} | mysql #{default_options}"
      else
        puts "not supported file #{file}"
      end

      commands.push(command) unless command.empty?
    end

    def split_integer_and_string(input)
      parts = input.split('_', 2)
      integer = parts[0].to_i
      string = parts[1]
      [integer, string]
    end

    def get_element_or_last(array, index)
      index < array.length ? array[index] : array.last
    end

    def gzip_file?(file_path)
      magic_number = "\x1F\x8B".force_encoding('ASCII-8BIT')

      File.open(file_path, "rb") do |file|
        file.read(2) == magic_number
      end
    end

  end
end

