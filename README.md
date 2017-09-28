# Twilioチュートリアル(SDK 4.13.0)

都合により、古いバージョンのtwilio-rubyを使っています。
最新のSDKバージョンは5.Xなので注意してください。

# Twilioの無料トライアルアカウントを作成する

以下のURLからサインアップして、トライアルアカウントを作成してください。(クレジットカードを登録しない限り、課金は発生しません)

https://twilio.kddi-web.com/

Setting > General > SSL証明書の検証で、検証を「無効」にします。

https://jp.twilio.com/console/account/settings

# 開発環境構築

```
make setup
```

.envファイルにtwilioの接続情報と電話番号を記述します

```
TWILIO_ACCOUNT_SID = YOURACCOUNTSID
TWILIO_AUTH_TOKEN = YOURAUTHTOKEN
TWILIO_PHONE_NUMBER = YOURPHONENUMBER # twilioで購入した電話番号(ex: +815099999999)
DIAL_PHONE_NUMBER = DIALPHONENUMBER # 動作確認2の発信先の電話番号(ex: +818099999999)
```

railsサーバとngrokを起動します

```
./bin/rails s
[ターミナルの別タブ]
ngrok http 3000
# ログに表示されるngrokのURLを覚えておく
```

# 動作確認1: Twilio電話番号に電話した時に、音声を流す。

`./bin/rails c`でコンソールを起動し、twilio電話番号(TWILIO_PHONE_NUMBER)の`voice_url`と`voice_fallback_url`を設定します

```rb
client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
ngrok_url = 'http://YOUR_NGROK_URL'
voice_url = ngrok_url + '/twilio/voice.xml'
voice_fallback_url = ngrok_url + '/twilio/voice_fallback.xml'
incoming_phone_number = client.account.incoming_phone_numbers.list({ phone_number: ENV['TWILIO_PHONE_NUMBER'] }).first
incoming_phone_number.update(voice_method: 'GET',
                             voice_url: voice_url,
                             voice_fallback_method: 'GET',
                             voice_fallback_url: voice_fallback_url
                            )
```

twilio電話番号に電話をかけると、`TwilioController#voice`APIが呼び出され、`Success`という音声が流れます。

Railsログ:

```
Started GET "/twilio/voice.xml?.....
Processing by TwilioController#voice as XML
  Parameters: {"Called"=>"+815099999999", "ToState"=>"", "CallerCountry"=>"JP", "Direction"=>"inbound", "CalledVia"=>"05099999999", "CallerState"=>"", "ToZip"=>"", "CallSid"=>"Hoge", "To"=>"+815099999999", "CallerZip"=>"", "ToCountry"=>"JP", "ApiVersion"=>"2010-04-01", "CalledZip"=>"", "CalledCity"=>"", "CallStatus"=>"ringing", "From"=>"+818011111111", "AccountSid"=>"HOGE", "CalledCountry"=>"JP", "CallerCity"=>"", "Caller"=>"+818011111111", "FromCountry"=>"JP", "ToCity"=>"", "FromCity"=>"", "CalledState"=>"", "ForwardedFrom"=>"05099999999", "FromZip"=>"", "FromState"=>""}
```

`TwilioController#voice`の`# return head 400`をコメントアウトしてから電話をすると、`TwilioController#voice_fallback`APIが呼び出され、`Failed`という音声が流れます。

Railsログ:
```
Started GET "/twilio/voice_fallback.xml?.....
Processing by TwilioController#voice_fallback as XML
  Parameters: {"Called"=>"+815099999999", "ToState"=>"", "CallerCountry"=>"JP", "Direction"=>"inbound", "CalledVia"=>"05099999999", "CallerState"=>"", "ToZip"=>"", "CallSid"=>"Hoge", "To"=>"+815099999999", "CallerZip"=>"", "ToCountry"=>"JP", "ApiVersion"=>"2010-04-01", "CalledZip"=>"", "CalledCity"=>"", "CallStatus"=>"ringing", "From"=>"+818011111111", "AccountSid"=>"HOGE", "CalledCountry"=>"JP", "CallerCity"=>"", "Caller"=>"+818011111111", "FromCountry"=>"JP", "ToCity"=>"", "ErrorUrl"=>"http://hoge.ngrok.io/twilio/voice.xml", "FromCity"=>"", "CalledState"=>"", "ForwardedFrom"=>"05099999999", "ErrorCode"=>"11200", "FromZip"=>"", "FromState"=>""}
```

# 動作確認2: Twilio電話番号に電話した時に、別の電話番号に発信する。(動作確認失敗)

`./bin/rails c`でコンソールを起動し、twilio電話番号(TWILIO_PHONE_NUMBER)の`voice_url`を設定します

```rb
client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
ngrok_url = 'http://YOUR_NGROK_URL'
call_url = ngrok_url + '/twilio/call.xml'
incoming_phone_number = client.account.incoming_phone_numbers.list({ phone_number: ENV['TWILIO_PHONE_NUMBER'] }).first
incoming_phone_number.update(voice_method: 'GET', voice_url: call_url)
```

twilio電話番号に電話をかけると、ENV['DIAL_PHONE_NUMBER']に電話が発信されるはずなのだが、トライアル版の制限のせいか発信されなかった。

参考: [無料トライアルアカウントの制限事項は何ですか?](https://twilioforkwc.zendesk.com/hc/ja/articles/206426721-%E7%84%A1%E6%96%99%E3%83%88%E3%83%A9%E3%82%A4%E3%82%A2%E3%83%AB%E3%82%A2%E3%82%AB%E3%82%A6%E3%83%B3%E3%83%88%E3%81%AE%E5%88%B6%E9%99%90%E4%BA%8B%E9%A0%85%E3%81%AF%E4%BD%95%E3%81%A7%E3%81%99%E3%81%8B-)
