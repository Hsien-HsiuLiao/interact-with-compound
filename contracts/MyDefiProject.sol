pragma solidity ^0.7.3;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './CTokenInterface.sol';
import './ComptrollerInterface.sol';
import './PriceOracle.sol';

contract MyDefiProject {
    ComptrollerInterface public comptroller;
    PriceOracelInterface public priceOracle;

    constructor(
        address _comptroller,
        address _priceOracle
    ) {
        comptroller = ComptrollerInterface(_comptroller);
        priceOracle = PriceOracleInterface(_priceOracle);
    }

//LENDING PART
 //lend token on Compound
 function supply(address cTokenAddress, uint underlyingAmount) external {
     CTokenInterface cToken = CTokenInterface(cTokenAddress);
     address underlyingAddress = cToken.underlying();
     IERC20(underlyingAddress).approve(cTokenAddress, underlyingAmount);
     uint result = cToken.mint(underlyingAmount);
     require(
         result == 0,
         'cToken#mint() failed. see Compound ErrerReporter.sol formore details'
     );
 }

 //once you have your cToken, 
 //you want to redeem it against the underlying token that you initially lent plus interest
function redeem(address CTokenAddress, uint cTokenAmount) external {
    CTokenInterface cToken = CTokenInterface(cTokenAddress);
    uint result = cToken.redeem(cTokenAmount);
     require(
         result == 0,
         'cToken#redeem() failed. see Compound ErrerReporter.sol formore details'
     );
}
//end LENDING part

//BORROWING
//indicate which token to use as collateral
function enterMarket(address cTokenAddress) external {
    address[] memory markets = new address[](1);
    markets[0] = cTokenAddress;
    uint[] memory results = comptroller.enterMarkets(markets);
    require(
        results[0] == 0,
        'comptroller#enterMarkets() failed. see Compound ErrerReporter.sol formore details'
    );
}

function borrow(address cTokenAddress, uint borrowAmount) external {
    CTokenInterface cToken = CTokenInterface(cTokenAddress);
    address underlyingAddress = cToken.underlying();
    uint result = cToken.borrow(borrowAmount);
    require(
        result == 0,
        'cToken#borrow() failed. see Compound ErrerReporter.sol formore details'
    );
}

function repayBorrow(address cTokenAddress, uint underlyingAmount) external {
    CTokenInterface cToken = CTokenInterface(cTokenAddress);
    address underlyingAddress = cToken.underlying();
    IERC20(underlyingAddress).approve(cTokenAddress, underlyingAmount);
    uint result = cToken.repayBorrow(underlyingAmount);
    require(
        result == 0,
        'cToken#repayBorrow() failed. see Compound ErrerReporter.sol formore details'
    );
}

functiongetMaxBorrow(address cTokenAddress) external view returns(uint) {
    (uint result, uint liquidity, uint shortfall) = comptroller.getAccountLiquidity(address(this));
    require(
        result == 0, 
        'comptroller#getAccountLiquidity() failed. see Compound ErrerReporter.sol formore details'
    );
    require(shortfall == 0, 'account underwater');
    require(liquidity > 0, 'account does not have collateral');
    uint underlyingPrice = priceOracle.getUnderlyingPrice(cTokenAddress);
    return liquidity / underlyingPrice;
}

}