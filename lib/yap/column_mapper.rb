module ColumnMapper
  attr_reader :_api_aliases
  def api_aliases(aliases = nil, &block)
    raise "Aliases already defined. Make sure to invoke #{__method__.to_s} only once." if @_api_aliases.present?

    if aliases.present?
      unless aliases.is_a? Hash
        raise ArgumentError, "Expected first argument to be of type Hash, got #{aliases.class.name}."
      end

      @_api_aliases = aliases.symbolize_keys
    end

    if block_given?
      if aliases.present?
        raise ArgumentError, 'Only one of the following allowed: Hash of aliases or block.'
      end

      @_api_aliases = block
    end
  end

  def map_column(name)
    actual_column = name if column_names.include?(name)

    column_alias = if _api_aliases.is_a? Hash
      _api_aliases[name.to_sym].to_s
    elsif _api_aliases.is_a? Proc
      _api_aliases.call(name).to_s
    end

    column_alias || actual_column
  end
end
