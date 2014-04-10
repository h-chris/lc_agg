class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :screen_name
      t.string :name
      t.string :tweeted_at
      t.string :id_str
      t.string :retweeted_status
      t.string :profile_image_url
      t.text :text

      t.timestamps
    end
  end
end
