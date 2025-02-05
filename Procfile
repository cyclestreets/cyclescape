# If any proccess name is changed the proccess will have to be stopped manually e.g. sudo systemctl stop cyclescape-worker_1.1.service
worker_1: env QUEUE=* bundle exec rake environment resque:work
worker_2: env QUEUE=* bundle exec rake environment resque:work
resque_web: bundle exec resque-web -F -L --namespace resque:Cyclescape --app-dir ./ --pid-file /var/run/resque_web.pid --log-file /var/log/resque_web.log --url-file ./resque_web.url
sunspot: bundle exec rake sunspot:solr:run
resque_scheduler: bundle exec rake resque:scheduler
