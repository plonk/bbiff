require 'spec_helper'

class Bbs::C板
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
    when "/bbs/rawmode.cgi/category/1/2/1-1"
      str = <<EOD
1<>予定地<>sage<>1970/01/01(木) 09:00:00<>テスト<><>
EOD
      return str.encode('EUC-JP')
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
  before do
    @board = Bbs::C板.new('category', 1)
    @thread = @board.thread(2)
  end

  it "基本的なアクセッサに値が入っている" do
    expect(@thread.id).to eq 2
    expect(@thread.title).to eq "テスト"
    expect(@thread.last).to eq 1
    expect(@thread.board).to eq @board
  end

  it "postsメソッド" do
    expect( @thread.posts(1..1) ).to be_an(Array)
    expect( @thread.posts(1..1).size ).to eq 1

    expect { @thread.posts("1-") }.to raise_error(ArgumentError)
  end

end

describe "Bbs::Post" do
  TEST_LINE = "1<>予定地<>sage<>1970/01/01(木) 09:00:00<>テスト<><>"

  before do
    @post = Bbs::Post.from_line( TEST_LINE )
  end

  it "from_lineクラスメソッドが動く" do
    expect(@post).to be_a(Bbs::Post)
  end

  it "レス番号" do
    expect(@post.no).to eq 1
  end

  it "名前" do
    expect(@post.name).to eq "予定地"
  end

  it "メール" do
    expect(@post.mail).to eq "sage"
  end

  it "日付け" do
    expect(@post.date).to eq Time.at(0)
  end

  it "文字列に戻せる" do
    expect(@post.to_s).to eq TEST_LINE
  end

end
