import { Controller } from "@hotwired/stimulus"

export default class ToggleController extends Controller {
  static targets = ["content1", "content2"]

  toggleContent(e) {
    e.preventDefault()

    this.content1Target.classList.toggle('hidden')

    if (this.hasContent2Target) {
      this.content2Target.classList.toggle('hidden')
    }
  }
}
