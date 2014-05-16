class CreateYoutubes < ActiveRecord::Migration
  def change
    create_table :youtubes do |t|
      t.string :title
      t.string :thumb
      t.string :url
      t.string :embed_id
      t.string :tags
      t.string :lesson
      t.text :description

      t.timestamps
    end
  end
end
