# frozen_string_literal: true

base_interest = 0.0255

securities = [
  {
    share_price_start_of_year: 41,
    share_price_end_of_year: 62,
    number_of_shares: 382,
    partial_exemption: 0.7
  },
  {
    share_price_start_of_year: 73.8,
    share_price_end_of_year: 90,
    number_of_shares: 41,
    partial_exemption: 0.7
  },
  {
    share_price_start_of_year: 386,
    share_price_end_of_year: 480,
    number_of_shares: 9,
    partial_exemption: 0.7
  }
]

puts(securities.sum do |s|
  value_start_of_year = s[:share_price_start_of_year] * s[:number_of_shares]
  value_end_of_year = s[:share_price_end_of_year] * s[:number_of_shares]
  appreciation = value_end_of_year - value_start_of_year
  base_yield = value_start_of_year * base_interest * s[:partial_exemption]
  [appreciation, base_yield].min.round(2)
end)
