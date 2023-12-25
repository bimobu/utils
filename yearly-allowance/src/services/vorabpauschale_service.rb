# frozen_string_literal: true

require 'debug'

require_relative '../constants'

# Responsible of calculating the Vorabpauschale
class VorabpauschaleService
  def calculate_vorabpauschale(base_interest)
    portfolio = data_service.load_portfolio

    portfolio.securities.sum do |security|
      security.purchases.sum do |purchase|
        vorabpauschale_of_purchase(security, purchase, base_interest)
      end
    end
  end

  def vorabpauschale_of_purchase(security, purchase, base_interest) # rubocop:disable Metrics/AbcSize
    months_remaining = 12 - purchase.date.month + 1
    value_start_of_year = purchase.amount * security.share_price_start_of_year
    value_end_of_year = purchase.amount * security.share_price_end_of_year
    appreciation = value_end_of_year - value_start_of_year
    base_yield = value_start_of_year * base_interest * Constants.partial_exemption
    ([appreciation, base_yield].min * (months_remaining / 12.0)).round(2)
  end

  private

  def data_service
    @data_service ||= DataService.new
  end
end
