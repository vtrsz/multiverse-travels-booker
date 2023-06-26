class RickAndMortyApi
  def self.get_locations_size()
    # GraphQL query to get locations size
    query = <<-GRAPHQL
      query {
        locations {
          info {
            count
          }
        }
      }
    GRAPHQL

    # Send query to Rick And Morty GraphQL API
    response = HTTP::Client.post("https://rickandmortyapi.com/graphql", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: {"query" => query}.to_json)

    # Raise error if response status code is not 200
    if response.status_code != 200
      return raise "Error: [RickAndMortyApi] response: HTTP #{response.status_code} - #{response.body}"
    end

    return JSON.parse(response.body).["data"].["locations"].["info"].["count"].as_i
  end

  def self.get_location_name(id : Int32) : String
    # GraphQL query to get locations name
    query = <<-GRAPHQL
      query {
        location(id: #{id.to_s}) {
          name
        }
      }
    GRAPHQL

    # Send query to Rick And Morty GraphQL API
    response = HTTP::Client.post("https://rickandmortyapi.com/graphql", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: {"query" => query}.to_json)

    # Raise error if response status code is not 200
    if response.status_code != 200
      return raise "Error: [RickAndMortyApi] response: HTTP #{response.status_code} - #{response.body}"
    end

    # Raise error if location with id not found
    if JSON.parse(response.body).["data"].["location"] == nil
      return raise "Error: [RickAndMortyApi] response: location with id #{id.to_s} not found"
    end

    # Parse response body to get location name
    name = JSON.parse(response.body).["data"].["location"].["name"].as_s

    return name
  end

  def self.get_locations(locations : Array(Int32)) : Array(Location)
    # GraphQL query to get locations with residents and episodes they've appeared in
    query = <<-GRAPHQL
      query {
        locationsByIds(ids: #{locations.to_s}) {
          id,
          name,
          type,
          dimension,
          residents {
            episode {
              id
            }
          }
        }
      }
    GRAPHQL

    # Send query to Rick And Morty GraphQL API
    response = HTTP::Client.post("https://rickandmortyapi.com/graphql", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: {"query" => query}.to_json)

    # Raise error if response status code is not 200
    if response.status_code != 200
      return raise "Error: [RickAndMortyApi] response: HTTP #{response.status_code} - #{response.body}"
    end

    # Raise error if location with id not found
    if JSON.parse(response.body).["data"].["locationsByIds"].size != locations.size
      return raise "Error: [RickAndMortyApi] response: one of locations #{locations.to_s} was not found"
    end

    # Parse response body to get array of locations (JSON::Any)
    locations_from_api = JSON.parse(response.body).["data"].["locationsByIds"].as_a

    # Convert locations_from_api from JSON::Any to Location objects
    locations = locations_from_api.map do |location|
      residents = location["residents"].as_a.map do |resident|
        episodes = resident["episode"].as_a.map do |episode|
          Episode.new(episode["id"].as_s.to_i)
        end
        Resident.new(episodes)
      end
      Location.new(location["id"].as_s.to_i, location["name"].as_s, location["type"].as_s, location["dimension"].as_s, residents)
    end

    return locations
  end

  # Sort locations by size, popularity (number of characters residing and how many episodes they've appeared in), and name
  def self.sort_locations(locations : Array(Location)) : Array(Location)
    # Sort locations
    sorted_locations = locations.sort do |a, b|
      # 1nd - Sort by dimension
      if a.dimension != b.dimension
        a.dimension <=> b.dimension
      else
        # Get popularity of each location (popularity = number of characters residing and how many episodes they've appeared in)
        a_popularity = a.residents.size + a.residents.flat_map { |resident| resident.episode }.size
        b_popularity = b.residents.size + b.residents.flat_map { |resident| resident.episode }.size

        # 2nd - Sort by popularity
        if a_popularity != b_popularity
          a_popularity <=> b_popularity
        else
          # 3nd - Sort by name
          a.name <=> b.name
        end
      end
    end

    return sorted_locations
  end
end
