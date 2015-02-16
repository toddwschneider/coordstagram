# Coordstagram

Coordstagram is a simple Ruby on Rails application that uses the Instagram API to fetch, store, and view photos and videos that were taken near a user-specified latitude and longitude

For example, [here's a demo coordstagram app](http://gowanus.herokuapp.com/) that collects and displays all public Instagrams taken within 600 meters of the Gowanus Canal in Brooklyn. There are more [user-contributed examples](https://github.com/toddwschneider/coordstagram/wiki/examples) in the wiki (please add your own!)

If configured properly, you can host your own coordstagram app on Heroku at little to no monthly cost

<a href="https://heroku.com/deploy?template=https://github.com/toddwschneider/coordstagram"><img src="https://camo.githubusercontent.com/83b0e95b38892b49184e07ad572c94c8038323fb/68747470733a2f2f7777772e6865726f6b7563646e2e636f6d2f6465706c6f792f627574746f6e2e737667" alt="Deploy" data-canonical-src="https://www.herokucdn.com/deploy/button.svg" style="max-width:100%;"></a>

### Getting started

There are 4 config variables you have to set to make the app work:

1. `LATITUDE`
2. `LONGITUDE`
3. `MAX_DISTANCE_IN_METERS`
4. `INSTAGRAM_CLIENT_ID`

You can convert an address to latitude and longitude at [latlong.net](http://www.latlong.net/convert-address-to-lat-long.html) or [Google Maps](https://www.google.com/maps). If you use Google Maps, you'll need to copy/paste the coordinates from the URL bar:

![](http://i.imgur.com/nlqHrHF.png)

The config variable `MAX_DISTANCE_IN_METERS` determines the search radius from your coordinates when looking for Instagram media. Instagram lets you search a radius of up to 5,000 meters, but for many coordinates, especially in crowded cities, you'll get better results if you choose a lower value, maybe in the neighborhood of 50 to 100 meters

You'll need to register you app with Instagram in order to get an `INSTAGRAM_CLIENT_ID`:

- Head to [Instagram's developer website](http://instagram.com/developer) and sign in with your normal Instagram credentials
- Click the **Register Your Application** button
- Click the **Register a New Client** button
- Fill out the form. Leave the checkboxes in their default states. Enter `http://localhost` for the OAuth redirect_uri
- The Client ID is all you need, you can ignore the Client Secret

### Deploy on Heroku (for free!**)

Click the button below to get started:

<a href="https://heroku.com/deploy?template=https://github.com/toddwschneider/coordstagram"><img src="https://camo.githubusercontent.com/83b0e95b38892b49184e07ad572c94c8038323fb/68747470733a2f2f7777772e6865726f6b7563646e2e636f6d2f6465706c6f792f627574746f6e2e737667" alt="Deploy" data-canonical-src="https://www.herokucdn.com/deploy/button.svg" style="max-width:100%;"></a>

Or if you'd rather deploy manually (replace the config vars below with your own values!):

```
git clone git@github.com:toddwschneider/coordstagram.git
cd coordstagram
heroku apps:create your-app-name-here
heroku addons:add memcachier:dev
heroku addons:add newrelic:stark
heroku addons:add scheduler:standard
git push heroku master
heroku run rake db:migrate
heroku config:set LATITUDE=48.85837 LONGITUDE=2.294481 MAX_DISTANCE_IN_METERS=100 INSTAGRAM_CLIENT_ID="your instagram client id"
heroku run rake initial_backfill
```

**After you've deployed, either via the button or manually,** you might want to use the Heroku scheduler to get new items periodically. Run `heroku addons:open scheduler`, then create a new `rake get_new_items` task to run every day, hour, or 10 minutes: ![](http://i.imgur.com/fV0G14t.png)

** **free-ness not guaranteed!** Heroku's current pricing gives you 750 free dyno hours per month. You'll have 1 web dyno running at all times, so in a month with 31 days that leaves 750 - (31 * 24) = 6 hours = 360 minutes of free time to run the `rake get_new_items` task using Heroku's scheduler. If you run the rake task every hour, then it will run a total of 31 * 24 = 746 times in a month. As long as the rake task averages less than 29 seconds to finish, you won't receive any overage charges.

On the other hand, if you set your coordinates to somewhere very popular and you specify a large search distance, your rake job *might* average more than 29 seconds, which could result in a Heroku bill at the end of the month. The calculation changes a bit if you want to run the scheduler every 10 minutes, or only once per day, but that is left as an exercise for the reader...

### Development environment setup

```
git clone git@github.com:toddwschneider/coordstagram.git
cd coordstagram
createdb coordstagram_development
bundle install
rake db:migrate
```

Create a file called `.env` in your project's root directory, open it with your text editor, and make it look something like this (substituting your own values of course):

![](http://i.imgur.com/1zTnqls.png)

Then run:

```
rake initial_backfill
rails server
```

### Optional config variables

- `NAME_OF_SITE` default is "Coordstagram"
- `GOOGLE_ANALYTICS_TRACKING_ID` if you want to track visitors
- `MAX_PAGES_TO_FETCH_PER_UPDATE` default is 10. One page of Instagram results contains 20 photos/videos
- `PAGES_TO_FETCH_FOR_INITIAL_BACKFILL` default is 20

### Screenshots

Scroll photos:

![](http://i.imgur.com/dnveBEK.png)

Click to open larger version in modal, and see photo location on map:

![](http://i.imgur.com/FsZIoSW.png)

Responsive modal for tablets and phones:

![](http://i.imgur.com/oVcosOz.png)
