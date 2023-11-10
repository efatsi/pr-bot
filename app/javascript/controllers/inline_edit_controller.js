import { Controller } from "@hotwired/stimulus"

export default class InlineEditController extends Controller {
  static targets = ["content", "form", "toggle"]

  toggleForm(e) {
    e.preventDefault()

    this.contentTarget.classList.toggle('hidden')
    this.formTargets.forEach(form => form.classList.toggle('hidden'))
    this.toggleTarget.textContent = this.formTarget.classList.contains('hidden') ? 'Edit' : 'Cancel'
  }
}
