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
  [GtkTemplate (ui = "/org/gnome/gproxies/ui/row.ui")]
  public class Row : Gtk.ListBoxRow {
    [GtkChild]
    private Button details_button;
    [GtkChild]
    private Revealer details_revealer;

    public Row () {
      details_button.bind_property ("active",
				    details_revealer, "reveal-child",
				    BindingFlags.SYNC_CREATE |
				    BindingFlags.BIDIRECTIONAL);
    }
  }

} // namespace GProxies
