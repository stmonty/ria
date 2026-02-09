# Ria: A Transformable Array Computation System for Lean 4

## What Ria Is

Ria is a typed array computing library for Lean 4 — closer to JAX than NumPy.
It provides dense arrays backed by OpenBLAS, but its real identity is a
**transformable array computation system**: represent computations, transform
them (fusion, autodiff, vectorization), then lower to a backend for execution.

The key difference from JAX: JAX traces at runtime and trusts XLA to be
correct. Ria operates at compile time using Lean's metaprogramming, and the
transformations are **machine-checked** — fusion laws, AD rules, and shape
invariants are proved as Lean theorems.

Ria is not a neural network library. It is the foundation that a neural
network library ("Flax for Lean") would build on, the same way Flax builds
on JAX.

## Architecture

```
User code (typed arrays, combinators, autodiff)
    │
    ▼
Typed array IR (AiNF-inspired)
    │
    ├──► OpenBLAS (CPU)        ← Ria ships this
    │
    └──► XLA via PJRT (GPU/TPU) ← a second library adds this
```

Ria owns everything above the backend line. A separate library provides
neural network primitives (layers, optimizers, training loops) and the
XLA/PJRT backend for GPU/TPU dispatch.

### What lives in Ria

- Dense array types with type-level shapes
- BLAS-backed operations (CPU backend)
- Array combinators (`map`, `reduce`, `scan`, `zipWith`)
- Verified fusion via AiNF-inspired rewrites
- Rank polymorphism (automatic lifting across ranks)
- Index types (abstract index sets, type-safe iteration)
- **Automatic differentiation** (`grad`, `jvp`, `vjp`)

AD belongs here, not in the neural network library. It is a general array
transformation — physicists, engineers, and financial modelers all need
gradients. In Lean, we can prove the chain rule, product rule, and the
correctness of our AD implementation as theorems.

### What lives in the second library

- Neural network primitives (`Linear`, `Conv2d`, `Attention`, `LayerNorm`)
- Optimizers (Adam, SGD, schedules)
- Training loops, checkpointing, serialization
- XLA/PJRT backend (GPU/TPU dispatch via C FFI — same pattern as OpenBLAS)

---

## The Core Idea: Arrays as Positive Types

From "Compiling with Arrays" (Richter et al., ECOOP 2024):

**Functions are negative types** — you eliminate them by applying them.
**Arrays are positive types** — you eliminate them by pattern matching
(destructuring to access elements). They are duals in polarized type theory.

This duality justifies key program transformations:

- `let x = (for i => e1) in e2` can become `for i => let x = e1 in e2`
  — this is **loop fission**, and it is type-theoretically sound
- Maximally applying these conversions yields **AiNF** (Indexed Administrative
  Normal Form): every for-loop has a single assignment, all let-bindings are
  flat
- From AiNF, optimizations fall out naturally: dead code elimination, CSE,
  loop invariant code motion — no complex scheduling
- Then selectively **re-fuse** loops for cache locality and performance

Ria's long-term architecture uses this as its IR: represent array computations,
normalize to AiNF, optimize, lower to BLAS (or XLA).

---

## Roadmap

### Tier 1 — Foundation (Build System + FFI) [IN PROGRESS]

Get C compiling, OpenBLAS linking, and FFI round-tripping data.

`FloatArray` is the backing store — Lean's built-in unboxed double array.
`lean_float_array_cptr()` returns a `double*` directly usable by CBLAS.
Lean's GC handles the memory; `lean_is_exclusive` + `lean_copy_float_array`
gives us copy-on-write for in-place BLAS mutations.

**Deliverables:**
- `lakefile.lean` with `extern_lib` for C compilation + OpenBLAS linking
- `c/ria.h` — shared header with `ensure_exclusive` helper
- `c/ria_memory.c` — allocation via `lean_alloc_sarray`
- `c/ria_blas1.c` — Level 1 BLAS wrappers (`ddot`, `dscal`, `daxpy`)
- `Ria/FFI/` — Lean `@[extern]` declarations
- Smoke test: dot product of two vectors via OpenBLAS

**FFI conventions:**
- Read-only arrays: `@&` in Lean, `b_lean_obj_arg` in C (borrowed, no refcount)
- Mutated arrays: owned `lean_obj_arg` in C, must `ensure_exclusive` then return

### Tier 2 — Typed Arrays

Type-safe vectors and matrices with type-level dimensions.

```lean
structure Vector (n : Nat) where
  data : FloatArray
  h_size : data.size = n

structure Matrix (m : Nat) (n : Nat) (layout : Layout := .RowMajor) where
  data : FloatArray
  h_size : data.size = m * n
```

