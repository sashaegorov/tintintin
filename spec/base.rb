require 'rubygems'
require 'spec'
require 'sequel'

Sequel.sqlite

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'post'

# dunno why, but this is needed
Post.create_table

require 'ostruct'
Blog = OpenStruct.new(
	:title => 'My blog',
	:author => 'Anonymous Coward',
	:url_base => 'http://blog.example.com/'
)
