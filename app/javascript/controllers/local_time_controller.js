import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    datetime: String,
    format: { type: String, default: "short" }
  }

  connect() {
    this.render()
  }

  render() {
    const date = new Date(this.datetimeValue)

    let options
    switch (this.formatValue) {
      case "time":
        options = { hour: "2-digit", minute: "2-digit" }
        break
      case "long":
        options = { weekday: "long", month: "long", day: "numeric", hour: "2-digit", minute: "2-digit" }
        break
      default:
        options = { month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit" }
    }

    this.element.textContent = date.toLocaleString(undefined, options)
  }
}
