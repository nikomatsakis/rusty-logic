-- Examples using the Rusty AST
import «Rusty».AST

-- Example: Vec<T> struct 
def vecStruct : StructDef := {
  name := "Vec",
  typeParams := ["T"],
  fields := [("data", RustyType.param "T"), ("len", RustyType.struct "usize" [])]
}

-- Example: Iterator trait with associated type Item
def iteratorTrait : TraitDef := {
  name := "Iterator",
  supertraits := [],
  assocType := "Item",
  assocBounds := []
}

-- Example: Vec<T>: Iterator where Item = T
def vecIterImpl : TraitImpl := {
  typeParams := ["T"],
  traitName := "Iterator", 
  implType := RustyType.struct "Vec" [RustyType.param "T"],
  whereClause := [],
  assocTypeValue := RustyType.param "T"
}

-- Example: where clause T: Clone
def cloneWhereClause : WhereClause := 
  WhereClause.traitImpl (RustyType.param "T") "Clone"

-- Example program
def exampleProgram : Program := {
  structs := [vecStruct],
  traits := [iteratorTrait],
  impls := [vecIterImpl],
  functions := []
}

-- Example: judgment P; Γ ⊢ Clone : Vec<T> (proving where clause assuming T: Clone in context)
def vecCloneJudgment : Judgment := 
  Judgment.traitImpl 
    exampleProgram      -- program
    [cloneWhereClause]  -- context: T: Clone
    "Clone"             -- trait
    (RustyType.struct "Vec" [RustyType.param "T"])  -- type

-- Example: more general where clause judgment P; Γ ⊢ W
def generalWhereClauseJudgment : Judgment :=
  Judgment.whereClause
    exampleProgram      -- program
    []                  -- empty context
    cloneWhereClause    -- proving T: Clone directly

#check vecStruct
#check iteratorTrait  
#check vecIterImpl
#check cloneWhereClause
#check vecCloneJudgment
#check generalWhereClauseJudgment
#check exampleProgram