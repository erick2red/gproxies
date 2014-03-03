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
  [GtkTemplate (ui = "/org/gnome/gproxies/ui/window.ui")]
  public class Window : Gtk.ApplicationWindow {
    private const GLib.ActionEntry[] action_entries = {
      { "about", on_about_activate },
      { "add"  , on_add_activate },
    };

    private GLib.Settings settings;
    private static string proxies_filename;

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

      print ("Saving children\n");
      foreach (var child in proxies_list.get_children ()) {
	if (!(child is Row))
	  continue;

	if (removed && emitter == child)
	  continue;

	Row row = child as Row;
	print ("row_name of childrens is: %s\n", row.uid);

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

      /* FIXME: fill in with proper execute-plugins code */
      print ("Called activated row: %s\n", active_row.uid);
    }
  }

} // namespace GProxies
