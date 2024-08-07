#!/usr/bin/env ruby

require 'date'
require_relative "db-backup-base"

verify_tools_exist

env=ARGV.count > 0 ? ARGV[0] : "local"

require_relative "config/db-info-#{env}"
require_relative "config/data-tables"
require_relative "config/ignore-tables"

id=ARGV.count > 1 ? ARGV[1] : "0"
isRun=ARGV.count > 2 ? ARGV[2].to_s == 'true' : false
isGzip=ARGV.count > 3 ? ARGV[3].to_s == 'true' : true
limitDays=3

puts "ARGV=#{ARGV}, env=#{env}, id=#{id}, run=#{isRun}"


Array(DB_INFO[:database]).each_with_index do |database, index |

  defaultOptions="--column-statistics=0 #{mysqlDefaultOptions(database)}"
  backupDir=backupDirName(id, "#{index}_#{database}")

  run(isRun, "mkdir -p #{backupDir}")

  backupFile="#{backupDir}/" + DateTime.now.strftime("%Y-%m-%d") + "_#{id}"
  whereDate=(Date.today - limitDays).strftime("%Y-%m-%d 00:00:00")
  options=ENV['DUMP_OPTIONS'] || "--single-transaction --skip-lock-tables"

  puts "backupFile=#{backupFile}"

  ignoreTablesOption = IGNORE_TABLES.map { |e| "--ignore-table=#{DB_INFO[:database]}.#{e}"  }.join(' ')

  commands = [
    {:command => "mysqldump --no-data #{ignoreTablesOption} #{defaultOptions}", :file => "#{backupFile}-schema.sql"}
  ]

  backupTables = []

  DATA_TABLES.each {|table|
    where = table[:where].empty? ? "" : "--where=\"#{table[:where]} >= '#{whereDate}'\""
    if where.empty?
      backupTables.push(table[:name])
      next
    else
      commands.push({
                      :command => "mysqldump --no-create-info #{options} #{where} #{defaultOptions} #{table[:name]}",
                      :file => "#{backupFile}-#{table[:name]}.sql"
                    })
    end
  }

  commands.push({
                  :command => "mysqldump --no-create-info #{options} #{defaultOptions} #{backupTables.join(' ')}",
                  :file => "#{backupFile}-all-other-tables.sql"
                })

  commands.each { |command|
    file = isGzip ? "#{command[:file]}.gz" : command[:file]
    #puts "file=#{file}"
    if File.exist? file
      puts "[skip - file exists] #{command[:command]}"
      next
    end

    run(isRun, "#{command[:command]} | pv #{isGzip ? '| gzip ' : ''} > #{file}")
  }
end