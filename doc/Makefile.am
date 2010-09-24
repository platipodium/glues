SUBDIRS=pangaea

# Datei, die von Doxygen bearbeitet werden soll
EXTRA_DIST = glues.doxygen 
# Die zu reinigenden files
CLEANFILES = *.html *.gif *.css *.png
# zu erstellende Datei
#if ${DOXYGEN}==yes
  noinst_PROGRAMS = index.html
#endif
# Sourcefile
index_html_SOURCES = glues.doxygen
# ausfueren von Doxygen mit dem sourcefile
index.html: glues.doxygen
	if [[ "${DOXYGEN}"=="yes" ]]; then doxygen $(srcdir)/glues.doxygen; else touch index.html; fi
