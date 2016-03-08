module Bbiff

class Show
  class < UsageError
  end

  def usage
    STDERR.puts 'Usage: bbiff-show RES_LINE'
  end

  def main
    if ARGV.size != 1
      raise UsageError
    end

    post = Bbs::from_line(ARGV[0])
    puts render_post(post)
    
  rescue UsageError
    usage
  end

end

end
