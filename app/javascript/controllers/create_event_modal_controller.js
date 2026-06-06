import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]
  static values = { open: Boolean }

  connect() {
    if (this.openValue) {
      this.open()
    }
  }

  disconnect() {
    document.body.style.overflow = ""
  }

  open() {
    this.overlayTarget.removeAttribute("hidden")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.overlayTarget.setAttribute("hidden", "hidden")
    document.body.style.overflow = ""
  }

  closeFromBackdrop(event) {
    if (event.target === this.overlayTarget) {
      this.close()
    }
  }
}
