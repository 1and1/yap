require 'yap/filter_value'

module Yap
  ##
  # Multiple filter for a column can be separated by comma (,).
  #
  class FilterColumn
    attr_reader :name

    def initialize(name)
      @name = name
      @values = []
    end

    def parse_values(values)
      values.to_s.split(',').each do |value|
        filter_value = FilterValue.new
        filter_value.parse_value(value)
        @values << filter_value
      end
    end

    def where
      @values.select do |v|
        v.condition == :where
      end.map(&:value)
    end

    def not
      @values.select do |v|
        v.condition == :not
      end.map(&:value)
    end
  end
end
