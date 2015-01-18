module ColumnMapper
  private

  def map_column(name)
    begin
      map_name_to_column(name)
    rescue
      warn "#{self.name} does not implement map_name_to_column. If you do not need column mapping set disable_warnings=true" unless Yap::DEFAULTS.disable_warnings
      nil
    end || (column_names.include?(name) ? name : nil)
  end
end