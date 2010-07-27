require "#{File.dirname(__FILE__)}/lib/arturaz/custom_serialize.rb"
ActiveRecord::Base.extend Arturaz::CustomSerialize::ClassMethods