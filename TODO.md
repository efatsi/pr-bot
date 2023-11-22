# TODO
- commit form
  - fix new_branch submission
  - fix modal rendering on some widths

- add flash messages
  - test w/ commit success
  - test w/ commit failure

- contextual files fix
  db/schema.rb
  /db/schema.rb
  run unpack_files and "remove_starting_slash" on save
  alphabetize contextual_files on save
  pull files out of request

- consolidate Fire All add/remove turbo_stream code

- add "content search" mode. move the search filtering logic from the frontend to the backend
  - add 2 API calls nested under project:
    - file_name_search (pulling logic from `renderFileList`)
    - file_content_search (new action to grep for search terms within project files and return list with matches)
  - add toggle to fuzzy_finder form to switch between file_name and file_content mode
  - instead of loading all files into the DOM `data-fuzzy-finder-file-data-value`
    - pass in 2 new API paths that can be used based on what mode is switched

- Step 3: cleanup
  - maybe: get rid of steps, sit this button next to Step 2
  - stream button, similar to "continue"
    - new followup job
    - optional message?
  - LLM call w/
    - git diff
    - copy of full files
    - prompt asking to check for syntax errors, logic bugs, whitespace
    - example shows a couple things i want it to hit
  - generate new RoboChanges
    - render w/ light blue
    - maybe icon everything up (plus / pencil / broom)

- full-blown customizable action templates
  - on all projects: git push origin [branch]
  - can add new action templates to projects
  - can create actions from templates in RoboJob

- continue prompt:
  - render new ones w/ flair
  - a "ding" when it's done

- all files make click-to-copy (or open in vscode...)

- export sharable RoboJob

- cost updates
  - toggle on RoboJob to show per-request cost
    - show request cost on the Response dropdown
  - project cost dips down through RoboJob requests and job-less Commit requests
  - RoboJob cost dips down through self's requests, followup requests, and commit requests

## v2

- Better contextual file finding
  - Data compression
    - https://github.blog/2023-05-17-how-github-copilot-is-getting-better-at-understanding-your-code/
    - recognize filepath root and pull that out of contextual_file check
  - run this locally, slower but could be more accurate
    - robo recon:
      - cached process that generates overviews of files so contextual_files can be done more accurately
    - optional second pass:
      - only select a small subset first, instead of all the things you might need
      - then a second pass pulls additional files based on context learned from the first
      - until satisfied
      - collecting pieces of the files that matter
  - human seed:
    - user can define known context files to include, passes files to robo step to help find other files
  - git history
    - there's soooo much to dig through here, but it's some of the more valuable stuff (eg: fix this bug over here just like when it was fixed by shaaaaa)

- commit polish
  - handle branch funniness
    - If new_branch is an existing brnach, switch to it instead of creating a new one
    - bash_runner
      - takes array of commands and runs them all
      - tracks status
      - outputs all data in a json blob to be saved on records

## v3 / gettin fancy:

- wrap in Electron app

- handle photo uploads

- voice changes:
  - update the RoboChange file creation logic to target the full path based on the project's filepath. For context, look at robo_change robo_job and project model files

