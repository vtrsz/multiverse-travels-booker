@[ARTA::Route(path: "/travel_plans")]
class TravelController < ATH::Controller
  @[ARTA::Post(path: "")]
  def create_travel(@[ATHR::RequestBody::Extract]
                    travel_request : TravelCreateRequest) : ATH::Response
    # Calls the service to create a new travel
    travel = TravelService.create_travel(travel_request.travel_stops)

    if travel.nil?
      return raise ATH::Exceptions::BadRequest.new("travel_stops values need to be >= 1 <= #{LocationInfo.instance.size}")
    end

    # If the service returns false, it means that the travel could not be created
    if !travel
      return ATH::Response.new(status: :internal_server_error)
    end

    return ATH::Response.new(content: travel.to_json, status: :created, headers: HTTP::Headers{"content-type" => "application/json"})
  end

  @[ARTA::Get(path: "")]
  @[ATHA::QueryParam("optimize")]
  @[ATHA::QueryParam("expand")]
  def get_all_travels(optimize : Bool = false, expand : Bool = false) : ATH::Response
    # Calls the service layer to get all the travels
    ATH::Response.new(content: TravelService.get_all_travels(optimize, expand).to_json, headers: HTTP::Headers{"content-type" => "application/json"})
  end

  @[ARTA::Get(path: "/{id}")]
  @[ATHA::QueryParam("optimize")]
  @[ATHA::QueryParam("expand")]
  def get_travel(id : Int32, optimize : Bool = false, expand : Bool = false) : ATH::Response
    # Calls the service layer to get all the travels
    travel = TravelService.get_travel(id, optimize, expand)

    # If the service returns nil, it means that the travel could not be found
    if travel.nil?
      return ATH::Response.new(status: :not_found)
    end

    ATH::Response.new(content: travel.to_json, headers: HTTP::Headers{"content-type" => "application/json"})
  end

  @[ARTA::Put(path: "/{id}")]
  def update_travel(id : Int32,
                    @[ATHR::RequestBody::Extract]
                    travel_request : TravelCreateRequest) : ATH::Response
    # Calls the service to update a travel
    travel = TravelService.update_travel(id, travel_request.travel_stops)

    # If the service returns nil, it means that the travel could not be found
    if travel.nil?
      # And we return a 404
      return ATH::Response.new(status: :not_found)
    end

    # If the service returns false, it means that the travel could not be updated
    if !travel
      # And we return a 500
      return ATH::Response.new(status: :internal_server_error)
    end

    ATH::Response.new(content: travel.to_json, status: :ok, headers: HTTP::Headers{"content-type" => "application/json"})
  end

  @[ARTA::Post(path: "/{id}/append")]
  def append_travel(id : Int32,
                    @[ATHR::RequestBody::Extract]
                    travel_request : TravelCreateRequest) : ATH::Response
    # Calls the service to append travel_stops to a travel
    travel = TravelService.append_travel(id, travel_request.travel_stops)

    # If the service returns nil, it means that the travel could not be found
    if travel.nil?
      # And we return a 404
      return ATH::Response.new(status: :not_found)
    end

    # If the service returns false, it means that the travel could not be updated
    if !travel
      # And we return a 500
      return ATH::Response.new(status: :internal_server_error)
    end

    return ATH::Response.new(content: travel.to_json, status: :ok, headers: HTTP::Headers{"content-type" => "application/json"})
  end

  @[ARTA::Delete(path: "/{id}")]
  def delete_travel(id : Int32) : ATH::Response
    deleted = TravelService.delete_travel(id)

    if deleted.nil?
      return ATH::Response.new(status: :not_found)
    end

    if !deleted
      return ATH::Response.new(status: :internal_server_error)
    end

    ATH::Response.new(status: :no_content)
  end
end
