import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["allDay", "startTime", "endTime", "repeatToggle", "repeatFields", "repeatInput"]

  connect() {
    this.refreshState()
  }

  refreshState() {
    this.previousStartTime = this.startTimeTarget.value
    this.toggleAllDay()
    this.toggleRepeat()
  }

  handleStartTimeChange() {
    const previousDefault = this.shiftTime(this.previousStartTime, 60)

    if (this.endTimeTarget.value === previousDefault) {
      this.endTimeTarget.value = this.shiftTime(this.startTimeTarget.value, 60)
    }

    this.previousStartTime = this.startTimeTarget.value
  }

  rememberEndTime() {
    this.previousStartTime = this.startTimeTarget.value
  }

  toggleAllDay() {
    const disableTime = this.allDayTarget.checked
    this.startTimeTarget.disabled = disableTime
    this.endTimeTarget.disabled = disableTime
  }

  toggleRepeat() {
    const enabled = this.repeatToggleTarget.checked
    this.repeatFieldsTarget.classList.toggle("is-disabled", !enabled)

    this.repeatInputTargets.forEach((input) => {
      input.disabled = !enabled
    })
  }

  shiftTime(timeValue, minutes) {
    const [hours, mins] = timeValue.split(":").map(Number)
    const totalMinutes = (hours * 60 + mins + minutes + 1440) % 1440
    const shiftedHours = String(Math.floor(totalMinutes / 60)).padStart(2, "0")
    const shiftedMins = String(totalMinutes % 60).padStart(2, "0")

    return `${shiftedHours}:${shiftedMins}`
  }
}
