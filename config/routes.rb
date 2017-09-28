Rails.application.routes.draw do
  get 'twilio/voice'
  get 'twilio/call'
  get 'twilio/voice_fallback'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
