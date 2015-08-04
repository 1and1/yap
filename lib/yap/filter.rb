module Yap
  class Filter < Hash
    def initialize
      self[:where] = {}
      self[:not] = {}
    end

    def parse!(column, values)
      values.to_s.split(',').each do |value|
        # Perform negative match if value starts with '!'.
        if value =~/^!(.+)$/
          match = :not
          value = $1
        else
          match = :where
        end

        case value
        when /([<>]=?)(.+)/
          match, value = handle_comparison_operators(match, column, $1.to_sym, $2)
        when /(.+)\.{3}(.+)/
          value = $1...$2
        when /(.+)\.{2}(.+)/
          value = $1..$2
        else
          # Convert null to ruby nil to use 'IS NULL' in SQL.
          value = value.downcase == 'null' ? nil : value
        end

        # Ensure filter contains an array to append to.
        self[match][column] ||= []

        self[match][column] << value
      end
    end

    private

    def handle_comparison_operators(match, column, operator, value)
      # TODO make comparison operators work for String. See here: http://c4se.hatenablog.com/entry/2013/10/01/010305
      value = Float(value) rescue raise(Yap::FilterError, 'You can only use float values with comparison operators <, >, <= and >=.')

      case operator
      when :<
        handle_comparison_operators(toggle_match(match), column, :>=, value)
      when :>
        handle_comparison_operators(toggle_match(match), column, :<=, value)
      when :<=
        return match, -Float::INFINITY..value.to_f
      when :>=
        return match, value.to_f..Float::INFINITY
      end
    end

    def toggle_match(match)
      match == :where ? :not : :where
    end
  end
end
