Moodle Email Importer Module, SLOODLE Virtual World->Blog version

You probably don't want to install this as is.
We plan to incorporate this into the SLOODLE core, in which case you can just use SLOODLE.
Freemail originally had non-SLOODLE uses, which could fairly easily be put back.
This module is left here in case anyone wants to do that.


Copyright (c) various contributors (see below) based on original work by Serafim Panov
License http://www.gnu.org/licenses/gpl-3.0.html GNU GPL v3
Contributors:
* Serafim Panov
* Paul Preibisch
* Edmund Edgar


*** SECURITY WARNING ***

Some ways of setting this module up will allow people to send spam to the "drafts" section of your students' blogs.
If that would be a problem for you, make sure you read and understand the explanation below before turning it on.


*** How to use it ***

* Set up an email account that is accessible through IMAP. (POP may work, but I haven't tested it.)
* If you need to avoid people sending emails that pretend to be your students... 
  ...make sure the email account you use only accepts email from the servers of the grid that will be sending your email.

* Put the mail server details in the module settings page.
* If using SLOODLE, make sure your avatar is registered linked to your Moodle account.
* If not using SLOODLE, make sure your Moodle email account is the same as the one you registered with Second Life.
* Go to http://yoursite.example.com/moodle/mod/freemail/view.php
* Send a snapshot to your email address, putting the subject of the blog post in the subject field.
* Click the "Test" button, and your email should be processed and imported to your blog as a draft.
* If your Moodle site is running the cron, email should be processed automatically whenever it runs.
* It is possible to run the readmail.php file from the command line as a daemon, so it will handle emails immediately.
 

*** About this code ***

This code will allow you to send snapshots from SL or OpenSim
...and have them show up as blog entries in your blog.

It is based on Serafim Panov's Freemail module, designed for Moodle 1.x.
Freemail was a separate module that allowed you to send email for handling by
...various different bits of Moodle, like blog, profile, gallery and file uploads.

It was modifed by Paul Preibisch to work with SL postcards, but still as a standalone module.

Edmund Edgar then refactored it, ported it to Moodle 2. 
In the process it was stripped down and a lot of its original functionality removed.
If you are interested in making a module with this functionality in, take a look at the history at:
https://github.com/edmundedgar/moodle-mod_freemail


