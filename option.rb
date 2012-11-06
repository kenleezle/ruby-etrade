require 'rubygems'
require 'oauth'
require "rexml/document"

require_relative 'access_token'
require_relative 'consumer_token'

class Option
	attr_accessor :ticker
	attr_accessor :price
	attr_accessor :strike_price
	attr_accessor :option_expire_date
	attr_accessor :option_type
	attr_accessor :option_category

	def initialize(t,p,s,oed)
		@ticker = t
		@price = p
		@strike_price = s
		@option_expire_date = oed
		@option_type = "CALL"
		@option_category = "AMERICAN"
	end
	def term
		delta_years = (option_expire_date.year - Time.now.year)
		delta_days = (option_expire_date.day - Time.now.yday)
		return delta_years + delta_days/365.0
	end
	def to_s
		return "OPTION " + ticker + "\n Price: " + price.to_s + "\n Strike Price: " + strike_price.to_s + "\n Expiry Date: " + option_expire_date.expire_date.to_s + "\n Term in Years: " + term.to_s
	end
	def symbol
		return "#{ticker}:#{option_expire_date.year}:#{option_expire_date.month}:#{option_expire_date.day}:CALL:#{strike_price}"
	end
	def update_price
		consumer = OAuth::Consumer.new(CONSUMER_TOKEN[:token],CONSUMER_TOKEN[:secret],{:site => "https://etwssandbox.etrade.com", :http_method => :get})
		#consumer.http.set_debug_output($stderr)
		access_token = OAuth::Token.new(ACCESS_TOKEN[:token],ACCESS_TOKEN[:secret])
		response = consumer.request(:get, "/market/sandbox/rest/quote/#{symbol}", access_token, {:detailFlag => "OPTIONS"})
		doc = REXML::Document.new response.body
		@price = doc.elements["QuoteResponse/QuoteData/all/ask"].text.to_f
	end
end
class OptionExpireDate
	attr_accessor :ticker
	attr_accessor :year
	attr_accessor :month
	attr_accessor :day

	def initialize(t,y,m,d)
		@ticker = t
		@year = y
		@month = m
		@day = d
	end
	def expire_date
		return year.to_s+"-"+month.to_s+"-"+day.to_s
	end
	def to_s
		return "STOCK " + ticker + " Expire Date " + expire_date
	end
	def ==(oed)
		return ticker == oed.ticker && expire_date == oed.expire_date
	end
	def OptionExpireDate.find_all_by_ticker(ticker)
		consumer = OAuth::Consumer.new(CONSUMER_TOKEN[:token],CONSUMER_TOKEN[:secret],{:site => "https://etwssandbox.etrade.com", :http_method => :get})
		#consumer.http.set_debug_output($stderr)
		access_token = OAuth::Token.new(ACCESS_TOKEN[:token],ACCESS_TOKEN[:secret])

		response = consumer.request(:get, "/market/sandbox/rest/optionexpiredate?underlier=#{ticker}", access_token)
		doc = REXML::Document.new response.body

		oeds = Array.new

		doc.elements.each("OptionExpireDateGetResponse/ExpirationDate") { | element | 
			year = element.elements["year"].text.to_i
			month = element.elements["month"].text.to_i
			day = element.elements["day"].text.to_i
			oeds.push OptionExpireDate.new(ticker,year,month,day)
		}
		return oeds.uniq
	end
end
class OptionChain
	attr_accessor :ticker
	attr_accessor :options
	attr_accessor :option_expire_date

	def initialize(t)
		@ticker = t
		@options = Array.new
	end
	def to_s
		retval = "Option Chain " + ticker + "\n"
		options.each { | o | retval += o.to_s+"\n" }
		return retval
	end
	def OptionChain.find_by_ticker_and_option_expire_date(ticker,oed)
		consumer = OAuth::Consumer.new(CONSUMER_TOKEN[:token],CONSUMER_TOKEN[:secret],{:site => "https://etwssandbox.etrade.com", :http_method => :get})
		access_token = OAuth::Token.new(ACCESS_TOKEN[:token],ACCESS_TOKEN[:secret])

		params = {
			:chainType => "CALL",
			:expirationMonth => oed.month,
			:expirationYear => oed.year,
			:underlier => ticker
		}
		param_string = OAuth::Helper.normalize(params)
		response = consumer.request(:get, "/market/sandbox/rest/optionchains?#{param_string}", access_token)
		doc = REXML::Document.new response.body

		oc = OptionChain.new(ticker)
		doc.elements.each("OptionChainResponse/optionPairs/call") { | element | 
			strike_price = element.elements["strikePrice"].text.to_f
			option = Option.new(ticker,nil,strike_price,oed)
			option.update_price
			oc.options.push option
		}
		return oc
	end
end