`Layout` (RowMajor/ColMajor) is a type parameter, not a runtime flag. This
means `Matrix 3 4 .RowMajor` and `Matrix 3 4 .ColMajor` are different types.

**The payoff: zero-copy transpose.** `transpose` flips RowMajor to ColMajor
(and vice versa) without moving any data — just reinterpret the layout and
swap dimensions. The `h_size` proof uses `Nat.mul_comm`. When this matrix
feeds into `dgemm`, the Layout type automatically produces the correct CBLAS
transpose flags.

Type-level `n` is erased at runtime. The proof `h_size : data.size = n`
bridges the type world and the runtime world. Constructors use a decidable
check: `if h : d.size = n then ⟨d, h⟩ else panic! "size mismatch"`.

Element access uses `Fin n` — a natural number with a proof it's less than
`n`. Index-out-of-bounds is a type error.

**Deliverables:**
- `Ria/Layout.lean` — `inductive Layout | RowMajor | ColMajor`
- `Ria/Vector.lean` — `Vector n` with `zeros`, `fill`, `get`, `set`, `dot`
- `Ria/Matrix.lean` — `Matrix m n layout` with `zeros`, `fill`, `get`, `mul`, `transpose`
- `c/ria_blas3.c` — `dgemm`, `dgemv` wrappers
- `Ria/Instances.lean` — `Add`, `HMul`, `ToString`, `Repr`
- Typeclass instances so `A * B` dispatches to BLAS

### Tier 3 — Array Combinators

Functional array operations designed for composability and later fusion.

```lean
def Vector.map (f : Float → Float) (v : Vector n) : Vector n
def Vector.reduce (f : Float → Float → Float) (init : Float) (v : Vector n) : Float
def Vector.scan (f : Float → Float → Float) (init : Float) (v : Vector n) : Vector n
def Vector.zipWith (f : Float → Float → Float) (v1 v2 : Vector n) : Vector n
```

These are **Second-Order Array Combinators** (SOACs), the same vocabulary
Futhark uses. They run eagerly for now (simple loops or BLAS where applicable)
but their signatures are chosen to enable fusion in Tier 4.

Each combinator has two implementations:
- A **pure Lean** reference implementation (for proofs)
- An `@[implemented_by]` **fast version** (C loop or BLAS call for execution)

This separation is crucial: proofs reason about the pure version, users get
the fast version at runtime.

### Tier 4 — Verified Fusion

Prove fusion laws as Lean theorems. Inspired by "Compiling with Arrays" and
its AiNF normal form.

```lean
-- Map fusion (functor law)
theorem map_map (f g : Float → Float) (v : Vector n) :
    (v.map g).map f = v.map (f ∘ g)

-- Reduce-map fusion
theorem reduce_map (f : Float → Float) (op : Float → Float → Float)
    (init : Float) (v : Vector n) :
    (v.map f).reduce op init = v.reduce (fun a b => op a (f b)) init

-- Map identity
theorem map_id (v : Vector n) : v.map id = v
```

These are not just documentation — they are machine-checked proofs that the
transformations preserve semantics. A Lean metaprogram (tactic, macro, or
elaborator) could apply these rewrites automatically at compile time, the
way JAX's XLA applies fusion at trace time — but with formal guarantees.

**AiNF as an IR:** The long-term vision is a Lean representation of AiNF
where array programs are normalized into maximally fissioned form, optimized,
and lowered to BLAS calls. The fusion theorems justify the re-fusion step.

### Tier 5 — Rank Polymorphism

Functions on scalars automatically lift to operate on arrays of any rank.

From the APL/Remora tradition: when a rank-r function is applied to rank-n
data (n > r), it automatically iterates over the rank-(n-r) "frame." The
iteration space is derived from the type, not written by the programmer.

```lean
inductive RArray : List Nat → Type where
  | scalar : Float → RArray []
  | array : (Fin n → RArray shape) → RArray (n :: shape)

-- Lift any scalar function to any rank
def lift (f : Float → Float) : RArray shape → RArray shape
```

`lift (· + 1)` works on scalars, vectors, matrices, and 3D arrays without
code change. NumPy achieves this with implicit broadcasting rules that
sometimes surprise. Ria makes it explicit in the type system.

### Tier 6 — Index Types

Dex-style abstract index sets for type-safe iteration.

Index sets are types: `Fin n`, `(Fin m, Fin n)`, or custom index types.
`tabulate : (Fin n → Float) → Vector n` constructs an array from an index
function. The shape is known at the type level.

