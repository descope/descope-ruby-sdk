# frozen_string_literal: true

module SpecUtils
  module_function

  def generate_password
    lowercase_characters = ('a'..'z').to_a
    uppercase_characters = ('A'..'Z').to_a
    digits = ('0'..'9').to_a
    special_chars = %w[! @ # $ % ^ & *]
    characters = lowercase_characters + uppercase_characters + digits + special_chars

    password = special_chars.sample # guarantee one non-alphanumeric character
    password += 7.times.map { characters.sample }.join
    password + rand(100..999).to_s
  end

  def deep_stringify_keys(hash)
    hash.transform_keys!(&:to_s)
    hash.each_value do |value|
      deep_stringify_keys(value) if value.is_a? Hash
      value.each { |v| deep_stringify_keys(v) if v.is_a? Hash } if value.is_a? Array
    end
  end
end
