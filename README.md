# はてブオフ会用サービス

# Requirements

- Node.js v0.10.29
- npm install coffee-script -g
- Mongodb v2.4.10


# Setup

```sh
git clone .../offkai/
cd offkai
npm install
```


# Config

1. http://developer.hatena.ne.jp/ja/documents/auth/apis/oauth/consumer へアクセスして、説明文を読む。
2. http://www.hatena.ne.jp/oauth/develop へアクセスして、適当な名前でアプリを追加して、ConsumerKeyを得る。

```sh
cp config/sample.yaml config/default.yaml
```
して、編集する。

# Startup

```sh
npm start
```

