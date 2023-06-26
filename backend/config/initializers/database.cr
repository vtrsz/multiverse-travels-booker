require "granite"

# Set the database connection string

if !ENV.has_key?("DATABASE_URL")
    ENV["DATABASE_URL"] = "postgres://#{ENV["DB_USER"]}:#{ENV["DB_PASSWORD"]}@#{ENV["DB_HOST"]}:#{ENV["DB_PORT"]}/#{(ENV["ATHENA_ENV"] == "production") ? ENV["DB_NAME"] : "#{ENV["DB_NAME"]}-test"}"
end

Granite::Connections << Granite::Adapter::Pg.new(name: "postgre", url: ENV["DATABASE_URL"])
