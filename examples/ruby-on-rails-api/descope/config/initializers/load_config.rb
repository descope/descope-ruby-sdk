require 'erb'

module YAML
  def self.properly_load_file(path)
    contents = ERB.new(File.read(path)).result
    YAML.load(contents, aliases: true)
  rescue ArgumentError
    YAML.load(contents)
  end
end

APP_CONFIG = YAML.properly_load_file(Rails.root.join('config', 'config.yml'))[Rails.env]