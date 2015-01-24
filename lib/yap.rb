require 'active_support/concern'
require 'yap/exceptions'
require 'yap/column_mapper'
require 'yap/filterable'

##
# Support for Active Record pagination. All options can be safely accessed by the user through url query parameters. To
# get the number of the last page call the last_page method with the same parameters as the pagination.
#
#   User.paginate           # => Page 1 with default order and size.
#   User.paginate(params)   # => Passing parameters in controller.
#   User.paginate(
#       page:       1,
#       per_page:   10,
#       sort:       :id,
#       direction:  :asc
#   )                       # => Invocation with custom options.
#
#   User.last_page          # => Last page as a number for defaults
#   User.last_page(params)  # => Last page for given params. Works the same way as paginate.
#
# @see Filterable Filter results by attributes.
#
module Yap
  extend ActiveSupport::Concern
  include Filterable

  DEFAULTS = Struct.new(:page, :per_page, :sort, :direction, :disable_warnings)
                 .new(1, 10, 'id', 'ASC', false)

  def self.configure
    raise ArgumentError, 'No block given.' unless block_given?
    yield(DEFAULTS)
  end

  module ClassMethods
    def last_page(params)
      per_page = extract_number(params[:per_page], DEFAULTS.per_page)
      (filter(params[:filter]).count / per_page.to_f).ceil
    end
  end

  included do
    extend ClassMethods
    extend ColumnMapper

    ##
    # The paginate scope takes a hash as parameter. All options are optional and can be combined arbitrarily.
    #
    # @param [Hash] The parameters used for pagination (:page, :per_page, :sort, :direction)
    #
    scope :paginate, -> (params = {}) {
      page, per_page, order_by = extract_pagination_params(params)
      filter(params[:filter]).limit(per_page).offset((page-1)*per_page).order(order_by)
    }

    private

    def self.extract_pagination_params(params)
      page = extract_number(params[:page], DEFAULTS.page)
      per_page = extract_number(params[:per_page], DEFAULTS.per_page)
      sort = extract_column(params[:sort])
      direction = extract_direction(params[:direction])

      return page, per_page, (sort =~ /\./ ? "#{sort} #{direction}" : { sort => direction })
    end

    def self.extract_number(number, default)
      number ||= default
      begin
        number = Integer(number)
      rescue
        raise PaginationError.new("'#{number}' is not a valid number.")
      end

      raise PaginationError.new('Only positive numbers are accepted.') unless number > 0
      number
    end

    def self.extract_column(sort)
      sort ||= DEFAULTS.sort
      column = map_column(sort.to_s.downcase)
      raise PaginationError.new("Cannot sort by '#{sort}'.") unless column
      column
    end

    def self.extract_direction(direction)
      direction ||= DEFAULTS.direction
      dir = (direction).to_s.upcase
      raise PaginationError.new("'#{direction}' is not a valid direction. Use 'asc' or 'desc'.") unless %w[ASC DESC].include? dir
      dir
    end
  end
end
