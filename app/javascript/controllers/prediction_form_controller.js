import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "submitButton"]

  connect() {
    this.element.addEventListener("turbo:submit-start", this.onSubmitStart.bind(this))
    this.element.addEventListener("turbo:submit-end", this.onSubmitEnd.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-start", this.onSubmitStart.bind(this))
    this.element.removeEventListener("turbo:submit-end", this.onSubmitEnd.bind(this))
  }

  onSubmitStart() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add("opacity-50")
    }
  }

  onSubmitEnd(event) {
    if (event.detail.success) {
      this.showSuccessAnimation()
    }
  }

  showSuccessAnimation() {
    this.element.classList.add("prediction-saved")
    setTimeout(() => {
      this.element.classList.remove("prediction-saved")
    }, 1000)
  }
}
