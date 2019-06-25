require 'active_support/concern'
require 'yap/active_record/relation'
require 'yap/params_extractor'
require 'yap/filterable'
require 'yap/exceptions'
require 'string_infinity'

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

  DEFAULTS = Struct.new(:page, :per_page, :hard_limit, :sort, :direction, :disable_warnings)
    .new(1, 10, nil, :id, :asc, false)

  def self.configure
    raise ArgumentError, 'No block given.' unless block_given?

    yield(DEFAULTS)
  end

  def self.configuration
    DEFAULTS.dup
  end

  included do
    extend ParamsExtractor

    ##
    # The paginate scope takes a hash as parameter. All options are optional and can be combined arbitrarily.
    #
    # @param [Hash] params The parameters used for pagination (:page, :per_page, :sort, :direction, :filter)
    #
    scope :paginate, lambda { |params = {}|
      page, per_page, order_by = extract_pagination_params(params)
      filtered(params[:filter]).limit(per_page).offset((page - 1) * per_page).order(order_by)
    }
  end
end
