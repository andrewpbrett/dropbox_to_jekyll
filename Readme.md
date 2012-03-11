## Dropbox to Jekyll

This is a little script I wrote that will ping your "/Public/Photos" folder on dropbox and import any photos it finds as posts with the "photo" layout into your [Jekyll](https://github.com/mojombo/jekyll) blog. 

You can set it to ping once/minute (1440 times/day) and still be well under the rate limit of 5000/day. 

It will even push to Github for you! Take a look at [my Jekyll install](http://andybrett.com/photos)'s photos page for an example. To add a photo there, I can just drop it in "Public/Photos" from the Dropbox mobile app, and cron will pick it up within a minute and publish. 

Right now it's fairly customized for my setup, but feel free to modify/hack it to your purposes. MIT license. 

### Dependencies

The script assumes you have redis running and that the 'dropbox' namespace is empty.

Gems:
- git
- redis
- redis-namespace
- dropbox_sdk

You'll also need a dropbox account (obviously).

### Instructions

- Install redis
- Install the aformentioned gems
- Create a [Dropbox app](https://www.dropbox.com/developers/apps)
- `git clone https://github.com/andrewpbrett/dropbox_to_jekyll.git`
- Create a config.yml as follows:

    app_key: YOUR_APP_KEY 
    app_secret: YOUR_APP_SECRET 
    access_token_key: YOUR_ACCESS_TOKEN_KEY 
    access_token_secret: YOUR_ACCESS_TOKEN_SECRET 
    jekyll_path: PATH_TO_YOUR_JEKYLL_INSTALL 

- `ruby import.rb`
