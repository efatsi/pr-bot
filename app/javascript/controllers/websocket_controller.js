import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class WebsocketController extends Controller {
  static values = { roboJobId: String }

  connect() {
    console.log("WebsocketController connected")
    this.consumer = createConsumer()

    this.consumer.subscriptions.create(
      { channel: "RoboChannel", robo_job_id: this.roboJobIdValue },
      { received: this.handleReceivedMessage.bind(this) }
    )
  }

  handleReceivedMessage(data) {
    console.log("Received message:", data)

    if (data.turbo_stream) {
      // if data is an array, make it an array
      if (!Array.isArray(data.turbo_stream)) {
        data.turbo_stream = [data.turbo_stream]
      }

      // render each turbo stream message
      for (const message of data.turbo_stream) {
        Turbo.renderStreamMessage(message)
      }
    }
  }
}
