module Bbiff

class Show
  class UsageError < StandardError
  end

  NOTIFY_SEND = 'notify-send'

  def usage
    STDERR.puts 'Usage: bbiff-show RES_LINE'
  end

  def main
    if ARGV.size != 1
      raise UsageError
    end

    post = Bbs::Post.from_line(ARGV[0])
    notify_send = ENV['BBIFF_NOTIFY_SEND'] || 
                  (`which #{NOTIFY_SEND}` != "" ? NOTIFY_SEND : 'echo')
    system("#{notify_send} #{Shellwords.escape(render_post(post))}")
    
  rescue UsageError
    usage
  end

end

end

