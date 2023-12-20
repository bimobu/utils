# frozen_string_literal: true

require_relative 'base'

# Represents a Purchase of one security
class Purchase < Base
  attr_accessor :date, :buy_price, :amount, :shares_sold

  def self.create(purchase_hash)
    Purchase.new(
      date: Time.new(purchase_hash['date']),
      buy_price: purchase_hash['buy_price'],
      amount: purchase_hash['amount'],
      shares_sold: purchase_hash['shares_sold']
    )
  end

  def initialize(date:, buy_price:, amount:, shares_sold:)
    super()
    @date = date
    @buy_price = buy_price
    @amount = amount
    @shares_sold = shares_sold
  end

  def realized_profit(sell_price:)
    (sell_value(sell_price:, amount: @shares_sold) - buy_value(amount: shares_sold)).round(2)
  end

  def profit(sell_price:)
    (sell_value(sell_price:) - buy_value).round(2)
  end

  def buy_value(amount: @amount)
    @buy_price * amount
  end

  def sell_value(sell_price:, amount: @amount)
    sell_price * amount
  end

  def shares_to_sell(sell_price:, goal_profit:)
    shares_to_sell = goal_profit / profit_per_share(sell_price:)
    [@amount, shares_to_sell.ceil].min
    # ceil => always sell the share even if it exceeds the goal profit
    # round => sell the share if it exceeds the goal profit by less than 50% of its profit
    # floor => never sell the share even if it exceeds the goal profit
  end

  def profit_per_share(sell_price:)
    (sell_price - @buy_price).round 2
  end
end
