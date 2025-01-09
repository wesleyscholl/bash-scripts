# Script run garbage collection 
#!/bin/bash

# Run git gc prune - remove objects that are no longer pointed to by any object
git gc --prune=now

# Run git repack - remove loose objects and pack refs
git repack -a -d -f --depth=250 --window=250

# Run git prune - remove objects that are unreferenced and unpacked
git prune

# Run git reflog expire - expire reflog entries older than 30 days
git reflog expire --expire=30.days --all

# Run git fsck - check the validity of objects in the database
git fsck --full --unreachable --verbose

# Run git gc --aggressive - aggressively compresses the repository
git gc --aggressive

