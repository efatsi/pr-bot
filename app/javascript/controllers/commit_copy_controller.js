import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "source" ]

  useMessage(event) {
    event.preventDefault()

    const message = event.currentTarget.dataset.message
    const description = event.currentTarget.dataset.description || ''

    const fullMessage = `${message}${description ? '\n\n' + description : ''}`
    this.sourceTarget.value = fullMessage

    // if description, increase the rows on the textarea
    if (description) {
      this.sourceTarget.rows = 5
    } else {
      this.sourceTarget.rows = 2
    }
  }
}
