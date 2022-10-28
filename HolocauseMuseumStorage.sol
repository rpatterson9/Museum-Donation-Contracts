/*



This contract is to accept and store Eth and ERC20 tokens to be donated
to the Los Angeles Holocause Museum...


Thank you for helping out!

















ps..



F YE!


**/







// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


pragma solidity ^0.8.13;


contract HolocauseMuseumStorage {
    mapping(address => bool) public whitelisted;
    address payable public holocaustMuseum;

    address payable public admin;
    address payable public rabbi;

    // Payable constructor can receive Ether
    constructor(address _admin, address _rabbi) {
        admin = payable(_admin);
        rabbi = payable(_rabbi);
       holocaustMuseum  = payable(0xC1c252BA9625f92703E76AbF39Ae0BD31BdDaCB8);
        
    }

    // send all donated  ERC20s to the holocaustMuseum!  Thank you for your support! 

    function donateToken(address token, uint256 _amount) public payable {
        IERC20(token).transferFrom(msg.sender, address(this), _amount);
    }

    // Function to withdraw all ERC20 token from this contract. (only in emergency)
    function withdrawToken(address token) public onlyAdmin {
        IERC20(token).transferFrom(
            address(this),
            msg.sender,
            IERC20(token).balanceOf(address(this))
        );
    }


  // send all donated ERC20s to the museum

    function sendTokensToMuseum(address token) public onlyAdmin {
        IERC20(token).transferFrom(
            address(this),
          holocaustMuseum,
            IERC20(token).balanceOf(address(this))
        );
    }




    // Function to transfer ERC20 from this contract to address from input
    function transferToken(
        address token,
        address payable _to,
        uint256 _amount
    ) public onlyrabbi isWhitelisted(_to) {
        IERC20(token).transfer(_to, _amount);
    }

    // Function to deposit Ether into this contract.
    // Call this function along with some Ether.
    // The balance of this contract will be automatically updated.
    function donateETH() public payable {}

    // Function to withdraw all Ether from this contract. (only in emergency)
    function withdrawEth() public {
        // get the amount of Ether stored in this contract
        uint256 amount = address(this).balance;

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = admin.call{value: amount}("");
        require(success, "Failed to send Ether");
    }


    // send all donated  Ethereum to the holocaustMuseum!  Thank you .. again!  for your support! 
    function sendEthToMuseum() public {
        // get the amount of Ether stored in this contract
        
        uint256 amount = address(this).balance;

        require(amount > 0, "theres nothing in here...");


        // send all Ether to museum
        (bool success, ) = admin.call{value: amount}("");
        require(success, "Failed to send Ether");
    }


    // Function to transfer Ether from this contract to address from input
    function transferEth(address payable _to, uint256 _amount)
        public
        onlyrabbi
        isWhitelisted(_to)
    {
        // Note that "to" is declared as payable
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    // Admin setter only callable by admin
    function setAdmin(address payable _admin) public onlyAdmin {
        admin = _admin;
    }

    // rabbi setter only callable by admin
    function setrabbi(address payable _rabbi) public onlyAdmin {
        rabbi = _rabbi;
    }

    // Function to whitelist a single address
    function whitelistAddress(address addy) public onlyAdmin {
        whitelisted[addy] = true;
    }

    // Function to whitelist multiple addresses
    function whitelistAddresses(address[] calldata addys) public onlyAdmin {
        for (uint256 i = 0; i < addys.length; i++) {
            whitelisted[addys[i]] = true;
        }
    }

    // Checkcs if msg.sender is admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    // Checkcs if msg.sender is rabbi
    modifier onlyrabbi() {
        require(msg.sender == rabbi, "Not rabbi");
        _;
    }

    // Checkcs address is whitelisted
    modifier isWhitelisted(address addy) {
        require(whitelisted[addy], "Not whitelisted");
        _;
    }

    // Returns ETH balance of this contract
    function getEthBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Returns token balance of this contract
    function getTokenBalance(address token) external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function setMuseumAdd(address _newMuseum) external onlyAdmin {
        holocaustMuseum  = payable(_newMuseum);

    }
}
