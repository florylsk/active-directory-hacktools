## What is this fork?!

I needed bloodhound with Kerberos support and found this [comment](https://github.com/fox-it/BloodHound.py/pull/77#issuecomment-1040080895). Turns out there was a branch supporting Kerberos auth all along! I took the liberty to merge this branch in to master to get them sweet BloodHound 4.2+ exports. All credit goes to the people who actually wrote the code:)

## Note

As stated by mr. Dirkjan himself this "needs more work and testing". It might not work in all cases so please report any issues you come across and we can try to fix them. Maybe one day we can submit this as a PR to the main repo.

```
$ python3 /opt/BloodHound.py/bloodhound.py -u redacted -k -d absolute.htb -dc dc.absolute.htb -ns 10.129.202.227 --dns-tcp --zip -no-pass -c All
INFO: Found AD domain: absolute.htb
INFO: Using TGT from cache
INFO: Found TGT with correct principal in ccache file.
INFO: Connecting to LDAP server: dc.absolute.htb
INFO: Found 1 domains
INFO: Found 1 domains in the forest
INFO: Found 1 computers
INFO: Connecting to LDAP server: dc.absolute.htb
INFO: Found 18 users
INFO: Found 55 groups
INFO: Found 0 trusts
INFO: Starting computer enumeration with 10 workers
INFO: Querying computer: dc.absolute.htb
INFO: Ignoring host dc.absolute.htb since its reported name  does not match
INFO: Done in 00M 02S
INFO: Compressing output into 20220926135518_bloodhound.zip
```

If you get DNS errors you can try pointing DNS to yourself `-ns 127.0.0.1` while running dnschef:

```
python3 dnschef.py --fakeip <dc ip> --fakedomains <domain> -q
```

# BloodHound.py

![Python 3 compatible](https://img.shields.io/badge/python-3.x-blue.svg)
![PyPI version](https://img.shields.io/pypi/v/bloodhound.svg)
![License: MIT](https://img.shields.io/pypi/l/bloodhound.svg)

BloodHound.py is a Python based ingestor for [BloodHound](https://github.com/BloodHoundAD/BloodHound), based on [Impacket](https://github.com/CoreSecurity/impacket/).

This version of BloodHound.py is **only compatible with BloodHound 4.2 or newer**. For the 3.x range, use version 1.1.1 via pypi. As of version 1.3, BloodHound.py only supports Python 3, Python 2 is no longer tested and may break in the future.

## Limitations

BloodHound.py currently has the following limitations:

-   Supports most, but not all BloodHound (SharpHound) features (see below for supported collection methods, mainly GPO based methods are missing)
-   Kerberos authentication support is not yet complete

## Installation and usage

You can install the ingestor via pip with `pip install bloodhound`, or by cloning this repository and running `python setup.py install`, or with `pip install .`.
BloodHound.py requires `impacket`, `ldap3` and `dnspython` to function.

The installation will add a command line tool `bloodhound-python` to your PATH.

To use the ingestor, at a minimum you will need credentials of the domain you're logging in to.
You will need to specify the `-u` option with a username of this domain (or `username@domain` for a user in a trusted domain). If you have your DNS set up properly and the AD domain is in your DNS search list, then BloodHound.py will automatically detect the domain for you. If not, you have to specify it manually with the `-d` option.

By default BloodHound.py will query LDAP and the individual computers of the domain to enumerate users, computers, groups, trusts, sessions and local admins.
If you want to restrict collection, specify the `--collectionmethod` parameter, which supports the following options (similar to SharpHound):

-   _Default_ - Performs group membership collection, domain trust collection, local admin collection, and session collection
-   _Group_ - Performs group membership collection
-   _LocalAdmin_ - Performs local admin collection
-   _RDP_ - Performs Remote Desktop Users collection
-   _DCOM_ - Performs Distributed COM Users collection
-   _PSRemote_ - Performs Remote Management (PS Remoting) Users collection
-   _DCOnly_ - Runs all collection methods that can be queried from the DC only, no connection to member hosts/servers needed. This is equal to Group,Acl,Trusts,ObjectProps
-   _Session_ - Performs session collection
-   _Acl_ - Performs ACL collection
-   _Trusts_ - Performs domain trust enumeration
-   _LoggedOn_ - Performs privileged Session enumeration (requires local admin on the target)
-   _ObjectProps_ - Performs Object Properties collection for properties such as LastLogon or PwdLastSet
-   _All_ - Runs all methods above, except LoggedOn
-   _Experimental_ - Connects to individual hosts to enumerate services and scheduled tasks that may have stored credentials

Multiple collectionmethods should be separated by a comma, for example: `-c Group,LocalAdmin`

You can override some of the automatic detection options, such as the hostname of the primary Domain Controller if you want to use a different Domain Controller with `-dc`, or specify your own Global Catalog with `-gc`.

## Docker usage

1. Build container  
   `docker build -t bloodhound .`
2. Run container  
   `docker run -v ${PWD}:/bloodhound-data -it bloodhound`  
   After that you can run `bloodhound-python` inside the container, all data will be stored in the path from where you start the container.
