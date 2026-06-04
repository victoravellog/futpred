import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  open(event) {
    // Don't open modal if clicking on form inputs or buttons
    if (event.target.closest("form") || event.target.closest("button") || event.target.closest("input")) {
      return
    }

    this.dialogTarget.showModal()
    document.body.style.overflow = "hidden"
  }

  close() {
    this.dialogTarget.close()
    document.body.style.overflow = ""
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
