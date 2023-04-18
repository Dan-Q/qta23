require "test_helper"

class MainControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get main_index_url
    assert_response :success
  end

  test "should get login" do
    get main_login_url
    assert_response :success
  end

  test "should get rsvp" do
    get main_rsvp_url
    assert_response :success
  end

  test "should get rsvp_submit" do
    get main_rsvp_submit_url
    assert_response :success
  end
end
