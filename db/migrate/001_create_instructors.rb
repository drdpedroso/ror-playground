class CreateInstructors < ActiveRecord::Migration[6.1]
  def change
    create_table :instructors do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :specialization, null: false
      t.text :bio
      t.string :phone
      
      t.timestamps
    end
    
    add_index :instructors, :email, unique: true
  end
end