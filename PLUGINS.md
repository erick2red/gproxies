## Plugins definitions guidelines

* Plugins must be contained in a folder inside `$XDG_DATA_DIR/gproxies`
* Inside the folder it need at least one `plugin.ini` key-file
* `plugin.ini` file must have a `[Plugin]` section and a `name` and `exec` key inside
* `Plugin.name` key should match the name of the plugin folder
* `Plugin.exec` key should contain the relative path of the script/app to execute
* The arguments passed to the scrip/app are `host`, `port`, `user` and `password` in that order
* The script/app should return 0 in success
