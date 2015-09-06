RAILS_ENV=production 
rake assets:precompile
unicorn_pid=`cat pids/unicorn.pid`
sidekiq_pid=`cat pids/sidekiq.pid`
sudo kill -9 $unicorn_pid
sudo kill -9 $sidekiq_pid
unicorn -c config/unicorn.rb -E production -p 3000  -D
bundle exec sidekiq -e production -C config/sidekiq.yml -d