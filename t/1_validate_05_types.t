# -*- Mode: Perl; -*-

use strict;

$^W = 1;

### determine number of tests
seek(DATA,0,0);
my $prog  = join "", <DATA>;
my @tests = ($prog =~ /&print_ok\(/g);
my $tests = @tests;
print "1..$tests\n";

require CGI::Ex::Validate;

my ($N, $v, $e, $ok) = (0);

sub validate {
  return scalar &CGI::Ex::Validate::validate(@_);
}
sub print_ok {
  my $ok = shift;
  $N ++;
  print "" . ($ok ? "" : "not ") . "ok $N\n";
}
&print_ok(1);


### required
$v = {foo => {required => 1}};
$e = &validate({}, $v);
&print_ok($e);

$e = &validate({foo => 1}, $v);
&print_ok(! $e);

### validate_if
$v = {foo => {required => 1, validate_if => 'bar'}};
$e = &validate({}, $v);
&print_ok(! $e);

$e = &validate({bar => 1}, $v);
&print_ok($e);

### required_if
$v = {foo => {required_if => 'bar'}};
$e = &validate({}, $v);
&print_ok(! $e);

$e = &validate({bar => 1}, $v);
&print_ok($e);

### max_values
$v = {foo => {required => 1}};
$e = &validate({foo => [1,2]}, $v);
&print_ok($e);

$v = {foo => {max_values => 2}};
$e = &validate({}, $v);
&print_ok(! $e);

$e = &validate({foo => "str"}, $v);
&print_ok(! $e);

$e = &validate({foo => [1]}, $v);
&print_ok(! $e);

$e = &validate({foo => [1,2]}, $v);
&print_ok(! $e);

$e = &validate({foo => [1,2,3]}, $v);
&print_ok($e);

### min_values
$v = {foo => {min_values => 3, max_values => 10}};
$e = &validate({foo => [1,2,3]}, $v);
&print_ok(! $e);

$e = &validate({foo => [1,2,3,4]}, $v);
&print_ok(! $e);

$e = &validate({foo => [1,2]}, $v);
&print_ok($e);

$e = &validate({foo => "str"}, $v);
&print_ok($e);

$e = &validate({}, $v);
&print_ok($e);

#  
#  ### allow for enum types
#  foreach my $type ($self->filter_type('enum',$types)) {
#    my $ref = ref($field_val->{$type}) ? $field_val->{$type} : [split(/\s*\|\|\s*/,$field_val->{$type})];
#    my $value = $form->{$field};
#    $value = '' if ! defined $value;
#    if (! grep {$_ eq $value} @$ref) {
#      $self->add_error(\@errors, $field, $type, $field_val, $ifs_match);
#    }
#  }
#
#  ### field equality test
#  foreach my $type ($self->filter_type('equals',$types)) {
#    my $field2 = $field_val->{$type};
#    my $success = 0;
#    if ($field2 =~ m/^([\"\'])(.*)\1$/) {
#      my $test = $2;
#      $test = '' if $test eq '|'; # copy behavior from FORMS
#      if (exists($form->{$field}) || ! defined($form->{$field})) {
#        $success = ($form->{$field} eq $test);
#      }
#    } elsif (exists($form->{$field2}) && defined($field2)) {
#      if (exists($form->{$field}) || ! defined($form->{$field})) {
#        $success = ($form->{$field} eq $form->{$field2});
#      }
#    } elsif (! exists($form->{$field}) || ! defined($form->{$field})) {
#      $success = 1; # occurs if they are both undefined
#    }
#    if (! $success) {
#      $self->add_error(\@errors, $field, $type, $field_val, $ifs_match);
#    }
#  }
#
#  ### length min check
#  foreach my $type ($self->filter_type('min_len',$types)) {
#    my $n = $field_val->{$type};
#    if (exists($form->{$field}) && defined($form->{$field}) && length($form->{$field}) < $n) {
#      $self->add_error(\@errors, $field, $type, $field_val, $ifs_match);
#    }
#  }
#
#  ### length max check
#  foreach my $type ($self->filter_type('max_len',$types)) {
#    my $n = $field_val->{$type};
#    if (exists($form->{$field}) && defined($form->{$field}) && length($form->{$field}) > $n) {
#      $self->add_error(\@errors, $field, $type, $field_val, $ifs_match);
#    }
#  }
#
#  ### now do match types
#  foreach my $type ($self->filter_type('match',$types)) {
#    my $ref = ref($field_val->{$type}) ? $field_val->{$type} : [split(/\s*\|\|\s*/,$field_val->{$type})];
#    foreach my $rx (@$ref) {
#      my $not = ($rx =~ s/^\s*!~?\s*//) ? 1 : 0;
#      if ($rx !~ /^\s*m?([^\w\s])(.*[^\\])\1([eisgmx]*)\s*$/s
#          && $rx !~ /^\s*m?([^\w\s])()\1([eisgmx]*)\s*$/s) {
#        die "Not sure how to parse that match ($rx)";
#      }
#      my ($pat,$opt) = ($2,$3);
#      $opt =~ tr/g//d;
#      die "The e option cannot be used on validation match's" if $opt =~ /e/;
#      if (defined($form->{$field}) && length($form->{$field})) {
#        if ( ($not && $form->{$field} =~ m/(?$opt:$pat)/)
#             || (! $not && $form->{$field} !~ m/(?$opt:$pat)/)
#             ) {
#          $self->add_error(\@errors, $field, $type, $field_val, $ifs_match);
#        }
#      }
#    }
#  }
#
#  ### allow for comparison checks
#  foreach my $type ($self->filter_type('compare',$types)) {
#    my $comp = $field_val->{$type} || next;
#    my $value = $form->{$field};
#    my $test = 0;
#    if ($comp =~ /^\s*(>|<|[><!=]=)\s*([\d\.\-]+)\s*$/) {
#      $value = 0 if ! $value;
#      if    ($1 eq '>' ) { $test = ($value >  $2) }
#      elsif ($1 eq '<' ) { $test = ($value <  $2) }
#      elsif ($1 eq '>=') { $test = ($value >= $2) }
#      elsif ($1 eq '<=') { $test = ($value <= $2) }
#      elsif ($1 eq '!=') { $test = ($value != $2) }
#      elsif ($1 eq '==') { $test = ($value == $2) }
#
#    } elsif ($comp =~ /^\s*(eq|ne|gt|ge|lt|le)\s+(.+?)\s*$/) {
#      $value = '' if ! $value && ! length $value;
#      if    ($1 eq 'gt') { $test = ($value gt $2) }
#      elsif ($1 eq 'lt') { $test = ($value lt $2) }
#      elsif ($1 eq 'ge') { $test = ($value ge $2) }
#      elsif ($1 eq 'le') { $test = ($value le $2) }
#      elsif ($1 eq 'ne') { $test = ($value ne $2) }
#      elsif ($1 eq 'eq') { $test = ($value eq $2) }
#
#    } else {
#      die "Not sure how to compare \"$comp\"";
#    }
#    if (! $test) {
#      $self->add_error(\@errors, $field, $type, $field_val, $ifs_match);
#    }
#  }
#
#  ### program side sql type
#  foreach my $type ($self->filter_type('sql',$types)) {
#    my $db_type = $field_val->{"${type}_db_type"};
#    my $dbh = ($db_type) ? $self->{dbhs}->{$db_type} : $self->{dbh};
#    if (! $dbh) {
#      die "Missing dbh for $type type on field $field" . ($db_type ? " and db_type $db_type" : "");
#    } elsif (UNIVERSAL::isa($dbh,'CODE')) {
#      $dbh = &$dbh($field, $self) || die "SQL Coderef did not return a dbh";
#    }
#    my $sql = $field_val->{$type};
#    my @args = ($field_val) x $sql =~ tr/?//;
#    my $return = $dbh->selectrow_array($sql, {}, @args); # is this right - copied from O::FORMS
#    $field_val->{"${type}_error_if"} = 1 if ! defined $field_val->{"${type}_error_if"};
#    if ( (! $return && $field_val->{"${type}_error_if"})
#         || ($return && ! $field_val->{"${type}_error_if"}) ) {
#      $self->add_error(\@errors, $field, $type, $field_val, $ifs_match);
#    }
#  }
#
#  ### server side boolean type
#  foreach my $type ($self->filter_type('boolean',$types)) {
#    next if $field_val->{$type};
#    $self->add_error(\@errors, $field, $type, $field_val, $ifs_match);
#  }
#
#  ### do specific type checks
#  foreach my $type ($self->filter_type('type',$types)) {
#    if (! $self->check_type($form->{$field},$field_val->{'type'},$field,$form)){
#      $self->add_error(\@errors, $field, $type, $field_val, $ifs_match);
#    }
#  }            
__DATA__
