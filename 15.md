Your job is it to create a TODO_LIST.md!

I want you to READ ALL .md files 1 at the time!
After your read ONE .md file: UPSERT the existing TODO_LIST.md!
Then READ THE NEXT .md file!
Also document inside the TODO_LIST.md which files you already read any which you know you still need to READ!

READ, UNDERSTAND, RESEARCH, REFLECT. Break this down into multiple actionable steps.
Think about them again. Execute and Verify them one step at the time. Repeat until
done. Keep going until everything works and you think you did a great job!

Use 1 Sub Agent per file. ONLY 1 Agent at the same time. If a Agent does not response properly ask again with a smaller / split up request.

Now your job is to:
A) figure out, by reading the actually code file, if some of these todo's are already done
B) how much they were done, are there properly integrated and so on and so forth...
C) and update each TODO_LIST.md to represent all these accordingly! AND make sure to de-duplicate the TODOs.
D) repeat until all files are done.

WHEN YOU CREATE YOUR OWN INTERNAL TODO LIST FOR THIS SESSION, MAKE FUCKING SURE TO structure it like this:

- Let Agent READ FILE X, and verify/research the current code based on the claims
- Update TODO_LIST.md with critical findings from file X
- git commit TODO_LIST.md
- Let Agent READ FILE Y, and ...
- Update TODO_LIST.md with critical findings from file Y
- git commit TODO_LIST.md
- ....
