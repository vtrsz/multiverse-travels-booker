struct Episode
  include JSON::Serializable

  getter id : Int32

  def initialize(@id : Int32)
  end
end

struct Resident
  include JSON::Serializable

  getter episode : Array(Episode)

  def initialize(@episode : Array(Episode))
  end
end

struct Location
  include JSON::Serializable

  getter id : Int32
  getter name : String
  getter type : String
  getter dimension : String
  getter residents : Array(Resident)

  def initialize(@id : Int32, @name : String, @type : String, @dimension : String, @residents : Array(Resident))
  end
end

# Singleton class to get the size of the locations
struct LocationInfo
  getter size : Int32

  private def initialize
    @size = RickAndMortyApi.get_locations_size()
  end

  def self.instance
    @@instance ||= new
  end
end
