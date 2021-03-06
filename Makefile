# This Makefile requires GNU Make 4 or a BSD make.

PLUGIN=		auth_saslauthd.so
HDRS=		saslauthd_client.h
SRCS=		saslauthd_client.c auth_saslauthd.c

SASLAUTHD_PATH!=perl -e 'print (((grep {-S} "/run/saslauthd/mux", \
		"/var/state/saslauthd/mux", "/var/sasl2/mux"), \
		"/var/run/saslauthd/mux")[0])'
SASLAUTHD_SERVICE=mariadb

PLUGINDIR!=	mysql_config --plugindir
MYINCDIR!=	mysql_config --variable=pkgincludedir
MYLIBDIR!=	mysql_config --variable=pkglibdir
MYFLAGS!=	mysql_config --cflags

DEFS=		-DMYSQL_DYNAMIC_PLUGIN \
		-DSASLAUTHD_PATH='"${SASLAUTHD_PATH}"' \
		-DSASLAUTHD_SERVICE='"${SASLAUTHD_SERVICE}"'

PICFLAGS+=	-fPIC
CFLAGS+=	${OPTIMIZE} ${PICFLAGS} -I${MYINCDIR}/server ${MYFLAGS} ${DEFS}
SOFLAGS+=	-shared
SOLIBS+=	-lpthread -L${MYLIBDIR} -lmysqlservices

OBJS=		${SRCS:.c=.o}

INSTALL=	install

all: ${PLUGIN}

${PLUGIN}: ${OBJS}
	${CC} ${SOFLAGS} -o ${PLUGIN} ${OBJS} ${SOLIBS}

${OBJS}: ${SRCS} ${HDRS}

install: ${PLUGIN}
	${INSTALL} -D -m 0755 ${PLUGIN} ${DESTDIR}${PLUGINDIR}/${PLUGIN}

clean:
	rm -f ${PLUGIN} ${OBJS}

.PHONY: all install clean
