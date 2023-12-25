# frozen_string_literal: true

require_relative '../constants'

# Handles calculation for allowances
class AllowanceService
  def find_max_allowance(allowance) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    portfolio = data_service.load_portfolio
    security = portfolio.securities.first
    purchases = security.purchases

    maximize_allowance(purchases:, sell_price: security.share_price_end_of_year, allowance:) => {
      amount_to_sell_over_allowance:,
      profit_over_allowance:
    }

    last_sold_purchase = last_sold_purchase(purchases)
    profit_per_share = last_sold_purchase.profit_per_share(sell_price: security.share_price_end_of_year) * Constants.partial_exemption
    profit_under_allowance = (profit_over_allowance - profit_per_share).round(2)
    amount_to_sell_under_allowance = amount_to_sell_over_allowance - 1

    {
      amount_to_sell_over_allowance:,
      profit_over_allowance:,
      amount_to_sell_under_allowance:,
      profit_under_allowance:,
      portfolio:,
      ticker: security.id
    }
  end

  private

  def maximize_allowance(purchases:, sell_price:, allowance:) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    goal_profit_next_purchase = allowance
    amount_to_sell_over_allowance = 0
    profit_over_allowance = 0

    purchases.each do |p|
      break if goal_profit_next_purchase.negative?
      next if p.amount <= p.shares_sold

      goal_profit = (goal_profit_next_purchase / Constants.partial_exemption).round(2)

      shares_to_sell = p.shares_to_sell(
        sell_price:,
        goal_profit:
      )
      p.shares_sold += shares_to_sell
      profit = (p.realized_profit(sell_price:, amount: shares_to_sell) * Constants.partial_exemption).round(2)

      amount_to_sell_over_allowance += shares_to_sell
      goal_profit_next_purchase -= profit
      profit_over_allowance += profit

      break if p.shares_sold < p.amount
    end

    { amount_to_sell_over_allowance:, profit_over_allowance: }
  end

  def last_sold_purchase(purchases)
    purchases[purchases.rindex { |p| p.shares_sold.positive? }]
  end

  def data_service
    @data_service ||= DataService.new
  end
end
