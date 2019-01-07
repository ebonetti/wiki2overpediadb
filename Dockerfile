FROM postgres:latest

ADD db /stockdb
RUN set -eux; \
cd /; \
mkdir /db; \ 
echo "#!/usr/bin/env bash\n\
set -e;\n\
cp -nr /stockdb/* /db;\n\
start-postgres() {\n\
set -- postgres\n\
$(cat docker-entrypoint.sh | head -n -1);\n\
setsid pg_ctl start -w;\n\
}; start-postgres > /dev/null 2>&1;\n\
trap 'pg_ctl stop -m s -w > /dev/null 2>&1; find . -user \$(whoami) -delete;' TERM QUIT INT EXIT;\n\
mycommand=\$@ bash --rcfile <(echo 'exec \$mycommand;')"> docker-entrypoint.sh;
ENTRYPOINT ["docker-entrypoint.sh"]
USER postgres
WORKDIR /db
CMD ["psql", "-v", "pagesfilepath=/db/pages.csv", "-v", "revisionsfilepath=/db/revisions.csv", "-v", "socialjumpsfilepath=/db/socialjumps.csv"]