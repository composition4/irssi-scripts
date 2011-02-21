use strictures 1;
use MooseX::Declare;

our $VERSION = 0.01;

class Test::Irssi {

    use Term::VT102;
    use Term::Terminfo;
    use feature qw/say switch/;
    use Data::Dump;
    use IO::File;
    use Test::Irssi::Driver;
    use Test::Irssi::Callbacks;

    # requires the latest pre-release POE from
    # https://github.com/rcaputo/poe until a new release is...released.
    use lib $ENV{HOME} . "/projects/poe/lib";
    use POE;


    has 'irssi_binary'
      => (
          is => 'ro',
          isa => 'Str',
          required => 1,
         );

    has 'irssi_homedir'
      => (
          is => 'ro',
          isa => 'Str',
          required => 1,
         );

    has 'terminal_width'
      => (
          is => 'ro',
          isa => 'Int',
          required => 1,
          default => 80,
         );

    has 'terminal_height'
      => (
          is => 'ro',
          isa => 'Int',
          required => 1,
          default => 24,
         );

    has 'vt'
      => (
          is => 'ro',
          isa => 'Term::VT102',
          required => 1,
          lazy => 1,
          builder => '_build_vt102',
         );

    has 'logfile'
      => (
          is => 'ro',
          isa => 'Str',
          required => 1,
          default => 'irssi-test.log',
         );

    has '_logfile_fh'
      => (
          is => 'ro',
          isa => 'IO::File',
          required => 1,
          lazy => 1,
          builder => '_build_logfile_fh',
         );

    has '_driver'
      => (
          is => 'ro',
          isa => 'Test::Irssi::Driver',
          required => 1,
          lazy => 1,
          builder => '_build_driver',
         );

    has '_callbacks'
      => (
          is => 'ro',
          isa => 'Test::Irssi::Callbacks',
          required => 1,
          lazy => 1,
          builder => '_build_callback_obj',
         );

    method _build_callback_obj {
        my $cbo = Test::Irssi::Callbacks->new(parent => $self);

        $self->log("Going to register vt callbacks");
        $cbo->register_vt_callbacks;

        return $cbo;
    }

    method _build_driver {
        my $drv = Test::Irssi::Driver->new(parent => $self);
        return $drv;
    }

    method _build_vt102 {
        my $rows = $self->terminal_height;
        my $cols = $self->terminal_width;

        my $vt = Term::VT102->new($cols, $rows);

        # options
        $vt->option_set(LINEWRAP => 1);
        $vt->option_set(LFTOCRLF => 1);


        return $vt;
    }

    method _build_logfile_fh {

        my $logfile = $self->logfile;

        my $fh = IO::File->new($logfile, 'w');
        die "Couldn't open $logfile for writing: $!" unless defined $fh;
        $fh->autoflush(1);

        return $fh;
    }


    method log (Str $msg) {
        $self->_logfile_fh->say($msg);
    }


    method run {
        $self->_driver->setup();
        $self->log("Driver setup complete");
        ### Start a session to encapsulate the previous features.
        $poe_kernel->run();
    }
}

__END__

=head1 NAME

Test::Irssi - A cunning testing system for Irssi scripts

=head1 SYNOPSIS

blah blah blah
