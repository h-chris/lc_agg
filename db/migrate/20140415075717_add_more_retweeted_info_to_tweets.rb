class AddMoreRetweetedInfoToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :r_screen_name, :string
    add_column :tweets, :r_name, :string
    add_column :tweets, :r_profile_image_url, :string
  end
end
