class TwilioController < ApplicationController
  # 音声を流します
  def voice
    # return head 400
    twiml = Twilio::TwiML::Response.new do |r|
      r.Say 'Success'
    end
    render xml: twiml.text
  end

  # ENV['DIAL_PHONE_NUMBER']に電話します
  def call
    twiml = Twilio::TwiML::Response.new do |r|
      r.Dial ENV['DIAL_PHONE_NUMBER'], callerId: ENV['TWILIO_PHONE_NUMBER']
    end
    render xml: twiml.text
  end

  # voice_urlへのリクエストに失敗した時のコールバックです
  def voice_fallback
    twiml = Twilio::TwiML::Response.new do |r|
      r.Say 'Failed'
    end
    render xml: twiml.text
  end
end
