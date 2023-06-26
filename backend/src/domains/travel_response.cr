struct ExpandedTravelStop
  include JSON::Serializable

  getter id : Int32
  getter name : String
  getter type : String
  getter dimension : String

  def initialize(@id : Int32, @name : String, @type : String, @dimension : String)
  end
end

struct TravelResponse
  include JSON::Serializable

  getter id : Int32

  getter travel_stops : Array(Int32)

  def initialize(@id : Int32, @travel_stops : Array(Int32))
  end
end

struct ExpandedTravelResponse
  include JSON::Serializable

  getter id : Int32

  getter travel_stops : Array(ExpandedTravelStop)

  def initialize(@id : Int32, @travel_stops : Array(ExpandedTravelStop))
  end
end
