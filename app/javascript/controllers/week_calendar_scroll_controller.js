import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["viewport"]
  static values = {
    hour: { type: Number, default: 6 },
    hourHeight: { type: Number, default: 64 }
  }

  connect() {
    requestAnimationFrame(() => {
      this.viewportTarget.scrollTop = this.hourValue * this.hourHeightValue
    })
  }
}
