# Build plan overhaul
goal: making the input prompt better when it's time to generate instructions

- "build_plan" button now does "enhance_feature_request":
  - 2 new RoboRequests
    - "enhance_feature_request" request_type
    - robo_model: gpt | gemini
    - favored: boolean default false
  - prompt:
    - talk about the problem and solution in technical detail
    - talk out the execution paths for complex logic that supports the validity of the solution
      - give it a good example here (find on internet)
  - show outputs of both in realtime
  - when done
    - shows both if not one favored
    - pick one as favored
    - button to go back to review options
    - inline edit
    - continue conversing w/ it
- build instructions button
  - uses the beefed up prompt
    - finds the last request of type "enhance_feature_request"
    - off to the usual races
