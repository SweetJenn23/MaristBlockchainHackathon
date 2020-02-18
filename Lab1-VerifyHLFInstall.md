# Lab 1: Verify Hyperledger Fabric Installation

In this lab, you will start with a basic Linux server instance running on IBM LinuxONE Community Cloud. The script you ran installed several software prerequisites including:

* Docker and Docker Compose

* Node.js (8.9.4) and npm

* Golang compiler

* Hyperledger Fabric v1.4

* Hyperledger Fabric samples 

* Pre-requisite packages for the above items that vary depending on the Linux distribution selected

  

  Note: Hyperledger Fabric 1.4 was specifically chosen for this event because it has the most documentation and examples available for your usage.



## Installation verification lab overview

During this lab, you will verify the installation of Hyperledger Fabric, build various artifacts such as Docker images and executable binaries from the source code to verify that your Hyperledger Fabric installation is in working order.

The installation script clonded the Hyperledger Fabric's **fabric-samples** repository. In the fabric-samples directory on your guest, you'll run the verification test known as "Build your first network" to create a basic Hyperledger Fabric network and utilize the Hyperledger Fabric Command Line Interface (CLI) to verify that core Hyperledger Fabric functionality is working correctly.



### Running  the "Build your first network" sample

1. Run the command, `docker images`

   You will see several Docker images that were created. You will notice that many of the Docker images at the top of the output were created in the last few minutes. These were created by the make docker native command issued in the installation script. The Docker images that are a few months old were downloaded from Hyperledger Fabric's public DockerHub repository. Your output should look similar to that shown here, although your image IDs will be different for the images that were created in the last few minutes:

```
$ docker images
EPOSITORY                     TAG                              IMAGE ID            CREATED             SIZE
hyperledger/fabric-ca          latest                           7742a1dfc2bf        16 seconds ago      147MB
hyperledger/fabric-ca          s390x-1.4.5-snapshot-93f6863     7742a1dfc2bf        16 seconds ago      147MB
hyperledger/fabric-tools       latest                           41be81b41a6e        2 minutes ago       1.41GB
hyperledger/fabric-tools       s390x-1.4.5-snapshot-189380870   41be81b41a6e        2 minutes ago       1.41GB
hyperledger/fabric-tools       s390x-latest                     41be81b41a6e        2 minutes ago       1.41GB
<none>                         <none>                           53de79f7e543        2 minutes ago       1.66GB
hyperledger/fabric-buildenv    latest                           e3998463c06f        3 minutes ago       1.33GB
hyperledger/fabric-buildenv    s390x-1.4.5-snapshot-189380870   e3998463c06f        3 minutes ago       1.33GB
hyperledger/fabric-buildenv    s390x-latest                     e3998463c06f        3 minutes ago       1.33GB
hyperledger/fabric-ccenv       latest                           fe28248ceb32        4 minutes ago       1.28GB
hyperledger/fabric-ccenv       s390x-1.4.5-snapshot-189380870   fe28248ceb32        4 minutes ago       1.28GB
hyperledger/fabric-ccenv       s390x-latest                     fe28248ceb32        4 minutes ago       1.28GB
hyperledger/fabric-orderer     latest                           60279cfff46c        5 minutes ago       118MB
hyperledger/fabric-orderer     s390x-1.4.5-snapshot-189380870   60279cfff46c        5 minutes ago       118MB
hyperledger/fabric-orderer     s390x-latest                     60279cfff46c        5 minutes ago       118MB
hyperledger/fabric-peer        latest                           3b66e81870f0        5 minutes ago       126MB
hyperledger/fabric-peer        s390x-1.4.5-snapshot-189380870   3b66e81870f0        5 minutes ago       126MB
hyperledger/fabric-peer        s390x-latest                     3b66e81870f0        5 minutes ago       126MB
hyperledger/fabric-baseimage   s390x-0.4.18                     2dac0e897f90        3 months ago        1.22GB
hyperledger/fabric-baseos      s390x-0.4.18                     986ecfd780c6        3 months ago        78.3MB
```





2. Navigate to the fabric-samples directory. `cd ~/git/src/github.com/hyperledger/fabric-samples`

