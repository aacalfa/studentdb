record Student : Type where
  MkStudent : (name : String) ->
             (perm : Nat) -> Student


data AssignmentFormat : Type where
  Discussion     : AssignmentFormat
  Implementation : AssignmentFormat
  Writeup        : AssignmentFormat

data SubjectArea : Type where
   SubTypes : SubjectArea
   ILP : SubjectArea
   LLP : SubjectArea
   DepTypes : SubjectArea
   LP : SubjectArea

data Assignment : AssignmentFormat -> SubjectArea -> Type where
   MkAssignment : (f : AssignmentFormat) -> (sa : SubjectArea) -> Assignment f sa

data Vect : Nat -> Type -> Type where
  Nil : Vect Z a
  (::) : a -> Vect k a -> Vect (S k) a 

record Class : Type where
  ClassInfo : (students : Vect n Student) ->
              (assignments : Vect m (Assignment f sa)) ->
              (className : String) ->
              Class


