#!/bin/bash
ln -sf /usr/share/zoneinfo/"$TZ" /etc/localtime
if [ ! -d "/var/cache/squid/00" ]; then
	/usr/sbin/squid --foreground -z
	exec /usr/sbin/squid -sYC -N
fi
if [ "$(cat /etc/squid/squid.conf | grep -o 'domain[^\]*' | cut -d= -f2)" != "${DOMAIN}"."${PREFIX}" ]; then
	sed -i "s/auth_param ntlm program.*/auth_param ntlm program \/usr\/lib64\/squid\/ntlm_auth \--diagnostics \--helper-protocol\=squid-2.5-ntlmssp \--domain\=${DOMAIN}.${PREFIX}/g" /etc/squid/squid.conf
fi
exec /usr/sbin/squid -sYC -N
