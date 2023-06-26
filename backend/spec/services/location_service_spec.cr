require "../spec_helper"

struct LocationServiceTest < ASPEC::TestCase
  def before_all
    puts "\nLocationService unit tests:"
  end

  test "it should get a image successfully" do
    image = LocationService.get_image(1)

    image.should be_a Hash(String, String)

    image.as(Hash(String, String))["url"].should eq "https://static.wikia.nocookie.net/rickandmorty/images/f/fc/S2e5_Earth.png/revision/latest"
  end

  test "it should cannot get a image in rickandmortyapi" do
    image = LocationService.get_image(999)

    image.should be_a Bool
    image.should eq false
  end

  test "it should cannot locate in rickandmorty wiki the location" do
    image = LocationService.get_image(4)

    image.should be_a Nil
    image.should eq nil
  end
end
