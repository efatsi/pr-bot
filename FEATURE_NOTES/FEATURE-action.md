# Todo
- replace "Directory Tree:", w/ <directory-tree> </directory-tree>
  - project search: `"[\w+\s?]{2,}:",`

# User-Defined and User-Run actions
Add the ability to run custom actions from the RoboJob show page.
On the show page, there will be a button for each ActionTemplate defined on the Project
Clicking the button will load a new Action form based on the ActionTemplate
The action form will have different inputs based on the template.

add to models
ActionTemplate
- robo_runnable (passes template and description to Robot so it can fire those actions if it sees fit)

project form
- add nested_has_many simple_form stuff for that so the user can add/remove these templates inline

when showing the action form
- render an input for each action_argument
- if action_argument input_type is "branch"
  - make the input a select
  - dip into project filepath directory and get
    - list of git branches: use these as choices for the select input
    - current branch: use this as the "selected" option
  - add a select option for "+ New Branch"
    - clicking on that turns the select input into a regular string input allowing the user to type in a new branch name
- if `string`
  - regular string input

when submitting the action form
- if has all required arguments
- save Action, save command based on action_template and arguments
- run command in project directory
- save output from command run

redo history to
- include actions amidst job changesets
- include commits while at it

rewrite RoboChanges controller to pull the sse stuff into background jobs

## thoughts
RoboChanges
are these just Actions that were queued up based on ActionTemplates?
  yeah... because i'm (edit: not) about to add a `command` field to RoboChange

## oooh:
command: `rspec spec/` & feed response back into prompt up to 3 times trying to fix it
  robo conductor that can run multiple requests with automated feedback and "go on" / "stop" decision points

## uh oh
- how does it restart your rails server?
