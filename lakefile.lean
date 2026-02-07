import Lake
open System Lake DSL

def openBlasLinkArgs : Array String := Id.run do
  if Platform.isOSX then
    #[
      "-L/opt/homebrew/opt/openblas/lib",
      "-lopenblas"
    ]
  else if Platform.isWindows then
    #[
      "-LC:/msys64/mingw64/lib",
      "-lopenblas"
    ]
  else
    #[
      "-L/usr/lib/x86_64-linux-gnu",
      "-L/usr/local/lib",
      "-L/usr/lib",
      "-lopenblas"
    ]

def openBlasIncArgs : Array String := Id.run do
  if Platform.isOSX then
    #[
      "-I/opt/homebrew/opt/openblas/include"
    ]
  else
    #[
      "-I/usr/lib/x86_64-linux-gnu"
    ]

package ria where
  moreLinkArgs := openBlasLinkArgs

extern_lib riac pkg := do
  let cDir := pkg.dir / "c"
  let cFilesJob ← inputDir cDir (text := true) (filter := fun path => path.extension == some "c")
  cFilesJob.mapM fun cFiles => do
    let mut oFiles := #[]
    for cFile in cFiles do
      let stem := cFile.fileStem.getD (cFile.fileName.getD "csrc")
      let oFile := pkg.buildDir / "c" / s!"{stem}.o"
      let cArgs := Array.append #["-I", (← getLeanIncludeDir).toString] openBlasIncArgs
      compileO oFile cFile cArgs "cc"
      oFiles := oFiles.push oFile
    let libPath := pkg.staticLibDir / nameToStaticLib "riac"
    compileStaticLib libPath oFiles
    pure libPath

@[default_target]
lean_lib Ria where
  needs := #[riac]

lean_exe ria where
  root := `Main
