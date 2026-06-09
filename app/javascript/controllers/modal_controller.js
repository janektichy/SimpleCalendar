import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "editOverlay", "deleteOverlay"]
  static values = { open: Boolean }

  // Lifecycle

  connect() {
    if (this.openValue) {
      this.openInitialOverlay()
    }
  }

  disconnect() {
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

  closeCreateFromBackdrop(event) {
    if (this.hasOverlayTarget && event.target === this.overlayTarget) {
      this.closeCreate()
    }
  }

  // Edit event modal

  openEdit() {
    if (this.hasEditOverlayTarget) {
      this.showOverlay(this.editOverlayTarget)
    }
  }

  closeEdit() {
    if (this.hasEditOverlayTarget) {
      this.hideOverlay(this.editOverlayTarget)
    }
  }

  closeEditFromBackdrop(event) {
    if (this.hasEditOverlayTarget && event.target === this.editOverlayTarget) {
      this.closeEdit()
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

  closeDeleteFromBackdrop(event) {
    if (this.hasDeleteOverlayTarget && event.target === this.deleteOverlayTarget) {
      this.closeDelete()
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
    overlay.removeAttribute("hidden")
    this.lockBodyScroll()
  }

  hideOverlay(overlay) {
    overlay.setAttribute("hidden", "hidden")
    this.unlockBodyScroll()
  }

  lockBodyScroll() {
    document.body.style.overflow = "hidden"
  }

  unlockBodyScroll() {
    document.body.style.overflow = ""
  }
}
