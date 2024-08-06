#!/usr/bin/env ruby

require_relative "db-backup-base"

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

DEFAULT_OPTIONS=mysqlDefaultOptions()
backupDir=backupDirName(id)

run(IS_RUN, "cat drop_all_tables.sql | mysql #{DEFAULT_OPTIONS}") if IS_DROP_ALL_TABLES

def restoreEach(file)
  command = ""
  if file.end_with? ".sql.gz"
    command = "zcat #{file} | mysql #{DEFAULT_OPTIONS}"
  elsif file.end_with? ".sql"
    command = "cat #{file} | mysql #{DEFAULT_OPTIONS}"
  else
    puts "not supported file #{file}"
  end

  run(IS_RUN, command) if not command.empty?
end

Dir.entries(backupDir).reject {|f| File.directory? f} .select {|f| f.include?("-schema.sql")} .each {|f|
  restoreEach(backupDir+"/"+f)
}
Dir.entries(backupDir).reject {|f| File.directory? f} .reject {|f| f.include?("-schema.sql")} .each {|f|
  restoreEach(backupDir+"/"+f)
}
