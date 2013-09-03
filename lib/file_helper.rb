require 'sinatra/base'
require "tree"

class FileHelper

  def self.scan_for_article_meta(dir)
      meta_root_node = Tree::TreeNode.new(dir)
  	 
      Dir.foreach(dir) { |file|
      	fullpath = File.join(dir, file)
        if(File.file?(fullpath) && file.end_with?(".md"))
          meta_root_node << get_article_meta(fullpath)
        elsif (File.directory?(fullpath) && !file.eql?(".") && !file.eql?(".."))
          # recursive scan
          meta_root_node << scan_for_article_meta(fullpath)
        end
      }
      return meta_root_node
  end

    def self.get_article_meta(file)
      meta, content   = File.read(file, :encoding => "utf-8").split("\n\n", 2)

      article         = OpenStruct.new YAML.load(meta)
      article.date    = Time.parse article.date.to_s

      article.slug    = File.basename(file, '.md')
      article.content  = content;

      return Tree::TreeNode.new(file, article)
  end
  
end


  
  