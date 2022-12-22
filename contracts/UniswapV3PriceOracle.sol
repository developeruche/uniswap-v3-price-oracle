// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;


import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

contract UniswapV3PriceOracle {
    address public immutable token0;
    address public immutable token1;
    address public immutable pool;

    constructor(address _factory, uint24 _fee, address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;

        address _pool = IUniswapV3Factory(_factory).getPool(_token0, _token1, _fee);
        require(_pool != address(0), "pool doesn't exist");
        pool = _pool;
    }


    /// @notice using this function you would be able top get the time weighted average price of token out in terms of token in
    function estimateAmountOut(address _tokenIn, uint128 _amountIn, uint32 _secondsAgo) external view returns (uint256 amountOut_) {
        require(_tokenIn == token0 || _tokenIn == token1, "invaild token");

        address tokenOut = _tokenIn == token0 ? token1 : token0;
        (int24 tick, ) = OracleLibrary.consult(pool, _secondsAgo);
        amountOut_ = OracleLibrary.getQuoteAtTick(
            tick, _amountIn, _tokenIn, tokenOut
        );
    }
}