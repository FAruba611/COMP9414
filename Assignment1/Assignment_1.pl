% Program:  Assignment_1.pl
% Source:   Prolog
%
% Purpose:  This is the Assignment 1 program of COMP9414 where we write Prolog
%           procedures to perform some list and tree operations.
%
% Mission:  Assignment 1 : Prolog Programming
%
% Written:  Changfeng Li (zID:z5137858)



% QUESTION 1:
% Write a predicate weird_sum(List, Result) which takes a List of numbers,
% and computes the sum of the squares of the numbers in the list that are
% numbers that are greater than or equal to 5 , minus the sum of the absolute
% value of the numbers that are less than or equal to 2.

% case 1: rid the number larger than 5 and save to List_5
rid_five([],[]).
rid_five([Head | Tail], List_5) :-
    not(abs(Head) >= 5),
    !,
    rid_five(Tail, List_5).

rid_five([Head | Tail], [Head | List_5]) :-
    rid_five(Tail, List_5).

% case 2: rid the number smaller than 2 and save to List_2
rid_two([],[]).
rid_two([Head | Tail], List_2) :-
    not(abs(Head) =< 2),
    !,
    rid_two(Tail, List_2).

rid_two([Head | Tail], [Head | List_2]) :-
    rid_two(Tail, List_2).


% calculate sum 
% notice: this fcn has bug : it is even able for number not in this range to calculate
sumbig_5([],0).
sumbig_5([Head | Tail], Sum) :-
    sumbig_5(Tail, Tail_Sum),
    Sum is Head * Head + Tail_Sum.

sumsma_2([],0).
sumsma_2([Head | Tail], Sum) :-
    sumsma_2(Tail, Tail_Sum),
    Sum is Tail_Sum - abs(Head).

% main()
weird_sum(List,Final) :-
    rid_five(List,AfterList1),
    sumbig_5(AfterList1,Final1),
    rid_two(List,AfterList2),
    sumsma_2(AfterList2,Final2),
    Final is Final1 + Final2.



% QUESTION 2:
% We assume that each person will have the same family name as their father, 
% but that married women retain their original birth name. 
% Write a predicate same_name(Person1,Person2) that succeeds if it can be deduced from the facts 
% in the database that Person1 and Person2 will have the same family name. 
% (It is ok if your code returns true multiple times). For example: 
% ?- same_name(pat, brian).
% false.

% ?- same_name(jenny, jim).
% true 
% Note that your same_name predicate will be tested with different facts to those in family.pl 

% data
/*
parent(jim, brian).
parent(brian, jenny).
parent(jenny, wang).
parent(pat, brian).
parent(jim, jane).
parent(jim, mark).
parent(pat, jane).
parent(pat, mark).


parent(jane,annie).
parent(jane,anna).
parent(mike,annie).
parent(mike,anna).

parent(ryan, cowan).
parent(vicky,cowan).
parent(daniel,vayne).

parent(van, frank).
parent(van, taylor).
parent(van, mike).
parent(boogie, frank).
parent(boogie, taylor).
parent(boogie, mike).

parent(frank, ken).
parent(ken, leon).

female(pat).
female(jane).
female(jenny).
female(annie).
female(anna).
female(vicky).
female(cowan).
female(vayne).
female(boogie).
female(taylor).
male(jim).
male(brian).
male(mike).
male(wang).
male(mark).
male(ryan).
male(daniel).
male(sam).
male(van).
male(frank).
male(mike).
male(ken).
male(leon).
*/
/*
~:couple
-:brother and sister
 :not relational

1st gen :                        |  2nd gen :                       |  3rd gen :        | 4th gen :
 jim(male) ~ pat(female)         |   brian(male)                    |   jenny(female)      wang(male)
                                                                        


                                     -jane(female) ~ mike(male)     |   annie(female)
                                                                       -anna(female)
                                     
                                     -mark(male)

-ryan(male) ~ vicky(female)      |   cowan(female) ~ sam(male)

             
             -daniel(male)           vayne(female)


 van(male) ~ boogie(female)      |   frank(male)                    |   ken(male)       |   leon(male)

                                    -taylor(female)                    

                                    -mike(male)
*/
% judge couples:

