import { Controller } from "@hotwired/stimulus"

export default class MuteController extends Controller {
  static targets = ["mutedIcon", "unmutedIcon"]

  connect() {
    this.playSound = document.cookie.split('; ').some(cookie => cookie.trim().startsWith('playSound=true'))
  }

  toggle() {
    this.playSound = !this.playSound
    document.cookie = `playSound=${this.playSound};path=/;`
    this.updateIconVisibility()
  }

  updateIconVisibility() {
    this.mutedIconTarget.classList.toggle('hidden', this.playSound)
    this.unmutedIconTarget.classList.toggle('hidden', !this.playSound)
  }
}
