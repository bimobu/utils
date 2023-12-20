# frozen_string_literal: true

require 'debug'
require_relative 'security'
require_relative 'base'

# Represents the whole Portfolio
class Portfolio < Base
  attr_accessor :securities

  def self.create(portfolio_hash)
    Portfolio.new(
      securities: portfolio_hash['securities'].map do |security_hash|
        Security.create(security_hash)
      end
    )
  end

  def initialize(securities:)
    super()
    @securities = securities
  end

  def security(id)
    @securities.find { |security| security.id == id }
  end
end
