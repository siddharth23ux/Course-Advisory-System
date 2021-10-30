:-dynamic(incompletePreRequisites/1), dynamic(courseDone/1), dynamic(courseChecked/2), dynamic(doneNow/1), dynamic(career/1).
:-['courses.txt'].
:-['careers.txt'].
:-['preRequisites.txt'].
start():-write('Enter the list of Careers/Courses that you are interested in (only check for registered careers; to check the list of registered careers type : career(X)): '), read(List), list_of_careers(List), outputSuggestedCourseOrJobs(UnSortedList, 1), mergeSort(Sorted, UnSortedList, 1), outputSuggestedCourseOrJobs(Sorted, 2), asker(Sorted), cleaner, !.

asker(Sorted):- write('Do you want to add your interest points to your result? (y/n) : '), nl, read(Input), ((Input=y)->(adder(Sorted), mergeSort(NewSorted, Sorted, 2), nl, write('New changed recommendations : '), nl, outputSuggestedCourseOrJobs(NewSorted, 2));((Input=n)->(write('ok, best of luck')); (write('Enter a valid choice!'), nl, asker(Sorted)))), !.

asker2(Course, Input):- nl, write('How much interested are you in this Course/Job (1-5) :'), write(Course), write(' ? : '), nl, write('1. hate it (-1 point)'), nl, write('2. don\'t either hate or love it (+0 point)'), nl, write('3. slightly interested in it (+1 point)'), nl, write('4. love it (+2 points)'), nl, write('5. it is a must do (+5 points)'), nl, read(X), ((integer(X), (X>=1, 5>=X))-> map(X, Input); nl, write('Enter a valid input : input out of range (>=1 and <=5) or not an integer!'), nl, asker2(Course, Input)), !.

map(1, -1).
map(2, 0).
map(3, 1).
map(4, 2).
map(5, 5).

adder([Current|Remaining]):- asker2(Current, Result), courseChecked(Current, Val), retractall(courseChecked(Current, _)), Next is (Val+Result), assert(courseChecked(Current, Next)), adder(Remaining), !.

adder([]).

list_of_careers([Career|Remaining]):- checkPreRequisites(Career), list_of_careers(Remaining).

list_of_careers([]).

checkPreRequisites(Input):- (not(courseChecked(Input, _))->(assert(courseChecked(Input, 1)), not(branchRecurser(Input)), suggestingCondition(Input));true).

suggestingCondition(Input):- (incompletePreRequisites(Input)-> retract(incompletePreRequisites(Input)); assert(suggestedCourseOrJob(Input))).

branchRecurser(Input):- preRequisite(Input, Course), isCourseDone(Input, Course), fail.

isCourseDone(Input, Course):- (not(courseChecked(Course, _))->(assert(doneNow(Course)), interiorCheck(Input, Course)); ((not(courseDone(Course))-> incompletePreRequisitesSetter(Input); true), true)), numberOfAccessSetter(Course).

incompletePreRequisitesSetter(Input):-(incompletePreRequisites(Input)-> true; assert(incompletePreRequisites(Input))).

numberOfAccessSetter(Course):- (doneNow(Course)->(retractall(doneNow(Course))); (increaseNumberOfAccesses(Course))).

interiorCheck(Input, Course):-(courseDone(Course)-> (assert(courseChecked(Course, 1)), true) ; (askIfCourseIsDone(Course) -> (assert(courseChecked(Course, 1)), assert(courseDone(Course))); (incompletePreRequisitesSetter(Input), checkPreRequisites(Course), (not(courseChecked(Course, _))->(assert(courseChecked(Course, 1))); true)))).


increaseNumberOfAccesses(Course):- courseChecked(Course, Val), NewVal is (Val+1), retractall(courseChecked(Course, _)), assert(courseChecked(Course, NewVal)), !.

