PKGS=\
forgeupgrade \
cvs-tuleap \
mailman-tuleap \
php-mediawiki-tuleap \
viewvc-tuleap \
jpgraph-tuleap \
htmlpurifier \
php-restler \
restler-api-explorer \
php-zendframework \
php-sabredav \
openfire-tuleap-plugins \
php-guzzle \
php-pear-Mail-Mbox \
geshi \


srpms-docker: srpms-docker-$(OS)
	@echo "Done"

srpms-docker-rhel6:
	@[ -d /root/rpmbuild/SRPMS ] || mkdir -p /root/rpmbuild/SRPMS
	@touch /root/rpmbuild/SRPMS/doing_rhel5
	@for pkg in $(PKGS); \
	do \
		echo "------------------------------- $$pkg ---------------------------------------" ; \
		if ls -l /srpms/rhel6/$$pkg-[0-9]*.src.rpm 2>/dev/null ; \
		then \
			echo "           |" ; \
			echo "           +--> $$pkg already source built" ; \
			echo "" ; \
		else \
			echo "           |" ; \
			echo "           +---- Building $$pkg -----" ; \
			echo "" ; \
			if [ -f ../../Makefile.$$pkg ] ; \
			then \
				make -C ../../ -f Makefile.$$pkg PKG_NAME=$$pkg buildsrc ; \
			else \
				make -C ../../ -f Makefile.pkgname PKG_NAME=$$pkg buildsrc ; \
			fi ; \
		fi; \
	done 
	@chown -R $$UID.$$GID /root/rpmbuild ;
	@#ls -al /root/rpmbuild/*
	@echo "Done $@"
	
srpms-docker-rhel5:
	@[ -d /root/rpmbuild/SRPMS ] || mkdir -p /root/rpmbuild/SRPMS
	@touch /root/rpmbuild/SRPMS/not_doing_rhel5
	@#ls -al /root/rpmbuild/*
	@echo "Done $@"
