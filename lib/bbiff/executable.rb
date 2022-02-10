require 'unicode/display_width'

module Bbiff

class Executable
  class UsageError < StandardError
  end

  class LineIndicator
    def initialize(out = STDOUT)
      @width = 0
      @out = out
      @closed = false
    end

    def set_line(str)
      raise_if_closed!

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
      raise_if_closed!

      @out.print "\n"
      @width = 0
    end

    def clear
      raise_if_closed!

      @out.print "\r#{' ' * @width}\r"
      @width = 0
    end

    def puts(str)
      raise_if_closed!

      set_line(str)
      newline
    end

    def raise_if_closed!
      if @closed
        raise 'Closed LineIndicator'
      end
    end

    def close
      if @closed
        raise 'already closed LineIndicator'
      else
        @out.puts if @width > 0
        @closed = true
      end
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

  def show(title, post)
    notify_send = ENV['BBIFF_NOTIFY_SEND'] || (`which notify-send` != "" ? 'notify-send' : 'echo')
    system("#{notify_send} #{Shellwords.escape(title)} #{Shellwords.escape(render_post(post))}")
  end

  RETRY_INTERVAL_SECONDS = 3

  def start_polling(thread, start_no)
    out = LineIndicator.new
    begin
      delay = @settings.current['delay_seconds']
      board_settings = get_board_settings(thread.board)
      thread_stop = (board_settings['BBS_THREAD_STOP'] || '1000').to_i

      puts "#{board_settings['BBS_TITLE']} − #{thread.title}(#{thread.last})"
      puts "    #{@settings.current['thread_url']}"

      loop do
        out.set_line "#{thread.title}(#{thread.last}) 新着レス確認中"

        posts = thread.posts(parse_range("#{start_no}-"),
          { long_polling: @settings.current['long_polling'] })
        t = Time.now
        posts.each do |post|
          out.puts "-----"
          unless @settings.current['no_render']
            puts render_post(post)
          end

          show(thread.title, post)
        end

        start_no = thread.last + 1
        if start_no > thread_stop
          out.puts "スレッドストップ"
          break
        end

        d = [delay-(Time.now-t), 0].max.round
        d.times do |i|
          j = i + 1
          out.set_line "#{thread.title}(#{thread.last}) 待機中 [#{'.'*j}#{' '*(d - j)}]"
          sleep 1
        end
      end
    ensure
      out.close
    end
  rescue Interrupt
    STDERR.puts "ユーザー割り込みにより停止"
  rescue => e
    STDERR.print "Error: "
    STDERR.puts e.message
    STDERR.puts e.backtrace if $DEBUG
    STDERR.puts "#{RETRY_INTERVAL_SECONDS}秒後にリトライ"
    sleep RETRY_INTERVAL_SECONDS
    retry
  end

  COPYRIGHT = "Copyright © 2016-2022 Yoteichi"
  
  def usage
    STDERR.puts "Usage: bbiff [OPTIONS] [http://jbbs.shitaraba.net/bbs/read.cgi/CATEGORY/BOARD_ID/THREAD_ID/] [START_NUMBER]"

    STDERR.puts <<"EOD"

Bbiff version #{Bbiff::VERSION}
#{COPYRIGHT}

          -h, --help
          -v, --version
          --no-render
          --debug
          --long-polling (for Genkai)
          --delay-seconds=N
EOD
  end

  def version
    STDERR.puts <<"EOD"
Bbiff version #{Bbiff::VERSION}
#{COPYRIGHT}
EOD
  end

  def main
    args = []
    ARGV.each do |arg|
      case arg
      when '-h', '--help'
        raise UsageError
      when '-v', '--version'
        version
        exit 0
      when '--no-render'
        @settings.current['no_render'] = true
      when '--debug'
        $DEBUG = true
      when '--long-polling'
        @settings.current['long_polling'] = true
      when /\A--delay-seconds=(.+)\z/
        s = $1
        if s =~ /\A\d+\z/
          @settings.current['delay_seconds'] = s.to_i
        else
          STDERR.puts "delay-seconds must be a non-negative integer"
          raise UsageError
        end
      when /\A-/
        STDERR.puts "invalid option #{arg.inspect}"
        raise UsageError
      else
        args << arg
      end
    end

    if args.size < 1
      raise UsageError
    else
      url = args[0]
    end

    begin
      thread = Bbs::create_thread(url)
      @settings.current['thread_url'] = url
    rescue Bbs::Downloader::DownloadFailure => e
      STDERR.puts "#{e.response.code} #{e.response.msg}: #{e.response.uri}"
      exit 1
    rescue => e
      STDERR.puts e.message
      exit 1
    end
    if thread.nil?
      STDERR.puts "スレッドのURLとして解釈できませんでした。(#{url})"
      exit 1
    end

    start_no = args[1] ? args[1].to_i : thread.last + 1
    start_polling(thread, start_no)
  rescue UsageError
    usage
    exit 1
  end
end

end
