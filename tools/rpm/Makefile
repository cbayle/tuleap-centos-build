srpms-docker: srpms-docker-$(OS)
	echo "Done"

srpms-docker-rhel6:
	make -C ../../ -f Makefile.pkgname PKG_NAME=forgeupgrade buildsrc
	make -C ../../ -f Makefile.pkgname PKG_NAME=jpgraph-tuleap buildsrc
	make -C ../../ -f Makefile.pkgname PKG_NAME=viewvc-tuleap buildsrc
	make -C ../../ -f Makefile.pkgname PKG_NAME=htmlpurifier buildsrc
	make -C ../../ -f Makefile.pkgname PKG_NAME=php-zendframework buildsrc
	make -C ../../ -f Makefile.pkgname PKG_NAME=php-restler buildsrc
	make -C ../../ -f Makefile.pkgname PKG_NAME=restler-api-explorer buildsrc
	chown -R $$UID.$$GID /root/rpmbuild
	ls -al /root/rpmbuild/*
	echo "Done $@"
	
srpms-docker-rhel5:
	touch /root/rpmbuild/SRPMS/not_doing_rhel5
	ls -al /root/rpmbuild/*
	echo "Done $@"
