#!/usr/bin/perl -w

use strict;
use warnings;
use POSIX;
use DBI;

#calling the "main" subroutine.
main();

#Subroutine main
#Pulls all rows from updates database
#iterates through every row 
sub main {
	my $dataPull=dataBasePull(dataBaseConnection());
	my $row=0;
	
	#iterates through every row if the account is being created it calls one sub otherwise it calls the other.
	while($row<=$#{$dataPull}){
		if($dataPull->[$row][1] eq "C"){
			#calls accountCreation passing only the accountId
			accountCreation($dataPull->[$row][0]);
		} else {
			#calls fileRebuild passing the array
			fileRebuild($dataPull->[$row]);
		}
		$row++;
	}
	
}

#Subroutine accountCreation
#	Arguments $accountId
#Routine starts the create_account script and then deletes the row
sub accountCreation{
	#runs the create_account script in the background passing the accountid as an argument
	system "/home/nagios/scripting/strix-backend/file_scripts/create_account.pl $_[0] 2>&1 >> /var/log/nagiScripts/account_creation.log &";
	rowDelete(dataBaseConnection(),$_[0]);
}

#Subroutine accountCreation
#	Arguments $database information
#Routine defines values from the database information then if any fields are 1 it runs the respective update script to rebuild the file then deletes the row
sub fileRebuild{
	my $accountId=$_[0][0];
	my $contact=$_[0][2];
	my $cgroup=$_[0][3];
	my $host=$_[0][4];
	
	if ($contact == 1){
		system "/home/nagios/scripting/strix-backend/file_scripts/rebuild_contact.pl $accountId 2>&1 >> /var/log/nagiScripts/contact_rebuilding.log &";
	}
	
	if ($cgroup == 1){
		system "/home/nagios/scripting/strix-backend/file_scripts/rebuild_groups.pl $accountId 2>&1 >> /var/log/nagiScripts/group_rebuilding.log &";
	}
	
	if ($host == 1){
		system "/home/nagios/scripting/strix-backend/file_scripts/rebuild_host.pl $accountId 2>&1 >> /var/log/nagiScripts/host_rebuilding.log &";
	}
	rowDelete(dataBaseConnection(),$accountId);
}

#sub dataBaseConnection
#sets the database connection information and creates the $dbh variable
#	returns $dbh
sub dataBaseConnection {
	my $dsn='dbi:mysql:nagiUpdates';
	my $user='nagiTest';
	my $pass='hV22buZAVFk22fx';
	
	my $dbh=DBI->connect($dsn,$user,$pass) || die "Error opening database: $DBI::errstr/n";
	return ($dbh);
}

#sub dataBasePull
#	Arguments $dbh
#Pulls all rows from the database
#	Returns $dump
sub dataBasePull {
	my ($sth, $dump, $query);
	my $dbh=$_[0];
	
	$query="SELECT * FROM accounts_updated";
	
	$sth=$dbh->prepare($query) || die "Prepare failed: $DBI::errstr/n";
	$sth->execute() || die "Couldn't execute query: $DBI::errstr/n";  
	$dump=$sth->fetchall_arrayref;
	$sth->finish();
	$dbh->disconnect || die "Failed to disconnect/n";
	return $dump;
}

#sub rowDelete
#	Arguments $dbh $accountId
#Deletes teh specified row
#	Returns $dump
sub rowDelete {
	my $dbh=$_[0];
	my ($sth, $dump, $query);
	
	$query="DELETE FROM accounts_updated WHERE account_id='$_[1]'";
	
	$sth=$dbh->prepare($query) || die "Prepare failed: $DBI::errstr/n";
	$sth->execute() || die "Couldn't execute query: $DBI::errstr/n";
	$sth->finish();
	$dbh->disconnect || die "Failed to disconnect/n";
}
