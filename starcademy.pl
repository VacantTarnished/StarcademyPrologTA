/* Starcademy, by Elias Pühringer and Ali Coban. */

:- dynamic i_am_at/1, at/2, inventory/1, is_open/1, unlocked/1, dead/1, has/2.
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(is_open(_)), retractall(unlocked(_)).

map :-
        write('---------------------------------------------------------------------'), nl,
        write('| [Ritual Room]    [Bedchambers]                                    |'), nl,
        write('|     |  |             |  |                                         |'), nl,
        write('| [NW Corridor] == [N  Corridor]                                    |'), nl,
        write('|     |  |             |  |                                         |'), nl,
        write('| [W  Corridor] == [ Mainhall  ] == [E  Corridor] == [Sith Chamber] |'), nl,
        write('|     |  |             |  |             |  |                        |'), nl,
        write('| [Prison Ward]    [   Exit    ]    [Instructors]                   |'), nl,
        write('---------------------------------------------------------------------'), nl.

i_am_at(bedchamber).

path(exit, n, mainhall).
path(mainhall, s, exit).
path(mainhall, e, eastcorridor).
path(mainhall, n, northcorridor).
path(mainhall, w, westcorridor).
path(eastcorridor, w, mainhall).
path(westcorridor, e, mainhall).
path(westcorridor, n, northwestcorridor).
path(northcorridor, s, mainhall).
path(northcorridor, n, bedchamber).
path(bedchamber, s, northcorridor).
path(northcorridor, w, northwestcorridor).
path(northwestcorridor, e, northcorridor).
path(northwestcorridor, s, westcorridor).
path(westcorridor, s, prison_ward).
path(prison_ward, n, westcorridor).
path(northwestcorridor, n, ritual_room).
path(ritual_room, s, northwestcorridor).
path(eastcorridor, e, sith_lord_chambers).
path(sith_lord_chambers, w, eastcorridor).
path(eastcorridor, s, instructorroom).
path(instructorroom, n, eastcorridor).

unlocked(ritual_room).
unlocked(northcorridor).
unlocked(northwestcorridor).
unlocked(westcorridor).
unlocked(mainhall).
unlocked(eastcorridor).
unlocked(prison_ward).
unlocked(exit).
unlocked(instructorroom).
unlocked(bedchamber).

npc(instructor).
npc(zash).
npc(warden).
npc(acolyte).

item(sith_artifact).
item(sith_holocron).
item(lightsaber_hilt).
item(kyber_crystal).
item(exit_key).
item(zash_letter).
item(chamber_key).

at(sith_holocron, bedchamber).
at(zash, sith_lord_chambers).
at(warden, prison_ward).
at(acolyte, bedchamber).
at(instructor, instructorroom).

has(zash_letter, zash).

inv :- 
        findall(Is_In, inventory(Is_In), Entire),
        write(Entire), nl.

talk(X) :-
        i_am_at(Place),
        at(X, Place),
        npc(X),
        dialogue(X), !.

talk(sith_holocron) :-
        inventory(sith_holocron),
        write('The sith holocron whispers dark secrets of the force to you.'), nl, !;
        i_am_at(Place),
        at(sith_holocron, Place),
        write('The sith holocron whispers dark secrets of the force to you.'), nl, !.

talk(X) :-
        i_am_at(Place),
        at(X, Place),
        item(X),
        write('Why are you trying to talk to an object?'), !.

talk(_) :-
        write('You don''t see them here.'), nl.

/* These rules describe how to pick up an object. */

take(X) :-
        inventory(X),
        write('You''re already holding it!'),
        !, nl.

take(X) :-
        i_am_at(Place),
        item(X),
        at(X, Place),
        retract(at(X, Place)),
        assert(inventory(X)),
        write('OK.'),
        !, nl.

take(X) :-
        i_am_at(Place),
        npc(X),
        at(X, Place),
        write('As you try grabbing '), write(X), nl, 
        write('they cut you down with their Lightsaber'), nl, die, nl, !.

take(_) :-
        write('I don''t see it here.'),
        nl.


/* These rules describe how to put down an object. */

/* These rules define the direction letters as calls to go/1. */

n :- go(n).

s :- go(s).

e :- go(e).

w :- go(w).


/* This rule tells how to move in a given direction. */
go(s) :-
        i_am_at(exit),
        inventory(exit_key),
        finish,
        !.

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, There),
        unlocked(There),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        !, look.

