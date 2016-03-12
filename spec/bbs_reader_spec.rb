require 'spec_helper'

class Bbs::C板
  private
  # その他のメソッドのテストの為にダウンロードメソッドを上書きする。
  #
  # カテゴリ: category
  # 掲示板ID: 1
  # スレッドID: 2
  #
  # という体。
  def ダウンロード(url)
    case url.path
    when "/category/1/subject.txt"
      str = <<EOD
2.cgi,テスト(1)
EOD
      return str.encode("EUC-JP")
    when "/bbs/rawmode.cgi/category/1/2"
      fail 'unimplemented'
    when "/bbs/api/setting.cgi/category/1/"
      str = <<EOD
TOP=http://jbbs.shitaraba.net/category/1/
DIR=category
BBS=1
CATEGORY=カテゴリ
BBS_ADULT=0
BBS_THREAD_STOP=1000
BBS_NONAME_NAME=リスナーさん
BBS_DELETE_NAME=＜削除＞
BBS_TITLE=テスト
BBS_COMMENT=テスト
EOD
      return str.encode("EUC-JP")
    else
      fail "知らないURL: #{url.inspect}"
    end
  end
end

describe "Bbs::C板" do
  before do
    @board = Bbs::C板.new('category', 1)
  end

  it "設定を取って来られる" do
    dic = @board.設定
    expect(
      dic['BBS_TITLE']
    ).to eq 'テスト'
  end

  it "スレッド一覧が取得できる" do
    expect(
      @board.threads.size
    ).to eq 1
  end

  it "番号でスレッドが取得できる" do
    expect(
      @board.thread(2)
    ).to be_a(Bbs::Thread)

    # 存在しないスレッドは nil を返す
    expect(
      @board.thread(999)
    ).to be_nil
  end

end

describe "Bbs::Thread" do
end

describe "Bbs::Post" do
end
