module studentrecords

record Student : Type where
  MkStudent : (name : String) ->
             (perm : Int) -> Student

data AssignmentFormat = Discussion | Implementation | Writeup

data SubjectArea = SubTypes | ILP | LLP | DepTypes | LP 

record Assignment : Type where
   MkAssignment : (sa : SubjectArea) -> (fmt : AssignmentFormat) -> Assignment

record StudentAssignment : Type where
  MkStudentAssignment : (student : Student) -> 
                      (assignment1 : Maybe (Assignment)) -> 
                      (assignment2 : Maybe (Assignment)) ->
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

ParseAssignment : String -> Maybe (Assignment)
ParseAssignment str = let tokens = split (== '-') str in
                         Just (MkAssignment !(ParseSubjectArea !(index' 0 tokens)) !(ParseAssignmentFormat !(index' 1 tokens)))

                 
ParseStudentAssignment : String -> Maybe StudentAssignment
ParseStudentAssignment str = let x = split (== '\t') str in
                            Just (MkStudentAssignment !(ParseStudent !(index' 0 x) !(index' 1 x)) (ParseAssignment !(index' 2 x)) (ParseAssignment !(index' 3 x)))

ParseRecords : List String -> List StudentAssignment
ParseRecords [] = []
ParseRecords (x :: xs) = let res = (ParseStudentAssignment x) in
                            case res of
                               Just rec => rec :: (ParseRecords xs)
                               Nothing => ParseRecords xs

---------------
--------------- Accessors

GetName : StudentAssignment -> String
GetName stdas = name (student stdas) 

GetNames : List StudentAssignment -> List String
GetNames recs = map (GetName) recs