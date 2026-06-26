import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.panelPlaceholder = null
    this.layeredPanel = null
    this.ownerModalElement = null
    this.ownerModalController = null
    this.layeredActionHandlers = []
  }

  disconnect() {
    this.restorePanelFromWeekLayer()
  }

  handleToggle() {
    if (!this.element.open) {
      this.clearWeekPopoverPosition()
      return
    }

    document.querySelectorAll("details.event-popover[open]").forEach((popover) => {
      if (popover !== this.element) {
        popover.removeAttribute("open")
        popover.dispatchEvent(new Event("toggle"))
      }
    })

    this.positionWeekPopover()
  }

  closeFromOutside(event) {
    if (!this.element.open) return
    if (this.element.contains(event.target)) return

    this.close()
  }

  close() {
    this.element.removeAttribute("open")
    this.clearWeekPopoverPosition()
  }

  positionWeekPopover() {
    if (!this.element.classList.contains("event-popover--week")) return

    this.clearWeekPopoverPosition()

    const panel = this.element.querySelector(".event-popover__panel")
    if (!panel) return

    const gap = 8
    const weekView = this.element.closest(".calendar-week-view")
    const popoverLayer = weekView?.querySelector(".calendar-week-view__popover-layer")
    if (!weekView || !popoverLayer) return

    const triggerRect = this.element.getBoundingClientRect()
    this.movePanelToWeekLayer(panel, popoverLayer)

    const panelRect = panel.getBoundingClientRect()
    const scrollViewport = this.element.closest(".calendar-week-view__viewport")
    const viewportRect = scrollViewport?.getBoundingClientRect()
    const weekViewRect = weekView.getBoundingClientRect()
    const popoverLayerRect = popoverLayer.getBoundingClientRect()
    const visibleTop = viewportRect?.top ?? 0
    const visibleBottom = viewportRect?.bottom ?? window.innerHeight
    let top

    if (this.element.classList.contains("event-popover--all-day")) {
      top = Math.min(visibleTop + 100, visibleBottom - panelRect.height - gap) - weekViewRect.top
    } else {
      top = Math.max(triggerRect.top, visibleTop) - weekViewRect.top
    }

    top += weekViewRect.top - popoverLayerRect.top

    const left = this.element.classList.contains("event-popover--left")
      ? triggerRect.left - weekViewRect.left - panelRect.width - gap
      : triggerRect.right - weekViewRect.left + gap
    const layerLeft = left + weekViewRect.left - popoverLayerRect.left

    this.element.style.setProperty("--week-popover-top", `${top}px`)
    this.element.style.setProperty("--week-popover-left", `${layerLeft}px`)
    panel.style.setProperty("--week-popover-top", `${top}px`)
    panel.style.setProperty("--week-popover-left", `${layerLeft}px`)
    this.prepareLayeredPanelActions(panel)
    panel.classList.add("event-popover__panel--week-layered")
  }

  clearWeekPopoverPosition() {
    if (!this.element.classList.contains("event-popover--week")) return

    this.element.classList.remove("event-popover--positioned-week")
    this.element.style.removeProperty("--week-popover-top")
    this.element.style.removeProperty("--week-popover-left")
    this.restorePanelFromWeekLayer()
  }

  movePanelToWeekLayer(panel, popoverLayer) {
    if (!this.panelPlaceholder) {
      this.panelPlaceholder = document.createComment("event popover panel")
    }

    panel.before(this.panelPlaceholder)
    popoverLayer.appendChild(panel)
    this.layeredPanel = panel
    this.element.classList.add("event-popover--positioned-week")
  }

  restorePanelFromWeekLayer() {
    if (!this.panelPlaceholder || !this.layeredPanel) return

    const panel = this.layeredPanel

    panel.classList.remove("event-popover__panel--week-layered")
    panel.style.removeProperty("--week-popover-top")
    panel.style.removeProperty("--week-popover-left")
    this.restoreLayeredPanelActions(panel)
    this.panelPlaceholder.replaceWith(panel)
    this.layeredPanel = null
    this.ownerModalElement = null
    this.ownerModalController = null
  }

  prepareLayeredPanelActions(panel) {
    this.ownerModalElement = this.element.closest("[data-controller~='modal']")
    this.ownerModalController = this.application.getControllerForElementAndIdentifier(this.ownerModalElement, "modal")
    if (!this.ownerModalElement) return

    this.addLayeredActionHandler(panel, "[data-action*='modal#openEdit']", (event) => this.openOwnerModal(event, "openEdit"))
    this.addLayeredActionHandler(panel, "[data-action*='modal#openDelete']", (event) => this.openOwnerModal(event, "openDelete"))
  }

  restoreLayeredPanelActions(panel) {
    this.layeredActionHandlers.forEach(({ button, handler }) => {
      button.removeEventListener("click", handler)
    })
    this.layeredActionHandlers = []
  }

  addLayeredActionHandler(panel, selector, handler) {
    panel.querySelectorAll(selector).forEach((button) => {
      button.addEventListener("click", handler)
      this.layeredActionHandlers.push({ button, handler })
    })
  }

  openOwnerModal(event, actionName) {
    event.preventDefault()
    event.stopPropagation()

    const modalController = this.ownerModalController
    this.close()
    modalController?.[actionName]?.()
  }
}
