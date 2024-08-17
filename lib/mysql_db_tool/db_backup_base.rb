

def run(is_run, command)
  if not is_run
    puts "[dryRun] #{command}"
  else
    puts "Running: [#{command}]"
    puts `#{command}`
  end
end

def backup_dir_name(id, db_name = "")
  "backup-#{id}#{db_name.empty? ? '' : "/#{db_name}"}"
end

def mysql_default_options(db_info, database)
  " --ssl-mode=disabled -h #{db_info[:host]} -u #{db_info[:user]} #{db_info[:password].to_s.empty? ? '' : " -p'#{db_info[:password]}'"} #{db_info[:port].to_s.empty? ? '' : " -P'#{db_info[:port]}'"} #{database} "
end

def verify_tools_exist
  tools = ["mysql", "mysqldump", "gzip", "zcat"]
  missing_tools = []

  tools.each do |tool|
    unless system("which #{tool} > /dev/null 2>&1")
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
