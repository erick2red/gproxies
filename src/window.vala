/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 8 -*- */
/*
 * Copyright (C) 2014 Erick Pérez Castellanos <erick.red@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

using Gtk;

namespace GProxies {
  public struct Plugin {
    public string name;
    public string description;
    public string exec_line;
  }

  [GtkTemplate (ui = "/org/gnome/gproxies/ui/window.ui")]
  public class Window : Gtk.ApplicationWindow {
    private const GLib.ActionEntry[] action_entries = {
      { "about", on_about_activate },
      { "add"  , on_add_activate },
    };

    private GLib.Settings settings;
    private static string proxies_filename;
    private static string plugins_dirpath;

    /* active configuration */
    private weak Row active_row;

    [GtkChild]
    private MenuButton settings_button;
    [GtkChild]
    private ListBox proxies_list;

    public Window (Application app) {
      Object (application: app);

      active_row = null;

      add_action_entries (action_entries, this);

      settings = new GLib.Settings ("org.gnome.gproxies");
      var use_default_action = settings.create_action ("use-default");
      add_action (use_default_action);

      var builder = Utils.load_ui ("menu.ui");
      settings_button.menu_model = builder.get_object ("settings-menu") as MenuModel;

      show_all ();

      /* setup data & plugins folders */
      if (!settings.get_boolean ("did-setup")) {
        if (Utils.setup_files_folders () == false) {
          printerr ("GProxies: Unable to create setup folders\n");
          app.quit ();
        } else {
          settings.set_boolean ("did-setup", true);
        }
      }

      plugins_dirpath = Path.build_filename (Environment.get_user_data_dir (),
                                             "gproxies");

      /* open file, process it */
      proxies_filename = Path.build_filename (Environment.get_user_config_dir (),
                                              "gproxies",
                                              "proxies.variant");
      string contents;
      try {
        FileUtils.get_contents (proxies_filename, out contents);
      } catch (FileError e) {
        printerr ("Error %s\nProxies data could not be loaded\n", e.message);
      }
      try {
        var data = Variant.parse (new VariantType ("a(ssuss)"), contents);

        foreach (var tv in data) {
          var r = new Row ();
          ProxyData pdata = { tv.get_child_value (1).get_string (),
                              tv.get_child_value (2).get_uint32 (),
                              tv.get_child_value (3).get_string (),
                              tv.get_child_value (4).get_string () };
          r.proxy_data = pdata;
          r.show ();

          proxies_list.add (r);
          r.modified.connect (save_proxies);

          if (active_row != null)
            r.selection_radio.join_group (active_row.selection_radio);
          if (active_row == null)
            active_row = r;
          if (r.uid == settings.get_string ("active-proxy")) {
            r.set_active (true);
            active_row = r;
          }
        }
      } catch (VariantParseError e) {
        printerr ("Error %s\nProxies data could not be loaded\n", e.message);
      }
    }

    private void on_about_activate () {
      const string copyright = "Copyright \xc2\xa9 2014 Erick Pérez Castellanos\n";

      const string authors[] = {
        "Erick Pérez Castellanos <erick.red@gmail.com>",
        null
      };

      Gtk.show_about_dialog (this,
                             "program-name", _("GProxies"),
                             "version", Config.VERSION,
                             "comments", _("Utility to help you keep your proxy configurations."),
                             "copyright", copyright,
                             "authors", authors,
                             "license-type", Gtk.License.GPL_2_0,
                             "wrap-license", false,
                             null);
    }

    private void on_add_activate () {
      var r = new Row ();
      r.details_shown = true;
      r.show ();
      if (active_row != null) {
        r.selection_radio.join_group (active_row.selection_radio);
      }
      r.set_active (true);
      active_row = r;

      proxies_list.add (r);
      r.modified.connect (save_proxies);
    }

    private void save_proxies (Row emitter, bool removed) {
      var type = new VariantType ("a(ssuss)");
      var builder = new VariantBuilder (type);

      foreach (var child in proxies_list.get_children ()) {
        if (!(child is Row))
          continue;

        if (removed && emitter == child)
          continue;

        Row row = child as Row;

        builder.add ("(ssuss)",
                     row.uid,
                     row.host_entry.text, row.port_entry.get_value_as_int (),
                     row.user_entry.text, row.password_entry.text);
      }

      try {
        FileUtils.set_contents (proxies_filename, builder.end ().print (true));
      } catch (FileError e) {
        printerr ("Error %s\nProxies could not be saved\n", e.message);
      }
    }

    [GtkCallback]
    private void row_activated (ListBoxRow source_row) {
      if (!(source_row is Row))
        return;

      (source_row as Row).set_active (true);
      active_row = source_row as Row;
      settings.set_string ("active-proxy", active_row.uid);

      exec_plugins (active_row.proxy_data);
    }

    private List<Plugin?> get_plugins () {
      var r = new List<Plugin?> ();

      try {
        var dir = File.new_for_path (plugins_dirpath);
        var enumerator = dir.enumerate_children (FileAttribute.STANDARD_NAME, 0);

        FileInfo file_info;
        while ((file_info = enumerator.next_file ()) != null) {
          if (file_info.get_file_type () != FileType.DIRECTORY)
            continue;

          var ini = new KeyFile ();
          var ini_path = Path.build_filename (plugins_dirpath,
                                              file_info.get_name (),
                                              "plugin.ini"); /* this name is mandatory */
          if (!ini.load_from_file (ini_path, 0)) {
            printerr ("Plugin: %s could not be loaded\n", file_info.get_name ());
            continue;
          }

          if (!ini.has_key ("Plugin", "name") ||
              !ini.has_key ("Plugin", "exec")) {
            continue;
          }

          Plugin p = { ini.get_string ("Plugin", "name"),
                       ini.get_string ("Plugin", "description"),
                       ini.get_string ("Plugin", "exec") };
          r.append (p);
        }
      } catch (Error e) {
        printerr ("Error %s\nPlugins could not be loaded\n", e.message);
      }

      return r;
    }

    public void exec_default_plugin (ProxyData pdata) {
      /* set GNOME proxy settings */
      var proxy_settings = new GLib.Settings ("org.gnome.system.proxy");
      proxy_settings.set_enum ("mode", 1);

      var http_settings = proxy_settings.get_child ("http");
      var https_settings = proxy_settings.get_child ("https");
      var host = pdata.host;
      if (pdata.user != "")
        host = "%s:%s@%s".printf (pdata.user, pdata.password, pdata.host);
      http_settings.set_string ("host", host);
      http_settings.set_int ("port", (int) pdata.port);
      https_settings.set_string ("host", host);
      https_settings.set_int ("port", (int) pdata.port);
    }

    public void exec_plugins (ProxyData pdata) {
      if (settings.get_boolean ("use-default"))
        exec_default_plugin (pdata);

      /* FIXME: fill in with proper execute-plugins code */
      print ("setting proxy to :%s:%s@%s:%u\n",
             pdata.user, pdata.password,
             pdata.host, pdata.port);
      var errors_plugins = new List<string> ();
      var all_plugins = get_plugins ();
      foreach (var plugin in all_plugins) {
        if (0 != exec_plugin (plugin, pdata))
          errors_plugins.append (plugin.name);
      }
      /* FIXME: replace it for proper notification */
      print ("%u plugins executed correctly\n",
             all_plugins.length () - errors_plugins.length ());
    }

    public int exec_plugin (Plugin plugin, ProxyData pdata) {
      string[] argv = { Path.build_filename (plugins_dirpath,
                                             plugin.name,
                                             plugin.exec_line),
                        pdata.host,
                        "%u".printf (pdata.port),
                        pdata.user,
                        pdata.password };
      int exit_status;
      try {
        Process.spawn_sync (null, argv, null,
                            SpawnFlags.STDOUT_TO_DEV_NULL |
                            SpawnFlags.STDERR_TO_DEV_NULL,
                            null, null, null, out exit_status);
      } catch (SpawnError e) {
        printerr ("Error %s.\nPlugin %s could not be executed\n",
                  e.message,
                  plugin.name);
      }
      return exit_status;
    }
  }

} // namespace GProxies
