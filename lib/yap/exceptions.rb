module Yap
  class YapError < StandardError; end
  class PaginationError < YapError; end
  class FilterError < YapError; end
end
