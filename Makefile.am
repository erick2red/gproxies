ACLOCAL_AMFLAGS = -I m4 ${ACLOCAL_FLAGS}

SUBDIRS = po

# desktop file
# (we can't use INTLTOOL_DESKTOP_RULE here due to lp#605826)
%.desktop: %.desktop.in
	$(MKDIR_P) $(dir $@); LC_ALL=C $(INTLTOOL_MERGE) -d -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< $@
applicationsdir = $(datadir)/applications
applications_DATA = data/org.gnome.gproxies.desktop
dist_noinst_DATA = data/org.gnome.gproxies.desktop.in

# DBus service file
servicedir = $(datadir)/dbus-1/services
service_DATA = data/org.gnome.gproxies.service
dist_noinst_DATA += data/org.gnome.gproxies.service.in

data/org.gnome.gproxies.service: data/org.gnome.gproxies.service.in Makefile
	$(AM_V_GEN) sed -e "s|\@bindir\@|$(bindir)|" $< > $@

# appdata file
appdatadir = $(datadir)/appdata
appdata_DATA = data/appdata/org.gnome.gproxies.appdata.xml

# gsettings
gsettings_SCHEMAS = data/org.gnome.gproxies.gschema.xml
@INTLTOOL_XML_RULE@
@GSETTINGS_RULES@

AM_CPPFLAGS = \
	-DGETTEXT_PACKAGE=\""$(GETTEXT_PACKAGE)"\" \
	-DGNOMELOCALEDIR=\""$(localedir)"\" \
	-DDATADIR=\""$(datadir)"\"

AM_VALAFLAGS = \
	--target-glib=2.38 \
	--pkg gtk+-3.0 \
	--gresources  $(top_srcdir)/data/gproxies.gresource.xml

bin_PROGRAMS = gproxies

BUILT_SOURCES = \
	src/resources.c

resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies --sourcedir=$(top_srcdir)/data $(top_srcdir)/data/gproxies.gresource.xml)
src/resources.c: $(top_srcdir)/data/gproxies.gresource.xml $(resource_files)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=$(top_srcdir)/data --generate-source $<

VALA_SOURCES = \
	src/application.vala \
	src/window.vala \
	src/utils.vala \
	src/main.vala

gproxies_SOURCES = \
	$(BUILT_SOURCES) \
	$(VALA_SOURCES) \
	src/config.vapi

AM_CFLAGS = \
	$(GPROXIES_CFLAGS) \
	-Wall \
	-Wno-unused-but-set-variable \
	-Wno-unused-variable

gproxies_LDFLAGS = -export-dynamic
gproxies_LDADD = \
	$(GPROXIES_LIBS) \
	-lm

EXTRA_DIST = \
	$(resource_files) \
	data/appdata/org.gnome.gproxies.appdata.xml \
	data/gproxies.gresource.xml \
	data/org.gnome.gproxies.gschema.xml.in.in

CLEANFILES = \
	$(applications_DATA) \
	$(service_DATA)

DISTCLEANFILES = \
	$(gsettings_SCHEMAS)

MAINTAINERCLEANFILES = \
	ABOUT-NLS \
	aclocal.m4 \
	config.guess \
	config.h.in \
	config.rpath \
	config.sub \
	depcomp \
	install-sh \
	ltmain.sh \
	missing \
	$(gsettings_SCHEMAS:.xml=.valid) \
	$(VALA_SOURCES:.vala=.c) \
	*.stamp

-include $(top_srcdir)/git.mk
