class CreateInstagramItems < ActiveRecord::Migration
  def change
    create_table :instagram_items do |t|
      t.string :instagram_id, null: false
      t.datetime :created_time, null: false
      t.string :username, null: false
      t.string :user_id, null: false
      t.string :link, null: false
      t.string :path, null: false
      t.float :latitude, null: false
      t.float :longitude, null: false
      t.float :distance_from_center_in_meters, null: false
      t.string :instagram_type, null: false
      t.string :filter

      t.text :full_data, null: false
      t.timestamps null: false
    end

    add_index :instagram_items, :instagram_id, unique: true
    add_index :instagram_items, :path
    add_index :instagram_items, :created_time
    add_index :instagram_items, [:distance_from_center_in_meters, :created_time], name: 'index_on_distance_and_created'
    add_index :instagram_items, [:latitude, :longitude]
  end
end
