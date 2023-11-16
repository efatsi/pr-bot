import { Controller } from "@hotwired/stimulus"

export default class FuzzyFileFinderController extends Controller {
  static values = { fileData: Array, inputId: String }
  static targets = ['results', 'input']

  connect() {
    this.selectedFiles = new Set();
    this.finalInput = document.getElementById(this.inputIdValue);

    this.loadSelectedFiles();
    this.renderFileList();
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

    if (this.inputTarget.value.length > 0) {
      this.inputTarget.focus();
    }
  }

  removeFileFromInput(fileName) {
    this.finalInput.value = this.finalInput.value.split('\n').filter(file => file.trim() !== fileName).join('\n');
  }

  addFileToInput(fileName) {
    if (!this.finalInput.value.includes(fileName)) {
      if (this.finalInput.value.length > 0) {
        this.finalInput.value += '\n';
      }

      this.finalInput.value += fileName;
    }
  }

  renderFileList() {
    let fileList = this.fileDataValue;

    if (this.searchTerm && this.searchTerm.length > 0) {
      const searchTerms = this.searchTerm.split(' ').filter(term => term.length > 0);
      fileList = this.fileDataValue.filter(file => searchTerms.every(term => file.toLowerCase().includes(term.toLowerCase())));
    }

    const fileClass = "cursor-pointer px-1 my-0.5 rounded-sm hover:bg-blue-700"

    this.resultsTarget.innerHTML = fileList.map(file => {
      const selectedClass = this.selectedFiles.has(file) ? '!bg-green-700' : '';
      return `<div class="${fileClass} ${selectedClass}" data-action="click->fuzzy-file-finder#toggleFileSelection">${file}</div>`;
    }).join('');
  }

  inputValueChanged() {
    this.searchTerm = this.inputTarget.value.toLowerCase();
    this.renderFileList();
  }

  loadSelectedFiles() {
    const selectedFiles = this.finalInput.value.split('\n').filter(file => file.trim().length > 0);
    selectedFiles.forEach(file => this.selectedFiles.add(file));
  }
}
