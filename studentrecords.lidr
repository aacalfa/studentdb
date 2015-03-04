> module studentrecords

-----------------------------
----- Data and Records ------
-----------------------------

Records will be used in this implementation to represent a student (basically defined by a name and
a perm number), the assignment, which consists of a subject area and the format, and lastly the
student assignment record, which combines the two records just described. 

Records are data types which assemble several values (the record's fields) together, as in a python
class. Field accesses and updates are automatically generated (Gets and Sets).

Student record, consists of a name and a perm number as fields.

> record Student : Type where
>   MkStudent : (name : String) ->
>              (perm : Int) -> Student
 
Assignment format data. Can be either Discussion, Implementation or Writeup.

> data AssignmentFormat = Discussion | Implementation | Writeup
 
SubjectArea data. Can be either SubTypes, ILP, LLP, DepTypes or LP

> data SubjectArea = SubTypes | ILP | LLP | DepTypes | LP 
 
Assignment record, consists of a SubjectArea and and an AssignmentFormat.

> record Assignment : Type where
>    MkAssignment : (sa : SubjectArea) -> (fmt : AssignmentFormat) -> Assignment
 
StudentAssignment record, consists of a Student record, and two Assignments.
Note: Assignments can denote Nothing.

> record StudentAssignment : Type where
>   MkStudentAssignment : (student : Student) -> 
>                       (assignment1 : Maybe (Assignment)) -> 
>                       (assignment2 : Maybe (Assignment)) ->
>                       StudentAssignment
 
-----------------------------
--- String representation ---
-----------------------------
 
For us to be able to print the data and records defined above, we must overload the show function
such that we can display the assignment and student information accordingly. We can do this by using the
"instance" operator on show.

> instance Show AssignmentFormat where
>    show Discussion = "D"
>    show Implementation = "I"
>    show Writeup = "W"
 
> instance Show SubjectArea where
>    show ILP = "ilp"
>    show LLP = "llp"
>    show LP = "lp"
>    show DepTypes = "depT"
>    show SubTypes = "subT"
 
 
> instance Show Assignment where
>    show assgn = (show (sa assgn)) ++ "-" ++ (show (fmt assgn))
 
> instance Show Student where
>    show std = (name std) ++ "," ++ (show (perm std))
 
> AssignmentToStr : Maybe Assignment -> String
> AssignmentToStr massgn = case massgn of
>                             Just sassgn => show sassgn
>                             Nothing => ""
 
> instance Show StudentAssignment where
>    show sassgn = (show (student sassgn)) ++ "\t" ++ (AssignmentToStr (assignment1 sassgn)) ++ "\t" ++ (AssignmentToStr (assignment2 sassgn)) 
 
-----------------------------------------
--------------- Parsers -----------------
-----------------------------------------

The functions below perform the parsing of the input file that contains the students information.
Each line of the file must have the following format:
[student name] \t [student perm number] \t [assignment 1] \t [assignment2]
The assignments have the undermentioned format:
[SubjectArea]-[AssignmentFormat]
 
ParseStudent: Parses two strings, the first is the student name, and the second is the student perm number
Returns a Student or Nothing

> ParseStudent : String -> String -> Maybe Student
> ParseStudent name permStr = let perm = cast permStr in
>                               case perm of
>                                  0 => Nothing
>                                  _ => Just (MkStudent name perm) 
 
ParseAssignmentFormat: Parses a string that denotes the AssignmentFormat data
Returns the corresponding the AssignmentFormat or Nothing

> ParseAssignmentFormat : String -> Maybe AssignmentFormat
> ParseAssignmentFormat str = case str of
>                               "I" => Just Implementation
>                               "W" => Just Writeup
>                               "D" => Just Discussion
>                               _ => Nothing
 
ParseSubjectArea: Parses a string that denotes the SubjectArea data
Returns the corresponding the SubjectArea or Nothing

> ParseSubjectArea : String -> Maybe SubjectArea
> ParseSubjectArea str =  case str of
>                           "subT" => Just SubTypes
>                           "depT" => Just DepTypes
>                           "llp" => Just LLP
>                           "ilp" => Just ILP
>                           "lp" => Just LP
>                           _ => Nothing
 
ParseAssignment: Parses a string that denotes the Assignment record
Returns the corresponding the Assignment or Nothing

> ParseAssignment : String -> Maybe (Assignment)
> ParseAssignment str = let tokens = split (== '-') str in
>                          Just (MkAssignment !(ParseSubjectArea !(index' 0 tokens)) !(ParseAssignmentFormat !(index' 1 tokens)))
 
 
ParseStudentAssignment: Parses a string that denotes the StudentAssignment record
Returns the corresponding the StudentAssignment or Nothing

"str" represents a line in the input file, described in line 83 of this source file.
Firstly, the string is split by the tab delimiter ("\t") so that we can get the different student information,
the result of the split is stored in x, which is a list of Strings.
The first index (0) holds the student name, the second represents his or her perm number, and
so on. The last index (3) demanded a call to function trim, that removes whitespaces. This is done
to make sure there are no line breaks ("\n") that would make the parsing incorrect.

> ParseStudentAssignment : String -> Maybe StudentAssignment
> ParseStudentAssignment str = let x = split (== '\t') str in
>                             Just (MkStudentAssignment !(ParseStudent !(index' 0 x) !(index' 1 x)) (ParseAssignment !(index' 2 x)) (ParseAssignment (trim !(index' 3 x))))
 
ParseRecords: Parses a list of strings that denotes all StudentAssignment records (namely, all lines of the input
file)
Returns the corresponding list or Nothing

> ParseRecords : List String -> List StudentAssignment
> ParseRecords [] = []
> ParseRecords (x :: xs) = let res = (ParseStudentAssignment x) in
>                             case res of
>                                Just rec => rec :: (ParseRecords xs)
>                                Nothing => ParseRecords xs
 
----------------------------------------
-------------- Accessors ---------------
----------------------------------------

Records allows us to easily access its fields values, just by writing the field name first (name,
for example) and then the variable name that corresponds to the field type.

GetName: Returns the name of a StudentAssignment record

> GetName : StudentAssignment -> String
> GetName stdas = name (student stdas) 
 
GetNames: Returns the names of a list of StudentAssignment records

> GetNames : List StudentAssignment -> List String
> GetNames recs = map (GetName) recs

