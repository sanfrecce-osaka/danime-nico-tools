# danime-nico-tools

danime-nico-toolsというサービスは、<br>
現状のdアニメストア ニコニコ支店では見たいアニメを見つけにくく、コメントが全く無いまたは少ないアニメが多いという問題を解決したい<br>
アニメをコメント付きで見たい人向けの、<br>
dアニメストア ニコニコ支店用検索サイトです。<br>
ユーザーはchrome拡張との連携で他動画のコメントの引用、及びアニメの検索ができ、<br>
本家dアニメストア ニコニコ支店とは違って、<br>
目当てのアニメを見つけやすい検索と公式チャンネル以外からもコメントを引用できる機能が備わっている事が特徴です。

## Requirement

- Ruby 2.5.1
- Rails 5.2.0

## Setup

```bash
$ brew install yarn
$ bin/setup
$ yarn install
$ bin/rails s
```

## Test
```bash
$ bin/rails spec
```

## Licence
MIT
