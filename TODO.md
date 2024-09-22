## BIG PUNCH LIST
x event navigation
x image uploads
~ making context better
  ~ search terms
    - human review of terms
    - option for one more round of file checking after the first, iterative over each file

## contextual files
- inline edit of seed files
- hooking up file finder when reviewing examined files
  - always render a hidden input form
  - selections in the modal update the input form, which auto submits, which auto updates all seed_contextual_files for that robojob

- cleanup
  - display accepted in list next to seed, only have pending / ignored in table
  - open full input list in VSCode
  - button to display "input" when prompt is running
  - button to display "implementation overview" explanation from robot
  - move followon orchestration to RoboConductor out of runner's finish+super

## lil punch list
- expand_all actions button
- rm RoboJob + FollowupJob, replace w/ WorkSession + RoboJobs
- job termination: add "stop" to running job (rename scaffold to processing)
- add "copy" to Action renderings

# export sharable RoboJob
- unpacked feature requests
- unpacked implementation overview
- diffs splayed out w/o the border cutting them off

## File navigator
- search results
  - clicking should navigate to text
  - highlight the search text?
- select & hover code pops up options
  - search by this
  - ask AI to lookup based on this blob (maybe redundant)

## better context expansion
- `hit_the_internet` & `summarize_results`
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
  - example shows a couple things i want it to hit (cleaning up whitespace would be sweeeeet)
- generate new RoboChanges
  - render w/ light blue
  - maybe icon everything up (plus / pencil / broom)

## cost updates
- toggle on project / index
- `RoboRequestCostCalculator`
  - count up all the tokens better
    - make a single request w/o images, simple
    - wait for API usage to report it
    - count it
    - then, do one w/ images, can sum up based on size
  - per-robot cost hash
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
