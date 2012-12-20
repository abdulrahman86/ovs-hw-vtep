SHELL = /bin/sh
PYTHON = python
DOT = dot

RUN_PYTHON = PYTHONPATH=`pwd`/../python $(PYTHON)

vtep-diagram.pdf: vtep.ovsschema
	$(RUN_PYTHON) ../ovsdb/ovsdb-dot.in $? | $(DOT) -Tpdf > $@
