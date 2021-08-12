#!/bin/bash

check_version()
{
	wget https://github.com/Phala-Network/solo-mining-scripts/archive/poc5.zip -O /tmp/main.zip
	unzip -o /tmp/main.zip -d /tmp/phala
	if [ "$(cat $installdir/.env | awk -F "=" '{print $NF}')" != "$(cat /tmp/phala/solo-mining-scripts-poc5/.env | awk -F "=" '{print $NF}')" ]; then
		sed -i "4c NODE_VOLUMES=$(cat $installdir/.env|awk -F "=" 'NR==4 {print $NF}')" /tmp/phala/solo-mining-scripts-poc5/.env
		sed -i "5c PRUNTIME_VOLUMES=$(cat $installdir/.env|awk -F "=" 'NR==5 {print $NF}')" /tmp/phala/solo-mining-scripts-poc5/.env
		sed -i "6c CORES=$(cat $installdir/.env|awk -F "=" 'NR==6 {print $NF}')" /tmp/phala/solo-mining-scripts-poc5/.env
		sed -i "7c NODE_NAME=$(cat $installdir/.env|awk -F "=" 'NR==7 {print $NF}')" /tmp/phala/solo-mining-scripts-poc5/.env
		sed -i "8c MNEMONIC=$(cat $installdir/.env|awk -F "=" 'NR==8 {print $NF}')" /tmp/phala/solo-mining-scripts-poc5/.env
		sed -i "9c GAS_ACCOUNT_ADDRESS=$(cat $installdir/.env|awk -F "=" 'NR==9 {print $NF}')" /tmp/phala/solo-mining-scripts-poc5/.env
		sed -i "10c OPERATOR=$(cat $installdir/.env|awk -F "=" 'NR==10 {print $NF}')" /tmp/phala/solo-mining-scripts-poc5/.env
		rm -rf /opt/phala/{scripts,.env,docker-compose.yml,console.js}  /usr/bin/phala
		cp /tmp/phala/solo-mining-scripts-poc5/{.env,console.js,docker-compose.yml} /opt/phala
		cp -r /tmp/phala/solo-mining-scripts-poc5/scripts/en /opt/phala/scripts
		chmod +x /opt/phala/scripts/*
		ln -s /opt/phala/scripts/phala.sh /usr/bin/phala
		log_info "----------The local script version is too low and has been automatically upgraded. Please execute the command again!----------"
		exit 1
	fi

	rm -rf /tmp/phala
	rm /tmp/main.zip
}

update_script()
{
	log_info "----------Update phala script----------"

	wget https://github.com/Phala-Network/solo-mining-scripts/archive/poc5.zip -O /tmp/main.zip
	unzip -o /tmp/main.zip -d /tmp/phala
	rm -rf /opt/phala
	rm /usr/bin/phala
	mkdir /opt/phala
	cp -r /tmp/phala/solo-mining-scripts-poc5/scripts/en /opt/phala/scripts
	cp -r /tmp/phala/solo-mining-scripts-poc5/.env /opt/phala/
	cp -r /tmp/phala/solo-mining-scripts-poc5/console.js /opt/phala/
	cp -r /tmp/phala/solo-mining-scripts-poc5/docker-compose.yml /opt/phala/
	chmod +x /opt/phala/scripts/*
	ln -s /opt/phala/scripts/phala.sh /usr/bin/phala

	log_success "----------Update success----------"
	rm -rf /tmp/phala
	rm /tmp/main.zip
}

update_clean()
{
	log_info "----------Clean phala node images----------"
	log_info "Kill phala-node phala-pruntime phala-pherry"
	cd $installdir
	docker-compose stop
	docker container rm --force phala-node phala-pruntime phala-pherry
	docker image rm $(awk -F '[=]' 'NR==1,NR==3 {print $2}' $installdir/.env)

	log_info "----------Clean data----------"
	local node_data=$(awk -F '[=:]' 'NR==4 {print $2}' $installdir/.env)
	local pruntime_data=$(awk -F '[=:]' 'NR==5 {print $2}' $installdir/.env)
	if [ -d $node_data ]; then
		rm -rf $node_data
	elif [ -d $pruntime_data ]; then
		rm -rf $pruntime_data
	fi
	log_success "----------Clean success----------"

	start
}

update_noclean()
{
	log_info "----------Update phala node----------"
	log_info "Kill phala-node phala-pruntime phala-pherry"
	cd $installdir
	docker-compose stop
	docker container rm --force phala-node phala-pruntime phala-pherry
	docker image rm $(awk -F '[=]' 'NR==1,NR==3 {print $2}' $installdir/.env)

	start
	log_success "----------Update success----------"
}

update()
{
	case "$1" in
		clean)
			update_clean
			;;
		scripts)
			update_script
			;;
		"")
			update_noclean
			;;
		*)
			log_err "----------Parameter error----------"
	esac
}
