# UpOnly Protocol

This repository is a collection of smart contracts that collectively form the UpOnly Protocol.

To read about the protocol in detail, make your way over to [Protocol Doc](/docs/PROTOCOL.md) and for more rough notes, there's a [notes folder](/docs/notes/) inside the docs directory. 

#### TLDR
> UpOnly is a protocol designed to let users of the protocol deploy a new token without requiring any liquidity. The newly deployed token gets traded on a bonding curve with preset parameters of the curve(starting price, cap, etc). Once the token has reached the liquidity cap, the accrued liquidity along with a preset amount of tokens are added to Uniswap V2 to be openly tradeable for the public. 

## Testing

There are unit tests for all the four contracts —
1. [Factory.t.sol](/test/core/Factory.t.sol)
2. [Curve.t.sol](/test/core/Curve.t.sol)
3. [Token.t.sol](/test/core/Token.t.sol)
4. [UniV2Adapter.t.sol](/test/core/adapter/UniV2Adapter.t.sol)

And there's one end-to-end test [here](/test/e2e/base-mainnet/Integration.t.sol) that runs on a fork of Base Mainnet. The forking is handled inside the test itself, you do not need to do anything special to run this test. 

```shell
$ forge test
```

---

If you have any questions or thoughts about the protocol, hit me up on [Telegram](https://t.me/manangouhari) or [X](https://x.com/manangouhari).