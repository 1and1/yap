module ColumnMapper
  private

  def map_column(name)
    column_names.include?(name) ? name : if respond_to? :map_name_to_column
      map_name_to_column(name)
    else
      warn "#{self.name} does not implement map_name_to_column. If you do not need column mapping set disable_warnings=true" unless Yap::DEFAULTS.disable_warnings
      nil
    end
  end
end