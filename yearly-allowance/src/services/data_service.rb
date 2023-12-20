# frozen_string_literal: true

require 'debug'

require_relative '../data_classes/portfolio'

# Responsible for reading from and writing to the data file
class DataService
  def load_portfolio
    Portfolio.create(read_data_hash)
  end

  def save_portfolio(portfolio)
    write_data_hash(portfolio.to_hash)
  end

  private

  def read_data_hash
    file = File.read(data_file)
    JSON.parse(file)
  end

  def write_data_hash(data_hash)
    File.write(data_file, JSON.pretty_generate(data_hash))
  end

  def data_file
    "#{__dir__.split('/')[..-3].join('/')}/data/portfolio.json"
  end
end
