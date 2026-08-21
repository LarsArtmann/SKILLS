// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/domain-types block #5
type DefDur time.Duration
type AliasDur = time.Duration

reflect.TypeOf(DefDur(5)) == reflect.TypeOf(time.Duration(5))   // false — distinct
reflect.TypeOf(AliasDur(5)) == reflect.TypeOf(time.Duration(5)) // true  — identical
reflect.TypeOf(DefDur(5)).Name()   // "DefDur"
reflect.TypeOf(AliasDur(5)).Name() // "Duration" (the underlying name)