```lean
def tabulate (f : Fin n → Float) : Vector n

-- Type-safe contraction (matrix multiply from first principles)
def contract (A : Matrix m k) (B : Matrix k n) : Matrix m n :=
  tabulate fun i =>
    tabulate fun j =>
      Vector.reduce (· + ·) 0.0 (tabulate fun l => A.get i l * B.get l j)
```

No index-out-of-bounds possible — it is a type error. The tabulate-based
matrix multiply should compile and match the BLAS result, verifying
correctness.

### Tier 7 — Automatic Differentiation

AD as a first-class array transformation, not a neural network feature.

**Forward-mode** (`jvp`): propagate tangent vectors alongside primal
computation. Implemented via dual numbers — straightforward.

**Reverse-mode** (`vjp`): propagate cotangent vectors backward. This is
backpropagation generalized. Harder — requires either a Wengert tape or
source-to-source transformation.

```lean
-- Forward-mode: Jacobian-vector product
def jvp (f : Vector n → Vector m) (x : Vector n) (v : Vector n) : Vector m × Vector m

-- Reverse-mode: vector-Jacobian product
def vjp (f : Vector n → Vector m) (x : Vector n) : Vector m × (Vector m → Vector n)

-- Gradient (reverse-mode of scalar-valued function)
def grad (f : Vector n → Float) (x : Vector n) : Vector n
```

The Lean advantage: prove the chain rule, product rule, and correctness of
the AD transformation as theorems. SciLean has symbolic differentiation;
Ria takes an engineering approach with verified forward/reverse mode.

Conal Elliott's "The Simple Essence of Automatic Differentiation" provides
the categorical framework. Dex shows how to combine AD with index types.

---

## Key Technical Patterns

### Copy-on-write for BLAS mutations (C)
```c
static inline void ensure_exclusive(lean_object **obj) {
    if (!lean_is_exclusive(*obj)) {
        *obj = lean_copy_float_array(*obj);
    }
}
```
Before any in-place BLAS operation (`dscal`, `daxpy`), check exclusive
ownership. If shared, copy first. This preserves functional purity while
enabling in-place mutation when safe.

### Size invariant bridging (Lean)
```lean
def zeros (n : Nat) : Vector n :=
  let d := Ria.FFI.allocZeros n.toUSize
  if h : d.size = n then ⟨d, h⟩ else panic! "size mismatch"
```
Runtime O(1) decidable check produces the proof that bridges FFI-allocated
memory with the type-level dimension.

### Dual implementation for proofs + performance (Lean)
```lean
-- Pure version (for proofs)
def Vector.mapPure (f : Float → Float) (v : Vector n) : Vector n := ...

-- Fast version (for execution)
@[implemented_by Vector.mapFast]
def Vector.map (f : Float → Float) (v : Vector n) : Vector n := mapPure f v
```
Fusion theorems are proved against `mapPure`. Users get `mapFast` at runtime.
The `@[implemented_by]` attribute is the bridge.

### Zero-copy transpose (Lean)
```lean
def transpose (M : Matrix m n .RowMajor) : Matrix n m .ColMajor :=
  ⟨M.data, by rw [Nat.mul_comm]; exact M.h_size⟩
```
No data movement. Layout flips at the type level. The proof that
`data.size = m * n → data.size = n * m` is just commutativity of
multiplication.

---

## Papers

### Core — Array Compilation & Fusion

**Compiling with Arrays** — Richter, Bohler, Weisenburger, Mezini (ECOOP 2024, Distinguished Paper)
Arrays as positive types in polarized type theory. Introduces Indexed
Administrative Normal Form (AiNF): maximally fissioned loops where the normal
form *is* the optimization. No scheduling decisions needed.
- https://arxiv.org/abs/2405.18242
- https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ECOOP.2024.33

**A Short Cut to Deforestation** — Gill, Launchbury, Peyton Jones (FPCA 1993)
The original shortcut fusion paper. The `foldr`/`build` rule for eliminating
intermediate data structures. Foundation for all fusion work that followed.
- https://dl.acm.org/doi/10.1145/165180.165214

**Stream Fusion: From Lists to Streams to Nothing at All** — Coutts, Leshchinskiy, Stewart (ICFP 2007)
Extends shortcut fusion to streams. Enables fusion of zips, folds, and
comprehensions. Directly relevant to our combinator design.
- https://www.cs.tufts.edu/~nr/cs257/archive/duncan-coutts/stream-fusion.pdf

**Functional Array Fusion**
Combinator-based loop fusion for array algorithms.
- https://dl.acm.org/doi/10.1145/507635.507661

**With-Loop Fusion in SAC**
SAC language's approach to array fusion with parallelization.
- https://link.springer.com/chapter/10.1007/11964681_11

