# frozen_string_literal: true

# Handles constants
class Constants
  class << self
    def partial_exemption
      @partial_exemption ||= ENV['PARTIAL_EXEMPTION'].to_f
    end
  end
end
