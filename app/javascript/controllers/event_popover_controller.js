import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  handleToggle() {
    if (!this.element.open) return

    document.querySelectorAll("details.event-popover[open]").forEach((popover) => {
      if (popover !== this.element) {
        popover.removeAttribute("open")
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
  }

  positionWeekPopover() {
    if (!this.element.classList.contains("event-popover--week")) return

    this.element.classList.remove("event-popover--up", "event-popover--down", "event-popover--left", "event-popover--right")
    this.element.style.removeProperty("--week-popover-top")

    const panel = this.element.querySelector(".event-popover__panel")
    const viewport = this.element.closest(".calendar-week-view__viewport")
    if (!panel || !viewport) return

    const gap = 8
    const triggerRect = this.element.getBoundingClientRect()
    const viewportRect = viewport.getBoundingClientRect()
    const panelHeight = panel.offsetHeight
    const spaceBelow = viewportRect.bottom - triggerRect.bottom
    const spaceAbove = triggerRect.top - viewportRect.top

    if (this.element.classList.contains("event-popover--all-day")) {
      this.positionAllDayWeekPopover(panelHeight, triggerRect, viewportRect, gap)
    } else if (spaceBelow >= panelHeight + gap || spaceBelow >= spaceAbove) {
      this.element.classList.add("event-popover--down")
    } else {
      this.element.classList.add("event-popover--up")
    }
  }

  positionAllDayWeekPopover(panelHeight, triggerRect, viewportRect, gap) {
    const dayColumn = this.element.closest(".calendar-week-view__day-column")
    const dayColumns = Array.from(this.element.closest(".calendar-week-view__grid")?.querySelectorAll(".calendar-week-view__day-column") || [])
    const dayIndex = dayColumns.indexOf(dayColumn)

    this.element.classList.add(dayIndex >= 4 ? "event-popover--left" : "event-popover--right")

    const visibleTop = viewportRect.top + 120
    const visibleBottom = viewportRect.bottom - gap
    const desiredTop = Math.max(visibleTop, Math.min(triggerRect.top + gap, visibleBottom - panelHeight))

    this.element.style.setProperty("--week-popover-top", `${desiredTop - triggerRect.top}px`)
  }
}
