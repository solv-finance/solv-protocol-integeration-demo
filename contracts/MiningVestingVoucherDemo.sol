//SPDX-License-Identifier: Unlicense

//WARNING: THIS IS ONLY DEMO, DO NOT APPLY TO PRODUCT ENVIRONMENT

pragma solidity ^0.7.0;

interface IVestingVoucher {
    function mint(
        uint64 term_,
        uint256 amount_,
        uint64[] calldata maturities_,
        uint32[] calldata percentages_,
        string memory originalInvestor_
    ) external returns (uint256, uint256);

    function transferFrom(
        address from,
        address to,
        uint256 voucherId
    ) external;

    function underlying() external view returns (address);

    function vestingPool() external view returns (address);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}

contract MiningVestingVoucherDemo {
    IVestingVoucher public voucher;
    uint256 public unitDecimals = 18;

    mapping(address => uint256) public miningUnits;

    constructor() {
        address solvVoucherAddress = 0x4B0dd1aDEdA251ACec75140608bAd663fB0c4cAB;
        voucher = IVestingVoucher(solvVoucherAddress);
    }

    function depositUnderlying(uint256 amount_) external {
        _doTransferIn(voucher.underlying(), msg.sender, amount_);
    }

    function mining() external {
        miningUnits[msg.sender] += (8 * (10**unitDecimals));
    }

    function claim(uint256 amount_) external {
        uint256 balance = miningUnits[msg.sender];
        require(balance >= amount_, "insufficient balance");
        miningUnits[msg.sender] -= amount_;

        IERC20(voucher.underlying()).approve(
            address(voucher.vestingPool()),
            amount_
        );

        uint64 term = 30 * 86400; // LINEAR release.  if ONE-TIME release, term should be 0
        uint64[] memory maturities = new uint64[](1);
        maturities[0] = uint64(block.timestamp + term);

        uint32[] memory percentages = new uint32[](1);
        percentages[0] = uint32(10000);

        (, uint256 voucherId) = voucher.mint(
            term,
            balance,
            maturities,
            percentages,
            "Mining DEMO"
        );
        voucher.transferFrom(address(this), msg.sender, voucherId);
    }

    function _doTransferIn(
        address underlying,
        address from,
        uint256 amount
    ) internal returns (uint256) {
        require(msg.value == 0, "don't support msg.value");
        uint256 balanceBefore = IERC20(underlying).balanceOf(address(this));
        (bool success, bytes memory data) = underlying.call(
            abi.encodeWithSelector(
                IERC20.transferFrom.selector,
                from,
                address(this),
                amount
            )
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "STF"
        );

        // Calculate the amount that was *actually* transferred
        uint256 balanceAfter = IERC20(underlying).balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "TOKEN_TRANSFER_IN_OVERFLOW");
        return balanceAfter - balanceBefore; // underflow already checked above, just subtract
    }
}
