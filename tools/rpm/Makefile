PKGS=\
forgeupgrade \
jpgraph-tuleap \
viewvc-tuleap \
htmlpurifier \
php-zendframework \
php-restler \
restler-api-explorer \


PKGS3=\
php-sabredav \
php-guzzle \
openfire-tuleap-plugins \
php-sabredav \
geshi \
mailman-tuleap \
php-pear-Mail-Mbox \


srpms-docker: srpms-docker-$(OS)
	echo "Done"

srpms-docker-rhel6:
	for pkg in $(PKGS); \
	do \
		make -C ../../ -f Makefile.pkgname PKG_NAME=$$pkg buildsrc ; \
	done 
	chown -R $$UID.$$GID /root/rpmbuild
	ls -al /root/rpmbuild/*
	echo "Done $@"
	
srpms-docker-rhel5:
	touch /root/rpmbuild/SRPMS/not_doing_rhel5
	ls -al /root/rpmbuild/*
	echo "Done $@"
