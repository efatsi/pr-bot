import { Controller } from "@hotwired/stimulus"

export default class AudioController extends Controller {
  static values = { singleDing: Boolean }

  connect() {
    if (this.playSound()) {
      if (this.singleDingValue) {
        this.singleDing()
      } else {
        this.doubleDing()
      }
    }
  }

  singleDing() {
    this.element.play()
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
