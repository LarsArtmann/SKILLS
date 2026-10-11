// source: how-to-golang/references/domain-types block #7
// WRONG — UserID is now a distinct type; id.NewID[...] returns
// id.ID[UserBrand, nanoid.ID], not UserID, so every call site
// needs a conversion and library functions won't accept it.
type UserID id.ID[UserBrand, nanoid.ID]

// RIGHT — same type, all library methods and conversions work
type UserID = id.ID[UserBrand, nanoid.ID]

