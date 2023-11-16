import { Controller } from "@hotwired/stimulus"

export default class FuzzyFileFinderController extends Controller {
  static values = { fileData: Array, inputId: String, filePreviewUrl: String }
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

    this.resultsTarget.innerHTML = fileList.map(file => {
      return this.renderFile(file);
    }).join('');
  }

  renderFile(file) {
    const fileClass = "cursor-pointer pl-2 my-0.5 rounded hover:bg-blue-700 group flex items-center justify-between"
    const selectedClass = this.selectedFiles.has(file) ? '!bg-green-700' : '';
    const linkClass = `px-2 py-0.5 rounded hover:text-white ${this.selectedFiles.has(file) ? 'hover:bg-green-800' : 'hidden group-hover:block hover:bg-blue-800'}`
    const linkAction = `data-action="click->fuzzy-file-finder#openFile" data-fuzzy-file-finder-file-param="${file}"`

    return (
      `<div class="${fileClass} ${selectedClass}" data-action="click->fuzzy-file-finder#toggleFileSelection">
        <span>${file}</span>
        <a href="#" class="${linkClass}" ${linkAction}>${this.eyeSvg()}</a>
      </div>`
    )
  }

  inputValueChanged() {
    this.searchTerm = this.inputTarget.value.toLowerCase();
    this.renderFileList();
  }

  loadSelectedFiles() {
    const selectedFiles = this.finalInput.value.split('\n').filter(file => file.trim().length > 0);
    selectedFiles.forEach(file => this.selectedFiles.add(file));
  }

  openFile(e) {
    e.preventDefault();
    const file = e.params.file
    console.log("filePreviewUrl", this.filePreviewUrlValue)
    console.log(`Opening file: ${file}`);

    // fetch file preview from server
    fetch(`${this.filePreviewUrlValue}?file=${file}`)
      .then(response => response.text())
      .then(data => {
        console.log(data);
      });

  }

  eyeSvg() {
    return (
      `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="h-5 w-5">
        <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 010-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178z" />
        <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
      </svg>`
    )
  }
}
