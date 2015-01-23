module Yap
  class Filter < Hash
    def initialize
      self[:where] = {}
      self[:not] = {}
    end

    def parse!(column, values)
      values.to_s.split(',').each do |value|
        # Perform negative match if value starts with '!'.
        if value =~/^!(.+)$/
          match = :not
          value = $1
        else
          match = :where
        end

        if value =~ /(.+)\.\.(.+)/
          value = $1..$2
        else
          value = value.downcase == 'null' ? nil : value
        end

        # Ensure filter contains an array to append to.
        self[match][column] ||= []

        # Convert null to ruby nil to use 'IS NULL' in SQL.
        self[match][column] << value
      end
    end
  end
end
