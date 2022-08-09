// SPDX-License-Identifier: MIT 
/*
          _____                    _____             _____                   _______                   _____                   _______           _____          
         /\    \                  /\    \           /\    \                 /::\    \                 /\    \                 /::\    \         /\    \         
        /::\    \                /::\____\         /::\    \               /::::\    \               /::\    \               /::::\    \       /::\    \        
       /::::\    \              /:::/    /         \:::\    \             /::::::\    \             /::::\    \             /::::::\    \      \:::\    \       
      /::::::\    \            /:::/    /           \:::\    \           /::::::::\    \           /::::::\    \           /::::::::\    \      \:::\    \      
     /:::/\:::\    \          /:::/    /             \:::\    \         /:::/~~\:::\    \         /:::/\:::\    \         /:::/~~\:::\    \      \:::\    \     
    /:::/__\:::\    \        /:::/    /               \:::\    \       /:::/    \:::\    \       /:::/__\:::\    \       /:::/    \:::\    \      \:::\    \    
   /::::\   \:::\    \      /:::/    /                /::::\    \     /:::/    / \:::\    \     /::::\   \:::\    \     /:::/    / \:::\    \     /::::\    \   
  /::::::\   \:::\    \    /:::/    /      _____     /::::::\    \   /:::/____/   \:::\____\   /::::::\   \:::\    \   /:::/____/   \:::\____\   /::::::\    \  
 /:::/\:::\   \:::\    \  /:::/____/      /\    \   /:::/\:::\    \ |:::|    |     |:::|    | /:::/\:::\   \:::\ ___\ |:::|    |     |:::|    | /:::/\:::\    \ 
/:::/  \:::\   \:::\____\|:::|    /      /::\____\ /:::/  \:::\____\|:::|____|     |:::|    |/:::/__\:::\   \:::|    ||:::|____|     |:::|    |/:::/  \:::\____\
\::/    \:::\  /:::/    /|:::|____\     /:::/    //:::/    \::/    / \:::\    \   /:::/    / \:::\   \:::\  /:::|____| \:::\    \   /:::/    //:::/    \::/    /
 \/____/ \:::\/:::/    /  \:::\    \   /:::/    //:::/    / \/____/   \:::\    \ /:::/    /   \:::\   \:::\/:::/    /   \:::\    \ /:::/    //:::/    / \/____/ 
          \::::::/    /    \:::\    \ /:::/    //:::/    /             \:::\    /:::/    /     \:::\   \::::::/    /     \:::\    /:::/    //:::/    /          
           \::::/    /      \:::\    /:::/    //:::/    /               \:::\__/:::/    /       \:::\   \::::/    /       \:::\__/:::/    //:::/    /           
           /:::/    /        \:::\__/:::/    / \::/    /                 \::::::::/    /         \:::\  /:::/    /         \::::::::/    / \::/    /            
          /:::/    /          \::::::::/    /   \/____/                   \::::::/    /           \:::\/:::/    /           \::::::/    /   \/____/             
         /:::/    /            \::::::/    /                               \::::/    /             \::::::/    /             \::::/    /                        
        /:::/    /              \::::/    /                                 \::/____/               \::::/    /               \::/____/                         
        \::/    /                \::/____/                                   ~~                      \::/____/                 ~~                               
         \/____/                  ~~                                                                  ~~                                                        
* Brought to you by Star System Labs
* Otto The AutoBot
*/

