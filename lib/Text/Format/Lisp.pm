package Text::Format::Lisp;

use warnings;
use strict;
use Carp;
use Scalar::Util qw( looks_like_number );
use base qw( Exporter );

our @EXPORT_OK = qw( Format );

use version;
our $VERSION = qv('0.0.3');

=head2 Format($fh,$format,@params)

Does the nearest Perl equivalent of Lisp's (format) function. Along with some
random fun extensions.

=cut

sub Format
  {
  my ( $fh, $format, @args ) = @_;
  my $state = {};

  my $action =
    {
    q{A} => sub
      {
      if ( $state->{in_tilde} )
        {
        Carp::croak q{error in FORMAT: no more arguments} unless @args;
        }
      else
        {
        $state->{output} .= q{A};
        }
      },
    q{B} => sub
      {
      if ( $state->{in_tilde} )
        {
        Carp::croak q{error in FORMAT: no more arguments} unless @args;
        }
      else
        {
        $state->{output} .= q{B};
        }
      },
    q{f} => sub
      {
      if ( $state->{in_tilde} )
        {
        Carp::croak q{error in FORMAT: no more arguments} unless @args;
        }
      else
        {
        $state->{output} .= q{f};
        }
      },
    q{o} => sub
      {
      if ( $state->{in_tilde} )
        {
        Carp::croak q{error in FORMAT: no more arguments} unless @args;
        }
      else
        {
        $state->{output} .= q{o};
        }
      },
    q{0} => sub
      {
      if ( $state->{in_tilde} )
        {
        Carp::croak q{error in FORMAT: string ended before directive was found};
        }
      else
        {
        $state->{output} .= q{0};
        }
      },
    q{4} => sub
      {
      if ( $state->{in_tilde} )
        {
#        Carp::croak q{error in FORMAT: string ended before directive was found};
        $state->{argument} .= q{4};
        }
      else
        {
        $state->{output} .= q{0};
        }
      },
    q{~} => sub
      {
      if ( $state->{in_tilde} )
        {
        $state->{output} .= q{~};
        $state = undef;
        }
      else
        {
        $state->{in_tilde} = 1;
        }
      },
    q{@} => sub
      {
      if ( $state->{in_tilde} )
        {
        $state->{at_sign} = 1;
        }
      else
        {
        $state->{output} .= q{@};
        }
      },
    q{:} => sub
      {
      if ( $state->{in_tilde} )
        {
        $state->{colon} = 1;
        }
      else
        {
        $state->{output} .= q{:};
        }
      },
    q{$} => sub
      {
      if ( $state->{in_tilde} )
        {
        $state->{in_tilde} = undef;
        Carp::croak q{error in FORMAT: no more arguments} unless @args;
        my $arg = shift @args;
        if ( defined $arg )
          {
          if ( looks_like_number($arg) )
            {
            my $format_len = 2;
            if ( $state->{argument} )
              {
              $format_len = $state->{argument};
              }
            if ( $state->{at_sign} )
              {
              $state->{output} .= sprintf $arg >= 0 ? qq{+%.${format_len}f} : qq{%.${format_len}f}, $arg;
              }
            else 
              {
              $state->{output} .= sprintf qq{%.${format_len}f}, $arg;
              }
            }
          else
            {
            $state->{output} .= $arg;
            }
          }
        else
          {
          $state->{output} .= q{NIL};
          }
        }
      else
        {
        $state->{output} .= q{$};
        }
      },
    };

  for my $c ( split //, $format )
    {
    $action->{$c}->() if defined $action->{$c};
    }

  return $state->{output} if defined $state->{output};

  Carp::croak q{error in FORMAT: no corresponding close paren} if
    $format eq q{~)};
  Carp::croak q{error in FORMAT: no corresponding open paren} if
    $format eq q{~(};
  Carp::croak q{error in FORMAT: no corresponding close bracket} if
    $format eq q{~>};
  Carp::croak q{error in FORMAT: no corresponding open bracket} if
    $format eq q{~<};
  Carp::croak q{error in FORMAT: no corresponding close brace} if
    $format eq qq(~\x7d);
  Carp::croak q{error in FORMAT: no corresponding open brace} if
    $format eq qq(~\x7b);
  Carp::croak q{error in FORMAT: no matching closing slash} if
    $format eq q{~/};

  Carp::croak
    q{error in FORMAT: unknown format directive (character: Nul)} if
    $format eq qq{~\x00};
  Carp::croak
    q{error in FORMAT: unknown format directive (character: Soh)} if
    $format eq qq{~\x01};
  Carp::croak
    q{error in FORMAT: unknown format directive (character: Stx)} if
    $format eq qq{~\x02};
  Carp::croak
    q{error in FORMAT: unknown format directive (character: GRAVE_ACCENT)} if
    $format eq q{~`};
  Carp::croak
    q{error in FORMAT: unknown format directive (character: FULL_STOP)} if
    $format eq q{~.};
  Carp::croak
    q{error in FORMAT: unknown format directive (character: QUOTATION_MARK)} if
    $format eq q{~"};
  Carp::croak
    q{error in FORMAT: unknown format directive (character: EQUALS_SIGN)} if
    $format eq q{~=};
  Carp::croak q{error in FORMAT: unknown format directive (character: LATIN_CAPITAL_LETTER_Q)} if
    $format eq q{~Q};
  Carp::croak q{error in FORMAT: unknown format directive (character: EXCLAMATION_MARK)} if
    $format eq q{~!};
  Carp::croak q{error in FORMAT: unknown format directive (character: Space)} if
    $format eq q{~ };
  Carp::croak q{error in FORMAT: no more arguments} if
    $format eq q{~W} or
    $format eq q{~E} or
    $format eq q{~*};
  if ( $format eq q{~} or
       $format eq q{~@} or
       $format eq q{~#} or
       $format eq q{~'} or
       $format eq q{~,} or
       $format eq q{~-} or
       $format eq q{~+} or
       $format eq q{~:} or
       $format =~ m{~[0-9]} )
    {
    Carp::croak q{error in FORMAT: string ended before directive was found};
    }
  
  my $output = undef;
#  $output = $format;
if ( $format ) { $output = '~' }
else { $output = q{} }
  if ( $fh )
    {
    print $fh $output;
    }
  return $output;
  }

1; # Magic true value required at end of module
__END__

=head1 NAME

Text::Format::Lisp - [One line description of module's purpose here]


=head1 VERSION

This document describes Text::Format::Lisp version 0.0.1


=head1 SYNOPSIS

    use Text::Format::Lisp;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
Text::Format::Lisp requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-text-format-lisp@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Jeffrey Goff  C<< <jgoff@cpan.org> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Jeffrey Goff C<< <jgoff@cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
