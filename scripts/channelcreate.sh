

#190715_hyperledger environments
function printHelp() {
  echo "Usage: "
  echo "  channelcreate.sh"
  echo "    <mode> - one of 'create', 'join', 'chaincode'"
  echo "      - '1. create' - Genrate channel"
  echo "      - '2. join' - Join channel"
  echo "      - '3. chaincode' - Chaincode functions"
  echo "             'install' - Install chaincode"
  echo "             'invoke' - Invoke chaincode"
  echo "             'query' - Query chaincode"
}

function channelCreate() {
  INPUT_CHANNELNAME=$1
  peer channel create -o orderer.example.com:7050 -c $INPUT_CHANNELNAME -f ../channel-artifacts/${INPUT_CHANNELNAME}.tx --outputBlock ../${INPUT_CHANNELNAME}.block --tls --cafile $ORDERER_CA
}

function channelJoin() {
  INPUT_CHANNELNAME=$1
  ORG=$CORE_PEER_LOCALMSPID

  peer channel join -b ../${INPUT_CHANNELNAME}.block --tls --cafile $ORDERER_CA

  if [ "$CORE_PEER_ADDRESS" == "peer0.org1.example.com:7051" ]; then
    peer channel update -o orderer.example.com:7050 -c $INPUT_CHANNELNAME -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${ORG}anchors_${INPUT_CHANNELNAME}.tx --tls --cafile $ORDERER_CA  
  elif [ "$CORE_PEER_ADDRESS" == "peer0.org2.example.com:9051" ]; then
    peer channel update -o orderer.example.com:7050 -c $INPUT_CHANNELNAME -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${ORG}anchors_${INPUT_CHANNELNAME}.tx --tls --cafile $ORDERER_CA  
  elif [ "$CORE_PEER_ADDRESS" == "peer0.org3.example.com:11051" ]; then
    peer channel update -o orderer.example.com:7050 -c $INPUT_CHANNELNAME -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${ORG}anchors_${INPUT_CHANNELNAME}.tx --tls --cafile $ORDERER_CA  
  else
    echo 
  fi
}

function chaincode() {
  if [ "$CHAINCODE_STATE" == "install" ]; then
    if [ "$CHAINCODE_NAME" == "" ]; then
      echo "========Warning========"
      echo "Chaincode name is null"
      exit
    fi

    peer chaincode install -n $CHAINCODE_NAME -v 1.0 -p github.com/chaincode/cdr_test/go/
    

  elif [ "$CHAINCODE_STATE" == "instantiate" ]; then
    if [ "$CHAINCODE_NAME" == "" ]; then
      echo "========Warning========"
      echo "Chaincode name is null"
      exit
    fi

    ORG=$CORE_PEER_LOCALMSPID
    if [ "$ORG" == "Org1MSP" ]; then
      peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME123 -n $CHAINCODE_NAME -v 1.0 -c '{"Args":["init"]}' -P "OR ('Org1MSP.peer', 'Org2MSP.peer', 'Org3MSP.peer')"
      peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME12 -n $CHAINCODE_NAME -v 1.0 -c '{"Args":["init"]}' -P "OR ('Org1MSP.peer', 'Org2MSP.peer')"
      peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME13 -n $CHAINCODE_NAME -v 1.0 -c '{"Args":["init"]}' -P "OR ('Org1MSP.peer', 'Org3MSP.peer')"
    elif [ "$ORG" == "Org2MSP" ]; then
      peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME123 -n $CHAINCODE_NAME -v 1.0 -c '{"Args":["init"]}' -P "OR ('Org1MSP.peer', 'Org2MSP.peer', 'Org3MSP.peer')"
      peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME12 -n $CHAINCODE_NAME -v 1.0 -c '{"Args":["init"]}' -P "OR ('Org1MSP.peer', 'Org2MSP.peer')"
    elif [ "$ORG" == "Org3MSP" ]; then
      peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME123 -n $CHAINCODE_NAME -v 1.0 -c '{"Args":["init"]}' -P "OR ('Org1MSP.peer', 'Org2MSP.peer', 'Org3MSP.peer')"
      peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME13 -n $CHAINCODE_NAME -v 1.0 -c '{"Args":["init"]}' -P "OR ('Org1MSP.peer', 'Org3MSP.peer')"
    else 
      echo "Not included ORG in the blockchain"
    fi

  elif [ "$CHAINCODE_STATE" == "invoke" ]; then
    if [ "$CHAINCODE_NAME" == "" ]; then
      echo "========Warning========"
      echo "Chaincode name is null"
      exit
    fi

    read -p "Args.. Date> " DATE
    # aguments are needed.
    # read -p "Args.. type, PLMN, sign, etc."

    s1='{"Args":["createAgreement","agreement","'
    s2='","20190822_20200722","CHNCM_KORKF","SIGN","AGMT"]}'
    s=$s1$DATE$s2

    peer chaincode invoke -o orderer:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/roaming/orderers/orderer.roaming/msp/tlscacerts/tlsca.roaming-cert.pem -C $CHANNEL_NAME -n $CHAINCODE_NAME --peerAddresses peer0.org1:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.exapmle.compeers/peer0.org1/tls/ca.crt  -c $s


  elif [ "$CHAINCODE_STATE" == "query" ]; then
    if [ "$CHAINCODE_NAME" == "" ]; then
      echo "========Warning========"
      echo "Chaincode name is null"
      exit
    fi

    echo "> Select Query Range (1. name/2. range/3. all)"
    read -p "> " RANGE

    if [ "$RANGE" == "3" ]; then
      echo ""
      echo "> Query result"
      echo ""
      peer chaincode query -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["queryAllAgreements"]}'

    elif [ "$RANGE" == "1" ]; then
      echo "> Input agreement Date(YYYYMMDD)"
      read -p "> " AGMT_DATE
      echo ""
      echo "> Query result"
      echo ""
      s1='{"Args":["queryAgreement","agreement","'
      s2='"]}'
      s=$s1$AGMT_DATE$s2
      peer chaincode query -C $CHANNEL_NAME -n $CHAINCODE_NAME -c $s

    elif [ "$RANGE" == "2" ]; then
      read -p "> Start Date : " START_DATE
      read -p "> End Date   : " END_DATE
      echo ""
      echo "> Query result"
      echo ""
      s1='{"Args":["queryRangeAgreements","agreement'
      s2='","agreement'
      s3='"]}'
      s=$s1$START_DATE$s2$END_DATE$s3
      peer chaincode query -C $CHANNEL_NAME -n $CHAINCODE_NAME -c $s

    else
      echo ""
      echo "> Do not use this number or character"
    fi
  else
    echo "> Need more parameters"
  fi
}

