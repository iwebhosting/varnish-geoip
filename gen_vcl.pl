#!/usr/bin/perl
#
# Generates the VCL file from geoip.c
#

use strict;
use warnings;

my @c_code = <STDIN>;
my @vcl_code;

READ_C: while (my $line = shift @c_code) {

    # Parse VCL ifdefs
    if ($line =~ m{^ \s* \#(ifn?def) \s+ __VCL__}mx) {
        #warn "\$1 = $1   \$line = $line\n";
        my $include = $1 eq 'ifdef' ? 1 : 0;
        IFDEF: while ($line = shift @c_code) {
            #warn "\tread_line $line\n";
            if ($line =~ m{^ \s* \#endif}mx) {
                last IFDEF;
            }
            elsif ($line =~ m{^ \s* \#else}mx) { 
                $include = 1 - $include;
            }
            push @vcl_code, $line if $include;
        }
        next;
    }

    push @vcl_code, $line;
}

@vcl_code = (
    "C{\n\n",
    "/* ------------------------------------------------------" . ("-" x length($0)) . " */\n",
    "/* THIS FILE IS AUTOMATICALLY GENERATED BY $0. DO NOT EDIT. */\n\n",
    @vcl_code,
    "\n/* THIS FILE IS AUTOMATICALLY GENERATED BY $0. DO NOT EDIT. */\n",
    "/* ------------------------------------------------------" . ("-" x length($0)) . " */\n",
    "}C\n",
);

print @vcl_code;

