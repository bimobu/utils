# frozen_string_literal: true

require 'json'

require_relative 'constants'
require_relative './services/data_service'
require_relative './services/profit_service'
require_relative './services/vorabpauschale_service'

def data_service
  DataService.new
end

def profit_service
  ProfitService.new
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
    'a' => lambda do # rubocop:disable Metrics/BlockLength
      allowance = prompt_allowance.round(2)
      goal_profit = (allowance / Constants.partial_exemption).round(2)

      puts "Trying to maximize your allowance of #{allowance} by reaching a profit of #{goal_profit}..."

      profit_service.reach_goal_profit(goal_profit) => {
        amount_to_sell_over_goal_profit:,
        profit_over_goal_profit:,
        amount_to_sell_under_goal_profit:,
        profit_under_goal_profit:,
        portfolio:,
        ticker:
      }

      taxed_profit_over_goal = (profit_over_goal_profit * Constants.partial_exemption).round(2)
      allowance_overshoot = (taxed_profit_over_goal - allowance).round(2)
      taxed_profit_under_goal = (profit_under_goal_profit * Constants.partial_exemption).round(2)
      allowance_undershoot = (allowance - taxed_profit_under_goal).round(2)

      puts <<~DOC

        To maximize your allowance of #{allowance}, you can sell #{shares_string amount_to_sell_over_goal_profit} of #{ticker} for a profit of #{profit_over_goal_profit} (taxed #{taxed_profit_over_goal}), exceeding your allowance by #{allowance_overshoot}.
        If you do not want to exceed your allowance, just sell one less share (#{shares_string amount_to_sell_under_goal_profit}) for a profit of #{profit_under_goal_profit} (taxed #{taxed_profit_under_goal}), deceeding your allowance by #{allowance_undershoot}
      DOC

      get_input(
        "\nDo you want to update the json data with the the new sold shares over the allowance? [y/n]",
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
