## BIG PUNCH LIST
x event navigation
~ making context better
~ image uploads
- open contextual files list in VSCode

## contextual files
- expand
  - auto ignore if not valid
  - auto examine
  - auto accept 4+, auto reject 2-
  - auto fire highlight after examine

- examine display
  - :mag: button to open file viewer w/ file

- config options
  - change open file links to open in VSCode

- cleanup
  - button to display "implementation overview" explanation from robot
  - `# TODO: move this logic closer to gemini client` in `job_runners/instructions/runner.rb`
  - bonus request to highlight the key words
    - can load it in the background, skip the stream, and replace when it's done
    - https://chatgpt.com/c/ecb250e3-44ef-44b2-8b02-7107e76efaa7, highlighting w/ italics and bold oohhhhh
  - fix Accept link in "Examine" detail
  - remove Edit link in "Expand" detail
  - default dropdowns to closed, button to toggle all
    - new controller to inspect children for all dropdowns and close em from the outside

- phase2 / experimental
  - ask for key line numbers in prompt
    - modeling
      - nth: key line numbers []
      - nth: request_more_supporting_files
  - ask more questions in expansion
    - second pass at expand / examine after first
      - or, asking "any more files you want to see after each file"
    - eg: what project-wide searches to run in what subdirectories to find more context?
          then run those searches and consider files
    - maybe RoboConductor can do some orchestrating?!
      - starting different robo_request batches tied to the same event
      - wrapping them in it's own `on_finish` logic, to queue follow ons (through itself? 😬)
  - later: `hit_the_internet` & `summarize_results`
  - human input: make vscode helper to output file name w/ line numbers from selection

## lil punch list
- slider for the width between the feature and the contextual files
- add gpt-4 ♨️ / 🌡️ (increased temperature)
- buttons
  - expand_all child dropdown (put on actions)
- editing UI: open file viewer/picker from default view
- rename project.filepath to project.repository_path
- inspect, fix or kill, git commit on project
- remove skipped actions from prompt when followup
  - option to do so if any skipped, checked by default

# Event Navigation
## RoboEvent actions
- add "edit input" if editable type (build_instructions / followup_instructions)
- add "ignore" action if !start
  - toggle between active / ignored robo_events + dotted "next event" UI
- add "stop" to running job (rename scaffold to processing)
- add "copy" to Action renderings

# export sharable RoboJob
- unpacked feature requests
- unpacked implementation overview
- diffs splayed out w/o the border cutting them off

## File navigator
- search results
  - clicking should navigate to text
  - highlight the search text?
- hover code pops up options
  - search by this
  - ask AI to lookup based on this blob (maybe redundant)

## internet search
- ask AI for a few internet searches given the prompt
- hit some API somehow, LangChain has examples
  - https://python.langchain.com/docs/integrations/tools/ddg
  - https://python.langchain.com/docs/integrations/tools/tavily_search
  - maybe pop out of Ruby for this one, pass to Python via Redis and use off-the-shelf tooling
- summarize responses into condense information useful for the implementation

## git history
- can work against a specific diff
  - need ability to vet files into subset first
    - `git show --stat` + prompt knows how to whittle out big yaml files or updates out of the gates
    - skip contents of deleted files
    - skip contents of markdown files
  - for interesting files, pass in more than git gives you by default
    - `-U` flag can increase context lines: `git diff -U20`
- remind the prompt this is supplementary to contextual files (wrap in `<context:git>` `</context:git>`)
  - replace others eg: "Directory Tree:" w/ <directory-tree> </directory-tree>
  - project search: `"[\w+\s?]{2,}:",`

## commit mode
- aka attributable robo collab
  - helpful for scanning & catching robo blunders
- Better Fire All button
  - runs changes
  - opens new commit as sub-event
  - auto generates prompt based on your last input and diff
  - commits as a different github user
- prompts to commit your stuff for you if you have in progress changes
- can revert commits, navigate back to version

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

## different changeset format
- ask for lines to replace instead of content
  - less tokens
  - potentially more accurate
- ask for changes in git-diff mode instead of find-replace mode
  - it's way better, so says the Aider team
    - https://aider.chat/docs/unified-diffs.html
  - but... what about when it fucks up?

## cost updates
- toggle on project / index
- count up all the tokens better
- cached on robo_job
  - counts all requests, parent_job aggregates self requests + children job counts
- toggle on RoboJob to show per-request cost
  - show request cost on the Response dropdown

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
