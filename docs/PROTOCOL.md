# UpOnly Protocol

> This document serves as the source of truth for how the UpOnly protocol should behave. 

UpOnly is a protocol designed to let users of the protocol deploy a new token without requiring any liquidity. The newly deployed token gets traded on a bonding curve with preset parameters of the curve(starting price, cap, etc). Once the token has reached the liquidity cap, the accrued liquidity along with a preset amount of tokens are added to Uniswap V2 to be openly tradeable for the public. 

## Features

1. Deploy a token. 
2. Trade the token without any backing liquidity.
3. Token gets shifted to a DEX when it hits maturity and becomes freely transferable. 

## Mechanisms
This section attempts to explain the how the key features in the protocol function. 

### Creating a Market
The `MarketFactory`(Factory) contract is responsible for deploying the new tokens and the associated markets for them. 

1. Send the fee to the fee receiver. 
2. Create a new `MarketCurve`(Curve) with the parameters sourced from Factory.
3. Create a new `MarketToken`(Token) and provide it with the address of the Curve created in the above step. 
4. The Token on its creation mints a preset amount of TOKEN and transfers it to the receiver, which is also provided in its constructor. 
5. Initialise the Curve with the above created Token & the address of the DEX adapter. 

Creating a new market charges the caller of the smart contract an `initiationFee` which is configurable in the Factory contract.

> ℹ️ — It is important to note that the newly created token has limited transferability capabilities before it completes the bonding curve. While the token has not graduated, it is only transferable to and from the associated Curve. 

### The Bonding Curve.

> `x` is the backing token (aka ETH).
> `y` is the new token being traded.

The market dynamics are modelled after the xy=k(constant product) curve. Now, because of the lack of `x` liquidity when a market is created, we require `virtual reserves` to simulate the Curve as if there's a certain amount of `x` and `y` in the pool, which are not indicative of the real `x` and `y` balances in the pool, to simulate the price conditions and the price action that we desire.

To accomodate for this, the Curve maintains two separate balances for `x` and `y` — `virtualReserve` and `balance`.

#### Buying on the Curve

> Swapping `x` for `y`.

1. To buy the Token, the user needs to provide `xIn` and `yMinOut`. `xIn` is the amount of ETH they want to swap with, and `yMinOut` is the minimum amount of token they're willing to receive in return. 
2. The adjusted amount of `xIn` is calculated by deducting the trading fee from the original amount. 
3. If the sum of `adjustedXIn` and the amount of `x` accumulated in the pool exceed the liquidity cap, the excess amount of `x` is returned to the user. 
4. Then, the Curve checks if the amount of tokens to transfer to the user passes the slippage check.
5. If the amount of `y` available in the Curve has reached zero with this trade, status is updated to `CapReached`.
6. `y` is transferred to the user and the fee(charged on the incoming `x`) is transferred to the fee receiver. 

#### Selling on the curve

> Swapping `y` for `x`.

1. To sell the Token, the user needs to proivde `yIn` and `xMinOut`. `yIn` is the amount of Token they want to swap out of, and `xMinOut` is the minimum amount of ETH they're willing to receive. 
2. The amount of `xOut` is for `yIn` is calculated with `getQuote`. 
3. The amount of fee charged on `xOut` is calculated to arrived at adjusted `xOut`. (On selling, fee is charged on outgoing `x`).
4. Then, adjusted `xOut` has to pass a slippage check. (adjusted `xOut` > `minXOut`).
5. `y` is transferred from the user to the Curve, adjusted `xOut` is transffered to the user, and the amount of `x` charged as fee is transferred to the fee receiver. 

#### Graduating a Token

Graduating a Token basically means that the bonding curve has been fulfilled, now the Token can move on to the real world and the gaurd-rails can be lifted. 

1. Ensure the status is `CapReached`.
2. Update the status to `Graduated`.
3. Send the `graduationFee` to the fee receiver. 
4. Curve calls `Token::setGraduated(true)` to lift up the transferability limitations from the token. 
5. The DEX Adapter is called to create a pair for TOKEN<>ETH and add `xToLP` + `yReservedForLP` amount of liquidity to the newly created pair. 

---

The above is a list of UpOnly Protocol's core mechanisms. There's a fair bit of more functionality that's essentially admin stuff to tweak the protocol once it's deployed. 

If you have any questions about the above doc or think that something's mission or unclear, reach out to me on [Telegram](https://t.me/manangouhari) or [X](https://x.com/manangouhari).