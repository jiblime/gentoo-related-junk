Basic shell scripts and notes.

### latest gentoo official minimal iso

`echo "Downloading minimal ISO" && wget "http://distfiles.gentoo.org/releases/amd64/autobuilds/$(curl -s http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-iso.txt | tail -n1 | sed 's/\ .*//')"`

## Stage Tarballs


##### gentoo official latest stage3 amd64 systemd tarball

`echo "Downloading stage3 amd64 systemd tarball" && wget "http://distfiles.gentoo.org/releases/amd64/autobuilds/$(curl -s http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-systemd.txt | awk 'match($0,/[0-9].*bz2/) { print substr($0,RSTART,RLENGTH) }')"`

##### gentoo official latest stage3 amd64 nomultilib tarball

`echo "Downloading stage3 amd64 nomultilib tarball" && wget "http://distfiles.gentoo.org/releases/amd64/autobuilds/$(curl -s http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-nomultilib.txt | awk 'match($0,/[0-9].*xz/) { print substr($0,RSTART,RLENGTH) }')"`

##### unofficial arm stage 1/2/3

`https://files.emjay-embedded.co.uk/unofficial-gentoo/arm-stages/testing/`

##### unofficial musl stage 4

`https://drive.google.com/open?id=1A8Qh7-VGixbt_Z7gODQKHvN88_KIVLIn`

`https://old.reddit.com/r/Gentoo/comments/daur9u/new_amd64_muslclanglibcelftoolchain_stage4/`

Basic chroot script meant to be ran in the directory to be chrooted:

```
#!/bin/bash
mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm # Mounting /dev/shm is required for some distros
chmod 1777 /dev/shm
mount -t proc none proc -v
mount --rbind --make-rslave /sys sys -v
mount --rbind --make-rslave /dev dev -v
mount --rbind /tmp tmp -v
echo "Chrooting."
echo "  . /etc/profile; env-update"
chroot . /bin/bash
```

For a second Gentoo install:

```
#!/bin/bash
mount --rbind /var/cache/distfiles/ var/cache/distfiles -v
mount --rbind /var/cache/binpkgs var/cache/binpkgs -v
mount --rbind /var/db/repos/gentoo var/db/repos/gentoo -v
```
