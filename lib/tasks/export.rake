namespace :export do
  desc "Prints RedditPost.first and Tweet.first in seeds.rb."
  task :seeds_format => :environment do
    puts "RedditPost.create(#{RedditPost.first.serializable_hash.delete_if {|key, value| ['id',  'created_at', 'updated_at'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    puts "Tweet.create(#{Tweet.first.serializable_hash.delete_if {|key, value| ['id',  'created_at', 'updated_at'].include?(key)}.to_s.gsub(/[{}]/,'')})"
  end
end
