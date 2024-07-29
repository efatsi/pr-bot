import { Controller } from "@hotwired/stimulus"

export default class HeaderController extends Controller {
  static targets = ["settings", "robotInput", "fileOpenerInput", "robotCount"]

  connect() {
    const cookiedRobots = document.cookie.split(';').find(c => c.includes('selectedRobots'))
    if (cookiedRobots) {
      const selectedRobots = cookiedRobots.split('=')[1].split(',')
      this.robotInputTargets.forEach(r => {
        r.checked = selectedRobots.includes(r.value)
      })
    }

    this.handleRobotChange()

    this.settingsOpen = false

    // recognize when clicking outside of this.element and close the settings dropdown
    document.addEventListener('click', (e) => {
      if (this.settingsOpen && !this.element.contains(e.target)) {
        this.toggleSettings()
      }
    })
  }

  toggleSettings() {
    this.settingsOpen = !this.settingsOpen

    if (this.settingsOpen) {
      this.settingsTarget.classList.remove('hidden')
    } else {
      this.settingsTarget.classList.add('hidden')
    }
  }

  handleRobotChange() {
    const selectedRobots = this.robotInputTargets.filter(r => r.checked)
    document.cookie = `selectedRobots=${selectedRobots.map(r => r.value).join(',')}; path=/`

    this.robotCountTarget.textContent = selectedRobots.length
  }

  handleFileOpenerChange(e) {
    const selectedFileOpener = this.fileOpenerInputTargets.find(r => r.checked)
    document.cookie = `selectedFileOpener=${selectedFileOpener.value}; path=/`
  }
}
