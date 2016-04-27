#!/usr/bin/perl -w
#https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/objectdefinitions.html#contact
#/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

use strict;
use warnings;
use POSIX;
use DBI;

main(@ARGV);

sub main {
	my $accountId=$_[0];
	my $email=dataBasePull(dataBaseConnection(),$accountId,0);
	my $nagAcctPath="/usr/local/nagios/etc/accounts/$email->[0][0]";
	
	rebuildContact($nagAcctPath, $accountId);
}

sub rebuildContact {
	my ($nagAcctPath, $accountId, $count, $contactId);
	$nagAcctPath=$_[0];
	$accountId=$_[1];
	$count=0;
	$contactId=0;
	my $dataPull=dataBasePull(dataBaseConnection(),$accountId,1);
	my $contactFile="$nagAcctPath/contacts/contacts.cfg";
	my $contactBackup="$nagAcctPath/contacts/contacts.bkp_cfg";
	my @contactFields=(";contact_id", "contact_name", "alias", "use", "contactgroups", "email", "address1", "address2", "host_notifications_enabled", "service_notifications_enabled");
	my @newFields=();

	rename $contactFile, $contactBackup;

	open CONTACTFILE, '>', "$contactFile" or die $!;

	while($contactId < $#{$dataPull->[0]}){
		$dataPull->[$contactId][$count]=substr $dataPull->[$contactId][$count], -2, 2;
		for $count (0 .. $#contactFields-2){
			if($dataPull->[$contactId][$count+1] ne "null"){
				push @newFields, "$contactFields[$count] $dataPull->[$contactId][$count+1]";
			} else {
				push @newFields, ";$contactFields[$count]";
			}
			$count++;
		}
		push @newFields, "$contactFields[8] $dataPull->[$contactId][9]";
		push @newFields, "$contactFields[9] $dataPull->[$contactId][9]";
		
		print CONTACTFILE "define contact {\n";
		foreach my $line (@newFields){
			print CONTACTFILE "\t$line\n";
		}
		print CONTACTFILE "}";
		
		@newFields=();
		$count=0;
		$contactId++;
	}
	
	close CONTACTFILE;
}

sub dataBasePull {
	my ($dbh, $accountId, $queryNum, $sth, $dump);
	my @queryList;
	$dbh=$_[0];
	$accountId=$_[1];
	$queryNum=$_[2];
	
	$queryList[0]="SELECT email FROM account_information WHERE account_id='$accountId'";
	$queryList[1]="SELECT * FROM nagios_contact WHERE account_id='$accountId'";
	
	$sth=$dbh->prepare($queryList[$queryNum]) || die "Prepare failed: $DBI::errstr\n";
	
	$sth->execute() || die "Couldn't execute query: $DBI::errstr\n";
	
	#$sth->dump_results();  
	$dump=$sth->fetchall_arrayref;
	$sth->finish();
	$dbh->disconnect || die "Failed to disconnect\n";
	return $dump;
}

sub dataBaseConnection {
	my $dsn='dbi:mysql:nagidb';
	my $user='nagiTest';
	my $pass='hV22buZAVFk22fx';
	
	my $dbh=DBI->connect($dsn,$user,$pass) || die "Error opening database: $DBI::errstr\n";
	return ($dbh);
}
