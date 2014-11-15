#! /usr/bin/make -f

BUILDPLACE=buildplace
BUILDRESULT=buildresult
#
# rpmbuild --showrc | grep _topdir
# gives
# _builddir	%{_topdir}/BUILD
# _buildrootdir	%{_topdir}/BUILDROOT
# _rpmdir	%{_topdir}/RPMS
# _sourcedir	%{_topdir}/SOURCES
# _specdir	%{_topdir}/SPECS
# _srcrpmdir	%{_topdir}/SRPMS
# _topdir	%{getenv:HOME}/rpmbuild

RPMBUILD=rpmbuild --quiet --define='_topdir $(BUILDPLACE)' --define='_tmppath %{_topdir}' --define='_sysconfdir /etc' --define='_rpmdir $(BUILDRESULT)' --define='_specdir %{_topdir}/SPECS' 
#--define='_sourcedir %{_topdir}/SOURCES'

default:
	echo 'Nothing to do'

all: clean default

clean:	
	-rm -Rf $(HOME)/.rpmmacros $(BUILDPLACE) $(BUILDRESULT)
