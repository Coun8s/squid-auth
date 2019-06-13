FROM centos:centos7.6.1810

MAINTAINER Vitaliy Skvortcov <vitaliyskvortcov@gmail.com>

RUN yum -y install wget autoconf automake authconfig make gcc-c++ libecap libecap-devel openssl-devel openldap-devel pam-devel quota-devel libdb-devel libxml2-devel \
samba-winbind samba-winbind-clients pam_krb5 krb5-workstation \
&& wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py -O /usr/bin/systemctl \
&& wget -P /opt/ http://www.squid-cache.org/Versions/v4/squid-4.4.tar.gz \
&& tar xfv /opt/squid-4.4.tar.gz -C /opt/ \
&& sed -i 's/.*debugs(28, DBG_IMPORTANT, "WARNING: " \x3C\x3C name \x3C\x3C " ACL is used in " \x3C\x3C.*/\x20\x20\x20\x20\x20\x20\x20\x20debugs(28, 5, "checking " \x3C\x3C name \x3C\x3C " ACL is used in " \x3C\x3C/g' /opt/squid-4.4/src/acl/Acl.cc \
&& sed -i 's/.*debugs(28, DBG_IMPORTANT, "WARNING: " \x3C\x3C name \x3C\x3C " ACL is used in " \x3C\x3C.*/\x20\x20\x20\x20\x20\x20\x20\x20debugs(28, 5, "checking " \x3C\x3C name \x3C\x3C " ACL is used in " \x3C\x3C/g' /opt/squid-4.4/src/acl/ConnectionsEncrypted.cc \
&& cd /opt/squid-4.4/ \
&& ./configure \
--build=x86_64-redhat-linux-gnu \
--host=x86_64-redhat-linux-gnu \
--program-prefix= \
--prefix=/usr \
--exec-prefix=/usr \
--bindir=/usr/bin \
--sbindir=/usr/sbin \
--sysconfdir=/etc \
--datadir=/usr/share \
--includedir=/usr/include \
--libdir=/usr/lib64 \
--libexecdir=/usr/libexec \
--sharedstatedir=/var/lib \
--mandir=/usr/share/man \
--infodir=/usr/share/info \
--exec_prefix=/usr \
--libexecdir=/usr/lib64/squid \
--localstatedir=/var \
--datadir=/usr/share/squid \
--sysconfdir=/etc/squid \
--with-logdir=/var/log/squid \
--with-pidfile=/var/run/squid.pid \
--disable-dependency-tracking \
--enable-follow-x-forwarded-for \
--enable-auth \
--enable-auth-basic=DB,LDAP,NCSA,NIS,PAM,POP3,RADIUS,SASL,SMB,SMB_LM,getpwnam \
--enable-auth-ntlm=SMB_LM,fake \
--enable-auth-digest=file,LDAP,eDirectory \
--enable-auth-negotiate=kerberos,wrapper \
--enable-external-acl-helpers=eDirectory_userip,kerberos_ldap_group,LDAP_group,wbinfo_group,unix_group,file_userip \
--enable-cache-digests \
--enable-cachemgr-hostname=localhost \
--enable-delay-pools \
--enable-epoll \
--enable-icap-client \
--enable-ident-lookups \
--enable-linux-netfilter \
--enable-removal-policies=heap,lru \
--enable-snmp \
--enable-storeio=aufs,diskd,ufs,rock \
--enable-wccpv2 \
--enable-esi \
--enable-security-cert-generators \
--enable-security-cert-validators \
--enable-icmp \
--with-aio \
--with-default-user=squid \
--with-filedescriptors=16384 \
--with-dl \
--with-openssl \
--enable-ssl-crtd \
--with-pthreads \
--with-included-ltdl \
--disable-arch-native \
--without-nettle \
'build_alias=x86_64-redhat-linux-gnu' \
'host_alias=x86_64-redhat-linux-gnu' \
'CFLAGS=-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches   -m64 -mtune=generic' \
'LDFLAGS=-Wl,-z,relro ' \
'CXXFLAGS=-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches   -m64 -mtune=generic -fPIC' \
'PKG_CONFIG_PATH=:/usr/lib64/pkgconfig:/usr/share/pkgconfig' \
--enable-ltdl-convenience \
&& make all -j4 && make install -j4 && make clean && cd ~ && rm -fr /opt/* && yum -y remove wget autoconf automake gcc-c++ && yum clean all

COPY ./conf/squid.conf /etc/squid/squid.conf
COPY ./scripts/start.sh /start.sh
COPY ./conf/winbind.service /usr/lib/systemd/system/winbind.service
COPY ./scripts/adldap.sh /usr/bin/adldap

RUN useradd squid -d /var/spool/squid -s /sbin/nologin \
&& chown squid:squid -R /var/log/squid \
&& chown squid:squid -R /var/cache/squid \
&& chmod -R 755 /var/cache/squid \
&& chmod 4755 /usr/lib64/squid/pinger \
&& chmod +x /start.sh \
&& chmod +x /usr/bin/adldap \
&& mv /usr/bin/ntlm_auth /usr/lib64/squid \
&& usermod -a -G wbpriv squid \
&& systemctl enable winbind

ENV DC=dchostname \
	DOMAIN=domain \
	PREFIX=local \
	USERADMIN=userdcadmin \
	TZ=Europe/Saratov

VOLUME ["/var/log/squid"] \
	   ["/etc/squid"] \
	   ["/var/cache/squid"]

EXPOSE 3127

CMD /usr/bin/systemctl