pragma solidity ^0.8.15;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract OttoTheAutoBot is ERC20, Ownable, ReentrancyGuard {

  using SafeMath for uint256;

  // variables 
  address public tokenA = 0xECCF35F941Ab67FfcAA9A1265C2fF88865caA005; // WLUNC Terra Bridge Token
  address public tokenB = 0x156ab3346823B651294766e23e6Cf87254d68962; // WLUNA Wormhole Token
  address public tokenC = ; // Moonbase Token
  address public tokenD = ; // Meteor Token
  address public burnAddress = 0x000000000000000000000000000000000000dEaD; 
  address public vault = 0x52FC23AfB047C5eeD7CA5B03F1795CBe2731fFaA; // Star System Labs Vault - MultiSig
  uint256 public totalTokenVaulted = 0;
  uint256 public totalTokenBurnt = 0;
  uint256 public atokenVaulted = 0;
  uint256 public atokenBurnt = 0;
  uint256 public btokenVaulted = 0;
  uint256 public btokenBurnt = 0;

  // Token C Allowance Mapping
  mapping(address => uint256) public aTocTokenTrackerBalance;
  mapping(address => uint256) public bTocTokenTrackerBalance;

  // Token D Allowance Mapping
  mapping(address => uint256) public aTodTokenTrackerBalance;
  mapping(address => uint256) public bTodTokenTrackerBalance;

  // interface
  IERC20 ATOKEN = IERC20(tokenA);
  IERC20 BTOKEN = IERC20(tokenB);
  IERC20 CTOKEN = IERC20(tokenC);
  IERC20 DTOKEN = IERC20(tokenD);

  constructor() ERC20("AutoBot", "Otto"){}

  // ================== A to C Functions START =======================

  // Modifier to check token allowance
    modifier checkAllowanceAtoC(uint256 amountToSend) {
        require(ATOKEN.allowance(msg.sender, address(this)) >= amountToSend, "Error");
        _;
    }

  // Send the token A to contract to transfer later for token C
  function sendTokenAtoC(uint256 amountToSend) checkAllowanceAtoC(amountToSend) public {
   ATOKEN.transferFrom(msg.sender, address(this), amountToSend);
   aTocTokenTrackerBalance[msg.sender] += amountToSend;
  }

  // Swap of Token A for Token C
  function AtoCSwap() public {
    //variable for amount 
    uint256 amountToSend = aTocTokenTrackerBalance[msg.sender];


    // Amounts
    uint256 vaultCut = amountToSend * 70/100;
    uint256 burnCut = amountToSend * 30/100;

    // Requires
    require(amountToSend != 0, 'enter valid amount to send');

    //swap

     ATOKEN.transfer(vault , vaultCut);
     ATOKEN.transfer(burnAddress , burnCut);

     // transfer of token c 
     CTOKEN.transfer(msg.sender, amountToSend * 1/1000);

     // update of mapping
     aTocTokenTrackerBalance[msg.sender] = 0;

    // update of A incrementals
     atokenVaulted += vaultCut;
     atokenBurnt += burnCut;

    // total tracker incrementals
     totalTokenVaulted += vaultCut;
     totalTokenBurnt += burnCut;

  }

  // ================== A to C Functions END =======================

  // ================== B to C Functions START =======================

  // Modifier to check token allowance
    modifier checkAllowanceBtoC(uint256 amountToSend) {
        require(BTOKEN.allowance(msg.sender, address(this)) >= amountToSend, "Error");
        _;
    }

  // Send the token B to contract to transfer later for token C
  function sendTokenBtoC(uint256 amountToSend) checkAllowanceBtoC(amountToSend) public {
   BTOKEN.transferFrom(msg.sender, address(this), amountToSend);
   bTocTokenTrackerBalance[msg.sender] += amountToSend;
  }

  // Swap of Token B for Token C
  function BtoCSwap() public {
    //variable for amount 
    uint256 amountToSend = bTocTokenTrackerBalance[msg.sender];


    // Amounts
    uint256 vaultCut = amountToSend * 70/100;
    uint256 burnCut = amountToSend * 30/100;

    // Requires
    require(amountToSend != 0, 'enter valid amount to send');

    //swap

     BTOKEN.transfer(vault , vaultCut);
     BTOKEN.transfer(burnAddress , burnCut);

     // transfer of token c 
     CTOKEN.transfer(msg.sender, amountToSend * 1/1000);

     // update of mapping
     bTocTokenTrackerBalance[msg.sender] = 0;

    // update of B incrementals
     btokenVaulted += vaultCut;
     btokenBurnt += burnCut;

    // total tracker incrementals
     totalTokenVaulted += vaultCut;
     totalTokenBurnt += burnCut;

  }

  // ================== B to C Functions END =======================

  // ================== A to D Functions START =======================

  // Modifier to check token allowance
    modifier checkAllowanceAtoD(uint256 amountToSend) {
        require(ATOKEN.allowance(msg.sender, address(this)) >= amountToSend, "Error");
        _;
    }

  // Send the token A to contract to transfer later for token D
  function sendTokenAtoD(uint256 amountToSend) checkAllowanceAtoD(amountToSend) public {
   ATOKEN.transferFrom(msg.sender, address(this), amountToSend);
   aTodTokenTrackerBalance[msg.sender] += amountToSend;
  }

  // Swap of Token A For Token D
  function AtoDSwap() public {
    //variable for amount 
    uint256 amountToSend = aTodTokenTrackerBalance[msg.sender];


    // Amounts
    uint256 vaultCut = amountToSend * 70/100;
    uint256 burnCut = amountToSend * 30/100;

    // Requires
    require(amountToSend != 0, 'enter valid amount to send');

    //swap

     ATOKEN.transfer(vault , vaultCut);
     ATOKEN.transfer(burnAddress , burnCut);

     // transfer of token d 
     DTOKEN.transfer(msg.sender, amountToSend * 1/1000000);

     // update of mapping
     aTodTokenTrackerBalance[msg.sender] = 0;

    // update of A incrementals
     atokenVaulted += vaultCut;
     atokenBurnt += burnCut;

    // total tracker incrementals
     totalTokenVaulted += vaultCut;
     totalTokenBurnt += burnCut;

  }

  // ================== A to D Functions END =======================

  // ================== B to D Functions START =======================

  // Modifier to check token allowance
    modifier checkAllowanceBtoD(uint256 amountToSend) {
        require(BTOKEN.allowance(msg.sender, address(this)) >= amountToSend, "Error");
        _;
    }

  // Send the token B to contract to transfer later for token D
  function sendTokenBtoD(uint256 amountToSend) checkAllowanceBtoD(amountToSend) public {
   BTOKEN.transferFrom(msg.sender, address(this), amountToSend);
   bTodTokenTrackerBalance[msg.sender] += amountToSend;
  }

  // Swap of Token B for Token D
  function BtoDSwap() public {
    //variable for amount 
    uint256 amountToSend = bTodTokenTrackerBalance[msg.sender];


    // Amounts
    uint256 vaultCut = amountToSend * 70/100;
    uint256 burnCut = amountToSend * 30/100;

    // Requires
    require(amountToSend != 0, 'enter valid amount to send');

    //swap

     BTOKEN.transfer(vault , vaultCut);
     BTOKEN.transfer(burnAddress , burnCut);

     // transfer of token d 
     DTOKEN.transfer(msg.sender, amountToSend * 1/1000000);

     // update of mapping
     bTodTokenTrackerBalance[msg.sender] = 0;

    // update of B incrementals
     btokenVaulted += vaultCut;
     btokenBurnt += burnCut;

    // total tracker incrementals
     totalTokenVaulted += vaultCut;
     totalTokenBurnt += burnCut;

  }

  // ================== B to D Functions END =======================

  // ================== Control Panel Functions START =======================

  function setConfigAddresses(address _tokenA,address _tokenB,address _tokenC,address _tokenD,address _vault) public onlyOwner {
      tokenA = _tokenA;
      tokenB = _tokenB;
      tokenC = _tokenC;
      tokenD = _tokenD;
      vault = _vault;

  }

  function withdrawTokens(address _tokenContract, uint256 _amount) external {
    IERC20 tokenContract = IERC20(_tokenContract);
    tokenContract.transfer(msg.sender, _amount);
  } 

  // ================== Control Panel Functions END =======================
}