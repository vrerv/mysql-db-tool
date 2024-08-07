#!/usr/bin/env ruby

require_relative "db-backup-base"

def split_integer_and_string(input)
  parts = input.split('_', 2)
  integer = parts[0].to_i
  string = parts[1]
  [integer, string]
end

def get_element_or_last(array, index)
  index < array.length ? array[index] : array.last
end

verify_tools_exist

env=ARGV.count > 0 ? ARGV[0] : "local"

if env.downcase.end_with? "prod"
  abort "Aborted. Never restore production DB!"
end

require_relative "config/db-info-#{env}"

id=ARGV.count > 1 ? ARGV[1] : "0"
IS_RUN=ARGV.count > 2 ? ARGV[2].to_s == 'true' : false
IS_DROP_ALL_TABLES=ARGV.count > 3 ? ARGV[3].to_s == 'true' : false

puts "ARGV=#{ARGV}, env=#{env}, id=#{id}, run=#{IS_RUN} IS_DROP_ALL_TABLES=#{IS_DROP_ALL_TABLES}"

backupDir=backupDirName(id)

puts "backupDir=#{backupDir}"
databases = Array(DB_INFO[:database])

databaseMap = {}

Dir.entries(backupDir).reject {|f| File.directory? f}.sort.each do |f|

  index, origin_database = split_integer_and_string(f)
  database = get_element_or_last(databases, index)
  databaseMap["`#{origin_database}`\\."] = "`#{database}`."
end
gsubstring = databaseMap.map { |k,v| ".gsub(/#{k}/, \"#{v}\")" }.join("")

Dir.entries(backupDir).reject {|f| File.directory? f}.sort.each do |f|

  index, origin_database = split_integer_and_string(f)
  database = get_element_or_last(databases, index)

  defaultOptions=mysqlDefaultOptions(database)
  backupDir=backupDirName(id, f)

  run(IS_RUN, "cat drop_all_tables.sql | mysql #{defaultOptions}") if IS_DROP_ALL_TABLES
  run(IS_RUN, "cat drop_all_views.sql | mysql #{defaultOptions}") if IS_DROP_ALL_TABLES

  def restoreEach(file, defaultOptions, gsubstring)
    command = ""
    if file.end_with? ".sql.gz"
      command = "zcat #{file} | ruby -pe '$_=$_#{gsubstring}' | mysql #{defaultOptions}"
    elsif file.end_with? ".sql"
      command = "cat #{file} | ruby -pe '$_=$_#{gsubstring}' | mysql #{defaultOptions}"
    else
      puts "not supported file #{file}"
    end

    run(IS_RUN, command) if not command.empty?
  end

  Dir.entries(backupDir).reject {|f| File.directory? f} .select {|f| f.include?("-schema.sql")} .each {|f|
    restoreEach(backupDir+"/"+f, defaultOptions, gsubstring)
  }
  Dir.entries(backupDir).reject {|f| File.directory? f} .reject {|f| f.include?("-schema.sql")} .each {|f|
    restoreEach(backupDir+"/"+f, defaultOptions, gsubstring)
  }

end

