require 'rake'
require 'sinatra'
require './qr_generate_app.rb'

desc 'run the server'
# so we don't have to run thin if we don't want to
task :run do |t|
  require './qr_generate_app.rb'
  QrGenerateApp.run!
end

