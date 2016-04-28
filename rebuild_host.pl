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
	
	rebuildHost($nagAcctPath, $accountId);
}

sub rebuildHost {
	my ($nagAcctPath, $count, $hostId, $hostFile);
	$nagAcctPath=$_[0];
	$count=0;
	$hostId=0;
	my $dataPull=dataBasePull(dataBaseConnection(),$_[1],1);
	my $hostDir="$nagAcctPath/hosts";
	my $hostDirBackup="$nagAcctPath/hosts_bkp";
	my @hostFields=("host_name", "alias", "address", "account_type", "contacts", "contact_groups");
	my @newFields=();

	rename $hostDir, $hostDirBackup;
	mkdir $hostDir || die $!;

	while($hostId < $#{$dataPull->[0]}){
		
		$hostFile="$hostDir/host$hostId.cfg";
	
		open HOSTFILE, '>', "$hostFile" or die $!;

		for $count (0 .. $#hostFields){
			if($dataPull->[$hostId][$count+1] ne "NULL"){
				push @newFields, "$hostFields[$count] $dataPull->[$hostId][$count+2]";
			} else {
				push @newFields, ";$hostFields[$count]";
			}
			$count++;
		}
		
		print HOSTFILE "define host {\n";
		foreach my $line (@newFields){
			print HOSTFILE "\t$line\n";
		}
		print HOSTFILE "}";
		
		@newFields=();
		$count=0;
		$hostId++;
		
		close HOSTFILE;
	}
}

sub dataBasePull {
	my ($dbh, $accountId, $queryNum, $sth, $dump);
	my @queryList;
	$dbh=$_[0];
	$accountId=$_[1];
	$queryNum=$_[2];
	
	$queryList[0]="SELECT email FROM account_information WHERE account_id='$accountId'";
	$queryList[1]="SELECT * FROM nagios_host WHERE account_id='$accountId'";
	
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
