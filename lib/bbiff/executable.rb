require 'unicode/display_width'

module Bbiff

class Executable
  class UsageError < StandardError
  end

  class LineIndicator
    def initialize(out = STDOUT)
      @width = 0
      @out = out
    end

    def set_line(str)
      clear
      if str[-1] == "\n"
        if str.rindex("\n") != str.size-1 || str.index("\n") < str.rindex("\n")
          raise 'multiline' 
        end

        @out.print str
        @width = 0
      else
        @out.print str
        @width = mbswidth(str)
      end
    end

    def newline
      @out.print "\n"
      @width = 0
    end

    def clear
      @out.print "\r#{' ' * @width}\r"
      @width = 0
    end

    def puts(str)
      set_line(str)
      newline
    end

    private

    def mbswidth(str)
      Unicode::DisplayWidth.of(str)
    end
  end

  def initialize
    @settings  = Settings.new
  end

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

  def get_board_settings(board)
    return board.settings
  rescue Bbs::Downloader::DownloadFailure => e
    STDERR.puts "Warning: 以下の場所から掲示板の設定が取得できませんでした。(#{e.response.message})"
    STDERR.puts board.settings_url
    return {'BBS_TITLE'=>'＜不明＞'}
  end

  def start_polling(thread, start_no)
    out = LineIndicator.new
    delay = @settings.current['delay_seconds']
    board_settings = get_board_settings(thread.board)
    thread_stop = (board_settings['BBS_THREAD_STOP'] || '1000').to_i

    puts "#{board_settings['BBS_TITLE']} − #{thread.title}(#{thread.last})"
    puts "    #{@settings.current['thread_url']}"

    loop do
      out.set_line "#{thread.title}(#{thread.last}) 新着レス確認中"

      thread.posts(parse_range("#{start_no}-")).each do |post|
        out.puts "-----"
        puts render_post(post)

        system(@settings.current['bbiff_show'],
               thread.title, post.to_s)

        sleep 1
      end

      start_no = thread.last + 1
      if start_no >= thread_stop
        out.puts "スレッドストップ"
        break 
      end

      delay.times do |i|
        j = i + 1
        out.set_line "#{thread.title}(#{thread.last}) 待機中 [#{'.'*j}#{' '*(delay - j)}]"
        sleep 1
      end
    end
  rescue Interrupt
    STDERR.puts "\nユーザー割り込みにより停止"
  rescue => e
    STDERR.puts "error occured"
    puts e.message
    puts e.backtrace
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
    if ARGV.include?('-h') || ARGV.include?('--help')
      raise UsageError
    end

    if ARGV.size < 1 && !@settings.current['thread_url']
      raise UsageError
    elsif ARGV.size < 1
      url = @settings.current['thread_url']
      thread = Bbs::create_thread(url)
    else
      url = ARGV[0]

      begin
        thread = Bbs::create_thread(url)
        @settings.current['thread_url'] = url
      rescue
        puts "URLが変です"
        usage
        exit 1
      end
    end

    start_no = ARGV[1] ? ARGV[1].to_i : thread.last + 1
    start_polling(thread, start_no)
  rescue UsageError
    usage
    exit 1
  ensure
    @settings.save
  end
end

end
