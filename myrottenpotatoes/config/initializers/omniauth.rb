# config/initializers/omniauth.rb
# Replace API_KEY and API_SECRET with the values you got from Twitter
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, "0BmxoUlwYxCLLcXihWpfLAs9P", "ZhRuhjPflMHxtTOQ7QGrrGFjR5sYYDkP6Pz4jAHpPO2Af5fPM0"
end

