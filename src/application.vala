/*
* Copyright (c) {{yearrange}} albert ()
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: albert <>
*/
using Granite;
using Granite.Widgets;
using Gtk;

namespace anim8 {
	public class Application : Granite.Application {
		anim8.Document document = new Document();

		/* Addressable UI objects */
		Gtk.ApplicationWindow window;
		Gtk.ListStore frames_list;
		Gtk.TreeView  frames_view;
		Gtk.Image     viewport;

		public Application () {
			Object (
				application_id: "com.github.albert-tomanek.anim8",
				flags: ApplicationFlags.FLAGS_NONE
			);
		}

		protected override void activate () {
			this.load_ui();
			this.load_css();

			this.window.set_application(this);
			this.window.show_all ();

			this.frames_view.get_selection().changed.connect((sel) => {
				Gtk.TreeIter iter;
				sel.get_selected(null, out iter);
				uint64 frame_no = 0;
				frames_list.get(iter, 0, &frame_no, -1);
				this.view_frame(this.document.frames[(int)frame_no - 1]);	// Frames start counting from 1 in UI
			});

			// string[] frs = { "/home/albert/Downloads/IMG_20191217_201935592_BURST000_COVER.jpg", "/home/albert/Downloads/IMG_20191217_201935592_BURST001.jpg" };
			// foreach (string fr in frs)
			// {
			// 	this.add_frame(fr);
			// }
		}

		private void load_ui()
		{
			var builder = new Gtk.Builder.from_file("../data/layout/main.glade");
			builder.connect_signals(this);

			this.window      = builder.get_object("main_win") as Gtk.ApplicationWindow;
			this.frames_list = builder.get_object("frames_store") as Gtk.ListStore;
			this.frames_view = builder.get_object("frames_view") as Gtk.TreeView;
			this.viewport    = builder.get_object("viewport") as Gtk.Image;
		}

		private void load_css()
		{
	        var prov = new Gtk.CssProvider ();
	        prov.load_from_path ("../data/style/style.css");
	        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), prov, Gtk.STYLE_PROVIDER_PRIORITY_USER);
		}

		private void add_frame(string file)
		{
			var frame = Frame() { file = file };
			this.document.frames.add(frame);

			this.frames_list.append(out frame.list_ent);
			this.frames_list.set(frame.list_ent, 0, this.document.frames.size, 1, frame.file);
		}

		private void view_frame(Frame frame)	// Open a frame in the viewport
		{
			var pixbuf = new Gdk.Pixbuf.from_file(frame.file);
			float ratio = (float) this.viewport.get_allocated_width() / (float) pixbuf.width;
			pixbuf = pixbuf.scale_simple((int) (pixbuf.width * ratio), (int) (pixbuf.height * ratio), Gdk.InterpType.BILINEAR);

			this.viewport.set_from_pixbuf(pixbuf);
			this.viewport.queue_draw();
		}

		[CCode (instance_pos = -1)]
		internal void on_import_frame(void *data = null)
		{
			var file_chooser = new FileChooserDialog ("Import frames", this.window, FileChooserAction.OPEN,
				"_Cancel", ResponseType.CANCEL,
				"_Open", ResponseType.ACCEPT);

			file_chooser.select_multiple = true;

			if (file_chooser.run () == ResponseType.ACCEPT) {
				foreach (string path in file_chooser.get_filenames())
				{
					this.add_frame(path);
				}
			}
			file_chooser.destroy ();
		}

		public static int main (string[] args) {
			var app = new anim8.Application ();
			return app.run (args);
		}
	}
}
