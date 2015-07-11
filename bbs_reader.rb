require 'net/http'
require 'uri'

module Bbs

class C板
  def initialize(カテゴリ, 掲示板番号)
    @カテゴリ = カテゴリ
    @掲示板番号 = 掲示板番号
    @設定URL = URI.parse( "http://jbbs.shitaraba.net/bbs/api/setting.cgi/#{カテゴリ}/#{掲示板番号}/" )
    @スレ一覧URL = URI.parse( "http://jbbs.shitaraba.net/#{カテゴリ}/#{掲示板番号}/subject.txt" )
  end

  def dat_url(スレッド番号)
    return URI.parse("http://jbbs.shitaraba.net/bbs/rawmode.cgi/#{@カテゴリ}/#{@掲示板番号}/#{スレッド番号}/")
  end

  def 設定
    応答 = Net::HTTP.start(@設定URL.host, @設定URL.port) { |http|
      http.get(@設定URL.path)
    }
    r = 応答.body
    return r.force_encoding("EUC-JP").encode("UTF-8")
  end

  def スレ一覧
    応答 = Net::HTTP.start(@スレ一覧URL.host, @スレ一覧URL.port) { |http|
      http.get(@スレ一覧URL.path)
    }
    r = 応答.body
    return r.force_encoding("EUC-JP").encode("UTF-8")
  end

  def dat(スレッド番号)
    url = dat_url(スレッド番号)
    応答 = Net::HTTP.start(url.host, url.port) { |http|
      p url
      http.get(url.path)
    }
    r = 応答.body
    return r.force_encoding("EUC-JP").encode("UTF-8")
  end

  def thread(スレッド番号)
    threads.find { |t| t.id == スレッド番号 }
  end

  def threads
    スレ一覧.each_line.map do |line|
      fail FormatError unless line =~ /^(\d+)\.cgi,([^(]+)\((\d+)\)$/
      id, title, last = $1.to_i, $2, $3.to_i
      Thread.new(self, id, title, last)
    end
  end
end

class Post
  attr_reader :no, :name, :mail, :date, :body

  def self.from_line(line)
    no, name, mail, date, body, = line.split('<>')
    Post.new(no, name, mail, date, body)
  end

  def initialize(no, name, mail, date, body)
    @no = no.to_i
    @name = name
    @mail = mail
    @date = str2time(date)
    @body = body
  end

  private

  def str2time(str)
    if str =~ %r{^(\d{4})/(\d{2})/(\d{2})\(.\) (\d{2}):(\d{2}):(\d{2})$}
      y, mon, d, h, min, sec = [$1, $2, $3, $4, $5, $6].map(&:to_i)
      Time.new(y, mon, d, h, min, sec)
    else
      fail ArgumentError
    end
  end
end

class Thread
  attr_reader :id, :title, :last, :board

  def initialize(board, id, title, last = 1)
    @board = board
    @id = id
    @title = title
    @last = last
  end

  def dat_url
    @board.dat_url(@id)
  end

  def posts(range)
    dat_for_range(range).each_line.map do |line|
      Post.from_line(line.chomp).tap do |post|
        # ついでに last を更新
        @last = [post.no, last].max
      end
    end
  end

  def dat_for_range(range)
    if range.last == Float::INFINITY
      query = "#{range.first}-"
    else
      query = "#{range.first}-#{range.last}"
    end
    url = URI(dat_url + query)
    res = Net::HTTP.start(url.host, url.port) { |http| http.get(url.path) }
    res.body.force_encoding("EUC-JP").encode("UTF-8")
  end
end

end # Module
# include Bbs
# 自板 = C板.new("game", 48538)
# # puts 自板.設定
# # puts 自板.スレ一覧
# t =  自板.thread(1416739363)

# p t.posts(900..950)

