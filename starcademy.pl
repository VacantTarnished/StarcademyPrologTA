/* Star Academy, by Elias Pühringer and Ali Coban. */

:- dynamic i_am_at/1, at/2, inventory/1.
:- retractall(at(_, _)), retractall(i_am_at(_)).

i_am_at(bedchamber).

path(exit, n, mainhall).
path(mainhall, s, exit).
path(mainhall, e, eastcorridor).
path(mainhall, n, northcorridor).
path(mainhall, w, westcorridor).
path(eastcorridor, w, mainhall).
path(westcorridor, e, mainhall).
path(eastcorridor, n, northeastcorridor).
path(westcorridor, n, northwestcorridor).
path(northcorridor, s, mainhall).
path(northcorridor, n, bedchamber).
path(bedchamber, s, northcorridor).
path(northcorridor, e, northeastcorridor).
path(northeastcorridor, w, northcorridor).
path(northcorridor, w, northwestcorridor).
path(northwestcorridor, e, northcorridor).
path(northeastcorridor, s, eastcorridor).
path(northwestcorridor, s, westcorridor).
path(westcorridor, s, instructorroom).
path(instructorroom, n, westcorridor).
path(westcorridor, w, trainingroom).
path(trainingroom, e, westcorridor).

at(sith_holocron, bedchamber).

inv :- 
        findall(Is_In, inventory(Is_In), Entire),
        write(Entire), nl.

/* These rules describe how to pick up an object. */

take(X) :-
        inventory(X),
        write('You''re already holding it!'),
        !, nl.

take(X) :-
        i_am_at(Place),
        at(X, Place),
        retract(at(X, Place)),
        assert(inventory(X)),
        write('OK.'),
        !, nl.

take(_) :-
        write('I don''t see it here.'),
        nl.


/* These rules describe how to put down an object. */

drop(X) :-
        inventory(X),
        i_am_at(Place),
        retract(inventory(X)),
        assert(at(X, Place)),
        write('OK.'),
        !, nl.

drop(_) :-
        write('You aren''t carrying this currently!'),
        nl.


/* These rules define the direction letters as calls to go/1. */

n :- go(n).

s :- go(s).

e :- go(e).

w :- go(w).


/* This rule tells how to move in a given direction. */

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, There),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        !, look.

go(_) :-
        write('You can''t go that way.').


/* This rule tells how to look about you. */

look :-
        i_am_at(Place),
        describe(Place),
        nl,
        notice_objects_at(Place),
        nl.


/* These rules set up a loop to mention all the objects
   in your vicinity. */

notice_objects_at(bedchamber) :-
        at(X, bedchamber),
        write('There is a '), write(X), write(' on your bed'), nl, !.

notice_objects_at(Place) :-
        at(X, Place),
        write('There is a '), write(X), write(' here.'), nl,
        fail.

notice_objects_at(_).


/* This rule tells how to die. */

die :-
        finish.


/* Under UNIX, the "halt." command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final "halt." */

finish :-
        nl,
        write('The game is over. Please enter the "halt." command.'),
        nl.


/* This rule just writes out game instructions. */

instructions :-
        nl,
        write('Enter commands using standard Prolog syntax.'), nl,
        write('Available commands are:'), nl,
        write('start.             -- to start the game.'), nl,
        write('n.  s.  e.  w.     -- to go in that direction.'), nl,
        write('take(Object).      -- to pick up an object.'), nl,
        write('drop(Object).      -- to put down an object.'), nl,
        write('look.              -- to look around you again.'), nl,
        write('instructions.      -- to see this message again.'), nl,
        write('halt.              -- to end the game and quit.'), nl,
        write('inv.               -- to output your inventory'), nl,
        nl.


/* This rule prints out instructions and tells where you are. */

start :-
        instructions,
        write('You wake up in your bed for another day in this accursed Academy.'), nl,
        write('First things first you should bring the holocron with which you studied back to the library.'), nl.


/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description. */

describe(mainhall) :- 
        write('You are in the mainhall of the Sith Academy.'), nl,
        write('South is the Exit.'), nl,
        write('North is the Northcorridor.'), nl,
        write('East is the Eastcorridor.'), nl,
        write('West is the Westcorridor.'), nl.
describe(northcorridor) :- 
        write('You are in a long corridor in the north of the academy halls.'), nl,
        write('North of you are the Sith Bedchambers.'), nl,
        write('East of you is the Northeasterncorridor.'), nl,
        write('West of you is the Nothwesterncorridor.'), nl,
        write('South of you is the Mainhall.'), nl.
describe(northeastcorridor) :- 
        write('You are in the Northeastcorridor.'), nl,
        write('South is the Easterncorridor.'), nl,
        write('North is [Room].'), nl,
        write('East is [Room].'), nl,
        write('West is the Northerncorridor.'), nl.
describe(northwestcorridor) :- 
        write('You are in the Northwestcorridor.'), nl,
        write('East is the Northerncorridor.'), nl,
        write('South is the Westcorridor.'), nl,
        write('North is [Room].'), nl.
describe(westcorridor) :- 
        write('You are in the Westcorridor.'), nl,
        write('West is [Room].'), nl,
        write('East is the Mainhall.'), nl,
        write('North is the Northwestcorridor.'), nl,
        write('South is [Room].'), nl.
describe(eastcorridor) :- 
        write('You are in the Eastcorridor.'), nl,
        write('East is [Room.]'), nl,
        write('West is the Mainhall.'), nl,
        write('North is the Northeastcorridor.'), nl,
        write('South is [Room].'), nl.
describe(bedchamber) :- 
        write('You are in the Sith Bedchambers, here you and your peers sleep.'), nl,
        write('On the right you see your messy bed.'), nl,
        write('You can leave by going south.'), nl.
describe(instructorroom) :-
        write('You are in the Instructors room, here you can remember all the hard things'), nl, 
        write('your Instructors put you through.'), nl, 
        write('Go north to leave this room.'),nl.
describe(trainingroom) :-
        write('You are in the Training Quarters.'), nl,
        write('Here you have been through grueling Training with your Instructors'), nl.
describe(exit) :-
        write('In front of you are huge medal doors sealed shut by the sith council'), nl.