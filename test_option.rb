require "option"

OptionExpireDate.find_all_by_ticker("GOOG").each { | oed |
  puts "Finding Option Chain for Expiration Date: " + oed.to_s
  oc = OptionChain.find_by_ticker_and_option_expire_date("GOOG",oed)
  puts oc
}
