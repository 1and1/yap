require 'active_support/concern'
require 'exceptions'

##
# Include into model to have Model.filter available
#
# TODO need doc
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
