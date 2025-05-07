# frozen_string_literal: true

module SpecUtils
  module_function

  def generate_password
    lowercase_characters = ('a'..'z').to_a
    uppercase_characters = ('A'..'Z').to_a
    digits = ('0'..'9').to_a
    special_chars = %w[! @ # $ % ^ & *]

    # Ensure one character from each category
    password = lowercase_characters.sample +
      uppercase_characters.sample +
      digits.sample +
      special_chars.sample

    # Fill in remaining characters randomly
    5.times { password += [lowercase_characters, uppercase_characters, digits, special_chars].sample.sample }

    # Randomize the order of characters to make the password less predictable
    password.split('').shuffle.join
  end

  def deep_stringify_keys(hash)
    hash.transform_keys!(&:to_s)
    hash.each_value do |value|
      deep_stringify_keys(value) if value.is_a? Hash
      value.each { |v| deep_stringify_keys(v) if v.is_a? Hash } if value.is_a? Array
    end
  end

  def build_prefix
    # Use GITHUB_RUN_NUMBER as the primary identifier, fall back to a timestamp if not available
    prefix = ENV['GITHUB_RUN_NUMBER'] || ENV['GITHUB_RUN_ID']
    prefix ? "build#{prefix}-" : "local-#{Time.now.to_i}-"
  end
end
