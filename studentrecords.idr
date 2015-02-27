module studentrecords

-- Student record, consists of a name and a perm number
record Student : Type where
  MkStudent : (name : String) ->
             (perm : Int) -> Student

-- Assignment format data. Can be either Discussion, Implementation
-- or Writeup
data AssignmentFormat = Discussion | Implementation | Writeup

-- SubjectArea data. Can be either SubTypes, ILP, LLP, DepTypes or LP
data SubjectArea = SubTypes | ILP | LLP | DepTypes | LP 

-- Assignment record, consists of a SubjectArea and and an AssignmentFormat
record Assignment : Type where
   MkAssignment : (sa : SubjectArea) -> (fmt : AssignmentFormat) -> Assignment

-- StudentAssignment record, consists of a Student record, and two Assignments.
-- Note: Assignments can denote Nothing.
record StudentAssignment : Type where
  MkStudentAssignment : (student : Student) -> 
                      (assignment1 : Maybe (Assignment)) -> 
                      (assignment2 : Maybe (Assignment)) ->
                      StudentAssignment

-----------------------------
--- String representation ---
-----------------------------

instance Show AssignmentFormat where
   show Discussion = "D"
   show Implementation = "I"
   show Writeup = "W"

instance Show SubjectArea where
   show ILP = "ilp"
   show LLP = "llp"
   show LP = "lp"
   show DepTypes = "depT"
   show SubTypes = "subT"


instance Show Assignment where
   show assgn = (show (sa assgn)) ++ "-" ++ (show (fmt assgn))

instance Show Student where
   show std = (name std) ++ "," ++ (show (perm std))

AssignmentToStr : Maybe Assignment -> String
AssignmentToStr massgn = case massgn of
                            Just sassgn => show sassgn
                            Nothing => ""

instance Show StudentAssignment where
   show sassgn = (show (student sassgn)) ++ "\t" ++ (AssignmentToStr (assignment1 sassgn)) ++ "\t" ++ (AssignmentToStr (assignment2 sassgn)) 

-----------------------------------------
--------------- Parsers -----------------
-----------------------------------------

-- Parses two strings, the first is the student name, and the second is the student perm number
-- Returns a Student or Nothing
ParseStudent : String -> String -> Maybe Student
ParseStudent name permStr = let perm = cast permStr in
                              case perm of
                                 0 => Nothing
                                 _ => Just (MkStudent name perm) 

-- Parses a string that denotes the AssignmentFormat data
-- Returns the corresponding the AssignmentFormat or Nothing
ParseAssignmentFormat : String -> Maybe AssignmentFormat
ParseAssignmentFormat str = case str of
                              "I" => Just Implementation
                              "W" => Just Writeup
                              "D" => Just Discussion
                              _ => Nothing

-- Parses a string that denotes the SubjectArea data
-- Returns the corresponding the SubjectArea or Nothing
ParseSubjectArea : String -> Maybe SubjectArea
ParseSubjectArea str =  case str of
                          "subT" => Just SubTypes
                          "depT" => Just DepTypes
                          "llp" => Just LLP
                          "ilp" => Just ILP
                          "lp" => Just LP
                          _ => Nothing

-- Parses a string that denotes the Assignment record
-- Returns the corresponding the Assignment or Nothing
ParseAssignment : String -> Maybe (Assignment)
ParseAssignment str = let tokens = split (== '-') str in
                         Just (MkAssignment !(ParseSubjectArea !(index' 0 tokens)) !(ParseAssignmentFormat !(index' 1 tokens)))


-- Parses a string that denotes the StudentAssignment record
-- Returns the corresponding the StudentAssignment or Nothing
ParseStudentAssignment : String -> Maybe StudentAssignment
ParseStudentAssignment str = let x = split (== '\t') str in
                            Just (MkStudentAssignment !(ParseStudent !(index' 0 x) !(index' 1 x)) (ParseAssignment !(index' 2 x)) (ParseAssignment (trim !(index' 3 x))))

-- Parses a list of strings that denotes all StudentAssignment records
-- Returns the corresponding list or Nothing
ParseRecords : List String -> List StudentAssignment
ParseRecords [] = []
ParseRecords (x :: xs) = let res = (ParseStudentAssignment x) in
                            case res of
                               Just rec => rec :: (ParseRecords xs)
                               Nothing => ParseRecords xs

-----------------------------------------
--------------- Accessors ---------------
-----------------------------------------

-- Returns the name of a StudentAssignment record
GetName : StudentAssignment -> String
GetName stdas = name (student stdas) 

-- Returns the names of a list of StudentAssignment records
GetNames : List StudentAssignment -> List String
GetNames recs = map (GetName) recs
