# TODO
- add "content search" mode. move the search filtering logic from the frontend to the backend
  - add 2 API calls nested under project:
    - file_name_search (pulling logic from `renderFileList`)
    - file_content_search (new action to grep for search terms within project files and return list with matches)
  - add toggle to fuzzy_finder form to switch between file_name and file_content mode
  - instead of loading all files into the DOM `data-fuzzy-finder-file-data-value`
    - pass in 2 new API paths that can be used based on what mode is switched

- commit button
  - "looks good", hint to commit whenever stuff works
  - open modals
    - offer AI suggestion based on diff (and feature)
    - long version / short version
    - button to fire git commit
    - input for branch (defaults to current branch, if type new branch, checkout before committing)

- full-blown customizable action templates
  - on all projects: git push origin [branch]
  - can add new action templates to projects
  - can create actions from templates in RoboJob

- contextual files fix
  db/schema.rb
  /db/schema.rb
  run unpack_files and "remove_starting_slash" on save
  alphabetize contextual_files on save
  pull files out of request

- continue prompt:
  - render new ones w/ flair
  - a "ding" when it's done

- all files make click-to-copy (or open in vscode...)

- export sharable RoboJob


## v2

- API call w/ changed files / diff back to check for syntax issues / logic bugs

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

## v3 / gettin fancy:

- handle photo uploads

- voice changes:
  - update the RoboChange file creation logic to target the full path based on the project's filepath. For context, look at robo_change robo_job and project model files

