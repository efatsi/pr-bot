import { Controller } from "@hotwired/stimulus"

export default class DropdownMenuController extends Controller {
  static targets = ["dropdown"]

  connect() {
    this.dropdownOpen = false

    // recognize when clicking outside of this.element and close the dropdown
    document.addEventListener('click', (e) => {
      if (this.dropdownOpen && !this.element.contains(e.target)) {
        this.toggle()
      }
    })
  }

  toggle() {
    this.dropdownOpen = !this.dropdownOpen

    if (this.dropdownOpen) {
      this.dropdownTarget.classList.remove('hidden')
    } else {
      this.dropdownTarget.classList.add('hidden')
    }
  }
}
