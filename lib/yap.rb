require 'active_support/concern'
require 'yap/exceptions'
require 'yap/filterable'

##
# Include into model to make it paginatable. The paginate scope takes a hash as parameter. All options are optional and
# can be combined arbitrarily.
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
# @param [Hash] the parameters used for pagination (:page, :per_page, :sort, :direction)
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

  included do
    extend ClassMethods

    scope :paginate, -> (params = {}) {
      page, per_page, column, direction = extract_pagination_params(params)
      filter(params[:filter]).limit(per_page).offset((page-1)*per_page).order("#{column} #{direction}")
    }

    private

    def self.extract_pagination_params(params)
      page = extract_number(params[:page], DEFAULTS.page)
      per_page = extract_number(params[:per_page], DEFAULTS.per_page)
      sort = extract_column(params[:sort])
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

    def self.extract_column(sort)
      column = map_column(sort.present? ? sort.to_s.downcase : DEFAULTS.sort)
      raise PaginationError.new("Cannot sort by '#{sort}'.") unless column
      column
    end

    def self.extract_direction(direction)
      dir = direction.present? ? direction.to_s.upcase : DEFAULTS.direction
      raise PaginationError.new("'#{direction}' is not a valid direction. Use 'asc' or 'desc'.") unless %w[ASC DESC].include? dir
      dir
    end

    private

    def self.map_column(name)
      begin
        map_name_to_column(name)
      rescue
        warn "#{self.name} does not implement map_name_to_column. If you do not need column mapping set disable_warnings=true" unless DEFAULTS.disable_warnings
        nil
      end || (column_names.include?(name) ? name : nil)
    end
  end

  module ClassMethods
    def last_page(params)
      per_page = extract_number(params[:per_page], DEFAULTS.per_page)
      (count / per_page.to_f).ceil
    end
  end
end
