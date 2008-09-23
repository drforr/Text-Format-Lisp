use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Text::Format::Lisp',
    license             => 'perl',
    dist_author         => 'Jeffrey Goff <jgoff@cpan.org>',
    dist_version_from   => 'lib/Text/Format/Lisp.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'Text-Format-Lisp-*' ],
);

$builder->create_build_script();
