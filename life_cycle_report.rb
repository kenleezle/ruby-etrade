require './report'
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
		@@map[short_name+"="] = {:index => @@map.size, :name => long_name}
		@@field_names.push(long_name)
	end
	def LifeCycleReportItem.setup
		@@map = Hash.new
		@@field_names = Array.new
		add_field("ticker","Ticker")
		add_field("stock_price","Stock Price")
		add_field("100_stock_price","Stock Price * 100")
		add_field("option_price","Option Price")
		add_field("100_option_price","Option Price * 100")
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
		raise NoMethodError unless @@map[method.to_s]
		fields[@@map[method.to_s][:index]] = args[0]
	end
end
