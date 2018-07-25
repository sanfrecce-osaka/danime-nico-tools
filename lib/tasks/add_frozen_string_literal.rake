# frozen_string_literal: true

require 'rake/clean'

namespace :rubocop do
  desc '対象ファイルの文字列をイミュータブルにする'
  task :add_frozen_string_literal do
    file_path_list = `bundle exec rubocop | grep "Missing magic comment" | cut -d: -f 1`.chomp.split("\n")
    ADDITIONAL_LINE = "# frozen_string_literal: true\n\n"
    file_path_list.each do |file_path|
      lines = File.readlines(file_path)
      if %r{#!/usr/bin/env ruby}.match?(lines.first)
        lines.insert(1, ADDITIONAL_LINE)
      else
        lines.unshift(ADDITIONAL_LINE)
      end
      File.write(file_path, lines.join(''))
    end
  end
end
