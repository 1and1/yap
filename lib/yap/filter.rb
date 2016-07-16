require 'yap/filter_column'

module Yap
  class Filter
    def initialize
      @failed = []
      @columns = []
    end

    def parse!(model, params)
      params.each do |attribute, values|
        parse_arrtibute(model, attribute, values)
      end

      raise FilterError, "Cannot filter by: #{@failed.join(', ')}" unless @failed.empty?
    end

    def where
      extract_filters(:where)
    end

    def not
      extract_filters(:not)
    end

    private

    def extract_filters(condition)
      @columns.inject({}) do |filter, column|
        values = column.send(condition)

        if values.empty?
          filter
        else
          filter.merge(column.name => values.size == 1 ? values.first : values)
        end
      end
    end

    def parse_arrtibute(model, attribute, values)
      column = model.map_column(attribute.to_s.downcase)
      if column.nil?
        @failed << attribute
        return
      end

      filter_column = FilterColumn.new(column)
      filter_column.parse_values(values)
      @columns << filter_column
    end
  end
end
