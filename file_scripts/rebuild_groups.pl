#!/usr/bin/perl -w
#https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/objectdefinitions.html#contact
use strict;
use warnings;
use POSIX;
use DBI;

main(@ARGV);

sub main {
	my ($accountId)=$_[0];
	my $email=dataBasePull(dataBaseConnection(),$accountId,0);
	my $nagAcctPath="/usr/local/nagios/etc/accounts/$email->[0][0]";
	
	editContactsGroup($nagAcctPath, $accountId);
}

sub editContactsGroup {
	my $dataPull=dataBasePull(dataBaseConnection(),$_[1],2);
	my ($nagAcctPath, $count, $contactId);
	$nagAcctPath=$_[0];
	$count=0;
	$groupId=0;
	my $contactsGroupFile="$nagAcctPath/contacts/contacts_group.cfg";
	my $contactsGroupBackup="$nagAcctPath/contacts/contacts_group.bkp_cfg";
	my @contactGroupFields=("contactgroup_name", "alias", "members");
	my @newFields=();
	
	
	rename $contactsGroupFile, $contactsGroupBackup;

	open CONTACTGROUPFILE, '>', "$contactsGroupFile" or die $!;

	while($groupId < $#{$dataPull->[0]}){
		$dataPull->[$groupId][$count]=substr $dataPull->[$groupId][$count], -2, 2;
		for $count (0 .. $#{$dataPull->[0]}-3){
			push @newFields, "$contactGroupFields[$count] $dataPull->[$contactId][$count+1]";
			$count++;
		}
		
		print CONTACTGROUPFILE "define contactgroup {\n";
		foreach my $line (@newFields){
			print CONTACTGROUPFILE "\t$line\n";
		}
		print CONTACTGROUPFILE "}";
		
		@newFields=();
		$count=0;
		$contactId++;
	}
	
	close CONTACTGROUPFILE;
}


sub dataBasePull {
	my ($dbh, $accountId, $queryNum, $sth, $dump)=$_[0], $_[1] $_[2];
	my @queryList;
	
	$queryList[0]="SELECT email FROM account_information WHERE account_id='$accountId'";
	$queryList[1]="SELECT * FROM nagios_contact_groups WHERE account_id='$accountId'";
	
	$sth=$dbh->prepare($queryList[$queryNum]) || die "Prepare failed: $DBI::errstr\n";
	
	$sth->execute() || die "Couldn't execute query: $DBI::errstr\n";
	
	#$sth->dump_results();  
	$dump=$sth->fetchall_arrayref;
	$sth->finish();
	$dbh->disconnect || die "Failed to disconnect\n";
	return($dump);
}

sub dataBaseConnection {
	my $dsn='dbi:mysql:nagidb';
	my $user='nagiTest';
	my $pass='hV22buZAVFk22fx';
	
	my $dbh=DBI->connect($dsn,$user,$pass) || die "Error opening database: $DBI::errstr\n";
	return ($dbh);
}
