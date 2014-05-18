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
    text = params['text_to_encode']
    border = 0
    level = params['level'].to_sym
    pixel_size = size_by_text text

    file = Tempfile.new(['qrcode_', '.png'], settings.qrdir, 'w')

    encode_opts = {
      pixel_size: pixel_size,
      border: border,
      level: level
    }
    if allow?(text)
      Qr4r::encode text, file.path, encode_opts
    else
      encode_opts.merge!({error_text: "Вы превысили допустимое количество символов."})
    end

    slim :index, :locals => {
      file: asset_path(file.path),
      link: text
    }.merge(encode_opts)

  end

  run! if app_file == $0

  def allow?(text)
    text.size < 119
  end

  def size_by_text(text)
    return 14 if (text.size < 70)
    return 12 if (text.size < 120)
  end

  def asset_path(f)
    f.gsub(/^#{settings.public_folder}/, '')
  end
end
