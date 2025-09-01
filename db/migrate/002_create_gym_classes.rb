class CreateGymClasses < ActiveRecord::Migration[6.1]
  def change
    create_table :gym_classes do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.integer :duration, null: false
      t.integer :capacity, null: false
      t.integer :enrolled_count, default: 0
      t.datetime :schedule_time, null: false
      t.references :instructor, null: false, foreign_key: true
      
      t.timestamps
    end
    
    add_index :gym_classes, :schedule_time
  end
end