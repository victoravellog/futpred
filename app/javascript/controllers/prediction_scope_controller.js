import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "dialog"]
  static values = {
    fixtureId: Number,
    organizationTournamentId: Number
  }

  connect() {
    this.submitting = false
  }

  intercept(event) {
    if (this.submitting) return
    event.preventDefault()
    this.showDialog()
  }

  showDialog() {
    const template = this.dialogTarget
    const dialog = template.content.cloneNode(true)
    this.dialogElement = dialog.firstElementChild
    document.body.appendChild(this.dialogElement)

    const buttons = this.dialogElement.querySelectorAll("button")
    buttons.forEach(button => {
      button.addEventListener("click", (e) => {
        e.preventDefault()
        e.stopPropagation()
        const action = button.dataset.scopeAction
        if (action === "this") this.applyToThis()
        else if (action === "all") this.applyToAll()
        else if (action === "cancel") this.cancel()
      })
    })

    this.dialogElement.addEventListener("click", (e) => {
      if (e.target === this.dialogElement) {
        this.cancel()
      }
    })
  }

  applyToThis() {
    this.submitWithScope("current")
  }

  applyToAll() {
    this.submitWithScope("all")
  }

  submitWithScope(scope) {
    const form = this.formTarget
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = "apply_scope"
    input.value = scope
    form.appendChild(input)

    this.closeDialog()
    this.submitting = true
    form.requestSubmit()
  }

  cancel() {
    this.closeDialog()
  }

  closeDialog() {
    if (this.dialogElement) {
      this.dialogElement.remove()
      this.dialogElement = null
    }
  }
}