3. Navigate to the first-network directory. This is the sample that you will use in this lab. `cd first-network`   

4. View the options to run the sample script. `./byfn.sh -h`

   You will run the test using a script named byfn.sh in this directory. There are several arguments to this script. Invoke the script with the -h argument in order to display some help text.

```
   $ ./byfn.sh -h
   Usage:
     byfn.sh <mode> [-c <channel name>] [-t <timeout>] [-d <delay>] [-f <docker-compose-file>] [-s <dbtype>] [-l <language>] [-o <consensus-type>] [-i <imagetag>] [-v]
       <mode> - one of 'up', 'down', 'restart', 'generate' or 'upgrade'
   
      - 'up' - bring up the network with docker-compose up
      - 'down' - clear the network with docker-compose down
      - 'restart' - restart the network
      - 'generate' - generate required certificates and genesis block
      - 'upgrade'  - upgrade the network from version 1.3.x to 1.4.0
         <channel name> - channel name to use (defaults to "mychannel")
            -t <timeout> - CLI timeout duration in seconds (defaults to 10)
            -d <delay> - delay duration in seconds (defaults to 3)
            -f <docker-compose-file> - specify which docker-compose file use (defaults to docker-compose-cli.yaml)
            -s <dbtype> - the database backend to use: goleveldb (default) or couchdb
            -l <language> - the chaincode language: golang (default) or node
            -o <consensus-type> - the consensus-type of the ordering service: solo (default) or kafka
            -i <imagetag> - the tag to be used to launch the network (defaults to "latest")
            -v - verbose mode
```

   

5. Generate the artifacts needed to build a network. `./byfn.sh generate -c mychannel`

   Running byfn.sh with the generate argument is needed in order to generate the necessary cryptographic material and channel configuration for a channel named mychannel. If you wish to use a different channel name, maybe named after your favorite child or pet or car or football team or spouse, use the -c argument as well, but be aware that channel names must start with a lowercase character, and contain only lowercase characters, numbers, and a small number of punctuation characters such as a dash (-) and a couple others I can't remember right now. You'll also have to use this channel name on other inovcations of byfn.sh in subsequent steps. Just don't use uppercase letters, okay? (You can use uppercase numbers if that makes you feel better). The below examples show creating a channel named mychannel. Use mychannel or create your own name or leave the -c argument off altogether to use the default of mychannel. 

