require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :test => :spec

Rake::Task.tasks.each do |task|
  task.enhance(['bundler:symlink_lockfile'])
end

namespace :bundler do
  desc "Create a symbolic link from Gemfile.lock_for_bundler2 to Gemfile.lock if current bundler version is >= 2.0"
  task :symlink_lockfile do
    require 'bundler'

    # Get the current Bundler version
    current_version = Gem::Version.new(Bundler::VERSION)
    required_version = Gem::Version.new('2.0.0')

    if current_version >= required_version
      lockfile = 'Gemfile.lock'
      new_lockfile = 'Gemfile.lock_for_bundler2'

      if File.exist?(new_lockfile)
        if File.exist?(lockfile) && !File.symlink?(lockfile)
          puts "Backing up existing #{lockfile} to #{lockfile}.backup"
          File.rename(lockfile, "#{lockfile}.backup")
        end

        unless File.exist?(lockfile)
          puts "Creating symbolic link from #{new_lockfile} to #{lockfile}"
          File.symlink(new_lockfile, lockfile)
        end
      else
        puts "#{new_lockfile} does not exist."
      end
    else
      puts "Current Bundler version (#{current_version}) is less than 2.0.0, no changes made."
    end
  end
end