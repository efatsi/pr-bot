import { Controller } from "@hotwired/stimulus"

// initialize server-side event connection
// render Turbo stream messages from server

export default class SsStreamController extends Controller {
  static values = { url: String, autofire: Boolean }

  connect() {
    if (this.autofireValue) {
      this.startConnection()
    }
  }

  startConnection(e) {
    if (e) {
      e.preventDefault()
    }

    console.log("Opening server-side event connection:", this.urlValue)
    const eventSource = new EventSource(this.urlValue)

    eventSource.addEventListener("message", (event) => {
      // console.log("Received server-side event:", event)
      const data = JSON.parse(event.data)

      if (data.turbo_stream) {
        // you can pass in an array, or we'll make it an array here
        if (!Array.isArray(data.turbo_stream)) {
          data.turbo_stream = [data.turbo_stream]
        }

        // render each turbo stream message
        for (const message of data.turbo_stream) {
          Turbo.renderStreamMessage(message)
        }
      }
    })

    eventSource.addEventListener("error", (event) => {
      if (event.eventPhase === EventSource.CLOSED) {
        console.log("Server-side event connection closed:", event)
        eventSource.close()
      } else {
        console.error("Server-side event error:", event)
      }
    })
  }
}
