namespace Ria

inductive Layout where
  | RowMajor
  | ColMajor
  deriving DecidableEq, Repr, Inhabited

def Layout.toUInt8 : Layout → UInt8
  | .RowMajor => 0
  | .ColMajor => 1

end Ria
