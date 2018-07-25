# frozen_string_literal: true

class YAMLFile
  class << self
    def write(target_path, text)
      File.write(target_path, text.to_yaml)
    end

    def open(file_path)
      YAML.load(File.read(file_path))
    end
  end
end
