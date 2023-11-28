# TODO
- contextual files enhance
  ~ show found search matches below file
    - show all results
      - collect all lines, collapse overlaps, remove duplicates
      - show distinct groups
      - highlight matching search term (checking regex)
    - highlight line & handle click when hovering search results

  - let you access file finder from show view
    - allow form still, but can add / remove w/o it

  - files mentioned in feature request have content sent in contextual_files search
  - files mentioned in feature request are auto added to contextual_files
  - per file line, show "rationale" from robo_request (or "included in feature request") (or "human added")

- prompt stuff
  - for instrsuctions: do rewrite entire methods. do not rewrite just the smallest portion necessary

- Step 3: cleanup
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

- all files make click-to-copy (or open in vscode...)
- a "ding" when it's done

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
  - git history
    - there's soooo much to dig through here, but it's some of the more valuable stuff (eg: fix this bug over here just like when it was fixed by shaaaaa)

## v3 / gettin fancy:

- wrap in Electron app

- handle photo uploads

- voice changes:
  - update the RoboChange file creation logic to target the full path based on the project's filepath. For context, look at robo_change robo_job and project model files

