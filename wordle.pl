#!/usr/bin/perl

# wordle game using a list of 5 letter words all upper case
# target is to guess the word
# correct letters will be 'X'
# correct but misplaced letters will be '#'
# non existing letters will be '0'

use strict;
use warnings;
use Data::Dumper;
use if ($^O eq 'linux' || $^O eq 'darwin'), 'Term::ANSIColor'; # LINUX|MAC
use if ($^O eq 'MSWin32'), 'Win32::Console::ANSI'; # Windows
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;

open(FH, "<", "wordlist") || die "Can't open: $!\n";
my @wordlist = <FH>;
close(FH);

chomp(@wordlist);
my (%abc,%word,@green_letter,@yellow_letter,$last,$length,$result);
$word{number}  = int(rand(scalar @wordlist));
$word{letters} = $wordlist[$word{number}];

my $DEBUG  = 0;
my $WIN    = 1;
my $guess = '     ';
my $string = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

map { $abc{$_} = BRIGHT_WHITE . "$_"; } (split //, $string);
$string = join("", sort(keys %abc));

system("clear") if ($^O eq 'linux' || $^O eq 'darwin'); # clear the screen to have a nice game view
system("cls")   if ($^O eq 'MSWin32');
printf BRIGHT_WHITE."\n\n";
printf BRIGHT_WHITE."    #   #   ###   ###   ###   #     ####  \n";
printf BRIGHT_WHITE."    #   #  #   #  #  #  #  #  #     #     \n";
printf BRIGHT_WHITE."    # # #  #   #  #  #  #  #  #     ###   \n";
printf BRIGHT_WHITE."    ## ##  #   #  # #   #  #  #     #     \n";
printf BRIGHT_WHITE."    #   #   ###   #  #  ###   ####  ####  \n\n\n";
printf BRIGHT_WHITE."         Rate das 5 Stellige Wort!!!\n\n";
printf " ------------------------------------------\n";
printf BRIGHT_WHITE." $string | " . ON_BRIGHT_BLACK . $guess . RESET . BRIGHT_WHITE . " | " . RESET;

while ($WIN) {
    $word{verify} = [0,0,0,0,0];
    if (do_guess()) {
        check_letters();
        printf color_letters();

        check_win();
    }
}

sub check_win {
    return if ($word{verify}[0] ne 'X'); 
    return if ($word{verify}[1] ne 'X'); 
    return if ($word{verify}[2] ne 'X'); 
    return if ($word{verify}[3] ne 'X'); 
    return if ($word{verify}[4] ne 'X'); 
    printf BRIGHT_GREEN."WIN!!!\n\n".RESET;
    $WIN=0;
}

sub do_guess {
    $last   = $guess;
    $length = 0;
    while ($length != 5){
        $guess = uc(<STDIN>);
        chomp($guess);
        $length = length($guess);
        if ($length != 5){
            printf BRIGHT_WHITE." Kein 5 stelliges Wort.\n".RESET;
            if ($result){ printf $result; }
            else        { printf BRIGHT_WHITE . " $string |       | ".RESET; }
        }
    }
    if ($guess !~ /[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]/) {
        $guess = $last;
        printf BRIGHT_WHITE." Nur Buchstaben erlaubt.\n".RESET;
    } else {
        my $match = grep { /$guess/ } @wordlist;
        if ($match == 0){
            $guess = $last;
            printf BRIGHT_WHITE." Wort nicht gefunden.\n".RESET;
        }
    }

    return 1;
}

sub check_letters {
    print "$guess\n" if ($DEBUG);
    print "$word{letters}\n" if ($DEBUG);

    my @x=split (//, $guess);
    my @y=split (//, $word{letters}); 
    my %letter_match_stack;

    my $match_y = 0;
    foreach my $in (@y) {
	#first all real hits maintaining letter_match_stack
    	my $match_x = 0;
        foreach my $out (@x) {
            print "CHECK: $in - $out\n" if ($DEBUG);
            if ($in eq $out) {
                if ($match_y == $match_x) {
                    $word{verify}[$match_x] = 'X';
		    $letter_match_stack{$match_y} = 1; #put the matching elmenet of the to be guessed word onto the stack
                }
                print "MATCH: $match_x - $match_y\n" if ($DEBUG);
            }
            $match_x++;
        }
	print Dumper \%letter_match_stack if ($DEBUG);
	
    	$match_x = 0;
        foreach my $out (@x) {
            if ($in eq $out) {
                $word{verify}[$match_x] = '#' if ($word{verify}[$match_x] ne 'X' and !$letter_match_stack{$match_y}); #check also the stack if there was a match before already for that letter
		$letter_match_stack{$match_y} = 1; #put the matching elmenet of the to be guessed word onto the stack
                print "MATCH: $match_x - $match_y\n" if ($DEBUG);
            }
            $match_x++;
        }
	print Dumper \%letter_match_stack if ($DEBUG);
       	$match_y++;
    }
}

sub color_letters {
    my $c = 0;
    my $COLOR;
    my @letter = split //, $guess;
    $result = "";
    while ($c < 5){
        #background color for second column
        if    ($word{verify}[$c] eq "0"){ $COLOR = ON_BRIGHT_BLACK;  }
        elsif ($word{verify}[$c] eq "#"){ $COLOR = ON_BRIGHT_YELLOW; }
        elsif ($word{verify}[$c] eq "X"){ $COLOR = ON_BRIGHT_GREEN;  }
        $result .= sprintf $COLOR . $letter[$c];

        #foreground color for first column
        if    ($word{verify}[$c] eq "0"){ $abc{$letter[$c]} = BRIGHT_RED    . $letter[$c] if ((! grep /^$letter[$c]$/, @green_letter) && (! grep /^$letter[$c]$/, @yellow_letter)); }
        elsif ($word{verify}[$c] eq "#"){ $abc{$letter[$c]} = BRIGHT_YELLOW . $letter[$c] if ( ! grep /^$letter[$c]$/, @green_letter);            push @yellow_letter, $letter[$c]; }
        elsif ($word{verify}[$c] eq "X"){ $abc{$letter[$c]} = BRIGHT_GREEN  . $letter[$c];                                                        push @green_letter,  $letter[$c]; }
        $c++;
    }
    delete($abc{' '});
    $string = join("", map { sprintf "%s", $abc{$_}; } sort(keys %abc));
    $result = sprintf BRIGHT_WHITE . " " . $string . RESET . BRIGHT_WHITE . " | " . RESET . BLACK . $result . RESET. BRIGHT_WHITE . " | " . RESET;
    return $result;
}
