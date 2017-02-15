module ActiveRecord
  class Relation
    ##
    # Access the relation without pagination in a block. Limit and offset values are removed, filters still apply.
    #
    # @return [Object] Return value of the block
    #
    def without_pagination
      rel = dup
      rel.limit! nil
      rel.offset! nil

      yield rel
    end

    ##
    # Returns the total number of results without pagination. This is used for generating range and last_page values.
    # The result for a relation is cached because count can be quite expensive.
    #
    # @return [Integer] Total number of results
    #
    def total
      @total ||= without_pagination(&:count)
    end

    ##
    # Calculates the last page for paginated results.
    #
    # @return [Integer] Last page as a number
    #
    def last_page
      page = (total / limit_value.to_f).ceil

      page == 0 ? 1 : page
    end

    ##
    # Returns a hash defining a range with :from, :to and optionally :total. Note that querying the total count requires
    # an extra query to be executed.
    #
    # @param [Boolean] include_total Include total value
    # @return [Hash] Values defining the range of the current page.
    #
    def range(include_total = false)
      from = offset_value + 1
      to = offset_value + limit_value
      to = total if total < to && include_total

      range = { from: from, to: to }
      return range unless include_total

      range.merge(total: total)
    end
  end
end
