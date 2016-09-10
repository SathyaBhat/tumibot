Tumibot - Telegram bot which replies with 'catchphrases' at random times. Hilarity level depends on context, not 100% guaranted. But guaranteed not to spam

###Pre requisites

    sudo apt-get install ruby2.3-dev build-essential

###Steps to get it up and running 

 - Install bundler

        gem install bundler

 - Install required gems
 
        bundle install

 - Create the db folder
 
        mkdir db/

 - Run the db-setup module
  
        ruby db-setup.rb

 - Configure the bot:
   
   Copy the `yaml.example` files to `.yaml` and modify `secrets.yaml` to add the Telegram bot token. Change the `user_confidence_levels.yaml` by updating the username, weight and responses the bot must send.
 
###Bot dev 

If you'd like to work further on the bot, there's a Vagrant file which you can customize before you bring it up with 

    vagrant up
    vagrant ssh
