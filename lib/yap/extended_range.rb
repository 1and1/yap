module Yap
  class ExtendedRange < Range
    def begin
      infinity_or_do_not_change super
    end

    def end
      infinity_or_do_not_change super
    end

    def infinity_or_do_not_change(value)
      if value.is_a? StringInfinity
        if value == String::INFINITY
          Float::INFINITY
        elsif value == -String::INFINITY
          -Float::INFINITY
        else
          raise ArgumentError, "Invalid value for StringInfinity."
        end
      else
        value
      end
    end
  end
end
