require "test_helper"

class Api::V1::MetarReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get api_v1_metar_reports_create_url
    assert_response :success
  end
end
