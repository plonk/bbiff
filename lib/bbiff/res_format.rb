require 'cgi'
require_relative 'bbs_reader'

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

def render_date(t)
  weekday = [*'日月火水木金土'.each_char]
  "%d/%d/%d(%s) %02d:%02d:%02d" % [t.year, t.month, t.day, weekday[t.wday], t.hour, t.min, t.sec]
end

def indent(n, text)
  text.each_line.map { |line| ' ' * n + line }.join
end

def render_body(body)
  unescaped = CGI.unescapeHTML(body.gsub(/<br>/i, "\n"))
  indent(4, unescaped) + "\n"
end

def render_post(post)
  "#{render_resno post.no}：#{render_name post.name, post.mail}：#{render_date post.date}\n" \
  "#{render_body post.body}"
end

# posts = Bbs::C板.new('game', 48538).thread(1416739363).posts(1..Float::INFINITY)
# puts posts.map(&method(:render_post)).join("\n\n")
