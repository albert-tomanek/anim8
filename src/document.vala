namespace anim8
{
	class Document
	{
		public Gee.ArrayList<Frame?> frames = new Gee.ArrayList<Frame?>();
	}

	struct Frame
	{
		public string file;
		public Gtk.TreeIter list_ent;
	}
}
