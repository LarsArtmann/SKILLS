// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/domain-types block #6
// WRONG — this is just string, no type safety at all
type Email = string

// RIGHT — distinct type, compile-time safety, write your own methods
type Email string

