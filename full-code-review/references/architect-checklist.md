# Architect Checklist

Reflect on EVERYTHING. Put your Sr. Software Architect & Product Owner hats on.

Ask for every file:

- Are we doing data-flow well?
- Are we making sure states that should not exist are UNREPRESENTABLE, enforced by STRONG TYPES?
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
