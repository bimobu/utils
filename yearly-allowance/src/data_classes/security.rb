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
      share_price_end_of_year: security_hash['share_price_end_of_year'],
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
end
