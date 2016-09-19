module Bbiff

class Show
  class UsageError < StandardError
  end

  NOTIFY_SEND = 'notify-send'

  def usage
    STDERR.puts 'Usage: bbiff-show TITLE RES_LINE'
  end

  def main
    if ARGV.size != 2
      raise UsageError
    end

    title = ARGV[0]
    post = Bbs::Post.from_s(ARGV[1])
    notify_send = ENV['BBIFF_NOTIFY_SEND'] || 
                  (`which #{NOTIFY_SEND}` != "" ? NOTIFY_SEND : 'echo')
    system("#{notify_send} #{Shellwords.escape(title)} #{Shellwords.escape(render_post(post))}")
    
  rescue UsageError
    usage
  end

end

end

