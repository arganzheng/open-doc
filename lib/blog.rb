require 'sinatra/base'
require 'ostruct'
require 'yaml'
require 'time'
require "logger"
require "tree"
require "sinatra/view_helper"
require "file_helper"


class Blog < Sinatra::Base
  helpers Sinatra::ViewHelper

  set :root, File.expand_path('../../', __FILE__)
  set :markdown, :layout_engine => :erb
  set :app_file, __FILE__
  set :meta_root_node, nil

  configure do
    set :documents_path, File.join(settings.root, "articles")
    FileHelper.documents_path = settings.documents_path

    enable :logging
    file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
    file.sync = true
    use Rack::CommonLogger, file
  end

  before do
    logger.datetime_format = "%Y/%m/%d @ %H:%M:%S "
    logger.level = Logger::INFO
  end

  ## generate sidebar at startup
  meta_root_node = FileHelper.scan_for_article_meta(settings.documents_path)
  meta_root_node.print_tree

  #get "/doc/#{article.slug}" do
  #  erb :article, :locals => { :article => article }, :layout => :post
  #end

  get '/' do
    erb :index, :layout => :'layout/layout'
  end

  get '/sidebar' do
    erb :index, :locals => { :meta_root_node => meta_root_node }, :layout => :'layout/sidebar'
  end

  get %r{/doc/?([\w[_/-]?]+)?[/]?} do | page|
    if(page.nil?)
      page = "__init__"
    elsif(page.end_with?("/"))
      page = page.chop;
    end

    file = File.join(settings.root, "articles", page + ".md")
    if(not File.exists?(file)) # not exist, could be path/__init__.md
      file = File.join(settings.root, "articles", page, "__init__.md")      
    end

    if(File.exists?(file)) 
      meta, content   = File.read(file, :encoding => "utf-8").split("\n\n", 2)
      article         = OpenStruct.new YAML.load(meta)
      article.date    = Time.parse article.date.to_s
      article.content = content
      article.slug    = File.basename(file, '.md')

      erb :article, :locals => { :article => article }, :layout => :'layout/post'
    else
      logger.error "404: " + page + " not found!"
      raise error(404)
    end
  end

end


