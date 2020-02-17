**** Major thanks to IBM Washington Systems Center and Bruce Almighty Gilkes for their help ****

This lab is a technical introduction to blockchain, specifically smart contract development using the latest developer enhancements in the Linux Foundation’s Hyperledger Fabric v1.4.

This lab is based on Hyperledger Fabric commercial paper tutorial, that can be found here:
https://hyperledger-fabric.readthedocs.io/en/latest/tutorial/commercial_paper.html

Part I
In this lab, we will take you through connecting to an existing network, one that is running outside of in Visual Studio Code (VS Code). The network we will be using is the ‘basic-network’ used by the “Commercial Paper” Hyperledger Fabric tutorial, and we will stand this network up, run through a simple version of the tutorial and then extend the network with a new smart contract transaction.

The scenario the tutorial follows is one of a commercial paper trading network called PaperNet. Commercial paper itself is a type of unsecured lending in the form of a “promissory note”. The papers are normally issued by large corporations to raise funds to meet short-term financial obligations at a fixed rate of interest. Once issued at a fixed price, for a fixed term, another company or bank will purchase them at a discount to the face value and when the term is up, they will be redeemed for their face value.
As an example, if a paper was issued at a face value of 10 million USD for a 6-month term at 2% interest then it could be bought for 9.8 million USD (10M – 2%) by another company or bank who are happy to bear the risk that the issuer will not default. Once the term is up, then the paper could be redeemed or sold back to the issuer for their full face value of 10 million USD. Between buying and redemption, the paper can be bought or sold between different parties on a commercial paper market.
These three key steps of issue, buy and redeem are the main transactions in a simplified commercial paper marketplace, which we will mirror in our lab. We will see a commercial paper issued by a company called MagnetoCorp, and once issued on the PaperNet blockchain network another company called DigiBank will first buy the paper and then redeem it.
In diagram form it looks like this:

https://github.com/AnkaShugol/BlockchainBreakfast/blob/master/img/Architecture.png

0. Let's clean up from the previous lab, making sure that all docker containers are stopped and removed:

docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

1. Enter the following cd command to change directory to the basic network folder that we will use for this lab:

ubuntu@jf01:~$ cd git/src/github.com/hyperledger/fabric-samples/basic-network/
ubuntu@jf01:~/git/src/github.com/hyperledger/fabric-samples/basic-network$ 

2. Type the ls command and press enter to see the files that make up the basic- network.

ubuntu@jf01:~/git/src/github.com/hyperledger/fabric-samples/basic-network$ ls
README.md  configtx.yaml    connection.yaml  crypto-config.yaml  generate.sh  start.sh  teardown.sh
config     connection.json  crypto-config    docker-compose.yml  init.sh      stop.sh


These files contain the configuration for the basic-network along with a script to set it up. Feel free to have a look at their contents if you are curious. The main files of interest are start.sh and docker-compose.yml; you can open the files to view them with a command like “code start.sh” but make sure you do not change the contents of any of the files.

3. To start the network running, run the following command in your terminal start.sh: 

ubuntu@jf01:~/git/src/github.com/hyperledger/fabric-samples/basic-network$ ./start.sh
Note: make sure you enter the period ( . ) at the beginning of this command or the command will not be found.
This command is a script that starts the docker containers that make up the basic network and may take a minute or so to run. The command may output a warning which you can ignore. When it has finished, your terminal should look something like this:

# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel create -o orderer.example.com:7050 -c mychannel -f /etc/hyperledger/configtx/channel.tx
2020-01-23 16:59:10.530 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2020-01-23 16:59:10.560 UTC [cli.common] readBlock -> INFO 002 Received block: 0
# Join peer0.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join -b mychannel.block
2020-01-23 16:59:10.908 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2020-01-23 16:59:10.982 UTC [channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel

Now let's take a look at the containers.

4. Run the command below in your terminal docker ps:
This command lists the docker containers that are running. Although this output is a little hard to read, you can make your terminal window wider to see the output better if you wish. 
This command shows that we have started four containers, one for each of the Hyperledger fabric-peer, fabric-ca, fabric-couchdb and fabric-orderer components. 
Together these make up the simple basic-network that we will be using. A more realistic setup would have multiple copies of the components to better reflect the multiple parties in the network, but for a lab this simple network will suffice. 

ubuntu@jf01:~/git/src/github.com/hyperledger/fabric-samples/basic-network$ docker ps
CONTAINER ID        IMAGE                              COMMAND                  CREATED             STATUS              PORTS                                            NAMES
f3e4a0c597fd        hyperledger/fabric-peer:1.4.1      "peer node start"        31 seconds ago      Up 29 seconds       0.0.0.0:7051->7051/tcp, 0.0.0.0:7053->7053/tcp   peer0.org1.example.com
b6e69ff6af06        hyperledger/fabric-orderer:1.4.1   "orderer"                34 seconds ago      Up 32 seconds       0.0.0.0:7050->7050/tcp                           orderer.example.com
30d71804d58d        hyperledger/fabric-ca:1.4.1        "sh -c 'fabric-ca-se…"   34 seconds ago      Up 33 seconds       0.0.0.0:7054->7054/tcp                           ca.example.com
8508faada7f5        hyperledger/fabric-couchdb         "tini -- /docker-ent…"   34 seconds ago      Up 31 seconds       4369/tcp, 9100/tcp, 0.0.0.0:5984->5984/tcp       couchdb

Basic network:

5. These containers are joined together into the same docker network called net_basic. A docker network lets containers communicate with each other. Take a look at the network by running this command to inspect it:

docker network inspect net_basic
You should see output similar to this:

ubuntu@jf01:~/git/src/github.com/hyperledger/fabric-samples/basic-network$ docker network inspect net_basic
[
    {
        "Name": "net_basic",
        "Id": "0cd8c5d6a9aa8d355087b136e705207bc493c596ee9844cc3cf0f59b196fc3b2",
        "Created": "2020-01-23T17:52:01.788235583Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "192.168.64.0/20",
                    "Gateway": "192.168.64.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "30d71804d58de41efc59dbb7fd12cd6fa0ddb8b16c671d3345d4d6975b649329": {
                "Name": "ca.example.com",
                "EndpointID": "4b83e80873897bf3577811578099dc69a50aee4f59669b7d30bf43e7f5fa1d4f",
                "MacAddress": "02:42:c0:a8:40:02",
                "IPv4Address": "192.168.64.2/20",
                "IPv6Address": ""
            },
            "8508faada7f516fcb33165248114c26b1dd00baae9a96bb62539e2f7d1792f35": {
                "Name": "couchdb",
                "EndpointID": "6a9cb14f1417afde230adcd780d572e76a46a4fbf2ca6a964b0a7dd018c8caa3",
                "MacAddress": "02:42:c0:a8:40:03",
                "IPv4Address": "192.168.64.3/20",
                "IPv6Address": ""
            },
            "b6e69ff6af067e51192deb6799f63a985da7c437aec8a7614e73aa0588f61304": {
                "Name": "orderer.example.com",
                "EndpointID": "ac7d9726ecdf04e638132f7dfba9c6c7a8f6dc6ad85c65bb0f0aba0ab13cbad1",
                "MacAddress": "02:42:c0:a8:40:04",
                "IPv4Address": "192.168.64.4/20",
                "IPv6Address": ""
            },
            "f3e4a0c597fdec085bd0cf52e77fcb034df7d4c46e56bb56024d1f6a8feb4d67": {
                "Name": "peer0.org1.example.com",
                "EndpointID": "e127d2191ec9c79bc95e29ecd103495ee960d04179ea2800f3f6643ccaa0bacf",
                "MacAddress": "02:42:c0:a8:40:05",
                "IPv4Address": "192.168.64.5/20",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
ubuntu@jf01:~/git/src/github.com/hyperledger/fabric-samples/basic-network$ 

Scroll back up and look at the output. You can see that each of the containers have their own IP address inside the same network so they can communicate with each other.
Next, we will begin working as if we were an administrator for MagnetoCorp who would want to see combined logs from all these components. Although proper dashboards could be created, we will use a simple log viewing tool in this lab.


6. From the terminal, change to the following folder:
    cd ../commercial-paper/organization/magnetocorp/configuration/cli/
The full path should now be showing as:

ubuntu@jf01:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/configuration/cli$ 

Next, we are going to act as a MagnetoCorp administrator again and interact with the network. To do this we need to issue commands to the peer to install and instantiate smart contracts (also known as chaincode).  

Part II Running the Issue transaction as MagnetoCorp

First, let’s give our terminal a name so we know who we are running as by issuing the command:
   set-title MagnetoCorp
Prior to that, we need to add the set-title command to $HOME/.bashrc, by copying the following:

set-title(){
  ORIG=$PS1
  TITLE="\e]2;$@\a"
  PS1=${ORIG}${TITLE}
}

7. After that, let's reload our environment by issuing the command source $HOME/.bashrc

ubuntu@jf01:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/configuration/cli$ source $HOME/.bashrc

And let's give our terminal a name MagnetoCorp:
ubuntu@jf01:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/configuration/cli$ set-title MagnetoCorp

8. The Fabric commands we need to use are in the fabric-tools docker image, so let’s start it running by issuing this docker-compose command to start the container:
docker-compose -f docker-compose.yml up -d cliMagnetoCorp

ubuntu@jf01:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/configuration/cli$ docker-compose -f docker-compose.yml up -d cliMagnetoCorp

If we run the docker ps command again we should see that the new container is running. 

ubuntu@jf01:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/configuration/cli$ docker ps
CONTAINER ID        IMAGE                              COMMAND                  CREATED             STATUS              PORTS                                            NAMES
ef8200f4e3ca        hyperledger/fabric-tools:1.4.1     "/bin/bash"              46 seconds ago      Up 41 seconds                                                        cliMagnetoCorp
f3e4a0c597fd        hyperledger/fabric-peer:1.4.1      "peer node start"        About an hour ago   Up About an hour    0.0.0.0:7051->7051/tcp, 0.0.0.0:7053->7053/tcp   peer0.org1.example.com
b6e69ff6af06        hyperledger/fabric-orderer:1.4.1   "orderer"                About an hour ago   Up About an hour    0.0.0.0:7050->7050/tcp                           orderer.example.com
30d71804d58d        hyperledger/fabric-ca:1.4.1        "sh -c 'fabric-ca-se…"   About an hour ago   Up About an hour    0.0.0.0:7054->7054/tcp                           ca.example.com
8508faada7f5        hyperledger/fabric-couchdb         "tini -- /docker-ent…"   About an hour ago   Up About an hour    4369/tcp, 9100/tcp, 0.0.0.0:5984->5984/tcp       couchdb

Both of these containers have also been added to the net_basic network as well and you can run the docker network inspect net_basic command again if you want to see this for yourself.
Next we will begin to deploy the PaperNet smart contract.

9. Change directory to the magnetocorp/contract folder:
      cd ../../contract/
   The directory should be: ubuntu@jf01:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/contract$    
   
10. Let's take a look at the smart contract papercontract.js code, you can do it either from a terminal, or from the browser, follow the link:
https://github.com/hyperledger/fabric-samples/blob/release-1.4/commercial-paper/organization/magnetocorp/contract/lib/papercontract.js

11. 19. Let’s expand the issue transaction and take a look so we can see what it will do.
Line 68 creates a new CommercialPaper object from the parameters passed in using the static createInstance method on the CommercialPaper class. This class is defined in the separate “paper.js” file which is also if the lib folder alongside papercontract.js if you want to take a look at this method.
Line 71 then moves the newly created paper into the ISSUED state and on line 74 it has its owner set from the parameters passed in.
Line 77 adds the paper to a “paperList” which is responsible for storing the state of the paper in the world state. This is defined in the paperlist.js file if you want to take a deeper look.
Line 80 then returns the paper to the client who called this transaction.

Now we are going to install the papercontract onto a peer in the network.

11. Let's go back to MagnetoCorp terminal window and issue the following command:
   docker exec cliMagnetoCorp peer chaincode install -n papercontract -v 0.0.3 -p /opt/gopath/src/github.com/contract -l node
Note: The above command must be entered as a single line. Be sure to copy /paste and enter it as a single line.

Note 2: In the above command, the flags are case-sensitive and the flag “-l” is a letter “l” for language and not a number one.

The output should be something like this one:

2020-01-23 18:57:30.846 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 001 Using default escc
2020-01-23 18:57:30.846 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default vscc
2020-01-23 18:57:30.866 UTC [chaincodeCmd] install -> INFO 003 Installed remotely response:<status:200 payload:"OK" > 
ubuntu@jf01:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/contract$ 

This command uses the cliMagnetoCorp container which was configured to send commands to peer0.org1.example.com in our basic network. Its main role is to copy the papercontract source code and send it to the remote peer, ready for it to be instantiated.


https://github.com/AnkaShugol/BlockchainBreakfast/blob/master/img/PaperNet.png

12. To instantiate the contract on peer0, issue the following command at the
MagnetoCorp terminal:
   docker exec cliMagnetoCorp peer chaincode instantiate -n papercontract -v 0.0.3 -l node -c '{"Args":["org.papernet.commercialpaper:instantiate"]}' -C mychannel -P "AND ('Org1MSP.member')"
Note: As before, the above command must be entered as a single line. If you copy and paste it from here, be sure to enter it as a single line. 
Again, remember, the flags are case-sensitive and the flag “-l” is a letter “l” for language and not a number one.

The result should be like this, you should see the new container with the chaincode. Issue docker ps :

ubuntu@qa10:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/contract$ docker ps
CONTAINER ID        IMAGE                                                                                                             COMMAND                  CREATED             STATUS              PORTS                                            NAMES
5e1ab12c75b7        dev-peer0.org1.example.com-papercontract-0.0.3-5f1d60e28249e81faa02102ce57e28b86443fdc9c08e350371a8b90ac690ae6e   "/bin/sh -c 'cd /usr…"   57 seconds ago      Up 55 seconds                                                        dev-peer0.org1.example.com-papercontract-0.0.3
55fcebc5df47        hyperledger/fabric-tools                                                                                          "/bin/bash"              3 minutes ago       Up 3 minutes                                                         cliMagnetoCorp
232ad9d42298        hyperledger/fabric-peer                                                                                           "peer node start"        4 minutes ago       Up 4 minutes        0.0.0.0:7051->7051/tcp, 0.0.0.0:7053->7053/tcp   peer0.org1.example.com
5ad2a5616f28        hyperledger/fabric-orderer                                                                                        "orderer"                4 minutes ago       Up 4 minutes        0.0.0.0:7050->7050/tcp                           orderer.example.com
3c64cd01840b        hyperledger/fabric-couchdb                                                                                        "tini -- /docker-ent…"   4 minutes ago       Up 4 minutes        4369/tcp, 9100/tcp, 0.0.0.0:5984->5984/tcp       couchdb
c288fb3e9dd2        hyperledger/fabric-ca                                                                                             "sh -c 'fabric-ca-se…"   4 minutes ago       Up 4 minutes        0.0.0.0:7054->7054/tcp                           ca.example.com

This command also uses the cliMagnetoCorp container to cause the contract to become instantiated on the mychannel channel. In addition, it also invokes the instantiate transaction as part of the command which allows any required initialisation to take place. Finally, note the last option – the -P flag which specifies which organisations in the network need to endorse the transactions issued by this contract before they will be considered valid.
Note that this command may take a little time to run as it will cause the peer to create a new docker container to be created to run the contract in.

 
 
 13.  If you wish to see this new container, run the docker ps command again – it should have a name beginning with: dev-peer0.org1.example.com-papercontract-0.

Now the contract is up and running, it is time to start running transactions, and to start things moving, MagnetoCorp is going to run an application to issue the first commercial paper on the PaperNet network. To do this we are going to act as Isabella, an employee of MagnetoCorp.

14. Change to the folder that contains the issue application. 

cd ../application/

ubuntu@qa10:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/application$ 

15. Run the ls command to see the files in this folder: ls
We see that there are several files:

ubuntu@qa10:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/application$ ls
addToWallet.js  issue.js  package-lock.json  package.json

Next let’s take a look at the issue application.

16. Take a look at the code for the issue application. The main points are:

Lines 18 - 21: Import various dependencies
Line 25: Load the identity from the wallet on the file system
Line 31: Create a new gateway
Line 41: Load the connection profile from file system
Line 53: Connect to the gateway
Line 58: Get the mychannel channel from the gateway network
Line 63: Get the papercontract contract from the gateway
Line 68: Use the contract to submit the issue transaction, passing in the details of the paper to be issued.
Line 71: Log the response
As we can see above on line 25, the issue application will need to load Isabella’s identity before it can create the transaction, so we need to make sure her identity is in the wallet that the issue application will use as shown in this diagram:



However, before we can run the application, we need to download the dependencies listed in the package.json file from npm


17. Switch back to the MagnetoCorp terminal and issue this command:
npm install
Note: This will take a while to download the dependencies and you may see a slightly different output to that shown below.

If you have issues with accessing the directory, you should run 
sudo chown ubuntu /home/ubuntu/git and then retry npm install

When the download has finished, if you run ls again, you will see a new node_modules folder has been created. It is the node_modules folder that contains the dependencies.

 COPY Release/grpc_node.node
  COPY /home/ubuntu/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/application/node_modules/grpc/src/node/extension_binary/node-v64-linux-s390x-glibc/grpc_node.node
  TOUCH Release/obj.target/action_after_build.stamp
make: Leaving directory '/home/ubuntu/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/application/node_modules/grpc/build'
npm WARN nodejs@1.0.0 No description
npm WARN nodejs@1.0.0 No repository field.

added 323 packages from 231 contributors and audited 1950 packages in 114.558s
found 1 critical severity vulnerability
  run `npm audit fix` to fix them, or `npm audit` for details
  
  
18. Now we are almost ready to issue a new commercial paper, we just need to load Isabella’s digital certificate into the wallet before we can use it. 
To do this we run the following application:
   node addToWallet.js

ubuntu@qa10:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/application$ node addToWallet.js
done

addToWallet simply copies an identity from the basic-network to our wallet location for use by other applications.

19. Run this command to see the contents of the newly created wallet:
      ls ../identity/user/isabella/wallet/
      
ubuntu@qa10:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/application$  ls ../identity/user/isabella/wallet/
User1@org1.example.com

Now you can see the User1@org1.example.com folder which is used by the issue application. If we run another command, we can see the three files that make up the identity itself:
ls ../identity/user/isabella/wallet/User1@org1.example.com

ubuntu@qa10:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/application$ ls ../identity/user/isabella/wallet/User1@org1.example.com
User1@org1.example.com  c75bd6911aca808941c3557ee7c97e90f3952e379497dc55eb903f31b50abc83-priv  c75bd6911aca808941c3557ee7c97e90f3952e379497dc55eb903f31b50abc83-pub

These files consist of a private key for signing transactions, a public key linked to the private key and a file that contains both metadata and a certificate for our user.

20. Now we can finally issue the commercial paper by running:

node issue.js

ubuntu@qa10:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/application$ node issue.js
Connect to Fabric gateway.
Use network channel: mychannel.
Use org.papernet.commercialpaper smart contract.
Submit commercial paper issue transaction.
Process issue transaction response.{"class":"org.papernet.commercialpaper","key":"\"MagnetoCorp\":\"00001\"","currentState":1,"issuer":"MagnetoCorp","paperNumber":"00001","issueDateTime":"2020-05-31","maturityDateTime":"2020-11-30","faceValue":"5000000","owner":"MagnetoCorp"}
MagnetoCorp commercial paper : 00001 successfully issued for value 5000000
Transaction complete.
Disconnect from Fabric gateway.
Issue program complete.


From the output you can see that we followed the steps outlined above to successfully issue commercial paper 00001 for 5,000,000 USD. We have submitted the transaction to the network and the contract has written these details to the world state and the ledger. 
The transaction was also endorsed and validated before it was committed.

Part III Working as DigiCorp
21. Now that we have issued paper 00001, we want to take on the persona of an employee of DigiBank who is going to buy and redeem this paper. 


22. Let’s open up a new tabbed terminal window so we can act as Balaji, an employee
of DigiBank. 

For ease of use, let’s give this new terminal tab a name: 

set-title DigiBank

Now we can easily switch between the different users as required by clicking on the tab for the user we want.

As DigiBank, let’s change to DigiBank’s application folder: cd ../../digibank/application/

The full path: 

ubuntu@qa10:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/digibank/application$ 

23. Let’s have a look at what files we have in this folder by running:
ls

ubuntu@qa10:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/digibank/application$ ls
addToWallet.js  buy.js  package-lock.json  package.json  redeem.js

We can see this is similar to MagnetoCorp’s application folder, but this time we have three different applications, buy.js, redeem.js and getPaper.js instead of issue.js.
Note: getPaper.js is added as part of this lab, and it is not part of the original Commercial Paper tutorial. 
The contents of this file are shown in the appendix to this lab guide.

24. As before, before we can run anything, we need to download the dependencies from npm:
npm install

Note: remember this can take a while to complete.

25. As we are going to be running as Balaji, we need to load the identity they are going
to use into DigiBank’s wallet, just like we did for Isabella earlier: 

node addToWallet.js

26. Let’s take a quick look again at the identity the application copied: 
ls ../identity/user/balaji/wallet/

ubuntu@qa10:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/digibank/application$ ls ../identity/user/balaji/wallet/
Admin@org1.example.com

This time you can see the identity is Admin@org1.example.com, as Balaji is acting as an admin for DigiBank.

Just like last time, we can also run another command, we can see the three files that make up the identity itself:
ls ../identity/user/balaji/wallet/Admin@org1.example.com

ubuntu@qa10:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/digibank/application$ ls ../identity/user/balaji/wallet/Admin@org1.example.com
Admin@org1.example.com  cd96d5260ad4757551ed4a5a991e62130f8008a0bf996e4e4b84cd097a747fec-priv  cd96d5260ad4757551ed4a5a991e62130f8008a0bf996e4e4b84cd097a747fec-pub

Again, these files consist of a private key for signing transactions, a public key linked to the private key and a file that contains both metadata and a certificate for our user.
Now Balaji from DigiBank would like to buy the commercial paper 00001. 

Part IV Running the Buy and Redeem transactions as DigiBank


27. In the same DigiBank terminal, run the buy application:
node buy.js

ubuntu@qa10:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/digibank/application$ node buy.js 
Connect to Fabric gateway.
Use network channel: mychannel.
Use org.papernet.commercialpaper smart contract.
Submit commercial paper buy transaction.
Process buy transaction response.
MagnetoCorp commercial paper : 00001 successfully purchased by DigiBank
Transaction complete.
Disconnect from Fabric gateway.
Buy program complete.

As you can see the transaction went through successfully, and paper 0001 is now owned by DigiBank.

28. Next, let’s assume that the maturity date has been reached and DigiBank wants to redeem the paper. Also in the DigiBank terminal, let’s run the redeem application as Balaji:
   node redeem.js
   
ubuntu@qa10:~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/digibank/application$ node redeem.js 
Connect to Fabric gateway.
Use network channel: mychannel.
Use org.papernet.commercialpaper smart contract.
Submit commercial paper redeem transaction.
Process redeem transaction response.
MagnetoCorp commercial paper : 00001 successfully redeemed with MagnetoCorp
Transaction complete.
Disconnect from Fabric gateway.
Redeem program complete.

Again the transaction has run smoothly, and the paper was redeemed with MagnetoCorp.

* End of the lab *

© 2020 International Business Machines Corporation. No part of this document may be reproduced or transmitted in any form without written permission from IBM.
