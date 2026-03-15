import Ria

open Ria
open Ria.IR

-- Helper: USize proof for small sizes
private theorem small_lt_usize (n : Nat) (h : n ≤ 1000) : n < USize.size := by
  rcases USize.size_eq with h32 | h64 <;> omega

-- Helper: compare floats with tolerance
private def approxEq (a b : Float) (eps := 1e-10) : Bool :=
  (a - b).abs < eps

-- Helper: check all elements of two vectors match
private def allClose (a b : Ria.Array [n]) (eps := 1e-10) : Bool :=
  (List.range n).all fun i =>
    approxEq (a.data.get i (by sorry)) (b.data.get i (by sorry)) eps

-- Simple test runner
private def runTest (name : String) (test : IO Unit) : IO Bool := do
  try
    test
    IO.println s!"  ✓ {name}"
    return true
  catch e =>
    IO.eprintln s!"  ✗ {name}: {e}"
    return false

-- ============================================================
-- Array construction tests
-- ============================================================

def testZeros : IO Unit := do
  let v := Array.zeros [3] (small_lt_usize 3 (by omega))
  assert! v.get ⟨0, by omega⟩ == 0.0
  assert! v.get ⟨1, by omega⟩ == 0.0
  assert! v.get ⟨2, by omega⟩ == 0.0

def testFill : IO Unit := do
  let v := Array.fill [4] 5.0 (small_lt_usize 4 (by omega))
  assert! v.get ⟨0, by omega⟩ == 5.0
  assert! v.get ⟨1, by omega⟩ == 5.0
  assert! v.get ⟨2, by omega⟩ == 5.0
  assert! v.get ⟨3, by omega⟩ == 5.0

def testOnes : IO Unit := do
  let v := Array.ones [3] (small_lt_usize 3 (by omega))
  assert! v.get ⟨0, by omega⟩ == 1.0
  assert! v.get ⟨1, by omega⟩ == 1.0
  assert! v.get ⟨2, by omega⟩ == 1.0

-- ============================================================
-- Element access tests
-- ============================================================

def testGetSet : IO Unit := do
  let v := Array.zeros [3] (small_lt_usize 3 (by omega))
  let v := v.set ⟨1, by omega⟩ 42.0
  assert! v.get ⟨0, by omega⟩ == 0.0
  assert! v.get ⟨1, by omega⟩ == 42.0
  assert! v.get ⟨2, by omega⟩ == 0.0

def testGet2dSet2d : IO Unit := do
  let m := Array.zeros [2, 3] (small_lt_usize 6 (by omega))
  let m := m.set2d ⟨0, by omega⟩ ⟨2, by omega⟩ 7.0
  let m := m.set2d ⟨1, by omega⟩ ⟨0, by omega⟩ 9.0
  assert! m.get2d ⟨0, by omega⟩ ⟨2, by omega⟩ == 7.0
  assert! m.get2d ⟨1, by omega⟩ ⟨0, by omega⟩ == 9.0
  assert! m.get2d ⟨0, by omega⟩ ⟨0, by omega⟩ == 0.0

-- ============================================================
-- BLAS operations tests
-- ============================================================

def testAdd : IO Unit := do
  let h := small_lt_usize 3 (by omega)
  let v1 := Array.fill [3] 2.0 h
  let v2 := Array.fill [3] 3.0 h
  let result := v1 + v2
  assert! result.get ⟨0, by omega⟩ == 5.0
  assert! result.get ⟨1, by omega⟩ == 5.0

def testSub : IO Unit := do
  let h := small_lt_usize 3 (by omega)
  let v1 := Array.fill [3] 5.0 h
  let v2 := Array.fill [3] 3.0 h
  let result := v1 - v2
  assert! result.get ⟨0, by omega⟩ == 2.0

