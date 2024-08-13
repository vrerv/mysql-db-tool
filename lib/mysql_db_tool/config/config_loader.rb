require 'json'

module MySQLDBTool
  module Config
    class ConfigLoader
      DEFAULT_CONFIG = {
        db_info: {
          host: "localhost",
          user: "root",
          password: "",
          database: ["mysql"],
          port: 3306
        },
        data_tables: [
          # { name: "large_table1", where: "updated_at" }
        ],
        ignore_tables: [
        ]
      }

      def self.load(environment)
        file_path = File.join(Dir.pwd, "config-#{environment}.json")
        if File.exist?(file_path)
          file_contents = File.read(file_path)
          json_data = JSON.parse(file_contents)
          {
            db_info: symbolize_keys(json_data['dbInfo']),
            data_tables: json_data['dataTables'].map { |table| symbolize_keys(table) },
            ignore_tables: json_data['ignoreTables']
          }
        else
          puts "Warning: config-#{environment}.json not found in the current directory. Using default configuration."
          DEFAULT_CONFIG
        end
      rescue JSON::ParserError => e
        puts "Error parsing config-#{environment}.json: #{e.message}. Using default configuration."
        DEFAULT_CONFIG
      end

      private

      def self.symbolize_keys(hash)
        hash.transform_keys(&:to_sym)
      end
    end
  end
end
