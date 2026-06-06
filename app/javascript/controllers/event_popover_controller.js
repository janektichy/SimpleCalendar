import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  handleToggle() {
    if (!this.element.open) return

    document.querySelectorAll("details.event-popover[open]").forEach((popover) => {
      if (popover !== this.element) {
        popover.removeAttribute("open")
      }
    })
  }

  closeFromOutside(event) {
    if (!this.element.open) return
    if (this.element.contains(event.target)) return

    this.close()
  }

  close() {
    this.element.removeAttribute("open")
  }
}
