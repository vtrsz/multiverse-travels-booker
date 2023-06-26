require "../spec_helper"

struct LocationControllerTest < IntegrationTestCase
  def before_all
    puts "\nLocationController integration tests:"
  end

  test "it should returns successfully" do
    response = self.get("/location/1/image")

    self.assert_response_is_successful
  end

  test "it should returns 404 when a image is not found" do
    response = self.get("/location/4/image")

    self.assert_response_has_status(:not_found)
  end

  test "it should returns 422 - unprocessable entity" do
    response = self.get("/location/-1/image")

    self.assert_response_has_status(:unprocessable_entity)
    response.body.should eq({:code => 422, :message => "Invalid location id, needs to be >= 1 and <= #{LocationInfo.instance.size}"}.to_json)
  end

  test "it should returns 400 - bad request" do
    wrong_location_id = "test"
    response = self.get("/location/#{wrong_location_id}/image")

    self.assert_response_has_status(:bad_request)
    response.body.should eq({:code => 400, :message => "Parameter 'location_id' with value '#{wrong_location_id}' could not be converted into a valid 'Int32'."}.to_json)
  end
end
