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
	my ($nagAcctPath, $count, $hostId, $hostFile, $services);
	$nagAcctPath=$_[0];
	$count=0;
	$hostId=0;
	my $hosts=dataBasePull(dataBaseConnection(),$_[1],1);
	my $hostDir="$nagAcctPath/hosts";
	my $hostDirBackup="$nagAcctPath/hosts_bkp";
	my @hostFields=("host_name", "alias", "address", "account_type", "contacts", "contact_groups");
	my @serviceFields=("host_name", "service_description", "check_command", "use", "contacts", "contact_groups");
	my @newFields=();

	rename $hostDir, $hostDirBackup;
	mkdir $hostDir || die $!;

	while($hostId < $#{$dataPull->[0]}){
		
		$hostFile="$hostDir/host$hostId.cfg";
	
		open HOSTFILE, '>', "$hostFile" or die $!;

		for $count (0 .. $#hostFields){
			if($hosts->[$hostId][$count+1] ne "NULL"){
				push @newFields, "$hostFields[$count] $hosts->[$hostId][$count+2]";
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
		
		$services=dataBasePull(dataBaseConnection(),$_[1],2,$hostId+1);
		
		while $serviceNum < $#{$services->[0]}){
			for $count (0 .. $#serviceFields){
				if($services->[$hostId][$count+3] ne "NULL"){
					push @newFields, "$hostFields[$count] $services->[$hostId][$count+2]";
				} else {
					push @newFields, ";$hostFields[$count]";
				}
				$count++;
			}
		
		
			print HOSTFILE "define service {\n";
			foreach my $line (@newFields){
				print HOSTFILE "\t$line\n";
			}
			print HOSTFILE "}";
		
		}
		
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
	$hostId=$_[3];
	
	$queryList[0]="SELECT email FROM account_information WHERE account_id='$accountId'";
	$queryList[1]="SELECT * FROM nagios_host WHERE account_id='$accountId'";
	$queryList[2]="SELECT * FROM nagios_host_services WHERE account_id='$accountId' AND host_id='0$hostId'";
	
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
