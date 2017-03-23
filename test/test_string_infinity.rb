require 'test_helper'

class TestStringInfinity < ActiveSupport::TestCase
  def test_should_be_equal
    assert String::INFINITY == String::INFINITY
  end

  def test_should_not_be_equal_negative
    assert_not String::INFINITY == String::INFINITY_NEGATIVE
  end

  def test_should_not_be_equal_string
    assert_not String::INFINITY == 'string'
  end
end
