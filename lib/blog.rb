require 'sinatra/base'
require 'ostruct'
require 'yaml'
require 'time'

class Blog < Sinatra::Base
  set :root, File.expand_path('../../', __FILE__)
  set :articles, []
  set :app_file, __FILE__
  Dir.glob "#{root}/articles/**/*.md" do |file|
    meta, content   = File.read(file, :encoding => "utf-8").split("\n\n", 2)
    article         = OpenStruct.new YAML.load(meta)
    article.date    = Time.parse article.date.to_s
    article.content = content
    article.slug    = File.basename(file, '.md')
    get "/doc/#{article.slug}" do
      erb :article, :locals => { :article => article }, :layout => :post
    end
    articles << article
  end
  articles.sort_by! { |article| article.date }
  articles.reverse!
   
  get '/' do
    erb :index
  end
end
