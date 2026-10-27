class AddNameToEnsnareViolation < ActiveRecord::Migration[4.2]
  def change
    add_column :ensnare_violations, :name, :string
  end
end
