# snes9x-coop

This repo is all the bits to build a version of snes9x-rr that can synchronize the state of two Super Nintendo games over the internet (allowing "cooperative" playthroughs of single-player games).

The bits that make this work are pure Lua and are contained entirely in the "coop" directory. These Lua scripts should be able to run exactly the same in any installation of snes9x-rr so long as LuaSockets and IUP DLLs are present in the directory with the snes9x exe. In other words, you can copy the "coop" folder out of this repository into your own snes9x and throw away the rest.

## How I constructed this

- Checked out https://github.com/TASVideos/snes9x-rr ; this version of the repo contains the windows binaries required to build.
- Checked out https://github.com/snes9x-rr/snes9x ; this version of the repo has a current snes9x branch. Exported files on top of TASVideos archive.
- Minor fixes to get the result to build in VS2015.
- Copied Penlight 1.5.2 (from github) into coop/ folder
- Built luasocket-3.0-rc1 (from github) and copied socket.lua into coop/ and core.dll into coop/socket/
- Downloaded iup-3.22_Win32_dll14_lib from SourceForge and extracted iup.dll from it, downloaded iup-3.22-Lua51_Win32_dll14_lib from SourceForge and extracted iuplua51.dll from it, renamed iuplua51.dll to iuplua.dll and also opened it in a hex editor and changed its dependency on "lua5.1.dll" to "lua51.dll\0". Copied all this into coop/ 

## How to build for testing

Install the Cg toolkit from Nvidia's website.

Then open the solution file in win32/ and build and run.

## How to build for install

To make an install package:

- Build as release
- Copy win32/snes9x.exe into install dir
- Copy lua/lib/lua51.dll into install dir
- Copy coop/ directory into install dir.

## How to build for Mac or Linux?

You're going to need to somehow build shared objects for the C portion of Luasocket.

## How to use (to be moved into a README-USAGE.md at some point)

When you boot this up, you'll want to turn off the "frame display" by pressing period, and probably turn off bilinear filtering in the video menu.

After this, start the game and choose "New Lua Script Window" from File. Select "coop.lua" from the lua folder. It will pop up a dialog asking for the IRC nick to log in as and the IRC nick your partner will log in as.

At the moment, you can basically run the script once per boot. On the second attempt to run the coop script it crashes. I don't know why. I suspect it has something to do with loading the LuaSocket/IUP DLLs.

## Author / License

The "coop" bits (the Lua files in coop/) are written by <<andi.m.mcclure@gmail.com>>. The license is:

	Copyright (C) 2017 Andi McClure

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF
	ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
	TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
	PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT
	SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
	ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
	ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
	OR OTHER DEALINGS IN THE SOFTWARE.

The coop folder contains Penlight. Here is its license:

	Copyright (C) 2009-2016 Steve Donovan, David Manura.

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF
	ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
	TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
	PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT
	SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
	ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
	ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
	OR OTHER DEALINGS IN THE SOFTWARE.

The coop folder contains Luasocket. Here is its license:

	LuaSocket 3.0 license
	Copyright © 2004-2013 Diego Nehab

	Permission is hereby granted, free of charge, to any person obtaining a
	copy of this software and associated documentation files (the "Software"),
	to deal in the Software without restriction, including without limitation
	the rights to use, copy, modify, merge, publish, distribute, sublicense,
	and/or sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
	DEALINGS IN THE SOFTWARE.

The coop folder contains IUP. Here is its license:

	Copyright (c) 1994-2017 Tecgraf/PUC-Rio.

	Permission is hereby granted, free of charge, to any person obtaining a
	copy of this software and associated documentation files (the "Software"),
	to deal in the Software without restriction, including without limitation
	the rights to use, copy, modify, merge, publish, distribute, sublicense,
	and/or sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
	DEALINGS IN THE SOFTWARE.

SNES9X has its own license or cloud of licenses. It looks like it's MIT but there's a copy of the GPL in the docs/ folder?? Look in the docs/ folder.
