class ChangeIsSelfInRedditPostsTable < ActiveRecord::Migration
  def self.up
    add_column :reddit_posts, :is_self, :boolean
  end
end
