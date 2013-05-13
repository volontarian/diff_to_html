# -*- encoding : utf-8 -*-
module DiffToHtml
  class GitConverter < Converter
    def file_header_pattern
      /^diff --git.+/
    end
  
    def get_filename(file_diff)
      match = (file_diff =~ / b\/(.+)/)
      raise "not matched!" if !match
      $1
    end  
  end
end