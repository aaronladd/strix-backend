#!/usr/bin/perl -w

use strict;
use warnings;
use POSIX;
use DBI;

main(@ARGV);

sub main {
	my $dataPull=dataBasePull(dataBaseConnection());
	my $row=-1;
	
	while($row<$#{$dataPull->[0]}){
		$row++;
		print "$dataPull->[$row][1]\n";
		if($dataPull->[$row][1] eq "N"){
			print "$dataPull->[$row]\n";
			#accountCreation($dataPull->[$row]);
		} else {
			print "$dataPull->[$row]\n";
			#fileRebuild($dataPull->[$row]);
		}
	}
	
}

sub accountCreation{
	my $accountId=$_->[0][0];
	exec '\home\nagios\scripting\create_account.pl', $accountId;
	#rowDelete(dataBaseConnection(),$accountId);
}

sub fileRebuild{
	my $accountId=$_->[0][0];
	my $contact=$_->[0][2];
	my $cgroup=$_->[0][3];
	my $host=$_->[0][4];
	
	if ($contact == 1){
		exec '\home\nagios\scripting\rebuild_contact.pl', $accountId;
	}
	
	if ($cgroup == 1){
		exec '\home\nagios\scripting\rebuild_groups.pl', $accountId;
	}
	
	if ($host == 1){
		exec '\home\nagios\scripting\rebuild_host.pl', $accountId;
	}
	#rowDelete(dataBaseConnection(),$accountId);
}

sub dataBaseConnection {
	my $dsn='dbi:mysql:nagiUpdates';
	my $user='nagiTest';
	my $pass='hV22buZAVFk22fx';
	
	my $dbh=DBI->connect($dsn,$user,$pass) || die "Error opening database: $DBI::errstr\n";
	return ($dbh);
}

sub dataBasePull {
	my $dbh=$_[0];
	my ($sth, $dump, $query);
	
	$query="SELECT * FROM accounts_updated";
	
	$sth=$dbh->prepare($query) || die "Prepare failed: $DBI::errstr\n";
	$sth->execute() || die "Couldn't execute query: $DBI::errstr\n";  
	$dump=$sth->fetchall_arrayref;
	$sth->finish();
	$dbh->disconnect || die "Failed to disconnect\n";
	return $dump;
}

sub rowDelete {
	my $dbh=$_[0];
	my ($sth, $dump, $query);
	
	$query="DELETE FROM accounts_updated WHERE account_id='$_[1]";
	
	$sth=$dbh->prepare($query) || die "Prepare failed: $DBI::errstr\n";
	$sth->execute() || die "Couldn't execute query: $DBI::errstr\n";
	$sth->finish();
	$dbh->disconnect || die "Failed to disconnect\n";
}
