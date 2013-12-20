Ghost
=====

A gem that allows you to create, list, and modify local hostnames
with ease in Linux and other Unix-based operating systems (more to come)...

Requirements
============

Unix-based OS (for now)

Intended Usage
==============

This gem is designed primarily for web developers who need to add
and modify hostnames to their system for virtual hosts on their
local/remote web server. However, it could be of use to other people
who would otherwise modify their `/etc/hosts` file manually and
flush the cache.

Command
-------

    $ sudo ghost add mydevsite.local
      [Adding] mydevsite.local -> 127.0.0.1

    $ sudo ghost add staging-server.local 67.207.136.164
      [Adding] staging-server.local -> 67.207.136.164

    $ ghost list
    Listing 2 host(s):
      mydevsite.local      -> 127.0.0.1
      staging-server.local -> 67.207.136.164

    $ sudo ghost delete mydevsite.local
      [Deleting] mydevsite.local

    $ sudo ghost delete_matching test
      [Deleting] test2.local
      [Deleting] test.local

    $ ghost list
    Listing 1 host(s):
      staging-server.local -> 67.207.136.164

    $ sudo ghost modify staging-server.local 64.233.167.99
      [Modifying] staging-server.local -> 64.233.167.99

    $ ghost list
    Listing 1 host(s):
      staging-server.local -> 64.233.167.99

    $ ghost export > some_file

    $ ghost empty
      [Emptying] Done.

    $ ghost list
    Listing 0 host(s):

    $ ghost import some_file
      [Adding] staging-server.local -> 64.233.167.99

    $ ghost list
    Listing 1 host(s):
      staging-server.local -> 64.233.167.99

With RVM, you need to add `rvmsudo` before the command:

    $ rvmsudo ghost add mydevsite.local
      [Adding] mydevsite.local -> 127.0.0.1

Library
-------

There is also a library that can be used in Ruby scripts. The `ghost`
command is a wrapper for the library. View the source of `bin/ghost`
to see how to use the library.

Installation
============

    gem install ghost
    
Using `sudo` may be necessary in some circumstances, depending on your setup 
(for example, using the stock Ruby that comes on OS X).

Contributors
============

A list of contributors can be found [here](https://github.com/bjeanes/ghost/graphs/contributors)..

Legal Stuff
===========

Copyright (c) 2008-2013 Bodaniel Jeanes

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
