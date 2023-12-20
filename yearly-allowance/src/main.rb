# frozen_string_literal: true

require 'json'

require_relative './purchase'

# Allowance

def maximize_allowance(purchases:, sell_price:, allowance:) # rubocop:disable Metrics/MethodLength
  goal_profit_next_purchase = allowance
  overall_amount_to_sell = 0
  overall_profit = 0

  purchases.each do |p|
    break if goal_profit_next_purchase.negative?
    next if p.amount <= p.shares_sold

    shares_to_sell = p.shares_to_sell(
      sell_price:,
      goal_profit: goal_profit_next_purchase
    )
    p.shares_sold = shares_to_sell
    profit = p.realized_profit(sell_price:)

    overall_amount_to_sell += shares_to_sell
    goal_profit_next_purchase -= profit
    overall_profit += profit

    break if p.shares_sold < p.amount
  end

  { amount_to_sell: overall_amount_to_sell, profit: overall_profit }
end

def last_sold_purchase(purchases)
  purchases[purchases.rindex { |p| p.shares_sold.positive? }]
end

def find_max_allowance(ticker, sell_price, allowance)
  purchases(ticker) => { purchases:, data_hash: }

  maximize_allowance(purchases:, sell_price:, allowance:) => {
    amount_to_sell:,
    profit: profit_over_allowance
  }

  last_sold_purchase = last_sold_purchase(purchases)
  profit_under_allowance = (profit_over_allowance - last_sold_purchase.profit_per_share(sell_price:)).round(2)

  { amount_to_sell:, profit_over_allowance:, profit_under_allowance:, purchases: }
end

# DATA

def data_file
  "#{__dir__.split('/')[..-2].join('/')}/data/portfolio.json"
end

def read_data_hash
  file = File.read(data_file)
  JSON.parse(file)
end

def raw_purchases(data_hash, ticker)
  data_hash['securities'].find { |s| s['ticker'] == ticker }['purchases']
end

def purchases(ticker)
  data_hash = read_data_hash

  purchases = raw_purchases(data_hash, ticker).map do |p|
    Purchase.new(
      date: Time.new(p['date']),
      buy_price: p['buy_price'],
      amount: p['amount'],
      shares_sold: p['shares_sold']
    )
  end

  { purchases:, data_hash: }
end

# OUTPUT

def get_input(statement, lambda_hash)
  puts statement

  input = gets.chomp.downcase

  lambda = lambda_hash[input]

  if lambda.nil?
    puts 'Couldn\'t understand, please try again.'
    return get_input(statement, lambda_hash)
  end

  repeat = lambda.call

  get_input(statement, lambda_hash) if repeat
end

def print_summary(ticker, sell_price)
  purchases(ticker) => { purchases:, data_hash: }

  puts "Purchase value: #{purchases.sum(&:buy_value)}"
  puts "Current value: #{purchases.sum { |p| p.sell_value(sell_price:) }}"
  puts "Realized profit: #{purchases.sum { |p| p.realized_profit(sell_price:) }}"
  puts "Overall profit: #{purchases.sum { |p| p.profit(sell_price:) }}"
end

def shares_string(number)
  "#{number} #{number > 1 ? 'shares' : 'share'}"
end

def update_json(data_hash, ticker, purchases)
  puts 'Updating the json data'
  data_hash['securities'].find { |s| s['ticker'] == ticker }['purchases'] = purchases.map(&:to_hash)
  File.write(data_file, JSON.pretty_generate(data_hash))
end

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
def output_max_allowance_and_write_to_json(allowance:, amount_to_sell:, profit_over_allowance:,
                                           profit_under_allowance:, purchases:)
  puts <<~DOC

    To maximize your allowance, you can sell #{shares_string amount_to_sell} for a profit of #{profit_over_allowance}, exceeding your allowance by #{(profit_over_allowance - allowance).round(2)}.
    If you do not want to exceed your allowance, just sell one less share (#{shares_string(amount_to_sell - 1)}) for a profit of #{profit_under_allowance}, deceeding your allowance by #{(allowance - profit_under_allowance).round(2)}
  DOC

  get_input("\nDo you want to update the json data with the the new sold shares? [y/n] Press [P] to print the data.", {
              'y' => -> { update_json(data_hash, ticker, purchases) },
              'n' => -> { puts 'Not updating the json data' },
              'p' => lambda do
                pp(purchases.map(&:to_hash))
                true
              end
            })
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize

ticker = 'LYX00F'
sell_price = 60.00
allowance = 988.37 - 395.59

get_input('What do you want to do? Press [P] to print the summary. Press [A] to maximize your allowance.', {
            'p' => -> { print_summary(ticker, sell_price) },
            'a' => lambda do
              find_max_allowance(ticker, sell_price, allowance) => {
                amount_to_sell:,
                profit_over_allowance:,
                profit_under_allowance:,
                purchases:
              }

              output_max_allowance_and_write_to_json(allowance:, amount_to_sell:, profit_over_allowance:,
                                                     profit_under_allowance:, purchases:)
            end
          })
