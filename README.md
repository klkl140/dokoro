# dokoro
a roboter for playing cards


##idea:
This device should replace a normal player.
It will be possible to play doko without having 4 people at the same table.
The device could act like a normal player, playing with its own intelligence or as an interface for an external player, for example sitting in timbuktu.
In addition it can be used for many different card games. Only a software problem.....

![dokoro openscad](images/all.png)

##how it should work:
A human player is distributing the cards. The **dokoro** gets its cards placed in the cardholder.
It starts scanning its cards. For this purpose it has minimalistic hardware. One motor, one servo and a camera. The cards a placed one by one in front of the camera and an image-recognition is used. 

After all the cards are recognized the play could start. A camera watches the playfield. This second view might be part of the first camera view using a mirror.
For the intelligence the project [FreeDoko](http://free-doko.sourceforge.net/de/FreeDoko.html) is planed to be used.

##other ideas:
A monitor could be used to show informations, a speaker for giving _valuable comments_. When the dokoro is used as an interface, these parts could be used to get a real connection to the remote player. 

##current status:
The hardware seems to work. Cards could be moved by the driven rubber bands. The servo is mechanically able to move the cards and the whole flow of scanning the cards seem possible.  
FreeDoko could be compiled and the place of the missing interface is clear.  
Next step is connecting the raspbi to drive motor and servo.
Im searching for help in every project part. Help is given when someone tries to build of his own example for development.  
__There is no working example available.__  

##challenges:
The reliability of the mechanic is not easy. All moving parts are constructed with ball bearings. The separation of cards might be difficult, especially when dirty cards will be allowed.  
Getting the interface to the Freedoko source might be easy. There is a network-player option which matches perfectly. The server has to the changed in the way that cards are not in the program but on the table.  
The use as an interface for external players will be a big place for software development.   

Enjoy it.... Klaus 