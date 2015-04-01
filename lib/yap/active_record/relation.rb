module ActiveRecord
  class Relation
    def without_pagination
      rel = dup
      rel.limit! nil
      rel.offset! nil

      yield rel
    end

    def total
      @total ||= without_pagination { |rel| rel.count }
    end

    def last_page
      page = (total / limit_value.to_f).ceil

      page == 0 ? 1 : page
    end

    def range
      from = offset_value+1
      to = from+limit_value-1
      to = total if total < to

      {
          from: from,
          to: to,
          total: total
      }
    end
  end
end