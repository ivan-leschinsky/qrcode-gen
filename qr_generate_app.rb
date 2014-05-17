require 'rubygems'
require 'bundler'
Bundler.require :default

require 'sinatra/base'

require 'slim'
require 'fileutils'

require 'qr4r'

class QrGenerateApp < Sinatra::Base

  set :environment, :production
  set :logging, true
  set :static, true
  set :root, Dir.pwd
  set :public_folder, File.join(settings.root, 'public')
  set :qrdir, File.join(settings.public_folder, 'generated')
  set :port, 5678
  APP_ROOT = root

  if !File.exists?(settings.qrdir)
    FileUtils::mkdir_p settings.qrdir
  end

  get '/' do
    slim :index
  end

  post '/' do
    link = params['text_to_encode']
    border = params['border'] || 0
    level = params['level'].to_sym
    pixel_size = params['pixel_size'] || 15

    file = Tempfile.new(['qrcode_', '.png'], settings.qrdir, 'w')

    encode_opts = {
      pixel_size: pixel_size,
      border: border,
      level: level,
      levels: {
                l: "7%",
                m: "15%",
                q: "25%",
                h: "30%"
              }
    }
    Qr4r::encode link, file.path, encode_opts
    slim :index, :locals => {
      file: asset_path(file.path),
      link: link
    }.merge(encode_opts)

  end

  run! if app_file == $0

  def get_levels
    {
      l: "7%",
      m: "15%",
      q: "25%",
      h: "30%"
    }
  end

  def asset_path(f)
    f.gsub(/^#{settings.public_folder}/, '')
  end
end
