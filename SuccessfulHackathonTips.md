# Tips for a successful Hackathon



### You're going to have some awesome ideas. You'll want to present the big idea, but you'll need to narrow it down to a very small one.



##### For example:

<u>Big idea:</u> Tracking all foods from farm to table.
* Participants: Shipping companies, farmers, store
* Asset(s): any type of food imaginable. Each food will need a unique identifier.
* Transactions: foodMade, foodShippedFromFarm, foodReceivedShipping, foodDeliveredStore, etc.

<u>Small one to prototype:</u> Tracking a **fresh** avocado from Farmer Joe to a Walmart Store.

* Participants: FarmerJoe, WalmartStoreA, OurShippingCompany
* Asset: Avocado
  * Contains information like isFresh:bool, unique identifier, grownBy, harvestDate, shippedBy
* Transactions: harvestFood, shipFood, receiveFood, purchaseFood
  * shipFood might contain IoT data about the conditions it was shipped in to make sure it stayed in acceptable ranges but this would be out of the scope of a hackathon weekend.



### Really build your usecase to show it is original



1. If you can (and you should) Google your usecase idea and find something very similar, it isn't that original. See how else you could approach it or see if there are things about Marist you could add to make it original then what others have done or thought of.
2. Google to find statistics about how your idea would improve student life.
3. Put in the time and effort to make sure you have a very good idea that could be impactful.



### Building your prototype



Building your prototype breaks down into three areas:

1. **A front end** -- this is the pretty thing that we all like to interact with. You may or may not have time to actually make it connect to the back end. It's okay if it doesn't, but it's awesome when it can. Do make sure you make some time of mockup/design for what this should be like.

2. **The chaincode/contract** -- This is what you worked with in Lab 2 that lived in the contract folder. The commercial paper example is written in Node/JavaScript. This is a widely documented language. USE IT! It'll be MUCH easier then using Golang.

   COMPLETE LAB 2!!! Build from the Commerical Paper example. In a simple summary, you'll have two companies with their own credentials. You'll have an asset. Change the names in the sample code to make it match your use case, but a good foundation is already setup for you.

   

   <u>ALWAYS</u> edit the code and keep it in ~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/contract. The cliMagnetoCorp you created in Lab 2 knows to look in this location when you run a `docker exec cliMagnetoCorp .  . . ` command to do something with chaincode. Deviating from that will cost you time you don't have.

   

3. **The application** -- this was the thing like `getPaper.js` and `buy.js`. This is code that talks to the blockchain and runs transactions. Your front end can call these! Basically this is what puts things on the blockchain. These files existed in ~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/magnetocorp/application and ~/git/src/github.com/hyperledger/fabric-samples/commercial-paper/organization/digibank/application. Use/modify/add to these!

   I'd also encourage you to use the wallets already created by the sample because it'll save you time. You can talk to more complex permissions in your presentation.



### Coding

You can use VSCode and GitHub. The main reason to use VSCode is for the prompts it can give you on how to use the language and to show you where you might have errors in your code. If you want to compile locally on your laptop and not on LinuxONE, you can. It will be on you to figure out how to get Node installed for VSCode at version 8.9.4. 

If you use VSCode, I highly recommend you use GitHub too! It makes it easier to make sure your pushing the code to server to then pull it onto LinuxONE. If you stay in the repo we created in Lab2, you should be set for the weekend. Just add to it.



You can also code in the terminal for LinuxONE Community Cloud. You'll need to use VI or install nano. `sudo zypper install nano` for SLES or `sudo yum install nano`for RHEL. I think using nano is much easier then vi.



### Divide and conquer

Split the work up amongst teammates. Recommendation:

* 2 people working on the chaincode and application.
* 1 person working on the front end
* 1-2 people working on building the usecase and presentation.



### Managing your time

**By Saturday morning**: Make sure you've done all of the labs in the repository . . . or at least that your coders for the weekend have.

**By Saturday lunchtime (or earlier):** Make sure you have a solid idea that is approved by mentors and experts on hand before you start coding.

**Saturday lunchtime:** Coding should be in full swing! Keep your coders well nourished and entertained. :)

**Saturday late night:** If your code isn't working, that's okay. Take a break, step back and figure out how to make it simpler and just get SOMETHING setup/working. Any one thing.

**Sunday morning:** Coding should be wrapping up and finishing touches on presentation and front end should be happening.



### Presenting to the judges

Only 1 person, maybe 2, should present! Transitions are alway awkward and take time. You won't have long to present to minimise things that will take away from the actual content.

* Introduce the whole team quickly. That should just be done by 1 person.
* If you split the presentation, have one person do the business case and one person do the technical side/demo.
* Make sure to arrange the presentation so that a transition only happens once.



