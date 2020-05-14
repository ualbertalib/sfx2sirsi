# TEST Summary Holdings code
#
def ongoing?(thresholds)
  ongoing = false
  thresholds.each{ |t| ongoing = true if t[:ongoing] }  
  ongoing
end

def sort_thresholds(thresholds)
  
end

	thresholds = []
        summaryHoldings = ["(1956)-(1995)", "(1956)-(1995)", "(1990)-(1996)", "(1995)"]
	summaryHoldings.each{ |range| 
		range.gsub!(/\(/,"",).gsub!(/\)/,"").strip! if range.include?("(") 
		}
        summaryHoldings.each{ |range|
                range_scan = range.scan(/\d{4}/)
                single_year = range.scan(/-/).empty?
 		if single_year
			thresholds << {:start => range_scan.first, :end => "null", :ongoing=>false}
		else
			(range_scan.count == 2) ? thresholds << {:start => range_scan.first, :end => range_scan.last, :ongoing=>false} : thresholds << {:start => range_scan.first, :end=>"null", :ongoing=>true}
		end
}
#	summary_holdings_statement = ""
 #     if  ongoing?(thresholds)
      