go(_) :-
        i_am_at(void),
        look,
        !.

go(_) :-
        write('You can''t go that way.').


/* This rule tells how to look about you. */

look :-
        i_am_at(Place),
        describe(Place),
        nl,
        notice_npcs_at(Place),
        notice_objects_at(Place),
        nl.


/* These rules set up a loop to mention all the objects
   in your vicinity. */

use(altar) :-
        i_am_at(ritual_room),
        inventory(lightsaber_hilt),
        inventory(kyber_crystal),
        write('You place your light saber hilt and kyber crystal on top of the altar.'), nl,
        write('As you start meditating you can feel the force guide you on how to finish constructing the lightsaber.'), nl,
        write('After a couple of minutes you are finished with a new weapon in hand'), 
        retract(inventory(lightsaber_hilt)), 
        retract(inventory(kyber_crystal)), 
        assert(inventory(lightsaber)), !.

use(altar) :-
        write('You can''t use that yet.'), nl, !.

use(_) :-
        write('You can''t use that').

kill(zash) :-
        write('Zash doesn''t even bat an eye as she cuts your head off in one swift swoop.'), nl, !, die.
kill(instructor) :-
        i_am_at(Place),
        at(instructor, Place),
        inventory(lightsaber),
        write('You close into your instructor as he slowly understands his fate.'), nl,
        write('He tries defending himself with his own Lightsaber but he is easily defeated by you.'), nl,
        write('You take his lightsaber for you.'), nl,
        retract(at(instructor, instructorroom)),
        assert(dead(instructor)),
        assert(inventory(instructors_lightsaber)), !.
kill(instructor) :-
        i_am_at(Place),
        at(instructor, Place),
        write('As you desperatly try to kill you instructor he strike you down with his lightsaber.'), nl,
        write('Should''nt have tried attacking him without a weapon'), nl, !, die.
kill(warden) :-
        i_am_at(Place),
        at(warden, Place),
        write('No matter what you try you can''t overpower the Warden. But he doesn''t kill you all he says is:'), nl,
        write('"Don''t even try it you never stand a chance against me"'), nl, !.
kill(acolyte) :-
        i_am_at(Place),
        at(acolyte, Place),
        inventory(lightsaber_hilt),
        write('Not even a weapon is needed to kill this weak acolyte, and since he already did his purpose you take the sith artifact back from him'), nl, 
        retract(at(acolyte, bedchamber)),
        assert(dead(acolyte)),
        assert(inventory(sith_artifact)), !.
kill(acolyte) :-
        i_am_at(Place),
        at(acolyte, Place),
        inventory(sith_artifact),
        write('You ponder wether to kill the acolyte or trade for the weapon hilt you can see on his person.'), nl,
        write('But after thinking about it for one more second you just kill him and take the hilt'), nl,
        retract(at(acolyte, bedchamber)),
        assert(dead(acolyte)),
        assert(inventory(lightsaber_hilt)), !.
kill(acolyte) :-
        i_am_at(Place),
        at(acolyte, Place),
        write('You kill the annyoing acolyte in the bedchamber and find a lightsaber hilt on his body that now is your own.'), nl,
        retract(at(acolyte, bedchamber)),
        assert(dead(acolyte)),
        assert(inventory(lightsaber_hilt)), !.

kill(_) :-
        write('You can''t do that.'), nl, !.

curse(X) :-
        inventory(sith_artifact),
        npc(X),
        write('NaN'),
        !.



read_l(sith_artifact) :- 
        write('There is ancient writing on this artifact that you can not decipher.'), nl, !.

read_l(sith_holocron) :-
        write('You open the holocron with the force and learn about the dark ways.'), nl,
        write('But you already studied this so why open it again, bring it back to the instructor.'), nl, !.

read_l(altar) :-
        write('The writing and depictions on this altar would implie that a lot of people died constructing it.'), nl, !.

read_l(zash_letter) :-
        inventory(zash_letter),
        write('To: Prison Ward'), nl,
        write('From: Lord Zash'), nl,
        write('Give the Sith Artifact you found on the last raiders to this apprentice here.'), nl, !.

read_l(_) :-
        write('You don''t see anything readable here'), nl.

notice_npcs_at(bedchamber) :-
        at(acolyte, bedchamber),
        write('You can see another acolyte here. Maybe you can talk to them.'), nl, nl, !.


