require 'spec_helper'

# render_post だけテストすれば全部のメソッドをテストすることが可能だけ
# ど、やっぱり全部のヘルパーメソッドにもテストを書いたほうがよさそう。

describe "レスの整形をするメソッド群" do

  it "render_nameが動く" do # ←英語風DSLの意味がない
    expect(render_name("ナナシ", "sage")).to eq "ナナシ"
  end

  it "render_resnoが動く" do
    expect(render_resno(1)).to eq "1"
  end

  it "indentが動く" do
    expect(indent(0, "a")).to eq "a"
    expect(indent(1, "a")).to eq " a"
    expect(indent(1, "a\nb\n")).to eq " a\n b\n"
  end

  it "render_bodyが動く" do
    expect(render_body("")).to eq "\n"
    expect(render_body("<br>")).to eq "    \n\n"
    expect(render_body("&#65374;")).to eq "    ～\n"
  end

  it "render_postが動く" do
    post = Bbs::Post.new("999", "名無しさん", "sage", "2011/11/11(金) 12:34:56", "ほげ")
    expect(render_post(post)).to eq "999：名無しさん：2011/11/11(金) 12:34:56\n    ほげ\n"
  end
end

describe "Integer extension" do
  it "en が動く" do
    expect(2.en).to eq "\x20\x20"
  end

  it "em が動く" do
    expect(1.em).to eq "\x20\x20"
  end
end
