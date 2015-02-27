record Student : Type where
  MkStudent : (name : String) ->
             (perm : Int) -> Student

data AssignmentFormat = Discussion | Implementation | Writeup

data SubjectArea = SubTypes | ILP | LLP | DepTypes | LP 

data Assignment : SubjectArea -> AssignmentFormat -> Type where
   MkAssignment : (sa : SubjectArea) -> (f : AssignmentFormat) -> Assignment sa f

record StudentAssignment : Type where
  MkStudentAssignment : (std : Student) -> 
                      (assignment1 : Maybe (Assignment sa1 f1)) -> 
                      (assignment2 : Maybe (Assignment sa2 f2)) ->
                      StudentAssignment


---------------
--------------- Parsers

ParseStudent : String -> String -> Maybe Student
ParseStudent name permStr = let perm = cast permStr in
                              case perm of
                                 0 => Nothing
                                 _ => Just (MkStudent name perm) 

ParseAssignmentFormat : String -> Maybe AssignmentFormat
ParseAssignmentFormat str = case str of
                              "I" => Just Implementation
                              "W" => Just Writeup
                              "D" => Just Discussion
                              _ => Nothing

ParseSubjectArea : String -> Maybe SubjectArea
ParseSubjectArea str =  case str of
                          "subT" => Just SubTypes
                          "depT" => Just DepTypes
                          "llp" => Just LLP
                          "ilp" => Just ILP
                          "lp" => Just LP
                          _ => Nothing

ParseAssignment : String -> Maybe (Assignment sa f)
ParseAssignment str = let tokens = split (== '-') str in
                         let subj = !(ParseSubjectArea (index 0 tokens)) in
                            let fmt = !(ParseAssignmentFormat (index 1 tokens)) in
                               Just (MkAssignment subj fmt) 

                 
{-
                 Just (MkAssignment !(ParseSubjectArea (index 0 x)) !(ParseAssignmentFormat (index 1 x)))


ParseStudentAssignment : String -> Maybe StudentAssignment
ParseStudentAssignment str = let x = split (== '\t') str in
                            StudentAssignment !(ParseStudent (index 0 x) (index 1 x)) (ParseAssignent (index 2 x)) (ParseAssignment (index 3 x))
-}