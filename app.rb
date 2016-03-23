require 'sinatra'
require 'slim'
require 'data_mapper'
require 'rouge'
require 'securerandom'

# DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")
  DataMapper.setup(:default, 'sqlite::memory:')
class Code
  include DataMapper::Resource
  storage_names[:default] = "code_list"
  property :id, String, :key => true
  property :content, Text
end

DataMapper.finalize.auto_upgrade!

#======================

def random_url
  str = String.new
  loop do
    str = SecureRandom.urlsafe_base64(6, false)
    break if Code.get("#{str}") == nil
  end
  str
end

#=====================

formatter = Rouge::Formatters::HTML.new(css_class: 'highlight',line_numbers: true)
lexer = Rouge::Lexers::Ruby.new



get /\A\/([-_\w]{8})\z/ do
  u = params['captures'].first
  c = Code.get("#{u}")
  slim :show, :locals => {:style => Rouge::Themes::Github.render(scope: '.highlight'),
  :content => formatter.format(lexer.lex(c[:content]))}
end

get '/' do
  slim :index
end

post '/' do
  url = random_url()
  Code.create(:id => url, :content => params[:content])
  redirect "/#{url}"
end