# UpOnly Protocol

The UpOnly Protocol is a modular collection of smart contracts that work together to create a system that lets the users:
1. Create a new token & generate a bonding curve market for the created token. 
2. Trade the newly created token until it hits the liquidity cap. 
3. Safely move the token to a DEX on reaching the liquidity cap. 

Users do not decide:
1. The initial supply of the token. 
2. The initial reserves of the token. 


## Smart Contracts

1. **Market Factory:**
This contract facilitates the creation of new markets. It deploys a manager, a token, and a curve. Then, it assigns the correct parameters to each of those contracts. 


2. **Market Manager:**
This contract stores all the necessary information for the market and routes the instructions to the curve or the token. This contract stores the liquidity required to LP when the cap is reached. 

3. **Market Curve:**
This contract is responsible for the trading activity of the token before the liquidity cap is reached. It simulates an xyk curve with virtual liquidity reserves to enable a market. This contract holds the liquidity of the token that is to be traded.

4. **Market Token:**
This contract represents the token that has been created. It's a standard ERC-20.

---

### How to setup the market?
1. Deploy the Manager, Token, and the Curve. 
2. Set the correct parameters for the curve. 