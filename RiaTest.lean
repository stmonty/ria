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
private def allClose (a b : Ria.Array [n] dtype) (eps := 1e-10) : Bool :=
  (List.range n).all fun i =>
    approxEq (a.readElem i.toUSize) (b.readElem i.toUSize) eps

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
-- Array construction tests (float64)
-- ============================================================

def testZeros : IO Unit := do
  let v := Array.zeros [3] .float64 (small_lt_usize 24 (by omega))
  assert! v.get ⟨0, by omega⟩ == 0.0
  assert! v.get ⟨1, by omega⟩ == 0.0
  assert! v.get ⟨2, by omega⟩ == 0.0

def testFill : IO Unit := do
  let v := Array.fill [4] 5.0 .float64 (small_lt_usize 4 (by omega))
  assert! v.get ⟨0, by omega⟩ == 5.0
  assert! v.get ⟨3, by omega⟩ == 5.0

def testOnes : IO Unit := do
  let v := Array.ones [3] .float64 (small_lt_usize 3 (by omega))
  assert! v.get ⟨0, by omega⟩ == 1.0

-- ============================================================
-- float32 tests
-- ============================================================

def testFillF32 : IO Unit := do
  let v := Array.fill [3] 7.0 .float32 (small_lt_usize 3 (by omega))
  assert! approxEq (v.get ⟨0, by omega⟩) 7.0 1e-6
  assert! approxEq (v.get ⟨1, by omega⟩) 7.0 1e-6
  assert! approxEq (v.get ⟨2, by omega⟩) 7.0 1e-6

def testAddF32 : IO Unit := do
  let h := small_lt_usize 3 (by omega)
  let v1 := Array.fill [3] 2.0 .float32 h
  let v2 := Array.fill [3] 3.0 .float32 h
  let result := v1 + v2
  assert! approxEq (result.get ⟨0, by omega⟩) 5.0 1e-6

def testDotF32 : IO Unit := do
  let h := small_lt_usize 3 (by omega)
  let v1 := Array.fill [3] 2.0 .float32 h
  let v2 := Array.fill [3] 3.0 .float32 h
  assert! approxEq (Ria.Array.dot v1 v2) 18.0 1e-4

-- ============================================================
-- Element access tests
-- ============================================================

def testGetSet : IO Unit := do
  let v := Array.zeros [3] .float64 (small_lt_usize 24 (by omega))
  let v := v.set ⟨1, by omega⟩ 42.0
  assert! v.get ⟨0, by omega⟩ == 0.0
  assert! v.get ⟨1, by omega⟩ == 42.0
  assert! v.get ⟨2, by omega⟩ == 0.0

def testGet2dSet2d : IO Unit := do
  let m := Array.zeros [2, 3] .float64 (small_lt_usize 48 (by omega))
  let m := m.set2d ⟨0, by omega⟩ ⟨2, by omega⟩ 7.0
  let m := m.set2d ⟨1, by omega⟩ ⟨0, by omega⟩ 9.0
  assert! m.get2d ⟨0, by omega⟩ ⟨2, by omega⟩ == 7.0
  assert! m.get2d ⟨1, by omega⟩ ⟨0, by omega⟩ == 9.0
  assert! m.get2d ⟨0, by omega⟩ ⟨0, by omega⟩ == 0.0

-- ============================================================
-- BLAS operations tests (float64)
-- ============================================================

def testAdd : IO Unit := do
  let h := small_lt_usize 3 (by omega)
  let v1 := Array.fill [3] 2.0 .float64 h
  let v2 := Array.fill [3] 3.0 .float64 h
  let result := v1 + v2
  assert! result.get ⟨0, by omega⟩ == 5.0

def testSub : IO Unit := do
  let h := small_lt_usize 3 (by omega)
  let v1 := Array.fill [3] 5.0 .float64 h
  let v2 := Array.fill [3] 3.0 .float64 h
  let result := v1 - v2
  assert! result.get ⟨0, by omega⟩ == 2.0

def testScale : IO Unit := do
  let v := Array.fill [3] 4.0 .float64 (small_lt_usize 3 (by omega))
  let result := (2.0 : Float) * v
  assert! result.get ⟨0, by omega⟩ == 8.0

def testNeg : IO Unit := do
  let v := Array.fill [3] 3.0 .float64 (small_lt_usize 3 (by omega))
  let result := -v
  assert! result.get ⟨0, by omega⟩ == -3.0

def testDot : IO Unit := do
  let h := small_lt_usize 3 (by omega)
  let v1 := Array.fill [3] 2.0 .float64 h
  let v2 := Array.fill [3] 3.0 .float64 h
  assert! Ria.Array.dot v1 v2 == 18.0

-- ============================================================
-- Combinator tests
-- ============================================================

def testMap : IO Unit := do
  let v := Array.fill [3] 5.0 .float64 (small_lt_usize 3 (by omega))
  let result := Ria.Array.map (· * 2.0) v
  assert! result.get ⟨0, by omega⟩ == 10.0

def testReduce : IO Unit := do
  let v := Array.fill [4] 3.0 .float64 (small_lt_usize 4 (by omega))
  let result := Ria.Array.reduce (· + ·) 0.0 v
  assert! result == 12.0

