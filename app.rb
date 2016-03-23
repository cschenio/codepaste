require 'sinatra'
require 'slim'
require 'data_mapper'
require 'rouge'

# DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")
  DataMapper.setup(:default, 'sqlite::memory:')
class Code
  include DataMapper::Resource
  storage_names[:default] = "code_list"
  property :id, String, :key => true
  property :content, Text
end

DataMapper.finalize.auto_upgrade!


Code.create(:id => "aaaaaaaa", :content => "def fact(n)
  if(n > 1)
    n * fact(n-1)
  else
    1
  end
end

100.times {
  fact(5000)
}")

#======================

formatter = Rouge::Formatters::HTML.new(css_class: 'highlight',line_numbers: true)
lexer = Rouge::Lexers::Ruby.new



get /\A\/([\w]{8})\z/ do
  u = params['captures'].first
  c = Code.get("#{u}")
  slim :show, :locals => {:style => Rouge::Themes::Github.render(scope: '.highlight'),
  :content => formatter.format(lexer.lex(c[:content]))}
end

get '/' do
  "See \$hostname/aaaaaaaa to view the effect."
end

