import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { active: String }

  connect() {
    this.show(this.activeValue || "account")
  }

  switch(event) {
    this.activeValue = event.currentTarget.dataset.settingsTabsPanelParam
    this.show(event.currentTarget.dataset.settingsTabsPanelParam)
  }

  show(activePanel) {
    this.tabTargets.forEach((tab) => {
      const isActive = tab.dataset.settingsTabsPanelParam === activePanel
      tab.classList.toggle("is-active", isActive)
      tab.setAttribute("aria-selected", isActive)
    })

    this.panelTargets.forEach((panel) => {
      panel.hidden = panel.dataset.settingsTabsPanel === activePanel ? false : true
    })
  }
}