def testScale : IO Unit := do
  let v := Array.fill [3] 4.0 (small_lt_usize 3 (by omega))
  let result := (2.0 : Float) * v
  assert! result.get ⟨0, by omega⟩ == 8.0
  assert! result.get ⟨1, by omega⟩ == 8.0

def testNeg : IO Unit := do
  let v := Array.fill [3] 3.0 (small_lt_usize 3 (by omega))
  let result := -v
  assert! result.get ⟨0, by omega⟩ == -3.0

def testDot : IO Unit := do
  let h := small_lt_usize 3 (by omega)
  let v1 := Array.fill [3] 2.0 h
  let v2 := Array.fill [3] 3.0 h
  assert! Ria.Array.dot v1 v2 == 18.0

-- ============================================================
-- Combinator tests
-- ============================================================

def testMap : IO Unit := do
  let v := Array.fill [3] 5.0 (small_lt_usize 3 (by omega))
  let result := Ria.Array.map (· * 2.0) v
  assert! result.get ⟨0, by omega⟩ == 10.0
  assert! result.get ⟨1, by omega⟩ == 10.0
  assert! result.get ⟨2, by omega⟩ == 10.0

def testReduce : IO Unit := do
  let v := Array.fill [4] 3.0 (small_lt_usize 4 (by omega))
  let result := Ria.Array.reduce (· + ·) 0.0 v
  assert! result == 12.0

def testReduceProduct : IO Unit := do
  let v := Array.fill [3] 2.0 (small_lt_usize 3 (by omega))
  let result := Ria.Array.reduce (· * ·) 1.0 v
  assert! result == 8.0

def testZipWith : IO Unit := do
  let h := small_lt_usize 3 (by omega)
  let v1 := Array.fill [3] 2.0 h
  let v2 := Array.fill [3] 3.0 h
  let result := Ria.Array.zipWith (· * ·) v1 v2
  assert! result.get ⟨0, by omega⟩ == 6.0
  assert! result.get ⟨1, by omega⟩ == 6.0

def testTabulate : IO Unit := do
  let v := Ria.Array.tabulate [4] (fun i => i.val.toFloat)
  assert! v.get ⟨0, by omega⟩ == 0.0
  assert! v.get ⟨1, by omega⟩ == 1.0
  assert! v.get ⟨2, by omega⟩ == 2.0
  assert! v.get ⟨3, by omega⟩ == 3.0

-- ============================================================
-- IR eval tests
-- ============================================================

def testEvalLiteral : IO Unit := do
  let v := Array.fill [3] 7.0 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun _ => .literal v
  let result := eval (expr Ty.denote)
  assert! result.get ⟨0, by omega⟩ == 7.0

def testEvalMap : IO Unit := do
  let v := Array.fill [3] 4.0 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun _ =>
    .map (· + 1.0) (.literal v)
  let result := eval (expr Ty.denote)
  assert! result.get ⟨0, by omega⟩ == 5.0
  assert! result.get ⟨2, by omega⟩ == 5.0

def testEvalScalarOps : IO Unit := do
  let expr : ClosedExpr .float := fun _ =>
    .addf (.litF 3.0) (.mulf (.litF 2.0) (.litF 4.0))
  let result := eval (expr Ty.denote)
  assert! result == 11.0

def testEvalLett : IO Unit := do
  let v := Array.fill [3] 2.0 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr .float := fun _ =>
    .lett (.literal v) (fun x => .reduce (· + ·) 0.0 (.var x))
  let result := eval (expr Ty.denote)
  assert! result == 6.0

-- ============================================================
-- Fusion correctness tests
-- ============================================================

def testFusionMapMap : IO Unit := do
  let v := Array.fill [3] 2.0 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun _ =>
    .map (· + 1.0) (.map (· * 2.0) (.literal v))
  let unfused := eval (expr Ty.denote)
  let fused := eval (fuse (expr Ty.denote))
  assert! allClose unfused fused

