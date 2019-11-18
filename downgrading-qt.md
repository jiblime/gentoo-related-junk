Rebuild the qt libraries for your preferred qt version. Mask unwanted versions appropriately.

```
emerge -1v $(qlist -IC dev-qt) # This first to fix Qt library version tagging
emerge -1v $(qlist -IC kde-frameworks) # Then emerge this category to setup rebuilding the kde-plasma/ and kde-apps/ categories
emerge -1v $(qlist -IC kde-plasma)
emerge -1v dev-python/PyQt5 dev-python/PyQt5-sip app-crypt/qca media-gfx/zbar sys-auth/polkit-qt net-libs/accounts-qt dev-libs/libdbusmenu-qt app-text/poppler net-libs/signond media-gfx/zbar
emerge -1v $(qlist -IC kde-apps)
```

If simply rebuilding the KDE ecosystem, this works:     
'emerge -1avD $(qlist -IC kde-{frameworks,plasma,apps)'
