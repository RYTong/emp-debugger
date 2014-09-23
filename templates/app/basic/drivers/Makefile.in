# Makefile for the C drivers.
#
# Copyright (c) 2009-2010 Beijing RYTong Information Technologies, Ltd.
# All rights reserved.
#
# No part of this source code may be copied, used, or modified
# without the express written consent of RYTong.

DRIVERS =

all: $(DRIVERS)

.PHONY: $(DRIVERS) install clean distclean 

$(DRIVERS):
	$(MAKE) -C $@ all

install:

clean distclean:
	for d in $(DRIVERS) ; do \
	  echo "*** $$d" ; \
	  (cd $$d; $(MAKE) $@) ; \
	done

