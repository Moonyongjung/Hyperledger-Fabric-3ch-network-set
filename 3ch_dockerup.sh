function printHelp() {
  echo "Usage: "
  echo "  dockerup.sh <mode>"
  echo "    <mode> - one of 'up', 'down'"
  echo "      - 'up' - bring up the network with docker-compose up"
  echo "      - 'down' - clear the network with docker-compose down"

  echo "	dockerup.sh up"
  echo "	dockerup.sh down"
}

function networkUp () {
  ../bin/cryptogen generate --config=./crypto-config.yaml
  ../bin/configtxgen -profile OrdererGenesis -channelID sys-channel -outputBlock ./channel-artifacts/genesis.block
  
  export CHANNEL_NAME12=channel12
  export CHANNEL_PROFILE12=Channel12
  ../bin/configtxgen -profile $CHANNEL_PROFILE12 -outputCreateChannelTx ./channel-artifacts/$CHANNEL_NAME12.tx -channelID $CHANNEL_NAME12
  
  export CHANNEL_NAME13=channel13
  export CHANNEL_PROFILE13=Channel13
  ../bin/configtxgen -profile $CHANNEL_PROFILE13 -outputCreateChannelTx ./channel-artifacts/$CHANNEL_NAME13.tx -channelID $CHANNEL_NAME13
  
  export CHANNEL_NAME123=channel123
  export CHANNEL_PROFILE123=Channel123
  ../bin/configtxgen -profile $CHANNEL_PROFILE123 -outputCreateChannelTx ./channel-artifacts/$CHANNEL_NAME123.tx -channelID $CHANNEL_NAME123


  ../bin/configtxgen -profile $CHANNEL_PROFILE12 -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors_$CHANNEL_NAME12.tx -channelID $CHANNEL_NAME12 -asOrg Org1MSP
  ../bin/configtxgen -profile $CHANNEL_PROFILE12 -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors_$CHANNEL_NAME12.tx -channelID $CHANNEL_NAME12 -asOrg Org2MSP

  ../bin/configtxgen -profile $CHANNEL_PROFILE13 -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors_$CHANNEL_NAME13.tx -channelID $CHANNEL_NAME13 -asOrg Org1MSP
  ../bin/configtxgen -profile $CHANNEL_PROFILE13 -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors_$CHANNEL_NAME13.tx -channelID $CHANNEL_NAME13 -asOrg Org3MSP

  ../bin/configtxgen -profile $CHANNEL_PROFILE123 -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors_$CHANNEL_NAME123.tx -channelID $CHANNEL_NAME123 -asOrg Org1MSP
  ../bin/configtxgen -profile $CHANNEL_PROFILE123 -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors_$CHANNEL_NAME123.tx -channelID $CHANNEL_NAME123 -asOrg Org2MSP
  ../bin/configtxgen -profile $CHANNEL_PROFILE123 -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors_$CHANNEL_NAME123.tx -channelID $CHANNEL_NAME123 -asOrg Org3MSP

  export BYFN_CA1_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/org1.example.com/ca && ls *_sk)
  export BYFN_CA2_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/org2.example.com/ca && ls *_sk)
  export BYFN_CA3_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/org3.example.com/ca && ls *_sk)

  docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_CA up
}

function networkDown () {
  # docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH -f $COMPOSE_FILE_KAFKA -f $COMPOSE_FILE_RAFT2 -f $COMPOSE_FILE_CA down --volumes --remove-orphans
  docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_CA down --volumes --remove-orphans

  rm -rf channel-artifacts/*.block channel-artifacts/*.tx crypto-config 
  
  rm -rf ../sdk-node/javascript/3ch-test-network-sdk/hfc-key-store

  # Remove previous docker ps
  # PS_CNTNR=$(docker ps -aq)
  # if [ -z "$PS_CNTNR" -o "$PS_CNTNR" = " " ]; then
  #         echo "Not exist ps"
  # else
  #         docker rm -f $PS_CNTNR
  # fi

  docker rmi $(docker images|grep cdrtest)
}

export COMPOSE_FILE=docker-compose-cli.yaml
export COMPOSE_FILE_COUCH=docker-compose-couch.yaml
export COMPOSE_FILE_KAFKA=docker-compose-kafka.yaml
export COMPOSE_FILE_RAFT2=docker-compose-etcdraft2.yaml
export COMPOSE_FILE_CA=docker-compose-ca.yaml

export IMAGE_TAG="latest"

export FABRIC_CFG_PATH=$PWD


MODE=$1
shift

if [ "${MODE}" == "up" ]; then
  networkUp
elif [ "${MODE}" == "down" ]; then
  networkDown
else
  printHelp
  exit 1
fi
