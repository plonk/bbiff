require 'cgi'
require_relative 'bbs_reader'

class Fixnum
  def em
    ' ' * (self*2)
  end

  def en
    ' ' * self
  end
end

def render_name(name, email)
  if email.empty?
    name
  else
    name
  end
end

def render_resno(no)
  no.to_s
end

def indent(n, text)
  text.each_line.map { |line| n.en + line }.join
end

def render_body(body)
  unescaped = CGI.unescapeHTML(body.gsub(/<br>/i, "\n"))
  indent(4, unescaped) + "\n"
end

def render_post(post)
  "#{render_resno post.no}：#{render_name post.name, post.mail}：#{post.date}\n" \
  "#{render_body post.body}"
end

# posts = Bbs::C板.new('game', 48538).thread(1416739363).posts(1..Float::INFINITY)
# puts posts.map(&method(:render_post)).join("\n\n")
