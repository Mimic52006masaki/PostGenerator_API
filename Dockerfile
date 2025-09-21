FROM ruby:3.3.0-slim

# 必要なパッケージをインストール
# (DBコンテナの準備を待つために pg_isready が必要)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev nodejs npm curl postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# 作業ディレクトリ
WORKDIR /app

# Bundler インストール
RUN gem install bundler

# GemfileとGemfile.lockを先にコピー
COPY Gemfile Gemfile.lock ./

# Gemをインストール
RUN bundle install

# アプリケーションコードをコピー
COPY . .

# entrypoint.shをコピーして実行権限を付与
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# ポート
EXPOSE 3001

# Railsサーバー起動（開発用）
CMD ["bin/rails", "server", "-p", "3001", "-b", "0.0.0.0"]
