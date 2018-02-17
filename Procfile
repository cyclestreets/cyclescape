medium: env QUEUE=medium bundle exec rake environment resque:work
mailers: env QUEUE=mailers bundle exec rake environment resque:work
resque_web: bundle exec resque-web -F -L --namespace resque:Cyclescape --app-dir ./ --pid-file /var/run/resque_web.pid --log-file /var/log/resque_web.log --url-file ./resque_web.url
sunspot: bundle exec rake sunspot:solr:run