export CHANNEL_NAME12=channel12
export CHANNEL_PROFILE12=Channel12
export CHANNEL_NAME13=channel13
export CHANNEL_PROFILE13=Channel13
export CHANNEL_NAME123=channel123
export CHANNEL_PROFILE123=Channel123

export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
# CORE_PEER_ADDRESS=peer0.org1.example.com:7051
# CORE_PEER_LOCALMSPID="Org1MSP"
# CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

echo "============================================================================================================"
echo "Hyperledger Fabric _ 3ch network Platform"
echo ""
echo "Fabric channel Create and Join & Chaincode Install, Invoke and Query"
echo "============================================================================================================"
while :
do
echo ""
echo "============================================================================================================"
echo "Input mode number you use"
echo ""
echo "1. create              2. join              3. chaincode                4. create/join/install/init"
echo "   - Channel create       - Channel join       - Chaincode functions       - Channel create ~ chaincode init"    
echo "============================================================================================================"
read -p "> " MODE




#MODE=$1
#shift

if [ "${MODE}" == "1" ]; then

  echo "> Channel create 123 or 12 or 13"
  read -p ">" CHANNEL_STATE_INPUT
  if [ "$CHANNEL_STATE_INPUT" == "123" ]; then
    channelCreate $CHANNEL_NAME123
  elif [ "$CHANNEL_STATE_INPUT" == "12" ]; then
    channelCreate $CHANNEL_NAME12
  elif [ "$CHANNEL_STATE_INPUT" == "13" ]; then
    channelCreate $CHANNEL_NAME13
  else
    echo "> Do not use this number or character"
  fi

  
  
elif [ "${MODE}" == "2" ]; then
  #echo "> Channel? (123; 12; 13)"
  #read -p "> " ORG_STATE

  ORG=$CORE_PEER_LOCALMSPID
  if [ "$ORG" == "Org1MSP" ]; then
    channelJoin $CHANNEL_NAME123
    channelJoin $CHANNEL_NAME12
    channelJoin $CHANNEL_NAME13
  elif [ "$ORG" == "Org2MSP" ]; then
    channelJoin $CHANNEL_NAME123
    channelJoin $CHANNEL_NAME12
  elif [ "$ORG" == "Org3MSP" ]; then
    channelJoin $CHANNEL_NAME123
    channelJoin $CHANNEL_NAME13
  else
    echo "> Do not use this number or character"
  fi
  


elif [ "${MODE}" == "3" ]; then
  echo "> Selct Mode number (1. install/2. instantiate/3. invoke/4. query)"
  read -p "> " CHAINCODE_STATE_INPUT
  if [ "$CHAINCODE_STATE_INPUT" == "1" ]; then
    CHAINCODE_STATE="install"
  elif [ "$CHAINCODE_STATE_INPUT" == "2" ]; then
    CHAINCODE_STATE="instantiate"
  elif [ "$CHAINCODE_STATE_INPUT" == "3" ]; then
    CHAINCODE_STATE="invoke"
  elif [ "$CHAINCODE_STATE_INPUT" == "4" ]; then
    CHAINCODE_STATE="query"
  else
    echo "> Do not use this number or character"
  fi

  # echo "> Input chaincode name"
  # read -p "> " CHAINCODE_NAME

  CHAINCODE_NAME="cdrtest"

  chaincode
elif [ "${MODE}" == "4" ]; then
  channelCreate
  #channelJoin
  
  CHAINCODE_STATE="install"  
  echo "> Input chaincode name"
  read -p "> " CHAINCODE_NAME
  chaincode
elif [ "${MODE}" == "exit" ]; then
  exit
else
  printHelp
  exit 1
fi

done