```
   $ ./byfn.sh generate -c mychannel
   Generating certs and genesis block for channel 'mychannel' with CLI timeout of '10' seconds and CLI delay of '3' seconds
   Continue? [Y/n] Y
   proceeding ...
   /home/ubuntu/git/src/github.com/hyperledger/fabric-samples/first-network/../bin/cryptogen
   
   ##########################################################
   
   ##### Generate certificates using cryptogen tool #########
   
   ##########################################################
   
   + cryptogen generate --config=./crypto-config.yaml
     org1.example.com
     org2.example.com
   + res=0
   + set +x
   
   /home/ubuntu/git/src/github.com/hyperledger/fabric-samples/first-network/../bin/configtxgen
   
   ##########################################################
   
   #########  Generating Orderer Genesis block ##############
   
   ##########################################################
   
   CONSENSUS_TYPE=solo
   
   + '[' solo == solo ']'
   + configtxgen -profile TwoOrgsOrdererGenesis -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block
     2019-01-15 11:35:34.252 EST [common.tools.configtxgen] main -> INFO 001 Loading configuration
     2019-01-15 11:35:34.284 EST [common.tools.configtxgen.localconfig] completeInitialization -> INFO 002 orderer type: solo
     2019-01-15 11:35:34.284 EST [common.tools.configtxgen.localconfig] Load -> INFO 003 Loaded configuration: /home/ubuntu /git/src/github.com/hyperledger/fabric-samples/first-network/configtx.yaml
     2019-01-15 11:35:34.317 EST [common.tools.configtxgen.localconfig] completeInitialization -> INFO 004 orderer type: solo
     2019-01-15 11:35:34.317 EST [common.tools.configtxgen.localconfig] LoadTopLevel -> INFO 005 Loaded configuration: /home/ubuntu/git/src/github.com/hyperledger/fabric-samples/first-network/configtx.yaml
     2019-01-15 11:35:34.319 EST [common.tools.configtxgen] doOutputBlock -> INFO 006 Generating genesis block
     2019-01-15 11:35:34.319 EST [common.tools.configtxgen] doOutputBlock -> INFO 007 Writing genesis block
   + res=0
   + set +x
   
   #################################################################
   
   ### Generating channel configuration transaction 'channel.tx' ###
   
   #################################################################
   
   + configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID tim
     2019-01-15 11:35:34.390 EST [common.tools.configtxgen] main -> INFO 001 Loading configuration
     2019-01-15 11:35:34.422 EST [common.tools.configtxgen.localconfig] Load -> INFO 002 Loaded configuration: /home/ubuntu /git/src/github.com/hyperledger/fabric-samples/first-network/configtx.yaml
     2019-01-15 11:35:34.452 EST [common.tools.configtxgen.localconfig] completeInitialization -> INFO 003 orderer type: solo
     2019-01-15 11:35:34.452 EST [common.tools.configtxgen.localconfig] LoadTopLevel -> INFO 004 Loaded configuration: /home/ubuntu/git/src/github.com/hyperledger/fabric-samples/first-network/configtx.yaml
     2019-01-15 11:35:34.452 EST [common.tools.configtxgen] doOutputChannelCreateTx -> INFO 005 Generating new channel configtx
     2019-01-15 11:35:34.453 EST [common.tools.configtxgen] doOutputChannelCreateTx -> INFO 006 Writing new channel tx
   + res=0
   + set +x
   
   #################################################################
   
   #######    Generating anchor peer update for Org1MSP   ##########
   
   #################################################################
   
   + configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP
     2019-01-15 11:35:34.518 EST [common.tools.configtxgen] main -> INFO 001 Loading configuration
     2019-01-15 11:35:34.548 EST [common.tools.configtxgen.localconfig] Load -> INFO 002 Loaded configuration: /home/ubuntu/git/src/github.com/hyperledger/fabric-samples/first-network/configtx.yaml
     2019-01-15 11:35:34.579 EST [common.tools.configtxgen.localconfig] completeInitialization -> INFO 003 orderer type: solo
     2019-01-15 11:35:34.579 EST [common.tools.configtxgen.localconfig] LoadTopLevel -> INFO 004 Loaded configuration: /home/ubuntu/git/src/github.com/hyperledger/fabric-samples/first-network/configtx.yaml
     2019-01-15 11:35:34.579 EST [common.tools.configtxgen] doOutputAnchorPeersUpdate -> INFO 005 Generating anchor peer update
     2019-01-15 11:35:34.579 EST [common.tools.configtxgen] doOutputAnchorPeersUpdate -> INFO 006 Writing anchor peer update
   + res=0
   + set +x
   
   #################################################################
   
   #######    Generating anchor peer update for Org2MSP   ##########
   
   #################################################################
   
   + configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP
     2019-01-15 11:35:34.656 EST [common.tools.configtxgen] main -> INFO 001 Loading configuration
     2019-01-15 11:35:34.703 EST [common.tools.configtxgen.localconfig] Load -> INFO 002 Loaded configuration: /home/ubuntu/git/src/github.com/hyperledger/fabric-samples/first-network/configtx.yaml
     2019-01-15 11:35:34.737 EST [common.tools.configtxgen.localconfig] completeInitialization -> INFO 003 orderer type: solo
     2019-01-15 11:35:34.737 EST [common.tools.configtxgen.localconfig] LoadTopLevel -> INFO 004 Loaded configuration: /home/ubuntu/git/src/github.com/hyperledger/fabric-samples/first-network/configtx.yaml
     2019-01-15 11:35:34.737 EST [common.tools.configtxgen] doOutputAnchorPeersUpdate -> INFO 005 Generating anchor peer update
     2019-01-15 11:35:34.737 EST [common.tools.configtxgen] doOutputAnchorPeersUpdate -> INFO 006 Writing anchor peer update
   + res=0
   + set +x
```

   

   6. Run the script using the channel generated in the prior step. `./byfn.sh up -l node -s couchdb -o kafka -c mychannel`

      Issuing the command starts the Hyperledger Fabric network using Node.js chaincode (the -l node argument and value), using CouchDB as the state database (the -s couchdb argument and value), the Kafka orderer consensus algorithm (the -o kafka argument and value, and the channel named mychannel (the -c mychannel argument and value). If your channel is not named mychannel use your correct channel name instead. If you want to try one of the other options for chaincode language, state database, or consensus algorithm, I applaud your curiosity and leave the determination of which options to choose as an exercise for the reader):

