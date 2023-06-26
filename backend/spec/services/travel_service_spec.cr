require "../spec_helper"

struct TravelServiceTest < ASPEC::TestCase
  def before_all
    puts "\nTravelService unit tests:"
  end

  # Clean the database before each test
  def initialize
    Micrate::DB.exec "TRUNCATE TABLE \"travels\" RESTART IDENTITY;", Micrate::DB.connect
  end

  test "it should create a travel successfully" do
    travel = TravelService.create_travel([1,2,3])

    travel.should be_a TravelResponse
    
    travel.as(TravelResponse).id.should eq 1
    travel.as(TravelResponse).travel_stops.should eq [1,2,3]
  end

  test "it should cannot create a travel" do
    travel = TravelService.create_travel([-1])

    travel.should be_a Nil
    travel.should eq nil
  end

  test "it should process travel successfully" do
    travel = Travel.create(travel_stops: [1,2,3])

    response = TravelService.process_locations(travel.id!, travel.travel_stops, false, false)

    response.should be_a TravelResponse
    response.id.should eq travel.id!
    response.travel_stops.should eq travel.travel_stops
  end

  test "it should process travel optimized successfully" do
    travel = Travel.create(travel_stops: [2,11,19])
    
    response = TravelService.process_locations(travel.id!, travel.travel_stops, true, false)

    response.should be_a TravelResponse

    response.id.should eq travel.id!
    response.travel_stops.should eq [19,2,11]
  end

  test "it should process travel expanded successfully" do
    travel = Travel.create(travel_stops: [1,2,3])
    
    response = TravelService.process_locations(travel.id!, travel.travel_stops, false, true)

    response.should be_a ExpandedTravelResponse
    
    response.travel_stops.first.as(ExpandedTravelStop).id.should eq 1
    response.travel_stops.first.as(ExpandedTravelStop).name.should eq "Earth (C-137)"
    response.travel_stops.first.as(ExpandedTravelStop).type.should eq "Planet"
    response.travel_stops.first.as(ExpandedTravelStop).dimension.should eq "Dimension C-137"
  end

  test "it should process travel optimized and expanded successfully" do
    travel = Travel.create(travel_stops: [2,11,19])
    
    response = TravelService.process_locations(travel.id!, travel.travel_stops, true, true)

    response.should be_a ExpandedTravelResponse

    response.as(ExpandedTravelResponse).travel_stops.[0].id.should eq 19
    response.as(ExpandedTravelResponse).travel_stops.[0].name.should eq "Gromflom Prime"
    response.as(ExpandedTravelResponse).travel_stops.[0].type.should eq "Planet"
    response.as(ExpandedTravelResponse).travel_stops.[0].dimension.should eq "Replacement Dimension"
    response.as(ExpandedTravelResponse).travel_stops.[1].id.should eq 2
    response.as(ExpandedTravelResponse).travel_stops.[1].name.should eq "Abadango"
    response.as(ExpandedTravelResponse).travel_stops.[1].type.should eq "Cluster"
    response.as(ExpandedTravelResponse).travel_stops.[1].dimension.should eq "unknown"
    response.as(ExpandedTravelResponse).travel_stops.[2].id.should eq 11
    response.as(ExpandedTravelResponse).travel_stops.[2].name.should eq "Bepis 9"
    response.as(ExpandedTravelResponse).travel_stops.[2].type.should eq "Planet"
    response.as(ExpandedTravelResponse).travel_stops.[2].dimension.should eq "unknown"
  end

  test "it should cannot procces a travel" do
    response = expect_raises(Exception, "Location ids must be between 1 and #{LocationInfo.instance.size}") do
      TravelService.process_locations(1, [-1, 2, 3], false, false)
    end
  end

  test "it should get travel successfully" do
    travel = Travel.create(travel_stops: [1,2,3])
    
    response = TravelService.get_travel(travel.id!, false, false)

    response.should be_a TravelResponse

    response.as(TravelResponse).id.should eq travel.id!
    response.as(TravelResponse).travel_stops.should eq travel.travel_stops
  end

  test "it should get travel optimized successfully" do
    travel = Travel.create(travel_stops: [2,11,19])
    
    response = TravelService.get_travel(travel.id!, true, false)

    response.should be_a TravelResponse

    response.as(TravelResponse).id.should eq travel.id!
    response.as(TravelResponse).travel_stops.should eq [19,2,11]
  end

  test "it should get travel expanded successfully" do
    travel = Travel.create(travel_stops: [1,2,3])
    
    response = TravelService.get_travel(travel.id!, false, true)

    response.should be_a ExpandedTravelResponse

    response.as(ExpandedTravelResponse).travel_stops.first.id.should eq 1
    response.as(ExpandedTravelResponse).travel_stops.first.name.should eq "Earth (C-137)"
    response.as(ExpandedTravelResponse).travel_stops.first.type.should eq "Planet"
    response.as(ExpandedTravelResponse).travel_stops.first.dimension.should eq "Dimension C-137"
  end

  test "it should get travel optimized and expanded successfully" do
    travel = Travel.create(travel_stops: [2,11,19])
    
    response = TravelService.get_travel(travel.id!, true, true)

    response.should be_a ExpandedTravelResponse
    
    response.as(ExpandedTravelResponse).travel_stops.[0].id.should eq 19
    response.as(ExpandedTravelResponse).travel_stops.[0].name.should eq "Gromflom Prime"
    response.as(ExpandedTravelResponse).travel_stops.[0].type.should eq "Planet"
    response.as(ExpandedTravelResponse).travel_stops.[0].dimension.should eq "Replacement Dimension"
    response.as(ExpandedTravelResponse).travel_stops.[1].id.should eq 2
    response.as(ExpandedTravelResponse).travel_stops.[1].name.should eq "Abadango"
    response.as(ExpandedTravelResponse).travel_stops.[1].type.should eq "Cluster"
    response.as(ExpandedTravelResponse).travel_stops.[1].dimension.should eq "unknown"
    response.as(ExpandedTravelResponse).travel_stops.[2].id.should eq 11
    response.as(ExpandedTravelResponse).travel_stops.[2].name.should eq "Bepis 9"
    response.as(ExpandedTravelResponse).travel_stops.[2].type.should eq "Planet"
    response.as(ExpandedTravelResponse).travel_stops.[2].dimension.should eq "unknown"
  end

  test "it should not get travel" do
    response = TravelService.get_travel(5, false, false)

    response.should be_a Nil
    response.should eq nil
  end

  test "it should not get travel with wrong values" do
    travel = Travel.create(travel_stops: [-1,2,3])

    response = expect_raises(Exception, "Location ids must be between 1 and #{LocationInfo.instance.size}") do
      TravelService.get_travel(1, false, false)
    end
  end

  test "it should get all travels successfully" do
    travel = Travel.create(travel_stops: [1,2,3])
    
    response = TravelService.get_all_travels(false, false)

    response.should be_a Array(TravelResponse)
    response.size.should eq 1
    response.first.id.should eq travel.id!
    response.first.travel_stops.should eq travel.travel_stops
  end

  test "it should get all travels optimized successfully" do
    travel = Travel.create(travel_stops: [2,11,19])
    
    response = TravelService.get_all_travels(true, false)

    response.should be_a Array(TravelResponse)

    response.size.should eq 1
    response.first.id.should eq travel.id!
    response.first.travel_stops.should eq [19,2,11]
  end

  test "it should get all travels expanded successfully" do
    travel = Travel.create(travel_stops: [1,2,3])
    
    response = TravelService.get_all_travels(false, true)


    response.should be_a Array(ExpandedTravelResponse)

    response.size.should eq 1
    response.first.travel_stops.first.as(ExpandedTravelStop).id.should eq 1
    response.first.travel_stops.first.as(ExpandedTravelStop).name.should eq "Earth (C-137)"
    response.first.travel_stops.first.as(ExpandedTravelStop).type.should eq "Planet"
    response.first.travel_stops.first.as(ExpandedTravelStop).dimension.should eq "Dimension C-137"
  end

  test "it should get all travels optimized and expanded successfully" do
    travel = Travel.create(travel_stops: [2,11,19])
    
    response = TravelService.get_all_travels(true, true)

    response.should be_a Array(ExpandedTravelResponse)

    response.first.travel_stops.[0].as(ExpandedTravelStop).id.should eq 19
    response.first.travel_stops.[0].as(ExpandedTravelStop).name.should eq "Gromflom Prime"
    response.first.travel_stops.[0].as(ExpandedTravelStop).type.should eq "Planet"
    response.first.travel_stops.[0].as(ExpandedTravelStop).dimension.should eq "Replacement Dimension"
    response.first.travel_stops.[1].as(ExpandedTravelStop).id.should eq 2
    response.first.travel_stops.[1].as(ExpandedTravelStop).name.should eq "Abadango"
    response.first.travel_stops.[1].as(ExpandedTravelStop).type.should eq "Cluster"
    response.first.travel_stops.[1].as(ExpandedTravelStop).dimension.should eq "unknown"
    response.first.travel_stops.[2].as(ExpandedTravelStop).id.should eq 11
    response.first.travel_stops.[2].as(ExpandedTravelStop).name.should eq "Bepis 9"
    response.first.travel_stops.[2].as(ExpandedTravelStop).type.should eq "Planet"
    response.first.travel_stops.[2].as(ExpandedTravelStop).dimension.should eq "unknown"
  end

  test "it should get empty travels successfully" do
    response = TravelService.get_all_travels(false, false)

    response.should be_a Array(TravelResponse)
    response.size.should eq 0
  end

  test "it should cannot get all travels" do
    travel = Travel.create(travel_stops: [-1,2,3])
    response = expect_raises(Exception, "Location ids must be between 1 and #{LocationInfo.instance.size}") do
      TravelService.get_all_travels(false, false)
    end
  end

  test "it should update a travel successfully" do
    travel = Travel.create(travel_stops: [1,2,3])
    new_travel_stops = [5,6,7]
    response = TravelService.update_travel(travel.id!, new_travel_stops)

    response.should be_a TravelResponse
    response.as(TravelResponse).id.should eq travel.id!
    response.as(TravelResponse).travel_stops.should eq new_travel_stops
  end

  test "it should cannot update a travel" do
    response = TravelService.update_travel(1, [1,2,3])

    response.should be_a Nil
    response.should eq nil
  end

  test "it should cannot update with wrong travel_stops values" do
    travel = Travel.create(travel_stops: [1,2,3])
    
    response = expect_raises(Exception, "travel_stops values must be between 1 and #{LocationInfo.instance.size}") do
      TravelService.update_travel(travel.id!, [-1,2,3])
    end
  end

  test "it should delete a travel successfully" do
    travel = Travel.create(travel_stops: [1,2,3])
    response = TravelService.delete_travel(travel.id!)

    response.should be_a Bool
    response.should eq true
  end

  test "it should cannot delete a travel" do
    response = TravelService.delete_travel(1)

    response.should be_a Nil
    response.should eq nil
  end

  test "it should append a travel successfully" do
    travel = Travel.create(travel_stops: [1,2,3])
    travel_stops = [4,5,6]
    response = TravelService.append_travel(travel.id!, travel_stops)

    response.should be_a TravelResponse
    response.as(TravelResponse).travel_stops.should eq [1,2,3].concat(travel_stops)
  end

  test "it should cannot append a travel" do
    response = TravelService.append_travel(1, [1,2,3])

    response.should be_a Nil
    response.should eq nil
  end

  test "it should cannot append a travel with wrong travel_stops values" do
    travel = Travel.create(travel_stops: [1,2,3])
    
    response = expect_raises(Exception, "travel_stops values must be between 1 and #{LocationInfo.instance.size}") do
      TravelService.update_travel(travel.id!, [-4,5,6])
    end
  end
end
