/**** I, Omri Goldberg (208938985) assert that the work I submitted is entirely my own.
I have not received any part from any other student in the class (or other source),
nor did I give parts of it for use to others. I have clearly marked in the comments
of my program any code taken from an external source. *****/


user:file_search_path(sat,'/home/omrigo13/Downloads/satsolver').
:- use_module(sat(satsolver)).


% Task 1: Encoding Addition
% Signature: add(Xs,Ys,Xs,Cnf)/4
% Purpose: The predicate expects Xs and Ys to be bound to bit vectors. 
% It creates the bit vector Zs (with a sufficient number of bits) and a Cnf 
% which is satisfied precisely when Xs,Ys,Zs are bound to binary numbers
% such that the sum of Xs and Ys is Zs.
add(Xs,Ys,Zs,Cnf):- add(Xs,Ys,-1,Zs,Cnf).
add([],[],Cin,[Cin],[]).
add([],[Y|Ys],Cin,[Z|Zs],Cnf):-
    fa(-1,Y,Cin,Cout,Z,Cnf1),
    add([],Ys,Cout,Zs,Cnf2),
    append(Cnf1,Cnf2,Cnf).
add([X|Xs],[],Cin,[Z|Zs],Cnf):-
    fa(X,-1,Cin,Cout,Z,Cnf1),
    add(Xs,[],Cout,Zs,Cnf2),
    append(Cnf1,Cnf2,Cnf).
add([X|Xs],[Y|Ys],Cin,[Z|Zs],Cnf):-
    fa(X,Y,Cin,Cout,Z,Cnf1),
    add(Xs,Ys,Cout,Zs,Cnf2),
    append(Cnf1,Cnf2,Cnf).


% Signature: fa(X,Y,Cin,Cout,Z,Cnf)/6
fa(X,Y,Cin,Cout,Z,[[Z,-X,-Y,-Cin],[-Z,-X,-Y,Cin],
                                     [-Z,-X,Y,-Cin],[-Z,X,-Y,-Cin],
                                     [Z,-X,Y,Cin],[Z,X,-Y,Cin],
                                     [Z,X,Y,-Cin],[-Z,X,Y,Cin],
                                     [-Cout,X,Y],[-Cout,X,-Y,Cin],
                                     [Cout,X,-Y,-Cin],[-Cout,-X,Y,Cin],
                                     [Cout,-X,Y,-Cin],[Cout,-X,-Y]]).


% Task 2: Encoding less equals and less than
% Signature: padding(Xs,Ys,PaddedXs,PaddedYs)/4
padding(Xs,Ys,PaddedXs,PaddedYs):-
   length(Xs,Lx), 
   length(Ys,Ly),
   Lx =:= Ly,
   PaddedXs = Xs,
   append(Ys,[-1],PaddedYs).
padding(Xs,Ys,PaddedXs,PaddedYs):-
   length(Xs,Lx), 
   length(Ys,Ly),
   Lx > Ly, 
   append(Ys,[-1],F),
   padding(Xs,F,PaddedXs,PaddedYs).
padding(Xs,Ys,PaddedXs,PaddedYs):-
   length(Xs,Lx), 
   length(Ys,Ly),
   Lx < Ly, 
   append(Xs,[-1],F),
   padding(F,Ys,PaddedXs,PaddedYs).
   
   
% Signature: leq(Xs,Ys,Cnf)/3
% Purpose: The predicate expect Xs and Ys to be bound to bit vectors. 
% It creates a Cnf which is satisfied precisely when Xs is less equal Ys.
leq(Xs,Ys,Cnf):-
   padding(Xs,Ys,Padx,Pady),
   add(Padx,_,Pady,Cnf).
   

% Signature: lt(Xs,Ys,Cnf)/3
% Purpose: The predicates expect Xs and Ys to be bound to bit vectors. 
% It creates a Cnf which is satisfied precisely when Xs is less than Ys.
lt(Xs,Ys,Cnf):-
   add(Xs,[1],Zs,Cnf1),
   leq(Zs,Ys,Cnf2),
   append(Cnf1,Cnf2,Cnf).   


% Task 3: Encoding Sum
% Signature: sum(ListofNumbers, Zs, Cnf)/3
% Purpose: The predicate expects List to be bound to a
% list of bit vectors. It creates the bit vector Zs and a Cnf which is satisfied when
% The vectors in List and Zs are bound to binary numbers such that the sum of the
% numbers in List is equal to Zs.
sum([],[-1],[]).
sum([Xs],Xs,[]).
sum([Xs,Ys|List],Zs,Cnf):- 
    add(Xs,Ys,Ws,Cnf1),
    sum([Ws|List],Zs,Cnf2),
    append(Cnf1,Cnf2,Cnf).
    

% Task 4: Encoding Multiplication
% Signature: times(Xs,Ys,Zs,Cnf)/4
% Purpose: The predicate expects Xs and Ys to be bound to bit vectors. 
% It creates the bit vector Zs and a Cnf which is satisfied when Xs,Ys,Zs are bound to
% binary numbers such that the multiplication of Xs and Ys is Zs.
times(Xs,Ys,Zs,Cnf):-
    getlst(Xs,Ys,List,Cnf1),
    sum(List,Zs,Cnf2),
    append(Cnf1,Cnf2,Cnf).


