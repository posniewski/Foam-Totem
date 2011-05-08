package Net::Twitter::Lite;
use 5.005;
use warnings;
use strict;

our $VERSION = '0.02000';
$VERSION = eval { $VERSION };

use Carp;
use URI::Escape;
use JSON::Any qw/XS DWIW JSON/;
use Net::Twitter::Lite::Error;

sub new {
    my ($class, %args) = @_;

    my $new = bless {
        apiurl     => 'http://twitter.com',
	$args{identica} ? ( apiurl => 'http://identi.ca/api' ) : (),
        searchurl  => 'http://search.twitter.com',
        useragent  => __PACKAGE__ . "/$VERSION (Perl)",
        clientname => __PACKAGE__,
        clientver  => $VERSION,
        clienturl  => 'http://search.cpan.org/dist/Net-Twitter-Lite/',
        source     => 'twitterpm',
        useragent_class => 'LWP::UserAgent',
        useragent_args  => {},
        %args
    }, $class;

    $new->{ua} ||= do {
        eval "use $new->{useragent_class}";
        croak $@ if $@;

        $new->{useragent_class}->new(%{$new->{useragent_args}});
    };

    $new->{ua}->agent($new->{useragent});
    $new->{ua}->default_header('X-Twitter-Client'         => $new->{clientname});
    $new->{ua}->default_header('X-Twitter-Client-Version' => $new->{clientver});
    $new->{ua}->default_header('X-Twitter-Client-URL'     => $new->{clienturl});
    $new->{ua}->env_proxy;

#    $new->{ua}->add_handler(request_prepare => sub {
#        if ( exists $new->{username} && exists $new->{password} ) {
#            shift->authorization_basic($new->{username}, $new->{password});
#        }
#    });

    return $new;
}

sub credentials {
    my $self = shift;

    croak "exected a username and password" unless @_ == 2;

    $self->{username} = shift;
    $self->{password} = shift;
}

