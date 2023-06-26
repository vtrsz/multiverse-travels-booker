require "../spec_helper"

struct RickAndMortyApiTest < ASPEC::TestCase
  def before_all
    puts "\nRickAndMortyApi unit tests:"
  end

  test "it should get location quantity" do
    response = RickAndMortyApi.get_locations_size

    response.should be_a Int32
    response.should be > 0
  end

  test "it should get location name" do
    response = RickAndMortyApi.get_location_name(1)

    response.should be_a String
    response.should eq "Earth (C-137)"
  end

  test "it should cannot get location name" do
    wrong_id = -1
    response = expect_raises(Exception, "Error: [RickAndMortyApi] response: location with id #{wrong_id.to_s} not found") do
      RickAndMortyApi.get_location_name(wrong_id)
    end
  end

  test "it should get locations" do
    locations = [1, 2, 3]
    response = RickAndMortyApi.get_locations(locations)

    response.should be_a Array(Location)
    response.first.id.should eq locations[0]
    response.first.name.should eq "Earth (C-137)"
    response.first.type.should eq "Planet"
    response.first.dimension.should eq "Dimension C-137"
    response.first.residents.should be_a Array(Resident)
  end

  test "it should cannot get locations" do
    locations = [-1, 2, 3]

    response = expect_raises(Exception, "Error: [RickAndMortyApi] response: one of locations #{locations.to_s} was not found") do
      RickAndMortyApi.get_locations(locations)
    end
  end

  test "it should sort locations successfully" do
    # non sorted: [2,11,19]
    locations = [
      Location.new(2, "Abadango", "Cluster", "unknown", [Resident.new([Episode.new(27)])]),
      Location.new(11, "Bepis 9", "Planet", "unknown", [Resident.new([Episode.new(1),
                                                                      Episode.new(11),
                                                                      Episode.new(19),
                                                                      Episode.new(25)
      ])]),
      Location.new(19, "Gromflom Prime", "Planet", "Replacement Dimension", [] of Resident),
    ]

    response = RickAndMortyApi.sort_locations(locations)
    response.should be_a Array(Location)

    # sorted should be: [19,2,11]
    response.[0].id.should eq 19
    response.[1].id.should eq 2
    response.[2].id.should eq 11
  end
end
