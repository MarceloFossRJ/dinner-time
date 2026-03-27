class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.string :title, null: false
      t.string :category
      t.integer :cook_time, default: 0
      t.integer :prep_time, default: 0
      t.integer :total_time, default: 0
      t.decimal :ratings, precision: 3, scale: 2
      t.string :author
      t.text :image_url

      t.timestamps
    end

    add_index :recipes, :category
    add_index :recipes, :total_time
  end
end
