#!/usr/bin/perl
## script by Xyne
## http://bbs.archlinux.org/viewtopic.php?id=57291
use strict;
use warnings;
my $n = (`pacman -Qu | wc -l`);
chomp ($n);
if ($n == 0)
{
     print "Actualizado"
}
else
{
print "$n Disponibles "
}