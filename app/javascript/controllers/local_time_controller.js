import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    datetime: String,
    format: { type: String, default: "short" },
    accordionDate: String
  }

  connect() {
    this.render()
  }

  render() {
    const date = new Date(this.datetimeValue)
    const localDate = date.toLocaleDateString("en-CA") // YYYY-MM-DD format
    const locale = document.documentElement.lang || "es"

    // Check if fixture date differs from accordion date (crosses midnight)
    const showDate = this.hasAccordionDateValue && localDate !== this.accordionDateValue

    let options
    if (showDate) {
      options = { month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit", hour12: false }
    } else {
      switch (this.formatValue) {
        case "time":
          options = { hour: "2-digit", minute: "2-digit", hour12: false }
          break
        case "long":
          options = { weekday: "long", day: "numeric", month: "long", hour: "2-digit", minute: "2-digit", hour12: false }
          break
        default:
          options = { month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit", hour12: false }
      }
    }

    this.element.textContent = date.toLocaleString(locale, options)
  }
}
