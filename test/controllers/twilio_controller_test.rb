require 'test_helper'

class TwilioControllerTest < ActionDispatch::IntegrationTest
  test "should get configure" do
    get twilio_configure_url
    assert_response :success
  end

  test "should get voice" do
    get twilio_voice_url
    assert_response :success
  end

  test "should get voice_fallback" do
    get twilio_voice_fallback_url
    assert_response :success
  end

end
