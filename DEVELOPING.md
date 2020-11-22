

### Developing on the project

when-changed is a simple python command ligne that auto recompile the project, when files changes

	when-changed *.zig zig build
		 when-changed leveldb.zig ../zig/zig test leveldb.zig  -l leveldb -l c -l c++



### Possible Improvments

- Use a full parser

seems a target port for zig in antlr4, is a good idea
https://github.com/antlr/antlr4/blob/master/doc/creating-a-language-target.md


