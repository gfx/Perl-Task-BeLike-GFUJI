#!perl -w
use strict;
use Fatal qw(open close);

my @requires = (
    'Standard and de facto standard' => [qw(
        Encode
        parent
        LWP
        DBI
        DBD::SQLite
        YAML
        YAML::XS
        JSON
        JSON::XS
        Module::CoreList
        Variable::Magic
        IPC::Run
    )],

    'CPAN' => [qw(
        CPAN
        CPAN::Mini
        Term::ReadKey
        Term::ReadLine
        Term::ReadLine::Perl
        Text::Glob
        File::Which
    )],
    
    'Development and testing' => [qw(
        Module::Build
        Module::Install
        Module::Install::XSUtil
        Module::Install::AuthorRequries
        Module::Install::AuthorTests
        Module::Install::Repository

        Test::More
        Test::LeakTrace
        Test::Base
        Test::Output
        Test::Exception
        Test::NoWarnings
        Test::Pod
        Test::Pod::Coverage
        Test::Synopsis
        Test::Deep
        Test::Perl::Critic

        Devel::Cover
        Devel::NYTProf

        Module::Setup
    )],

    'Release' => [qw(
        ShipIt
        ShipIt::Step::ChangeAllVersions
        ShipIt::Step::CheckVersionMatch
        CPAN::Uploader
    )],

    'Moose and Mouse' => [qw(
        Class::MOP
        Moose
            MooseX::Types
            MooseX::Types::Path::Class
            MooseX::Getopt
        Mouse
            MouseX::Types
            MouseX::Types::Path::Class
            MouseX::Getopt
        Any::Moose
        Any::Moose::Convert
    )],

    'Utility' => [qw(
        Data::Util
        PerlIO::Util
    )],

    'Web application' => [qw(
        PSGI
        Plack
        Plac::Request
        HTTP::Engine

        HTML::FillInForm::Lite
        Text::MicroTemplate
        Text::MicroTemplate::Extended
    )],

    'Data and database' => [qw(
        DBIx::Class

        Text::CSV
        Text::CSV_XS
        Spreadsheet::ParseExcel
        Spreadsheet::WriteExcel
     )],
);

open my $MakefilePL, '>', 'Makefile.PL';
open my $POD,        '>', 'lib/Task/BeLike/GFUJI.pod';

print $MakefilePL <<'PL';
use strict;
use warnings;
use inc::Module::Install;
all_from 'lib/Task/BeLike/GFUJI.pm';

PL

print $POD <<'POD';
=encoding utf8

=head1 NAME

Task::BeLike::GFUJI - GFUJI's favarite CPAN modules

=head1 CONTENTS

POD

while(my($caption, $modules) = splice @requires, 0, 2){
    print $caption, "\n";

    print $POD "=head2 $caption\n\n";

    foreach my $module(@{$modules}){
        my $info = get_module_info($module);
        print "    $module/$info->{version} - $info->{abstract}\n";

        print $MakefilePL "requires qw($module $info->{version});\n";

        print $POD        "=head2 $module $info->{version}\n\n";
        print $POD        $info->{abstract}, "\n\n";
    }
}

print $MakefilePL <<'PL';
auto_set_repository;
WriteAll(check_nmake => 0);
PL

print $POD <<'POD';

=head1 AUTHOR

Goro Fuji (gfx) E<lt>gfuji at cpan.orgE<gt>

=head1 COPYRIGHT AND LISENCE

Copyright (c) 2010, Goro Fuji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
POD

close $MakefilePL;
close $POD;

sub get_module_info{
    my($module) = @_;

    my $pm = $module.".pm";
    $pm =~ s{::}{/}g; # }

    my $fullpath;
    foreach my $path(@INC){
        if(-e "$path/$pm"){
            $fullpath = "$path/$pm";
        }
    }

    if(!$fullpath){
        return { version => 0, abstract => '' };
    }

    open my($fh), '<', $fullpath;

    my $version;
    my $abstract;

    while(<$fh>){
        if(!defined($version) && / \b VERSION \b \s* = [^;]+ ;/xms){
            my $VERSION;
            $version = eval($_) || 0;
        }

        if(!defined($abstract) && /^=head1 \s+ NAME \b/xms){
            while(<$fh>){
                if(/\S/){
                    $abstract = $_;
                    chomp $abstract;
                    $abstract =~ s/\Q$module\E \s* - \s*//xms;
                    last;
                }
            }
        }
    }

    close $fh;

    $fullpath =~ s/\.pm$/\.pod/;
    if(!defined($abstract) && -f $fullpath){
        open $fh, '<', $fullpath;
        while(<$fh>){
            if(/^=head1 \s+ NAME \b/xms){
                while(<$fh>){
                    if(/\S/){
                        $abstract = $_;
                        chomp $abstract;
                        $abstract =~ s/\Q$module\E \s* - \s*//xms;
                        last;
                    }
                }
            }
        }
    }
    $abstract ||= '';

    return { version => $version, abstract => $abstract };
}
