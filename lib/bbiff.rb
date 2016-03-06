require 'shellwords'
require 'optparse'
require 'active_support'
require 'active_support/core_ext/string'

require 'bbiff/version'
require 'bbiff/bbs_reader'

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

def start_polling(thread, start_no, command, format_type='default')
  default_notify_command = 'notify-send'
  notify_send = ENV['BBIFF_NOTIFY_SEND'] ||
                command ||
                (system("which #{default_notify_command}") ? default_notify_command : 'echo')
  formatter = eval "Bbiff::Formatter::#{format_type.camelcase}"
  loop do
    thread.posts(parse_range("#{start_no}-")).each do |post|
      system("#{notify_send} #{Shellwords.escape(formatter.format(post))}")
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
  STDERR.puts <<EOD
Usage: bbiff [option] [http://jbbs.shitaraba.net/bbs/read.cgi/CATEGORY/BOARD_ID/THREAD_ID/] [START_NUMBER]

Bbiff version #{Bbiff::VERSION}
Copyright © 2016 Yoteichi
--

    -c, --command COMMAND   Specify notify-send command.
    -f, --format  FORMAT    Specify res format type.
    -h, --help              Display this help message.
EOD
end

def main
  if ARGV.empty?
    usage
    exit 1
  end

  command = nil
  format_type = 'default'
  opt = OptionParser.new
  opt.on('-h', '--help') { usage; exit }
  opt.on('-c COMMAND', '--command COMMAND') { |v| command = v }
  opt.on('-f FORMAT', '--format FORMAT') { |v| format_type = v }
  opt.parse!(ARGV)

  begin
    require "bbiff/formatter/#{format_type}"
  rescue LoadError => e
    STDERR.puts "Error: Unknown format [#{format_type}]"
    exit 1
  end

  url = ARGV[0]

  if url =~ %r{\Ah?ttp://jbbs.shitaraba.net/bbs/read.cgi/(\w+)/(\d+)/(\d+)/?\z}
    ita = [$1, $2.to_i]
    sure = $3.to_i
  end

  thread = Bbs::C板.new(*ita).thread(sure)
  start_no = ARGV[1] ? ARGV[1].to_i : thread.last + 1
  start_polling(thread, start_no, command, format_type)
end
