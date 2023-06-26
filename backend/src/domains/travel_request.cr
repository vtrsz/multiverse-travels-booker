LOCATIONS_SIZE = LocationInfo.instance.size

struct TravelCreateRequest
    include AVD::Validatable
    include JSON::Serializable

    @[Assert::Size(range: 1.., min_message: "A travel_stops values cannot be empty")]
    @[Assert::All([
        @[Assert::Positive(message: "A travel_stops values cannot be negative")],
        @[Assert::NotNil(message: "A travel_stops values cannot be nil")],
        @[Assert::LessThanOrEqual(LOCATIONS_SIZE, message: "A travel_stops values need to be less than or equal #{LOCATIONS_SIZE}")]
    ])]
    getter travel_stops : Array(Int32)
end
