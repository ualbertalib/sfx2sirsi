require "rspec"
require "./summary_holdings.rb"

include SummaryHoldings

describe SummaryHoldings do
  it "properly transforms a threshold with all overlapping ranges, with an embargo, embargo superseded by  " do
    summaryHoldings = ["(1956)-(1965)", "(1966)-(1999)", "(1990)-most recent 3 years unavailable", "(1995)", "(2000)-"]
    expect(SummaryHoldings.pretty_print(SummaryHoldings.merge(SummaryHoldings.compile(summaryHoldings)))).to eq("1956- ")
  end

  it "properly transforms a threshold all overlapping ranges, with an active embargo" do
    summaryHoldings = ["(1956)-(1965)", "(1966)-(1999)", "(1990)-most recent 3 years unavailable", "(1995)", "(2000)"]
    expect(pretty_print(merge(compile(summaryHoldings)))).to eq("1956- , most recent 3 years unavailable")
  end

  it "properly transforms a threshold with no overlapping and no disjoint ranges, with no embargo." do
    summaryHoldings = ["(1956)-(1960)", "(1966)-(1999)"]
    expect(pretty_print(merge(compile(summaryHoldings)))).to eq("1956-1960, 1966-1999")
  end

  it "properly transforms an open-ended threshold with disjoint ranges" do
    summaryHoldings = ["(1956)-(1960)", "(1966)-"]
    expect(pretty_print(merge(compile(summaryHoldings)))).to eq("1956-1960, 1966- ")
  end

  it "properly transforms a closed threshold with overlap" do
    summaryHoldings = ["(1966)-(1999)", "(1990)-(2010)"]
    expect(pretty_print(merge(compile(summaryHoldings)))).to eq("1966-2010")
  end

  it "properly transforms disjoint ranges with an embargo" do
    summaryHoldings = ["(1956)-(1960)", "(1966)-Most recent 2 years unavailable"]
    expect(pretty_print(merge(compile(summaryHoldings)))).to eq("1956-1960, 1966- , Most recent 2 years unavailable")
  end

  it "properly transforms: one disjoint, one overlap" do
    summaryHoldings = ["(1956)-(1960)", "(1966)-(1999)", "(1990)-(2010)"]
    expect(pretty_print(merge(compile(summaryHoldings)))).to eq("1956-1960, 1966-1999, 1990-2010")
  end

  it "properly transforms: one disjoint, one overlap, open-ended" do  
    summaryHoldings = ["(1956)-(1960)", "(1966)-(1999)", "(1990)-"]
    expect(pretty_print(merge(compile(summaryHoldings)))).to eq("1956-1960, 1966-1999, 1990- ")
  end

  it "properly transforms: single year ranges" do  
    summaryHoldings = ["(1994)-(1994)"]
    expect(pretty_print(merge(compile(summaryHoldings)))).to eq("1994")
  end

  it "properly transforms an empty threshold" do
    summaryHoldings = [""]
    expect(pretty_print(merge(compile(summaryHoldings)))).to eq("Available")
  end
end
