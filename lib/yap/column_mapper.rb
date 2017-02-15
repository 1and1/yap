module ColumnMapper
  def map_column(name)
    actual_column = name if column_names.include?(name)

    column_alias = if respond_to? :map_name_to_column
      map_name_to_column(name)
    elsif actual_column.nil? && !Yap::DEFAULTS.disable_warnings
      warn "#{self.name} does not implement map_name_to_column. If you do not need column mapping set " \
          'disable_warnings=true'
    end

    column_alias || actual_column
  end
end
