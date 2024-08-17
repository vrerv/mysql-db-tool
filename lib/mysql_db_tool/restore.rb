require_relative "db_backup_base"

module MySQLDBTool

  class Restore

    def initialize(options = {})
      @options = options
      tableConfig = MySQLDBTool::Config::ConfigLoader.load(options[:env])
      @data_tables = tableConfig[:data_tables]
      @ignore_tables = tableConfig[:ignore_tables]
      @db_info = tableConfig[:db_info]
    end

    def perform

      verify_tools_exist

      env=@options[:env] || "local"

      if env.downcase.end_with? "prod"
        abort "Aborted. Never restore production DB!"
      end

      id=@options[:id] || "0"
      isRun=@options[:run]
      isDropAllTables=@options[:drop_all_tables]

      puts "ARGV=#{ARGV}, env=#{env}, id=#{id}, run=#{isRun} isDropAllTables=#{isDropAllTables}"

      backupDir=backupDirName(id)

      puts "backupDir=#{backupDir}"
      databases = Array(@db_info[:database])

      databaseMap = {}
      sameDb = true

      Dir.entries(backupDir).reject {|f| File.directory? f}.sort.each do |f|

        index, origin_database = split_integer_and_string(f)
        database = get_element_or_last(databases, index)
        sameDb = sameDb && (database == origin_database)
        databaseMap["`#{origin_database}`\\."] = "`#{database}`."
      end

      gsubstring = sameDb ? "" : databaseMap.map { |k,v| ".gsub(/#{k}/, \"#{v}\")" }.join("")

      Dir.entries(backupDir).reject {|f| File.directory? f}.sort.flat_map do |f|

        commands = []

        index, origin_database = split_integer_and_string(f)
        database = get_element_or_last(databases, index)

        defaultOptions=mysqlDefaultOptions(@db_info, database)
        backupDir=backupDirName(id, f)

        commands.push("cat #{MySQLDBTool.find_resource('sql/drop_all_tables.sql')} | mysql #{defaultOptions}") if isDropAllTables
        commands.push("cat #{MySQLDBTool.find_resource('sql/drop_all_views.sql')} | mysql #{defaultOptions}") if isDropAllTables

        Dir.entries(backupDir).reject {|f| File.directory? f} .select {|f| f.include?("-schema.sql")} .each {|f|
          restore_each(commands, backupDir+"/"+f, defaultOptions, gsubstring)
        }
        Dir.entries(backupDir).reject {|f| File.directory? f} .reject {|f| f.include?("-schema.sql")} .each {|f|
          restore_each(commands, backupDir+"/"+f, defaultOptions, gsubstring)
        }
        commands
      end
    end

    private

    def restore_each(commands, file, defaultOptions, gsubstring)
      command = ""
      replacing = " | ruby -pe '$_=$_#{gsubstring}'" unless gsubstring.empty?
      if file.end_with? ".sql"
        command = "cat #{file} #{replacing} | mysql #{defaultOptions}"
      elsif gzip_file?(file)
        command = "zcat #{file} #{replacing} | mysql #{defaultOptions}"
      else
        puts "not supported file #{file}"
      end

      commands.push(command) if not command.empty?
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

