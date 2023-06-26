@[ADI::Register]
class ResponseListener
  include AED::EventListenerInterface

  @[AEDA::AsEventListener]
  def on_response(event : ATH::Events::Response) : Nil
    # If the response is JSON, remove the charset from the content-type header
    if event.response.headers.has_key?("content-type") && event.response.headers["content-type"] == "application/json; charset=UTF-8"
      event.response.headers["content-type"] = "application/json"
    end
  end
end