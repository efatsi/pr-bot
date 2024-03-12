import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['lastConvo', 'allConvos']

  toggleCheckboxes(e) {
    if (this.hasLastConvoTarget && this.hasAllConvosTarget) {
      // only run this if both targets are present
      if (e.target == this.lastConvoTarget) {
        this.allConvosTarget.checked = false;
      } else if (e.target == this.allConvosTarget) {
        this.lastConvoTarget.checked = false;
      }
    }
  }
}
