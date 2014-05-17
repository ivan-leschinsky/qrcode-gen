require 'rubygems'
require 'sinatra'

disable :run, :reload

require './qr_generate_app.rb'

run QrGenerateApp.new
