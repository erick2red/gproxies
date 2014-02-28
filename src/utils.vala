/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 8 -*- */
/*
 * Copyright (C) 2013  Paolo Borelli <pborelli@gnome.org>
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
  namespace Utils {

    public Gtk.Builder load_ui (string ui) {
      var builder = new Gtk.Builder ();
      try {
        builder.add_from_resource ("/org/gnome/gproxies/ui/".concat (ui, null));
      } catch (Error e) {
        error ("loading main builder file: %s", e.message);
      }
      return builder;
    }

    public bool setup_files_folders () {
      /* config_dir/gproxies */
      var dirpath = Path.build_filename (Environment.get_user_config_dir (),
	                                 "gproxies");
      if (DirUtils.create (dirpath, 0755) != 0) {
	return false;
      }

      /* config_dir/gproxies/proxies.variant */
      var filename = Path.build_filename (dirpath, "proxies.variant");
      var f = FileStream.open (filename, "w");

      /* data_dir/gproxies */
      dirpath = Path.build_filename (Environment.get_user_data_dir (),
	                             "gproxies");
      if (DirUtils.create (dirpath, 0755) != 0) {
	return false;
      }

      return true;
    }

  } // namespace Utils
} // namespace GProxies
