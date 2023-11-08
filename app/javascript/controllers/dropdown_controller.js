import { Controller } from "@hotwired/stimulus"

export default class DropdownController extends Controller {
  static targets = ["panel"];

  toggle(e) {
    // if clicking a button or link, don't toggle
    if (e.target.tagName === "BUTTON" || e.target.tagName === "A") {
      return
    }

    this.panelTarget.classList.toggle("hidden");
  }
}
