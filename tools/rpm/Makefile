PKGS=\
forgeupgrade \

PKGS=\
cvs-tuleap \


PKGS1=\
mailman-tuleap \
php-mediawiki-tuleap \
viewvc-tuleap \


PKGS=\
jpgraph-tuleap \
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
php-pear-Mail-Mbox \


srpms-docker: srpms-docker-$(OS)
	echo "Done"

srpms-docker-rhel6:
	for pkg in $(PKGS); \
	do \
		if [ -f ../../Makefile.$$pkg ] ; \
		then \
			make -C ../../ -f Makefile.$$pkg PKG_NAME=$$pkg buildsrc ; \
		else \
			make -C ../../ -f Makefile.pkgname PKG_NAME=$$pkg buildsrc ; \
		fi ; \
	done 
	chown -R $$UID.$$GID /root/rpmbuild
	ls -al /root/rpmbuild/*
	echo "Done $@"
	
srpms-docker-rhel5:
	touch /root/rpmbuild/SRPMS/not_doing_rhel5
	ls -al /root/rpmbuild/*
	echo "Done $@"
