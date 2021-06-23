# pomodoro-osx

This project is a minimalistic Pomodoro timer for OS X written in Swift started by @bengsfort, and 
substantially enhanced by myself.

![done](https://github.com/clayton-grey/pomodoro-osx/blob/master/Screenshots/Screenshot.png?raw=true)

The preferences let you specify the number of pomodoros before a long break. Time length for pomodoros, short breaks, and long breaks. You can also start the timer at any given stage in the process.

You have the option to show the timer in the status bar, or a just an indicator of which type of period you are in. There are options for notification sound, but those are controlled by Notification Center in more 
recent OSX versions. (I've left it for legacy reasons for those running older OS's.)

It will display alerts whenever your sessions are up so you can go take a break or get back to work.

## @todo

- Add detection for OS versions with Notification Center and replace the sound-on-complete option with a link to NC.
