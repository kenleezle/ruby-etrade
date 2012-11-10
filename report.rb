class Report
	attr_accessor :report_items
	FORMAT = ["csv","pretty_print"]

	def initialize
		@report_items = Array.new
	end
	def addReportItem(item)
		@report_items.push(item)
	end
	def toString(format)
		retval = ""
		retval += @report_items.first.class.header_line(format)+"\n"
		@report_items.each { | ri | retval += ri.toString(format)+"\n" }
		return retval
	end
end
class ReportItem
	attr_accessor :fields
	def toString
		raise "Abstract Method"
	end
end
