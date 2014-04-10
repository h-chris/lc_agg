class CreateRedditPosts < ActiveRecord::Migration
  def change
    create_table :reddit_posts do |t|
      t.string :title
      t.string :author
      t.string :url
      t.string :subreddit
      t.string :permalink
      t.string :is_self
      t.string :posted_at
      t.string :thumbnail
      t.string :domain
      t.string :name

      t.timestamps
    end
  end
end
