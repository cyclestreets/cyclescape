akismet_file = Rails.root.join('config', 'rollbar')
if akismet_file.exist?
  Cyclescpae::Application.config.rakismet.key = akismet_file.read.strip
  Cyclescpae::Application.config.rakismet.url = 'http://www.cyclescape.org/'
end
