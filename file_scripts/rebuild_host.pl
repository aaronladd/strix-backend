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
	
	rebuildAllHosts($nagAcctPath, $accountId);
}

sub rebuildAllHosts {
	my ($nagAcctPath, $count, $hostId, $hostFile, $hostFileNumber, $services, $serviceNum, $accountId, $queryHostId);
	$nagAcctPath=$_[0];
	$accountId=$_[1];
	$count=0;
	$hostId=-1;
	$serviceNum=-1;
	my $hosts=dataBasePull(dataBaseConnection(),$accountId,1);
	my $hostDir="$nagAcctPath/hosts";
	my $hostDirBackup="$nagAcctPath/hosts_bkp";
	my @hostFields=("host_name", "alias", "address", "account_type", "contacts", "contact_groups");
	my @serviceFields=("host_name", "service_description", "check_command", "use", "contacts", "contact_groups");
	my @newFields=();

	rename $hostDir, $hostDirBackup;
	mkdir $hostDir || die $!;

	while($hostId < $#{$dataPull}){
		$hostId++;
		$hostFileNumber=$hostId+1;
		$hostFile="$hostDir/host$hostFileNumber.cfg";
	
		open HOSTFILE, '>', "$hostFile" or die $!;

		for $count (2 .. $#{$dataPull->[0]}){
			if($hosts->[$hostId][$count]){
				push @newFields, "$hostFields[$count-2] $hosts->[$hostId][$count]";
			} else {
				push @newFields, ";$hostFields[$count-2]";
			}
		}
		
		print HOSTFILE "define host {\n";
		foreach my $line (@newFields){
			print HOSTFILE "\t$line\n";
		}
		print HOSTFILE "}\n";
		
		@newFields=();
		$count=0;
		
		$services=dataBasePull(dataBaseConnection(),$_[1],2,$hosts->[$hostId][1]);
		
		while ($serviceNum < $#{$services}){
		
			for $count (3 .. $#{$services->[0]}){
				if($services->[$hostId][$count]){
					push @newFields, "$hostFields[$count-3] $services->[$hostId][$count]";
				} else {
					push @newFields, ";$hostFields[$count-3]";
				}
			}
		
		
			print HOSTFILE "define service {\n";
			foreach my $line (@newFields){
				print HOSTFILE "\t$line\n";
			}
			print HOSTFILE "}\n";
		
		}
		
		@newFields=();
		$count=0;
		close HOSTFILE;
	}
}

sub dataBasePull {
	my ($dbh, $accountId, $queryNum, $sth, $dump);
	my @queryList;
	$dbh=$_[0];
	$accountId=$_[1];
	$queryNum=$_[2];
	$hostId=$_[3];
	
	$queryList[0]="SELECT email FROM account_information WHERE account_id='$accountId'";
	$queryList[1]="SELECT * FROM nagios_host WHERE account_id='$accountId'";
	$queryList[2]="SELECT * FROM nagios_host_services WHERE account_id='$accountId' AND host_id='$hostId'";
	
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
