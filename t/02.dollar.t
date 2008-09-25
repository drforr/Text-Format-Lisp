use Test::More tests => 2;

BEGIN
  {
  use_ok
    (
    'Text::Format::Lisp',
    'Format'
    );
  }

ok( Format( undef, q{~$}, 0 ) eq q{0.00}, q{format.dollar.1} ); 
