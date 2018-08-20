pragma solidity ^0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol";
import "./Ownable.sol";

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
        Bid[] bids; 
        ListingStatus status; 
    }

    struct Bid{
        address bidder; 
        uint256 bidValue;
        uint256 depositValue;
        BidStatus bidStatus;
    }

    

  //  uint[] acceptedListing;
    Listing[] ActiveListing;
    address public owner; 
    uint public numberOfListing;
    uint256 private contractAmount;

    modifier isSeller(uint _listingid){
        require(ActiveListing[_listingid].seller == msg.sender, "Not the seller accepting the bid");
        _;
    }
    
    modifier isBidder(uint _listingid, uint _bidid){
        require(ActiveListing[_listingid].bids[_bidid].bidder == msg.sender, "Not the bidder of the bid");
        _;
    }

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
        Listing memory _listing;
        _listing.seller = msg.sender;
        _listing.deedid = _deedid;
        _listing.price = _price;
        _listing.status = ListingStatus.Listed;
        
        ActiveListing.push(_listing);
        numberOfListing++;
        emit ListingEvent(_deedid, _price, ListingStatus.Listed);
    }

    function getLengthOfSellerDeeds() public returns(uint _length){
        return ownership[msg.sender].length;
    }

    function getDeed(uint _deedid) public returns(address _owner, uint256 _value){
        return(deeds[_deedid].owner, deeds[_deedid].value);
    }

    function addBid(uint256 _listingid, uint256 _bidValue, uint256 _depositValue) public{
        // Wanting to add BIDS for a Listing here.
        Bid _bid;
        _bid.bidValue = _bidValue;
        _bid.bidder = msg.sender;
        _bid.depositValue = _depositValue; 
        _bid.bidStatus = BidStatus.Pending;
        ActiveListing[_listingid].bids.push(_bid);
        ActiveListing[_listingid].status = ListingStatus.Bid;
    }

    function acceptBidSeller(uint _listingid, uint _bidid) public isSeller(_listingid){            
        ActiveListing[_listingid].bids[_bidid].bidStatus = BidStatus.Accepted;
        ActiveListing[_listingid].status = ListingStatus.Accepted;
    }

    function payDeposit(uint _listingid, uint _bidid) public payable isBidder(_listingid, _bidid){
        contractAmount += msg.value;
        if(msg.value == ActiveListing[_listingid].bids[_bidid].depositValue){
            ActiveListing[_listingid].status = ListingStatus.DepositPaid;
        }
    }
    
    function validateListing(uint _listingid) public{        
        ActiveListing[_listingid].status = ListingStatus.Validated;
    } 

    function payFullAmount(uint _listingid, uint _bidid) public payable isBidder(_listingid, _bidid){ 
        contractAmount += msg.value;
        if(ActiveListing[_listingid].status == ListingStatus.Validated){
            if(msg.value == (ActiveListing[_listingid].bids[_bidid].bidValue - ActiveListing[_listingid].bids[_bidid].depositValue)){               
                ActiveListing[_listingid].status = ListingStatus.Paid;
             //   We can either do the transfer here? Or let there be like a deeds office that does the offical transfer? I'll program both for now and comment out here
             //   address sellerAddress = ActiveListing[_listingid].seller;
             //   sellerAddress.transfer(ActiveListing[_listingid].bids[_bidid].bidValue);
            }
        }
    }
    function completeTransfer(uint _listingid, uint _bidid) public{
        address sellerAddress = ActiveListing[_listingid].seller;
        sellerAddress.transfer(ActiveListing[_listingid].bids[_bidid].bidValue);
    }
}