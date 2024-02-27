import { Controller } from "@hotwired/stimulus"

export default class HeaderController extends Controller {
  static targets = ["robots", "robotInput", "robotCount"]

  connect() {
    const cookiedRobots = document.cookie.split(';').find(c => c.includes('selectedRobots'))
    if (cookiedRobots) {
      const selectedRobots = cookiedRobots.split('=')[1].split(',')
      this.robotInputTargets.forEach(r => {
        r.checked = selectedRobots.includes(r.value)
      })
    }

    this.handleRobotChange()
  }

  toggleRobots() {
    this.robotsTarget.classList.toggle('hidden')
  }

  handleRobotChange() {
    const selectedRobots = this.robotInputTargets.filter(r => r.checked)
    document.cookie = `selectedRobots=${selectedRobots.map(r => r.value).join(',')}; path=/`

    this.robotCountTarget.textContent = selectedRobots.length
  }
}