notice_npcs_at(Place) :-
        at(X, Place),
        npc(X),
        write('You can see '), write(X), write(' here. Maybe you can talk to them.'), nl, nl, !.

notice_npcs_at(_).

notice_objects_at(bedchamber) :-
        at(X, bedchamber),
        item(X),
        write('There is a '), write(X), write(' on your bed'), nl, !.

notice_objects_at(Place) :-
        at(X, Place),
        item(X),
        write('There is a '), write(X), write(' here.'), nl,
        fail.

notice_objects_at(_).


/* This rule tells how to die. */

die :-
        write('You just got killed, good job, really not many ways to die in this game.'), nl,
        write('Now the game is finished enter halt. to end the game.'), nl,
        retractall(i_am_at(_)),
        retractall(inventory(_)),
        assert(i_am_at(void)).


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
        write('look.              -- to look around you again.'), nl,
        write('instructions.      -- to see this message again.'), nl,
        write('halt.              -- to end the game and quit.'), nl,
        write('inv.               -- to output your inventory'), nl,
        write('talk(NPC).         -- to talk to the npc in the room'), nl,
        write('use(X).            -- to use a construct'), nl,
        write('read_l(X).         -- to read out text on a item/object'), nl,
        write('map.               -- to show the map of the academy'), nl,
        write('kill.              -- to try and kill a npc'), nl,
        nl.


/* This rule prints out instructions and tells where you are. */

start :-
        instructions,
        write('You wake up in your bed for another day in this accursed Academy.'), nl,
        write('First things first you should bring the holocron with which you studied back to your instructor.'), nl.


/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description. */

dialogue(zash) :-
        inventory(lightsaber_hilt),
        has(zash_letter, zash),
        write('Ah there you are my new apprentice. First things first let me tell you what happens now'), nl,
        write('You will construct your own lightsaber and after that we will go to Dromundkas where we will start your training'), nl, nl,
        write('Here I will give you a letter with which you should be able to get a light saber hilt.'), nl,
        write('Oh? You already have one splendid! Then I can just give the bled kyber crystal'), nl,
        write('Here it is.'), nl, 
        retract(has(zash_letter, zash)),
        assert(inventory(kyber_crystal)), nl, !.

dialogue(zash) :-
        inventory(lightsaber_hilt),
        write('Good Job aquiring that lightsaber hilt, now all that remains is a bled kyber crystal for finish.'), nl,
        write('Here is one for now, later you will make you own.'), nl, nl,
        write('*Zash gave you a bled kyber crystal*'),
        assert(inventory(kyber_crystal)), nl, !.
dialogue(zash) :-
        inventory(lightsaber),
        write('Hello my apprentice everything is in place for us to go to Dromundkas.'), nl,
        write('Leave the academy and meet me at the spaceship.') , nl, 
        assert(inventory(exit_key)),!.

dialogue(zash) :-
        inventory(sith_artifact),
        write('I see you went to the warden with the letter.'), nl,
        write('Good Job but you still haven''t returned with the lightsaber hilt. Now go.'), nl, !.

dialogue(zash) :- 
        inventory(lightsaber_hilt),
        inventory(kyber_crystal),
        write('You have got everything you need to construct your lightsaber.'), nl,
        write('Go into the ritual room to create the lightsaber and come back once you have it'), nl,
        write('Now create your weapon and we can go to Dromundkas'), nl, !.

dialogue(zash) :-
        write('Ah there you are my new apprentice. First things first let me tell you what happens now'), nl,
        write('You will construct your own lightsaber and after that we will go to Dromundkas where we will start your training'), nl, nl,
        write('Here I will give you a letter with which you should be able to get a light saber hilt.'), nl,
        write('How? Easy: Find it out yourself this is your last test to truly become my apprentice.'), nl,
        write('Once you have the Saber Hilt come back and talk to me, I will then tell you what to do next.'), nl,
        retract(has(zash_letter, zash)),
        assert(inventory(zash_letter)), !.
dialogue(acolyte) :-
        inventory(sith_artifact),
        write('I see you have quite the interesting artifact on you.'),nl,
        write('I''d trade you it for a light saber hilt, heard you need one for lord Zash'), nl,
        write('You interested?'), nl,
        write('*you trade the artifact for the hilt*'), nl,
        write('Ight thanks for the trade, was definetly worth it for both of us.'), nl,
        retract(inventory(sith_artifact)),
        assert(inventory(lightsaber_hilt)), !.

