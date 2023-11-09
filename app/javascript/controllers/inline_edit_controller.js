import { Controller } from "@hotwired/stimulus"

export default class InlineEditController extends Controller {
  static targets = [ "content", "form" ]

  connect() {
    console.log('InlineEditController#connect')

    console.log(this.contentTarget)
    console.log(this.formTarget)
  }

  toggleForm(e) {
    e.preventDefault()

    this.contentTarget.classList.toggle('hidden')
    this.formTarget.classList.toggle('hidden')
  }
}
