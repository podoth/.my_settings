#!/usr/bin/ruby
=begin
  hello-applet.rb

  Copyright (c) 2004 Ruby-GNOME2 Project Team
  This program is licenced under the same licence as Ruby-GNOME2.

  $Id: hello-applet.rb,v 1.1 2004/06/06 17:23:04 mutoh Exp $
=end


require 'panelapplet2'


OAFIID="OAFIID:GNOME_EmacsMarkApplet_Factory"

init = proc do |applet, iid|
  label = Gtk::Label.new

  applet.add(label)
  applet.show_all

  Thread.start do
    loop do
    if !(`pgrep -fx "emacs --daemon"`.empty?)
      text="E"
    else
      text="O"
    end
      label.set_text(text)
      sleep(1)
    end
  end
  true
end

oafiid = OAFIID
run_in_window = (ARGV.length == 1 && ARGV.first == "run-in-window")
oafiid += "_debug" if run_in_window

PanelApplet.main(oafiid, "Emacs Mark Applet (Ruby-GNOME2)", "0", &init)

if run_in_window
  main_window = Gtk::Window.new
  main_window.set_title "Emacs Mark Applet"
  main_window.signal_connect("destroy") { Gtk::main_quit }
  app = PanelApplet.new
  init.call(app, oafiid)
  app.reparent(main_window)
  main_window.show_all
  Gtk::main
end


