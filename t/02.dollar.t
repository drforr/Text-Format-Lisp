use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

use Test::More tests => 14;

BEGIN
  {
  use_ok
    (
    'Text::Format::Lisp',
    'Format'
    );
  }

my %seen = ();

sub _ok {
  my ( $test, $message ) = @_;
  die "Message '$message' duplicated!\n" if ++$seen{$message} > 1;
  return ok(@_);
}

_ok( Format( undef, q{~$}, 0 ) eq q{0.00}, q{format.dollar.1} ); 

_ok( Format( undef, q{~$}, undef ) eq q{NIL}, q{format.dollar.2} ); 

_ok( Format( undef, q{~$}, q{foo} ) eq q{foo}, q{format.dollar.3} ); 

_ok( Format( undef, q{A~$}, q{foo} ) eq q{Afoo}, q{format.dollar.4} ); 

_ok( Format( undef, q{A~$B}, q{foo} ) eq q{AfooB}, q{format.dollar.5} ); 

my $DEBUG = 0;

sub test_formats
  {
  my ( $format_str, $test_list, $test_name ) = @_;
  my @collected_failures;
  for ( my $i = 0; $i < @$test_list; $i += 2 )
    {
    my ( $value, $string ) = @{$test_list}[$i,$i+1];
    my $format;
    eval { $format = Format( undef, $format_str, $value ) };
    unless ( defined( $format ) and ($format eq $string) and !$@ )
      {
      push @collected_failures, [ $value, $format, $@ ];
      }
    }
  use YAML; die Dump(\@collected_failures) if $DEBUG;
  _ok( !@collected_failures, $test_name );
  }

{
my @money =
  (
  1 => q{1.00},
  -1 => q{-1.00},
  2.1 => q{2.10},
  30.25 => q{30.25},
  1.792 => q{1.79},
  -3.003 => q{-3.00},
  1234.0078 => q{1234.00},
  1234.5678 => q{1234.57},
  );
#$DEBUG = 1;
test_formats( q{~$}, \@money, q{format.dollar.6} );
}

{
my @money =
  (
  1 => q{[1.00]},
  -1 => q{[-1.00]},
  2.1 => q{[2.10]},
  30.25 => q{[30.25]},
  1.792 => q{[1.79]},
  -3.003 => q{[-3.00]},
  1234.0078 => q{[1234.00]},
  1234.5678 => q{[1234.57]},
  );
#$DEBUG = 1;
test_formats( q{[~$]}, \@money, q{format.dollar.7} );
}

{
my @collected_failures;
my @money =
  (
  1 => q{+1.00},
  -1 => q{-1.00},
  2.1 => q{+2.10},
  30.25 => q{+30.25},
  1.792 => q{+1.79},
  -3.003 => q{-3.00},
  1234.0078 => q{+1234.00},
  1234.5678 => q{+1234.57},
  );
#$DEBUG = 1;
test_formats( q{~@$}, \@money, q{format.dollar.8} );
}

{
my @money =
  (
  1 => q{1.00},
  -1 => q{-1.00},
  2.1 => q{2.10},
  30.25 => q{30.25},
  1.792 => q{1.79},
  -3.003 => q{-3.00},
  1234.0078 => q{1234.00},
  1234.5678 => q{1234.57},
  );
#$DEBUG = 1;
test_formats( q{~:$}, \@money, q{format.dollar.9} );
}

{
my @collected_failures;
my @money =
  (
  1 => q{+1.00},
  -1 => q{-1.00},
  2.1 => q{+2.10},
  30.25 => q{+30.25},
  1.792 => q{+1.79},
  -3.003 => q{-3.00},
  1234.0078 => q{+1234.00},
  1234.5678 => q{+1234.57},
  );
#$DEBUG = 1;
test_formats( q{~@:$}, \@money, q{format.dollar.10} );
}

{
my @collected_failures;
my @money =
  (
  1 => q{+1.00},
  -1 => q{-1.00},
  2.1 => q{+2.10},
  30.25 => q{+30.25},
  1.792 => q{+1.79},
  -3.003 => q{-3.00},
  1234.0078 => q{+1234.00},
  1234.5678 => q{+1234.57},
  );
#$DEBUG = 1;
test_formats( q{~:@$}, \@money, q{format.dollar.11} );
}

{
my @collected_failures;
my @money =
  (
  1 => q{+1.},
  -1 => q{-1.},
  2.1 => q{+2.},
  30.25 => q{+30.},
  1.792 => q{+1.},
  -3.003 => q{-3.},
  1234.0078 => q{+1234.},
  1234.5678 => q{+1234.},
  );
#$DEBUG = 1;
test_formats( q{~0$}, \@money, q{format.dollar.12} );
}

{
my @collected_failures;
my @money =
  (
  1 => q{+1.0000},
  -1 => q{-1.0000},
  2.1 => q{+2.1000},
  30.25 => q{+30.2500},
  1.792 => q{+1.7920},
  -3.003 => q{-3.0030},
  1234.0078 => q{+1234.0078},
  1234.5678 => q{+1234.5678},
  1234.567891 => q{+1234.5678},
  999.9999 => q{+999.9999},
  );
#$DEBUG = 1;
test_formats( q{~4$}, \@money, q{format.dollar.13} );
}
