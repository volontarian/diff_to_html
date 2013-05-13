require File.expand_path('../lib/diff_to_html/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'diff_to_html'
  s.version = '0.0.1'
  s.date = '2013-05-13'
  
  s.summary = "Unified diff to HTML converter"
  s.description = "Generates HTML view of given unified diff"
  
  s.authors = ['Adam Doppelt', 'Artem Vasiliev', 'Mathias Gawlista']
  s.email = 'gawlista@gmail.com'
  s.homepage = 'http://github.com/applicat/diff_to_html'
  
  s.has_rdoc = true
  s.rdoc_options = ['--main', 'README.rdoc']
  s.rdoc_options << '--inline-source' << '--charset=UTF-8'
  s.extra_rdoc_files = ['README.rdoc']
  s.version = DiffToHtml::VERSION
  s.license       = "MIT"
  
  s.files = Dir['README.rdoc', 'LICENSE', 'lib/**/*']
end