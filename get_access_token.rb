require 'rubygems'
require 'oauth'
require 'consumer_token'
include OAuth::Helper

consumer = OAuth::Consumer.new(CONSUMER_TOKEN[:token],CONSUMER_TOKEN[:secret],{:site => "https://etws.etrade.com", :http_method => :get})
request_token = consumer.get_request_token()

puts "In your browser, go to https://us.etrade.com/e/t/etws/authorize?key=#{escape(CONSUMER_TOKEN[:token])}&token=#{escape(request_token.token)}"
puts "Once you have authorized this app, enter your pin here and press enter:"

pin = $stdin.readline().chomp

access_token = consumer.get_access_token(request_token,{:oauth_verifier => pin})

puts "Now copy and paste the following hash into a new file in this directory called access_token.rb"
puts "ACCESS_TOKEN = {"
puts "  :token => \"#{access_token.token}\","
puts "  :secret => \"#{access_token.secret}\""
puts "}"
