import { Controller } from "@hotwired/stimulus"

export default class AutofocusController extends Controller {
  connect() {
    this.element.focus()
    this.element.scrollIntoView({ behavior: "smooth", block: "center" })
  }
}
