# frozen_string_literal: true

# The base class that the others inherit from
class Base
  def to_hash
    hash = {}

    instance_variables.each do |var|
      value = instance_variable_get(var)
      value = value.to_hash if value.respond_to?(:to_hash)
      value = value.map(&:to_hash) if value.respond_to?(:[]) && value[0].respond_to?(:to_hash)
      hash[var.to_s.delete('@')] = value
    end

    hash
  end
end
