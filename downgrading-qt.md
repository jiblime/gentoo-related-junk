Attach files by dragging & dropping, selecting or pasting them.

Rebuild the qt libraries for your preferred qt version. Mask unwanted versions appropriately.

1) Rebuild the dev-qt library, which will change the shared library version tags.

2) Rebuild kde-frameworks to set up rebuilding of kde-{plasma,apps}

2.1) Rebuild other libraries that are linked to dev-qt prior to kde-apps

3) Rebuild kde-apps

4) 1emerge -pv $(eix -\# -I -U qt5)`

Super quick note: PyQt5 >5.13 works with 5.12, ICE on the 5.12* ebuilds

```
emerge -1v $(qlist -IC dev-qt)
emerge -1v $(qlist -IC kde-frameworks)Then emerge this category to setup rebuilding the kde-plasma/ and kde-apps/ categories
emerge -1v $(qlist -IC kde-plasma)
emerge -1v dev-python/PyQt5 dev-python/PyQt5-sip app-crypt/qca media-gfx/zbar sys-auth/polkit-qt net-libs/accounts-qt dev-libs/libdbusmenu-qt app-text/poppler net-libs/signond media-gfx/zbar
emerge -1v $(qlist -IC kde-apps)
emerge -1v $(eix -\# -I -U qt5)
```

If simply rebuilding the KDE ecosystem, this works:     
'emerge -1avD $(qlist -IC kde-{frameworks,plasma,apps)'

Tool to mask whole categories' versions below, mainly for dev-qt. This works if your package.mask file is either a file or directory. 

Usage: ./the-name-you-want-to-give-it {CATEGORY}

Example: ./make-sure-to-chmod-x-it dev-qt

~~NOTE: It's not masking PyQt5 properly. You've got to do that yourself.~~
```
#!/bin/bash

CATEGORY="${1}"
CATEGORY=${CATEGORY%/}

echo ""
if [[ -z "${CATEGORY}" ]] ; then
	echo "Append a package category as an argument to use this script"
	exit
fi

if [[ $(eix "${CATEGORY}/") = "No matches found" ]] ; then
	echo "Category not found. Try something like dev-qt" && exit
fi

add_versions() {

# Check for package.accept_keywords type
PAK="${EPREFIX}/etc/portage/package.accept_keywords"
if [[ -f ${PAK} ]] ; then
	echo hi
fi

}

get_versions() {

	VERSIONS=($(eix --format '<availableversions:NAMEVERSION>' -\* -0 "${CATEGORY}/" | sed 's/^.*\-//g'))

}


get_versions

echo "Choose the version to mask:"
for (( x=0 ; x<${#VERSIONS[@]} ; x++ )) ; do
	printf "$((${x} + 1))) %s\n" ${VERSIONS[${x}]};
done

echo -e "\nThe version you choose will be masked with a >= glob"
read -p "Make your selection by typing in the full version: " -e choice
echo ${choice}

stuff_you_dont_want="$(EIX_LIMIT=0 eix --format '<availableversions:NAMEVERSION>' -\* dev-qt/ | fgrep "${choice}" | sed 's/^/>=/g' | grep -v 'qtchooser\|qtlockedfile\|qtsingleapplication') \n>=dev-python/PyQt5-${choice}"

if [[ -d /etc/portage/package.mask ]] ; then
	echo -e ${stuff_you_dont_want} | tr " " "\n" >> "/etc/portage/package.mask/dev-qt-${choice}" && echo "Success!" || echo "Something went wrong, it's your fault"
elif [[ -f /etc/portage/package.mask ]] ; then
	echo -e ${stuff_you_dont_want} >> "/etc/portage/package.mask" && echo "Success!" || echo "Something went wrong, it's your fault"
else
	echo "Neither a package.mask file nor directory was found, ABORT" ; exit 1
fi


# Note: eix has a function to automatically append '=' to all package names. There must be more
# to eix that would greatly improve this script. TODO: read stuff

# Note: I don't remember if the top half of this script does anything but I'll check later



#read -p ""
#get_category
#EIX_LIMIT=0 eix --format '<availableversions:NAMEVERSION>' -* dev-qt/ | fgrep '5.14.0_beta2' | sed 's/^/=/g'
```