askIfCourseIsDone(Course):-write("Have you done this course : "), write(Course), write('? (y/n)'), nl, read(Answer), (Answer = y -> true; (Answer = n -> false; write('Enter a valid choice!'), nl, askIfCourseIsDone(Course))).

outputSuggestedCourseOrJobs(UnSortedList, 1):- listCreator(UnSortedList), write('Unsorted list of suggested courses : '), write(UnSortedList), nl.

outputSuggestedCourseOrJobs(Sorted, 2):- nl, write('The list of Courses/ Jobs you should take in the decreasing order of priority (along with priority number) : '), nl, printer(Sorted, 1), !.

printer([Current| Remaining], Index):- write(Index), write('. '), write(Current), write(' ('), courseChecked(Current, Output), write(Output), write(')'), nl, Next is (Index+1), printer(Remaining, Next), !.
printer([], Index).


listCreator([Current|Remaining]):-retract(suggestedCourseOrJob(Current)), listCreator(Remaining).

listCreator([]).

cleaner:- retractall(courseDone(_)), retractall(suggestedCourseOrJob(_)), retractall(incompletePreRequisites(_)), retractall(courseChecked(_,_)).

merge(List, List, [], 1).
merge(List, [], List, 1).

merge([MinList1|RestMerged], [MinList1|RestList1], [MinList2|RestList2], 1) :-
  ((career(MinList1), career(MinList2));
   (career(MinList2), not(career(MinList1)));
  (courseChecked(MinList1, Val1), courseChecked(MinList2, Val2), Val1 >= Val2)),
  merge(RestMerged,RestList1,[MinList2|RestList2], 1), !.
merge([MinList2|RestMerged], [MinList1|RestList1], [MinList2|RestList2], 1) :-
  ((career(MinList1), not(career(MinList2)));
  (courseChecked(MinList1, Val1), courseChecked(MinList2, Val2), Val2 > Val1)),
  merge(RestMerged,[MinList1|RestList1],RestList2, 1), !.

merge(List, List, [], 2).
merge(List, [], List, 2).

merge([MinList1|RestMerged], [MinList1|RestList1], [MinList2|RestList2], 2) :-
  (courseChecked(MinList1, Val1), courseChecked(MinList2, Val2), Val1 >= Val2),
  merge(RestMerged,RestList1,[MinList2|RestList2], 2), !.
merge([MinList2|RestMerged], [MinList1|RestList1], [MinList2|RestList2], 2) :-
  (courseChecked(MinList1, Val1), courseChecked(MinList2, Val2), Val2 > Val1),
  merge(RestMerged,[MinList1|RestList1],RestList2, 2), !.


mergeSort([], [], X).
mergeSort([A], [A|[]], X).

mergeSort(Sorted, List, X) :-
  length(List, N),
  FirstLength is //(N, 2),
  SecondLength is N - FirstLength,
  length(FirstUnsorted, FirstLength),
  length(SecondUnsorted, SecondLength),
  append(FirstUnsorted, SecondUnsorted, List),
  mergeSort(FirstSorted, FirstUnsorted, X),
  mergeSort(SecondSorted, SecondUnsorted, X),
  merge(Sorted, FirstSorted, SecondSorted, X).

/*
career(research-analyst).
career(data-scientist).
career(software-engineer).
course(ai).
course(dsa).
course(java).
course(communication_skills).
course(random_course).
preRequisite(ai, dsa).
preRequisite(dsa, java).
preRequisite(ai, java).
preRequisite(research-analyst, ai).
preRequisite(research-analyst, communication_skills).
preRequisite(software-engineer, java).
*/



/*courseDone().
suggestedCourseOrJob().*/
%Backtracking with if else(done)
%do data entries
%make for multiple uses (done(?)) : just finish all asserts.
%check for maximum number of entries
%create pdf
%add more things :
%1. maximum courses satisfied with given course
%2. minimum courses to satisfy maximum
%3. marks for further sorting

