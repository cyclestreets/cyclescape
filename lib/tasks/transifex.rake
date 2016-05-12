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
    # We need to pull 'all' translations, otherwise transifex skips cs-CZ and
    # also ignores cs_CZ
    system 'tx pull --all --force'

    locale_dir = File.join(Rails.root, 'config', 'locales')

    Dir.chdir(locale_dir) do
      # Remove the en_GB versions which are just copies of the sources.
      Dir.glob('*en_GB*') do |filename|
        File.delete(File.join(locale_dir, filename))
      end

      # Move the underscore variants to be dashes, e.g. cs_CZ to cs-CZ
      Dir.glob('*_??.yml') do |filename|
        source_path = File.join(locale_dir, filename)
        target_path = File.join(locale_dir, filename.reverse.sub('_', '-').reverse)
        File.rename(source_path, target_path)

        # The language key inside each file is wrong too...
        content = YAML.load_file(target_path).transform_keys{ |k| k.sub('_', '-') }.to_yaml
        File.write(target_path, content)
      end
    end
  end
end
