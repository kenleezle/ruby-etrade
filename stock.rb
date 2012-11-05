require 'rubygems'
require 'oauth'
require "rexml/document"

require_relative 'access_token'
require_relative 'consumer_token'

class Stock
	attr_accessor :ticker
	attr_accessor :price

	def initialize(t,p)
		@ticker = t
		@price = p
	end
	def to_s
		return "STOCK " + ticker + " " + price.to_s
	end
	def Stock.find_by_ticker(t)
		consumer = OAuth::Consumer.new(CONSUMER_TOKEN[:token],CONSUMER_TOKEN[:secret],{:site => "https://etwssandbox.etrade.com", :http_method => :get})
		access_token = OAuth::Token.new(ACCESS_TOKEN[:token],ACCESS_TOKEN[:secret])
		response = consumer.request(:get, "/market/sandbox/rest/quote/#{t}", access_token, {:detailFlag => "INTRADAY"})
		doc = REXML::Document.new response.body
		return Stock.new(t,doc.elements["QuoteResponse/QuoteData/all/ask"].text.to_f)
	end
end

puts Stock.find_by_ticker("GOOG")
