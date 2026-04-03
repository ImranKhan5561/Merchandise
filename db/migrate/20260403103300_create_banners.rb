class CreateBanners < ActiveRecord::Migration[8.1]
  def change
    create_table :banners do |t|
      t.string :title, null: false
      t.string :subtitle
      t.string :badge_text
      t.text :description
      t.string :button_text, default: "Discover Collection"
      t.string :button_link, default: "/browse"
      t.string :image_url, null: false
      t.integer :position, default: 0
      t.boolean :active, default: true
      t.string :text_align, default: "left" # left, center, right

      t.timestamps
    end
    add_index :banners, :active
    add_index :banners, :position
  end
end
