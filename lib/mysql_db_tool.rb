# Require all necessary files
require_relative 'mysql_db_tool/backup'
require_relative 'mysql_db_tool/restore'
require_relative 'mysql_db_tool/db_backup_base'

# Define the main module
module MySQLDBTool
  class Error < StandardError; end

  # You might want to add methods to easily access your main functionalities
  def self.backup(options = {})
    isRun = options[:run]
    commands = Backup.new(options).perform
    commands.each { |command| run(isRun, command) }
  end

  def self.restore(options = {})
    isRun = options[:run]
    commands = Restore.new(options).perform
    commands.each { |command| run(isRun, command) }
  end

  def self.find_resource(relative_path)
    File.join(File.dirname(__FILE__), 'mysql_db_tool', relative_path)
  end
end

# You might want to include a version file
require_relative 'mysql_db_tool/version'