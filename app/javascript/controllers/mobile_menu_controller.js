import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]

  toggle() {
    const isHidden = this.menuTarget.classList.toggle("hidden")
    this.buttonTarget.classList.toggle("rotate-[360deg]", !isHidden)
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.buttonTarget.classList.remove("rotate-[360deg]")
  }
}
