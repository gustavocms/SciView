## SciView

## Local Environment Setup

### Prerequisites

#### Setup Heroku
You will only need to setup the Heroku toolkit if you plan on publishing to Heroku. Otherwise, it is not necessary for your local environment.

https://toolbelt.heroku.com/

#### Setup PostgreSQL

On Mac:
    $ brew install postgres

#### Setup Redis

On Mac:
    $ brew install redis

#### Setup Bower (I don't think we're using Bower any more ... so probably skip this section)

On Mac:
    # Pre-reqs (Node.JS and Node Package Manager)

    $ brew install node npm
    
    # Install bower
    $ npm install bower


On Ubuntu: 
http://www.euperia.com/development/install-nodejs-and-bower-on-ubuntu-12-04-precise/1269

* Install bower dependencies

Add your dependencies inside ruby_app/Bowerfile, like the following:

    asset 'bootstrap'

Run bower install to download dependencies (the files will be downloaded to vendor/assets/bower_components):

    $ rake bower:install

Add the library to the asset pipeline:

    //= require bootstrap/dist/js/bootstrap

### Running the app

    $ cd ruby_app
    $ foreman start -p 3000

## Deploying to Heroku

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
