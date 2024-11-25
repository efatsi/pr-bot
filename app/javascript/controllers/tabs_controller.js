import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab"]

  connect() {
    this.currentTab = "input"
  }

  showTab(event) {
    event.preventDefault()

    const tabKey = event.currentTarget.dataset.tabKey

    this.tabTargets.forEach((tab) => {
      if (tab.dataset.tab === tabKey) {
        if (this.currentTab === tabKey) {
          // unselect tab
          this.currentTab = null
          tab.classList.add('hidden')

        } else {
          // select new tab
          this.currentTab = tabKey
          tab.classList.remove('hidden')

        }
      } else {
        // hide other tabs
        tab.classList.add('hidden')
      }
    })
    console.log('toggle', tabKey)
    console.log('currentTab', this.currentTab)
  }
}
