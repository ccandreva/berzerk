#!/bin/perl

use strict;

foreach (@ARGV) {
    my $file = $_;
    my $cmd = "magick composite -geometry +4+5 $file ./Blank-16x18.png new/$file";
    print $cmd,"\n";
    system($cmd);
}

