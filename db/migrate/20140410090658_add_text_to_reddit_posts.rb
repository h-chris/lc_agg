class AddTextToRedditPosts < ActiveRecord::Migration
  def change
    add_column :reddit_posts, :text, :text
  end
end
