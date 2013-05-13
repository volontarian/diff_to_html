# -*- encoding : utf-8 -*-
require 'cgi'

module DiffToHtml
  class Converter
    attr_accessor :file_prefix
      
    def composite_to_html(composite_diff)
      diffs_to_html get_diffs(composite_diff)
    end
    
    def diffs_to_html(diffs)
      result = '<ul class="diff">'
      @filenum = 0
      
      diffs.each do |file_map|
        result << get_single_file_diff(file_map[:filename], file_map[:file])
        @filenum += 1
      end
      
      result << '</ul>'
      result    
    end
    
    def get_single_file_diff(file_name, diff_file)
      result = ""
      diff = diff_file.split("\n")
      diff, line = shift_until_first_line(diff)
      
      if line =~ /^---/
        result << begin_file(file_name)
        result << get_single_file_diff_body(diff)
        result << "</li>"      
      else
        #"<div class='error'>#{line}</div>"
        result =%Q{<li><h2><a name="F#{@filenum}" href="#F#{@filenum}">#{file_name}</a></h2>#{line}</li>}
      end
  
      result
    end
    
    def get_single_file_diff_body(diff)
      @last_op, @left, @right = ' ', [], []
      
      if diff.is_a? String
        diff = diff.split("\n") 
        diff, line = shift_until_first_line(diff)
      end
      
      diff.shift #+++
      
      result = %Q{
        <table class='diff'>
          <colgroup>
          <col class="lineno"/>
          <col class="lineno"/>
          <col class="content"/>
        </colgroup>   
      }
      
      range = diff.shift
      left_ln, right_ln = range_info(range)
      result << range_row(range)
      
      diff.each do |line|
        op = line[0,1]
        line = line[1..-1] || ''
        
        if op == '\\'
          line = op + line
          op = ' '
        end
        
        if ((@last_op != ' ' and op == ' ') or (@last_op == ' ' and op != ' '))
          left_ln, right_ln = flush_changes(result, left_ln, right_ln)
        end
        
        # truncate and escape
        line = CGI.escapeHTML(line)

        case op
        when ' '
          @left.push(line)
          @right.push(line)
        when '-' then @left.push(line)
        when '+' then @right.push(line)
        when '@' 
          range = '@' + line
          flush_changes(result, left_ln, right_ln)
          left_ln, right_ln = range_info(range)
          result << range_row(range)
        else
          flush_changes(result, left_ln, right_ln)
          result << "</table></li>"
          break
        end
        @last_op = op
      end

      flush_changes(result, left_ln, right_ln)
      result << "</table>" 
      
      result
    end
  
    def file_header_pattern
      raise "Method to be implemented in VCS-specific class"
    end
    
    private
    
    def get_diffs(composite_diff)
      pattern = file_header_pattern
      files = composite_diff.split(pattern)
      headers = composite_diff.scan(pattern) #huh can't find a way to get both at once
      files.shift if files[0] == '' #first one is junk usually
      result = []
      i = 0
      
      files.each do |file|
        result << {:filename => "#{file_prefix}#{get_filename(headers[i])}", :file => file}
        i += 1
      end
      
      result
    end
    
    def shift_until_first_line(diff)
      diff.shift if diff.first.match(/#index/)
      
      line = nil
      
      while line !~ /^---/ && !diff.empty?
        line = diff.shift
      end
      
      [diff, line]
    end
    
    def begin_file(file)
      result = %Q{
        <li>
          <h2><a name="F#{@filenum}" href="#F#{@filenum}">#{file}</a></h2>
      }
      
      result
    end
    
    def range_info(range)
      left_ln, right_ln = range.gsub(/(@|-|\+)+/, '').strip.split(' ').map{|ln| ln.split(',')[0]}

      begin
        return Integer(left_ln), Integer(right_ln)
      rescue Exception => e
        raise NotImplementedError.new(
          e.class.name + " (#{e.message}): " + range.inspect + " => [#{left_ln.inspect}, #{right_ln.inspect}]"
        )
      end
    end
  
    def range_row(range)
      "<tr class='range'><td>...</td><td>...</td><td>#{range}</td></tr>"
    end
    
    def flush_changes(result, left_ln, right_ln)
      x, left_ln, right_ln = get_diff_row(left_ln, right_ln)
      result << x
      @left.clear
      @right.clear    
      return left_ln, right_ln
    end
    
    #
    # helper for building the next row in the diff
    #
    def get_diff_row(left_ln, right_ln)
      result = []
      if @left.length > 0 or @right.length > 0
        modified = (@last_op != ' ')
        
        if modified
          left_class = " class='r'"
          right_class = " class='a'"
          result << "<tbody class='mod'>"
        else
          left_class = right_class = ''
        end
        
        result << @left.map do |line| 
          x = "<tr#{left_class}>#{ln_cell(left_ln, 'l')}"
          
          if modified
            x += ln_cell(nil)
          else
            x += ln_cell(right_ln, 'r')
            right_ln += 1
          end
          
          x += "<td>#{line}</td></tr>"
          
          left_ln += 1
          
          x
        end
        
        if modified
          result << @right.map do |line| 
            x = "<tr#{right_class}>#{ln_cell(nil)}#{ln_cell(right_ln, 'r')}<td>#{line}</td></tr>"
            right_ln += 1
            x
          end
          
          result << "</tbody>"
        end
      end
      
      return result.join("\n"), left_ln, right_ln
    end
  
    def ln_cell(ln, side = nil)
      anchor = "f#{@filenum}#{side}#{ln}"
      result = "<td class = 'ln'>"
      result += "<a name='#{anchor}' href='##{anchor}'>" if ln
      result += "#{ln}"
      result += "</a>" if ln
      result += "</td>"
      result
    end
  end
end