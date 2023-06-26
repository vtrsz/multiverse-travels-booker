ARG CRYSTAL_IMAGE_VERSION

FROM crystallang/crystal:${CRYSTAL_IMAGE_VERSION}

# Set the working directory
WORKDIR /backend

# Install cmake & c compiler (dependencies of lexbor)
RUN apt-get update && apt-get install -y cmake && apt-get install -y build-essential

# Copy shard.yml to the working directory
COPY shard.yml ./

# Install dependencies
RUN shards install

# Copy the application source code to the working directory
COPY . .

COPY bin/micrate ./bin/micrate

# Build the application
RUN crystal build src/server.cr --release
