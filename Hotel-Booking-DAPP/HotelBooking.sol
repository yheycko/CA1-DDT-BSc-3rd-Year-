/// @title HotelBooking
/// @notice Escrow-based hotel booking. Guest = sender, Hotel = receiver,
///         the blockchain (this contract) = trusted middle layer.
contract HotelBooking {
    enum Status { None, Booked, CheckedIn, Cancelled }

    struct Room {
        uint256 pricePerNight; // in wei
        bool exists;
    }

    struct Booking {
        address guest;      // sender
        uint256 roomId;
        uint256 nights;
        uint256 amount;     // wei held in escrow
        Status status;
    }

    address payable public hotel;               // receiver
    uint256 public bookingCount;
    mapping(uint256 => Room) public rooms;
    mapping(uint256 => Booking) public bookings;
    mapping(uint256 => bool) public roomBusy;   // one active booking per room

    event RoomAdded(uint256 indexed roomId, uint256 pricePerNight);
    event RoomBooked(uint256 indexed bookingId, address indexed guest, uint256 roomId, uint256 amount);
    event CheckedIn(uint256 indexed bookingId, address indexed hotel, uint256 amount);
    event BookingCancelled(uint256 indexed bookingId, address indexed guest, uint256 refund);

    modifier onlyHotel() {
        require(msg.sender == hotel, "Only hotel can do this");
        _;
    }
