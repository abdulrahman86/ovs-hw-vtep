bin_PROGRAMS += \
	vtep/vtep-ctl

MAN_ROOTS += \
	vtep/vtep-ctl.8.in

DISTCLEANFILES += \
	vtep/vtep-ctl.8

man_MANS += \
	vtep/vtep-ctl.8

vtep_vtep_ctl_SOURCES = vtep/vtep-ctl.c
vtep_vtep_ctl_LDADD = lib/libopenvswitch.a $(SSL_LIBS)

# VTEP schema and IDL
EXTRA_DIST += vtep/vtep.ovsschema
pkgdata_DATA += vtep/vtep.ovsschema

# VTEP E-R diagram
#
# There are two complications here.  First, if "python" or "dot" is not
# available, then we have to just use the existing diagram.  Second,
# different "dot" versions produce slightly different output for the
# same input, but we don't want to gratuitously change vtep.pic if
# someone tweaks the schema in some minor way that doesn't affect the
# table structure.  To avoid that we store a checksum of vtep.gv in
# vtep.pic and only regenerate vtep.pic if vtep.gv actually changes.
$(srcdir)/vtep/vtep.gv: ovsdb/ovsdb-dot.in vtep/vtep.ovsschema
if HAVE_PYTHON
	$(OVSDB_DOT) --no-arrows $(srcdir)/vtep/vtep.ovsschema > $@
else
	touch $@
endif
$(srcdir)/vtep/vtep.pic: $(srcdir)/vtep/vtep.gv ovsdb/dot2pic
if HAVE_DOT
	sum=`cksum < $(srcdir)/vtep/vtep.gv`;			\
	if grep "$$sum" $@ >/dev/null 2>&1; then			\
	  echo "vtep.gv unchanged, not regenerating vtep.pic";	\
	  touch $@;							\
	else								\
	  echo "regenerating vtep.pic";				\
	  (echo ".\\\" Generated from vtep.gv with cksum \"$$sum\"";	\
	   dot -T plain < $(srcdir)/vtep/vtep.gv			\
	    | $(srcdir)/ovsdb/dot2pic -f 2) > $@;				\
	fi
else
	touch $@
endif
EXTRA_DIST += vtep/vtep.gv vtep/vtep.pic

# VTEP schema documentation
EXTRA_DIST += vtep/vtep.xml
dist_man_MANS += vtep/vtep.5
$(srcdir)/vtep/vtep.5: \
	ovsdb/ovsdb-doc.in vtep/vtep.xml vtep/vtep.ovsschema \
	$(srcdir)/vtep/vtep.pic
	$(OVSDB_DOC) \
		--title="vtep" \
		--er-diagram=$(srcdir)/vtep/vtep.pic \
		$(srcdir)/vtep/vtep.ovsschema \
		$(srcdir)/vtep/vtep.xml > $@.tmp
	mv $@.tmp $@

# Version checking for vtep.ovsschema.
ALL_LOCAL += vtep/vtep.ovsschema.stamp
vtep/vtep.ovsschema.stamp: vtep/vtep.ovsschema
	@sum=`sed '/cksum/d' $? | cksum`; \
	expected=`sed -n 's/.*"cksum": "\(.*\)".*/\1/p' $?`; \
	if test "X$$sum" = "X$$expected"; then \
	  touch $@; \
	else \
	  ln=`sed -n '/"cksum":/=' $?`; \
	  echo >&2 "$?:$$ln: checksum \"$$sum\" does not match (you should probably update the version number and fix the checksum)"; \
	  exit 1; \
	fi
CLEANFILES += vtep/vtep.ovsschema.stamp
