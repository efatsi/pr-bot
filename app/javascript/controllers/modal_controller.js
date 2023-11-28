import { Controller } from "@hotwired/stimulus"
import { enter, leave } from "controllers/util/transitions"

export default class extends Controller {
  static targets = ["wrapper", "body"]

  connect() {
    enter(this.wrapperTarget)
    enter(this.bodyTarget)

    this.element["modalController"] = this
  }

  close(e) {
    if (e) { e.preventDefault() }

    leave(this.wrapperTarget)
    leave(this.bodyTarget).then(() => {
      // Remove the modal element after the fade out so it doesn't blanket the screen
      this.element.remove()
    })
  }

  // Can set this up on the data-controller="modal" element w/
  // data-action="keyup@document->modal#closeOnEscape"
  closeOnEscape(e) {
    if (e.key === "Escape") {
      this.close()
    }
  }
}
