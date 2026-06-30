# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

pin "js-cookie", to: "https://cdn.jsdelivr.net/npm/js-cookie@3.0.8/dist/js.cookie.mjs"
pin "autosize", to: "https://cdn.jsdelivr.net/npm/autosize@6.0.1/dist/autosize.esm.js"

pin_all_from "app/javascript/controllers", under: "controllers"
