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

def print_summary_for_security(security)
  puts "\n#{security.id}:"
  puts "Purchase value: #{security.purchase_value}"
  puts "Year end value: #{security.year_end_value}"
  puts "Realized profit: #{security.realized_profit}"
  puts "Overall profit: #{security.overall_profit}"
end

def print_summary
  portfolio = data_service.load_portfolio

  portfolio.securities.each do |security|
    print_summary_for_security(security)
  end
end

def shares_string(number)
  "#{number} #{number > 1 ? 'shares' : 'share'}"
end

def calculate_vorabpauschale
  puts 'What is the base interest rate in %?'
  base_interest = gets.chomp.to_f / 100
  vorabpauschale_service.calculate_vorabpauschale(base_interest)
end

def prompt_allowance
  puts 'What is the goal profit you want to realize?'
  allowance = gets.chomp.to_f

  puts 'Do you want to subtract your vorabpauschale? [Y/N]'
  allowance -= calculate_vorabpauschale if gets.chomp.downcase == 'y'

  allowance
end

beginning_question = <<~DOC
  What do you want to do?
  [P] => print the summary
  [V] => calculate your Vorabpauschale
  [A] => maximize your allowance
DOC

get_input(
  beginning_question,
  {
    'p' => -> { print_summary },
    'v' => lambda do
      vorabpauschale = calculate_vorabpauschale
      puts "Your Vorabpauschale is expected to be #{vorabpauschale}"
    end,
    'a' => lambda do
      allowance = prompt_allowance

      puts "Trying to maximize your allowance of #{allowance}..."

      allowance_service.find_max_allowance(allowance) => {
        amount_to_sell:,
        profit_over_allowance:,
        profit_under_allowance:,
        portfolio:,
        ticker:
      }

      puts <<~DOC

        To maximize your allowance, you can sell #{shares_string amount_to_sell} of #{ticker} for a profit of #{profit_over_allowance}, exceeding your allowance by #{(profit_over_allowance - allowance).round(2)}.
        If you do not want to exceed your allowance, just sell one less share (#{shares_string(amount_to_sell - 1)}) for a profit of #{profit_under_allowance}, deceeding your allowance by #{(allowance - profit_under_allowance).round(2)}
      DOC

      get_input(
        "\nDo you want to update the json data with the the new sold shares? [y/n]",
        {
          'y' => lambda do
            puts 'Updating the json data'
            data_service.save_portfolio(portfolio)
          end,
          'n' => -> { puts 'Not updating the json data' }
        }
      )
    end
  }
)
