import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["viewport"]

  connect() {
    requestAnimationFrame(() => {
      this.viewportTarget.scrollTop = this.viewportTarget.scrollHeight * 0.2
    })
  }
}
