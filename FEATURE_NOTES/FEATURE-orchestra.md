# Scratch / Infra Overview

currently, i can assemble unique prompts to hit the LLM once:

`RoboJob`: has a high level user-defined feature prompt
`RoboConductor`: takes a `RoboJob` and a `request_type` and oversees
  makes a `RoboRequest`
  calls `PromptGenerator` w/ `RoboRequest` to seed prompt data
  passes prompt to LLM
  processes response in `Handlers`


the conductor now needs to be able to run multiple RoboRequests simultaneously... right? or is human required every time


# planning hat vs. implementing hat
- hit `generate_plan` button:
  - is given action templates and examples of using all of them to make a high level plan
  - generates a json list of action skeletons
    -> create pre_flight Actions

- user can review plan's list of actions
  - skip actions
  - edit actions
  - continue-the-conversation (eg: that's not quite right, I skipped two, do it like this instead)
    - generates more action skeletons

- hit `generate_action_details` button:
  - new robo_request for each item in the plan
    - prompt_generator leans on action_type & action_template to send appropriate examples
      - includes the plan and previous action requests w/in this cycle
    - handler takes response and
      - fills out Action record
      - flips from pre_flight to pending
    - ask for lines to replace instead of content

## and then
- rewrite `PromptGenerator` instructions history to include past action conversation
  - for only actions that were executed
- replace `generate_instructions` button press w/ logic to:
  - `generate_plan` & `generate_action_details` w/o middle review step
  - 😢 RIP `RoboChanges`
- allow "edit and rerun last request (abandon this changeset)"

## nice-to-have:
- run different steps w/ different models via background jobs
  - run the results through a "Decide which is best" assistant
  - show user view that can page through different implementation sets w/ assistant's "hot take" on top of each one
