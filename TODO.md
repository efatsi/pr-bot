# punch list
- back up / redo
  - history view down the left side
  - can click in to back up to that step, or delete the last step
  - then threads, keep this but fork off from here

- making context better:
  - button to whittle down current list w/ concurrent (free!) GoogleAI calls based on request
    - iterate through each file
      - clean filename (leading slash)
      - look at file contents
        - decide if relevant in the sphere of the feature request
        - decide if want to see new files
  - button to "looking at these files, what other files would you want to check out based on request"

- image uploads

- open one file, or batch of files, in vs code



# TODO
## Context Files
- let you define files first
- new "Manage Context" modal
  - AI buttons:
    - `scan_file_directory` for possible candidates
    - `generate_keywords` (from request / files) and find_files_from_keyword
    - `analyze_for_relevance`
      * bonus:
        * make this work on chunks of LOCs instead of full files
        * pass back:`line_numbers`, `why_important`, `importance_weight` (critical, helpful, maybe_helpful)
          * use this to capture the LLM's desire to overtalk, and put that yammering in the right box
    - later: `hit_the_internet` & `summarize_results`
  - 2 tabs
    - AI Control
    - Human File Review (current file search / viewer)
  - 3 columns in AI Control
    - actual_file_list
    - AI-found candidates
      - can strike out items, rest are passed to analysis
    - AI filtered analysis
      - shows each file/chunk w/ reasoning and weight
      - clicking on line should open file-viewer (w/ LOCs highlighted if present)
      - can strike out items, or commit all to actual_file_list
      - prompt:
        - need human input to help find what we're looking for

- File navigator
  - search results
    - clicking should navigate to text
    - highlight the search text?
  - hover code pops up options
    - search by this
    - ask AI to lookup based on this blob (maybe redundant)

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

## lil things
- streamed responses are received in funky order
  - server: append a timestamp during send
  - client: push inputs into a queue ordered by timestamp, delay the rendering of the first queue item .5 seconds
- rename project.filepath to project.repository_path
- show commits on RoboJob
- fix git commit get request inside a frame BS

# Better Context
## contextual files enhance
- can work w/ line numbers
  - robo input: extract snippets instead of full files
    - break up file into overlapping chunks
  - human input: make vscode helper to output file name w/ line numbers from selection

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
