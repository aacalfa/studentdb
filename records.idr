record Student : Type where
  MkStudent : (name : String) ->
             (perm : Nat) -> Student

data Assignment : Type where
  Discussion     : Assignment
  Implementation : Assignment
  Writeup        : Assignment

data Vect : Nat -> Type -> Type where
  Nil : Vect Z a
  (::) : a -> Vect k a -> Vect (S k) a 

record Class : Type where
  ClassInfo : (students : Vect n Student) ->
              (assignments : Vect m Assignment) ->
              (className : String) ->
              Class


