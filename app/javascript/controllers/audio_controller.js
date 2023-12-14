import { Controller } from "@hotwired/stimulus"

export default class AudioController extends Controller {
  connect() {
    if (this.playSound()) {
      this.doubleDing()
    }
  }

  doubleDing() {
    this.element.play()
    setTimeout(() => {
      this.element.currentTime = 0
      this.element.play()
    }, 175)
  }

  playSound() {
    return document.cookie.split('; ').some(cookie => cookie.trim().startsWith('playSound=true'))
  }
}
