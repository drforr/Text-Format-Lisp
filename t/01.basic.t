use strict;
use warnings;
use Test::More tests => 5;

BEGIN
  {
  use_ok
    (
    'Text::Format::Lisp',
    'Format'
    );
  }

ok( Format( undef, q{} ) eq q{}, q{format.nil.1} );

ok( Format( undef, q{0} ) eq q{0}, q{format.nil.2} );

ok( Format( undef, q{foo} ) eq q{foo}, q{format.nil.3} );

{
my @collected_failures;
my @directives =
  (
  qq{\x00} => q{unknown format directive (character: Nul)},
  qq{\x01} => q{unknown format directive (character: Soh)},
  qq{\x02} => q{unknown format directive (character: Stx)},
  q{`} => q{unknown format directive (character: GRAVE_ACCENT)},
  q{.} => q{unknown format directive (character: FULL_STOP)},
  q{"} => q{unknown format directive (character: QUOTATION_MARK)},
  q{=} => q{unknown format directive (character: EQUALS_SIGN)},
  q{Q} => q{unknown format directive (character: LATIN_CAPITAL_LETTER_Q)},
  q{!} => q{unknown format directive (character: EXCLAMATION_MARK)},
  q{ } => q{unknown format directive (character: Space)},
  q{0} => q{string ended before directive was found},
  q{@} => q{string ended before directive was found},
  q{#} => q{string ended before directive was found},
  q{'} => q{string ended before directive was found},
  q{,} => q{string ended before directive was found},
  q{+} => q{string ended before directive was found},
  q{-} => q{string ended before directive was found},
  q{:} => q{string ended before directive was found},
  q{$} => q{no more arguments},
  q{W} => q{no more arguments},
  q{E} => q{no more arguments},
  q{*} => q{no more arguments},
  q{)} => q{no corresponding close paren},
  q{(} => q{no corresponding open paren},
  q{>} => q{no corresponding close bracket},
  q{<} => q{no corresponding open bracket},
  qq(\x7d) => q{no corresponding close brace},
  qq(\x7b) => q{no corresponding open brace},
  q{/} => q{no matching closing slash},
  );
for ( my $i = 0; $i < @directives; $i += 2 )
  {
  my ( $value, $error ) = @directives[$i,$i+1];
  my $foo = quotemeta(q{error in FORMAT: } . $error);
  my $format;
  eval { $format = Format( undef, q{~} . $value ) };
  unless ( $@ and $@ =~ m{ $foo }mx )
    {
    push @collected_failures, [ $value, $error, $@ ];
    }
  }
#use YAML; die Dump(\@collected_failures);
ok( !@collected_failures, q{format.nil.error.4} );
}
