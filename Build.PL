use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'SFC::SFS',
    license             => 'artistic2',
    dist_author         => 'kotone <t11080hio@sfc.keio.ac.jp>',
    dist_version_from   => 'lib/SFC/SFS.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'SFC-SFS-*' ],
);

$builder->create_build_script();
