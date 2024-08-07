#!/usr/bin/env ruby

user=ARGV.count > 0 ? ARGV[0] : "db_user"
password=ARGV.count > 1 ? ARGV[1] : "db_user_password"
db=ARGV.count > 2 ? ARGV[2] : "db_name"
host=ARGV.count > 3 ? ARGV[3] : "localhost"

replace_map = {
  "DB_USER" => user,
  "DB_PASSWORD" => password,
  "DB_NAME" => db,
  "DB_HOST" => host
}

puts `cat ./create_db_user_template.sql | ruby -pe '$_=$_#{replace_map.map { |k,v| ".gsub(/#{k}/, \"#{v}\")" }.join("")}' `
