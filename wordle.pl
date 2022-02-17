#!/usr/bin/perl

# wordle game using a list of 5 letter words all upper case
# target is to guess the word
# correct letters will be 'X'
# correct but misplaced letters will be '#'
# non existing letters will be '0'

use strict;
use warnings;
use Data::Dumper;

my @wordlist = `cat wordlist`;
chomp(@wordlist);
my (%word,$guess);
$word{number} =int(rand(scalar @wordlist));
$word{letters} =$wordlist[$word{number}];

my $DEBUG=0;
my $WIN = 1;

while ($WIN) {
    print "\nRate das 5 Stellige Wort!!!\n";
    print "-------------------------------------\n";
    $word{verify} = [0,0,0,0,0];
    if (do_guess()) {
        check_letters();
        
        print "WORD: $guess\n";
        print "HITS: $word{verify}[0]$word{verify}[1]$word{verify}[2]$word{verify}[3]$word{verify}[4]\n";

        check_win();
    }
}

sub check_win {
    return if ($word{verify}[0] ne 'X'); 
    return if ($word{verify}[1] ne 'X'); 
    return if ($word{verify}[2] ne 'X'); 
    return if ($word{verify}[3] ne 'X'); 
    return if ($word{verify}[4] ne 'X'); 
    print "WIN!!!\n";
    $WIN=0;
}

sub do_guess {
    $guess = uc(<STDIN>);
    chomp($guess);
    my $match = grep { /$guess/ } @wordlist;
    print "Wort nicht gefunden\n" if ($match == 0);
    
    return $match;
}

sub check_letters {
    print "$guess\n" if ($DEBUG);
    print "$word{letters}\n" if ($DEBUG);

    my @x=split (//, $guess); 
    my @y=split (//, $word{letters}); 

    my $match_x = 0;
    foreach my $in (@x) {
    my $match_y = 0;
        foreach my $out (@y) {
            if ($in eq $out) {
                if ($match_y == $match_x) {
                    $word{verify}[$match_x] = 'X';
                } else {
                    $word{verify}[$match_x] = '#' if ($word{verify}[$match_x] ne 'X');
                }
                print "check: $in $out\n" if ($DEBUG);
                print "$match_y - $match_x\n" if ($DEBUG);
            }
            $match_y++;
        }
            $match_x++;
    }
}
