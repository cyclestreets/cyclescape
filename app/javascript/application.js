import '@hotwired/turbo-rails'
import { Application } from '@hotwired/stimulus'
import { eagerLoadControllersFrom } from '@hotwired/stimulus-loading'

const application = Application.start()
eagerLoadControllersFrom('controllers', application)

Turbo.session.drive = false
