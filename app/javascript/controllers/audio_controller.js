import { Controller } from "@hotwired/stimulus"

export default class AudioController extends Controller {
  connect() {
    this.doubleDing()
  }

  doubleDing() {
    this.element.play()
    setTimeout(() => {
      this.element.currentTime = 0
      this.element.play()
    }, 175)
  }
}
