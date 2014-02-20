/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 8 -*- */
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
      {  "add" , on_add_activate },
    };

    [GtkChild]
    private HeaderBar header_bar;
    [GtkChild]
    private Button add_button;
    [GtkChild]
    private ListBox proxies_list;

    /* active configuration */
    private weak Row active_row;

    public Window (Application app) {
      Object (application: app);

      active_row = null;

      add_action_entries (action_entries, this);

      show_all ();
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

    /* FIXME: demo code */
    static int counter = 0;
    private void on_add_activate () {
      stdout.printf ("Hii you just pressed add\n");

      /* FIXME: demo code */
      counter += 1;

      var r = new Row ();
      r.row_name = "192.168.25%d.%d:3128".printf (counter, ++counter);
      r.show_details (true);
      r.show ();
      if (active_row != null) {
	r.selection_radio.join_group (active_row.selection_radio);
      }
      r.set_active (true);
      active_row = r;

      proxies_list.add (r);
    }
  }

} // namespace GProxies
