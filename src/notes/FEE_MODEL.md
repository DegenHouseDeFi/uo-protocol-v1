# UpOnly Fee Model

UpOnly Protocol accrues a fees on the following actions:
1. On creating a token.
2. On every trade.
3. On every token graduation event. 

## Token Creation Fee
Every time a token is created, the protocol will charge a __fee of ~$5 in ETH__. Currently, the number in ETH comes out to be __0.0015 ETH__.

## Trade Fee

The protocol will charge a __1% fee on every trade__. 

Two types of trades are possible, and the specifics of the fee depend on the trade:
1. Buying a token with ETH.
2. Selling a token for ETH.

### Buying a token:
On a buy, the protocol will charge 1% of the input ETH.

### Selling a token:
On a sale, the protocol will charge 1% of the output ETH.


## Graduation Fee

"Token Gradutation" signifies that a token has completed the bonding curve and is now being moved to Uniswap and open to the world. 

On every "graduation," the protocol will charge roughly __$150__. 
Currently, the number in ETH comes out to be __0.05 ETH__.