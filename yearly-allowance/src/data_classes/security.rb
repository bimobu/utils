# frozen_string_literal: true

require_relative 'purchase'
require_relative 'base'

# Represents a security
class Security < Base
  attr_accessor :id, :share_price_start_of_year, :share_price_end_of_year, :purchases

  def self.create(security_hash)
    Security.new(
      id: security_hash['id'],
      share_price_start_of_year: security_hash['share_price_start_of_year'],
      share_price_end_of_year: security_hash['share_price_end_of_year'], # also being used as the current price
      purchases: security_hash['purchases'].map { |p| Purchase.create(p) }
    )
  end

  def initialize(id:, share_price_start_of_year:, share_price_end_of_year:, purchases:)
    super()
    @id = id
    @share_price_start_of_year = share_price_start_of_year
    @share_price_end_of_year = share_price_end_of_year
    @purchases = purchases
  end

  def purchase_value
    purchases.sum(&:buy_value).round(2)
  end

  def year_end_value
    purchases.sum { |p| p.sell_value(sell_price: share_price_end_of_year) }.round(2)
  end

  def realized_profit
    purchases.sum do |p|
      p.realized_profit(sell_price: share_price_end_of_year)
    end.round(2)
  end

  def overall_profit
    purchases.sum { |p| p.profit(sell_price: share_price_end_of_year) }.round(2)
  end
end
