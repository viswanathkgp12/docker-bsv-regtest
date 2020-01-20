#!/bin/bash
set -e

if [[ "$1" == "bitcoin-cli" || "$1" == "bitcoin-tx" || "$1" == "bitcoind" || "$1" == "test_bitcoin" ]]; then
	mkdir -p "$BITCOIN_DATA"

	if [[ ! -s "$BITCOIN_DATA/bitcoin.conf" ]]; then
		cat <<-EOF > "$BITCOIN_DATA/bitcoin.conf"
		printtoconsole=1
		rpcallowip=::/0
		rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
		rpcuser=${BITCOIN_RPC_USER:-bitcoin}
		EOF
		chown bitcoin:bitcoin "$BITCOIN_DATA/bitcoin.conf"
	fi

	# ensure correct ownership and linking of data directory
	# we do not update group ownership here, in case users want to mount
	# a host directory and still retain access to it
	chown -R bitcoin "$BITCOIN_DATA"
	ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin
	chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin
fi


echo "Starting bitcoind in regtest mode ..."
bitcoind -regtest -daemon --datadir=/data --conf=/data/bitcoin.conf
echo "Regtest setup successfully"

sleep 5

AUTH="-rpcuser=root -rpcpassword=bitcoin -rpcport=18332"

bitcoin-cli -regtest $AUTH getblockchaininfo

bitcoin-cli -regtest $AUTH generate 110
bitcoin-cli -regtest $AUTH importprivkey "cVVGgzVgcc5S3owCskoneK8R1BNGkBveiEcGDaxu8RRDvFcaQaSG" "Account1" false

while true ; do bitcoin-cli -regtest $AUTH generate 1 & sleep 5; done
