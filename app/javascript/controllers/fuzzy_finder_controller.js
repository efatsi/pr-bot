import { Controller } from "@hotwired/stimulus"

function escapeHtml(unsafe) {
  return unsafe
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

export default class FuzzyFinderController extends Controller {
  static values = {
    fileData: Array,
    inputId: String,
    filePreviewUrl: String,
    fileNameSearchUrl: String,
    fileContentSearchUrl: String,
  }

  static targets = [
    'results',
    'input',
    'fileSearch',
    'previewSection',
    'previewFile',
    'previewContent',
    'previewToggle'
  ]

  connect() {
    this.selectedFiles = new Set();
    this.finalInput = document.getElementById(this.inputIdValue);
    this.previewedFile = null;

    this.loadSelectedFiles();
    this.element.addEventListener('keydown', this.handleKeyDown.bind(this));
  }

  handleKeyDown(event) {
    if (event.target === this.inputTarget || event.target.classList.contains('file-item')) {
      switch (event.key) {
        case 'ArrowDown':
          event.preventDefault();
          this.focusNextFile();
          break;
        case 'ArrowUp':
          event.preventDefault();
          this.focusPreviousFile();
          break;
        case 'Enter':
        case ' ':
          if (event.target.classList.contains('file-item')) {
            event.preventDefault();
            this.toggleFileSelection(event);

            // maintain focus on selected file, all files were just rerendered
            const selectedFile = event.target.textContent.trim();
            const newFiles = Array.from(this.resultsTarget.querySelectorAll('.file-item'));
            const selectedFileIndex = newFiles.findIndex(file => file.textContent.trim() === selectedFile);
            files[selectedFileIndex].focus();
          }
          break;
        case 'ArrowRight':
          event.preventDefault();
          if (event.target.classList.contains('file-item')) {
            event.params = { file: event.target.textContent.trim() };
            this.openFile(event);
          }
          break;
        case 'ArrowLeft':
          event.preventDefault();
          if (this.previewedFile) {
            this.backToSearch(event);
          }
          break;
      }
    }
  }

  focusNextFile() {
    const currentFocus = document.activeElement;
    const files = Array.from(this.resultsTarget.querySelectorAll('.file-item'));
    const currentIndex = files.indexOf(currentFocus);
    if (currentIndex === -1 || currentIndex + 1 >= files.length) {
      files[0].focus();
    } else {
      files[currentIndex + 1].focus();
    }
  }

  focusPreviousFile() {
    const currentFocus = document.activeElement;
    const files = Array.from(this.resultsTarget.querySelectorAll('.file-item'));
    const currentIndex = files.indexOf(currentFocus);
    if (currentIndex <= 0) {
      this.inputTarget.focus();
    } else {
      files[currentIndex - 1].focus();
    }
  }


  toggleFileSelection(event) {
    // Prevent the default event behavior
    event.preventDefault();

    // Find filename, either based on previewing file or direct click
    let fileName;
    if (this.previewedFile) {
      fileName = this.previewedFile;
    } else {
      fileName = event.target.textContent.trim();
    }

    if (this.selectedFiles.has(fileName)) {
      this.selectedFiles.delete(fileName);
      this.removeFileFromInput(fileName);
    } else {
      this.selectedFiles.add(fileName);
      this.addFileToInput(fileName);
    }
    // TODO: bring this back... cache displayedFiles to align w/ selectedFiles
    // this.renderFileList();

    if (this.previewedFile) {
      this.setPreviewToggleText()
    }

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

  inputValueChanged() {
    const searchMode = this.element.querySelector('input[name="fuzzy_search[mode]"]:checked').value;
    const query = this.inputTarget.value;
    const url = searchMode === 'file_name' ? `${this.fileNameSearchUrlValue}?query=${query}` : `${this.fileContentSearchUrlValue}?query=${query}`;

    fetch(url)
      .then(response => response.json())
      .then(data => {
        this.resultsTarget.innerHTML = data.map(f => this.renderFile(f)).join('');
      });
  }

  renderFile(file) {
    const fileClass = "cursor-pointer pl-2 py-0.5 rounded hover:bg-blue-700 group flex items-center justify-between"
    const selectedClass = this.selectedFiles.has(file) ? '!bg-green-700' : '';
    const linkClass = `px-6 py-0.5 rounded hover:text-white ${this.selectedFiles.has(file) ? 'hover:bg-green-800' : 'hidden group-hover:block hover:bg-blue-800'}`
    const linkAction = `data-action="click->fuzzy-finder#openFile" data-fuzzy-finder-file-param="${file}"`

    return (
      `<div class="${fileClass} ${selectedClass} file-item" tabindex="0" data-action="click->fuzzy-finder#toggleFileSelection">
        <span>${file}</span>
        <a href="#" class="${linkClass}" ${linkAction} tabindex="0">${this.eyeSvg()}</a>
      </div>`
    )
  }

  loadSelectedFiles() {
    const selectedFiles = this.finalInput.value.split('\n').filter(file => file.trim().length > 0);
    selectedFiles.forEach(file => this.selectedFiles.add(file));
  }

  openFile(e) {
    e.preventDefault();
    const file = e.params.file

    fetch(`${this.filePreviewUrlValue}?file=${file}`)
      .then(response => response.text())
      .then(data => {
        this.previewedFile = file;
        this.setPreviewToggleText()

        this.previewFileTarget.innerHTML = file;
        this.previewContentTarget.innerHTML = `<code>${escapeHtml(data)}</code>`;
        // remove any existing classes
        this.previewContentTarget.classList.remove(...this.previewContentTarget.classList);
        this.previewContentTarget.classList.add("line-numbers", `language-${file.split('.').pop()}`);
        Prism.highlightAll()

        this.fileSearchTarget.classList.add('max-h-0', 'overflow-y-scroll');
        this.previewSectionTarget.classList.remove('max-h-0', 'overflow-y-scroll');
        this.element.classList.add("-translate-x-full");
      });
  }

  backToSearch(e) {
    e.preventDefault();

    this.previewedFile = null;

    this.fileSearchTarget.classList.remove('max-h-0', 'overflow-y-scroll');
    this.previewSectionTarget.classList.add('max-h-0', 'overflow-y-scroll');
    this.element.classList.remove("-translate-x-full");
  }

  setPreviewToggleText() {
    if (this.selectedFiles.has(this.previewedFile)) {
      this.previewToggleTarget.textContent = "- Remove";
    } else {
      this.previewToggleTarget.textContent = "+ Add";
    }
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
