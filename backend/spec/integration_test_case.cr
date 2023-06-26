abstract struct IntegrationTestCase < ATH::Spec::APITestCase
  def initialize
    super

    # Reset the database before each test
    Micrate::DB.exec "TRUNCATE TABLE \"travels\" RESTART IDENTITY;", Micrate::DB.connect
  end
end
