require 'active_support/concern'

##
# Include into model to make it paginatable. The paginate scope takes a hash as only parameter. All options are optional
# and can be combined arbitrarily.
#
#   User.paginate         # => Page 1 with default order and size.
#   User.paginate(params) # => Use this in controller to pass query parameters.
#   User.paginate(
#       page:       1,
#       per_page:   10,
#       sort:       :id,
#       direction:  :asc
#   )                     # => Invocation with custom options.
#
# @param [Hash] the parameters used for pagination (:page, :per_page, :sort, :direction)
#
module Yap
  extend ActiveSupport::Concern

  DEFAULTS = Struct.new(:page, :per_page, :sort, :direction)
                 .new(1, 10, :id, :asc)

  def self.configure
    raise ArgumentError, 'No block given.' unless block_given?
    yield(DEFAULTS)
  end

  included do
    extend ClassMethods

    scope :paginate, -> (params = {}) {
      page, per_page, sort, direction = extract_pagination_params(params)
      limit(per_page).offset((page-1)*per_page).order(sort => direction)
    }

    private

    def self.extract_pagination_params(params)
      page = extract_number(params[:page], DEFAULTS.page)
      per_page = extract_number(params[:per_page], DEFAULTS.per_page)
      sort = extract_sort(params[:sort])
      direction = extract_direction(params[:direction])

      return page, per_page, sort, direction
    end

    def self.extract_number(number, default)
      begin
        number = number.present? ? Integer(number) : default
      rescue
        raise PaginationError.new("'#{number}' is not a valid number.")
      end

      raise PaginationError.new('Only positive numbers are accepted.') unless number > 0
      number
    end

    def self.extract_sort(sort)
      sort = sort.present? ? sort : DEFAULTS.sort
      raise PaginationError.new("Cannot sort by '#{sort}'.") unless column_names.include? sort.to_s
      sort
    end

    def self.extract_direction(direction)
      dir = direction.present? ? direction.downcase.to_sym : DEFAULTS.direction
      raise PaginationError.new("'#{direction}' is not a valid direction. Use 'asc' or 'desc'.") unless [:asc, :desc].include? dir
      dir
    end
  end

  module ClassMethods
    def last_page(params)
      per_page = extract_number(params[:per_page], DEFAULTS.per_page)
      (count / per_page.to_f).ceil
    end
  end

  class PaginationError < StandardError; end
end
