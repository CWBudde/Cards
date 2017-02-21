# Cards

Cards is a simple Solitaire clone which was created in order to play one of my personal favorite solitaire game on any mobile device.

It was inspired by the Solitaire flash game which can be found at http://www.gamedesign.jp/flash/card/card.html

## Installation

The game does not need to get installed. You can simply [run this game in your browser](https://rawgit.com/CWBudde/Cards/master/Output/www/index.html). However, since this game comes with the full source code you can also compile it by yourself.
It's even possible to build Android and iOS versions from this code.

### Compilation with DWScript
The source code of this game is written in an Object Pascal dialect which can be compiled with [DWScript](https://www.delphitools.info/dwscript/). Since DWScript itself is not a full compiler, but a package of compiler tools around a very powerful scripting language more than this is necessary.
Initially the game was written with a proprietary IDE with a closed source compiler. However, recently an DWScript based open source compiler is available which allows to compile the source code with an equal quality. It is part of the [HOPE Object Pascal Environment](https://github.com/Walibeiro/Hope). While the entire suite is still in some sort of an alpha state (the IDE does not seem to be very stable), its command-line compiler (HCC.exe) looks promising. It also comes with a node.js command-line compiler, which might also work.

Now, in order to compile the source code you'll first need to download the command-line compiler. In addition to this you'll need the [HOPE APIs](https://github.com/Walibeiro/Hope-APIs).
  
Once everything is in place just call:

    HCC.exe Source\Cards.hpr

which should generate the file 'Cards.js' in the Output\www directory. All other files in that directory are static.

### Hybrid web-apps with Cordova
In order to transform this game into a hybrid web-app for your mobile device it's only necessary to run a few cordova calls.

First move to the 'Output' directory. Then add a platform with

    cordova platform add android

If cordova isn't installed already, please call

    npm i -g cordova

to use the Node.js package manager ("npm") to install cordova.

Once a platform has been added the app can already get built with

    cordova build

To run it on your device simply type

    cordova run --device

If you omit the '--device' it will run inside the emulator instead.

## License

The source code is released under the MIT license.
