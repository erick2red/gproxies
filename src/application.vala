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

namespace GProxies {
  public class Application : Gtk.Application {
    static bool print_version;
    const OptionEntry[] option_entries = {
      { "version", 'v', 0, OptionArg.NONE, ref print_version, N_("Print version information and exit"), null },
      { null }
    };

    const GLib.ActionEntry[] action_entries = {
      { "quit", on_quit_activate }
    };

    private Window window;

    public Application () {
      Object (application_id: "org.gnome.gproxies");

      add_action_entries (action_entries, this);
    }

    protected override void activate () {
      if (window == null) {
        window = new Window (this);
      }
      window.present ();
    }

    protected override void startup () {
      base.startup ();

      var builder = Utils.load_ui ("menu.ui");
      var app_menu = builder.get_object ("app-menu") as MenuModel;
      set_app_menu (app_menu);
    }

    protected override bool local_command_line ([CCode (array_length = false, array_null_terminated = true)] ref unowned string[] arguments, out int exit_status) {
      var ctx = new OptionContext ("");

      ctx.add_main_entries (option_entries, Config.GETTEXT_PACKAGE);
      ctx.add_group (Gtk.get_option_group (true));

      // Workaround for bug #642885
      unowned string[] argv = arguments;

      try {
        ctx.parse (ref argv);
      } catch (Error e) {
        exit_status = 1;
        return true;
      }

      if (print_version) {
        print ("%s %s\n", Environment.get_application_name (), Config.VERSION);
        exit_status = 0;
        return true;
      }

      return base.local_command_line (ref arguments, out exit_status);
    }

    void on_quit_activate () {
      quit ();
    }
  }

} // namespace GProxies
