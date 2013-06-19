#!/usr/bin/env python

import gffutils
import sys
gff_fn, db_fn = sys.argv[1:]
print gff_fn, db_fn
gffutils.create_db(gff_fn, db_fn)
