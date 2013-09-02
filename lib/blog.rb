require 'sinatra/base'
require 'ostruct'
require 'yaml'
require 'time'
require "logger"



class Blog < Sinatra::Base
  set :root, File.expand_path('../../', __FILE__)
  set :markdown, :layout_engine => :erb
  set :app_file, __FILE__
  set :articles, []

  configure do
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
  Dir.glob "#{root}/articles/**/*.md" do |file|
    meta, content   = File.read(file, :encoding => "utf-8").split("\n\n", 2)
    article         = OpenStruct.new YAML.load(meta)
    article.date    = Time.parse article.date.to_s
    article.content = content
    article.slug    = File.basename(file, '.md')
    #get "/doc/#{article.slug}" do
    #  erb :article, :locals => { :article => article }, :layout => :post
    #end
    articles << article
  end
  articles.sort_by! { |article| article.date }
  articles.reverse!
   
  get '/' do
    erb :index, :layout => :'layout/layout'
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


  helpers do

  def partial(template,locals=nil)
    if template.is_a?(String) || template.is_a?(Symbol)
      template=('partial/' + template.to_s).to_sym
    else
      locals=template
      template=template.is_a?(Array) ? ('partial/' + template.first.class.to_s.downcase).to_sym : ('partial/' + template.class.to_s.downcase).to_sym
    end
    if locals.is_a?(Hash)
      erb(template,{:layout => false},locals)      
    elsif locals
      locals=[locals] unless locals.respond_to?(:inject)
      locals.inject([]) do |output,element|
        output <<     erb(template,{:layout=>false},{template.to_s.delete("_").to_sym => element})
      end.join("\n")
    else 
      erb(template,{:layout => false})
    end
  end

  end

end


