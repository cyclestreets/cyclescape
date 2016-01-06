akismet_file = Rails.root.join('config', 'akismet')
if akismet_file.exist?
  Cyclescape::Application.config.rakismet.key = akismet_file.read.strip
elsif %w(development test).include? Rails.env
  Cyclescape::Application.config.rakismet.key = 'development'
end

Cyclescape::Application.config.rakismet.url = 'http://www.cyclescape.org/'
