# Require all necessary files
require_relative 'mysql_db_tool/backup'
require_relative 'mysql_db_tool/restore'
require_relative 'mysql_db_tool/db_backup_base'

# Define the main module
module MySQLDBTool
  class Error < StandardError; end

  # Environment variable description
  ENV_VAR_DESCRIPTION = <<~DESC
    Environment Variables:
      DUMP_OPTIONS - Additional options to pass to the MySQL dump command during the backup process.
                     This can include any options supported by mysqldump, such as --skip-lock-tables.
  DESC

  def self.env_opt(options, opts)
    opts.on("-e", "--env ENVIRONMENT", "Environment (default: local) - key to find the configuration file. e.g.) config-local.json") do |env|
      options[:env] = env
    end
  end

  def self.id_opt(options, opts)
    opts.on("-i", "--backup-id BACKUP_ID", "BACKUP_ID (default: 0)") do |id|
      options[:id] = id
    end
  end

  def self.run_opt(options, opts)
    opts.on("-r", "--run", "Run the backup (default: false) or Just show the commands") do
      options[:run] = true
    end
  end

  def self.database_opt(options, opts)
    opts.on("-d", "--database DATABASE", "Override option for dbInfo.database configuration") do |database|
      options[:database] = database.split(',')
    end
  end

  # You might want to add methods to easily access your main functionalities
  def self.backup(options = {})
    commands = Backup.new(options).perform
    commands.each { |command| run(options[:run], command) }
  end

  def self.restore(options = {})
    commands = Restore.new(options).perform
    commands.each { |command| run(options[:run], command) }
  end

  def self.find_resource(relative_path)
    File.join(File.dirname(__FILE__), 'mysql_db_tool', relative_path)
  end
end

# You might want to include a version file
require_relative 'mysql_db_tool/version'