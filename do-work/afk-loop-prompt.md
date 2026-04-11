Use `/do-work` for exactly one backlog task in this repo.

Execution rules for this AFK run only:

- Read the backlog from `.backlog/tasks/` and choose the highest-priority unblocked task.
- Read the relevant backlog and planning docs before you change anything.
- Read the attached recent-commits input before you implement.
- Follow `/do-work` for exploration, implementation, validation, and commit behavior.
- Complete exactly one task, validate it, commit it, and then mark that backlog task done.
- Do not ask the operator for input.
- If there is no unblocked task left, respond with `<promise>NO MORE TASKS</promise>` and a brief explanation.
- If you cannot proceed safely without operator input or because prerequisites are missing, respond with `<promise>BLOCKED</promise>` and a brief explanation.
