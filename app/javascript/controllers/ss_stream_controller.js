import { Controller } from "@hotwired/stimulus"

// initialize server-side event connection
// render Turbo stream messages from server

export default class SsStreamController extends Controller {
  static values = { url: String }

  startConnection(e) {
    e.preventDefault()

    const eventSource = new EventSource(this.urlValue)

    eventSource.addEventListener("message", (event) => {
      const data = JSON.parse(event.data)

      if (data.turbo_stream) {
        Turbo.renderStreamMessage(data.turbo_stream)
      }
    })

    eventSource.addEventListener("error", (event) => {
      if (event.eventPhase === EventSource.CLOSED) {
        eventSource.close()
      }
    })
  }
}
