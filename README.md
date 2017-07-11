# snes9x-coop

This repo is all the bits to build a version of snes9x-rr that can synchronize the state of two Super Nintendo games over the internet (allowing "cooperative" playthroughs of single-player games). The bits that make this work are pure Lua and are contained entirely in the "coop" directory. These Lua scripts should be able to run exactly the same in any installation of snes9x-rr so long as LuaSockets and IUP DLLs are present in the directory with the snes9x exe. The rest of snes9x is packaged in for my own convenience.

## How I constructed this

- Checked out https://github.com/TASVideos/snes9x-rr ; this version of the repo contains the windows binaries required to build.
- Checked out https://github.com/snes9x-rr/snes9x ; this version of the repo has a current snes9x branch. Exported files on top of TASVideos archive.
- Minor fixes to get it to work in VS2015.

## How to build for testing

Open the solution file in win32/ and build and run.

## How to build for install

To make an install package:

- Build as release
- Copy win32/snes9x.exe into install dir
- Copy lua/lib/lua51.dll into install dir
- Copy coop/ directory into install dir.
