import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { parentId: Number }

  connect() {
    const childEventLine = document.querySelector(`#child-event-line-${this.parentIdValue}`)
    childEventLine.classList.remove('hidden')
  }
}

