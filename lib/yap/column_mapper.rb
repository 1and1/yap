module ColumnMapper
  attr_reader :_api_aliases
  def api_aliases(aliases = nil, &block)
    raise "Aliases already defined. Make sure to invoke #{__method__} only once." if defined? @_api_aliases

    api_aliases_hash(aliases) if aliases.present?

    if block_given?
      raise ArgumentError, 'Only one of the following allowed: Hash of aliases or block.' if aliases.present?
      @_api_aliases = block
    end

    nil
  end

  def api_aliases_hash(aliases)
    unless aliases.is_a? Hash
      raise ArgumentError, "Expected first argument to be a Hash, got #{aliases.class.name}."
    end

    @_api_aliases = aliases.symbolize_keys

    nil
  end

  def map_column(name)
    actual_column = name if column_names.include?(name)

    column_alias = if _api_aliases.is_a? Hash
      _api_aliases[name.to_sym]
    elsif _api_aliases.is_a? Proc
      _api_aliases.call(name)
    end

    result = column_alias || actual_column
    return if result.blank?

    result.to_s
  end
end
