SLOODLE 2.x
Edmund Edgar, 2012-05-12

This is the main server-side component for the SLOODLE system connecting Moodle the 3D virtual worlds of Second Life or OpenSim.
See http://www.sloodle.org for details.

You will also need a set of in-world objects in Second Life or OpenSim. These are contained in the SLOODLE Rezzer.
Details of where to get these are available at sloodle.org. 
You can also create an IAR for OpenSim from scratch using the code at:
https://github.com/sloodle/sloodle_opensim_iar

This is for SLOODLE 2.x. Previous versions are managed using Subversion, hosted at Google Code:
http://code.google.com/p/sloodle/

This module installs under your Moodle mod/ directory, like other Moodle modules.
See http://slisapps.sjsu.edu/sl/index.php/Install_Sloodle for step-by-step instructions.

Web Server requirements:
* A web server running Moodle 1.9 or Moodle 2.x.
* This has been tested mainly on Moodle 2.0. Cursory testing has been done on 1.9, 2.1, 2.2 and 2.3.
* This code should run on either UNIX-like operating systems or Windows. However, the import functions of the presenter tool may misbehave on Windows, and the beanstalkd-based optimization won't be usable at all.

Browser requirements:
* Any regular web browser, with JavaScript turned on.
* Presenter upload functionality uses Flash.

Viewer requirements:
* Some tools require Shared Media. This needs a viewer based on the Linden viewer, version 2.0 or higher.

Grid requirements:
* You can use the SLOODLE 2.x objects on the main Second Life grid or an OpenSim grid. However, your OpenSim grid and your Moodle server need to be able to send HTTP requests to each other. This means:
 1) Your Moodle server needs to accept traffic from SL/OpenSim on the same port as the normal Moodle website. This is normally not a problem, but some Moodle sites using external sign-on methods may prevent it.
 2) Your Moodle server needs to allow traffic out on the ports used by your grid for HTTP-in. For Second Life, these are 12046 and 12043. Some large Moodle hosting providers have firewalls that block outgoing traffic, or limit it to ports 80 and 443.
 3) Traffic needs to be routable from your Moodle server to your grid. This can be a problem if you are running a public Moodle server outside your firewall, but your own OpenSim server inside your firewall. Fixing it may require NAT settings to allow traffic coming from outside your firewall to be directed to your grid, and ports opening to allow HTTP-in traffic through to it.

Optional components:
* The presenter tool has a feature to import PDFs and convert them into slides. This needs ImageMagick, available either through the command line or using PHP bindings.
* It is possible to optimize the sending of messages from the server to objects by adding a message queue, and running a process in the background called sloodled.php. This uses a separate piece of software called beanstalkd. See the comments at the top of sloodled.php for more details.

Other SLOODLE components:
* The primdrop tool for submitting in-world objects as homework uses the sloodleobject assignment plugin at https://github.com/sloodle/moodle-assignment_sloodleobject
* An optional menu block is available showing students' avatar information and helping people navigate to SLOODLE tools in Moodle: https://github.com/sloodle/moodle-block_sloodle_menu
* A separate menu block displays currency information related to the awards system: https://github.com/sloodle/moodle-block_sloodle_backpack
All the above are included in the zip / tarball release. The latest version is available at http://download.avatarclassroom.com/sloodle/


Please post any questions or comments on the forums at http://www.sloodle.org.
