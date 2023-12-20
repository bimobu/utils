# frozen_string_literal: true

# Handles calculation for allowances
class AllowanceService
  def find_max_allowance(allowance)
    portfolio = data_service.load_portfolio
    security = portfolio.securities.first
    purchases = security.purchases

    maximize_allowance(purchases:, sell_price: security.share_price_end_of_year, allowance:) => {
      amount_to_sell:,
      profit: profit_over_allowance
    }

    last_sold_purchase = last_sold_purchase(purchases)
    profit_under_allowance = (profit_over_allowance - last_sold_purchase.profit_per_share(sell_price: security.share_price_end_of_year)).round(2)

    { amount_to_sell:, profit_over_allowance:, profit_under_allowance:, portfolio:, ticker: security.id }
  end

  private

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

  def data_service
    @data_service ||= DataService.new
  end
end
