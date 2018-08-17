pragma solidity ^0.4.24;

import "node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";
import "node_modules/openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol";
import "contracts/Ownable.sol";

contract Proprty_Contract{
    
    enum ListingStatus {Listed, Bid, Accepted, DepositPaid, Validated, Paid, Completed}
    enum BidStatus {Pending, Accepted, Rejected}
    event ListingEvent(uint deedid, uint256 price, ListingStatus status);
 
   
    struct Deed{
        address owner;
        uint256 value;
    }
    mapping(uint => Deed) public deeds;
    mapping(address => uint[]) ownership;

    struct Listing{
        address seller;
        uint deedid;
        uint256 price;
   //     Bid[] bids; 
        ListingStatus status; 
    }

    struct Bid{
        address bider; 
        uint256 bidValue;
        uint256 depositValue;
    }


  //  uint[] acceptedListing;
    Listing[] ActiveListing;
    address public owner; 
    uint public numberOfListing;

    constructor() public{
        owner = msg.sender;
        deeds[0].owner = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
        deeds[0].value = 100;
        ownership[0xca35b7d915458ef540ade6068dfe2f44e8fa733c] = [0];
        deeds[1].owner = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
        deeds[1].value = 200;
        ownership[0x14723a09acff6d2a60dcdf7aa4aff308fddc160c] = [1];

    }

    function getListings(uint listingid) public returns(address _seller, uint _deedid, uint256 _price, ListingStatus _status){
        return(ActiveListing[listingid].seller, ActiveListing[listingid].deedid, ActiveListing[listingid].price, 
        ActiveListing[listingid].status);
    }
    

    function addListing(uint _deedid, uint256 _price) public returns(address, uint, uint256){
        //check to see if owner owns property
        ActiveListing.push(Listing({
            seller: msg.sender,
            deedid: _deedid,
            price: _price,
    //        [Bid{}],
            status: ListingStatus.Listed
        }));
        numberOfListing++;
        emit ListingEvent(_deedid, _price, ListingStatus.Listed);
    }

    function getLengthOfSellerDeeds() public returns(uint _length){
        return ownership[msg.sender].length;
    }

    function getDeed(uint _deedid) public returns(address _owner, uint256 _value){
        return(deeds[_deedid].owner, deeds[_deedid].value);
    }
}