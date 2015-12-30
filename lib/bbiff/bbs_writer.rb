require 'bbiff/bbs_reader'
require 'kconv'

module Bbiff


class Thread
  def post!(post)
    refurl= refurl()
    posturl   = URI.parse posturl()
    param = mkparam(post)

    req = Net::HTTP::Post.new(posturl.path, {
      "Referer" => refurl,
      "Agent"   => "bbiff v#{VERSION}"
    })
    req.set_form_data(param)

    res = Net::HTTP.start(posturl.host, posturl.port) { |http|
      http.request(req)
    }

    case res
    when Net::HTTPSuccess
      true
    else
      false
    end
  end

  private 

  def refurl()
    "http://jbbs.shitaraba.net/bbs/read.cgi/#{@board.カテゴリ}/#{@board.掲示板番号}/#{@id}/"
  end

  def posturl()
    "http://jbbs.shitaraba.net/bbs/write.cgi/#{@board.カテゴリ}/#{@board.掲示板番号}/#{@id}/" 
  end

  def mkparam(post)
    param = {
      DIR: @board.カテゴリ,
      BBS: @board.掲示板番号,
      KEY: @id,
      TIME: Time.now.to_i,
      NAME: post.name,
      MAIL: post.mail,
      MESSAGE: post.body
    }
    [:NAME, :MAIL, :MESSAGE].each{|k|
      param[k] ||= ""
      param[k] = param[k].toeuc
    }
    param
  end

end

end # module
