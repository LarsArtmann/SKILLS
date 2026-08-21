// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/domain-types block #4
type MyInt int

const five = 5
var a MyInt = five // OK: untyped constant takes MyInt's type
f := float64(1.5)
var b MyInt = f
// compile error: "cannot use f (variable of type float64) as MyInt value
// in variable declaration"

