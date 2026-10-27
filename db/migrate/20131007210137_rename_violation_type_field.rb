class RenameViolationTypeField < ActiveRecord::Migration[4.2]
  def change
	rename_column :ensnare_violations, :type, :violation_type
  end

end
