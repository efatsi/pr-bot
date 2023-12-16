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
    console.log(data)
  }
}