dialogue(acolyte) :-
        inventory(lightsaber_hilt),
        write('It was a good trade now leave me alone to study.'), nl, !.

dialogue(acolyte) :-
        inventory(lightsaber),
        write('I see you have gotten your Lightsaber.'), 
        write('Very nice, now you can leave this horrible place and go to Dromundkas, the capital planet of the sith empire'), nl, !.

dialogue(acolyte) :-
        write('You don''t interest me leave me alone').

dialogue(warden) :-
        inventory(zash_letter),
        write('I see, Lord Zash sent you with an invitational letter.'), nl,
        write('Alright, I guess I''m gonna have to give you the artifact, here you go.'), nl,
        write('*The prison warden gives you a interesting looking artifact*'),
        retract(inventory(zash_letter)),
        assert(inventory(sith_artifact)), !.

dialogue(warden) :-
        write('Hey there acolyte, you aren''t allowed here leave immediatly!'), nl.

dialogue(instructor) :-
        inventory(sith_holocron),
        write('Ah good you have come! Your lessons with the holocron have finished, yes?'), nl,
        write('Then now you are ready to go to Lord Zash here take this key for her chambers.'), nl,
        write('*Your instructor takes the holocron back and gives you the key to Lord Zash''s chambers*'), nl,
        retract(inventory(sith_holocron)),
        assert(inventory(chamber_key)),
        assert(unlocked(sith_lord_chambers)), !.

dialogue(instructor) :-
        inventory(chamber_key),
        write('Now go I am no longer your instructr'), nl, !.

dialogue(instructor) :-
        write('Incompetent Swine, you forgot the sith holocron. I told you I tolerate no mistakes.'), nl,
        write('Now you shall die.'), nl,
        die.

describe(mainhall) :- 
        write('You are in the mainhall of the Sith Academy.'), nl,
        write('South is the Exit.'), nl,
        write('North is the Northcorridor.'), nl,
        write('East is the Eastcorridor.'), nl,
        write('West is the Westcorridor.'), nl.
describe(northcorridor) :- 
        write('You are in a long corridor in the north of the academy halls.'), nl,
        write('North of you are the Sith Bedchambers.'), nl,
        write('West of you is the Nothwesterncorridor.'), nl,
        write('South of you is the Mainhall.'), nl.
describe(northwestcorridor) :- 
        write('You are in the Northwestcorridor.'), nl,
        write('East is the Northerncorridor.'), nl,
        write('South is the Westcorridor.'), nl,
        write('North is the Ritual room'), nl.
describe(westcorridor) :- 
        write('You are in the Westcorridor.'), nl,
        write('East is the Mainhall.'), nl,
        write('North is the Northwestcorridor.'), nl,
        write('South is the Prison Ward.'), nl.
describe(eastcorridor) :- 
        write('You are in the Eastcorridor.'), nl,
        write('East is Lord Zash chambers'), nl,
        write('West is the Mainhall.'), nl,
        write('South is the intructors room'), nl.
describe(bedchamber) :- 
        write('You are in the Sith Bedchambers, here you and your peers sleep.'), nl,
        write('On the right you see your messy bed.'), nl,
        write('You can leave by going south.'), nl.
describe(instructorroom) :-
        write('You are in the Instructors room, here you can remember all the hard things'), nl, 
        write('your Instructors put you through.'), nl, 
        write('Go north to leave this room.'),nl.
describe(sith_lord_chambers) :- 
        write('You are in Lord Zash''s chambers.'), nl, 
        write('Here Lord Zash will tell you what to do in order to leave this accursed academy.'), nl.
describe(exit) :-
        inventory(exit_key),
        write('In front of you are huge open medal doors.'), nl,
        write('You are now ready to go to Dromundkas'), nl, !.
describe(exit) :-
        write('In front of you are huge metal doors sealed shut by the sith council'), nl, !.
describe(void) :-
        write('After death you just find yourself on a endless dark plane.'), nl.
describe(prison_ward) :-
        write('You are in the prison ward of the academy.'), nl,
        write('here all the plunderers and sometimes even jedi get locked in when they are found on korriban'), nl.
describe(ritual_room) :-
        write('You currently are in the Ritual Room.'), nl, 
        write('Here acolytes construct their lightsaber and go to Dromundkas with their masters afterwards.'), nl,
        write('You can see a huge sith altar at the end of the room.').