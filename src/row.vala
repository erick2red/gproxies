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

    /* data entries */
    [GtkChild]
    public Entry host_entry;
    [GtkChild]
    public SpinButton port_entry;
    [GtkChild]
    public Entry user_entry;
    [GtkChild]
    public Entry password_entry;

    public string uid { get; private set; }

    public bool details_shown {
      get {
        return details_revealer.reveal_child;
      }
      set {
        details_revealer.set_reveal_child (value);
      }
    }

    public ProxyData proxy_data {
      get {
        return { host_entry.text,
            port_entry.get_value_as_int (),
            user_entry.text,
            password_entry.text };
      }
      set {
        host_entry.text = value.host;
        port_entry.value = value.port;
        user_entry.text = value.user;
        password_entry.text = value.password;

        update_row_data ();
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

      port_entry.set_value (3128);
      host_entry.changed.connect (update_save);
    }

    private void update_row_data () {
      label_name.set_text ("%s:%d".printf (host_entry.text,
                                           port_entry.get_value_as_int ()));
      /* update uid */
      var data = "%s $ %s $ %d $ %s".printf (host_entry.text,
                                             user_entry.text,
                                             port_entry.get_value_as_int (),
                                             password_entry.text);
      uid = Checksum.compute_for_string (ChecksumType.MD5, data);
    }

    private void update_save () {
      save_button.sensitive = (host_entry.text != "" &&
                               port_entry.value != 0.0);
    }

    [GtkCallback]
    public void save_row_details () {
      details_revealer.set_reveal_child (false);
      update_row_data ();

      modified (false);

      if (selection_radio.active)
        activate ();
    }

    [GtkCallback]
    public void destroy_callback (Button button) {
      modified (true);
      destroy ();
    }

    public void set_active (bool active) {
      selection_radio.set_active (active);
    }

    public signal void modified (bool removed);
  }

} // namespace GProxies
