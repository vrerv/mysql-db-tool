

def run(isRun, command)
  if not isRun
    puts "[dryRun] #{command}"
  else
    puts command
    puts `#{command}`
  end
end

def backupDirName(id, dbName = "")
  "backup-#{id}#{dbName.empty? ? '' : "/#{dbName}"}"
end

def mysqlDefaultOptions(database)
  " --ssl-mode=disabled -h #{DB_INFO[:hostname]} -u #{DB_INFO[:user]} #{DB_INFO[:password].to_s.empty? ? '' : " -p'#{DB_INFO[:password]}'"} #{database} "
end

def verify_tools_exist
  tools = ["mysql", "mysqldump", "pv", "gzip", "zcat"]
  missing_tools = []

  tools.each do |tool|
    if not system("which #{tool} > /dev/null 2>&1")
      missing_tools << tool
      puts "'#{tool}' is not available"
    end
  end

  if missing_tools.empty?
    puts "All required tools are available."
  else
    puts "Missing tools: #{missing_tools.join(', ')}"
    puts "Please install the missing tools."
    exit 1
  end
end
