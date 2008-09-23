use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Text::Format::Lisp',
    AUTHOR              => 'Jeffrey Goff <jgoff@cpan.org>',
    VERSION_FROM        => 'lib/Text/Format/Lisp.pm',
    ABSTRACT_FROM       => 'lib/Text/Format/Lisp.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Text-Format-Lisp-*' },
);
