// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/domain-types block #2
type DefBuffer bytes.Buffer // definition

var _ io.Writer = &DefBuffer{}
// compile error: "*DefBuffer does not implement io.Writer (missing method Write)"

