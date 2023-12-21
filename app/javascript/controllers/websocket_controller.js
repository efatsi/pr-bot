import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class WebsocketController extends Controller {
  static values = { roboJobId: String }

  disconnect() {
    if (this.subscription) {
      this.consumer.subscriptions.remove(this.subscription)
      document.roboSubscription = null
      console.log("WebsocketController disconnected and subscription removed")
    }
  }

  connect() {
    console.log("WebsocketController connected")
    this.consumer = createConsumer()

    if (!document.roboSubscription) {
      document.roboSubscription = this.consumer.subscriptions.create(
        { channel: "RoboChannel", robo_job_id: this.roboJobIdValue },
        { received: this.handleReceivedMessage.bind(this) }
      )
    } else {
      console.log("Using existing subscription")
    }
    this.subscription = document.roboSubscription
  }

  handleReceivedMessage(data) {
    console.log("Received message:", data)

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
  }
}
