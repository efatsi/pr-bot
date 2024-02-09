# Build plan overhaul
goal: making the input prompt better when it's time to generate instructions

- work in 2 robots
  - 2 new RoboRequests
    - robo_model: gpt | gemini
    - status: default / rejected / accepted
  - show outputs of both in realtime
  - when done
    - shows both if not one favored
    - build instructions locks one in as favored, others as rejected
    - update .feature_request lookup
    - put rejected ones in other dropdown
    - dropdown label should show robot responsible

- continue conversing w/ enhance thread
