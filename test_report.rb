require './life_cycle_report'

LifeCycleReportItem.setup
r = Report.new
tickers = ["GOOG","AAPL"]
tickers.each { | t |
	item = LifeCycleReportItem.new
	item.ticker = t
	item.stock_price = 50.56
	item.leverage = 3.5
	r.addReportItem(item)
}
puts r.toString("csv")
puts "******************"
puts r.toString("pretty_print")