my $api_def = [
    [ REST => [
        [ 'block_exists', {
            aliases     => [ qw// ],
            path        => 'blocks/exists/id',
            method      => 'GET',
            params      => [ qw/id user_id screen_name/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'blocking', {
            aliases     => [ qw// ],
            path        => 'blocks/blocking',
            method      => 'GET',
            params      => [ qw/page/ ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'blocking_ids', {
            aliases     => [ qw// ],
            path        => 'blocks/blocking/ids',
            method      => 'GET',
            params      => [ qw// ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'create_block', {
            aliases     => [ qw// ],
            path        => 'blocks/create/id',
            method      => 'POST',
            params      => [ qw/id/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'create_favorite', {
            aliases     => [ qw// ],
            path        => 'favorites/create/id',
            method      => 'POST',
            params      => [ qw/id/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'create_friend', {
            aliases     => [ qw/follow_new/ ],
            path        => 'friendships/create/id',
            method      => 'POST',
            params      => [ qw/id user_id screen_name follow/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'create_saved_search', {
            aliases     => [ qw// ],
            path        => 'saved_searches/create',
            method      => 'POST',
            params      => [ qw/query/ ],
            required    => [ qw/query/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'destroy_block', {
            aliases     => [ qw// ],
            path        => 'blocks/destroy/id',
            method      => 'POST',
            params      => [ qw/id/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'destroy_direct_message', {
            aliases     => [ qw// ],
            path        => 'direct_messages/destroy/id',
            method      => 'POST',
            params      => [ qw/id/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'destroy_favorite', {
            aliases     => [ qw// ],
            path        => 'favorites/destroy/id',
            method      => 'POST',
            params      => [ qw/id/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'destroy_friend', {
            aliases     => [ qw/unfollow/ ],
            path        => 'friendships/destroy/id',
            method      => 'POST',
            params      => [ qw/id user_id screen_name/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'destroy_saved_search', {
            aliases     => [ qw// ],
            path        => 'saved_searches/destroy/id',
            method      => 'POST',
            params      => [ qw/id/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'destroy_status', {
            aliases     => [ qw// ],
            path        => 'statuses/destroy/id',
            method      => 'POST',
            params      => [ qw/id/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'direct_messages', {
            aliases     => [ qw// ],
            path        => 'direct_messages',
            method      => 'GET',
            params      => [ qw/since_id max_id count page/ ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'disable_notifications', {
            aliases     => [ qw// ],
            path        => 'notifications/leave/id',
            method      => 'POST',
            params      => [ qw/id/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'downtime_schedule', {
            aliases     => [ qw// ],
            path        => 'help/downtime_schedule',
            method      => 'GET',
            params      => [ qw// ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 1,
        } ],
        [ 'enable_notifications', {
            aliases     => [ qw// ],
            path        => 'notifications/follow/id',
            method      => 'POST',
            params      => [ qw/id/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'end_session', {
            aliases     => [ qw// ],
            path        => 'account/end_session',
            method      => 'POST',
            params      => [ qw// ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'favorites', {
            aliases     => [ qw// ],
            path        => 'favorites/id',
            method      => 'GET',
            params      => [ qw/id page/ ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'followers', {
            aliases     => [ qw// ],
            path        => 'statuses/followers/id',
            method      => 'GET',
            params      => [ qw/id user_id screen_name page/ ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'followers_ids', {
            aliases     => [ qw// ],
            path        => 'followers/ids/id',
            method      => 'GET',
            params      => [ qw/id user_id screen_name page/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'friends', {
            aliases     => [ qw/following/ ],
            path        => 'statuses/friends/id',
            method      => 'GET',
            params      => [ qw/id user_id screen_name page/ ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'friends_ids', {
            aliases     => [ qw/following_ids/ ],
            path        => 'friends/ids/id',
            method      => 'GET',
            params      => [ qw/id user_id screen_name page/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'friends_timeline', {
            aliases     => [ qw/following_timeline/ ],
            path        => 'statuses/friends_timeline',
            method      => 'GET',
            params      => [ qw/since_id max_id count page/ ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'friendship_exists', {
            aliases     => [ qw/relationship_exists follows/ ],
            path        => 'friendships/exists',
            method      => 'GET',
            params      => [ qw/user_a user_b/ ],
            required    => [ qw/user_a user_b/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'mentions', {
            aliases     => [ qw/replies/ ],
            path        => 'statuses/replies',
            method      => 'GET',
            params      => [ qw/since_id max_id count page/ ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'new_direct_message', {
            aliases     => [ qw// ],
            path        => 'direct_messages/new',
            method      => 'POST',
            params      => [ qw/user text/ ],
            required    => [ qw/user text/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'public_timeline', {
            aliases     => [ qw// ],
            path        => 'statuses/public_timeline',
            method      => 'GET',
            params      => [ qw// ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'rate_limit_status', {
            aliases     => [ qw// ],
            path        => 'account/rate_limit_status',
            method      => 'GET',
            params      => [ qw// ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'saved_searches', {
            aliases     => [ qw// ],
            path        => 'saved_searches',
            method      => 'GET',
            params      => [ qw// ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'sent_direct_messages', {
            aliases     => [ qw// ],
            path        => 'direct_messages/sent',
            method      => 'GET',
            params      => [ qw/since_id max_id page/ ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'show_saved_search', {
            aliases     => [ qw// ],
            path        => 'saved_searches/show/id',
            method      => 'GET',
            params      => [ qw/id/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'show_status', {
            aliases     => [ qw// ],
            path        => 'statuses/show/id',
            method      => 'GET',
            params      => [ qw/id/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'show_user', {
            aliases     => [ qw// ],
            path        => 'users/show/id',
            method      => 'GET',
            params      => [ qw/id/ ],
            required    => [ qw/id/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'test', {
            aliases     => [ qw// ],
            path        => 'help/test',
            method      => 'GET',
            params      => [ qw// ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'update', {
            aliases     => [ qw// ],
            path        => 'statuses/update',
            method      => 'POST',
            params      => [ qw/status in_reply_to_status_id/ ],
            required    => [ qw/status/ ],
            add_source  => 1,
            deprecated  => 0,
        } ],
        [ 'update_delivery_device', {
            aliases     => [ qw// ],
            path        => 'account/update_delivery_device',
            method      => 'POST',
            params      => [ qw/device/ ],
            required    => [ qw/device/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'update_location', {
            aliases     => [ qw// ],
            path        => 'account/update_location',
            method      => 'POST',
            params      => [ qw/location/ ],
            required    => [ qw/location/ ],
            add_source  => 0,
            deprecated  => 1,
        } ],
        [ 'update_profile', {
            aliases     => [ qw// ],
            path        => 'account/update_profile',
            method      => 'POST',
            params      => [ qw/name email url location description/ ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'update_profile_background_image', {
            aliases     => [ qw// ],
            path        => 'account/update_profile_background_image',
            method      => 'POST',
            params      => [ qw/image/ ],
            required    => [ qw/image/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'update_profile_colors', {
            aliases     => [ qw// ],
            path        => 'account/update_profile_colors',
            method      => 'POST',
            params      => [ qw/profile_background_color profile_text_color profile_link_color profile_sidebar_fill_color profile_sidebar_border_color/ ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'update_profile_image', {
            aliases     => [ qw// ],
            path        => 'account/update_profile_image',
            method      => 'POST',
            params      => [ qw/image/ ],
            required    => [ qw/image/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'user_timeline', {
            aliases     => [ qw// ],
            path        => 'statuses/user_timeline/id',
            method      => 'GET',
            params      => [ qw/id user_id screen_name since_id max_id count page/ ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'verify_credentials', {
            aliases     => [ qw// ],
            path        => 'account/verify_credentials',
            method      => 'GET',
            params      => [ qw// ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
    ] ],
    [ Search => [
        [ 'search', {
            aliases     => [ qw// ],
            path        => 'search',
            method      => 'GET',
            params      => [ qw/q callback lang rpp page since_id geocode show_user/ ],
            required    => [ qw/q/ ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'trends', {
            aliases     => [ qw// ],
            path        => 'trends',
            method      => 'GET',
            params      => [ qw// ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'trends_current', {
            aliases     => [ qw// ],
            path        => 'trends/current',
            method      => 'GET',
            params      => [ qw/exclude/ ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'trends_daily', {
            aliases     => [ qw// ],
            path        => 'trends/daily',
            method      => 'GET',
            params      => [ qw/date exclude/ ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
        [ 'trends_weekly', {
            aliases     => [ qw// ],
            path        => 'trends/weekly',
            method      => 'GET',
            params      => [ qw/date exclude/ ],
            required    => [ qw// ],
            add_source  => 0,
            deprecated  => 0,
        } ],
    ] ],
];

my $post_request = sub {
    my ($ua, $uri, $args) = @_;
    return $ua->post($uri, $args);
};

my $get_request = sub {
    my ($ua, $uri, $args) = @_;
    $uri->query_form($args);
    return $ua->get($uri);
};

my $with_url_arg = sub {
    my ($path, $args) = @_;

    if ( defined(my $id = delete $args->{id}) ) {
        $path .= uri_escape($id);
    }
    else {
        chop($path);
    }
    return $path;
};

while ( @$api_def ) {
    my $api = shift @$api_def;
    my $api_name = shift @$api;
    my $methods = shift @$api;

    my $url_attr = $api_name eq 'REST' ? 'apiurl' : 'searchurl';

    my $base_url = sub { shift->{$url_attr} };

    for my $method ( @$methods ) {
        my $name    = shift @$method;
        my %options = %{ shift @$method };

        my ($arg_names, $path) = @options{qw/required path/};
        $arg_names = $options{params} if @$arg_names == 0 && @{$options{params}} == 1;
        my $request = $options{method} eq 'POST' ? $post_request : $get_request;

        my $modify_path = $path =~ s,/id$,/, ? $with_url_arg : sub { $_[0] };

        my $code = sub {
            my $self = shift;

            # copy callers args since we may add ->{source}
            my $args = ref $_[-1] eq 'HASH' ? { %{pop @_} } : {};

            if ( @_ ) {
                ref $_[$_] && croak "arg $_ must not be a reference" for 0..$#_;
                @_ == @$arg_names || croak "$name expected @{[ scalar @$arg_names ]} args";
                @{$args}{@$arg_names} = @_;
            }
            $args->{source} ||= $self->{source} if $options{add_source};

            my $local_path = $modify_path->($path, $args);

            my $uri = URI->new($base_url->($self) . "/$local_path.json");

            # upgrade params to UTF-8 so latin-1 literals can be handled as UTF-8 too
            utf8::upgrade $_ for values %$args;

            return $self->_parse_result($request->($self->{ua}, $uri, $args));
        };

        no strict 'refs';
        *{__PACKAGE__ . "::$_"} = $code for $name, @{$options{aliases}};
    }
}

sub _from_json {
    my ($self, $json) = @_;

    return eval { JSON::Any->from_json($json) };
}

sub _parse_result {
    my ($self, $res) = @_;

    # workaround for Laconica API returning bools as strings
    # (Fixed in Laconi.ca 0.7.4)
    my $content = $res->content;
    $content =~ s/^"(true|false)"$/$1/;

    # some JSON backends don't handle booleans correctly
    # TODO: move this fix to JSON::Any
    my $obj = $content eq 'true'  ? 1
            : $content eq 'false' ? ''
            : $self->_from_json($content);

    # Twitter sometimes returns an error with status code 200
    if ( $obj && ref $obj eq 'HASH' && exists $obj->{error} ) {
        die Net::Twitter::Lite::Error->new(twitter_error => $obj, http_response => $res);
    }

    return $obj if $res->is_success && defined $obj;

    my $error = Net::Twitter::Lite::Error->new(http_response => $res);
    $error->twitter_error($obj) if ref $obj;

    die $error;
}

1;

=head1 NAME

Net::Twitter::Lite - A perl interface to the Twitter API

=head1 VERSION

This document describes Net::Twitter::Lite version 0.02000

=head1 SYNOPSIS

  use Net::Twitter::Lite;

  my $nt = Net::Twitter::Lite->new(
      username => $user,
      password => $password
  );

  my $result = eval { $nt->update('Hello, world!') };

  eval {
      my $statuses = $nt->friends_timeline({ since_id => $high_water, count => 100 });
      for my $status ( @$statuses ) {
          print "$status->{time} <$status->{user}{screen_name}> $status->{text}\n";
      }
  };
  warn "$@\n" if $@;


=head1 DESCRIPTION

This module provides a perl interface to the Twitter APIs. It uses the same API definitions
as L<Net::Twitter>, but without the extra bells and whistles and without the additional dependencies.
Same great taste, less filling.


This module is related to, but is not part of the C<Net::Twitter>
distribution.  It's API methods and API method documentation are generated
from C<Net::Twitter>'s internals.  It exists for those who cannot, or prefer
not to install L<Moose> and its dependencies.

You should consider upgrading to C<Net::Twitter> for additional functionality,
finer grained control over features, full backwards compatibility with older
versions of C<Net::Twitter>, and additional error handling options.

=head1 MIGRATING FROM NET::TWITTER 2.x

If you are migrating from Net::Twitter 2.12 (or an earlier version), you may
need to make some minor changes to your application code in order to user
Net::Twitter::Lite successfully.

The primary difference is in error handling.  Net::Twitter::Lite throws
exceptions on error.  It does not support the C<get_error>, C<http_code>, and
C<http_message> methods used in Net::Twitter 2.12 and prior versions.

Instead of

  # DON'T!
  my $friends = $nt->friends();
  if ( $friends ) {
      # process $friends
  }

wrap the API call in an eval block:

  # DO!
  my $friends = eval { $nt->friends() };
  if ( $friends ) {
      # process $friends
  }

Here's a much more complex example taken from application code using
Net::Twitter 2.12:

  # DON'T!
  my $friends = $nt->friends();
  if ( $friends ) {
      # process $friends
  }
  else {
      my $error = $nt->get_error;
      if ( ref $error ) {
          if ( ref($error) eq 'HASH' && exists $error->{error} ) {
	          $error = $error->{error};
          }
          else {
	          $error = 'Unexpected error type ' . ref($error);
          }
      }
      else {
          $error = $nt->http_code() . ": " . $nt->http_message;
      }
      warn "$error\n";
  }

The Net::Twitter::Lite equivalent is:

  # DO!
  eval {
      my $friends = $nt->friends();
      # process $friends
  };
  warn "$@\n" if $@;
  return;

In Net::Twitter::Lite, an error can always be treated as a string.  See
L<Net::Twitter::Lite::Error>.  The HTTP Status Code and HTTP Message are both
available.  Rather than accessing them via the Net::Twitter::Lite instance,
you access them via the Net::Twitter::Lite::Error instance thrown as an error.

For example:

  # DO!
  eval {
     my $friends = $nt->friends();
     # process $friends
  };
  if ( my $error = $@ ) {
      if ( blessed $error && $error->isa("Net::Twitter::Lite::Error)
           && $error->code() == 502 ) {
          $error = "Fail Whale!";
      }
      warn "$error\n";
  }

=head2 Unsupported Net::Twitter 2.12 options to C<new>

Net::Twitter::Lite does not support the following Net::Twitter 2.12 options to
C<new>.  It silently ignores them:

=over 4

=item no_fallback

If Net::Twitter::Lite is unable to create an instance of the class specified in
the C<useragent_class> option to C<new>, it dies, rather than falling back to
an LWP::UserAgent object.  You really don't want a failure to create the
C<useragent_class> you specified to go unnoticed.

=item twittervision

Net::Twitter::Lite does not support the TwitterVision API.  Use Net::Twitter,
instead, if you need it.

=item skip_arg_validation

Net::Twitter::Lite does not API parameter validation.  This is a feature.  If
Twitter adds a new option to an API method, you can use it immediately by
passing it in the HASH ref to the API call.

Net::Twitter::Lite relies on Twitter to validate its own parameters.  An
appropriate exception will be thrown if Twitter reports a parameter error.

=item die_on_validation

See L</skip_arg_validation>.  If Twitter returns an bad parameter error, an
appropriate exception will be thrown.

=item arrayref_on_error

This option allowed the following idiom in Net::Twitter 2.12:

  # DON'T!
  for my $friend ( @{ $nt->friends() } ) {
     # process $friend
  }

The equivalent Net::Twitter::Lite code is:

  # DO!
  eval {
      for my $friend ( @{ $nt->friends() } ) {
          # process $friend
      }
  };

=back

=head2 Unsupported Net::Twitter 2.12 methods

=over 4

=item clone

The C<clone> method was added to Net::Twitter 2.x to allow safe error handling
in an environment where concurrent requests are handled, for example, when
using LWP::UserAgent::POE as the C<useragent_class>.  Since Net::Twitter::Lite
throws exceptions instead of stashing them in the Net::Twitter::Lite instance,
it is safe in a current request environment, obviating the need for C<clone>.

=item get_error

=item http_code

=item http_message

These methods are replaced by Net::Twitter::Lite::Error.  An instance of that
class is thrown errors are encountered.

=back

=head1 METHODS AND ARGUMENTS

=over 4

=item new

This constructs a C<Net::Twitter::Lite> object.  It takes several named parameters,
all of them optional:

=over 4

=item username

This is the screen name or email used to authenticate with Twitter.

=item password

This is the password used to authenticate with Twitter.

=item clientname

The value for the C<X-Twitter-Client-Name> HTTP header. It defaults to "Perl
Net::Twitter::Lite".

=item clientver

The value for the C<X-Twitter-Client-Version> HTTP header. It defaults to
current version of the C<Net::Twitter::Lite> module.

=item clienturl

The value for the C<X-Twitter-Client-URL> HTTP header. It defaults to the
search.cpan.org page for the C<Net::Twitter::Lite> distribution.

=item useragent_class

The C<LWP::UserAgent> compatible class used internally by C<Net::Twitter::Lite>.  It
defaults to "LWP::UserAgent".  For L<POE> based applications, consider using
"LWP::UserAgent::POE".

=item useragent_args

An HASH ref of arguments to pass to constructor of the class specified with
C<useragent_class>, above.  It defaults to {} (an empty HASH ref).

=item useragent

The value for C<User-Agent> HTTP header.  It defaults to
"Net::Twitter::Lite/0.02000 (Perl)".

=item source

The value used in the C<source> parameter of API method calls. It is currently
only used in the C<update> method in the REST API.  It defaults to
"twitterpm".  This results in the text "from Net::Twitter" rather than "from
web" for status messages posted from C<Net::Twitter::Lite> when displayed via the
Twitter web interface.  The value for this parameter is provided by Twitter
when a Twitter application is registered.  See
L<http://apiwiki.twitter.com/FAQ#HowdoIget%E2%80%9CfromMyApp%E2%80%9DappendedtoupdatessentfrommyAPIapplication>.

=item apiurl

The URL for the Twitter API. This defaults to "http://twitter.com".

=item identica

If set to 1 (or any value that evaluates to true), apiurl defaults to
"http://identi.ca/api".

=back

=item credentials($username, $password)

Set the credentials for Basic Authentication.  This is helpful for managing
multiple accounts.

=back

=head1 API METHODS AND ARGUMENTS

Most Twitter API methods take parameters.  All Net::Twitter::Lite API
methods will accept a HASH ref of named parameters as specified in the Twitter
API documentation.  For convenience, many Net::Twitter::Lite methods accept
simple positional arguments as documented, below.  The positional parameter
passing style is optional; you can always use the named parameters in a hash
ref if you prefer.

For example, the REST API method C<update> has one required parameter,
C<status>.  You can call C<update> with a HASH ref argument:

    $nt->update({ status => 'Hello world!' });

Or, you can use the convenient form:

    $nt->update('Hello world!');

The C<update> method also has an optional parameter, C<in_reply_to_status_id>.
To use it, you B<must> use the HASH ref form:

    $nt->update({ status => 'Hello world!', in_reply_to_status_id => $reply_to });

Convenience form is provided for the required parameters of all API methods.
So, these two calls are equivalent:

    $nt->friendship_exists({ user_a => $fred, user_b => $barney });
    $nt->friendship_exists($fred, $barney);

Many API methods have aliases.  You can use the API method name, or any of its
aliases, as you prefer.  For example, these calls are all equivalent:

    $nt->friendship_exists($fred, $barney);
    $nt->relationship_exists($fred, $barney);
    $nt->follows($fred, $barney);

Aliases support both the HASH ref and convenient forms:

    $nt->follows({ user_a => $fred, user_b => $barney });

Methods that support the C<page> parameter expect page numbers E<gt> 0.  Twitter silently
ignores invalid C<page> values.  So C<< { page => 0 } >> produces the same result
as C<< { page => 1 } >>.

=head1 REST API Methods

Several of these methods accept a user ID as the C<id> parameter.  The user ID
can be either a screen name, or the users numeric ID.  To disambiguate, use
the C<screen_name> or C<user_id> parameters, instead.

For example, These calls are equivalent:

    $nt->create_friend('net_twitter'); # screen name
    $nt->create_friend(1564061);       # numeric ID
    $nt->create_friend({ id => 'net_twitter' });
    $nt->create_friend({ screen_name => 'net_twitter' });
    $nt->create_friend({ user_id     => 1564061 });

However user_id 911 and screen_name 911 are separate Twitter accounts.  These
calls are NOT equivalent:

    $nt->create_friend(911); # interpreted as screen name
    $nt->create_friend({ user_id => 911 }); # screen name: richellis

Whenever the C<id> parameter is required and C<user_id> and C<screen_name> are
also parameters, using any one of them satisfies the requirement.



=over 4

=item B<block_exists>

=item B<block_exists(id)>



=over 4

=item Parameters: id, user_id, screen_name

=item Required: id

=back

Returns if the authenticating user is blocking a target user. Will return the blocked user's
object if a block exists, and error with HTTP 404 response code otherwise.


Returns: BasicUser

=item B<blocking>

=item B<blocking(page)>



=over 4

=item Parameters: page

=item Required: I<none>

=back

Returns an array of user objects that the authenticating user is blocking.


Returns: ArrayRef[BasicUser]

=item B<blocking_ids>



=over 4

=item Parameters: I<none>

=item Required: I<none>

=back

Returns an array of numeric user ids the authenticating user is blocking.


Returns: ArrayRef[Int]

=item B<create_block>

=item B<create_block(id)>



=over 4

=item Parameters: id

=item Required: id

=back

Blocks the user specified in the ID parameter as the authenticating user.
Returns the blocked user when successful.  You can find out more about
blocking in the Twitter Support Knowledge Base.


Returns: BasicUser

=item B<create_favorite>

=item B<create_favorite(id)>



=over 4

=item Parameters: id

=item Required: id

=back

Favorites the status specified in the ID parameter as the
authenticating user.  Returns the favorite status when successful.


Returns: Status

=item B<create_friend>

=item B<create_friend(id)>


=item alias: follow_new


=over 4

=item Parameters: id, user_id, screen_name, follow

=item Required: id

=back

Befriends the user specified in the ID parameter as the authenticating user.
Returns the befriended user when successful.  Returns a string describing the
failure condition when unsuccessful.


Returns: BasicUser

=item B<create_saved_search>

=item B<create_saved_search(query)>



=over 4

=item Parameters: query

=item Required: query

=back

Creates a saved search for the authenticated user.


Returns: SavedSearch

=item B<destroy_block>

=item B<destroy_block(id)>



=over 4

=item Parameters: id

=item Required: id

=back

Un-blocks the user specified in the ID parameter as the authenticating user.
Returns the un-blocked user when successful.


Returns: BasicUser

=item B<destroy_direct_message>

=item B<destroy_direct_message(id)>



=over 4

=item Parameters: id

=item Required: id

=back

Destroys the direct message specified in the required ID parameter.
The authenticating user must be the recipient of the specified direct
message.


Returns: DirectMessage

=item B<destroy_favorite>

=item B<destroy_favorite(id)>



=over 4

=item Parameters: id

=item Required: id

=back

Un-favorites the status specified in the ID parameter as the
authenticating user.  Returns the un-favorited status.


Returns: Status

=item B<destroy_friend>

=item B<destroy_friend(id)>


=item alias: unfollow


=over 4

=item Parameters: id, user_id, screen_name

=item Required: id

=back

Discontinues friendship with the user specified in the ID parameter as the
authenticating user.  Returns the un-friended user when successful.
Returns a string describing the failure condition when unsuccessful.


Returns: BasicUser

=item B<destroy_saved_search>

=item B<destroy_saved_search(id)>



=over 4

=item Parameters: id

=item Required: id

=back

Destroys a saved search. The search, specified by C<id>, must be owned
by the authenticating user.


Returns: SavedSearch

=item B<destroy_status>

=item B<destroy_status(id)>



=over 4

=item Parameters: id

=item Required: id

=back

Destroys the status specified by the required ID parameter.  The
authenticating user must be the author of the specified status.


Returns: Status

=item B<direct_messages>



=over 4

=item Parameters: since_id, max_id, count, page

=item Required: I<none>

=back

Returns a list of the 20 most recent direct messages sent to the authenticating
user including detailed information about the sending and recipient users.


Returns: ArrayRef[DirectMessage]

=item B<disable_notifications>

=item B<disable_notifications(id)>



=over 4

=item Parameters: id

=item Required: id

=back

Disables notifications for updates from the specified user to the
authenticating user.  Returns the specified user when successful.


Returns: BasicUser

=item B<enable_notifications>

=item B<enable_notifications(id)>



=over 4

=item Parameters: id

=item Required: id

=back

Enables notifications for updates from the specified user to the
authenticating user.  Returns the specified user when successful.


Returns: BasicUser

=item B<end_session>



=over 4

=item Parameters: I<none>

=item Required: I<none>

=back

Ends the session of the authenticating user, returning a null cookie.
Use this method to sign users out of client-facing applications like
widgets.


Returns: Error

=item B<favorites>



=over 4

=item Parameters: id, page

=item Required: I<none>

=back

Returns the 20 most recent favorite statuses for the authenticating
user or user specified by the ID parameter.


Returns: ArrayRef[Status]

=item B<followers>



=over 4

=item Parameters: id, user_id, screen_name, page

=item Required: I<none>

=back

Returns the authenticating user's followers, each with current status
inline.  They are ordered by the order in which they joined Twitter
(this is going to be changed).

Returns 100 followers per page.


Returns: ArrayRef[BasicUser]

=item B<followers_ids>

=item B<followers_ids(id)>



=over 4

=item Parameters: id, user_id, screen_name, page

=item Required: id

=back

Returns an array of numeric IDs for every user is followed by.


Returns: ArrayRef[Int]

=item B<friends>


=item alias: following


=over 4

=item Parameters: id, user_id, screen_name, page

=item Required: I<none>

=back

Returns the authenticating user's friends, each with current status
inline. They are ordered by the order in which they were added as
friends. It's also possible to request another user's recent friends
list via the id parameter.

Returns 100 friends per page.


Returns: ArrayRef[BasicUser]

=item B<friends_ids>

=item B<friends_ids(id)>


=item alias: following_ids


=over 4

=item Parameters: id, user_id, screen_name, page

=item Required: id

=back

Returns an array of numeric IDs for every user the specified user is following.

Currently, Twitter returns IDs ordered from most recently followed to least
recently followed.  This order may change at any time.


Returns: ArrayRef[Int]

=item B<friends_timeline>


=item alias: following_timeline


=over 4

=item Parameters: since_id, max_id, count, page

=item Required: I<none>

=back

Returns the 20 most recent statuses posted by the authenticating user
and that user's friends. This is the equivalent of /home on the Web.


Returns: ArrayRef[Status]

=item B<friendship_exists>

=item B<friendship_exists(user_a, user_b)>


=item alias: relationship_exists

=item alias: follows


=over 4

=item Parameters: user_a, user_b

=item Required: user_a, user_b

=back

Tests for the existence of friendship between two users. Will return true if
user_a follows user_b, otherwise will return false.


Returns: Bool

=item B<mentions>


=item alias: replies


=over 4

=item Parameters: since_id, max_id, count, page

=item Required: I<none>

=back

Returns the 20 most recent mentions (statuses containing @username) for the
authenticating user.


Returns: ArrayRef[Status]

=item B<new_direct_message>

=item B<new_direct_message(user, text)>



=over 4

=item Parameters: user, text

=item Required: user, text

=back

Sends a new direct message to the specified user from the authenticating user.
Requires both the user and text parameters.  Returns the sent message when
successful.


Returns: DirectMessage

=item B<public_timeline>



=over 4

=item Parameters: I<none>

=item Required: I<none>

=back

Returns the 20 most recent statuses from non-protected users who have
set a custom user icon.  Does not require authentication.  Note that
the public timeline is cached for 60 seconds so requesting it more
often than that is a waste of resources.


Returns: ArrayRef[Status]

=item B<rate_limit_status>



=over 4

=item Parameters: I<none>

=item Required: I<none>

=back

Returns the remaining number of API requests available to the
requesting user before the API limit is reached for the current hour.
Calls to rate_limit_status do not count against the rate limit.  If
authentication credentials are provided, the rate limit status for the
authenticating user is returned.  Otherwise, the rate limit status for
the requester's IP address is returned.


Returns: RateLimitStatus

=item B<saved_searches>



=over 4

=item Parameters: I<none>

=item Required: I<none>

=back

Returns the authenticated user's saved search queries.


Returns: ArrayRef[SavedSearch]

=item B<sent_direct_messages>



=over 4

=item Parameters: since_id, max_id, page

=item Required: I<none>

=back

Returns a list of the 20 most recent direct messages sent by the authenticating
user including detailed information about the sending and recipient users.


Returns: ArrayRef[DirectMessage]

=item B<show_saved_search>

=item B<show_saved_search(id)>



=over 4

=item Parameters: id

=item Required: id

=back

Retrieve the data for a saved search, by ID, owned by the authenticating user.


Returns: SavedSearch

=item B<show_status>

=item B<show_status(id)>



=over 4

=item Parameters: id

=item Required: id

=back

Returns a single status, specified by the id parameter.  The
status's author will be returned inline.


Returns: Status

=item B<show_user>

=item B<show_user(id)>



=over 4

=item Parameters: id

=item Required: id

=back

Returns extended information of a given user, specified by ID or screen
name as per the required id parameter.  This information includes
design settings, so third party developers can theme their widgets
according to a given user's preferences. You must be properly
authenticated to request the page of a protected user.


Returns: ExtendedUser

=item B<test>



=over 4

=item Parameters: I<none>

=item Required: I<none>

=back

Returns the string "ok" status code.


Returns: Str

=item B<update>

=item B<update(status)>



=over 4

=item Parameters: status, in_reply_to_status_id

=item Required: status

=back

Updates the authenticating user's status.  Requires the status parameter
specified.  A status update with text identical to the authenticating
user's current status will be ignored.


Returns: Status

=item B<update_delivery_device>

=item B<update_delivery_device(device)>



=over 4

=item Parameters: device

=item Required: device

=back

Sets which device Twitter delivers updates to for the authenticating
user.  Sending none as the device parameter will disable IM or SMS
updates.


Returns: BasicUser

=item B<update_profile>



=over 4

=item Parameters: name, email, url, location, description

=item Required: I<none>

=back

Sets values that users are able to set under the "Account" tab of their
settings page. Only the parameters specified will be updated; to only
update the "name" attribute, for example, only include that parameter
in your request.


Returns: ExtendedUser

=item B<update_profile_background_image>

=item B<update_profile_background_image(image)>



=over 4

=item Parameters: image

=item Required: image

=back

Updates the authenticating user's profile background image.  Expects
raw multipart data, not a URL to an image.


Returns: ExtendedUser

=item B<update_profile_colors>



=over 4

=item Parameters: profile_background_color, profile_text_color, profile_link_color, profile_sidebar_fill_color, profile_sidebar_border_color

=item Required: I<none>

=back

Sets one or more hex values that control the color scheme of the
authenticating user's profile page on twitter.com.  These values are
also returned in the /users/show API method.


Returns: ExtendedUser

=item B<update_profile_image>

=item B<update_profile_image(image)>



=over 4

=item Parameters: image

=item Required: image

=back

Updates the authenticating user's profile image.  Expects raw multipart
data, not a URL to an image.


Returns: ExtendedUser

=item B<user_timeline>



=over 4

=item Parameters: id, user_id, screen_name, since_id, max_id, count, page

=item Required: I<none>

=back

Returns the 20 most recent statuses posted from the authenticating
user. It's also possible to request another user's timeline via the id
parameter. This is the equivalent of the Web /archive page for
your own user, or the profile page for a third party.


Returns: ArrayRef[Status]

=item B<verify_credentials>



=over 4

=item Parameters: I<none>

=item Required: I<none>

=back

Returns an HTTP 200 OK response code and a representation of the
requesting user if authentication was successful; returns a 401 status
code and an error message if not.  Use this method to test if supplied
user credentials are valid.


Returns: ExtendedUser


=back



=head1 Search API Methods



=over 4

=item B<search>

=item B<search(q)>



=over 4

=item Parameters: q, callback, lang, rpp, page, since_id, geocode, show_user

=item Required: q

=back

Returns tweets that match a specified query.  You can use a variety of search operators in your query.


Returns: ArrayRef[Status]

=item B<trends>



=over 4

=item Parameters: I<none>

=item Required: I<none>

=back

Returns the top ten queries that are currently trending on Twitter.  The
response includes the time of the request, the name of each trending topic, and
the url to the Twitter Search results page for that topic.


Returns: ArrayRef[Query]

=item B<trends_current>

=item B<trends_current(exclude)>



=over 4

=item Parameters: exclude

=item Required: I<none>

=back

Returns the current top ten trending topics on Twitter.  The response includes
the time of the request, the name of each trending topic, and query used on
Twitter Search results page for that topic.


Returns: HashRef

=item B<trends_daily>



=over 4

=item Parameters: date, exclude

=item Required: I<none>

=back

Returns the top 20 trending topics for each hour in a given day.


Returns: HashRef

=item B<trends_weekly>



=over 4

=item Parameters: date, exclude

=item Required: I<none>

=back

Returns the top 30 trending topics for each day in a given week.


Returns: HashRef


=back



=head1 ERROR HANDLING

When C<Net::Twitter::Lite> encounters a Twitter API error or a network error, it
throws a C<Net::Twitter::Lite::Error> object.  You can catch and process these
exceptions by using C<eval> blocks and testing $@:

    eval {
        my $statuses = $nt->friends_timeline(); # this might die!

        for my $status ( @$statuses ) {
            #...
        }
    };
    if ( $@ ) {
        # friends_timeline encountered an error

        if ( blessed $@ && $@->isa('Net::Twitter::Lite::Error' ) {
            #... use the thrown error obj
            warn $@->error;
        }
        else {
            # something bad happened!
            die $@;
        }
    }

C<Net::Twitter::Lite::Error> stringifies to something reasonable, so if you don't need
detailed error information, you can simply treat $@ as a string:

    eval { $nt->update($status) };
    if ( $@ ) {
        warn "update failed because: $@\n";
    }

=head1 SEE ALSO

=over 4

=item L<Net::Twitter::Lite::Error>

The C<Net::Twitter::Lite> exception object.

=item L<http://apiwiki.twitter.com/Twitter-API-Documentation>

This is the official Twitter API documentation. It describes the methods and their
parameters in more detail and may be more current than the documentation provided
with this module.

=item L<LWP::UserAgent::POE>

This LWP::UserAgent compatible class can be used in L<POE> based application
along with Net::Twitter::Lite to provide concurrent, non-blocking requests.

=back

=head1 SUPPORT

Please report bugs to C<bug-net-twitter@rt.cpan.org>, or through the web
interface at L<https://rt.cpan.org/Dist/Display.html?Queue=Net-Twitter>.

Join the Net::Twitter IRC channel at L<irc://irc.perl.org/net-twitter>.

Follow net_twitter: L<http://twitter.com/net_twitter>.

Track Net::Twitter::Lite development at L<http://github.com/semifor/net-twitter-lite>.

=head1 AUTHOR

Marc Mims <marc@questright.com>

=head1 LICENSE

Copyright (c) 2009 Marc Mims

The Twitter API itself, and the description text used in this module is:

Copyright (c) 2009 Twitter

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut


