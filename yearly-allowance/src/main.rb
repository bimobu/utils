# frozen_string_literal: true

require 'json'

require_relative './services/data_service'
require_relative './services/allowance_service'
require_relative './services/vorabpauschale_service'

def data_service
  DataService.new
end

def allowance_service
  AllowanceService.new
end

def vorabpauschale_service
  VorabpauschaleService.new
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

  res = lambda.call
  res => {repeat:} if res.respond_to?(:deconstruct_keys)

  get_input(statement, lambda_hash) if repeat
end

def print_summary(ticker, sell_price)
  portfolio = data_service.load_portfolio
  purchases = portfolio.security(ticker).purchases

  puts "Purchase value: #{purchases.sum(&:buy_value)}"
  puts "Current value: #{purchases.sum { |p| p.sell_value(sell_price:) }}"
  puts "Realized profit: #{purchases.sum { |p| p.realized_profit(sell_price:) }}"
  puts "Overall profit: #{purchases.sum { |p| p.profit(sell_price:) }}"
end

def shares_string(number)
  "#{number} #{number > 1 ? 'shares' : 'share'}"
end

# rubocop:disable Metrics/MethodLength
def output_max_allowance_and_write_to_json(allowance:, amount_to_sell:, profit_over_allowance:,
                                           profit_under_allowance:, portfolio:)
  puts <<~DOC

    To maximize your allowance, you can sell #{shares_string amount_to_sell} for a profit of #{profit_over_allowance}, exceeding your allowance by #{(profit_over_allowance - allowance).round(2)}.
    If you do not want to exceed your allowance, just sell one less share (#{shares_string(amount_to_sell - 1)}) for a profit of #{profit_under_allowance}, deceeding your allowance by #{(allowance - profit_under_allowance).round(2)}
  DOC

  get_input("\nDo you want to update the json data with the the new sold shares? [y/n]",
            {
              'y' => lambda do
                puts 'Updating the json data'
                data_service.save_portfolio(portfolio)
              end,
              'n' => -> { puts 'Not updating the json data' }
            })
end
# rubocop:enable Metrics/MethodLength

ticker = 'LYX00F'
sell_price = 60.00
allowance = 988.37 - 395.59

get_input('What do you want to do? ' \
          '[P] => print the summary, ' \
          '[A] => maximize your allowance, ' \
          '[V] => calculate your Vorabpauschale.',
          {
            'p' => -> { print_summary(ticker, sell_price) },
            'a' => lambda do
              allowance_service.find_max_allowance(ticker, sell_price, allowance) => {
                amount_to_sell:,
                profit_over_allowance:,
                profit_under_allowance:,
                portfolio:
              }

              output_max_allowance_and_write_to_json(allowance:, amount_to_sell:, profit_over_allowance:,
                                                     profit_under_allowance:, portfolio:)
            end,
            'v' => -> { puts vorabpauschale_service.calculate_vorabpauschale }
          })