def testFusionTripleMap : IO Unit := do
  let v := Array.fill [3] 2.0 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun _ =>
    .map (· + 10.0) (.map (· * 3.0) (.map (· - 1.0) (.literal v)))
  let unfused := eval (expr Ty.denote)
  let fused := eval (fuse (expr Ty.denote))
  assert! allClose unfused fused
  -- (2-1)*3+10 = 13
  assert! approxEq (fused.get ⟨0, by omega⟩) 13.0

def testFusionReduceMap : IO Unit := do
  let v := Array.fill [3] 2.0 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr .float := fun _ =>
    .reduce (· + ·) 0.0 (.map (fun x => x * x) (.literal v))
  let unfused := eval (expr Ty.denote)
  let fused := eval (fuse (expr Ty.denote))
  assert! approxEq unfused fused
  -- 2*2 + 2*2 + 2*2 = 12
  assert! approxEq fused 12.0

def testFusionZipWithMapLeft : IO Unit := do
  let h := small_lt_usize 3 (by omega)
  let v1 := Array.fill [3] 2.0 h
  let v2 := Array.fill [3] 3.0 h
  let expr : ClosedExpr (.array [3]) := fun _ =>
    .zipWith (· + ·) (.map (· * 10.0) (.literal v1)) (.literal v2)
  let unfused := eval (expr Ty.denote)
  let fused := eval (fuse (expr Ty.denote))
  assert! allClose unfused fused
  -- 2*10 + 3 = 23
  assert! approxEq (fused.get ⟨0, by omega⟩) 23.0

def testFusionZipWithMapRight : IO Unit := do
  let h := small_lt_usize 3 (by omega)
  let v1 := Array.fill [3] 2.0 h
  let v2 := Array.fill [3] 3.0 h
  let expr : ClosedExpr (.array [3]) := fun _ =>
    .zipWith (· + ·) (.literal v1) (.map (· * 10.0) (.literal v2))
  let unfused := eval (expr Ty.denote)
  let fused := eval (fuse (expr Ty.denote))
  assert! allClose unfused fused
  -- 2 + 3*10 = 32
  assert! approxEq (fused.get ⟨0, by omega⟩) 32.0

def testFusionIdentity : IO Unit := do
  let v := Array.fill [3] 5.0 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun _ =>
    .map (· + 1.0) (.literal v)
  let unfused := eval (expr Ty.denote)
  let fused := eval (fuse (expr Ty.denote))
  assert! allClose unfused fused

def testFusionBlasDot : IO Unit := do
  let h := small_lt_usize 3 (by omega)
  let v1 := Array.fill [3] 2.0 h
  let v2 := Array.fill [3] 3.0 h
  let expr : ClosedExpr .float := fun _ =>
    .dot (.literal v1) (.literal v2)
  let unfused := eval (expr Ty.denote)
  let fused := eval (fuse (expr Ty.denote))
  assert! approxEq unfused fused
  assert! approxEq fused 18.0

-- ============================================================
-- Normalize (fusion through let-bindings) tests
-- ============================================================

def testNormalizeMapMapLet : IO Unit := do
  let v := Array.fill [3] 2.0 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun V =>
    .lett (.map (· * 2.0) (.literal v)) (fun a =>
      .map (· + 1.0) (.var a))
  let unfused := run expr
  let normalized := run (normalize expr)
  assert! allClose unfused normalized
  -- 2*2+1 = 5
  assert! approxEq (normalized.get ⟨0, by omega⟩) 5.0

def testNormalizeTripleMapLets : IO Unit := do
  let v := Array.fill [3] 2.0 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun V =>
    .lett (.map (· - 1.0) (.literal v)) (fun a =>
      .lett (.map (· * 3.0) (.var a)) (fun b =>
        .map (· + 10.0) (.var b)))
  let unfused := run expr
  let normalized := run (normalize expr)
  assert! allClose unfused normalized
  -- (2-1)*3+10 = 13
  assert! approxEq (normalized.get ⟨0, by omega⟩) 13.0

