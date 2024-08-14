
require_relative "lib/mysql_db_tool/version"

Gem::Specification.new do |spec|
  spec.name          = "mysql_db_tool"
  spec.version       = MySQLDBTool::VERSION
  spec.authors       = ["Soonoh Jung"]
  spec.email         = ["soonoh.jung@vrerv.com"]

  spec.summary       = "MySQL DB Tool"
  spec.description   = "A Ruby gem for backing up and restoring MySQL databases"
  spec.homepage      = "https://github.com/vrerv/mysql-db-tool"
  spec.license       = "MIT"

  spec.files         = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  spec.bindir        = "bin"
  spec.executables   = ["mysql_backup", "mysql_restore", "gen_create_db_user"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.6"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end