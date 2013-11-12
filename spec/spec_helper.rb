require "coveralls"
Coveralls.wear! do
  add_filter "/spec/"
end

require "pry"
require "rspec"
require_relative "../lib/bigslide"
