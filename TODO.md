# TODO
## Instructions vs. Build Plan
- plan editing
  - inline editing of plan (summary, file, relevant_files)
  - drag-n-drop (eg: so can add before remove)

- running `fill_in_plan`
  - recognize actions that depend on changes in earlier ones, group into steps. eg:
    - create new file
    - update new file
    - update other files based on new file
  - orrrr, pass in the previous actions...? idk this action plan doesn't seem all that good anymore...

- continue-the-convo button
  - hide if just pre_flight actions (until "modify plan")
  - add radio-select to "build instructions" (default) or "build plan"
    - update RoboConductor queue type based on input

- update general instructions prompt:
  - pass all action templates
  - include the line "Return the smallest possible changeset necessary to clearly implement the task."

- "modify plan" (save til later)
  - form input (copy-pasted from continue-the-convo)
    - radio select to mark as needs_change or looks_good
    - can modify contextual files (not feature request, saving that for back-up-convo)
    - box to input what should change
  - new prompt
  - new runner

## Context Files
- let you define files first
- button to hit LLM for more files with the defined set as prompt context
  - token limits might be a concern here for large projects
  - v2: break up this search into multiple batches
    - probably batched per-context-file, or per bucket of directory paths ... whichever is bigger

## Back up Conversation
- ability to edit previous request / context and re-run LLM
- organizing things in tree-like threads: ConversationThread
- clicking "edit" starts a new RoboJob / Thread
- RoboJob belongs_to Thread, Thread belongs_to Thread as well?
  - ... i see why chatgpt didn't let you edit the first message for a while lol
  - change the URL from robo_jobs/3 to robo_threads/3
  - when creating new RoboJob, build parent Thread, and then new RoboJob+Thread w/in that
  - threads can be branched off
- rendering defaults to most recent thread
- allow navigating back to previous threads, continuing those if wanted

# Tooling todo
## ability to halt AI
- quit on refresh
  - handle unsubscribed in backend channel
  - force the good_job task to stop
    - send `sigkill` somehow
    - `discard_on InterruptError`
- button to Stop

## lil things
- rename project.filepath to project.repository_path
- show commits on RoboJob
- fix git commit get request inside a frame BS

# Better Context
## contextual files enhance
- when asking for files, ask for structured data back
  - `line_numbers`, `why_important`, `importance_weight` (critical, helpful, maybe_helpful)
    - use this to capture the LLM's desire to overtalk, and put that yammering in the right box
  - show data in a human review step of the context digging
    - checkboxes to include / ignore
    - before directories get unpacked!

- can work w/ line numbers
  - robo input: extract snippets instead of full files
    - break up file into overlapping chunks
    - pass chunks to simple LLM and ask "what lines do you REALLY care about"
      - ask for an array of chunks w/ `line_numbers`, `why_important`, `importance_weight`
  - human input: make vscode helper to output file name w/ line numbers

- let you access file finder from show view
  - don't have the file finder just write to the form input, have it update the backend
- click on contextual file `↗` to open in file viewer
- remove leading slash before checking uniqueness (/db/seeds & db/seeds both on there)

## internet search
- ask AI for a few internet searches given the prompt
- hit some API somehow, LangChain has examples
  - https://python.langchain.com/docs/integrations/tools/ddg
  - https://python.langchain.com/docs/integrations/tools/tavily_search
  - maybe pop out of Ruby for this one, pass to Python via Redis and use off-the-shelf tooling
- summarize responses into condense information useful for the implementation

## git history
- can work against a specific diff
  - pass in more than git gives you by default
    - `-U` flag can increase context lines: `git diff -U20`
  - send git diff summary?
- skip contents of deleted files
- skip contents of markdown files
- remind the prompt this is supplementary to contextual files (wrap in `<context:git>` `</context:git>`)
  - replace others eg: "Directory Tree:" w/ <directory-tree> </directory-tree>
  - project search: `"[\w+\s?]{2,}:",`


# cleanup step
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

# export sharable RoboJob
- unpacked feature requests
- unpacked implementation overview
- diffs splayed out w/o the border cutting them off

# v2
- handle photo uploads

- question mode vs. feature mode
  - different prompt, lets you just ask questions about the app to get humanoid answers

- Commit History search
  - AI buddy that can dig into git commit history
  - the problem w/ diffs is they're too small.
    * can use `-U` flag
    * orrr, use `git show` to get data at that time for all the files and ask LLM which is important to send along to capture the diff
  - gotta be smrt and lean to avoid blowing token limits
    - if <4k can go local model
  - flow:
  1. ask AI to get the top keywords out of a request
  2. use keywords in a comprehensive local search to generate possibilities
  3. pass possibilities to AI model, as it to vet the ones we do care about for the feature
    - one at a time?
    - as many as will fit?
  4. load commit in as "context" for parent RoboJob (like files)
    - or just a subset of it (perhaps some of commit is not relevant)
    - build commit review UI that
      - shows tiers of selected options (AI filtered, all keyword search results, all)
      - has diff viewer (future: interlink between this and file search UI)
      - user can select/deselect relevant commits
  5. commit data is passed in during PromptGeneration

## different changeset format
- ask for lines to replace instead of content
  - less tokens
  - potentially more accurate
- ask for changes in git-diff mode instead of find-replace mode
  - it's way better, so says the Aider team
    - https://aider.chat/docs/unified-diffs.html
  - although I think line find-replace w/ numbers could be pretty fricking good
    - rationale:
      - it's easier for me to imagine that working w/ strong stability, so it might be easier for LLM to be good at it too?
      - LLMs have seen a lot of git diff examples, but that doesn't mean it's good at translating intention to/from that format. And I bet it's seen a LOT more examples of code in more readable formats performing tasks

- cost updates
  - show on project
    - http://localhost:3000/robo_jobs/79
    - demo mode?
  - check pricing ... http://localhost:3000/robo_jobs/124 is 0.05 but has loooots of requests
  - toggle on RoboJob to show per-request cost
    - show request cost on the Response dropdown
  - project cost dips down through RoboJob requests and job-less Commit requests
  - RoboJob cost dips down through self's requests, followup requests, and commit requests

- "Rollback to this step"
  - would require git committing on ... every action

## v3 / gettin fancy:
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
  - eg: update the Action file creation logic to target the full path based on the project's filepath. For context, look at action robo_job and project model files

- wrap in Electron app
