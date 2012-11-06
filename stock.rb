require 'rubygems'
require 'oauth'
require "rexml/document"

require_relative 'access_token'
require_relative 'consumer_token'

class Stock
	attr_accessor :ticker
	attr_accessor :price
	attr_accessor :ly_dividend

	def initialize(t,p,l)
		@ticker = t
		@price = p
		@ly_dividend = l
	end
	def to_s
		return "STOCK " + ticker + " Price: " + price.to_s + " Annual Dividend: " + ly_dividend.to_s
	end
	def Stock.find_by_ticker(t)
		consumer = OAuth::Consumer.new(CONSUMER_TOKEN[:token],CONSUMER_TOKEN[:secret],{:site => "https://etwssandbox.etrade.com", :http_method => :get})
		access_token = OAuth::Token.new(ACCESS_TOKEN[:token],ACCESS_TOKEN[:secret])

		response = consumer.request(:get, "/market/sandbox/rest/quote/#{t}", access_token, {:detailFlag => "INTRADAY"})
		doc = REXML::Document.new response.body
		price = doc.elements["QuoteResponse/QuoteData/all/ask"].text.to_f

		response = consumer.request(:get, "/market/sandbox/rest/quote/#{t}", access_token, {:detailFlag => "WEEK_52"})
		doc = REXML::Document.new response.body
		puts doc
		ly_dividend = doc.elements["QuoteResponse/QuoteData/all/annualDividend"].text.to_f

		return Stock.new(t,price,ly_dividend)
	end
	def option_expire_dates
		return OptionExpireDate.find_all_by_ticker(ticker)
	end
end

puts Stock.find_by_ticker("ASDFAS23")
