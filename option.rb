require 'rubygems'
require 'oauth'
require "rexml/document"

require_relative 'access_token'
require_relative 'consumer_token'

class Option
	attr_accessor :ticker
	attr_accessor :price
	attr_accessor :strike_price
	attr_accessor :expiry_date
	attr_accessor :option_type
	attr_accessor :option_category

	def initialize(t,p,s)
		@ticker = t
		@price = p
		@strike_price = s
		@option_type = "CALL"
		@option_category = "AMERICAN"
	end
	def set_expiry_date(y,m,d)
		@expiry_date = Time.new(y,m,d)
	end
	def term
		delta_years = (expiry_date.year - Time.now.year)
		delta_days = (expiry_date.yday - Time.now.yday)
		return delta_years + delta_days/365.0
	end
	def to_s
		return "OPTION " + ticker + "\n Price: " + price.to_s + "\n Strike Price: " + strike_price.to_s + "\n Expiry Date: " + expiry_date.to_s + "\n Term in Years: " + term.to_s
	end
	def Option.find_by_ticker(t)
		consumer = OAuth::Consumer.new(CONSUMER_TOKEN[:token],CONSUMER_TOKEN[:secret],{:site => "https://etwssandbox.etrade.com", :http_method => :get})
		access_token = OAuth::Token.new(ACCESS_TOKEN[:token],ACCESS_TOKEN[:secret])
		response = consumer.request(:get, "/market/sandbox/rest/quote/#{t}", access_token, {:detailFlag => "OPTIONS"})
		doc = REXML::Document.new response.body
		puts doc
		#return Option.new(t,doc.elements["QuoteResponse/QuoteData/all/ask"].text.to_f)
	end

end
puts Option.find_by_ticker("GOOG")
