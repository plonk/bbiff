require 'thor'
require 'daemonize'
require_relative 'bbs_reader'
require_relative 'res_format'
require_relative 'user_screen'

ITA = ['game', 48538]
SURE = 1432755949

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

def start_polling thread
  screen = UserScreen.new(Etc.getlogin)
  loop do
    thread.posts(parse_range("#{thread.last+1}-")).each do |post|
      screen.write("\n")
      screen.write(render_post(post))
    end
    sleep 10
  end
rescue Interrupt
  puts "終了します。"
end

class Bbiff < Thor
  desc 'list', 'スレッド一覧'
  def list
    ita = Bbs::C板.new(*ITA)
    puts ita.スレ一覧
  end

  desc 'show', 'レス表示'
  def show(range = 'all')
    text = Bbs::C板.new(*ITA)
      .thread(SURE)
      .posts(parse_range(range))
      .map { |post| render_post post }
      .join("\n")
    puts text
  end

  desc 'poll', '新着レス待機'
  def poll(daemonize = nil)
    if daemonize
      Daemons.daemonize
      UserScreen.new(Etc.getlogin).write "\nPID = #{Process.pid} でデーモン化されました。\n"
    end
    start_polling(Bbs::C板.new(*ITA).thread(SURE))
  end

  desc 'settings', '板の設定'
  def settings
    puts Bbs::C板.new(*ITA).設定
  end
end

Bbiff.start(ARGV)
