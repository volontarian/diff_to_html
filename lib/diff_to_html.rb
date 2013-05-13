# -*- encoding : utf-8 -*-
module DiffToHtml
  autoload :Converter, File.expand_path('diff_to_html/converter', File.dirname(__FILE__))
  autoload :SvnConverter, File.expand_path('diff_to_html/svn_converter', File.dirname(__FILE__))
  autoload :GitConverter, File.expand_path('diff_to_html/git_converter', File.dirname(__FILE__))
end