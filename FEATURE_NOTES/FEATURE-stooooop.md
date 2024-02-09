# ability to halt AI
in `ef/terminate-jobs`

- big button
  - calls Terminate service
  - kills rails server
  - somehow restarts the rails server as well
    - maybe a way it's configured?
      - would be cool to touch tmp/restart.txt and have local runner catch that
    - don't wanna use docker but could
