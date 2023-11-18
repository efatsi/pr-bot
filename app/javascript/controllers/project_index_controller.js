import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggleWrapper", "toggleIcon", "money"]

  connect() {
    this.hidden = true
  }

  toggle(e) {
    e.preventDefault()
    console.log("toggle")

    if (this.hidden) {
      this.show()
    } else {
      this.hide()
    }

    this.hidden = !this.hidden
  }

  show() {
    this.toggleWrapperTarget.classList.remove("bg-gray-200")
    this.toggleWrapperTarget.classList.add("bg-indigo-600")

    this.toggleIconTarget.classList.remove("translate-x-0")
    this.toggleIconTarget.classList.add("translate-x-5")

    this.moneyTargets.forEach((money) => {
      money.classList.remove("hidden")
    })
  }

  hide() {
    this.toggleWrapperTarget.classList.remove("bg-indigo-600")
    this.toggleWrapperTarget.classList.add("bg-gray-200")

    this.toggleIconTarget.classList.remove("translate-x-5")
    this.toggleIconTarget.classList.add("translate-x-0")

    this.moneyTargets.forEach((money) => {
      money.classList.add("hidden")
    })
  }
}
