import { Controller } from "@hotwired/stimulus"

export default class DiffViewController extends Controller {
  static targets = ["mutedIcon", "unmutedIcon"]

  connect() {
    const diffElement = this.element.querySelector("code")

    // wrap the diff lines with span tags to apply different styles
    diffElement.innerHTML = diffElement.innerHTML.split("\n").map(line => {
      if (/^--- \w\//.test(line)) {
        return `<span class="text-gray-400">${line}</span>`;
      } else if (/^\+\+\+ \w\//.test(line)) {
        return `<span class="text-gray-400">${line}</span>`;
      } else if (/^@@ .+ @@/.test(line)) {
        return `<span class="mt-1.5 inline-block text-gray-600">${line.replace(/(^@@ .+ @@).*/, '$1')}</span>`;
      } else if (/^\+/.test(line)) {
        return `<span class="ml-1 text-green-700">${line}</span>`;
      } else if (/^-/.test(line)) {
        return `<span class="ml-1 text-red-700">${line}</span>`;
      } else {
        return `<span class="ml-1">${line}</span>`;
      }
    }).join("\n");
  }
}
