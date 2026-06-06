import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { timeout: { type: Number, default: 8000 } }

  connect() {
    this.closeTimer = window.setTimeout(() => this.close(), this.timeoutValue)
  }

  disconnect() {
    window.clearTimeout(this.closeTimer)
  }

  close() {
    window.clearTimeout(this.closeTimer)
    this.element.remove()
  }
}
