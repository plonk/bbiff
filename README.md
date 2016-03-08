# bbiff - したらば掲示板用新着レス通知プログラム

## 必要なもの

notify-send コマンド

    sudo apt-get libnotify-bin

## インストール

`gem install bbiff` でインストールできます。

## 使い方

	bbiff スレッドのURL レス通知を始める番号

スレッドのURLは http://jbbs.shitaraba.net/bbs/read.cgi/カテゴリ/板ID/スレID/
の形式です。

単に

	bbiff

とすると、前回監視したスレッドを監視します。

## 開発・TODO

- .travis.ymlでテストするなら要編集
- moduleの中にまとめるべきかも

## リリース

ver 0.1.0
  * gem 化した。(DoG-peer さん)
  
ver 0.1.2
  * notify-send コマンドがインストールされていない場合は echo コマンド
    を利用するようにした。(raduwen さん)

ver 0.1.3
  * インストールすると動かなくなっていたバグを修正。

ver 0.2.0
  * プログラムの動作状態を表示するようにした。
  * 設定ファイルを ~/.config/bbiff 以下に置くようにした。
  * 最後に監視したスレッドを覚えておいて、URLを省略した時のデフォルト
    にするようにした。

## 作者

予定地 <plonk@piano.email.ne.jp>