judge_couple(Parent1,Parent2) :-
    parent(Parent1,Samechild),
    parent(Parent2,Samechild),
    Parent1 \== Parent2,
    (male(Parent1) ->female(Parent2);true),
    (male(Parent2) ->female(Parent1);true).

judge_is_not_single_dog(Parent1) :-
    parent(Parent1,Child),
    parent(Parent2,Child),
    Parent1 \== Parent2,
    (male(Parent1) ->female(Parent2);true), %is not male single dog
    (male(Parent2) ->female(Parent1);true).

% judge the origin
judge_origin(Origin, Person) :-
    parent(Origin, Person),
    male(Origin).
judge_origin(Origin, Person) :-
    parent(Parent, Person),
    judge_origin(Origin, Parent),
    male(Parent),
    male(Origin).

% judge grandparent
judge_grfather(Person1,Person2) :-
    parent(Person1,Son),
    parent(Son,Person2),
    male(Son),
    male(Person1),
    male(Person2).
    
% case1: this is a method to judge whether a line of descendant 
% have the same family line
judge_same_family_line(PersonA,PersonB) :-
    judge_origin(PersonX,PersonA),
    judge_origin(PersonX,PersonB).


% case2: judge the offspring (This rule restricted that daughter has the same name after marriage)
judge_offspring(Offspring, Person) :-
    parent(Person, Offspring),
    %( female(Offspring) -> judge_is_not_single_dog(Offspring); false).
    male(Person).%only dad

judge_offspring(Offspring, Person) :-
    parent(Person, Child),
    %( female(Child) -> judge_is_not_single_dog(Child); false ),
    judge_offspring(Offspring, Child),
    %( female(Offspring) -> judge_is_not_single_dog(Offspring); false).
    male(Child).

% case 3: judge the same sibling 
judge_sibling(Personfirst,Personsecond) :-
    parent(PersonX,Personfirst),
    parent(PersonX,Personsecond), 
    Personfirst \== Personsecond. 

% based on advanced rules
same_name(Person1,Person2):-
    judge_offspring(Person1, Person2);
    judge_offspring(Person2, Person1);
    judge_sibling(Person1, Person2);
    judge_same_family_line(Person1,Person2);
    Person1 = Person2.

% additional case:
% case_1: Person1 and Person2 are of same daddy
same_name(Person1, Person2) :-
    parent(Same_Parent, Person1),
    parent(Same_Parent, Person2),
    Person1 \== Person2.

% case_2: Person1 is the daddy of Person2
same_name(Person1,Person2) :-
    parent(Person1,Person2),
    male(Person1),
    Person1 \== Person2.

% case_3: Person1 is the son of Person2
same_name(Person1,Person2) :-
    parent(Person2,Person1),
    male(Person2),
    Person1 \== Person2.

% case_4: Person1 is the daddy
% and son is the father of Person2
same_name(Person1,Person2) :-
    judge_grfather(Person1,Person2),
    male(Person1),
    male(Person2),
    Person1 \== Person2.
    
% case_5: Person2 is the daddy 
% and child is the father of Person1
same_name(Person1,Person2) :-
    judge_grfather(Person2,Person1),
    male(Person1),
    male(Person2),
    Person1 \== Person2.




% QUESTION 3:
% Write a predicate log_table(NumberList, ResultList) :- Binds ResultList to the list of pairs
% consisting of a number and its log, for each number in NumberList.
/* Here is a maplist method 
log_table(NumberList, ResultList) :-
    maplist(lg, NumberList, Log_List),
    xp(NumberList, Log_List, ResultList).

% judge base case
xp([], [He | Ta], [He | Ta]).

xp(SmaeL, [], SmaeL).

% Recurion for xp process
xp([Headfirst|Tailfirst], [Headsec|Tailsec], [[Headfirst,Headsec]|Tail]) :-
    xp(Tailfirst,Tailsec,Tail).

lg(NumX,NumY) :-
    NumY is log(NumX).
*/
log_table([],[]).
log_table([Head | Tail1],[ Finallist | Tail2]):-
    answer(Head,Finallist),
    log_table(Tail1,Tail2).
    %ln_e(Head,Result).

