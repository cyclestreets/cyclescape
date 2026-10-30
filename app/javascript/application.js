import { Turbo } from '@hotwired/turbo-rails'
import { Application } from '@hotwired/stimulus'
import { eagerLoadControllersFrom } from '@hotwired/stimulus-loading'

const application = Application.start()
eagerLoadControllersFrom('controllers', application)

Turbo.config.drive.enabled = false
