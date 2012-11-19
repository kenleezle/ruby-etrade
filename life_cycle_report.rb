require './report'
require './option'
require './stock'
class LifeCycleReportItem < ReportItem
	def LifeCycleReportItem.header_line(format)
		if format == Report::Format::PRETTY_PRINT then
			retval = ""
			@@field_names.each { | f | retval += format_field(f) }
			return retval
		elsif format == Report::Format::CSV then
			return @@field_names.join(",")
		end
	end
	def LifeCycleReportItem.format_field(f)
		return sprintf("%20.20s", "#{f}");
	end
	def LifeCycleReportItem.add_field(short_name,long_name)
		map_size = @@map.size/2
		h = {:index => map_size, :name => long_name}
		@@map[short_name+"="] = h
		@@map[short_name] = h
		@@field_names.push(long_name)
	end
	def LifeCycleReportItem.setup
		@@map = Hash.new
		@@field_names = Array.new
		add_field("ticker","Ticker")
		add_field("stock_price","Stock Price")
		add_field("stock_price_100","Stock Price * 100")
		add_field("option_price","Option Price")
		add_field("option_price_100","Option Price * 100")
		add_field("strike_price","Strike Price")
		add_field("leverage","Leverage")
		add_field("term","Term in Years")
		add_field("annual_dividend","Annual Dividend")
		add_field("amount_borrowed","Amount Borrowed")
		add_field("implied_interest_rate","Implied Interest Rate")
	end
	def initialize
		@fields = Array.new
	end
	def toString(format)
		if format == Report::Format::PRETTY_PRINT then
			retval = ""
			fields.each { | f | retval += LifeCycleReportItem.format_field(f) }
			return retval
		elsif format == Report::Format::CSV then
			return fields.join(",")
		end
	end
	def method_missing(method,*args)
		raise NoMethodError, method.to_s unless @@map[method.to_s]
		if method.to_s =~ /=$/ then
			puts "setting #{method} to #{args[0]}"
			return fields[@@map[method.to_s][:index]] = args[0]
		else
			return fields[@@map[method.to_s][:index]]
		end
	end
end
class LifeCycleInvesting
	def LifeCycleInvesting.doReport
		puts "Please input a list of stocks, one per line"
		LifeCycleReportItem.setup
		report = Report.new
		tickers = Array.new
		STDIN.readlines.each { | ticker |
			tickers.push(ticker.chomp)
		}
		tickers.each { | ticker |
			puts "Ticker: #{ticker}"
			oeds = OptionExpireDate.find_all_by_ticker(ticker)
			oeds.each { | oed |
				puts "OED: #{oed}"
				next if oed.years_from_now < 1
				#skip expire date unless its longer than a year out
				option_chain = OptionChain.find_by_ticker_and_option_expire_date(ticker,oed)
				option_chain.options.each { | option |
					puts "option: #{option}"
					option.update_price
					stock = option.stock
					puts "stock: #{stock}"
					# Now we have all the information we need to add an item to the report
					report_item = LifeCycleReportItem.new
					report_item.ticker = ticker
					report_item.option_price = option.price
					report_item.stock_price = stock.price
					report_item.stock_price_100 = stock.price*100
					report_item.option_price_100 = option.price*100
					report_item.strike_price = option.strike_price
					report_item.annual_dividend = stock.ly_dividend
					report_item.leverage = stock.price/option.strike_price
					report_item.term = option.term
					report_item.amount_borrowed = stock.price - option.price

					implied_extra_payment = option.price + option.strike_price - stock.price
					transaction_payment = 20
					total_implied_payments = implied_extra_payment + report_item.annual_dividend + transaction_payment/100

					report_item.implied_interest_rate = (total_implied_payments/report_item.amount_borrowed)/(option.term_in_days/365)
					report.addReportItem(report_item)
				}
			}
		}
		puts "******************"
		puts report.toString(Report::Format::PRETTY_PRINT)
		puts "******************"
		puts report.toString(Report::Format::CSV)
		puts "******************"
	end
end
LifeCycleInvesting.doReport
