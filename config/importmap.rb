# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

# customディレクトリにあるJavaScriptコードをImportmapの設定に追加
# cf. app/views/layouts/application.html.erb, app/assets/config/manifest.js
pin_all_from "app/javascript/custom",      under: "custom"
