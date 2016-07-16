require 'yap/extended_range'

module Yap
  ##
  # Filter values can have the following formats:
  #
  #  * Integer - e.g. 100
  #  * String - e.g. text
  #  * Comparisons - e.g. >10, <=B
  #  * Dates - e.g. 1970-01-01 (depends on the database backend)
  #  * Ranges - e.g. 1...2, Jones..Smith
  #  * NULL -  e.g. NULL, null, Null
  #  * Negation - e.g. !value, !1..10
  #
  class FilterValue
    OPERATOR_INVERSION_MAP = { :< => :>=, :> => :<= }.freeze

    attr_reader :condition, :value

    def parse_value(value)
      value = handle_negation(value)

      @value = case value
      when /([<>]=?)(.+)/
        handle_comparison_operators($1.to_sym, $2)
      when /(.+)(\.{2,3})(.+)/
        Range.new $1, $3, $2 == '...'
      else
        handle_null(value)
      end
    end

    private

    def handle_negation(value)
      if value =~ /^!(.+)$/
        @condition = :not
        value = $1
      else
        @condition = :where
      end

      value
    end

    def handle_comparison_operators(operator, value)
      case operator
      when :<, :> then invert_comparison_operator(operator, value)
      when :<= then ExtendedRange.new(-String::INFINITY, value)
      when :>= then ExtendedRange.new(value, String::INFINITY)
      end
    end

    def invert_comparison_operator(operator, value)
      toggle_condition!
      handle_comparison_operators(OPERATOR_INVERSION_MAP[operator], value)
    end

    def toggle_condition!
      @condition = @condition == :where ? :not : :where
    end

    def handle_null(value)
      value.casecmp('null').zero? ? nil : value
    end
  end
end
