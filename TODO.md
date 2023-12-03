# TODO
## sm
- add remove_file to possible moves AI can return
- show commits on RoboJob

## md
- render errors when stream execution fails (eg: invalid path)
- show invalid path errors when setting contextual files
- remove additional_notes, collapse to one prose field
- all files make click-to-copy (or open in vscode...)
- a "ding" when it's done

## mg
- render feature requests inline, button to toggle one or all
- JS interval for alerting if server connection fails
- move continue / commit buttons into actions partial outside of box
  - show / hide when requests hit / resolve


# contextual files enhance
- let you access file finder from show view
  - allow form still, but can add / remove w/o it

- files mentioned in feature request have content sent in contextual_files search
- files mentioned in feature request are auto added to contextual_files
- per file line, show "rationale" from robo_request (or "included in feature request") (or "human added")


# Step 3: cleanup
- new stream button, similar to "continue"
  - new followup job
  - optional message from user to guide the cleanup
    - generate & display some primer examples that can be copied in
- LLM call w/
  - git diff
  - copy of full files
  - prompt asking to check for syntax errors, logic bugs, whitespace
  - example shows a couple things i want it to hit
- generate new RoboChanges
  - render w/ light blue
  - maybe icon everything up (plus / pencil / broom)

# full-blown customizable action templates
- default available on all projects: git push origin [branch]
- can add new action templates to projects
- can create actions from templates in RoboJob

# export sharable RoboJob

# cost updates
- show on project
  - http://localhost:3000/robo_jobs/79
  - demo mode?
- check pricing ... http://localhost:3000/robo_jobs/124 is 0.05 but has loooots of requests
- toggle on RoboJob to show per-request cost
  - show request cost on the Response dropdown
- project cost dips down through RoboJob requests and job-less Commit requests
- RoboJob cost dips down through self's requests, followup requests, and commit requests

# v2

- Commit History search
  - AI buddy that can dig into git commit history
  - combination of actual search & LLM stuff
  - gotta be smrt and lean to avoid blowing token limits
    - if <4k can go local model
  - poposition
    1. ask AI to get the top keywords out of a request
    2. use keywords in a comprehensive local search to generate possibilities
    3. pass possibilities to AI model, as it to vet the ones we do care about for the feature
      - one at a time?
      - as many as will fit?
    4. load commit in as "context" for parent RoboJob (like files)
      - or just a subset of it (perhaps some of commit is not relevant)
      - [bonus] convert commit details into formatted changesets, like how we want AI to respon
      - build commit UI that
        - shows tiers of selected options (AI filtered, all keyword search results, all)
        - has diff viewer (future: interlink between this and file search UI)
        - user can select/deselect relevant commits
    5. commit data is passed in during PromptGeneration

- Better contextual file finding
  - extract snippets instead of full files
  - Data compression
    - https://github.blog/2023-05-17-how-github-copilot-is-getting-better-at-understanding-your-code/
  - run this locally, slower but could be more accurate
    - robo recon:
      - cached process that generates overviews of files so contextual_files can be done more accurately
    - optional second pass:
      - only select a small subset first, instead of all the things you might need
      - then a second pass pulls additional files based on context learned from the first
      - until satisfied
      - collecting pieces of the files that matter

- question mode vs. feature mode
  - different prompt, lets you just ask questions about the app to get humanoid answers

## v3 / gettin fancy:

- wrap in Electron app

- handle photo uploads

- voice commands:
  - endless list of possibilities here ...
    - talk whatever you want into robot
    - give it a list of functions it can call depending on what step you're on
    - it can "call" one of those functions, which optionally advances the step, opening up different functions, or automated processes, whatever
    - `StepManager`
    - `Step`
      - data
      - allowed_functions
    - `Function`
      - call
  - eg: update the RoboChange file creation logic to target the full path based on the project's filepath. For context, look at robo_change robo_job and project model files

