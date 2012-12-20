SHELL = /bin/sh
PYTHON = python
DOT = dot

RUN_PYTHON = PYTHONPATH=`pwd`/../python $(PYTHON)

all: vtep-diagram.pdf vtep.5

vtep-diagram.pdf: vtep.ovsschema
	$(RUN_PYTHON) ../ovsdb/ovsdb-dot.in $? | $(DOT) -Tpdf > $@

vtep.pic: vtep.ovsschema
	$(RUN_PYTHON) ../ovsdb/ovsdb-dot.in --no-arrows $? | \
	    $(DOT) -Tplain | ../ovsdb/dot2pic > $@

vtep.5: vtep.ovsschema vtep.xml vtep.pic
	$(RUN_PYTHON) ../ovsdb/ovsdb-doc.in --er-diagram vtep.pic \
	    vtep.ovsschema vtep.xml > $@

clean:
	rm -f vtep-diagram.pdf vtep.pic vtep.5
