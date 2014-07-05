# はてブオフ会用サービス

# Requirements

- Node.js v0.10.29
- npm install coffee-script -g
- Mongodb v2.4.10


# Setup

```sh
sudo aptitude install build-essential mongodb
nave.sh use 0.10
npm install coffee-script -g
git clone https://github.com/hatebu-offkai/offkai.git
cd offkai
npm install
```


# Config

```sh
cp config/sample.yaml config/default.yaml
```
して、編集する。

# Startup

```sh
npm start
```