```
      $ ./byfn.sh up -l node -s couchdb -o kafka -c mychannel
         Starting for channel 'mychannel' with CLI timeout of '10' seconds and CLI delay of '3' seconds and using database 'couchdb'
         Continue? [Y/n] Y
          .
          . (output not shown)
          .
         ========= All GOOD, BYFN execution completed ===========
      
         _____   _   _   ____
      
         | ____| | \ | | |  _ \
         |  _|   |  \| | | | | |
         | |___  | |\  | | |_| |
         |_____| |_| \_| |____/
      
```

If you were following the output closely you may have noticed a few spots where the output paused for a little bit. This occurred at the point where a peer was building a new Docker image for chaincode. This occurs three times during the script. Additionally, Node.js chaincode takes longer for its Docker images to be built than does Go chaincode, so if you chose -l node the pause may have been long enough for you to worry a bit. But it's all good.

7. Run this command, `docker images dev-*` to see the three Docker images created for the chaincode. 

   These images will start with dev because this is the default name of a Hyperledger Fabric network and this script does not override the default:

```
$ docker images dev-*
REPOSITORY                                                                                             TAG                  IMAGE ID            CREATED             SIZE
dev-peer1.org2.example.com-mycc-1.0-26c2ef32838554aac4f7ad6f100aca865e87959c9a126e86d764c8d01f8346ab   latest              e35e3da4fba1        2 hours ago         1.55GB
dev-peer0.org1.example.com-mycc-1.0-384f11f484b9302df90b453200cfb25174305fce8f53f4e94d45ee3b6cab0ce9   latest              47f93d1b8fff        2 hours ago         1.55GB
dev-peer0.org2.example.com-mycc-1.0-15b571b3ce849066b7ec74497da3b27e54e0df1345daff3951b94245ce09c42b   latest              9929e2385ef9        2 hours ago         1.55GB
```

The second part of the Docker images name is the name of the peer for which the chaincode was created. This sample uses chaincode in three peers.



8. List the Docker containers that are running as part of this sample with this command. `docker ps -a`

```
$ docker ps -a
CONTAINER ID        IMAGE                                                                                                  COMMAND                  CREATED             STATUS              PORTS                      NAMES
87828b7c4878        dev-peer1.org2.example.com-mycc-1.0-26c2ef32838554aac4f7ad6f100aca865e87959c9a126e86d764c8d01f8346ab   "chaincode -peer.add…"   37 minutes ago      Up 37 minutes                                  dev-peer1.org2.example.com-mycc-1.0
34da6f5d254f        dev-peer0.org1.example.com-mycc-1.0-384f11f484b9302df90b453200cfb25174305fce8f53f4e94d45ee3b6cab0ce9   "chaincode -peer.add…"   37 minutes ago      Up 37 minutes                                  dev-peer0.org1.example.com-mycc-1.0
aa0bf82d58a0        dev-peer0.org2.example.com-mycc-1.0-15b571b3ce849066b7ec74497da3b27e54e0df1345daff3951b94245ce09c42b   "chaincode -peer.add…"   37 minutes ago      Up 37 minutes                                  dev-peer0.org2.example.com-mycc-1.0
7fcc3786a005        hyperledger/fabric-tools:latest                                                                        "/bin/bash"              38 minutes ago      Up 37 minutes                                  cli
1c003b7abee3        hyperledger/fabric-peer:latest                                                                         "peer node start"        38 minutes ago      Up 38 minutes       0.0.0.0:9051->9051/tcp     peer0.org2.example.com
7761aafabd9e        hyperledger/fabric-orderer:latest                                                                      "orderer"                38 minutes ago      Up 38 minutes       0.0.0.0:7050->7050/tcp     orderer.example.com
93bd4dc0374c        hyperledger/fabric-peer:latest                                                                         "peer node start"        38 minutes ago      Up 38 minutes       0.0.0.0:8051->8051/tcp     peer1.org1.example.com
95879547ace3        hyperledger/fabric-peer:latest                                                                         "peer node start"        38 minutes ago      Up 38 minutes       0.0.0.0:10051->10051/tcp   peer1.org2.example.com
c81c35ff5296        hyperledger/fabric-peer:latest                                                                         "peer node start"        38 minutes ago      Up 38 minutes       0.0.0.0:7051->7051/tcp     peer0.org1.example.com
```


