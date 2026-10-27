class CreateEnsnareViolations < ActiveRecord::Migration[4.2]
  def change
    create_table :ensnare_violations do |t|
      t.string :ip_address
      t.string :type

      t.timestamps
    end
  end
end
