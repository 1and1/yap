require 'yap/extended_range'

module Yap
  class Filter < Hash
    def initialize
      self[:where] = {}
      self[:not] = {}
    end

    def parse!(column, values)
      values.to_s.split(',').each do |value|
        condition, value = parse_value(value)

        self[condition][column] ||= []
        self[condition][column] << value
      end
    end

    private

    def parse_value(value)
      # Perform negative match if value starts with '!'.
      if value =~/^!(.+)$/
        condition = :not
        value = $1
      else
        condition = :where
      end

      case value
      when /([<>]=?)(.+)/
        condition, value = handle_comparison_operators(condition, $1.to_sym, $2)
      when /(.+)\.{3}(.+)/
        value = $1...$2
      when /(.+)\.{2}(.+)/
        value = $1..$2
      else
        # Convert null to ruby nil to use 'IS NULL' in SQL.
        value = value.downcase == 'null' ? nil : value
      end

      [condition, value]
    end

    def handle_comparison_operators(condition, operator, value)
      case operator
      when :<
        handle_comparison_operators(toggle_condition(condition), :>=, value)
      when :>
        handle_comparison_operators(toggle_condition(condition), :<=, value)
      when :<=
        return condition, ExtendedRange.new(-String::INFINITY, value)
      when :>=
        return condition, ExtendedRange.new(value, String::INFINITY)
      end
    end

    def toggle_condition(condition)
      condition == :where ? :not : :where
    end
  end
end
