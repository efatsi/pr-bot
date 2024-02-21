# RoboEvents

- removed files/index
  - ripple down other things that are removed
  - copy form behavior into `start` event

  - inline editing of FeatureRequest
  - inline editing of Contextual Files
  - open file viewer/picker from default view

- available actions based on last event + subject situation

- update instructions rendering
  - generate event, render that
  - then hook in the processing update

- event actions
  - can "destroy" if it's the last event (and not start)
    - knows what to wind back based on event type and subject
  - can "revert to here"
    - if event has children
    - destroys dependent events in reverse orders
