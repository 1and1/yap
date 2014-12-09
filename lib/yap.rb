class Yap
  DEFAULTS = Struct.new(:page, :per_page, :sort, :direction)
                 .new(1, 10, :id, :asc)

  def self.configure
    raise 'No block given.' unless block_given?
    yield(DEFAULTS)
  end
end