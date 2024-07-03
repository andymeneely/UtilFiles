
cat static_file_lists/linux-git-ls-tree.txt | grep -E '\.c$|\.h$|Makefile$|\.s$|\.S$' | sort | uniq | wc -l
