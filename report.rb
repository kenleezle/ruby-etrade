class Report
	attr_accessor :report_items
	class Format
		CSV = 1
		PRETTY_PRINT = 2
	end
	def initialize
		@report_items = Array.new
	end
	def addReportItem(item)
		@report_items.push(item)
	end
	def toString(format)
		raise "UnknownReportFormat" unless \
			format == Format::CSV || \
			format == Format::PRETTY_PRINT

		retval = ""
		if @report_items.length > 0 then
			retval += @report_items.first.class.header_line(format)+"\n"
			@report_items.each { | ri | retval += ri.toString(format)+"\n" }
		end
		return retval
	end
end
class ReportItem
	attr_accessor :fields
	def toString
		raise "Abstract Method"
	end
end
