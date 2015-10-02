
# Instajobs


## Get hired now!

This is a product being built by the Assembly community. You can help push this idea forward by visiting [https://assembly.com/instajobs](https://assembly.com/instajobs).

### How Assembly Works

Assembly products are like open-source and made with contributions from the community. Assembly handles the boring stuff like hosting, support, financing, legal, etc. Once the product launches we collect the revenue and split the profits amongst the contributors.

Visit [https://assembly.com](https://assembly.com) to learn more.

Using .. http://angular-rails.com as a base for getting some of the boilerplate going for the app.

To build local : (If it doesn't work report the issue, and fix if you got one, or just edit this readme.)

- clone
- bundle
- install mongodb
- install redis [link](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-redis)
- copy this [file](https://www.dropbox.com/s/x2mf8os6irdbz11/mongoid.yml?dl=0) in /config/mongoid.yml 
- sidekiq -c config/sidekiq.yml
- unicorn -c config/unicorn.rb
- Run https://github.com/javan/whenever to create the cron job and schedule it

## Development and Deployment

- The `release` branch is auto-deployed to production (AWS)
- The `master` branch contains the latest merged code
- If you want to contribute just fork `master` and send in a pull request with your changes
