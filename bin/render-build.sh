#!/usr/bin/env bash
# exit on error
set -o errexit
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate

# DBデータをクリアし、サンプルデータを追加する（チュートリアル固有）
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:migrate:reset
bundle exec rails db:seed
