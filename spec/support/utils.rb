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
end
