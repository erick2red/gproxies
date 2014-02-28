AC_PREREQ(2.63)

AC_INIT([gproxies],
        [0.1],
        [http://github.com/erick2red/gproxies],
        [gproxies])

dnl http://people.gnome.org/~walters/docs/build-api.txt
dnl We don't support separate builddir when building from git
echo \#buildapi-variable-no-builddir >/dev/null

AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_HEADERS(config.h)
AC_CONFIG_SRCDIR(src/main.vala)

AM_INIT_AUTOMAKE([1.11 tar-ustar dist-xz no-dist-gzip foreign])
m4_ifdef([AM_SILENT_RULES],[AM_SILENT_RULES([yes])])

IT_PROG_INTLTOOL(0.40)
AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION([0.17])
GETTEXT_PACKAGE=AC_PACKAGE_NAME
AC_SUBST([GETTEXT_PACKAGE])
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE,"$GETTEXT_PACKAGE",[The name of the gettext domain])

AC_PROG_CC
AC_PROG_CC_STDC
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AM_PROG_VALAC([0.21.2])

AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

GLIB_GSETTINGS

LT_INIT([disable-static])

PKG_PROG_PKG_CONFIG([0.22])

PKG_CHECK_MODULES(GPROXIES, [
    gio-2.0 >= 2.30.0
    glib-2.0 >= 2.39.91
    gtk+-3.0 >= 3.11.8
])

AC_CONFIG_FILES([
    Makefile
    data/org.gnome.gproxies.gschema.xml.in
    po/Makefile.in
])

AC_OUTPUT

echo "
    gproxies ${VERSION}

    prefix: ${prefix}
    Vala compiler: ${VALAC}
    C compiler: ${CC}

    Now type 'make' to build ${PACKAGE}
"
