import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "trigger"]

  open() {
    this.panelTarget.hidden = false
    this.triggerTarget.setAttribute("aria-expanded", "true")
  }

  close() {
    this.panelTarget.hidden = true
    this.triggerTarget.setAttribute("aria-expanded", "false")
  }

  closeFromOutside(event) {
    if (this.panelTarget.hidden) return
    if (this.element.contains(event.target)) return

    this.close()
  }
}
