path = File.expand_path(File.dirname(__FILE__))
$:.unshift(path) unless $:.include?(path)

require 'app_store/app'
require 'app_store/review'
require 'app_store/base'
