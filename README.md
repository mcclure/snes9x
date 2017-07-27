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
- Copy coop/ directory into install dir
- Copy docs/ directory into install dir
- Copy README-USAGE.md into install dir as README.md

## How to build for Mac or Linux?

You're going to need to somehow build shared objects for the C portions of LuaSocket and IUPLua.

## How to use

See [README-USAGE.md](README-USAGE.md)

## Author / License

See [coop/README.md](coop/README.md) for the coop/ licensing and `docs/` for the Snes9x license.
