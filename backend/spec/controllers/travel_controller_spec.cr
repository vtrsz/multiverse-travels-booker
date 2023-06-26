require "../spec_helper"

struct TravelControllerTest < IntegrationTestCase
  def before_all
    puts "\nTravelController integration tests:"
  end

  test "it should create successfully" do
    travel = {:travel_stops => [1,2,3]}.to_json
    response = self.post("/travel_plans", body: travel)

    self.assert_response_has_status(:created)
    self.assert_response_header_equals("content-type", "application/json")

    created_travel = JSON.parse(response.body)
    created_travel["id"].should eq 1
    created_travel["travel_stops"].should eq JSON.parse(travel)["travel_stops"]
  end

  test "it should return 400 if travel_stops are not an array when creating" do
    travel = {:travel_stops => nil}.to_json
    response = self.post("/travel_plans", body: travel)

    self.assert_response_has_status(:bad_request)
    self.assert_response_header_equals("content-type", "application/json")

    error = JSON.parse(response.body)
    error["message"].should eq "Malformed JSON payload."
  end

  test "it should return 422 if travel_stops has negative numbers when creating" do
    travel = {:travel_stops => [-1,2,3]}.to_json
    response = self.post("/travel_plans", body: travel)

    self.assert_response_has_status(:unprocessable_entity)
    self.assert_response_header_equals("content-type", "application/json")

    error = JSON.parse(response.body)

    error["message"].should eq "Validation failed"
    error["errors"][0]["message"].should eq "A travel_stops values cannot be negative"
  end

  test "it should return 422 if travel_stops values is greater than location size numbers when creating" do
    wrong_location_id = LocationInfo.instance.size + 1
    travel = {:travel_stops => [wrong_location_id,2,3]}.to_json
    response = self.post("/travel_plans", body: travel)

    self.assert_response_has_status(:unprocessable_entity)
    self.assert_response_header_equals("content-type", "application/json")

    error = JSON.parse(response.body)

    error["message"].should eq "Validation failed"
    error["errors"][0]["message"].should eq "A travel_stops values need to be less than or equal #{LocationInfo.instance.size}"
  end

  test "it should return empty list of travels successfully" do
    response = self.get("/travel_plans")

    self.assert_response_has_status(:ok)
    self.assert_response_header_equals("content-type", "application/json")

    travels = JSON.parse(response.body)
    travels.size.should eq 0
  end

  test "it should return all travels successfully" do
    Travel.create(travel_stops: [1,2,3])
    Travel.create(travel_stops: [3,2,1])

    response = self.get("/travel_plans")

    self.assert_response_has_status(:ok)
    self.assert_response_header_equals("content-type", "application/json")

    travels = JSON.parse(response.body)
    travels.size.should eq 2
    travels[0]["id"].should eq 1
    travels[0]["travel_stops"].should eq [1,2,3]
    travels[1]["id"].should eq 2
    travels[1]["travel_stops"].should eq [3,2,1]
  end

  test "it should return all travels optimized successfully" do
    Travel.create(travel_stops: [2,11,19])

    response = self.get("/travel_plans?optimize=true")

    self.assert_response_has_status(:ok)
    self.assert_response_header_equals("content-type", "application/json")

    travels = JSON.parse(response.body)

    travels.size.should eq 1
    travels[0]["id"].should eq 1
    travels[0]["travel_stops"].should eq [19,2,11]
  end

  test "it should return all travels expanded successfully" do
    Travel.create(travel_stops: [1,2,3])

    response = self.get("/travel_plans?expand=true")

    self.assert_response_has_status(:ok)
    self.assert_response_header_equals("content-type", "application/json")
    
    travels = JSON.parse(response.body)

    travels.size.should eq 1
    travels[0]["id"].should eq 1
    travels[0]["travel_stops"][0].size.should eq 4
    travels[0]["travel_stops"][0]["id"].should eq 1
    travels[0]["travel_stops"][0]["name"].should eq "Earth (C-137)"
    travels[0]["travel_stops"][0]["type"].should eq "Planet"
    travels[0]["travel_stops"][0]["dimension"].should eq "Dimension C-137"
  end

  test "it should return all travels optimized and expanded successfully" do
    Travel.create(travel_stops: [2,11,19])

    response = self.get("/travel_plans?optimize=true&expand=true")

    self.assert_response_has_status(:ok)
    self.assert_response_header_equals("content-type", "application/json")
    
    travels = JSON.parse(response.body)

    travels.size.should eq 1
    travels[0]["id"].should eq 1
    travels[0]["travel_stops"][0].size.should eq 4
    travels[0]["travel_stops"][0]["id"].should eq 19
    travels[0]["travel_stops"][0]["name"].should eq "Gromflom Prime"
    travels[0]["travel_stops"][0]["type"].should eq "Planet"
    travels[0]["travel_stops"][0]["dimension"].should eq "Replacement Dimension"
    travels[0]["travel_stops"][1].size.should eq 4
    travels[0]["travel_stops"][1]["id"].should eq 2
    travels[0]["travel_stops"][1]["name"].should eq "Abadango"
    travels[0]["travel_stops"][1]["type"].should eq "Cluster"
    travels[0]["travel_stops"][1]["dimension"].should eq "unknown"
    travels[0]["travel_stops"][2].size.should eq 4
    travels[0]["travel_stops"][2]["id"].should eq 11
    travels[0]["travel_stops"][2]["name"].should eq "Bepis 9"
    travels[0]["travel_stops"][2]["type"].should eq "Planet"
    travels[0]["travel_stops"][2]["dimension"].should eq "unknown"
  end

  test "it should return a travel successfully" do
    Travel.create(travel_stops: [1,2,3])

    response = self.get("/travel_plans/1")

    self.assert_response_has_status(:ok)
    self.assert_response_header_equals("content-type", "application/json")

    travels = JSON.parse(response.body)

    travels["id"].should eq 1
    travels["travel_stops"].should eq [1,2,3]
  end

  test "it should return a travel optimized successfully" do
    Travel.create(travel_stops: [2,11,19])

    response = self.get("/travel_plans/1?optimize=true")

    self.assert_response_has_status(:ok)
    self.assert_response_header_equals("content-type", "application/json")

    travels = JSON.parse(response.body)

    travels["id"].should eq 1
    travels["travel_stops"].should eq [19,2,11]
  end

  test "it should return a travel expanded successfully" do
    Travel.create(travel_stops: [1,2,3])

    response = self.get("/travel_plans/1?expand=true")

    self.assert_response_has_status(:ok)
    self.assert_response_header_equals("content-type", "application/json")
    
    travels = JSON.parse(response.body)

    travels["id"].should eq 1
    travels["travel_stops"][0].size.should eq 4
    travels["travel_stops"][0]["id"].should eq 1
    travels["travel_stops"][0]["name"].should eq "Earth (C-137)"
    travels["travel_stops"][0]["type"].should eq "Planet"
    travels["travel_stops"][0]["dimension"].should eq "Dimension C-137"
  end

  test "it should return a travel optimized and expanded successfully" do
    Travel.create(travel_stops: [2,11,19])

    response = self.get("/travel_plans/1?optimize=true&expand=true")

    self.assert_response_has_status(:ok)
    self.assert_response_header_equals("content-type", "application/json")
    
    travels = JSON.parse(response.body)

    travels["id"].should eq 1
    travels["travel_stops"][0].size.should eq 4
    travels["travel_stops"][0]["id"].should eq 19
    travels["travel_stops"][0]["name"].should eq "Gromflom Prime"
    travels["travel_stops"][0]["type"].should eq "Planet"
    travels["travel_stops"][0]["dimension"].should eq "Replacement Dimension"
    travels["travel_stops"][1].size.should eq 4
    travels["travel_stops"][1]["id"].should eq 2
    travels["travel_stops"][1]["name"].should eq "Abadango"
    travels["travel_stops"][1]["type"].should eq "Cluster"
    travels["travel_stops"][1]["dimension"].should eq "unknown"
    travels["travel_stops"][2].size.should eq 4
    travels["travel_stops"][2]["id"].should eq 11
    travels["travel_stops"][2]["name"].should eq "Bepis 9"
    travels["travel_stops"][2]["type"].should eq "Planet"
    travels["travel_stops"][2]["dimension"].should eq "unknown"
  end

  test "it should return a 404 when get a travel who dont exist" do
    response = self.get("/travel_plans/1")

    self.assert_response_has_status(:not_found)
  end

  test "it should update a travel successfully" do
    Travel.create(travel_stops: [1,2,3])
    travel = {:travel_stops => [4,5,6]}.to_json
    response = self.put("/travel_plans/1", body: travel)

    self.assert_response_has_status(:ok)
    self.assert_response_header_equals("content-type", "application/json")

    updated_travel = JSON.parse(response.body)

    updated_travel["id"].should eq 1
    updated_travel["travel_stops"].should eq JSON.parse(travel)["travel_stops"]
  end

  test "it should return 404 when update a travel who dont exist" do
    travel = {:travel_stops => [4,5,6]}.to_json
    response = self.put("/travel_plans/1", body: travel)

    self.assert_response_has_status(:not_found)
  end

  test "it should return 400 if travel_stops are not an array when updating" do
    travel = {:travel_stops => nil}.to_json
    response = self.put("/travel_plans/1", body: travel)

    self.assert_response_has_status(:bad_request)
    self.assert_response_header_equals("content-type", "application/json")

    error = JSON.parse(response.body)
    error["message"].should eq "Malformed JSON payload."
  end

  test "it should return 422 if travel_stops has negative numbers when updating" do
    travel = {:travel_stops => [-1,2,3]}.to_json
    response = self.put("/travel_plans/1", body: travel)

    self.assert_response_has_status(:unprocessable_entity)
    self.assert_response_header_equals("content-type", "application/json")

    error = JSON.parse(response.body)

    error["message"].should eq "Validation failed"
    error["errors"][0]["message"].should eq "A travel_stops values cannot be negative"
  end

  test "it should return 422 if travel_stops values is greater than location size numbers when updating" do
    wrong_location_id = LocationInfo.instance.size + 1
    travel = {:travel_stops => [wrong_location_id,2,3]}.to_json
    response = self.put("/travel_plans/1", body: travel)

    self.assert_response_has_status(:unprocessable_entity)
    self.assert_response_header_equals("content-type", "application/json")

    error = JSON.parse(response.body)

    error["message"].should eq "Validation failed"
    error["errors"][0]["message"].should eq "A travel_stops values need to be less than or equal #{LocationInfo.instance.size}"
  end

  test "it should delete a travel successfully" do
    Travel.create(travel_stops: [1,2,3])

    response = self.delete("/travel_plans/1")

    self.assert_response_has_status(:no_content)
  end

  test "it should return 404 when delete a travel who dont exist" do
    travel = {:travel_stops => [4,5,6]}.to_json
    response = self.put("/travel_plans/1", body: travel)

    self.assert_response_has_status(:not_found)
  end

  test "it should append a travel successfully" do
    Travel.create(travel_stops: [1,2,3])
    travel = {:travel_stops => [4,5,6]}.to_json
    response = self.post("/travel_plans/1/append", body: travel)

    self.assert_response_has_status(:ok)
    self.assert_response_header_equals("content-type", "application/json")

    updated_travel = JSON.parse(response.body)

    # Convert from Array(Int32) -> String -> JSON::Any -> Array(JSON::Any) to compare the arrays
    travel_stops = JSON.parse([1, 2, 3].to_json).as_a

    updated_travel["id"].should eq 1
    updated_travel["travel_stops"].should eq travel_stops.concat(JSON.parse(travel)["travel_stops"].as_a)
  end

  test "it should return 404 when append a travel who dont exist" do
    travel = {:travel_stops => [4,5,6]}.to_json
    response = self.post("/travel_plans/1/append", body: travel)

    self.assert_response_has_status(:not_found)
  end

  test "it should return 400 if travel_stops are not an array when appending" do
    travel = {:travel_stops => nil}.to_json
    response = self.post("/travel_plans/1/append", body: travel)

    self.assert_response_has_status(:bad_request)
    self.assert_response_header_equals("content-type", "application/json")

    error = JSON.parse(response.body)
    error["message"].should eq "Malformed JSON payload."
  end

  test "it should return 422 if travel_stops has negative numbers when appending" do
    travel = {:travel_stops => [-1,2,3]}.to_json
    response = self.post("/travel_plans/1/append", body: travel)

    self.assert_response_has_status(:unprocessable_entity)
    self.assert_response_header_equals("content-type", "application/json")

    error = JSON.parse(response.body)

    error["message"].should eq "Validation failed"
    error["errors"][0]["message"].should eq "A travel_stops values cannot be negative"
  end

  test "it should return 422 if travel_stops values is greater than location size numbers when appending" do
    wrong_location_id = LocationInfo.instance.size + 1
    travel = {:travel_stops => [wrong_location_id,2,3]}.to_json
    response = self.post("/travel_plans/1/append", body: travel)

    self.assert_response_has_status(:unprocessable_entity)
    self.assert_response_header_equals("content-type", "application/json")

    error = JSON.parse(response.body)

    error["message"].should eq "Validation failed"
    error["errors"][0]["message"].should eq "A travel_stops values need to be less than or equal #{LocationInfo.instance.size}"
  end
end
