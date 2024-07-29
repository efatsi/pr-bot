import { Controller } from "@hotwired/stimulus"

export default class FileOpenerController extends Controller {
  connect() {
    setInterval(this.setHref.bind(this), 250)

    this.inAppPath = this.element.getAttribute('data-in-app-path');
    this.vsCodePath = this.element.getAttribute('data-vs-code-path');
  }

  setHref() {
    const selectedFileOpener = this.getCookie('selectedFileOpener');

    if (selectedFileOpener === 'in_app') {
      this.element.setAttribute('href', this.inAppPath);
    } else if (selectedFileOpener === 'vs_code') {
      this.element.setAttribute('href', this.vsCodePath);
    }
  }

  getCookie(name) {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop().split(';').shift();
  }
}
