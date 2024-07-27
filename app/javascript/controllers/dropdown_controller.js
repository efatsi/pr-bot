import { Controller } from "@hotwired/stimulus"

export default class DropdownController extends Controller {
  static targets = ["panel"];

  toggle(e) {
    // if clicking a button or link, or any of their parents, don't toggle
    if (e.target.closest("button, a")) {
      return;
    }

    this.panelTarget.classList.toggle("hidden");
  }
}
