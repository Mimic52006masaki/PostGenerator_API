#!/bin/bash
set -e

# Railsのserver.pidが残っていると起動に失敗する場合があるため削除
rm -f /app/tmp/pids/server.pid

# データベースの作成とマイグレーションを実行
# (docker-compose.ymlのhealthcheckでDBの準備を待機済み)
bundle exec rails db:prepare

# CMDで渡されたコマンドを実行 (Railsサーバーの起動)
exec "$@"