# ansible-test/Dockerfile
FROM debian:bullseye

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    ansible \
    sudo \
    ssh \
    vim \
    && apt-get clean

# Ansibleのバージョン確認
RUN ansible --version

# 作業ディレクトリの設定
WORKDIR /ansible
