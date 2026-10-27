class AddWeightToViolations < ActiveRecord::Migration[4.2]
  def change
    add_column :ensnare_violations, :weight, :integer
  end
end
