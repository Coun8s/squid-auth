# squid-auth
Dockerfile for Squid LDAP authentication

1. Start container
```bash
$ sudo docker run -d --name squid-auth \
--restart always \
--net host \
--cap-add=NET_ADMIN \
--dns 8.8.8.8
--dns-search chostname.domain.local
--volume squid-logs:/var/log/squid \
--volume squid-etc-auth:/etc/squid \
--volume squid-cache:/var/cache/squid \
-e DC=dchostname \
-e DOMAIN=domain \
-e PREFIX=local \
-e USERADMIN=userdcadmin \
-e TZ=Europe/Saratov
  coun/squid-auth:latest
```
2. Add to LDAP
```bash
sudo docker exec -ti squid-auth adldap
sudo docker restart squid-auth
```
3. Check
```bash
sudo docker exec -ti squid-auth wbinfo -t
```
