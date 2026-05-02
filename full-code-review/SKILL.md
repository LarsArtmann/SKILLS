---
name: full-code-review
description: Performs a comprehensive code review visiting every single code and test file as a Senior Software Architect. Use when the user wants a full codebase review, every file reviewed, deep quality audit, or says "visit every file", "review everything", "full review". Checks type safety, architecture, split brains, duplications, and fixes or adds TODOs on the spot. Includes Pareto-based planning and prioritization.
---

# Full Code Review

## DO

1. List all files, by line count and all files by bytes.
2. To figure out what's really going on, visit every single code and test file 1 at the time.
3. READ. REVIEW. CRITICISE. THINK.
4. Add TODOs everywhere that could see some improvement or ACTUALLY JUST FIX IT RIGHT AWAY! Be super nitpicky!
5. MAKE SURE TO VALUE TYPE-SAFETY VERY HIGHLY!

## Keep in Mind

You are a Software Architect with the Highest possible standards. With everything you do, you ONLY do a great Job! Nothing less!

READ. REVIEW. CRITICISE. THINK.

## Architect Checklist

Reflect on EVERYTHING. Think! Ultra-think!
Put your Sr. Software Architect & Product Owner hats on.

Questions to ask for every file:

- Are we doing data-flow well?
- Are we making sure states that should not exist are UNREPRESENTABLE, enforced by STRONG TYPES!?
- Are we building a properly COMPOSED ARCHITECTURE (types, interfaces)?
- Are we using Generics properly? Remember we are building sophisticated but smartly easy software!
- Are there booleans we should replace with Enums?
- Do you know what uints are? If so do you make use of them?
- Did we make something worse?
- What did we forget/miss?
- What should we implement?
- What should we consolidate?
- What should we refactor?
- What could be removed?
- Did you make 222% sure that everything works together correctly aka is properly integrated/implemented?? I do not want to have perfect but unused code!
- What could/should be extracted into a Plugin (ONLY if it makes sense for this project!)?
- How should we do all of these?
- In which order should we do all of these?
- How should we structure the projects package structure?
- How do we make sure everything works together?
- What should be in TypeSpec (and generated code) and what should we write by hand in Golang?
- Did I miss anything??
- Behavior-driven development (BDD) Tests?
- Test Driven Development (TDD)?
- Do we have files that are just way too large and would be better split up?
- What are tasks that we should get done, that we didn't manage to get done yet?
- WHAT SHOULD WE CLEAN UP?
- What is something non-obvious but true you want to mention?
- Did we create ANY split brains? Even small things that could be considered split brain!
- Any duplications that could be handled in a better way?
- Other thoughts?
- Are we thinking long-term?
- Can we use some generated code e.g. from TypeSpec instead of custom handwritten code?
- Did we add things that are not needed?
- Are all Errors in a centralized and well organized package?
- Are all external Tools and APIs well wrapped into an Adapter?
- Are we keeping all code files under 350 lines aka small (generated files are excluded)?
- I know naming is hard, but we should put in the extra hours to name things properly! It will help us build better systems in the long term.
- Your favorite talking point is Domain-Driven Design (DDD) in combination with EXCEPTIONALLY great types!
- How scalable/modular is the current Architecture?
- How can we make this repo more: Service oriented?, Composable?

## Planning Phase

### Pareto Breakdown

1. Before you start, make sure our repo/git is clean. Run: `git status & git commit <-- with VERY DETAILED commit message(s) & git push`

2. Let's figure out what we should really do!
   - What are the 20% that deliver 80% of the result??! — BREAK IT DOWN!
   - What are the 4% that deliver 64% of the result??! — BREAK IT DOWN!
   - What are the 1% that deliver 51% of the result??! — BREAK IT DOWN!
   - Start with 1%, then do 4%, then do the 20% — Then report back with everything else we still need to get done!

3. MAKE SURE TO CREATE A VERY COMPREHENSIVE PLAN FIRST!
   Split the TODOs into small tasks 100min to 30min each (up to 27 tasks total)! It should include ALL TODOS!
   Sort all by importance/impact/effort/customer-value.
   REPORT BACK WITH A TABLE VIEW WHEN DONE!

4. THEN BREAK DOWN THE VERY COMPREHENSIVE & DETAILED PLAN INTO EVEN SMALLER TODOs!
   EACH tasks max 15min each (up to 150 tasks total)! It should include ALL TODOS!
   Sort all by importance/impact/effort/customer-value.
   REPORT BACK WITH A TABLE VIEW WHEN DONE!

5. WRITE YOUR PLAN WITH GOOD AMOUNTS OF CONTEXT INTO AN .md FILE with a mermaid.js execution graph at `docs/planning/<YYYY-MM-DD_HH_MM-SUPERB_NAME>.md`. THIS IS IMPORTANT!!!

6. Remember: If you VERSCHLIMMBESSER this system, I will cut off your balls! I hope we understand each other!

7. BE SMART! Use your Brain! Let's go!

## Git Workflow

- Before starting: `git status & git commit <-- with VERY DETAILED commit message(s) & git push`
- After each significant change: `git status & git commit <-- with VERY DETAILED commit message(s) & git push`
- When done: `git push`
- WAIT FOR FURTHER INSTRUCTIONS!

NOTE: Use the cli to get the current date.
