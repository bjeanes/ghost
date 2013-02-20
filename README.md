Ghost
=====

A gem that allows you to create, list, and modify local hostnames
with ease in linux and OS (more to come)...

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

    $ ghost add mydevsite.local
      [Adding] mydevsite.local -> 127.0.0.1

    $ ghost add staging-server.local 67.207.136.164
      [Adding] staging-server.local -> 67.207.136.164

    $ ghost list
    Listing 2 host(s):
      mydevsite.local      -> 127.0.0.1
      staging-server.local -> 67.207.136.164

    $ ghost delete mydevsite.local
      [Deleting] mydevsite.local

    $ ghost delete_matching test
      [Deleting] test2.local
      [Deleting] test.local

    $ ghost list
    Listing 1 host(s):
      staging-server.local -> 67.207.136.164

    $ ghost modify staging-server.local 64.233.167.99
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

With RVM you need to add `rvmsudo` before the command:

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

If this list is ever out of date, you can get full contributor list
with `git log --format='%aN (%ae)' | sort -u` or from [here](https://github.com/bjeanes/ghost/graphs/contributors).

* [Alkesh Vaghmaria](https://github.com/alkesh)
* [Andrei Serdeliuc](https://github.com/extraordinaire)
* [Ben Hoskings](https://github.com/benhoskings)
* [Bo Jeanes](https://github.com/bjeanes)
* [David Warkentin](https://github.com/ev0rtex)
* [Duncan Beevers](https://github.com/duncanbeevers)
* [Felipe Coury](https://github.com/fcoury)
* [Finn Smith](https://github.com/finn)
* [Geoff Wagstaff](https://github.com/TheDeveloper)
* [Johannes Thoenes](https://github.com/jthoenes)
* [Justin Mazzi](https://github.com/jmazzi)
* [Lars Fronius](https://github.com/LarsFronius)
* [Lee Jensen](https://github.com/outerim)
* [Luiz Galaviz](https://github.com/MGalv)
* [Luiz Rocha](https://github.com/lsdr)
* [Mitchell Riley](https://github.com/mitchellvriley)
* [Noah Kantrowitz](https://github.com/coderanger)
* [Ryan Bigg](https://github.com/radar)
* [Sam Beam](https://github.com/sbeam)
* [Simon Courtois](https://github.com/simonc)
* [Turadg Aleahmad](https://github.com/turadg)

Legal Stuff
===========

Copyright (c) 2008-2012 Bodaniel Jeanes

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
