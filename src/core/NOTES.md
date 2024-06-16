# UpOnly Protocol

The UpOnly Protocol is a modular collection of smart contracts that work together to create a system that lets the users:
1. Create a new token & generate a bonding curve market for the created token. 
2. Trade the newly created token until it hits the liquidity cap. 
3. Safely move the token to a DEX on reaching the liquidity cap. 

Users do not decide:
1. The initial supply of the token. 
2. The initial reserves of the token. 


## Smart Contracts (not updated)

1. **Market Factory:**
This contract facilitates the creation of new markets. It deploys a manager, a token, and a curve. Then, it assigns the correct parameters to each of those contracts. 


2. **Market Manager:**
This contract stores all the necessary information for the market and routes the instructions to the curve or the token. This contract stores the liquidity required to LP when the cap is reached. 

3. **Market Curve:**
This contract is responsible for the trading activity of the token before the liquidity cap is reached. It simulates an xyk curve with virtual liquidity reserves to enable a market. This contract holds the liquidity of the token that is to be traded.

4. **Market Token:**
This contract represents the token that has been created. It's a standard ERC-20.

---

## Bonding Curve Parameters (Notes + WIP)

- Token Supply: 1 Billion
    - For sale: 800 Million
    - For LP: 200 Million

- Token Price Initial: 1.2e-9 ETH | $0.0000042
- Token Price Final:   1.8e-8 ETH | $0.0000641

- Virtual Reserves:
    - Initial:
        - ETH: 1.296
        - Token: 1.08 billion
    - Final: 
        - ETH: 5.04
        - Token: 280 million

- Final Liquidity to LP:
    - ETH: Final - Initial - 0.1(fee) = 3.644 
    - Token: 200M

- Token Metrics on DEX:
    - Price: $6.37e-05
    - Market Cap: $63k
    

- Market Cap:
    - Curve Initial: $3.5k
    - Curve Final: $64k
    - DEX Initial: $63k

---

### Simulating Pump's Parameters

- Token Supply: 1 Billion
    - For sale: 800 Million
    - For LP: 200 Million

- Token Price
    - Initial: 2.8e-8 SOL | $0.0000042
    - Final:   4.1e-7 SOL | $0.0000615
    

- Virtual Reserves
    - Initial:
        - SOL: 30.00000003
        - MEME: 1_073_000_000
    - Final: 
        - SOL: 115
        - MEME: 279_900_000 

- Final liquidity to LP
    - SOL: 79
    - MEME: 200_000_000

- Starting params on DEX: 
    - Price: 3.95e-7 SOL
    - Market Cap: $67.15k
