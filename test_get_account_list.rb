require 'rubygems'
require 'oauth'
require_relative 'access_token'
require_relative 'consumer_token'

consumer = OAuth::Consumer.new(CONSUMER_TOKEN[:token],CONSUMER_TOKEN[:secret],{:site => "https://etwssandbox.etrade.com", :http_method => :get})
access_token = OAuth::Token.new(ACCESS_TOKEN[:token],ACCESS_TOKEN[:secret])

puts consumer.request(:get, '/accounts/sandbox/rest/accountlist', access_token)
