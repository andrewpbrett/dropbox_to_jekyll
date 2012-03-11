require 'rubygems'
require 'dropbox_sdk'
require 'uri'
require 'git'
require 'redis'
require 'redis-namespace'
require 'fileutils'

redis = Redis.new
r = Redis::Namespace.new(:dropbox, :redis => redis)

config = YAML::load( File.open( File.join( File.dirname( __FILE__ ),'config.yml' ) ) )
app_key 	    = config['app_key']
app_secret 	    = config['app_secret']
access_token_key    = config['access_token_key']
access_token_secret = config['access_token_secret']

session = DropboxSession.new app_key, app_secret
session.set_access_token access_token_key, access_token_secret 
client = DropboxClient.new session, :dropbox

uid = client.account_info["uid"]
prefix = "/Public/Photos"
jekyll_path = config['jekyll_path']

begin
  photo_folder = client.metadata prefix, 10000, true, r.get("hash")

  r.set "hash", photo_folder["hash"]
  file_count = 0  
  photo_folder["contents"].each do |file|
    unless r.sismember("paths", file["path"]) or file["is_dir"]
      r.sadd "paths", file["path"]
      bits = client.thumbnail(URI.encode(file["path"]))
      open('thumb.jpg', 'w') { |f| f.puts bits }
      thumbnail = File.open 'thumb.jpg'
      client.put_file(file["path"].gsub("Photos/", "Photos/Thumbnails/"), thumbnail)
      FileUtils.rm('thumb.jpg')
      date_part = Date.parse(file["modified"]).strftime("%Y-%-m-%-d") + "-"
      path_part = file["path"].gsub(/#{prefix + "/"}/, "").downcase.gsub(/[^A-Za-z0-9]/, "-").gsub(/(\-)\1+/, '\1') + ".md"
      filename = date_part + path_part
      url = "http://dl.dropbox.com/u/#{uid.to_s + URI.encode(file["path"]).gsub("Public\/", "")}"
      f = File.open(filename, "w")
      f.write "---\n"
      f.write "layout: photo\n"
      f.write "source_url: #{url}\n"
      f.write "thumbnail_url: #{url.gsub("Photos/", "Photos/Thumbnails/")}\n"
      f.write "caption: \"\"\n"
      f.write "---\n"
      f.write "![](#{url})"
      f.close
      FileUtils.mv(f.path, jekyll_path + "_posts/")
      file_count += 1
    end
  end
  g = Git.open jekyll_path
  g.pull(g.remote('origin'))
  g.add '.'
  g.commit "imported #{file_count} photos from Dropbox public folder"
  g.push(g.remote('origin'))
rescue DropboxNotModified

  puts "not modified"

end
