Setting up a private Harmony blockchain with a 50 KB contract limit and USD as the native unit of account, along with two chains for test and live environments, requires customizing the Harmony environment. Here's a step-by-step guide to setting up both private chains—one using Stripe’s Test API and the other using the Live API.

### 1. **Prepare the Harmony Blockchain Environment**

   - **Install Docker**: Docker is the simplest way to deploy Harmony nodes for private networks.
   - **Install Go** (optional, only if building from source is required).
   - **Clone Harmony's GitHub Repository**:
     ```bash
     git clone https://github.com/harmony-one/harmony.git
     cd harmony
     ```

   - **Edit Contract Size Limit**:
     - Open the Harmony source files and locate the EVM configuration for contract size limits (usually in EVM constants or configuration files).
     - Modify the contract size limit from **24 KB to 50 KB** in the appropriate code location.

   - **Build from Source** (if required):
     ```bash
     make all
     ```

   - **Docker Setup for Private Network**:
     - For simplicity, we will run Docker containers for each private chain (TEST and LIVE).

### 2. **Customize for USD as the Unit of Account**

   - **Deploy a Custom USD Token**:
     - Create an ERC-20 smart contract named `USDToken` with `USD` as the symbol.
     - Use a Solidity compiler (like Remix) to compile and deploy this contract to each private chain (both TEST and LIVE).

     Here’s a basic ERC-20 smart contract:

     ```solidity
     pragma solidity ^0.8.0;
     import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

     contract USDToken is ERC20 {
         constructor(uint256 initialSupply) ERC20("USD Token", "USD") {
             _mint(msg.sender, initialSupply * (10 ** decimals()));
         }
     }
     ```

   - **Deploy this contract to your private networks**: Ensure each network has an initial USD supply minted to an account for testing and live transactions.

### 3. **Setup Chain Identifiers and Stripe API Integration**

   - **Network Identification**:
     - Each network can be distinguished by a unique chain ID and network name.
     - Assign **chain ID 59601** to `ELMX LOCALNET TEST` and **chain ID 59602** to `ELMX LOCALNET LIVE`.

   - **Docker Setup for Two Separate Chains**:
     - Run each node in Docker, specifying unique ports and chain IDs for TEST and LIVE environments.

     ```bash
     # Start ELMX LOCALNET TEST
     docker run -d --name elmx-test -p 9500:9500 -p 9501:9501 harmonyone/harmony --network-id 59601 --network-name "ELMX LOCALNET (TEST)"

     # Start ELMX LOCALNET LIVE
     docker run -d --name elmx-live -p 9600:9500 -p 9601:9501 harmonyone/harmony --network-id 59602 --network-name "ELMX LOCALNET (LIVE)"
     ```

   - **Stripe API Integration**:
     - Implement smart contracts or off-chain code that interacts with Stripe's API (Test API for the TEST chain, Live API for the LIVE chain).
     - Use Node.js or Python to handle Stripe payments for each network based on chain ID:
       - For `ELMX LOCALNET (TEST)`, use Stripe Test API keys.
       - For `ELMX LOCALNET (LIVE)`, use Stripe Live API keys.

### 4. **Setup Node.js Backend for Stripe Payments**

   - **Install Node.js Stripe Library**:
     ```bash
     npm install stripe
     ```

   - **Backend Code to Handle Stripe Transactions**:
     Create a Node.js server that checks which network (TEST or LIVE) it’s connected to and uses the corresponding Stripe API key.

     ```javascript
     const express = require('express');
     const stripe = require('stripe')(process.env.STRIPE_API_KEY);
     const app = express();

     app.post('/charge', async (req, res) => {
         const { amount, currency } = req.body;

         try {
             const paymentIntent = await stripe.paymentIntents.create({
                 amount,
                 currency,
             });
             res.send(paymentIntent);
         } catch (error) {
             res.status(500).send({ error: error.message });
         }
     });

     // Identify TEST or LIVE chain
     const chainId = process.env.CHAIN_ID;
     if (chainId === "1") {
         process.env.STRIPE_API_KEY = 'sk_test_xxxxx';
     } else if (chainId === "2") {
         process.env.STRIPE_API_KEY = 'sk_live_xxxxx';
     }

     app.listen(3000, () => {
         console.log(`Server running on chain ${chainId}`);
     });
     ```

   - **Start Backend**:
     - Run this backend server on separate instances for each network, setting `CHAIN_ID` and `STRIPE_API_KEY` accordingly.

### 5. **Testing and Deploying**

   - **Interact with Private Networks**: Use MetaMask or Harmony’s CLI with custom RPC URLs pointing to the ports of `ELMX LOCALNET TEST` and `ELMX LOCALNET LIVE`.
   - **Verify Transactions in USD**: Ensure transactions use USD and contract size limits are set to 50 KB.
   - **Deploy Smart Contracts and Test Stripe Integration**: Test both the TEST and LIVE networks by deploying contracts and initiating USD-based transactions, verifying that the correct Stripe API (test or live) is used accordingly.

With these steps, you’ll have a private Harmony blockchain network with a 50 KB contract size limit, USD as the base token, and integration with Stripe’s API for USD transactions. Let me know if you'd like to dive deeper into any particular part of this setup!