@[ARTA::Route(path: "/location")]
class RickAndMortyController < ATH::Controller
  @[ARTA::Get(path: "/{location_id}/image", requirements: {"id" => ART::Requirement::POSITIVE_INT})]
  def get_location_image(location_id : Int32) : ATH::Response
    if location_id < 1 || location_id > LocationInfo.instance.size
      return raise ATH::Exceptions::UnprocessableEntity.new("Invalid location id, needs to be >= 1 and <= #{LocationInfo.instance.size}")
    end

    # Calls the service layer to get the location image
    image = LocationService.get_image(location_id)
    
    # If no image is found, return a 404
    if image.nil?
      return raise ATH::Exceptions::NotFound.new("No image found for location with id #{location_id}")
    end

    # If an error occurs, return a 500
    if !image
      return ATH::Response.new(status: :internal_server_error, content: {"code" => 500, "message" => "Error while getting image for location with id #{location_id}"}.to_json, headers: HTTP::Headers{"content-type" => "application/json"})
    end

    # Calls the service layer to get the location image
    ATH::Response.new(content: image.to_json, headers: HTTP::Headers{"content-type" => "application/json"})
  end
end
