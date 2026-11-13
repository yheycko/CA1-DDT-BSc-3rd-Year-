// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Hotel booking with escrow.
// Guest = sender, Hotel owner = receiver, this contract = middle layer.
contract HotelBooking {
    address public owner;                        // the hotel
    mapping(uint => uint) public roomPrice;      // room id => price in wei
    mapping(uint => address) public roomGuest;   // room id => guest who booked
    mapping(uint => uint) public roomPaid;       // room id => money held in escrow

    event RoomAdded(uint id, uint price);
    event RoomBooked(uint id, address guest, uint amount);
    event CheckedIn(uint id, address guest, uint amount);
    event Cancelled(uint id, address guest, uint amount);

    constructor() {
        owner = msg.sender;                      // deployer becomes the hotel owner
    }

    // Hotel adds a room and sets its price
    function addRoom(uint id, uint price) public {
        require(msg.sender == owner, "Only owner");
        require(price > 0, "Price must be above 0");
        require(roomGuest[id] == address(0), "Room is booked");
        roomPrice[id] = price;
        emit RoomAdded(id, price);
    }
 // Guest books a room and pays the exact price into the contract
    function bookRoom(uint id) public payable {
        require(roomPrice[id] > 0, "Room does not exist");
        require(roomGuest[id] == address(0), "Room already booked");
        require(msg.value == roomPrice[id], "Wrong amount");
        roomGuest[id] = msg.sender;
        roomPaid[id] = msg.value;
        emit RoomBooked(id, msg.sender, msg.value);
    }

    // Hotel confirms the guest arrived, money is released to the hotel
    function checkIn(uint id) public {
        require(msg.sender == owner, "Only owner");
        require(roomGuest[id] != address(0), "Room not booked");
        address guest = roomGuest[id];
        uint amount = roomPaid[id];
        delete roomGuest[id];                    // reset BEFORE sending money
        delete roomPaid[id];
        (bool ok, ) = payable(owner).call{value: amount}("");
        require(ok, "Payment failed");
        emit CheckedIn(id, guest, amount);
    }

    // Guest cancels before check-in and gets a full refund
    function cancel(uint id) public {
        require(msg.sender == roomGuest[id], "Only the guest can cancel");
        uint amount = roomPaid[id];
        delete roomGuest[id];                    // reset BEFORE sending money
        delete roomPaid[id];
        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        require(ok, "Refund failed");
        emit Cancelled(id, msg.sender, amount);
    }

    // Money currently held by the contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}







  
