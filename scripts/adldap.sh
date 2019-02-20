#!/bin/bash
if [ "$(net ads info | grep "LDAP server name:" | awk '{print $4}')" != ""$DC"."$DOMAIN"."$PREFIX"" ]; then 
	authconfig --enablekrb5 \
	--krb5kdc="$DC"."$DOMAIN"."$PREFIX" \
	--krb5adminserver="$DC"."$DOMAIN"."$PREFIX" \
	--krb5realm="${DC^^}"."${DOMAIN^^}"."${PREFIX^^}" \
	--enablewinbind \
	--enablewinbindauth \
	--smbsecurity=ads \
	--smbrealm="${DOMAIN^^}"."${PREFIX^^}" \
	--smbservers="$DC"."$DOMAIN"."$PREFIX" \
	--smbworkgroup="${DOMAIN^^}" \
	--winbindtemplatehomedir=/home/%U \
	--winbindtemplateshell=/bin/bash \
	--enablemkhomedir \
	--enablewinbindusedefaultdomain \
	--update
	net ads join -U "$USERADMIN"
	systemctl restart winbind
else
	exec "$@"
fi