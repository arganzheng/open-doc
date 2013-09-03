require 'sinatra/base'
require "tree"

class FileHelper

  def self.documents_path=(path)
    @documents_path = path
  end
  def self.documents_path
    @documents_path
  end

  def self.scan_for_article_meta(dir)
      meta_root_node = Tree::TreeNode.new(dir)
      this_node = get_article_meta(dir)
      if(not this_node.nil?)
        meta_root_node = this_node
      end

      Dir.foreach(dir) { |file|
      	fullpath = File.join(dir, file)
        if(File.file?(fullpath) && file.end_with?(".md") && !file.end_with?("__init__.md"))
          meta_root_node << get_article_meta(fullpath)
        elsif (File.directory?(fullpath) && !file.eql?(".") && !file.eql?(".."))
          # recursive scan
          meta_root_node << scan_for_article_meta(fullpath)
        end
      }
      return meta_root_node
  end

  def self.get_article_meta(file)
    name = file
    if(File.directory?(file))
      slug = File.join('doc', file[documents_path.length, file.length-documents_path.length])
      file = File.join(file, "__init__.md")
    else
      slug = File.join('doc', file[documents_path.length, file.length-documents_path.length-3])
    end

    if(File.exists?(file))
      meta, content   = File.read(file, :encoding => "utf-8").split("\n\n", 2)

      article         = OpenStruct.new YAML.load(meta)
      article.date    = Time.parse article.date.to_s

      article.slug = slug

      article.content  = content;

      return Tree::TreeNode.new(name, article)
    end

  end

end


  
  