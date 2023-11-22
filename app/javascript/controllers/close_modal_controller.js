import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const modal = document.querySelector('[data-controller="modal"]')
    modal.modalController.close()
  }
}
