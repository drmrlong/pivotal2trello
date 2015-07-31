#!/bin/env perl

use strict;
use warnings;
use v5.16;

use Text::CSV;
use Email::MIME;
use Email::Sender::Simple qw(sendmail);

#
# change these:
#
my $my_return_email = 'you@you.com';
my $trello_board_email = '';
my $dont_email = 0;
#
# also, be sure to set up labels in Trello, in advance
#

my $file = $ARGV[0] or die "Need to get CSV file on the command line\n";

unless ($trello_board_email) {
    $dont_email = 1;
    say "Setting dont_email since no trello_board_email was provided.\n";
}

my $csv = Text::CSV->new({ binary => 1, auto_diag => 1 });

open( my $fh, '<:encoding(utf8)', $file) or die "Could not open '$file': $!\n";
my $header_ary = $csv->getline($fh);
my $header;
my $i = 0;
for (@$header_ary) {
    $header->{$i++} = $_;
}
#::Dwarn $header;

while (my $fields = $csv->getline($fh)) {
    #::Dwarn $fields;
    my $i=0;
    my ($title, $estimate, $desc, $label, @tasks);
    for my $field (@$fields) {
        #next unless $field;
        #say 'doing: ' . $header->{$i} . ', for field: ' . $field;
        $title    = $field if $header->{$i} eq 'Title';
        $estimate = $field if $header->{$i} eq 'Estimate';
        $desc     = $field if $header->{$i} eq 'Description';
        if ($header->{$i} eq 'Labels') {
            $label = $field || '';
            if ($label) {
                my @labels = split /, ?/, $label;
                for (@labels) {
                    s/ - /-/g;
                    s/ /_/g;
                    s/^/\#/;
                }
                $label = join ' ', @labels;
            }
        }
        if ($header->{$i} eq 'Task' and $field) {
            push @tasks, $field;
        }
        $i++;
    }
    $desc ||= '';
    my $subject = $title .' '. $label;
    $subject =~ s/^\s+//;
    my $body = $desc;
    $body .= ("\n\nEstimate: " . $estimate) if $estimate;
    if (scalar @tasks) {
        $body .= "\n\nTasks:\n\n* ";
        $body .= join "\n* ", @tasks;
    }
    if ($dont_email) {
        say 'subject: ' . $subject;
        say 'body: ' . $body;
        say "\n---------\n";
    }
    unless ($dont_email) {
        my $message = Email::MIME->create(
            header_str => [
                From    => $my_return_email,
                To      => $trello_board_email,
                Subject => $subject,
            ],
            attributes => {
                encoding => 'quoted-printable',
                charset  => 'UTF-8',
            },
            body_str => $body . "\n",
        );
        print "Sending for: " . substr($subject,0,30) . "\n";
        sendmail($message);
    }
}

$csv->eof or $csv->error_diag();
close $fh;
