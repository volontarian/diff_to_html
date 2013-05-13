# -*- encoding : utf-8 -*-
require File.expand_path('../lib/diff_to_html.rb', File.dirname(__FILE__))
require File.expand_path('./test.rb', File.dirname(__FILE__))
filename = ARGV[0] || File.expand_path('./diff.svn', File.dirname(__FILE__))
diff = File.open(filename).read
converter = DiffToHtml::SvnConverter.new
out(diff, converter, filename)
