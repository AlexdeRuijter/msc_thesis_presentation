### ABOUT THIS PROJECT

This is a minimal template I received from my supervisor, dr. M. Khosravi.
I adapted it slightly so it is compilable with the tools already in my workflow. That is;

-  `just`, a script runner
-  `bash`, the default shell on Linux
-  `zathura`, a lightweight PDF viewer with Vim-like keybinds
-  `texfot`, a small program to declutter the `LuaLaTex` compile-output
-  `pfdlatex`, the LaTeX compiler
-  `inotifywait`, keeping track of the changes to allow real-time compilation

If these components are installed, compilation should be easy.
Either call
-  `just watch` to monitor for changes, start zathura and recompile if necessary.
-  `just release` to compile the final version
