module Yap
  ##
  # Extends Range by StringInfinity.
  #
  class ExtendedRange < Range
    def begin
      handle_infinity super
    end

    def end
      handle_infinity super
    end

    def handle_infinity(value)
      return value unless value.is_a? StringInfinity

      if value.is_a?(StringInfinityNegative)
        -Float::INFINITY
      else
        Float::INFINITY
      end
    end
  end
end
