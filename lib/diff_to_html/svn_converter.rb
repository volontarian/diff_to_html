# -*- encoding : utf-8 -*-
module DiffToHtml
  class SvnConverter < Converter
    def file_header_pattern
      /^Index: .+/
    end
  
    def get_filename(header)
      match = (header =~ /^Index: (.+)/) #if we use this pattern file_header_pattern files split doesn't work
      raise "header '#{header}' not matched!" if !match
      $1
    end  
  end
end