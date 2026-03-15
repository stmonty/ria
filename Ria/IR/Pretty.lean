import Ria.IR.Expr

namespace Ria.IR

/-- Pretty-print an expression tree as a human-readable string.
    Variables are represented as names: x0, x1, x2, ... -/

private structure PrettyState where
  nextVar : Nat := 0

private abbrev PrettyM := StateM PrettyState

private def freshVar : PrettyM String := do
  let s ← get
  set { s with nextVar := s.nextVar + 1 }
  return s!"x{s.nextVar}"

/-- Variable representation for pretty-printing: each variable holds its name. -/
private abbrev NameV (_ : Ty) := String

partial def prettyExpr : Expr NameV a → PrettyM String
  | .var x => return x
  | .litF x => return toString x
  | .literal _ => return "arr"
  | .lett e body => do
    let name ← freshVar
    let eStr ← prettyExpr e
    let bodyStr ← prettyExpr (body name)
    return s!"let {name} = {eStr} in\n{bodyStr}"
  | .addf e1 e2 => do
    let s1 ← prettyExpr e1
    let s2 ← prettyExpr e2
    return s!"({s1} + {s2})"
  | .mulf e1 e2 => do
    let s1 ← prettyExpr e1
    let s2 ← prettyExpr e2
    return s!"({s1} * {s2})"
  | .subf e1 e2 => do
    let s1 ← prettyExpr e1
    let s2 ← prettyExpr e2
    return s!"({s1} - {s2})"
  | .map _f e => do
    let s ← prettyExpr e
    return s!"map(f, {s})"
  | .zipWith _f e1 e2 => do
    let s1 ← prettyExpr e1
    let s2 ← prettyExpr e2
    return s!"zipWith(f, {s1}, {s2})"
  | .reduce _f _init e => do
    let s ← prettyExpr e
    return s!"reduce(f, {s})"
  | .scale e1 e2 => do
    let s1 ← prettyExpr e1
    let s2 ← prettyExpr e2
    return s!"scale({s1}, {s2})"
  | .dot e1 e2 => do
    let s1 ← prettyExpr e1
    let s2 ← prettyExpr e2
    return s!"dot({s1}, {s2})"
  | .matmul e1 e2 => do
    let s1 ← prettyExpr e1
    let s2 ← prettyExpr e2
    return s!"matmul({s1}, {s2})"

/-- Pretty-print a closed expression. -/
def pretty (e : ClosedExpr a) : String :=
  let (s, _) := (prettyExpr (e NameV)).run {}
  s

/-- Count the number of map/zipWith/reduce nodes (i.e., array passes). -/
partial def countPasses : Expr NameV a → Nat
  | .var _ | .litF _ | .literal _ => 0
  | .lett e body =>
    let name := s!"_" -- dummy, won't be printed
    countPasses e + countPasses (body name)
  | .addf e1 e2 | .mulf e1 e2 | .subf e1 e2 =>
    countPasses e1 + countPasses e2
  | .map _ e => 1 + countPasses e
  | .zipWith _ e1 e2 => 1 + countPasses e1 + countPasses e2
  | .reduce _ _ e => 1 + countPasses e
  | .scale e1 e2 => countPasses e1 + countPasses e2
  | .dot e1 e2 => countPasses e1 + countPasses e2
  | .matmul e1 e2 => countPasses e1 + countPasses e2

/-- Count passes in a closed expression. -/
def passes (e : ClosedExpr a) : Nat :=
  countPasses (e NameV)

end Ria.IR
