import { Controller } from "@hotwired/stimulus"

export default class FuzzyFileFinderController extends Controller {
  static values = { fileData: Array }

  static targets = ['results', 'input']

  connect() {
    this.renderFileList(this.fileDataValue);
  }

  addFileToInput(event) {
    const fileName = event.target.textContent;
    const input = document.getElementById('contextual-file-form').querySelector('textarea');
    input.value += fileName + '\n';
  }

  inputValueChanged() {
    const searchTerm = this.inputTarget.value.toLowerCase();
    const searchTerms = searchTerm.split(' ').filter(term => term.length > 0);
    const filteredFiles = this.fileDataValue.filter(file => searchTerms.every(term => file.toLowerCase().includes(term)));
    this.renderFileList(filteredFiles);
  }

  renderFileList(fileList) {
    this.resultsTarget.innerHTML = fileList.map(file => `<div data-action="click->fuzzy-file-finder#addFileToInput">${file}</div>`).join('');
  }
}
