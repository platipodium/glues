# Datei, die von Doxygen bearbeitet werden soll
EXTRA_DIST = glues.doxygen
# Die zu reinigenden files
CLEANFILES = *.html *.gif *.css *.png
# zu erstellende Datei
noinst_PROGRAMS = index.html
# Sourcefile
index_html_SOURCES = glues.doxygen
# ausfueren von Doxygen mit dem sourcefile
index.html: glues.doxygen
	test -x doxygen && doxygen $(srcdir)/glues.doxygen
