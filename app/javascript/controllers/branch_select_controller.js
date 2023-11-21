import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selectWrapper", "newBranchWrapper"]

  checkInputs() {
    if (this.selectWrapperTarget.querySelector("select").value === '+ new branch') {
      this.selectWrapperTarget.classList.add('hidden');

      this.newBranchWrapperTarget.classList.remove('hidden');
      this.newBranchWrapperTarget.querySelector("input").focus();
    }
  }

  revertInputs() {
    this.newBranchWrapperTarget.classList.add('hidden');

    this.selectWrapperTarget.classList.remove('hidden');
    this.selectWrapperTarget.querySelector("select").focus();
  }
}
