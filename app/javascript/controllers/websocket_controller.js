import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

class TimestampedEvent {
  constructor(timestamp, event) {
    this.timestamp = timestamp
    this.event = event
  }
}

export default class WebsocketController extends Controller {
  static values = { roboJobId: String }

  connect() {
    this.consumer = createConsumer()

    this.streamInput = {}

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

  disconnect() {
    if (this.subscription) {
      this.consumer.subscriptions.remove(this.subscription)
      document.roboSubscription = null
      console.log("WebsocketController disconnected and subscription removed")
    }
  }

  handleReceivedMessage(data) {
    console.log("Received message:", data)

    if (data.event_timestamp) {
      this.handleTimestampedEvent(data)
    } else {
      this.renderMessage(data)
    }
  }

  renderMessage(data) {
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

  handleTimestampedEvent(data) {
    const newEvent = new TimestampedEvent(data.event_timestamp.time, data)
    const target = data.event_timestamp.target

    // set empty array if not exists
    if (!this.streamInput[target]) {
      this.streamInput[target] = []
    }

    // push new event wait then 200 ms to render
    this.streamInput[target].push(newEvent)
    setTimeout(() => {
      this.renderEarliestMessage(target)
    }, 200)
  }

  renderEarliestMessage(target) {
    this.streamInput[target].sort((a, b) => a.timestamp - b.timestamp)

    const earliestEvent = this.streamInput[target].shift()
    if (earliestEvent) {
      this.renderMessage(earliestEvent.event)
    }
  }
}
