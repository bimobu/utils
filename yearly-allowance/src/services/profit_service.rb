# frozen_string_literal: true

# Handles calculation for goal_profits
class ProfitService
  def reach_goal_profit(goal_profit) # rubocop:disable Metrics/MethodLength
    portfolio = data_service.load_portfolio
    security = portfolio.securities.first
    purchases = security.purchases

    maximize_goal_profit(purchases:, sell_price: security.share_price_end_of_year, goal_profit:) => {
      amount_to_sell_over_goal_profit:,
      profit_over_goal_profit:
    }

    last_sold_purchase = last_sold_purchase(purchases)
    profit_per_share = last_sold_purchase.profit_per_share(sell_price: security.share_price_end_of_year)
    profit_under_goal_profit = (profit_over_goal_profit - profit_per_share).round(2)
    amount_to_sell_under_goal_profit = amount_to_sell_over_goal_profit - 1

    {
      amount_to_sell_over_goal_profit:,
      profit_over_goal_profit:,
      amount_to_sell_under_goal_profit:,
      profit_under_goal_profit:,
      portfolio:,
      ticker: security.id
    }
  end

  private

  def maximize_goal_profit(purchases:, sell_price:, goal_profit:) # rubocop:disable Metrics/MethodLength
    goal_profit_next_purchase = goal_profit
    amount_to_sell_over_goal_profit = 0
    profit_over_goal_profit = 0

    purchases.each do |p|
      break if goal_profit_next_purchase.negative?
      next if p.amount <= p.shares_sold

      shares_to_sell = p.shares_to_sell(
        sell_price:,
        goal_profit: goal_profit_next_purchase
      )
      p.shares_sold += shares_to_sell
      profit = p.realized_profit(sell_price:, amount: shares_to_sell)

      amount_to_sell_over_goal_profit += shares_to_sell
      goal_profit_next_purchase -= profit
      profit_over_goal_profit += profit

      break if p.shares_sold < p.amount
    end

    { amount_to_sell_over_goal_profit:, profit_over_goal_profit: }
  end

  def last_sold_purchase(purchases)
    purchases[purchases.rindex { |p| p.shares_sold.positive? }]
  end

  def data_service
    @data_service ||= DataService.new
  end
end
