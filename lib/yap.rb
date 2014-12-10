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
#       sort:       'id',
#       direction   :asc
#   )                     # => Invocation with default options.
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
    scope :paginate, -> (params = {}) {
      page, per_page, sort, direction = extract_pagination_params(params)
      limit(per_page).offset((page-1)*per_page).order(sort => direction)
    }

    private

    def self.extract_pagination_params(params)
      page = params[:page].present? ? extract_number(params[:page]) : DEFAULTS.page
      per_page = params[:per_page].present? ? extract_number(params[:per_page]) : DEFAULTS.per_page
      sort = params[:sort].present? ? extract_sort(params[:sort]) : DEFAULTS.sort
      direction = params[:direction].present? ? extract_direction(params[:direction]) : DEFAULTS.direction

      return page, per_page, sort, direction
    end

    def self.extract_number(number)
      begin
        number = Integer(number)
      rescue
        raise PaginationError.new("'#{number}' is not a valid number.")
      end

      raise PaginationError.new('Only positive numbers are accepted.') unless number > 0
      number
    end

    def self.extract_sort(sort)
      raise PaginationError.new("Cannot sort by '#{sort}'.") unless column_names.include? sort.to_s
      sort
    end

    def self.extract_direction(direction)
      dir = direction.downcase.to_sym
      raise PaginationError.new("'#{direction}' is not a valid direction. Use 'asc' or 'desc'.") unless [:asc, :desc].include? dir
      dir
    end
  end

  class PaginationError < StandardError; end
end
