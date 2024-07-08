➜  protocol git:(main) ✗ slither . --checklist
'forge clean' running (wd: /Users/manan/dev/uponly/protocol)
'forge config --json' running
'forge build --build-info --skip */test/** */script/** --force' running (wd: /Users/manan/dev/uponly/protocol)
INFO:Detectors:
MarketCurve.graduate() (src/core/MarketCurve.sol#242-267) sends eth to arbitrary user
	Dangerous calls:
	- dexAdapter.createPairAndAddLiquidityETH{value: xToLP}(address(token),xToLP,params.yReservedForLP,BURN_ADDRESS) (src/core/MarketCurve.sol#261-263)
MarketCurve.sendEther(address,uint256) (src/core/MarketCurve.sol#324-329) sends eth to arbitrary user
	Dangerous calls:
	- (sent,None) = to.call{value: amount}() (src/core/MarketCurve.sol#325)
MarketFactory.sendEther(address,uint256) (src/core/MarketFactory.sol#182-187) sends eth to arbitrary user
	Dangerous calls:
	- (sent,None) = to.call{value: amount}() (src/core/MarketFactory.sol#183)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#functions-that-send-ether-to-arbitrary-destinations
INFO:Detectors:
Reentrancy in MarketCurve.buy(uint256,uint256) (src/core/MarketCurve.sol#148-193):
	External calls:
	- sendEther(msg.sender,xIn - adjustedXIn - fee) (src/core/MarketCurve.sol#163)
		- (sent,None) = to.call{value: amount}() (src/core/MarketCurve.sol#325)
	State variables written after the call(s):
	- balances.x += adjustedXIn (src/core/MarketCurve.sol#177)
	MarketCurve.balances (src/core/MarketCurve.sol#99) can be used in cross function reentrancies:
	- MarketCurve.balances (src/core/MarketCurve.sol#99)
	- MarketCurve.buy(uint256,uint256) (src/core/MarketCurve.sol#148-193)
	- MarketCurve.getBalances() (src/core/MarketCurve.sol#316-318)
	- MarketCurve.getQuote(uint256,uint256) (src/core/MarketCurve.sol#275-293)
	- MarketCurve.graduate() (src/core/MarketCurve.sol#242-267)
	- MarketCurve.initialiseCurve(MarketToken,UniswapV2LiquidityAdapter) (src/core/MarketCurve.sol#122-140)
	- MarketCurve.sell(uint256,uint256) (src/core/MarketCurve.sol#201-235)
	- balances.y -= out (src/core/MarketCurve.sol#178)
	MarketCurve.balances (src/core/MarketCurve.sol#99) can be used in cross function reentrancies:
	- MarketCurve.balances (src/core/MarketCurve.sol#99)
	- MarketCurve.buy(uint256,uint256) (src/core/MarketCurve.sol#148-193)
	- MarketCurve.getBalances() (src/core/MarketCurve.sol#316-318)
	- MarketCurve.getQuote(uint256,uint256) (src/core/MarketCurve.sol#275-293)
	- MarketCurve.graduate() (src/core/MarketCurve.sol#242-267)
	- MarketCurve.initialiseCurve(MarketToken,UniswapV2LiquidityAdapter) (src/core/MarketCurve.sol#122-140)
	- MarketCurve.sell(uint256,uint256) (src/core/MarketCurve.sol#201-235)
	- params.xVirtualReserve += adjustedXIn (src/core/MarketCurve.sol#179)
	MarketCurve.params (src/core/MarketCurve.sol#101) can be used in cross function reentrancies:
	- MarketCurve.buy(uint256,uint256) (src/core/MarketCurve.sol#148-193)
	- MarketCurve.constructor(MarketCurve.CurveParameters) (src/core/MarketCurve.sol#109-113)
	- MarketCurve.getParams() (src/core/MarketCurve.sol#295-309)
	- MarketCurve.getQuote(uint256,uint256) (src/core/MarketCurve.sol#275-293)
	- MarketCurve.getReserves() (src/core/MarketCurve.sol#311-314)
	- MarketCurve.graduate() (src/core/MarketCurve.sol#242-267)
	- MarketCurve.initialiseCurve(MarketToken,UniswapV2LiquidityAdapter) (src/core/MarketCurve.sol#122-140)
	- MarketCurve.params (src/core/MarketCurve.sol#101)
	- MarketCurve.sell(uint256,uint256) (src/core/MarketCurve.sol#201-235)
	- params.yVirtualReserve -= out (src/core/MarketCurve.sol#180)
	MarketCurve.params (src/core/MarketCurve.sol#101) can be used in cross function reentrancies:
	- MarketCurve.buy(uint256,uint256) (src/core/MarketCurve.sol#148-193)
	- MarketCurve.constructor(MarketCurve.CurveParameters) (src/core/MarketCurve.sol#109-113)
	- MarketCurve.getParams() (src/core/MarketCurve.sol#295-309)
	- MarketCurve.getQuote(uint256,uint256) (src/core/MarketCurve.sol#275-293)
	- MarketCurve.getReserves() (src/core/MarketCurve.sol#311-314)
	- MarketCurve.graduate() (src/core/MarketCurve.sol#242-267)
	- MarketCurve.initialiseCurve(MarketToken,UniswapV2LiquidityAdapter) (src/core/MarketCurve.sol#122-140)
	- MarketCurve.params (src/core/MarketCurve.sol#101)
	- MarketCurve.sell(uint256,uint256) (src/core/MarketCurve.sol#201-235)
	- status = Status.CapReached (src/core/MarketCurve.sol#184)
	MarketCurve.status (src/core/MarketCurve.sol#98) can be used in cross function reentrancies:
	- MarketCurve.buy(uint256,uint256) (src/core/MarketCurve.sol#148-193)
	- MarketCurve.constructor(MarketCurve.CurveParameters) (src/core/MarketCurve.sol#109-113)
	- MarketCurve.graduate() (src/core/MarketCurve.sol#242-267)
	- MarketCurve.initialiseCurve(MarketToken,UniswapV2LiquidityAdapter) (src/core/MarketCurve.sol#122-140)
	- MarketCurve.onlyTrading() (src/core/MarketCurve.sol#346-351)
	- MarketCurve.status (src/core/MarketCurve.sol#98)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities
INFO:Detectors:
MarketCurve.buy(uint256,uint256) (src/core/MarketCurve.sol#148-193) ignores return value by token.transfer(msg.sender,out) (src/core/MarketCurve.sol#188)
MarketCurve.sell(uint256,uint256) (src/core/MarketCurve.sol#201-235) ignores return value by token.transferFrom(msg.sender,address(this),yIn) (src/core/MarketCurve.sol#227)
UniswapV2LiquidityAdapter.createPairAndAddLiquidityETH(address,uint256,uint256,address) (src/core/adapters/UniswapV2Adapter.sol#43-56) ignores return value by MarketToken(token).transferFrom(msg.sender,address(this),yToSupply) (src/core/adapters/UniswapV2Adapter.sol#51)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unchecked-transfer
INFO:Detectors:
MarketCurve.buy(uint256,uint256) (src/core/MarketCurve.sol#148-193) uses a dangerous strict equality:
	- balances.y == 0 (src/core/MarketCurve.sol#183)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dangerous-strict-equalities
INFO:Detectors:
MarketCurve.buy(uint256,uint256) (src/core/MarketCurve.sol#148-193) ignores return value by (feeTo,BASIS_POINTS,None,tradeFee,None) = mom.feeParams() (src/core/MarketCurve.sol#154)
MarketCurve.sell(uint256,uint256) (src/core/MarketCurve.sol#201-235) ignores return value by (feeTo,BASIS_POINTS,None,tradeFee,None) = mom.feeParams() (src/core/MarketCurve.sol#208)
MarketCurve.graduate() (src/core/MarketCurve.sol#242-267) ignores return value by (feeTo,None,None,None,graduationFee) = mom.feeParams() (src/core/MarketCurve.sol#250)
MarketCurve.graduate() (src/core/MarketCurve.sol#242-267) ignores return value by token.approve(address(dexAdapter),params.yReservedForLP) (src/core/MarketCurve.sol#258)
UniswapV2LiquidityAdapter.createPairAndAddLiquidityETH(address,uint256,uint256,address) (src/core/adapters/UniswapV2Adapter.sol#43-56) ignores return value by MarketToken(token).approve(address(router),yToSupply) (src/core/adapters/UniswapV2Adapter.sol#52)
UniswapV2LiquidityAdapter.createPairAndAddLiquidityETH(address,uint256,uint256,address) (src/core/adapters/UniswapV2Adapter.sol#43-56) ignores return value by router.addLiquidityETH{value: xToSupply}(token,yToSupply,1,1,to,block.timestamp) (src/core/adapters/UniswapV2Adapter.sol#53)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return
INFO:Detectors:
MarketToken.constructor(string,string,address,address,uint256)._name (src/core/MarketToken.sol#35) shadows:
	- ERC20._name (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#41) (state variable)
MarketToken.constructor(string,string,address,address,uint256)._symbol (src/core/MarketToken.sol#35) shadows:
	- ERC20._symbol (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#42) (state variable)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#local-variable-shadowing
INFO:Detectors:
MarketToken.constructor(string,string,address,address,uint256)._mom (src/core/MarketToken.sol#35) lacks a zero-check on :
		- mom = _mom (src/core/MarketToken.sol#38)
UniswapV2LiquidityAdapter.constructor(address,address,address)._WETH (src/core/adapters/UniswapV2Adapter.sol#30) lacks a zero-check on :
		- WETH = _WETH (src/core/adapters/UniswapV2Adapter.sol#31)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-zero-address-validation
INFO:Detectors:
Reentrancy in MarketFactory.createMarket(string,string) (src/core/MarketFactory.sol#97-127):
	External calls:
	- sendEther(feeParams.feeTo,feeParams.initiationFee) (src/core/MarketFactory.sol#115)
		- (sent,None) = to.call{value: amount}() (src/core/MarketFactory.sol#183)
	- curve.initialiseCurve(token,dexAdapter) (src/core/MarketFactory.sol#120)
	External calls sending eth:
	- sendEther(feeParams.feeTo,feeParams.initiationFee) (src/core/MarketFactory.sol#115)
		- (sent,None) = to.call{value: amount}() (src/core/MarketFactory.sol#183)
	State variables written after the call(s):
	- allTokens.push(address(token)) (src/core/MarketFactory.sol#123)
	- tokenToCurve[token] = curve (src/core/MarketFactory.sol#124)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-2
INFO:Detectors:
Reentrancy in MarketCurve.buy(uint256,uint256) (src/core/MarketCurve.sol#148-193):
	External calls:
	- sendEther(msg.sender,xIn - adjustedXIn - fee) (src/core/MarketCurve.sol#163)
		- (sent,None) = to.call{value: amount}() (src/core/MarketCurve.sol#325)
	- token.transfer(msg.sender,out) (src/core/MarketCurve.sol#188)
	- sendEther(feeTo,fee) (src/core/MarketCurve.sol#189)
		- (sent,None) = to.call{value: amount}() (src/core/MarketCurve.sol#325)
	External calls sending eth:
	- sendEther(msg.sender,xIn - adjustedXIn - fee) (src/core/MarketCurve.sol#163)
		- (sent,None) = to.call{value: amount}() (src/core/MarketCurve.sol#325)
	- sendEther(feeTo,fee) (src/core/MarketCurve.sol#189)
		- (sent,None) = to.call{value: amount}() (src/core/MarketCurve.sol#325)
	Event emitted after the call(s):
	- Trade(msg.sender,true,adjustedXIn,out) (src/core/MarketCurve.sol#192)
Reentrancy in MarketFactory.createMarket(string,string) (src/core/MarketFactory.sol#97-127):
	External calls:
	- sendEther(feeParams.feeTo,feeParams.initiationFee) (src/core/MarketFactory.sol#115)
		- (sent,None) = to.call{value: amount}() (src/core/MarketFactory.sol#183)
	- curve.initialiseCurve(token,dexAdapter) (src/core/MarketFactory.sol#120)
	External calls sending eth:
	- sendEther(feeParams.feeTo,feeParams.initiationFee) (src/core/MarketFactory.sol#115)
		- (sent,None) = to.call{value: amount}() (src/core/MarketFactory.sol#183)
	Event emitted after the call(s):
	- MarketCreated(msg.sender,name,address(token),address(curve)) (src/core/MarketFactory.sol#126)
Reentrancy in UniswapV2LiquidityAdapter.createPairAndAddLiquidityETH(address,uint256,uint256,address) (src/core/adapters/UniswapV2Adapter.sol#43-56):
	External calls:
	- pair = IUniswapV2Factory(factory).createPair(token,WETH) (src/core/adapters/UniswapV2Adapter.sol#49)
	- MarketToken(token).transferFrom(msg.sender,address(this),yToSupply) (src/core/adapters/UniswapV2Adapter.sol#51)
	- MarketToken(token).approve(address(router),yToSupply) (src/core/adapters/UniswapV2Adapter.sol#52)
	- router.addLiquidityETH{value: xToSupply}(token,yToSupply,1,1,to,block.timestamp) (src/core/adapters/UniswapV2Adapter.sol#53)
	External calls sending eth:
	- router.addLiquidityETH{value: xToSupply}(token,yToSupply,1,1,to,block.timestamp) (src/core/adapters/UniswapV2Adapter.sol#53)
	Event emitted after the call(s):
	- PairCreatedAndLiquidityAdded(token,pair,to,xToSupply,yToSupply) (src/core/adapters/UniswapV2Adapter.sol#55)
Reentrancy in MarketCurve.graduate() (src/core/MarketCurve.sol#242-267):
	External calls:
	- sendEther(feeTo,graduationFee) (src/core/MarketCurve.sol#254)
		- (sent,None) = to.call{value: amount}() (src/core/MarketCurve.sol#325)
	- token.setGraduated(true) (src/core/MarketCurve.sol#257)
	- token.approve(address(dexAdapter),params.yReservedForLP) (src/core/MarketCurve.sol#258)
	- dexAdapter.createPairAndAddLiquidityETH{value: xToLP}(address(token),xToLP,params.yReservedForLP,BURN_ADDRESS) (src/core/MarketCurve.sol#261-263)
	External calls sending eth:
	- sendEther(feeTo,graduationFee) (src/core/MarketCurve.sol#254)
		- (sent,None) = to.call{value: amount}() (src/core/MarketCurve.sol#325)
	- dexAdapter.createPairAndAddLiquidityETH{value: xToLP}(address(token),xToLP,params.yReservedForLP,BURN_ADDRESS) (src/core/MarketCurve.sol#261-263)
	Event emitted after the call(s):
	- Graduated(address(token),address(dexAdapter)) (src/core/MarketCurve.sol#266)
Reentrancy in MarketCurve.sell(uint256,uint256) (src/core/MarketCurve.sol#201-235):
	External calls:
	- token.transferFrom(msg.sender,address(this),yIn) (src/core/MarketCurve.sol#227)
	- sendEther(msg.sender,out) (src/core/MarketCurve.sol#229)
		- (sent,None) = to.call{value: amount}() (src/core/MarketCurve.sol#325)
	- sendEther(feeTo,fee) (src/core/MarketCurve.sol#231)
		- (sent,None) = to.call{value: amount}() (src/core/MarketCurve.sol#325)
	External calls sending eth:
	- sendEther(msg.sender,out) (src/core/MarketCurve.sol#229)
		- (sent,None) = to.call{value: amount}() (src/core/MarketCurve.sol#325)
	- sendEther(feeTo,fee) (src/core/MarketCurve.sol#231)
		- (sent,None) = to.call{value: amount}() (src/core/MarketCurve.sol#325)
	Event emitted after the call(s):
	- Trade(msg.sender,false,out,yIn) (src/core/MarketCurve.sol#234)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-3
INFO:Detectors:
4 different versions of Solidity are used:
	- Version constraint ^0.8.20 is used by:
		-^0.8.20 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol#3)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#4)
		-^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4)
	- Version constraint ^0.8.13 is used by:
		-^0.8.13 (src/core/MarketCurve.sol#2)
		-^0.8.13 (src/core/MarketFactory.sol#2)
		-^0.8.13 (src/core/MarketToken.sol#2)
		-^0.8.13 (src/core/adapters/UniswapV2Adapter.sol#2)
		-^0.8.13 (src/interfaces/core/IMarketCurve.sol#2)
		-^0.8.13 (src/interfaces/core/IMarketFactory.sol#2)
		-^0.8.13 (src/interfaces/core/IMarketToken.sol#2)
	- Version constraint >=0.5.0 is used by:
		->=0.5.0 (src/interfaces/uniswapV2/IUniswapV2Factory.sol#1)
	- Version constraint >=0.6.2 is used by:
		->=0.6.2 (src/interfaces/uniswapV2/IUniswapV2Router01.sol#1)
		->=0.6.2 (src/interfaces/uniswapV2/IUniswapV2Router02.sol#1)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#different-pragma-directives-are-used
INFO:Detectors:
Version constraint ^0.8.20 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess.
It is used by:
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol#3)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#4)
	- ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4)
Version constraint ^0.8.13 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess
	- StorageWriteRemovalBeforeConditionalTermination
	- AbiReencodingHeadOverflowWithStaticArrayCleanup
	- DirtyBytesArrayToStorage
	- InlineAssemblyMemorySideEffects
	- DataLocationChangeInInternalOverride
	- NestedCalldataArrayAbiReencodingSizeValidation.
It is used by:
	- ^0.8.13 (src/core/MarketCurve.sol#2)
	- ^0.8.13 (src/core/MarketFactory.sol#2)
	- ^0.8.13 (src/core/MarketToken.sol#2)
	- ^0.8.13 (src/core/adapters/UniswapV2Adapter.sol#2)
	- ^0.8.13 (src/interfaces/core/IMarketCurve.sol#2)
	- ^0.8.13 (src/interfaces/core/IMarketFactory.sol#2)
	- ^0.8.13 (src/interfaces/core/IMarketToken.sol#2)
Version constraint >=0.5.0 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- DirtyBytesArrayToStorage
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching
	- EmptyByteArrayCopy
	- DynamicArrayCleanup
	- ImplicitConstructorCallvalueCheck
	- TupleAssignmentMultiStackSlotComponents
	- MemoryArrayCreationOverflow
	- privateCanBeOverridden
	- SignedArrayStorageCopy
	- ABIEncoderV2StorageArrayWithMultiSlotElement
	- DynamicConstructorArgumentsClippedABIV2
	- UninitializedFunctionPointerInConstructor
	- IncorrectEventSignatureInLibraries
	- ABIEncoderV2PackedStorage.
It is used by:
	- >=0.5.0 (src/interfaces/uniswapV2/IUniswapV2Factory.sol#1)
Version constraint >=0.6.2 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- MissingSideEffectsOnSelectorAccess
	- AbiReencodingHeadOverflowWithStaticArrayCleanup
	- DirtyBytesArrayToStorage
	- NestedCalldataArrayAbiReencodingSizeValidation
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching
	- EmptyByteArrayCopy
	- DynamicArrayCleanup
	- MissingEscapingInFormatting
	- ArraySliceDynamicallyEncodedBaseType
	- ImplicitConstructorCallvalueCheck
	- TupleAssignmentMultiStackSlotComponents
	- MemoryArrayCreationOverflow.
It is used by:
	- >=0.6.2 (src/interfaces/uniswapV2/IUniswapV2Router01.sol#1)
	- >=0.6.2 (src/interfaces/uniswapV2/IUniswapV2Router02.sol#1)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity
INFO:Detectors:
Low level call in MarketCurve.sendEther(address,uint256) (src/core/MarketCurve.sol#324-329):
	- (sent,None) = to.call{value: amount}() (src/core/MarketCurve.sol#325)
Low level call in MarketFactory.sendEther(address,uint256) (src/core/MarketFactory.sol#182-187):
	- (sent,None) = to.call{value: amount}() (src/core/MarketFactory.sol#183)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls
INFO:Detectors:
MarketToken (src/core/MarketToken.sol#10-69) should inherit from IMarketToken (src/interfaces/core/IMarketToken.sol#6-8)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-inheritance
INFO:Detectors:
Parameter MarketCurve.initialiseCurve(MarketToken,UniswapV2LiquidityAdapter)._token (src/core/MarketCurve.sol#122) is not in mixedCase
Parameter MarketCurve.initialiseCurve(MarketToken,UniswapV2LiquidityAdapter)._dexAdapter (src/core/MarketCurve.sol#122) is not in mixedCase
Parameter MarketFactory.updateMarketParams(uint256,uint256,uint256,uint256,uint256,uint256)._liquidityCap (src/core/MarketFactory.sol#132) is not in mixedCase
Parameter MarketFactory.updateMarketParams(uint256,uint256,uint256,uint256,uint256,uint256)._xStartVirtualReserve (src/core/MarketFactory.sol#133) is not in mixedCase
Parameter MarketFactory.updateMarketParams(uint256,uint256,uint256,uint256,uint256,uint256)._yStartVirtualReserve (src/core/MarketFactory.sol#134) is not in mixedCase
Parameter MarketFactory.updateMarketParams(uint256,uint256,uint256,uint256,uint256,uint256)._yMintAmount (src/core/MarketFactory.sol#135) is not in mixedCase
Parameter MarketFactory.updateMarketParams(uint256,uint256,uint256,uint256,uint256,uint256)._yReservedForLP (src/core/MarketFactory.sol#136) is not in mixedCase
Parameter MarketFactory.updateMarketParams(uint256,uint256,uint256,uint256,uint256,uint256)._yReservedForCurve (src/core/MarketFactory.sol#137) is not in mixedCase
Parameter MarketFactory.updateFeeParams(address,uint256,uint256,uint256,uint256)._feeTo (src/core/MarketFactory.sol#159) is not in mixedCase
Parameter MarketFactory.updateFeeParams(address,uint256,uint256,uint256,uint256)._BASIS_POINTS (src/core/MarketFactory.sol#160) is not in mixedCase
Parameter MarketFactory.updateFeeParams(address,uint256,uint256,uint256,uint256)._initiationFee (src/core/MarketFactory.sol#161) is not in mixedCase
Parameter MarketFactory.updateFeeParams(address,uint256,uint256,uint256,uint256)._tradeFee (src/core/MarketFactory.sol#162) is not in mixedCase
Parameter MarketFactory.updateFeeParams(address,uint256,uint256,uint256,uint256)._graduationFee (src/core/MarketFactory.sol#163) is not in mixedCase
Parameter MarketFactory.newDexAdapter(address,address,address)._WETH (src/core/MarketFactory.sol#176) is not in mixedCase
Parameter MarketFactory.newDexAdapter(address,address,address)._v2Factory (src/core/MarketFactory.sol#176) is not in mixedCase
Parameter MarketFactory.newDexAdapter(address,address,address)._v2Router (src/core/MarketFactory.sol#176) is not in mixedCase
Parameter MarketToken.setGraduated(bool)._isGraduated (src/core/MarketToken.sol#63) is not in mixedCase
Variable UniswapV2LiquidityAdapter.WETH (src/core/adapters/UniswapV2Adapter.sol#20) is not in mixedCase
Parameter IMarketFactory.updateFeeParams(address,uint256,uint256,uint256,uint256)._BASIS_POINTS (src/interfaces/core/IMarketFactory.sol#34) is not in mixedCase
Parameter IMarketFactory.newDexAdapter(address,address,address)._WETH (src/interfaces/core/IMarketFactory.sol#40) is not in mixedCase
Function IUniswapV2Router01.WETH() (src/interfaces/uniswapV2/IUniswapV2Router01.sol#5) is not in mixedCase
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [arbitrary-send-eth](#arbitrary-send-eth) (3 results) (High)
 - [reentrancy-eth](#reentrancy-eth) (1 results) (High)
 - [unchecked-transfer](#unchecked-transfer) (3 results) (High)
 - [incorrect-equality](#incorrect-equality) (1 results) (Medium)
 - [unused-return](#unused-return) (6 results) (Medium)
 - [shadowing-local](#shadowing-local) (2 results) (Low)
 - [missing-zero-check](#missing-zero-check) (2 results) (Low)
 - [reentrancy-benign](#reentrancy-benign) (1 results) (Low)
 - [reentrancy-events](#reentrancy-events) (5 results) (Low)
 - [pragma](#pragma) (1 results) (Informational)
 - [solc-version](#solc-version) (4 results) (Informational)
 - [low-level-calls](#low-level-calls) (2 results) (Informational)
 - [missing-inheritance](#missing-inheritance) (1 results) (Informational)
 - [naming-convention](#naming-convention) (21 results) (Informational)
## arbitrary-send-eth
Impact: High
Confidence: Medium
 - [ ] ID-0
[MarketCurve.sendEther(address,uint256)](src/core/MarketCurve.sol#L324-L329) sends eth to arbitrary user
	Dangerous calls:
	- [(sent,None) = to.call{value: amount}()](src/core/MarketCurve.sol#L325)

src/core/MarketCurve.sol#L324-L329


 - [ ] ID-1
[MarketCurve.graduate()](src/core/MarketCurve.sol#L242-L267) sends eth to arbitrary user
	Dangerous calls:
	- [dexAdapter.createPairAndAddLiquidityETH{value: xToLP}(address(token),xToLP,params.yReservedForLP,BURN_ADDRESS)](src/core/MarketCurve.sol#L261-L263)

src/core/MarketCurve.sol#L242-L267


 - [ ] ID-2
[MarketFactory.sendEther(address,uint256)](src/core/MarketFactory.sol#L182-L187) sends eth to arbitrary user
	Dangerous calls:
	- [(sent,None) = to.call{value: amount}()](src/core/MarketFactory.sol#L183)

src/core/MarketFactory.sol#L182-L187


## reentrancy-eth
Impact: High
Confidence: Medium
 - [ ] ID-3
Reentrancy in [MarketCurve.buy(uint256,uint256)](src/core/MarketCurve.sol#L148-L193):
	External calls:
	- [sendEther(msg.sender,xIn - adjustedXIn - fee)](src/core/MarketCurve.sol#L163)
		- [(sent,None) = to.call{value: amount}()](src/core/MarketCurve.sol#L325)
	State variables written after the call(s):
	- [balances.x += adjustedXIn](src/core/MarketCurve.sol#L177)
	[MarketCurve.balances](src/core/MarketCurve.sol#L99) can be used in cross function reentrancies:
	- [MarketCurve.balances](src/core/MarketCurve.sol#L99)
	- [MarketCurve.buy(uint256,uint256)](src/core/MarketCurve.sol#L148-L193)
	- [MarketCurve.getBalances()](src/core/MarketCurve.sol#L316-L318)
	- [MarketCurve.getQuote(uint256,uint256)](src/core/MarketCurve.sol#L275-L293)
	- [MarketCurve.graduate()](src/core/MarketCurve.sol#L242-L267)
	- [MarketCurve.initialiseCurve(MarketToken,UniswapV2LiquidityAdapter)](src/core/MarketCurve.sol#L122-L140)
	- [MarketCurve.sell(uint256,uint256)](src/core/MarketCurve.sol#L201-L235)
	- [balances.y -= out](src/core/MarketCurve.sol#L178)
	[MarketCurve.balances](src/core/MarketCurve.sol#L99) can be used in cross function reentrancies:
	- [MarketCurve.balances](src/core/MarketCurve.sol#L99)
	- [MarketCurve.buy(uint256,uint256)](src/core/MarketCurve.sol#L148-L193)
	- [MarketCurve.getBalances()](src/core/MarketCurve.sol#L316-L318)
	- [MarketCurve.getQuote(uint256,uint256)](src/core/MarketCurve.sol#L275-L293)
	- [MarketCurve.graduate()](src/core/MarketCurve.sol#L242-L267)
	- [MarketCurve.initialiseCurve(MarketToken,UniswapV2LiquidityAdapter)](src/core/MarketCurve.sol#L122-L140)
	- [MarketCurve.sell(uint256,uint256)](src/core/MarketCurve.sol#L201-L235)
	- [params.xVirtualReserve += adjustedXIn](src/core/MarketCurve.sol#L179)
	[MarketCurve.params](src/core/MarketCurve.sol#L101) can be used in cross function reentrancies:
	- [MarketCurve.buy(uint256,uint256)](src/core/MarketCurve.sol#L148-L193)
	- [MarketCurve.constructor(MarketCurve.CurveParameters)](src/core/MarketCurve.sol#L109-L113)
	- [MarketCurve.getParams()](src/core/MarketCurve.sol#L295-L309)
	- [MarketCurve.getQuote(uint256,uint256)](src/core/MarketCurve.sol#L275-L293)
	- [MarketCurve.getReserves()](src/core/MarketCurve.sol#L311-L314)
	- [MarketCurve.graduate()](src/core/MarketCurve.sol#L242-L267)
	- [MarketCurve.initialiseCurve(MarketToken,UniswapV2LiquidityAdapter)](src/core/MarketCurve.sol#L122-L140)
	- [MarketCurve.params](src/core/MarketCurve.sol#L101)
	- [MarketCurve.sell(uint256,uint256)](src/core/MarketCurve.sol#L201-L235)
	- [params.yVirtualReserve -= out](src/core/MarketCurve.sol#L180)
	[MarketCurve.params](src/core/MarketCurve.sol#L101) can be used in cross function reentrancies:
	- [MarketCurve.buy(uint256,uint256)](src/core/MarketCurve.sol#L148-L193)
	- [MarketCurve.constructor(MarketCurve.CurveParameters)](src/core/MarketCurve.sol#L109-L113)
	- [MarketCurve.getParams()](src/core/MarketCurve.sol#L295-L309)
	- [MarketCurve.getQuote(uint256,uint256)](src/core/MarketCurve.sol#L275-L293)
	- [MarketCurve.getReserves()](src/core/MarketCurve.sol#L311-L314)
	- [MarketCurve.graduate()](src/core/MarketCurve.sol#L242-L267)
	- [MarketCurve.initialiseCurve(MarketToken,UniswapV2LiquidityAdapter)](src/core/MarketCurve.sol#L122-L140)
	- [MarketCurve.params](src/core/MarketCurve.sol#L101)
	- [MarketCurve.sell(uint256,uint256)](src/core/MarketCurve.sol#L201-L235)
	- [status = Status.CapReached](src/core/MarketCurve.sol#L184)
	[MarketCurve.status](src/core/MarketCurve.sol#L98) can be used in cross function reentrancies:
	- [MarketCurve.buy(uint256,uint256)](src/core/MarketCurve.sol#L148-L193)
	- [MarketCurve.constructor(MarketCurve.CurveParameters)](src/core/MarketCurve.sol#L109-L113)
	- [MarketCurve.graduate()](src/core/MarketCurve.sol#L242-L267)
	- [MarketCurve.initialiseCurve(MarketToken,UniswapV2LiquidityAdapter)](src/core/MarketCurve.sol#L122-L140)
	- [MarketCurve.onlyTrading()](src/core/MarketCurve.sol#L346-L351)
	- [MarketCurve.status](src/core/MarketCurve.sol#L98)

src/core/MarketCurve.sol#L148-L193


## unchecked-transfer
Impact: High
Confidence: Medium
 - [ ] ID-4
[UniswapV2LiquidityAdapter.createPairAndAddLiquidityETH(address,uint256,uint256,address)](src/core/adapters/UniswapV2Adapter.sol#L43-L56) ignores return value by [MarketToken(token).transferFrom(msg.sender,address(this),yToSupply)](src/core/adapters/UniswapV2Adapter.sol#L51)

src/core/adapters/UniswapV2Adapter.sol#L43-L56


 - [ ] ID-5
[MarketCurve.sell(uint256,uint256)](src/core/MarketCurve.sol#L201-L235) ignores return value by [token.transferFrom(msg.sender,address(this),yIn)](src/core/MarketCurve.sol#L227)

src/core/MarketCurve.sol#L201-L235


 - [ ] ID-6
[MarketCurve.buy(uint256,uint256)](src/core/MarketCurve.sol#L148-L193) ignores return value by [token.transfer(msg.sender,out)](src/core/MarketCurve.sol#L188)

src/core/MarketCurve.sol#L148-L193


## incorrect-equality
Impact: Medium
Confidence: High
 - [ ] ID-7
[MarketCurve.buy(uint256,uint256)](src/core/MarketCurve.sol#L148-L193) uses a dangerous strict equality:
	- [balances.y == 0](src/core/MarketCurve.sol#L183)

src/core/MarketCurve.sol#L148-L193


## unused-return
Impact: Medium
Confidence: Medium
 - [ ] ID-8
[UniswapV2LiquidityAdapter.createPairAndAddLiquidityETH(address,uint256,uint256,address)](src/core/adapters/UniswapV2Adapter.sol#L43-L56) ignores return value by [MarketToken(token).approve(address(router),yToSupply)](src/core/adapters/UniswapV2Adapter.sol#L52)

src/core/adapters/UniswapV2Adapter.sol#L43-L56


 - [ ] ID-9
[MarketCurve.graduate()](src/core/MarketCurve.sol#L242-L267) ignores return value by [(feeTo,None,None,None,graduationFee) = mom.feeParams()](src/core/MarketCurve.sol#L250)

src/core/MarketCurve.sol#L242-L267


 - [ ] ID-10
[UniswapV2LiquidityAdapter.createPairAndAddLiquidityETH(address,uint256,uint256,address)](src/core/adapters/UniswapV2Adapter.sol#L43-L56) ignores return value by [router.addLiquidityETH{value: xToSupply}(token,yToSupply,1,1,to,block.timestamp)](src/core/adapters/UniswapV2Adapter.sol#L53)

src/core/adapters/UniswapV2Adapter.sol#L43-L56


 - [ ] ID-11
[MarketCurve.sell(uint256,uint256)](src/core/MarketCurve.sol#L201-L235) ignores return value by [(feeTo,BASIS_POINTS,None,tradeFee,None) = mom.feeParams()](src/core/MarketCurve.sol#L208)

src/core/MarketCurve.sol#L201-L235


 - [ ] ID-12
[MarketCurve.graduate()](src/core/MarketCurve.sol#L242-L267) ignores return value by [token.approve(address(dexAdapter),params.yReservedForLP)](src/core/MarketCurve.sol#L258)

src/core/MarketCurve.sol#L242-L267


 - [ ] ID-13
[MarketCurve.buy(uint256,uint256)](src/core/MarketCurve.sol#L148-L193) ignores return value by [(feeTo,BASIS_POINTS,None,tradeFee,None) = mom.feeParams()](src/core/MarketCurve.sol#L154)

src/core/MarketCurve.sol#L148-L193


## shadowing-local
Impact: Low
Confidence: High
 - [ ] ID-14
[MarketToken.constructor(string,string,address,address,uint256)._symbol](src/core/MarketToken.sol#L35) shadows:
	- [ERC20._symbol](lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#L42) (state variable)

src/core/MarketToken.sol#L35


 - [ ] ID-15
[MarketToken.constructor(string,string,address,address,uint256)._name](src/core/MarketToken.sol#L35) shadows:
	- [ERC20._name](lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#L41) (state variable)

src/core/MarketToken.sol#L35


## missing-zero-check
Impact: Low
Confidence: Medium
 - [ ] ID-16
[MarketToken.constructor(string,string,address,address,uint256)._mom](src/core/MarketToken.sol#L35) lacks a zero-check on :
		- [mom = _mom](src/core/MarketToken.sol#L38)

src/core/MarketToken.sol#L35


 - [ ] ID-17
[UniswapV2LiquidityAdapter.constructor(address,address,address)._WETH](src/core/adapters/UniswapV2Adapter.sol#L30) lacks a zero-check on :
		- [WETH = _WETH](src/core/adapters/UniswapV2Adapter.sol#L31)

src/core/adapters/UniswapV2Adapter.sol#L30


## reentrancy-benign
Impact: Low
Confidence: Medium
 - [ ] ID-18
Reentrancy in [MarketFactory.createMarket(string,string)](src/core/MarketFactory.sol#L97-L127):
	External calls:
	- [sendEther(feeParams.feeTo,feeParams.initiationFee)](src/core/MarketFactory.sol#L115)
		- [(sent,None) = to.call{value: amount}()](src/core/MarketFactory.sol#L183)
	- [curve.initialiseCurve(token,dexAdapter)](src/core/MarketFactory.sol#L120)
	External calls sending eth:
	- [sendEther(feeParams.feeTo,feeParams.initiationFee)](src/core/MarketFactory.sol#L115)
		- [(sent,None) = to.call{value: amount}()](src/core/MarketFactory.sol#L183)
	State variables written after the call(s):
	- [allTokens.push(address(token))](src/core/MarketFactory.sol#L123)
	- [tokenToCurve[token] = curve](src/core/MarketFactory.sol#L124)

src/core/MarketFactory.sol#L97-L127


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-19
Reentrancy in [MarketCurve.sell(uint256,uint256)](src/core/MarketCurve.sol#L201-L235):
	External calls:
	- [token.transferFrom(msg.sender,address(this),yIn)](src/core/MarketCurve.sol#L227)
	- [sendEther(msg.sender,out)](src/core/MarketCurve.sol#L229)
		- [(sent,None) = to.call{value: amount}()](src/core/MarketCurve.sol#L325)
	- [sendEther(feeTo,fee)](src/core/MarketCurve.sol#L231)
		- [(sent,None) = to.call{value: amount}()](src/core/MarketCurve.sol#L325)
	External calls sending eth:
	- [sendEther(msg.sender,out)](src/core/MarketCurve.sol#L229)
		- [(sent,None) = to.call{value: amount}()](src/core/MarketCurve.sol#L325)
	- [sendEther(feeTo,fee)](src/core/MarketCurve.sol#L231)
		- [(sent,None) = to.call{value: amount}()](src/core/MarketCurve.sol#L325)
	Event emitted after the call(s):
	- [Trade(msg.sender,false,out,yIn)](src/core/MarketCurve.sol#L234)

src/core/MarketCurve.sol#L201-L235


 - [ ] ID-20
Reentrancy in [MarketCurve.buy(uint256,uint256)](src/core/MarketCurve.sol#L148-L193):
	External calls:
	- [sendEther(msg.sender,xIn - adjustedXIn - fee)](src/core/MarketCurve.sol#L163)
		- [(sent,None) = to.call{value: amount}()](src/core/MarketCurve.sol#L325)
	- [token.transfer(msg.sender,out)](src/core/MarketCurve.sol#L188)
	- [sendEther(feeTo,fee)](src/core/MarketCurve.sol#L189)
		- [(sent,None) = to.call{value: amount}()](src/core/MarketCurve.sol#L325)
	External calls sending eth:
	- [sendEther(msg.sender,xIn - adjustedXIn - fee)](src/core/MarketCurve.sol#L163)
		- [(sent,None) = to.call{value: amount}()](src/core/MarketCurve.sol#L325)
	- [sendEther(feeTo,fee)](src/core/MarketCurve.sol#L189)
		- [(sent,None) = to.call{value: amount}()](src/core/MarketCurve.sol#L325)
	Event emitted after the call(s):
	- [Trade(msg.sender,true,adjustedXIn,out)](src/core/MarketCurve.sol#L192)

src/core/MarketCurve.sol#L148-L193


 - [ ] ID-21
Reentrancy in [MarketCurve.graduate()](src/core/MarketCurve.sol#L242-L267):
	External calls:
	- [sendEther(feeTo,graduationFee)](src/core/MarketCurve.sol#L254)
		- [(sent,None) = to.call{value: amount}()](src/core/MarketCurve.sol#L325)
	- [token.setGraduated(true)](src/core/MarketCurve.sol#L257)
	- [token.approve(address(dexAdapter),params.yReservedForLP)](src/core/MarketCurve.sol#L258)
	- [dexAdapter.createPairAndAddLiquidityETH{value: xToLP}(address(token),xToLP,params.yReservedForLP,BURN_ADDRESS)](src/core/MarketCurve.sol#L261-L263)
	External calls sending eth:
	- [sendEther(feeTo,graduationFee)](src/core/MarketCurve.sol#L254)
		- [(sent,None) = to.call{value: amount}()](src/core/MarketCurve.sol#L325)
	- [dexAdapter.createPairAndAddLiquidityETH{value: xToLP}(address(token),xToLP,params.yReservedForLP,BURN_ADDRESS)](src/core/MarketCurve.sol#L261-L263)
	Event emitted after the call(s):
	- [Graduated(address(token),address(dexAdapter))](src/core/MarketCurve.sol#L266)

src/core/MarketCurve.sol#L242-L267


 - [ ] ID-22
Reentrancy in [UniswapV2LiquidityAdapter.createPairAndAddLiquidityETH(address,uint256,uint256,address)](src/core/adapters/UniswapV2Adapter.sol#L43-L56):
	External calls:
	- [pair = IUniswapV2Factory(factory).createPair(token,WETH)](src/core/adapters/UniswapV2Adapter.sol#L49)
	- [MarketToken(token).transferFrom(msg.sender,address(this),yToSupply)](src/core/adapters/UniswapV2Adapter.sol#L51)
	- [MarketToken(token).approve(address(router),yToSupply)](src/core/adapters/UniswapV2Adapter.sol#L52)
	- [router.addLiquidityETH{value: xToSupply}(token,yToSupply,1,1,to,block.timestamp)](src/core/adapters/UniswapV2Adapter.sol#L53)
	External calls sending eth:
	- [router.addLiquidityETH{value: xToSupply}(token,yToSupply,1,1,to,block.timestamp)](src/core/adapters/UniswapV2Adapter.sol#L53)
	Event emitted after the call(s):
	- [PairCreatedAndLiquidityAdded(token,pair,to,xToSupply,yToSupply)](src/core/adapters/UniswapV2Adapter.sol#L55)

src/core/adapters/UniswapV2Adapter.sol#L43-L56


 - [ ] ID-23
Reentrancy in [MarketFactory.createMarket(string,string)](src/core/MarketFactory.sol#L97-L127):
	External calls:
	- [sendEther(feeParams.feeTo,feeParams.initiationFee)](src/core/MarketFactory.sol#L115)
		- [(sent,None) = to.call{value: amount}()](src/core/MarketFactory.sol#L183)
	- [curve.initialiseCurve(token,dexAdapter)](src/core/MarketFactory.sol#L120)
	External calls sending eth:
	- [sendEther(feeParams.feeTo,feeParams.initiationFee)](src/core/MarketFactory.sol#L115)
		- [(sent,None) = to.call{value: amount}()](src/core/MarketFactory.sol#L183)
	Event emitted after the call(s):
	- [MarketCreated(msg.sender,name,address(token),address(curve))](src/core/MarketFactory.sol#L126)

src/core/MarketFactory.sol#L97-L127


## pragma
Impact: Informational
Confidence: High
 - [ ] ID-24
4 different versions of Solidity are used:
	- Version constraint ^0.8.20 is used by:
		-[^0.8.20](lib/openzeppelin-contracts/contracts/access/Ownable.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol#L3)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#L4)
		-[^0.8.20](lib/openzeppelin-contracts/contracts/utils/Context.sol#L4)
	- Version constraint ^0.8.13 is used by:
		-[^0.8.13](src/core/MarketCurve.sol#L2)
		-[^0.8.13](src/core/MarketFactory.sol#L2)
		-[^0.8.13](src/core/MarketToken.sol#L2)
		-[^0.8.13](src/core/adapters/UniswapV2Adapter.sol#L2)
		-[^0.8.13](src/interfaces/core/IMarketCurve.sol#L2)
		-[^0.8.13](src/interfaces/core/IMarketFactory.sol#L2)
		-[^0.8.13](src/interfaces/core/IMarketToken.sol#L2)
	- Version constraint >=0.5.0 is used by:
		-[>=0.5.0](src/interfaces/uniswapV2/IUniswapV2Factory.sol#L1)
	- Version constraint >=0.6.2 is used by:
		-[>=0.6.2](src/interfaces/uniswapV2/IUniswapV2Router01.sol#L1)
		-[>=0.6.2](src/interfaces/uniswapV2/IUniswapV2Router02.sol#L1)

lib/openzeppelin-contracts/contracts/access/Ownable.sol#L4


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-25
Version constraint ^0.8.20 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess.
It is used by:
	- [^0.8.20](lib/openzeppelin-contracts/contracts/access/Ownable.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol#L3)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/utils/Context.sol#L4)

lib/openzeppelin-contracts/contracts/access/Ownable.sol#L4


 - [ ] ID-26
Version constraint >=0.6.2 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- MissingSideEffectsOnSelectorAccess
	- AbiReencodingHeadOverflowWithStaticArrayCleanup
	- DirtyBytesArrayToStorage
	- NestedCalldataArrayAbiReencodingSizeValidation
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching
	- EmptyByteArrayCopy
	- DynamicArrayCleanup
	- MissingEscapingInFormatting
	- ArraySliceDynamicallyEncodedBaseType
	- ImplicitConstructorCallvalueCheck
	- TupleAssignmentMultiStackSlotComponents
	- MemoryArrayCreationOverflow.
It is used by:
	- [>=0.6.2](src/interfaces/uniswapV2/IUniswapV2Router01.sol#L1)
	- [>=0.6.2](src/interfaces/uniswapV2/IUniswapV2Router02.sol#L1)

src/interfaces/uniswapV2/IUniswapV2Router01.sol#L1


 - [ ] ID-27
Version constraint >=0.5.0 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- DirtyBytesArrayToStorage
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching
	- EmptyByteArrayCopy
	- DynamicArrayCleanup
	- ImplicitConstructorCallvalueCheck
	- TupleAssignmentMultiStackSlotComponents
	- MemoryArrayCreationOverflow
	- privateCanBeOverridden
	- SignedArrayStorageCopy
	- ABIEncoderV2StorageArrayWithMultiSlotElement
	- DynamicConstructorArgumentsClippedABIV2
	- UninitializedFunctionPointerInConstructor
	- IncorrectEventSignatureInLibraries
	- ABIEncoderV2PackedStorage.
It is used by:
	- [>=0.5.0](src/interfaces/uniswapV2/IUniswapV2Factory.sol#L1)

src/interfaces/uniswapV2/IUniswapV2Factory.sol#L1


 - [ ] ID-28
Version constraint ^0.8.13 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess
	- StorageWriteRemovalBeforeConditionalTermination
	- AbiReencodingHeadOverflowWithStaticArrayCleanup
	- DirtyBytesArrayToStorage
	- InlineAssemblyMemorySideEffects
	- DataLocationChangeInInternalOverride
	- NestedCalldataArrayAbiReencodingSizeValidation.
It is used by:
	- [^0.8.13](src/core/MarketCurve.sol#L2)
	- [^0.8.13](src/core/MarketFactory.sol#L2)
	- [^0.8.13](src/core/MarketToken.sol#L2)
	- [^0.8.13](src/core/adapters/UniswapV2Adapter.sol#L2)
	- [^0.8.13](src/interfaces/core/IMarketCurve.sol#L2)
	- [^0.8.13](src/interfaces/core/IMarketFactory.sol#L2)
	- [^0.8.13](src/interfaces/core/IMarketToken.sol#L2)

src/core/MarketCurve.sol#L2


## low-level-calls
Impact: Informational
Confidence: High
 - [ ] ID-29
Low level call in [MarketCurve.sendEther(address,uint256)](src/core/MarketCurve.sol#L324-L329):
	- [(sent,None) = to.call{value: amount}()](src/core/MarketCurve.sol#L325)

src/core/MarketCurve.sol#L324-L329


 - [ ] ID-30
Low level call in [MarketFactory.sendEther(address,uint256)](src/core/MarketFactory.sol#L182-L187):
	- [(sent,None) = to.call{value: amount}()](src/core/MarketFactory.sol#L183)

src/core/MarketFactory.sol#L182-L187


## missing-inheritance
Impact: Informational
Confidence: High
 - [ ] ID-31
[MarketToken](src/core/MarketToken.sol#L10-L69) should inherit from [IMarketToken](src/interfaces/core/IMarketToken.sol#L6-L8)

src/core/MarketToken.sol#L10-L69


## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-32
Parameter [MarketFactory.updateMarketParams(uint256,uint256,uint256,uint256,uint256,uint256)._yStartVirtualReserve](src/core/MarketFactory.sol#L134) is not in mixedCase

src/core/MarketFactory.sol#L134


 - [ ] ID-33
Parameter [MarketFactory.updateFeeParams(address,uint256,uint256,uint256,uint256)._tradeFee](src/core/MarketFactory.sol#L162) is not in mixedCase

src/core/MarketFactory.sol#L162


 - [ ] ID-34
Parameter [MarketToken.setGraduated(bool)._isGraduated](src/core/MarketToken.sol#L63) is not in mixedCase

src/core/MarketToken.sol#L63


 - [ ] ID-35
Parameter [MarketFactory.newDexAdapter(address,address,address)._WETH](src/core/MarketFactory.sol#L176) is not in mixedCase

src/core/MarketFactory.sol#L176


 - [ ] ID-36
Variable [UniswapV2LiquidityAdapter.WETH](src/core/adapters/UniswapV2Adapter.sol#L20) is not in mixedCase

src/core/adapters/UniswapV2Adapter.sol#L20


 - [ ] ID-37
Parameter [MarketFactory.updateMarketParams(uint256,uint256,uint256,uint256,uint256,uint256)._yMintAmount](src/core/MarketFactory.sol#L135) is not in mixedCase

src/core/MarketFactory.sol#L135


 - [ ] ID-38
Parameter [MarketFactory.updateFeeParams(address,uint256,uint256,uint256,uint256)._graduationFee](src/core/MarketFactory.sol#L163) is not in mixedCase

src/core/MarketFactory.sol#L163


 - [ ] ID-39
Parameter [MarketFactory.updateMarketParams(uint256,uint256,uint256,uint256,uint256,uint256)._liquidityCap](src/core/MarketFactory.sol#L132) is not in mixedCase

src/core/MarketFactory.sol#L132


 - [ ] ID-40
Parameter [MarketFactory.updateFeeParams(address,uint256,uint256,uint256,uint256)._feeTo](src/core/MarketFactory.sol#L159) is not in mixedCase

src/core/MarketFactory.sol#L159


 - [ ] ID-41
Parameter [MarketFactory.newDexAdapter(address,address,address)._v2Router](src/core/MarketFactory.sol#L176) is not in mixedCase

src/core/MarketFactory.sol#L176


 - [ ] ID-42
Parameter [MarketCurve.initialiseCurve(MarketToken,UniswapV2LiquidityAdapter)._token](src/core/MarketCurve.sol#L122) is not in mixedCase

src/core/MarketCurve.sol#L122


 - [ ] ID-43
Parameter [MarketFactory.updateFeeParams(address,uint256,uint256,uint256,uint256)._initiationFee](src/core/MarketFactory.sol#L161) is not in mixedCase

src/core/MarketFactory.sol#L161


 - [ ] ID-44
Parameter [MarketFactory.updateFeeParams(address,uint256,uint256,uint256,uint256)._BASIS_POINTS](src/core/MarketFactory.sol#L160) is not in mixedCase

src/core/MarketFactory.sol#L160


 - [ ] ID-45
Parameter [MarketFactory.updateMarketParams(uint256,uint256,uint256,uint256,uint256,uint256)._yReservedForLP](src/core/MarketFactory.sol#L136) is not in mixedCase

src/core/MarketFactory.sol#L136


 - [ ] ID-46
Parameter [IMarketFactory.updateFeeParams(address,uint256,uint256,uint256,uint256)._BASIS_POINTS](src/interfaces/core/IMarketFactory.sol#L34) is not in mixedCase

src/interfaces/core/IMarketFactory.sol#L34


 - [ ] ID-47
Parameter [MarketFactory.updateMarketParams(uint256,uint256,uint256,uint256,uint256,uint256)._yReservedForCurve](src/core/MarketFactory.sol#L137) is not in mixedCase

src/core/MarketFactory.sol#L137


 - [ ] ID-48
Parameter [IMarketFactory.newDexAdapter(address,address,address)._WETH](src/interfaces/core/IMarketFactory.sol#L40) is not in mixedCase

src/interfaces/core/IMarketFactory.sol#L40


 - [ ] ID-49
Function [IUniswapV2Router01.WETH()](src/interfaces/uniswapV2/IUniswapV2Router01.sol#L5) is not in mixedCase

src/interfaces/uniswapV2/IUniswapV2Router01.sol#L5


 - [ ] ID-50
Parameter [MarketFactory.newDexAdapter(address,address,address)._v2Factory](src/core/MarketFactory.sol#L176) is not in mixedCase

src/core/MarketFactory.sol#L176


 - [ ] ID-51
Parameter [MarketFactory.updateMarketParams(uint256,uint256,uint256,uint256,uint256,uint256)._xStartVirtualReserve](src/core/MarketFactory.sol#L133) is not in mixedCase

src/core/MarketFactory.sol#L133


 - [ ] ID-52
Parameter [MarketCurve.initialiseCurve(MarketToken,UniswapV2LiquidityAdapter)._dexAdapter](src/core/MarketCurve.sol#L122) is not in mixedCase

src/core/MarketCurve.sol#L122


INFO:Slither:. analyzed (18 contracts with 94 detectors), 53 result(s) found