You may have a different number of containers running depending on what options you chose for your byfn up command. If you did not choose couchdb as your state databse with the -s argument then you will not see the four couchdb containers (one for each peer). If you did not choose the Kafka orderer consensus algorithm with the -o argument then you will not see the kafka and zookeeper containers.



9. Run the following command pipe, `docker ps --no-trunc | grep dev-peer`, to show a more verbose output of the docker ps command which comes courtesy of the --no-trunc argument and then pipes the output through grep with a judicious string, dev-peer to filter the output such that you only see the output for the three chaincode containers:

```
   $ docker ps --no-trunc | grep dev-peer
   fa737dc9aee372a6c3b231218581f10487b40b42fd368e09bd62908277c5f3f7   dev-peer1.org2.example.com-mycc-1.0-26c2ef32838554aac4f7ad6f100aca865e87959c9a126e86d764c8d01f8346ab   "/bin/sh -c 'cd /usr/local/src; npm start -- --peer.address peer1.org2.example.com:7052'"   2 hours ago         Up 2 hours                                                             dev-peer1.org2.example.com-mycc-1.0
   7ce34a33cf7baeae846f83ffcd4db57607c42282be784afa5ee62fe3805d7df1   dev-peer0.org1.example.com-mycc-1.0-384f11f484b9302df90b453200cfb25174305fce8f53f4e94d45ee3b6cab0ce9   "/bin/sh -c 'cd /usr/local/src; npm start -- --peer.address peer0.org1.example.com:7052'"   2 hours ago         Up 2 hours                                                             dev-peer0.org1.example.com-mycc-1.0
   0f7e7f6cad01215d306b2020c9e6d190aff69b47bc6b93c4fc46e4ae522f8ce1   dev-peer0.org2.example.com-mycc-1.0-15b571b3ce849066b7ec74497da3b27e54e0df1345daff3951b94245ce09c42b   "/bin/sh -c 'cd /usr/local/src; npm start -- --peer.address peer0.org2.example.com:7052'"   2 hours ago         Up 2 hours                                                             dev-peer0.org2.example.com-mycc-1.0
```

   In the above output you'll see the command used to start the container- e.g., "/bin/sh -c 'cd /usr/local/src; npm start -- --peer.address peer1.org2.example.com:7052'" for the first container listed. The npm start command is your clue that this is a Node.js container- npm is the de facto Node.js package manage, despite the authors of npm claiming that npm is not an acronym. 

10. Run this command to stop the Hyperledger Network. `./byfn.sh down`

```
   $ ./byfn.sh down
   Stopping for channel 'mychannel' with CLI timeout of '10' seconds and CLI delay of '3' seconds
   Continue? [Y/n] Y
    .
    . (output not shown)
    .
```

   

11. Run the command, `docker ps --all`, to see if there are any running Docker containers:

```
$ docker ps --all
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```
The script has removed all of the Docker containers.



12. Check to see if there are any Docker images for the chaincode. `docker images dev-*`

```
$ docker images dev-*
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
```
There are no Docker chaincode images remaining as well.

### Reviewing Lab 1

In this lab you used a sample from Hyperledger Fabric called, "build your first network", to verify the installation of Hyperledger Fabric. Once the test completed successfully, you used the same script with different parameters to take down the network and remove the imsages. 



## End of Lab1!

 Continue on to Lab 2.



© 2020 International Business Machines Corporation. No part of this document may be reproduced or transmitted in any form without written permission from IBM

