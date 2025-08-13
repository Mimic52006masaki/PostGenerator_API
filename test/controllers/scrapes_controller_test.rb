require "test_helper"

class ScrapesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get scrapes_create_url
    assert_response :success
  end
end
