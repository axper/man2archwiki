man2archwiki
============
Manpage to ArchWiki style HTML converter

Requirements
============
* mdocml (aka mandoc). Install it from [AUR](https://aur.archlinux.org/packages/mdocml/).

Usage
============
First make sure your `$BROWSER` is set, for example:

    export BROWSER=firefox

It's a good idea to put that line in your `.bashrc`.

Then you can run this script:
<pre>
./m <i>section</i> <i>manpage_name</i>
</pre>
For example:

    ./m 8 pacman

It will open the page in your browser.

The syntax is close to that of `man` command, however the section number is required.

If you are not sure what section a manpage is, you can use `apropos`, for example:

    apropos pacman

