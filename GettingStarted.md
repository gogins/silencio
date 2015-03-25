# The New Way #

On your Android device, install the Csound 6 app for Android from http://sourceforge.net/projects/csound/files/csound6/.

Mount your phone as a USB drive on your computer and copy the entire silencio directory onto your SD card so that you can run the scripts.

You will have to require the Silencio files with complete paths in your Lua code. More to come about this...

# The Old Way #

This should still work.

On your Android phone, install the Android Scripting Environment from http://code.google.com/p/android-scripting/ and also install Lua for Android.

Check out the Silencio Subversion repository onto your PC, or just download the few files currently in the repository.

Mount your phone as a USB drive on your computer and copy the entire silencio directory into the sl4a/scripts directory so that you can run the scripts.

Unmount the phone. Now, on the phone, open the Android Scripting Environment and load the SilencioTest.lua script and run it. After it finishes it should play a short generated score using the phone's built-in MIDI synthesizer.

To render with Csound, mount the phone on a computer on which Csound has been installed and is in the executable path. Open a console window and change to the silencio directory. Run "lua SilencioTest.lua".

At the current time, the built-in Csound orchestra in SilencioTest.lua uses Jack and will only run on Linux. But it does render the generated score.

You can easily edit the orchestra, however, to omit Jack and use different instruments that will run on Windows or OS X.