def testZipWith : IO Unit := do
  let h := small_lt_usize 3 (by omega)
  let v1 := Array.fill [3] 2.0 .float64 h
  let v2 := Array.fill [3] 3.0 .float64 h
  let result := Ria.Array.zipWith (· * ·) v1 v2
  assert! result.get ⟨0, by omega⟩ == 6.0

def testTabulate : IO Unit := do
  let v := Ria.Array.tabulate [4] .float64 (fun i => i.val.toFloat)
  assert! v.get ⟨0, by omega⟩ == 0.0
  assert! v.get ⟨1, by omega⟩ == 1.0
  assert! v.get ⟨2, by omega⟩ == 2.0
  assert! v.get ⟨3, by omega⟩ == 3.0

-- ============================================================
-- IR eval tests
-- ============================================================

def testEvalLiteral : IO Unit := do
  let v := Array.fill [3] 7.0 .float64 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun _ => .literal v
  let result := eval (expr Ty.denote)
  assert! result.get ⟨0, by omega⟩ == 7.0

def testEvalMap : IO Unit := do
  let v := Array.fill [3] 4.0 .float64 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun _ =>
    .map (· + 1.0) (.literal v)
  let result := eval (expr Ty.denote)
  assert! result.get ⟨0, by omega⟩ == 5.0

def testEvalScalarOps : IO Unit := do
  let expr : ClosedExpr .float := fun _ =>
    .addf (.litF 3.0) (.mulf (.litF 2.0) (.litF 4.0))
  assert! eval (expr Ty.denote) == 11.0

-- ============================================================
-- Fusion correctness tests
-- ============================================================

def testFusionMapMap : IO Unit := do
  let v := Array.fill [3] 2.0 .float64 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun _ =>
    .map (· + 1.0) (.map (· * 2.0) (.literal v))
  let unfused := eval (expr Ty.denote)
  let fused := eval (fuse (expr Ty.denote))
  assert! allClose unfused fused

def testFusionReduceMap : IO Unit := do
  let v := Array.fill [3] 2.0 .float64 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr .float := fun _ =>
    .reduce (· + ·) 0.0 (.map (fun x => x * x) (.literal v))
  let unfused := eval (expr Ty.denote)
  let fused := eval (fuse (expr Ty.denote))
  assert! approxEq unfused fused
  assert! approxEq fused 12.0

-- ============================================================
-- Normalize tests
-- ============================================================

def testNormalizeMapMapLet : IO Unit := do
  let v := Array.fill [3] 2.0 .float64 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun V =>
    .lett (.map (· * 2.0) (.literal v)) (fun a =>
      .map (· + 1.0) (.var a))
  let unfused := run expr
  let normalized := run (normalize expr)
  assert! allClose unfused normalized
  assert! approxEq (normalized.get ⟨0, by omega⟩) 5.0

def testNormalizeTripleMapLets : IO Unit := do
  let v := Array.fill [3] 2.0 .float64 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun V =>
    .lett (.map (· - 1.0) (.literal v)) (fun a =>
      .lett (.map (· * 3.0) (.var a)) (fun b =>
        .map (· + 10.0) (.var b)))
  let unfused := run expr
  let normalized := run (normalize expr)
  assert! allClose unfused normalized
  assert! approxEq (normalized.get ⟨0, by omega⟩) 13.0

def testNormalizePassCount : IO Unit := do
  let v := Array.fill [3] 2.0 .float64 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun V =>
    .lett (.map (· - 1.0) (.literal v)) (fun a =>
      .lett (.map (· * 3.0) (.var a)) (fun b =>
        .map (· + 10.0) (.var b)))
  assert! passes expr == 3
  assert! passes (normalize expr) == 1

-- ============================================================
-- Pretty-printing tests
-- ============================================================

def testPrettyLiteral : IO Unit := do
  let v := Array.fill [3] 1.0 .float64 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun _ => .literal v
  assert! pretty expr == "arr"

def testPrettyMap : IO Unit := do
  let v := Array.fill [3] 1.0 .float64 (small_lt_usize 3 (by omega))
  let expr : ClosedExpr (.array [3]) := fun _ =>
    .map (· + 1.0) (.literal v)
  assert! pretty expr == "map(f, arr)"

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
    -- float32
    ("fill f32", testFillF32),
    ("add f32", testAddF32),
    ("dot f32", testDotF32),
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
    ("zipWith", testZipWith),
    ("tabulate", testTabulate),
    -- IR eval
    ("eval literal", testEvalLiteral),
    ("eval map", testEvalMap),
    ("eval scalar ops", testEvalScalarOps),
    -- Fusion
    ("fusion: map-map", testFusionMapMap),
    ("fusion: reduce-map", testFusionReduceMap),
    -- Normalize
    ("normalize: map-map let", testNormalizeMapMapLet),
    ("normalize: triple map lets", testNormalizeTripleMapLets),
    ("normalize: pass count", testNormalizePassCount),
    -- Pretty
    ("pretty: literal", testPrettyLiteral),
    ("pretty: map", testPrettyMap)
  ]

  IO.println s!"Running {tests.length} tests...\n"

  for (name, test) in tests do
    let ok ← runTest name test
    if ok then passed := passed + 1
    else failed := failed + 1

  IO.println s!"\n{passed} passed, {failed} failed, {tests.length} total"

  if failed > 0 then return 1
  return 0
