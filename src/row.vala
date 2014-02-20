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

    [GtkChild]
    private Button save_button;
    [GtkChild]
    private Button delete_button;

    [GtkChild]
    private Label label_name;

    [GtkChild]
    public RadioButton selection_radio;

    public string row_name {
      get {
        return label_name.get_text ();
      }
      set {
        label_name.set_text (value);
      }
    }

    public Row () {
      details_button.bind_property ("active",
                                    details_revealer, "reveal-child",
                                    BindingFlags.SYNC_CREATE |
                                    BindingFlags.BIDIRECTIONAL);

      details_button.bind_property ("active",
                                    label_name, "sensitive",
                                    BindingFlags.SYNC_CREATE |
                                    BindingFlags.INVERT_BOOLEAN |
                                    BindingFlags.BIDIRECTIONAL);

      selection_radio.bind_property ("active",
                                     delete_button, "sensitive",
                                     BindingFlags.SYNC_CREATE |
                                     BindingFlags.INVERT_BOOLEAN |
                                     BindingFlags.BIDIRECTIONAL);

    }

    [GtkCallback]
    public void save_row_details () {
      /* FIXME: fill in with proper row saving functionality */
      details_revealer.set_reveal_child (false);
    }

    [GtkCallback]
    public void destroy_callback (Button button) {
      destroy ();
    }

    public void set_active (bool active) {
      selection_radio.set_active (active);
    }

    public void show_details (bool shown) {
      details_revealer.set_reveal_child (shown);
    }
  }

} // namespace GProxies
