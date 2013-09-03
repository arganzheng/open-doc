require 'sinatra/base'

module Sinatra

  module ViewHelper

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

  helpers ViewHelper

end

