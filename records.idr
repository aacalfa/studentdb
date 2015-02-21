record Student : Type where
  MkStudent : (name : String) ->
             (perm : Nat) -> Student

record Assignment : Type where
  MkAssignment : (assign1 : String) ->
                 (assign2 : String) -> Assignment

andre : Student
andre = MkStudent "Andre" 111

data Vect : Nat -> Type -> Type where
  Nil : Vect Z a
  (::) : a -> Vect k a -> Vect (S k) a 

data Pair a b = MkPair a b

record Class : Type where
  ClassInfo : (students : Vect n Student) ->
              (assignments : Vect m Assignment) ->
              (className : String) ->
              Class

vzipWith : (a -> b -> c) ->
              Vect n a -> Vect n b -> Vect n c
vzipWith f [] [] = ?vzipWith_rhs_1
vzipWith f (x :: xs) (y :: ys) = ?vzipWith_rhs_2              

--record Test : Type where
--  TestInfo :  (testpair : Vect n Main.Pair) ->
--              Test

--CS290C : Class
--CS290C = ClassInfo [] [] "CS290C"

--addStudent : Student -> Class -> Class
--addStudent p c = record { students = p :: students c } c