**Defunctionalizing Push Arrays** — Svensson
Pull arrays (demand-driven) vs push arrays (producer-driven).
Understanding this duality is key to designing efficient combinators.
- https://svenssonjoel.github.io/writing/defuncEmb.pdf

### Core — Rank Polymorphism

**An Array-Oriented Language with Static Rank Polymorphism** — Slepak, Shivers, Manolios (ESOP 2014)
Remora: formal semantics for rank polymorphism with a sound static type
system. Functions lift automatically across ranks.
- https://link.springer.com/chapter/10.1007/978-3-642-54833-8_3
- https://www.khoury.northeastern.edu/home/jrslepak/typed-j.pdf

**The Semantics of Rank Polymorphism** — Slepak, Shivers, Manolios
Full dissertation treatment with progress and preservation proofs.
- https://arxiv.org/abs/1907.00509

### Core — Dependent Types for Arrays

**Getting to the Point** — Paszke et al. (ICFP 2021)
Dex: typed index sets, parallelism-preserving autodiff, pointful array
programming. The key insight: index sets are types.
- https://arxiv.org/abs/2104.05372

**Towards Size-Dependent Types for Array Programming** — Henriksen & Elsman (ARRAY 2021)
Futhark's approach: compile-time shape checking with ML-style size types.
Practical middle ground between no types and full dependent types.
- https://futhark-lang.org/publications/array21.pdf

**Shape-Constrained Array Programming with Size-Dependent Types** — Bailly, Henriksen, Elsman (FHPNC 2023)
Enforces array-size consistency at compile time with nontrivial shape
transformations.
- https://dl.acm.org/doi/10.1145/3609024.3609412

### Core — Automatic Differentiation

**The Simple Essence of Automatic Differentiation** — Conal Elliott
Category-theoretic AD. Provides the framework for implementing forward and
reverse mode AD in a typed functional language with formal guarantees.
- https://conal.net/papers/essence-of-ad/essence-of-ad-icfp.pdf

**Symbolic and Automatic Differentiation of Languages**
Type-theoretic foundations for automatic differentiation.
- https://dl.acm.org/doi/10.1145/3473583

### Background — Memory Management & Lean Internals

**Counting Immutable Beans** — Ullrich & de Moura (IFL 2019)
Lean 4's reference counting scheme with borrow annotations and reuse
optimization. Explains why `@&` borrowed parameters work and when
copy-on-write kicks in.
- https://arxiv.org/abs/1908.05647

**Perceus: Garbage Free Reference Counting with Reuse** — Reinking et al. (PLDI 2021)
Precise reference counting with in-place reuse. The theory behind
`lean_is_exclusive` and `lean_copy_float_array`.
- https://www.microsoft.com/en-us/research/uploads/prod/2020/11/perceus-tr-v1.pdf

**The Lean 4 Theorem Prover and Programming Language** — de Moura & Ullrich
System description covering Lean 4's design, reference counting, and
compilation.
- https://lean-lang.org/papers/lean4.pdf

---

## Projects & Code

### Array Languages

**Futhark** — Purely functional, data-parallel array language
Compiles to GPU (CUDA/OpenCL) and multi-threaded CPU. Size-dependent types.
SOACs (Second-Order Array Combinators): map, reduce, scan, filter.
Study for: combinator design, size types, fusion engine.
- https://www.futhark-lang.org/
- https://github.com/diku-dk/futhark

**Dex** — Dependent types + index sets for arrays (Google Research)
Treats index sets as types. Built-in autodiff. Early-stage but conceptually
rich. Study for: index type design, typed iteration, AD integration.
- https://github.com/google-research/dex-lang

**Accelerate** — Embedded GPU array language for Haskell
EDSL with sharing recovery and array fusion. Generates CUDA/OpenCL.
Study for: embedded language design, fusion in a host language.
- https://github.com/AccelerateHS/accelerate
- https://www.acceleratehs.org/

**JAX** — Composable transformations of NumPy programs (Google)
Trace-based system with `jit`, `grad`, `vmap`, `pmap`. XLA backend.
Ria's closest spiritual ancestor — we're building the same idea but with
dependent types and formal verification instead of runtime tracing.
- https://github.com/jax-ml/jax

### Lean 4 Ecosystem

**SciLean** — Scientific computing in Lean 4
N-dimensional arrays, symbolic automatic differentiation, OpenBLAS
integration. Math-first approach (vs our engineering-first).
Study for: Lake configuration, FFI patterns, AD in Lean.
- https://github.com/lecopivo/SciLean

