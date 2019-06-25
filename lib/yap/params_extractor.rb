require 'yap/column_mapper'

module Yap
  ##
  # Methods for extracting valid pagination parameters from rails params.
  #
  module ParamsExtractor
    def extract_pagination_params(params)
      page = extract_page(params)
      per_page = extract_per_page(params)
      sort = extract_order(params)

      [page, per_page, sort]
    end

    def extract_page(params)
      extract_number(params[:page], DEFAULTS.page)
    end

    def extract_per_page(params)
      per_page = extract_number(params[:per_page], DEFAULTS.per_page)

      if DEFAULTS.hard_limit && per_page > DEFAULTS.hard_limit
        raise PaginationError, "Not more than #{DEFAULTS.hard_limit} items per page accepted."
      end

      per_page
    end

    def extract_number(number, default)
      number ||= default
      begin
        number = Integer(number)
      rescue ArgumentError
        raise PaginationError, "'#{number}' is not a valid number."
      end

      raise PaginationError, 'Only positive numbers are accepted.' unless number > 0

      number
    end

    def extract_order(params)
      sort, direction = params.values_at(:sort, :direction)

      case sort
      when Array, String
        build_order_from_array(sort, direction)
      when Hash
        build_order_from_hash(sort)
      else # nil or symbol
        build_order sort, direction
      end
    end

    def build_order_from_array(sort, direction = [])
      sort = convert_to_array(sort)
      direction = convert_to_array(direction)
      order = []
      sort.each_with_index do |s, i|
        order << build_order(s, direction[i] || DEFAULTS.direction)
      end

      order
    end

    def convert_to_array(object)
      object = object.split(',') if object.is_a?(String)

      Array.wrap(object)
    end

    def build_order_from_hash(sort)
      sort.map do |s, d|
        build_order(s, d)
      end
    end

    def build_order(sort, direction)
      sort = extract_column(sort || DEFAULTS.sort)
      direction = extract_direction(direction)

      (sort =~ /\./ ? "#{sort} #{direction}" : { sort => direction })
    end

    def extract_column(sort)
      column = map_column(sort.to_s)
      raise PaginationError, "Cannot sort by '#{sort}'." unless column

      column
    end

    def extract_direction(direction)
      direction ||= DEFAULTS.direction
      dir = direction.to_sym.downcase
      unless %i[asc desc].include? dir
        raise PaginationError, "'#{direction}' is not a valid direction. Use 'asc' or 'desc'."
      end

      dir
    end
  end
end
