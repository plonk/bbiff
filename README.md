# bbiff - したらば掲示板用新着レス通知プログラム

## 必要なもの

notify-send コマンド

    sudo apt-get libnotify-bin

## インストール

/usr/local 以下にインストールされます。

	sudo make install

`gem install bbiff`でインストールできるようにしたい

## 使い方

	bbiff スレッドのURL レス通知を始める番号

スレッドのURLは http://jbbs.shitaraba.net/bbs/read.cgi/カテゴリ/板ID/スレID/
の形式です。

## 開発・TODO

- ちゃんと動くか確認する
- bbiff.gemspecに名前とか説明とかを入れる
- gemにするならMakefileはいらなくなるはず
- .travis.ymlでテストするなら要編集
- ライセンスのファイルを作る
- moduleの中にまとめるべきかも

### gemとして公開する方法
`rake build`，`rake install`，`rake release`を使う．
[https://rubygems.org/](https://rubygems.org/)でユーザー登録し，完成したと思ったら，`rake release`で公開．
リリースごとにバージョンが上がっていないといけないので，間違ったものを公開すると，バージョンをもう一度あげて修正版を出すことになるので注意．



