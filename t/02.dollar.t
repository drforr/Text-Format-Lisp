use strict;
use warnings;
use Test::More tests => 9;

BEGIN
  {
  use_ok
    (
    'Text::Format::Lisp',
    'Format'
    );
  }

ok( Format( undef, q{~$}, 0 ) eq q{0.00}, q{format.dollar.1} ); 

ok( Format( undef, q{~$}, undef ) eq q{NIL}, q{format.dollar.2} ); 

ok( Format( undef, q{~$}, q{foo} ) eq q{foo}, q{format.dollar.3} ); 

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
    unless ( ($format eq $string) and !$@ )
      {
      push @collected_failures, [ $value, $format, $@ ];
      }
    }
  use YAML; die Dump(\@collected_failures) if $DEBUG;
  ok( !@collected_failures, $test_name );
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
  );
#$DEBUG = 1;
test_formats( q{~$}, \@money, q{format.dollar.4} );
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
  );
#$DEBUG = 1;
test_formats( q{~@$}, \@money, q{format.dollar.5} );
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
  );
#$DEBUG = 1;
test_formats( q{~:$}, \@money, q{format.dollar.6} );
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
  );
#$DEBUG = 1;
test_formats( q{~@:$}, \@money, q{format.dollar.7} );
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
  );
#$DEBUG = 1;
test_formats( q{~:@$}, \@money, q{format.dollar.8} );
}
