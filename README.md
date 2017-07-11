# snes9x-coop

This repo is all the bits to build a version of snes9x-rr that can synchronize the state of two Super Nintendo games over the internet (allowing "cooperative" playthroughs of single-player games). The bits that make this work are pure Lua and are contained entirely in the "coop" directory. These Lua scripts should be able to run exactly the same in any installation of snes9x-rr so long as LuaSockets and IUP DLLs are present in the directory with the snes9x exe. The rest of snes9x is packaged in for my own convenience only.

## How I constructed this

- Checked out https://github.com/TASVideos/snes9x-rr ; this version of the repo contains the windows binaries required to build.
- Checked out https://github.com/snes9x-rr/snes9x ; this version of the repo has a current snes9x branch. Exported files on top of TASVideos archive.
- Minor fixes to get the result to build in VS2015.
- Copied Penlight 1.5.2 (from github) into coop/ folder
- Built luasocket-3.0-rc1 (from github) and copied socket.lua into coop/ and core.dll into coop/socket/

## How to build for testing

Open the solution file in win32/ and build and run.

## How to build for install

To make an install package:

- Build as release
- Copy win32/snes9x.exe into install dir
- Copy lua/lib/lua51.dll into install dir
- Copy coop/ directory into install dir.

## How to build for Mac or Linux?

You're going to need to somehow build shared objects for the C portion of Luasocket.

## Author / License

The "coop" bits (the Lua files in coop/) are written by <<andi.m.mcclure@gmail.com>>. I will add a license for them soon.

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

SNES9X has its own license or cloud of licenses. It looks like it's MIT but there's a copy of the GPL in the docs/ folder?? Look in the docs/ folder.
