import { Controller } from "@hotwired/stimulus"

export default class ImageEditController extends Controller {
  destroy() {
    this.element.remove()
  }
}
