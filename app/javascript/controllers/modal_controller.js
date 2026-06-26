import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "editOverlay", "deleteOverlay"]
  static values = { open: Boolean }

  // Lifecycle

  connect() {
    this.overlayPlaceholders = new Map()
    this.overlayCloseHandlers = new Map()

    if (this.openValue) {
      this.openInitialOverlay()
    }
  }

  disconnect() {
    this.restoreBodyOverlays()
    this.unlockBodyScroll()
  }

  // Create event modal

  openCreate() {
    if (this.hasOverlayTarget) {
      this.showOverlay(this.overlayTarget)
    }
  }

  closeCreate() {
    if (this.hasOverlayTarget) {
      this.hideOverlay(this.overlayTarget)
    }
  }

  // Edit event modal

  openEdit() {
    if (this.hasEditOverlayTarget) {
      this.resetEditForm()
      this.showOverlay(this.editOverlayTarget)
    }
  }

  closeEdit() {
    if (this.hasEditOverlayTarget) {
      this.hideOverlay(this.editOverlayTarget)
    }
  }

  // Delete confirmation modal

  openDelete() {
    if (this.hasDeleteOverlayTarget) {
      this.showOverlay(this.deleteOverlayTarget)
    }
  }

  closeDelete() {
    if (this.hasDeleteOverlayTarget) {
      this.hideOverlay(this.deleteOverlayTarget)
    }
  }

  // Automatic opening after failed form submissions

  openInitialOverlay() {
    if (this.hasOverlayTarget) {
      this.openCreate()
    } else if (this.hasEditOverlayTarget) {
      this.openEdit()
    }
  }

  // Shared overlay behavior

  showOverlay(overlay) {
    this.moveOverlayToBody(overlay)
    this.addPortaledCloseHandlers(overlay)
    overlay.removeAttribute("hidden")
    this.lockBodyScroll()
  }

  hideOverlay(overlay) {
    overlay.setAttribute("hidden", "hidden")
    this.removePortaledCloseHandlers(overlay)
    this.restoreOverlayFromBody(overlay)
    this.unlockBodyScroll()
  }

  lockBodyScroll() {
    document.body.style.overflow = "hidden"
  }

  unlockBodyScroll() {
    document.body.style.overflow = ""
  }

  moveOverlayToBody(overlay) {
    if (overlay.parentElement === document.body) return

    const placeholder = document.createComment("event modal overlay")
    overlay.before(placeholder)
    this.overlayPlaceholders.set(overlay, placeholder)
    document.body.appendChild(overlay)
  }

  restoreOverlayFromBody(overlay) {
    const placeholder = this.overlayPlaceholders.get(overlay)
    if (!placeholder) return

    placeholder.replaceWith(overlay)
    this.overlayPlaceholders.delete(overlay)
  }

  restoreBodyOverlays() {
    Array.from(this.overlayPlaceholders.keys()).forEach((overlay) => {
      this.removePortaledCloseHandlers(overlay)
      this.restoreOverlayFromBody(overlay)
    })
  }

  resetEditForm() {
    this.editOverlayTarget.querySelectorAll("form").forEach((form) => {
      form.reset()
      form.dispatchEvent(new Event("reset", { bubbles: true }))
    })
  }

  addPortaledCloseHandlers(overlay) {
    if (this.overlayCloseHandlers.has(overlay)) return

    const clickHandler = (event) => {
      if (event.target.closest("[data-action*='modal#close']")) {
        event.preventDefault()
        this.hideOverlay(overlay)
      }
    }

    overlay.addEventListener("click", clickHandler)
    this.overlayCloseHandlers.set(overlay, clickHandler)
  }

  removePortaledCloseHandlers(overlay) {
    const clickHandler = this.overlayCloseHandlers.get(overlay)
    if (!clickHandler) return

    overlay.removeEventListener("click", clickHandler)
    this.overlayCloseHandlers.delete(overlay)
  }
}
