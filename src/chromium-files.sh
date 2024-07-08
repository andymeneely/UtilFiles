git ls-tree --name-only -r HEAD | grep -E '\.c$|\.cc$|\.cpp$|\.h$|Makefile$|\.s$|\.S$|\.ts$|\.js$' | sort | uniq

#
# | sort | uniq | wc -l
