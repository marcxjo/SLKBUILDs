#!/bin/sh
#
# Slackware Pre-Installation Configuration Helper for Atheme Services

MUID=130
MGID=130
USERNAME=atheme
GROUPNAME=atheme
COMMENT="IRC Directory Server"
LOGINSHELL=/usr/bin/false

echo ""
echo "This script attempts to satisfy the initial conditions to install"
echo "Atheme IRC Services as outlined in the README.Slackware file that"
echo "accompanies the Atheme SLKBUILD."
echo ""
echo "It starts with a reasonably low UID/GID pair and attempts to"
echo "create the user and group with access to Atheme files."
echo ""
echo "It also sets up those directories, since they're not included in"
echo "the package itself."
echo ""
echo "Press ENTER to continue, or CTRL+C to cancel."
read JUNK
echo ""

if grep -qe "^$GROUPNAME:" /etc/group; then
	echo "Hmm, looks like group $GROUPNAME already exists. Exiting..."
	exit 1
fi
if grep -qe "^$USERNAME:" /etc/passwd; then
	echo "Hmm, looks like user $USERNAME already exists. Exiting..."
	exit 1
fi

NEXTGID="$(MGID=$MGID awk -F: '{uid[$3]=1} END { for (i=ENVIRON["MGID"];i in uid;i++);print i}' /etc/group)"
echo creating group $GROUPNAME with GID $NEXTGID...
/usr/sbin/groupadd -g $NEXTGID $GROUPNAME
# if nscd is running update group cache
[ $(pidof nscd) ] && { nscd --invalidate group; }

NEXTUID="$(MUID=$MUID awk -F: '{uid[$3]=1} END { for (i=ENVIRON["MUID"];i in uid;i++);print i}' /etc/passwd)"
echo creating user $USERNAME with UID $NEXTUID...
/usr/sbin/useradd -g $GROUPNAME -u $NEXTUID -s $LOGINSHELL -d /var/lib/atheme -c $COMMENT $USERNAME
# if nscd is running update user cache
[ $(pidof nscd) ] && { nscd --invalidate passwd; }

echo "Creating directories..."
mkdir -p -m750 /var/run/atheme
mkdir -p -m750 /var/log/atheme
mkdir -p -m750 /var/lib/atheme
chown atheme:atheme /var/lib/atheme
chown atheme:atheme /var/run/atheme
chown atheme:atheme /var/log/atheme
