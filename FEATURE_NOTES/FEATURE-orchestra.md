## allow parallel research to seed context for plan
currently, i can assemble unique prompts to hit the LLM once:

the conductor now needs to be able to run multiple RoboRequests simultaneously... like "look into codebase" and "do internet research" before "build plan items"

`RoboConductor` takes `RoboJob` and `request_type`
  based on type, lines up:
    One Runner takes it all
    Multiple Runners one after the other
      Runner takes over PromptGeneration + LLM call OR hits redis and waits for python

## nice-to-have:
- run different steps w/ different models via background jobs
  - run the results through a "Decide which is best" assistant
  - show user view that can page through different implementation sets w/ assistant's "hot take" on top of each one