**LeanBLAS** — BLAS bindings for Lean 4
Direct FFI bindings to CBLAS. Uses `Float64Array` (ByteArray wrapper).
Study for: C wrapper patterns, `ensure_exclusive` usage.
- https://github.com/lecopivo/LeanBLAS

**Alloy** — Write C shims from within Lean code
Embeds C in Lean files. Alternative to separate `.c` files.
- https://github.com/tydeu/lean4-alloy

### Backends

**OpenBLAS** — Optimized BLAS library
Our CPU backend for Level 1/2/3 BLAS operations.
- https://github.com/OpenMathLib/OpenBLAS
- https://www.openblas.net

**XLA / PJRT** — Google's compiler and runtime for accelerators
PJRT is the C API for dispatching to CPU/GPU/TPU. Same FFI pattern as
OpenBLAS. This is how the second library would add GPU support.
- https://github.com/openxla/xla
- https://opensource.google/projects/jax (PJRT docs)

**hmatrix** — Haskell BLAS/LAPACK bindings
Mature functional BLAS wrapper. ForeignPtr-backed matrices.
Study for: API design, FFI patterns in a functional language.
- https://github.com/haskell-numerics/hmatrix

### API Reference

**NumPy** — The standard array API
Study for: what operations users expect, API ergonomics.
- https://numpy.org/doc/stable/reference/

---

## Lean 4 Technical References

**FFI Reference** — How `@[extern]`, `@&`, type mapping, and memory work
- https://lean-lang.org/doc/reference/latest/Run-Time-Code/Foreign-Function-Interface/

**Reference Counting** — Copy-on-write, `lean_is_exclusive`, borrow semantics
- https://lean-lang.org/doc/reference/latest/Run-Time-Code/Reference-Counting/

**Lake Build System** — `extern_lib`, `compileO`, `compileStaticLib`, `moreLinkArgs`
- https://github.com/leanprover/lean4/blob/master/src/lake/README.md

**Typeclasses** — For operator overloading (`Add`, `HMul`, `ToString`, etc.)
- https://lean-lang.org/theorem_proving_in_lean4/Type-Classes/

**Dependent Type Theory** — Foundation for type-level dimensions
- https://lean-lang.org/theorem_proving_in_lean4/Dependent-Type-Theory/

**FFI Developer Notes** — Implementation details beyond the reference manual
- https://github.com/leanprover/lean4/blob/master/doc/dev/ffi.md
- https://gist.github.com/ydewit/7ab62be1bd0fea5bd53b48d23914dd6b

**FFI Tutorial (GLFW)** — Comprehensive worked example of C bindings
- https://github.com/DSLstandard/Lean4-FFI-Programming-Tutorial-GLFW

---

## Conceptual Background

### Arrays as Positive Types (from "Compiling with Arrays")
Functions are negative types (eliminated by application). Arrays are positive
types (eliminated by pattern matching). This duality, from polarized type
theory, justifies loop fission as a commuting conversion. AiNF is the normal
form you get from maximally applying these conversions: flat let-bindings,
one assignment per for-loop. Optimizations fall out; then selectively re-fuse.

### Pull vs Push Arrays
Pull arrays: indexed by a function `Fin n -> a` (consumer-driven, good for
random access). Push arrays: provide elements to a continuation (producer-driven,
good for fusion). Accelerate uses push arrays for GPU code generation. Futhark
uses SOACs which can be seen as a defunctionalized form. Understanding both
representations is key to designing Ria's combinator layer.

### Rank Polymorphism (APL tradition)
A function on rank-r data applied to rank-n data (n > r) automatically
iterates over the rank-(n-r) frame. The iteration space comes from the
type, not from the programmer. NumPy does this with broadcasting rules that
sometimes surprise. Remora/Ria make it explicit and type-safe.
- https://prl.khoury.northeastern.edu/blog/2017/05/04/rank-polymorphism/
- https://aplwiki.com/

### The @[implemented_by] Pattern
Define a function twice: once in pure Lean (for proofs), once via FFI (for
speed). `@[implemented_by fast_version]` tells the compiler to use the fast
version at runtime while the proof infrastructure uses the pure version.
This is how we get verified fusion + BLAS performance — the bridge between
the two worlds.

### The Two-Library Architecture
Ria is the array substrate — types, transforms, autodiff, CPU backend.
A second library ("Flax for Lean") adds neural network primitives and an
XLA/PJRT backend for GPU/TPU. PJRT is a C API — same FFI pattern as
OpenBLAS, just a different backend behind the same Ria types. Users who
don't need neural networks use Ria alone. Users who do add the second
library and get GPU acceleration.
