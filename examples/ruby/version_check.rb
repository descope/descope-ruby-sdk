# frozen_string_literal: true

required_version = File.read('.ruby-version').strip

begin
  # Check the Ruby version using RUBY_VERSION constant
  current_version = RUBY_VERSION

  # Compare major, minor and patch versions
  if current_version.split('.').map(&:to_i) != required_version.split('.').map(&:to_i)
    raise StandardError, "Script requires Ruby version #{required_version} but found #{current_version}"
  end
rescue StandardError => e
  puts "Error: #{e}"
  puts "Script cannot run with incompatible Ruby version. Please install version #{required_version}."
  exit(1) # Exit with an error code
end