% Signature: getlst(Xs,Ys,List,Cnf)/4
getlst([],_,[],[]).
getlst([X|Xs],Ys,List,Cnf):-
    timessec(X,Ys,Zs,Cnf1),
    getlst(Xs,[-1|Ys],SList,Cnf2),
    append([Zs],SList,List),
    append(Cnf1,Cnf2,Cnf).
    
    
% Signature: timessec(X,Ys,Zs,Cnf)/4    
timessec(_,[],[],[]).
timessec(X,[Y|Ys],[Z|Zs],Cnf):-
    Cnf1 = [[-Z,X],[-Z,-X,Y],[Z,-X,-Y]],
    timessec(X,Ys,Zs,Cnf2),
    append(Cnf1,Cnf2,Cnf).


% Task 5: Encoding Power  
% Signature: power(N,Xs,Zs,Cnf)/4
% Purpose: The predicate expects Xs and Ys to be bound to bit vectors. 
% It creates the bit vector Zs and a Cnf which is satisfied when Xs,Zs are bound to binary
% numbers such that the Nth power of Xs is Zs.
power(0,_,[1],[]).
power(1,Xs,Xs,[]).
power(N,Xs,Zs,Cnf):-
    M is N - 1,
    power(M,Xs,Ws,Cnf1),
    times(Xs,Ws,Zs,Cnf2),
    append(Cnf1,Cnf2,Cnf).


% Task 6: Encoding Power Equations
% Signature: powerEquation(N,M,Zs,List,Cnf)/5
% Purpose: positive numbers N and M and a bit vector Zs generates a list 
% List = [As1; : : : ; AsM] and a Cnf which is satisfied exactly when ZsN = As1N + ... + AsMN.
powerEquation(N,M,Zs,List,Cnf):-
    length(List,M), 
    length(Zs,L),
    limsizelist(L,List),
    power(N,Zs,PowZs,Cnf1),
    poslst(List,Cnf2),
    sortlst(List,Cnf3),
    powlist(N,List,PList,Cnf4),
    sum(PList,PowZs,Cnf5),
    append(Cnf1,Cnf2,SOCnf),
    append(SOCnf,Cnf3,MOCnf),
    append(MOCnf,Cnf4,EOCnf),
    append(EOCnf,Cnf5,Cnf).
   

% Signature: limsizelist(L,List)/2   
limsizelist(_,[]).
limsizelist(L,[Xs|List]):-
    length(Xs,L),
    limsizelist(L,List).
    

% Signature: powlist(N,List,OList,Cnf)/4
powlist(_,[],[],[]). 
powlist(N,[Xs|List],OList,Cnf):-
    power(N,Xs,PXs,Cnf1),
    powlist(N,List,SList,Cnf2),
    append([PXs],SList,OList),
    append(Cnf1,Cnf2,Cnf),!.
    

% Signature: poslst(List,Cnf)/2   
poslst([Xs],Cnf):- leq([1],Xs,Cnf).
poslst([Xs|List],Cnf):-
    leq([1],Xs,Cnf1),
    poslst(List,Cnf2),
    append(Cnf1,Cnf2,Cnf).


% Signature: sortlst(List,Cnf)/2       
sortlst([_],[]).
sortlst([Xs,Ys|List],Cnf):-
    leq(Xs,Ys,Cnf1),
    sortlst([Ys|List],Cnf2),
    append(Cnf1,Cnf2,Cnf).
    
    
% Task 7: Euler's Conjecture 
solve(Instance, Solution) :-
    encode(Instance,Map,Cnf),
    sat(Cnf),
    decode(Map,Solution),
    verify(Instance,Solution).
    
	
encode(euler(N,NumBits),Map,Cnf):-
    findall(Bit_Vector,(length(Bit_Vector,NumBits),between(1,N,_)),Map),
    append([Zs],RMap,Map),
    length(RMap,M),
    powerEquation(N,M,Zs,RMap,Cnf).


decode([],[]).
decode([A|AList],[B|BList]):- 
    sumdecoder(A,B),
    decode(AList,BList).
    
	
sumdecoder(A,Decodenum):-
    powerdecoder(0,A,BList),
    sumdecoderlst(BList,Decodenum).
    
	
sumdecoderlst([],0).    
sumdecoderlst([B|List],Decodenum):-
    sumdecoderlst(List,Sum),
    Decodenum is B + Sum.


powerdecoder(_,[],[]).
powerdecoder(Place,[1|CList],[B|Decodenum]):-
    powerdecoderhelper(Place,2,B),
    N is Place + 1,
    powerdecoder(N,CList,Decodenum).
powerdecoder(Place,[-1|CList],[0|Decodenum]):-
    N is Place + 1,
    powerdecoder(N,CList,Decodenum).


powerdecoderhelper(0,_,1).    
powerdecoderhelper(N,Base,B):-
    M is N - 1,
    powerdecoderhelper(M,Base,P),
    B is P*Base.
    
	
verify(euler(N,_),Solution):-
    powerdecoderlst(N,Solution,PSolution),
    verify(PSolution).


powerdecoderlst(_,[],[]).
powerdecoderlst(N,[X|Solution],[PX|PSolution]):-
    powerdecoderhelper(N,X,PX),
    powerdecoderlst(N,Solution,PSolution).


verify([Sum,Sum]) :-
   writeln(verified:ok).
verify([Sum,X,Y|List]):-
   Z is X+Y,
   verify([Sum,Z|List]).