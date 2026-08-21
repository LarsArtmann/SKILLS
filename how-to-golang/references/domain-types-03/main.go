// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/domain-types block #3
type Celsius float64

c := Celsius(20) + Celsius(5)*2 // OK: float64 arithmetic preserved
c2 := c > Celsius(0)            // OK: comparison operators preserved

type Lines []string

lines := Lines{"a"}
lines[0] = "z"             // OK: indexing preserved
lines = append(lines, "b") // OK: append works on any defined slice type

