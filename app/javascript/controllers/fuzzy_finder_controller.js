import { Controller } from "@hotwired/stimulus"
import { useDebounce } from "stimulus-use"

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
    allFilesUrl: String,
    fileNameSearchUrl: String,
    fileContentSearchUrl: String,
    filePreview: String,
  }

  static targets = [
    'results',
    'input',
    'fileSearch',
    'previewSection',
    'previewFile',
    'previewContent',
    'previewToggle',
    'contentSearch',
    'caseSensitiveElement',
  ]

  static debounces = [
    {
      name: "slowHandleFormChange",
      wait: 250,
    },
  ];

  connect() {
    useDebounce(this);

    this.selectedFiles = new Set();
    this.displayFiles = new Set();
    this.finalInput = document.getElementById(this.inputIdValue);
    this.previewedFile = null;
    this.lastUrl = null;
    this.allFiles = [];
    this.abortController = null

    if (this.filePreviewValue) {
      this.openFile(this.filePreviewValue);
    }

    this.element.addEventListener('keydown', this.handleKeyDown.bind(this));

    this.loadSelectedFiles();
    this.renderFileList()
  }

  handleKeyDown(event) {
    // If in input, only handle down arrow differently
    if (event.target === this.inputTarget) {
      if (event.key == 'ArrowDown') {
        event.preventDefault();
        this.focusNextFile();
      }

      return
    }

    // If in file list, handle all keys
    if (event.target.classList.contains('file-item')) {
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
            this.toggleFileSelection(event, event.target.textContent.trim());

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
            this.openFile(event.target.textContent.trim())
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

    if (event.key == "Escape" && this.previewedFile) {
      this.backToSearch(event);
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


  toggleFileSelection(event, fileName) {
    // Prevent the default event behavior
    event.preventDefault();

    // Find filename, either based on previewing file, or passed in, or from event params
    if (!fileName) {
      if (this.previewedFile) {
        fileName = this.previewedFile;
      } else {
        fileName = event.params.file
      }
    }

    if (this.selectedFiles.has(fileName)) {
      this.selectedFiles.delete(fileName);
      this.removeFileFromInput(fileName);
    } else {
      this.selectedFiles.add(fileName);
      this.addFileToInput(fileName);
    }
    this.renderFileList();

    if (this.previewedFile) {
      this.setPreviewToggleText()
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

  slowHandleFormChange() {
    this.handleFormChange();
  }

  handleFormChange() {
    const query = this.inputTarget.value;

    let url
    if (this.searchMode() === 'all_files') {
      url = `${this.allFilesUrlValue}`;
    } else if (this.searchMode() === 'file_name') {
      url = `${this.fileNameSearchUrlValue}?query=${query}`
    } else {
      url = `${this.fileContentSearchUrlValue}?query=${query}&regex=${this.isRegex()}&case_sensitive=${this.isCaseSensitive()}`;
    }

    // show/hide regex checkbox if needed
    if (this.searchMode() === 'file_content') {
      this.contentSearchTargets.forEach(el => el.classList.remove('hidden'));
    } else {
      this.contentSearchTargets.forEach(el => el.classList.add('hidden'));
    }

    // check if query is empty
    if (query.trim() === '' && this.searchMode() !== 'all_files') {
      this.displayFiles = new Set();
      this.renderFileList()
      return;

    // then check if query is unchanged (or back to all files)
    } else if (this.lastUrl === url) {
      // if going back to all files, reset the data and refresh
      if (this.searchMode() === 'all_files') {
        this.displayFiles = this.allFiles;
        this.renderFileList()
      }
      // otherwise, nothing changed, return
      return;

    } else {
      // if here, query is new, stash the url and fetch data
      this.lastUrl = url;
    }

    if (this.abortController) { this.abortController.abort(); }
    this.abortController = new AbortController();

    fetch(url, { signal: this.abortController.signal })
      .then(response => response.json())
      .then(data => {
        this.abortController = null;

        if (this.searchMode() === 'all_files' && this.allFiles.length === 0) {
          this.allFiles = data;
        }

        this.displayFiles = data
        this.renderFileList();
      })
      .catch(error => {
        if (error.name !== 'AbortError') {
          console.error(error);
        }
      })
  }

  renderFileList() {
    if (this.displayFiles.size === 0) {
      this.resultsTarget.innerHTML = Array.from(this.selectedFiles).map(f => this.renderFile(f)).join('');
    } else {
      this.resultsTarget.innerHTML = this.displayFiles.map(f => this.renderFile(f)).join('');
    }
  }

  renderFile(file) {
    if (typeof file === 'string') {
      file = { file: file }
    }

    const rowClass = "p-0.5 rounded group-hover:bg-blue-700 flex items-center justify-between"
    const selectedClass = this.selectedFiles.has(file.file) ? '!bg-green-700' : '';
    const selectFileAttrs = `data-action="click->fuzzy-finder#toggleFileSelection" data-fuzzy-finder-file-param="${file.file}"`
    const showLinkClass = `px-6 py-0.5 rounded hover:text-white ${this.selectedFiles.has(file.file) ? 'hover:bg-green-800' : 'hidden group-hover:block hover:bg-blue-800'}`
    const showFileAction = `data-action="click->fuzzy-finder#openFileEvent" data-fuzzy-finder-file-param="${file.file}"`

    let toReturn = `<div class="${rowClass} ${selectedClass} file-item" tabindex="0">
    <span class="flex-grow" >${file.file}</span>
    <a href="#" class="${showLinkClass}" ${showFileAction} tabindex="0">${this.eyeSvg()}</a>
    </div>`

    if (this.searchMode() === 'file_content' && file.line_groups) {
      const groupContent = (group) => {
        let content_html = group.map(line => `<span class="text-xs text-gray-500">${line.line + 1}:</span> ${escapeHtml(line.content)}`).join('\n');
        return this.highlightSearchTerm(content_html, this.inputTarget.value);
      }

      toReturn += `<div class="text-sm text-gray-400 pl-2 flex flex-col gap-4 my-2 overflow-auto">
        ${file.line_groups.map(group => {
          return `<pre class="whitespace-pre max-w-full">${groupContent(group)}</pre>`;
        }).join('')}
      </div>`;
    }

    return `<div class="group cursor-pointer" ${selectFileAttrs}>${toReturn}</div>`;
  }

  loadSelectedFiles() {
    const selectedFiles = this.finalInput.value.split('\n').filter(file => file.trim().length > 0);
    selectedFiles.forEach(file => this.selectedFiles.add(file));
  }

  openFileEvent(e) {
    e.preventDefault();
    e.stopImmediatePropagation();

    this.openFile(e.params.file);
  }

  openFile(file) {
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

  highlightSearchTerm(content, searchTerm) {
    if (this.isRegex()) {
      const regex = this.isCaseSensitive() ? new RegExp(searchTerm, 'g') : new RegExp(searchTerm, 'gi');
      return content.replace(regex, '<span class="bg-[#6c2c07] rounded">$&</span>');
    } else {
      const escapedSearchTerm = escapeHtml(searchTerm).replace(/[.*+?^${}()|\[\]\\]/g, '\\$&');
      const searchRegex = new RegExp(escapedSearchTerm, this.isCaseSensitive() ? 'g' : 'gi');
      return content.replace(searchRegex, '<span class="bg-[#6c2c07] rounded">$&</span>');
    }
  }

  searchMode() {
    return this.element.querySelector('input[name="fuzzy_search[mode]"]:checked').value;
  }

  isRegex() {
    return this.element.querySelector('input[name="fuzzy_search[regex]"][type="checkbox"]').checked
  }

  isCaseSensitive() {
    return this.element.querySelector('input[name="fuzzy_search[case_sensitive]"][type="checkbox"]').checked
  }
}
