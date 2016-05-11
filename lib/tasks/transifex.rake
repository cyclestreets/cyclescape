namespace 'transifex' do
  desc 'Normalise and upload the source files'
  task :push => :environment do
    sources = %w(activerecord decorators devise_invitable devise forms)
    sources = sources.map{|s| "#{s}.en-GB.yml"}.push('en-GB.yml')
    sources.each do |source|
      input = File.join(Rails.root, 'config', 'locales', source)
      output = File.join(Rails.root, 'config', 'locales', "#{source}.normal")

      # YAML loading produces a hash where the references are effectively
      # preserved by having the values refer to the same object, and there's
      # no easy way to serialize the Hash without re-introducing the references.
      # JSON doesn't have references, so round-tripping via JSON de-normalises
      # them. What a hack.
      # http://stackoverflow.com/q/21016220/105451
      # http://stackoverflow.com/a/28548203/105451
      File.write(output, JSON.parse(YAML.load_file(input).to_json).to_yaml)
    end

    system 'tx push --source'

    sources.each do |source|
      file = File.join(Rails.root, 'config', 'locales', "#{source}.normal")
      File.delete(file)
    end
  end

  desc 'Pull the translations from transifex'
  task :pull do
    system 'tx pull'
  end
end
