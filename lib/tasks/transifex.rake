# frozen_string_literal: true

namespace "transifex" do
  desc "Normalise and upload the source files"
  task push: :environment do
    sources = %w[activerecord decorators devise_invitable devise forms]
    sources = sources.map { |s| "#{s}.en-GB.yml" }.push("en-GB.yml")
    sources.each do |source|
      input = File.join(Rails.root, "config", "locales", source)
      output = File.join(Rails.root, "config", "locales", "#{source}.normal")

      # YAML loading produces a hash where the references are effectively
      # preserved by having the values refer to the same object, and there's
      # no easy way to serialize the Hash without re-introducing the references.
      # JSON doesn't have references, so round-tripping via JSON de-normalises
      # them. What a hack.
      # http://stackoverflow.com/q/21016220/105451
      # http://stackoverflow.com/a/28548203/105451
      File.write(output, JSON.parse(YAML.load_file(input).to_json).to_yaml)
    end

    system "tx push --source"

    sources.each do |source|
      file = File.join(Rails.root, "config", "locales", "#{source}.normal")
      File.delete(file)
    end
  end

  desc "Pull the translations from transifex"
  task :pull do
    def flat_hash(hash, k = [])
      return { k => hash } unless hash.is_a?(Hash)

      hash.inject({}) { |h, v| h.merge! flat_hash(v[-1], k + [v[0]]) }
    end

    def find_interpolation(value)
      value ? value.scan(/\%{.*?}/).flatten : []
    end

    # We need to pull 'all' translations, otherwise transifex skips cs-CZ and
    # also ignores cs_CZ
    system "tx pull --all --force"

    locale_dir = File.join(Rails.root, "config", "locales")

    Dir.chdir(locale_dir) do
      # Remove the en_GB versions which are just copies of the sources.
      # Also select all the translations which include %{ ... }
      flat_gb = {}
      Dir.glob("*en_GB*") do |filename|
        name = filename.split(".").first
        flat_gb[name] = flat_hash(JSON.parse(YAML.load_file(filename).to_json))
                        .select { |_k, v| find_interpolation(v).first }
        File.delete(File.join(locale_dir, filename))
      end

      # Move the underscore variants to be dashes, e.g. cs_CZ to cs-CZ
      Dir.glob("*_??.yml") do |filename|
        source_path = File.join(locale_dir, filename)
        target_path = File.join(locale_dir, filename.reverse.sub("_", "-").reverse)
        File.rename(source_path, target_path)

        # The language key inside each file is wrong too...
        content = YAML.load_file(target_path)
        flat_content = flat_hash(content)
        content = content.transform_keys { |k| k.sub("_", "-") }

        tx_primary_key = flat_content.keys.first.first

        split_name = filename.split(".")

        name = if split_name.length == 2
                 "en_GB"
               else
                 split_name.first
               end

        # Find all the %{ ... } translations that do not match the GB equivalent
        wrong_interpolation = flat_gb[name].map do |k, v|
          tx_k = [tx_primary_key] + k[1..-1]
          { "key" => tx_k, "gb" => find_interpolation(v), tx_primary_key => find_interpolation(flat_content[tx_k]) }
        end.reject { |v| v["gb"].sort == v[tx_primary_key].sort }

        if wrong_interpolation.present?
          puts "These keys have the wrong interpolation on Transfix: #{wrong_interpolation.join("\n")}\n\n"
        end

        File.write(target_path, content.to_yaml)
      end
    end
  end
end
