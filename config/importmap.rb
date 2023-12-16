# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@rails/actioncable", to: "https://ga.jspm.io/npm:@rails/actioncable@7.1.2/app/assets/javascripts/actioncable.esm.js"
pin "stimulus-use", to: "https://ga.jspm.io/npm:stimulus-use@0.52.1/dist/index.js"
pin "controllers/util/transitions", to: "app/javascript/controllers/util/transitions.js"
pin_all_from "app/javascript/controllers", under: "controllers"