def testNormalizeReduceMapLet : IO Unit := do
  let v := Array.fill [3] 2.0 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr .float := fun V =>
    .lett (.map (fun x => x * x) (.literal v)) (fun a =>
      .reduce (· + ·) 0.0 (.var a))
  let unfused := run expr
  let normalized := run (normalize expr)
  assert! approxEq unfused normalized
  assert! approxEq normalized 12.0

def testNormalizePassCount : IO Unit := do
  let v := Array.fill [3] 2.0 (small_lt_usize 3 (by omega))
  -- 3 passes before normalize
  let expr : ClosedExpr (.array [3]) := fun V =>
    .lett (.map (· - 1.0) (.literal v)) (fun a =>
      .lett (.map (· * 3.0) (.var a)) (fun b =>
        .map (· + 10.0) (.var b)))
  assert! passes expr == 3
  -- 1 pass after normalize
  let norm := normalize expr
  assert! passes norm == 1

-- ============================================================
-- Pretty-printing tests
-- ============================================================

def testPrettyLiteral : IO Unit := do
  let v := Array.fill [3] 1.0 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun _ => .literal v
  assert! pretty expr == "arr"

def testPrettyMap : IO Unit := do
  let v := Array.fill [3] 1.0 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun _ =>
    .map (· + 1.0) (.literal v)
  assert! pretty expr == "map(f, arr)"

def testPrettyLet : IO Unit := do
  let v := Array.fill [3] 1.0 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun V =>
    .lett (.literal v) (fun a => .map (· + 1.0) (.var a))
  let s := pretty expr
  -- Should contain "let x0" and "map"
  assert! s.splitOn "let x0" != [s]
  assert! s.splitOn "map" != [s]

-- ============================================================
-- Main: run all tests
-- ============================================================

def main : IO UInt32 := do
  let mut passed := 0
  let mut failed := 0

  let tests : List (String × IO Unit) := [
    -- Construction
    ("zeros", testZeros),
    ("fill", testFill),
    ("ones", testOnes),
    -- Element access
    ("get/set 1D", testGetSet),
    ("get/set 2D", testGet2dSet2d),
    -- BLAS ops
    ("add", testAdd),
    ("sub", testSub),
    ("scale", testScale),
    ("neg", testNeg),
    ("dot", testDot),
    -- Combinators
    ("map", testMap),
    ("reduce", testReduce),
    ("reduce product", testReduceProduct),
    ("zipWith", testZipWith),
    ("tabulate", testTabulate),
    -- IR eval
    ("eval literal", testEvalLiteral),
    ("eval map", testEvalMap),
    ("eval scalar ops", testEvalScalarOps),
    ("eval lett", testEvalLett),
    -- Fusion
    ("fusion: map-map", testFusionMapMap),
    ("fusion: triple map", testFusionTripleMap),
    ("fusion: reduce-map", testFusionReduceMap),
    ("fusion: zipWith-map left", testFusionZipWithMapLeft),
    ("fusion: zipWith-map right", testFusionZipWithMapRight),
    ("fusion: identity", testFusionIdentity),
    ("fusion: BLAS dot", testFusionBlasDot),
    -- Normalize (fusion through lets)
    ("normalize: map-map let", testNormalizeMapMapLet),
    ("normalize: triple map lets", testNormalizeTripleMapLets),
    ("normalize: reduce-map let", testNormalizeReduceMapLet),
    ("normalize: pass count", testNormalizePassCount),
    -- Pretty-printing
    ("pretty: literal", testPrettyLiteral),
    ("pretty: map", testPrettyMap),
    ("pretty: let", testPrettyLet)
  ]

  IO.println s!"Running {tests.length} tests...\n"

  for (name, test) in tests do
    let ok ← runTest name test
    if ok then passed := passed + 1
    else failed := failed + 1

  IO.println s!"\n{passed} passed, {failed} failed, {tests.length} total"

  if failed > 0 then return 1
  return 0
