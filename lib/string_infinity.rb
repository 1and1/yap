class StringInfinity < String
  def -@
    String::INFINITY_NEGATIVE
  end

  def ==(other)
    self.class == other.class
  end
end

class StringInfinityNegative < StringInfinity; end

String::INFINITY = StringInfinity.new
String::INFINITY_NEGATIVE = StringInfinityNegative.new
