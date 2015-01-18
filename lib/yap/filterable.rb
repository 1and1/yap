require 'active_support/concern'
require 'yap/exceptions'

##
# ActiveRecords can be filtered by their attributes if either Yap or Filterable is included into the model. Filters can
# be applied through the filter or paginate scope. Multiple filters for the same attribute can be separated by comma,
# negative filters have a leading exclamation mark (!) and 'null' will be translated to the NULL value.
#
#   User.filter('gender' => 'f')        # => All female users.
#   User.filter(
#       'team_id' => '1,2',
#       'gender' => 'm'
#   )                                   # => All males of teams 1 and 2.
#   User.filter('team_id' => '!null')   # => All users with any team.
#   User.paginate(params)               # => Passing parameters in controller (http://localhost/users?filter[gender]=f)
#   User.paginate(
#       page:   1,
#       filter: { 'team' => 'null' }
#   )                                    # => Combining filter and pagination.
#
# @param [Hash] attribute/value pairs to filter ( { 'gender' => 'f' } )
#
module Yap
  module Filterable
    extend ActiveSupport::Concern

    included do
      scope :filter, -> (params = nil) {
        if params.blank?
          all
        else
          filter = extract_filter_params(params)
          where(filter[:where]).where.not(filter[:not])
        end
      }

      private

      def self.extract_filter_params(params)
        filter = {
            where: {},
            not: {}
        }

        failed = []
        params.each do |key, values|
          # TODO Add mapping support
          failed << key unless column_names.include? key.to_s
          values.to_s.split(',').each do |value|
            # Perform negative match if value starts with '!'.
            if value =~/^!(.+)$/
              match = :not
              value = $1
            else
              match = :where
            end

            # Ensure filter contains an array to append to.
            filter[match][key] ||= []

            # Convert null to ruby nil to use 'IS NULL' in SQL.
            filter[match][key] << (value.downcase == 'null' ? nil : value)
          end
        end

        raise FilterError.new('Cannot filter by: ' + failed.join(', ')) unless failed.empty?

        filter
      end
    end
  end
end
