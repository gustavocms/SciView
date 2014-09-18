# SciView

## Local Environment Setup

### Prerequisites

#### PostgreSQL

Mac:

    $ brew install postgres

#### Redis

Mac:

    $ brew install redis

#### Bower
(I don't think we're using Bower any more ... so probably skip this section... otherwise see the bottom of this readme for more details on how to setup Bower.)

#### Update your bundle

    $ bundle install
    
#### Create the SciView database

    $ rake db:setup

### Running the app

#### Launch the web server and redis

    $ cd ruby_app
    $ foreman start -p 3000

## Deploying to Heroku

### Setup Heroku Toolbelt
You will only need to setup the Heroku toolkit if you plan on publishing to Heroku. Otherwise, it is not necessary for your local environment.

https://toolbelt.heroku.com/

### Command line
We have a weird project structure, so you need a special command to deploy a subdirectory to Heroku.

    git push heroku `git subtree split --prefix ruby_app branch_to_deploy`:master --force

Note: Replace `heroku` with the correct remote name and `branch_to_deploy` with your current active branch.

### TempoDB
When TempoDB has been setup through Heroku, you can open the TempoDB web console via:

    $ heroku addons:open tempodb -a $HEROKU_APP_NAME

If you're logged into the FISI TempoDB web console, you can see a sine wave here:
https://tempo-db.com/database/a68ffbe8f6fe4fb3bbda2782002680f0/series/2552055117f247c095d165dabb3720c7/?start=2014-03-31T07%3A00%3A00.000Z&end=2014-04-05T06%3A59%3A59.000Z&interval=PT1S&function=

### Data generation examples

Get help from tool

    $ bin/datagen

Create 10 data points in test-key

    $ bin/datagen create test-key --count=10

Create 300,000 data points in test-key (delete and overwrite whatever exists)

    $ bin/datagen create test-key --count=300000 --force

Append 300,000 data points to test-key (do not overwrite whatever exists)

    $ bin/datagen create test-key --count=300000 --append

Append 1,000,000 data points to test-key (do not overwrite whatever exists) and log output to a file

    $ bin/datagen create test-key --count=1000000 --append >> ./log/test-key.log

    $ tail -f ./log/test-key.log

Benchmark rollup functions over different intervals on TempoDB (Primarily useful as an experimentation tool, feel free to change).

    $ rake data:benchmark



## Appendix

### Setting up Bower

Mac:
    
    # Pre-reqs (Node.JS and Node Package Manager)
    $ brew install node npm
    
    # Install bower
    $ npm install bower


Ubuntu: 
http://www.euperia.com/development/install-nodejs-and-bower-on-ubuntu-12-04-precise/1269

* Install bower dependencies

Add your dependencies inside ruby_app/Bowerfile, like the following:

    asset 'bootstrap'

Run bower install to download dependencies (the files will be downloaded to vendor/assets/bower_components):

    $ rake bower:install

Add the library to the asset pipeline:

    //= require bootstrap/dist/js/bootstrap
    

### ViewState

If no ViewState model exists, create one like this:

```ruby
ViewState.create(
  title: "TestViewState", 
  charts: [
    {"title"=>"Untitled Chart", "channels"=>[
      {"title"=>"default channel", "state"=>"expanded", "series"=>[
        {"title"=>"test", "category"=>"default category", "key"=>{"color"=>"#1ABC9C", "style"=>"solid"}}]}]}])
```

This will be available in the angular app at `/ng#/data-sets/:id`.
