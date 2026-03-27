import Ria.IR.Expr

namespace Ria.IR

private structure PrettyState where
  nextVar : Nat := 0

private abbrev PrettyM := StateM PrettyState

private def freshVar : PrettyM String := do
  let s ← get
  set { s with nextVar := s.nextVar + 1 }
  return s!"x{s.nextVar}"

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
  | .addf e1 e2 => do return s!"({← prettyExpr e1} + {← prettyExpr e2})"
  | .mulf e1 e2 => do return s!"({← prettyExpr e1} * {← prettyExpr e2})"
  | .subf e1 e2 => do return s!"({← prettyExpr e1} - {← prettyExpr e2})"
  | .map _f e => do return s!"map(f, {← prettyExpr e})"
  | .zipWith _f e1 e2 => do return s!"zipWith(f, {← prettyExpr e1}, {← prettyExpr e2})"
  | .reduce _f _init e => do return s!"reduce(f, {← prettyExpr e})"
  | .scale e1 e2 => do return s!"scale({← prettyExpr e1}, {← prettyExpr e2})"
  | .dot e1 e2 => do return s!"dot({← prettyExpr e1}, {← prettyExpr e2})"
  | .matmul e1 e2 => do return s!"matmul({← prettyExpr e1}, {← prettyExpr e2})"

def pretty (e : ClosedExpr a) : String :=
  let (s, _) := (prettyExpr (e NameV)).run {}
  s

partial def countPasses : Expr NameV a → Nat
  | .var _ | .litF _ | .literal _ => 0
  | .lett e body => countPasses e + countPasses (body "_")
  | .addf e1 e2 | .mulf e1 e2 | .subf e1 e2 => countPasses e1 + countPasses e2
  | .map _ e => 1 + countPasses e
  | .zipWith _ e1 e2 => 1 + countPasses e1 + countPasses e2
  | .reduce _ _ e => 1 + countPasses e
  | .scale e1 e2 | .dot e1 e2 | .matmul e1 e2 => countPasses e1 + countPasses e2

def passes (e : ClosedExpr a) : Nat :=
  countPasses (e NameV)

end Ria.IR
