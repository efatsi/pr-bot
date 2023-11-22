import { Controller } from "@hotwired/stimulus"

import { enter, leave } from "controllers/util/transitions"

export default class extends Controller {
  connect() {
    enter(this.element)
  }

  close() {
    leave(this.element).then(() => {
      this.element.remove()
    })
  }
}
