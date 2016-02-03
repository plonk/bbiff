require 'shellwords'
require_relative 'bbiff/version'
require_relative 'bbiff/bbs_reader'
require_relative 'bbiff/res_format'

def parse_range(str)
  if str == "all"
    1..Float::INFINITY
  elsif str =~ /^\d+$/
    str.to_i..str.to_i
  elsif str =~ /^\d+-$/
    str.to_i..Float::INFINITY
  elsif str =~ /^(\d+)-(\d+)$/
    $1.to_i..$2.to_i
  else
    fail ArgumentError
  end
end

def start_polling(thread, start_no)
  default_notify_command = 'notify-send'
  notify_send = ENV['BBIFF_NOTIFY_SEND'] || (system("which #{default_notify_command}") ? default_notify_command : 'echo')
  loop do
    thread.posts(parse_range("#{start_no}-")).each do |post|
      system("#{notify_send} #{Shellwords.escape(render_post(post))}")
      sleep 1
    end
    start_no = thread.last + 1
    break if start_no >= 1000
    sleep 10
  end
rescue Interrupt
rescue => e
  STDERR.puts "error occured #{e.message}"
  STDERR.puts "retrying..., ^C to quit"
  sleep 3
  start_polling(thread, start_no)
end

def usage
  STDERR.puts "Usage: bbiff [http://jbbs.shitaraba.net/bbs/read.cgi/CATEGORY/BOARD_ID/THREAD_ID/] [START_NUMBER]"
  
  STDERR.puts <<"EOD"

Bbiff version #{Bbiff::VERSION}
Copyright © 2016 Yoteichi
EOD
end

def main
  unless ARGV.size >= 1
    usage
    exit 1
  end
  url = ARGV[0]

  if url =~ %r{\Ah?ttp://jbbs.shitaraba.net/bbs/read.cgi/(\w+)/(\d+)/(\d+)/?\z}
    ita = [$1, $2.to_i]
    sure = $3.to_i
  end

  thread = Bbs::C板.new(*ita).thread(sure)
  start_no = ARGV[1] ? ARGV[1].to_i : thread.last + 1
  start_polling(thread, start_no)
end
