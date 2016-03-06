require 'cgi'
require 'active_support'
require 'active_support/core_ext/numeric'
require 'bbiff/bbs_reader'
require 'bbiff/formatter/base'

module Bbiff
  module Formatter
    class Default
      class << self
        def format(post)
          "#{render_resno post.no}：#{render_name post.name, post.mail}：#{render_date post.date}\n" \
            "#{render_body post.body}"
        end

        private

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
          weekday = '日月火水木金土'.chars
          delta = Time.now - t

          case delta
          when 0...1
            "たった今"
          when 1...(1.minute)
            "#{delta.to_i}秒前"
          when (1.minute)...(1.hour)
            "#{(delta / 60).to_i}分前"
          when (1.hour)...(24.hours)
            "#{(delta / 3600).to_i}時間前"
            # when (1.day)...Float::INFINITY
          else
            "#{t.year}/#{t.month}/#{t.day}(#{weekday[t.wday]}) #{t.hour}:#{t.min}:#{t.sec}"
          end
        end

        def render_body(body)
          unescaped = CGI.unescapeHTML(body.gsub(/<br>/i, "\n"))
          indent(4, unescaped) + "\n"
        end

        def indent(n, text)
          text.each_line.map { |line| spaces(n * 2) + line }.join
        end

        def spaces(n)
          ' ' * n
        end
      end
    end
  end
end