lg_10(Input,Calculator) :-
  Calculator is log10(Input).

ln_e(Input,Calculator) :-
  Calculator is log(Input).

answer(0,[0,1]).
answer(BaseNum,Result):-
  ln_e(BaseNum,CalcuNum),
  Result = [BaseNum,CalcuNum].


% QUESTION 4:
% Any list of integers can (uniquely) be broken into "parity runs" where each run 
% is a (maximal) sequence of consecutive even or odd numbers within the original list.
% For example, the list [8,0,4,3,7,2,-1,9,9]
% can be paruns to [[8,0,4],[3,7],[2],[-1,9,9]] 
paruns([],[]).

% judge odd and even one by one and rid []
paruns([Head | Tail], Res) :-
   judge_even([Head | Tail], Left, Last_L_1),
   judge_odd(Last_L_1, Mid, Last_List_2),
   % here, 3 case as put the restlist the head as Mid /Left
   (Left = [] 
    -> Res = [Mid|Right]; % even case
    Mid=[] 
    -> Res = [Left|Right]; % odd case
    Res=[Left,Mid|Right]),

  
   paruns(Last_List_2, Right).
   % recursive to the end 

judge_even([],[],[]). % Split even set
judge_even([HE | TE], [], [HE | TE]) :-
   integer(HE),
   HE mod 2 =:= 1.
judge_even([HE | TE], [HE | LE], Final_List_E) :-
   integer(HE),
   HE mod 2 =:= 0,
   judge_even(TE, LE, Final_List_E).


judge_odd([],[],[]). % Split odd set
judge_odd([HO | TO], [], [HO| TO]) :- 
   integer(HO),
   HO mod 2 =:= 0.
   % 0 is HE mod 2.
judge_odd([HO | TO], [HO | IO], Final_List_O) :-
   integer(HO),
   HO mod 2 =:= 1,
   % 1 is HE mod 2,
   judge_odd(TO, IO, Final_List_O).



% QUESTION 5:
% In this question we consider binary tree which are represented as either empty
% or tree(L,Num,R),where L and R are the left and right subtrees and Num is a number.
% When there is a number in the middle of the tree at a node that is a leaf,
% retain the numerical value and let Value be anonymous variable with no 
% name, unifies to anything without any effect and be a singleton variable\

% eg:
%         3
%        / \
%       e   5
%          / \
%         8   7
%        / \ / \
%       e  e e  e
% is_heap(H) :- is_heap(H, _).
% imagine that depth is 0

% base case
judge_low(empty,_).
judge_low( Node_Value,Child_Value ) :-
  Node_Value =< Child_Value.

is_heap(empty).
is_heap( tree( empty,_,empty) ).

% imagine that there are 3 fcn: both two branch ,only left branch and only right branch

is_heap( tree( L_Tree, Father_Node, empty) ) :-
  is_heap(L_Tree),
  (L_Tree = tree(_,L_Node,_) 
  -> judge_low(Father_Node,L_Node);
  true).

is_heap( tree( empty, Father_Node, R_Tree) ) :-
  is_heap(R_Tree),
  (R_Tree = tree(_,R_Node,_) 
  -> judge_low(Father_Node,R_Node);
  true).
  
is_heap( tree( L_Tree, Father_Node, R_Tree ) ) :-
  is_heap(L_Tree),
  (L_Tree = tree(_,L_Node,_) 
  -> judge_low(Father_Node,L_Node);
  true),
  is_heap(R_Tree),
  (R_Tree = tree(_,R_Node,_)
  -> judge_low(Father_Node,R_Node);
  true).





