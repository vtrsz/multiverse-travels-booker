ENV["ATHENA_ENV"] = "test"

# Load the environment variables.
require "dotenv"
Dotenv.load(path: "../.env")

require "spec"
require "micrate"
require "pg"

# Set up the database URL.
ENV["DATABASE_URL"] = "postgres://#{ENV["DB_USER"]}:#{ENV["DB_PASSWORD"]}@#{ENV["DB_HOST"]}:#{ENV["DB_PORT"]}/#{ENV["DB_NAME"]}-test"

# Run migrations.
Spec.before_suite do
  Micrate::DB.connection_url = ENV["DATABASE_URL"]

  Micrate::Cli.run_up
end

#Clear the database after the tests.
Spec.after_suite do
  Micrate::DB.exec "TRUNCATE TABLE \"travels\" RESTART IDENTITY;", Micrate::DB.connect
end

# Load the application.
require "../src/app"
# Load athena spec helpers.
require "athena/spec"

# Load the integration test case.
require "./integration_test_case"


# Runs all specs in the current directory.
ASPEC.run_all
