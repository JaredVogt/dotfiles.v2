- when writing commit messages, only reference claude by saying "Message by Claude" at the end
- NEVER include "Co-Authored-By: Claude <noreply@anthropic.com>" in commit messages
- The commit message should end with just "Message by Claude" and nothing else after that
- When adding console.logs for debugging purposes, preface message with [debug]
- if i do the same thing a bunch of times, suggest that perhaps I should add something to global CLAUDE.md


- Some ideas to try
- when i type deep-dive, do a deep-dive through the code base on the specific thing I am asking about and when you have a really good understanding let me know and ask me what I want me to do 

- when writing shell scripts, always use env bash

- when using applescript, use pure instead of calling out to shell script with do shell script... only if there is no other way, provide feedback that maybe a shell script is necessary (but note WARNING because the performance is bad)
