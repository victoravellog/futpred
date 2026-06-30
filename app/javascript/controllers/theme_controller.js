import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { theme: String }

  switch(event) {
    document.body.dataset.theme = this.themeValue
  }
}
