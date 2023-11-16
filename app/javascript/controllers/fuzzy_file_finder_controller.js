import { Controller } from "@hotwired/stimulus"

export default class FuzzyFileFinderController extends Controller {
  static values = { fileData: Array }

  static targets = ['results', 'input']

  connect() {
    this.selectedFiles = new Set();
    this.renderFileList();

    this.finalInput = document.getElementById('contextual-file-input');
  }

  toggleFileSelection(event) {
    const fileName = event.target.textContent.trim();
    event.preventDefault(); // Prevent the default event behavior

    if (this.selectedFiles.has(fileName)) {
      this.selectedFiles.delete(fileName);
      this.removeFileFromInput(fileName);
    } else {
      this.selectedFiles.add(fileName);
      this.addFileToInput(fileName);
    }
    this.renderFileList();
    this.inputTarget.focus();
  }

  removeFileFromInput(fileName) {
    this.finalInput.value = this.finalInput.value.split('\n').filter(file => file.trim() !== fileName).join('\n');
  }

  addFileToInput(fileName) {
    if (!this.finalInput.value.includes(fileName)) {
      this.finalInput.value += fileName + '\n';
    }
  }

  renderFileList() {
    let fileList = this.fileDataValue;

    if (this.searchTerm && this.searchTerm.length > 0) {
      const searchTerms = this.searchTerm.split(' ').filter(term => term.length > 0);
      fileList = this.fileDataValue.filter(file => searchTerms.every(term => file.toLowerCase().includes(term.toLowerCase())));
    }

    this.resultsTarget.innerHTML = fileList.map(file => {
      const fileClass = "cursor-pointer px-1 rounded-sm hover:bg-blue-700"
      const selectedClass = this.selectedFiles.has(file) ? '!bg-green-700' : '';
      return `<div class="${fileClass} ${selectedClass}" data-action="click->fuzzy-file-finder#toggleFileSelection">${file}</div>`;
    }).join('');
  }

  inputValueChanged() {
    this.searchTerm = this.inputTarget.value.toLowerCase();
    this.renderFileList();
  }
}
