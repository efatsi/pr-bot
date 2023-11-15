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
      const selectedClass = this.selectedFiles.has(file) ? 'bg-green-500 text-white' : '';
      return `<div class="cursor-pointer ${selectedClass}" data-action="click->fuzzy-file-finder#toggleFileSelection mouseover->fuzzy-file-finder#highlightFile mouseout->fuzzy-file-finder#unhighlightFile">${file}</div>`;
    }).join('');
  }

  highlightFile(event) {
    event.target.classList.add('bg-blue-500', 'text-white');
  }

  unhighlightFile(event) {
    event.target.classList.remove('bg-blue-500', 'text-white');
  }

  inputValueChanged() {
    this.searchTerm = this.inputTarget.value.toLowerCase();
    this.renderFileList();
  }
}
