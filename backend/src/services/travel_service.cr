class TravelService
  def self.create_travel(stops : Array(Int32)) : TravelResponse | Bool | Nil
    # If stops has wrong values, return false
    if stops.reject(1..LocationInfo.instance.size).size > 0
      return nil
    end

    begin
      travel = Travel.create!(travel_stops: stops)
    rescue ex : Granite::RecordNotSaved
      return false
    end

    return TravelResponse.new(travel.id!, travel.travel_stops)
  end

  def self.process_locations(id : Int32, locations : Array(Int32), optimize : Bool, expand : Bool) : TravelResponse | ExpandedTravelResponse
    # If locations has wrong values, raise an error
    if locations.reject(1..LocationInfo.instance.size).size > 0
      return raise ("Location ids must be between 1 and #{LocationInfo.instance.size}")
    end

    if !optimize && !expand
      return TravelResponse.new(id, locations)
    end

    # Return travels with optimization
    if optimize && !expand
      locations_from_api = RickAndMortyApi.get_locations(locations)
      sorted_locations = RickAndMortyApi.sort_locations(locations_from_api)

      # Create an array of Int32 by mapping the sorted_locations array
      travel_stops = sorted_locations.map do |location|
        location.id
      end

      return TravelResponse.new(id, travel_stops)
    end

    # Return travels with expansion
    if !optimize && expand
      locations_from_api = RickAndMortyApi.get_locations(locations)

      # Create an array of ExpandedTravelStop by mapping the locations_from_api array
      travel_stops = locations_from_api.map do |location|
        ExpandedTravelStop.new(
          id: location.id,
          name: location.name,
          type: location.type,
          dimension: location.dimension
        )
      end

      return ExpandedTravelResponse.new(id, travel_stops)
    end

    # Return travels with optimization and expansion
    if optimize && expand
      locations_from_api = RickAndMortyApi.get_locations(locations)
      sorted_locations = RickAndMortyApi.sort_locations(locations_from_api)

      # Create an array of ExpandedTravelStop by mapping the locations_from_api array
      travel_stops = sorted_locations.map do |location|
        ExpandedTravelStop.new(
          id: location.id,
          name: location.name,
          type: location.type,
          dimension: location.dimension
        )
      end

      return ExpandedTravelResponse.new(id, travel_stops)
    end

    return TravelResponse.new(0, [0]) # Just to avoid warning
  end

  def self.get_travel(id : Int32, optimize : Bool, expand : Bool) : TravelResponse | ExpandedTravelResponse | Nil
    begin
      travel = Travel.find!(id)
    rescue ex : Granite::Querying::NotFound
      return nil
    end

    return self.process_locations(travel.id!, travel.travel_stops, optimize, expand)
  end

  def self.get_all_travels(optimize : Bool, expand : Bool) : Array(TravelResponse) | Array(ExpandedTravelResponse)
    travels = Travel.all

    # Return empty array if there is no travels
    if travels.size == 0
      return [] of TravelResponse
    end

    # Process all travels
    response_locations = travels.map do |travel|
      self.process_locations(travel.id!, travel.travel_stops, optimize, expand)
    end

    # Return all travels with their correct type
    # (maps Array(TravelResponse | ExpandedTravelResponse) to -> Array(TravelResponse) | Array(ExpandedTravelResponse))
    expand ? return response_locations.map { |travel| travel.as(ExpandedTravelResponse) } : return response_locations.map { |travel| travel.as(TravelResponse) }
  end

  def self.update_travel(id : Int32, travel_stops : Array(Int32)) : TravelResponse | Bool | Nil
    # If travel_stops has wrong values, raise an error
    if travel_stops.reject(1..LocationInfo.instance.size).size > 0
      return raise ("travel_stops values must be between 1 and #{LocationInfo.instance.size}")
    end

    begin
      travel = Travel.find!(id)
    rescue ex : Granite::Querying::NotFound
      # Return nil if travel does not exist
      return nil
    end

    begin
      travel.update!(travel_stops: travel_stops)
    rescue ex : Granite::RecordNotSaved
      # Return false if travel could not be updated
      return false
    end

    return TravelResponse.new(travel.id!, travel.travel_stops)
  end

  def self.append_travel(id : Int32, travel_stops : Array(Int32)) : TravelResponse | Bool | Nil
    # If travel_stops has wrong values, raise an error
    if travel_stops.reject(1..LocationInfo.instance.size).size > 0
      return raise ("travel_stops values must be between 1 and #{LocationInfo.instance.size}")
    end

    begin
      travel = Travel.find!(id)
    rescue ex : Granite::Querying::NotFound
      # Return nil if travel does not exist
      return nil
    end

    travel.travel_stops.concat(travel_stops)

    begin
      travel.save!
    rescue ex : Granite::RecordNotSaved
      # Return nil if travel could not be updated
      return false
    end

    return TravelResponse.new(travel.id!, travel.travel_stops)
  end

  def self.delete_travel(id : Int32) : Bool | Nil
    begin
      travel = Travel.find!(id)
    rescue ex : Granite::Querying::NotFound
      # Return nil if travel does not exist
      return nil
    end

    begin
      travel.destroy!
    rescue ex : Granite::RecordNotDestroyed
      # Return false if travel could not be deleted
      return false
    end

    return true
  end
end
