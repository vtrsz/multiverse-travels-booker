# Set the environment to production
ENV["ATHENA_ENV"] = "production"

require "./app"

# Run the server
ATH.run(ENV["BACKEND_PORT"].to_i || 3000, ENV["BACKEND_IP"] || "0.0.0.0")